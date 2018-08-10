--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity jh512_reference is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  data_in                               : in std_logic_vector(511 downto 0);
  hash                                  : out std_logic_vector(511 downto 0);
  hash_new                              : out std_logic
);
end entity jh512_reference;

architecture jh512_reference_rtl of jh512_reference is
  
  alias slv is std_logic_vector;
  
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  type nat_array_8 is array(0 to 7) of natural;
  type nat_array_4 is array(0 to 3) of natural;
  type jh512_state is (IDLE, INIT, E, H_GEN, FINISH);
                        
  constant zeros64 : word64 := (others => '0');
  
  function endian_swap(x: word64) return word64 is
  begin
    return word64(x(7 downto 0)   & x(15 downto 8)  & x(23 downto 16) & x(31 downto 24) &
                  x(39 downto 32) & x(47 downto 40) & x(55 downto 48) & x(63 downto 56));
  end endian_swap;
  
  function shr(x: word64; n: natural) return word64 is
  begin
    return word64(zeros64(n-1 downto 0) & x(x'high downto n));
  end shr;
  
  function shl(x: word64; n: natural) return word64 is
  begin
    return word64(x(x'high-n downto 0) & zeros64(x'high downto x'length-n));
  end shl;
  
  function rotr(x: word64; n: natural) return word64 is
  begin
    return word64(x(n-1 downto 0) & x(x'high downto n));
  end rotr;
  
  function rotl(x: word64; n: natural) return word64 is
  begin
    return word64(x(x'high-n downto 0) & x(x'high downto x'length-n));
  end rotl;
  
  type word64_array168 is array(0 to 167) of word64;
  type word64_array16 is array(0 to 15) of word64;
  type word64_array8 is array(0 to 7) of word64;
  type word64_array4 is array(0 to 3) of word64;
  type word64_array2 is array(0 to 1) of word64;
  
  constant IV                           : word64_array16 := (X"6fd14b963e00aa17", X"636a2e057a15d543",
                                                             X"8a225e8d0c97ef0b", X"e9341259f2b3c361",
                                                             X"891da0c1536f801e", X"2aa9056bea2b6d80",
                                                             X"588eccdb2075baa6", X"a90f3a76baf83bf7",
                                                             X"0169e60541e34a69", X"46b58a8e2e6fe65a",
                                                             X"1047a7d0c1843c24", X"3b6e71b12d5ac199",
                                                             X"cf57f6ec9db1f856", X"a706887c5716b156",
                                                             X"e3c2fcdfe68517fb", X"545a4678cc8cdd4b");
  constant PADDING                      : word64_array8 := (X"0000000000000080", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0002000000000000");
  constant C                            : word64_array168 := (X"72d5dea2df15f867", X"7b84150ab7231557",
                                                              X"81abd6904d5a87f6", X"4e9f4fc5c3d12b40",
                                                              X"ea983ae05c45fa9c", X"03c5d29966b2999a",
                                                              X"660296b4f2bb538a", X"b556141a88dba231",
                                                              X"03a35a5c9a190edb", X"403fb20a87c14410",
                                                              X"1c051980849e951d", X"6f33ebad5ee7cddc",
                                                              X"10ba139202bf6b41", X"dc786515f7bb27d0",
                                                              X"0a2c813937aa7850", X"3f1abfd2410091d3",
                                                              X"422d5a0df6cc7e90", X"dd629f9c92c097ce",
                                                              X"185ca70bc72b44ac", X"d1df65d663c6fc23",
                                                              X"976e6c039ee0b81a", X"2105457e446ceca8",
                                                              X"eef103bb5d8e61fa", X"fd9697b294838197",
                                                              X"4a8e8537db03302f", X"2a678d2dfb9f6a95",
                                                              X"8afe7381f8b8696c", X"8ac77246c07f4214",
                                                              X"c5f4158fbdc75ec4", X"75446fa78f11bb80",
                                                              X"52de75b7aee488bc", X"82b8001e98a6a3f4",
                                                              X"8ef48f33a9a36315", X"aa5f5624d5b7f989",
                                                              X"b6f1ed207c5ae0fd", X"36cae95a06422c36",
                                                              X"ce2935434efe983d", X"533af974739a4ba7",
                                                              X"d0f51f596f4e8186", X"0e9dad81afd85a9f",
                                                              X"a7050667ee34626a", X"8b0b28be6eb91727",
                                                              X"47740726c680103f", X"e0a07e6fc67e487b",
                                                              X"0d550aa54af8a4c0", X"91e3e79f978ef19e",
                                                              X"8676728150608dd4", X"7e9e5a41f3e5b062",
                                                              X"fc9f1fec4054207a", X"e3e41a00cef4c984",
                                                              X"4fd794f59dfa95d8", X"552e7e1124c354a5",
                                                              X"5bdf7228bdfe6e28", X"78f57fe20fa5c4b2",
                                                              X"05897cefee49d32e", X"447e9385eb28597f",
                                                              X"705f6937b324314a", X"5e8628f11dd6e465",
                                                              X"c71b770451b920e7", X"74fe43e823d4878a",
                                                              X"7d29e8a3927694f2", X"ddcb7a099b30d9c1",
                                                              X"1d1b30fb5bdc1be0", X"da24494ff29c82bf",
                                                              X"a4e7ba31b470bfff", X"0d324405def8bc48",
                                                              X"3baefc3253bbd339", X"459fc3c1e0298ba0",
                                                              X"e5c905fdf7ae090f", X"947034124290f134",
                                                              X"a271b701e344ed95", X"e93b8e364f2f984a",
                                                              X"88401d63a06cf615", X"47c1444b8752afff",
                                                              X"7ebb4af1e20ac630", X"4670b6c5cc6e8ce6",
                                                              X"a4d5a456bd4fca00", X"da9d844bc83e18ae",
                                                              X"7357ce453064d1ad", X"e8a6ce68145c2567",
                                                              X"a3da8cf2cb0ee116", X"33e906589a94999a",
                                                              X"1f60b220c26f847b", X"d1ceac7fa0d18518",
                                                              X"32595ba18ddd19d3", X"509a1cc0aaa5b446",
                                                              X"9f3d6367e4046bba", X"f6ca19ab0b56ee7e",
                                                              X"1fb179eaa9282174", X"e9bdf7353b3651ee",
                                                              X"1d57ac5a7550d376", X"3a46c2fea37d7001",
                                                              X"f735c1af98a4d842", X"78edec209e6b6779",
                                                              X"41836315ea3adba8", X"fac33b4d32832c83",
                                                              X"a7403b1f1c2747f3", X"5940f034b72d769a",
                                                              X"e73e4e6cd2214ffd", X"b8fd8d39dc5759ef",
                                                              X"8d9b0c492b49ebda", X"5ba2d74968f3700d",
                                                              X"7d3baed07a8d5584", X"f5a5e9f0e4f88e65",
                                                              X"a0b8a2f436103b53", X"0ca8079e753eec5a",
                                                              X"9168949256e8884f", X"5bb05c55f8babc4c",
                                                              X"e3bb3b99f387947b", X"75daf4d6726b1c5d",
                                                              X"64aeac28dc34b36d", X"6c34a550b828db71",
                                                              X"f861e2f2108d512a", X"e3db643359dd75fc",
                                                              X"1cacbcf143ce3fa2", X"67bbd13c02e843b0",
                                                              X"330a5bca8829a175", X"7f34194db416535c",
                                                              X"923b94c30e794d1e", X"797475d7b6eeaf3f",
                                                              X"eaa8d4f7be1a3921", X"5cf47e094c232751",
                                                              X"26a32453ba323cd2", X"44a3174a6da6d5ad",
                                                              X"b51d3ea6aff2c908", X"83593d98916b3c56",
                                                              X"4cf87ca17286604d", X"46e23ecc086ec7f6",
                                                              X"2f9833b3b1bc765e", X"2bd666a5efc4e62a",
                                                              X"06f4b6e8bec1d436", X"74ee8215bcef2163",
                                                              X"fdc14e0df453c969", X"a77d5ac406585826",
                                                              X"7ec1141606e0fa16", X"7e90af3d28639d3f",
                                                              X"d2c9f2e3009bd20c", X"5faace30b7d40c30",
                                                              X"742a5116f2e03298", X"0deb30d8e3cef89a",
                                                              X"4bc59e7bb5f17992", X"ff51e66e048668d3",
                                                              X"9b234d57e6966731", X"cce6a6f3170a7505",
                                                              X"b17681d913326cce", X"3c175284f805a262",
                                                              X"f42bcbb378471547", X"ff46548223936a48",
                                                              X"38df58074e5e6565", X"f2fc7c89fc86508e",
                                                              X"31702e44d00bca86", X"f04009a23078474e",
                                                              X"65a0ee39d1f73883", X"f75ee937e42c3abd",
                                                              X"2197b2260113f86f", X"a344edd1ef9fdee7",
                                                              X"8ba0df15762592d9", X"3c85f7f612dc42be",
                                                              X"d8a7ec7cab27b07e", X"538d7ddaaa3ea8de",
                                                              X"aa25ce93bd0269d8", X"5af643fd1a7308f9",
                                                              X"c05fefda174a19a5", X"974d66334cfd216a",
                                                              X"35b49831db411570", X"ea1e0fbbedcd549b",
                                                              X"9ad063a151974072", X"f6759dbf91476fe2");

  
  function c_rj(r: natural; j: natural) return word64 is
  begin
    return endian_swap(C(to_integer(to_unsigned(r,8) & "00" + j)));
  end function c_rj;
  
  function sb(x: word64_array4; r: natural; j: natural) return word64_array4 is
    variable x2                         : word64_array4;
    variable t                          : word64;
  begin
    x2(3)                               := not x(3);
    x2(0)                               := x(0) xor (c_rj(r,j) and not x(2));
    t                                   := c_rj(r,j) xor (x2(0) and x(1));
    x2(0)                               := x2(0) xor (x(2) and x2(3));
    x2(3)                               := x2(3) xor (not x(1) and x(2));
    x2(1)                               := x(1) xor (x2(0) and x(2));
    x2(2)                               := x(2) xor (x2(0) and not x2(3));
    x2(0)                               := x2(0) xor (x2(1) or x2(3));
    x2(3)                               := x2(3) xor (x2(1) and x2(2));
    x2(1)                               := x2(1) xor (t and x2(0));
    x2(2)                               := x2(2) xor t;
    return x2;
  end function sb;
  
  function lb(x: word64_array8) return word64_array8 is
    variable x2                         : word64_array8;
  begin
    x2(4)                               := x(4) xor x(1);
    x2(5)                               := x(5) xor x(2);
    x2(6)                               := x(6) xor (x(3) xor x(0));
    x2(7)                               := x(7) xor x(0);
    x2(0)                               := x(0) xor x2(5);
    x2(1)                               := x(1) xor x2(6);
    x2(2)                               := x(2) xor (x2(7) xor x2(4));
    x2(3)                               := x(3) xor x2(4);
    return x2;
  end function lb;
  
  function s(x: word64_array8; r: natural; even: std_logic) return word64_array8 is
    variable j_offset                   : natural;
    variable x2                         : word64_array8;
  begin
    if even = '0' then
      j_offset                          := 2;
    else
      j_offset                          := 0;
    end if;
    (x2(0),x2(2),x2(4),x2(6))           := sb((x(0),x(2),x(4),x(6)), r, j_offset);
    (x2(1),x2(3),x2(5),x2(7))           := sb((x(1),x(3),x(5),x(7)), r, j_offset+1);
    return x2;
  end function s;
  
  function l(x: word64_array16) return word64_array16 is
    variable x2                         : word64_array16;  
  begin
    (x2(0),x2(2),x2(4),x2(6),x2(8),x2(10),x2(12),x2(14)) := lb((x(0),x(2),x(4),x(6),x(8),x(10),x(12),x(14)));
    (x2(1),x2(3),x2(5),x2(7),x2(9),x2(11),x2(13),x2(15)) := lb((x(1),x(3),x(5),x(7),x(9),x(11),x(13),x(15)));
    return x2;
  end function l;
  
  function w_0_5(x: word64_array2; c: word64; n: natural) return word64_array2 is
    variable x2                         : word64_array2;
    variable t                          : word64;
  begin
    t                                   := rotl(x(0) and c,n);
    x2(0)                               := (rotr(x(0),n) and c) or t;
    t                                   := rotl(x(1) and c,n);
    x2(1)                               := (rotr(x(1),n) and c) or t;
    return x2;
  end function w_0_5;
  
  function w(x: word64_array2; k: slv(2 downto 0)) return word64_array2 is
    variable x2                         : word64_array2;
    variable t                          : word64;
  begin
    case k is
    when "000" =>
      x2                                := w_0_5(x,X"5555555555555555",1);
    when "001" =>
      x2                                := w_0_5(x,X"3333333333333333",2);
    when "010" =>
      x2                                := w_0_5(x,X"0F0F0F0F0F0F0F0F",4);
    when "011" =>
      x2                                := w_0_5(x,X"00FF00FF00FF00FF",8);
    when "100" =>
      x2                                := w_0_5(x,X"0000FFFF0000FFFF",16);
    when "101" =>
      x2                                := w_0_5(x,X"00000000FFFFFFFF",32);
    when "110" =>
      x2                                := (x(1),x(0));
    when others =>
      null;
    end case;
    return x2;
  end function w;
  
  function slu(h: word64_array16; r: natural) return word64_array16 is
    variable h2                         : word64_array16;
  begin
    (h2(0),h2(1),h2(4),h2(5),h2(8),h2(9),h2(12),h2(13)) := s((h(0),h(1),h(4),h(5),h(8),h(9),h(12),h(13)), r, '1');
    (h2(2),h2(3),h2(6),h2(7),h2(10),h2(11),h2(14),h2(15)) := s((h(2),h(3),h(6),h(7),h(10),h(11),h(14),h(15)), r, '0');
    (h2(0),h2(1),h2(4),h2(5),h2(8),h2(9),h2(12),h2(13),h2(2),h2(3),h2(6),h2(7),h2(10),h2(11),h2(14),h2(15)) := l((h2(0),h2(1),h2(4),h2(5),h2(8),h2(9),h2(12),h2(13),h2(2),h2(3),h2(6),h2(7),h2(10),h2(11),h2(14),h2(15)));
    (h2(2),h2(3))                       := w((h2(2),h2(3)), slv(to_unsigned(r mod 7,3)));
    (h2(6),h2(7))                       := w((h2(6),h2(7)), slv(to_unsigned(r mod 7,3)));
    (h2(10),h2(11))                     := w((h2(10),h2(11)), slv(to_unsigned(r mod 7,3)));
    (h2(14),h2(15))                     := w((h2(14),h2(15)), slv(to_unsigned(r mod 7,3)));
    return h2;
  end function slu;
  
  function e(h: word64_array16) return word64_array16 is
    variable h2                         : word64_array16;
  begin
    h2                                  := h;
    for r in 0 to 41 loop
      h2                                := slu(h2, r);
    end loop;
    return h2;
  end function e;
  
  signal jh512_state_next               : jh512_state;
  signal last_pass                      : std_logic;
  signal data_in_array                  : word64_array8;
  signal m                              : word64_array8;
  signal h                              : word64_array16;
  signal done                           : std_logic;

  signal q_jh512_state                  : jh512_state;
  signal q_last_pass                    : std_logic;
  signal q_m                            : word64_array8;
  signal q_h                            : word64_array16;
  
begin

  hash_new                              <= done;
  
  output_mapping : for i in 0 to 7 generate
    hash((i+1)*64-1 downto i*64)        <= q_h(8+i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 7 generate
    data_in_array(i)                    <= data_in((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  jh512_proc : process(q_jh512_state, q_last_pass, q_m, q_h, data_in_array, start)
  begin
    jh512_state_next                    <= q_jh512_state;
    last_pass                           <= q_last_pass;
    m                                   <= q_m;
    h                                   <= q_h;
    done                                <= '0';
    case q_jh512_state is
    when IDLE =>
      last_pass                         <= '0';
      m                                 <= data_in_array;
      if start = '1' then
        for i in 0 to 15 loop
          h(i)                          <= endian_swap(IV(i));
        end loop;
        jh512_state_next                <= INIT;
      end if;
    when INIT =>
      for i in 0 to 7 loop
        h(i)                            <= q_h(i) xor q_m(i);
      end loop;
      jh512_state_next                  <= E;
    when E =>
      h                                 <= e(q_h);
      jh512_state_next                  <= H_GEN;
    when H_GEN =>
      for i in 0 to 7 loop
        h(8+i)                          <= q_h(8+i) xor q_m(i);
      end loop;
      if q_last_pass = '1' then
        jh512_state_next                <= FINISH;
      else
        last_pass                       <= '1';
        m                               <= PADDING;
        jh512_state_next                <= INIT;
      end if;
    when FINISH =>
      done                              <= '1';
      jh512_state_next                  <= IDLE;
    end case;
  end process jh512_proc;

  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_jh512_state                     <= IDLE;
    elsif rising_edge(clk) then
      q_jh512_state                     <= jh512_state_next;
      q_last_pass                       <= last_pass;
      q_m                               <= m;
      q_h                               <= h;
    end if;
  end process registers;
  
end architecture jh512_reference_rtl;