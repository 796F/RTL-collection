--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak512_reference is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  data_in                               : in std_logic_vector(511 downto 0);
  hash                                  : out std_logic_vector(511 downto 0);
  hash_new                              : out std_logic
);
end entity keccak512_reference;

architecture keccak512_reference_rtl of keccak512_reference is
  
  alias slv is std_logic_vector;
  
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  type nat_array_25 is array(0 to 24) of natural;
  type array_24_nat_array_25 is array(0 to 23) of nat_array_25;
  type keccak512_state is (IDLE, EXEC, H_GEN, FINISH);
                        
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
  
  type word64_array25 is array(0 to 24) of word64;
  type word64_array24 is array(0 to 23) of word64;
  type word64_array10 is array(0 to 9) of word64;
  type word64_array8 is array(0 to 7) of word64;
  type word64_array5 is array(0 to 4) of word64;
  type word64_array3 is array(0 to 2) of word64;
  
  function th_elt(x: word64_array10) return word64 is
    variable t                          : word64_array3;
  begin
    t(0)                                := x(5) xor x(6);
    t(1)                                := x(7) xor x(8);
    t(0)                                := t(0) xor x(9);
    t(0)                                := rotl(t(0) xor t(1),1);
    t(0)                                := t(0) xor x(4);
    t(1)                                := x(0) xor x(1);
    t(2)                                := x(2) xor x(3);
    t(1)                                := t(1) xor t(2);
    return word64(t(0) xor t(1));
  end th_elt;
  
  function theta(x: word64_array25) return word64_array25 is
    variable t                          : word64_array5;
    variable x2                         : word64_array25;
  begin
    t(0)                                := th_elt((x(20),x(21),x(22),x(23),x(24),x(5),x(6),x(7),x(8),x(9)));
    t(1)                                := th_elt((x(0),x(1),x(2),x(3),x(4),x(10),x(11),x(12),x(13),x(14)));
    t(2)                                := th_elt((x(5),x(6),x(7),x(8),x(9),x(15),x(16),x(17),x(18),x(19)));
    t(3)                                := th_elt((x(10),x(11),x(12),x(13),x(14),x(20),x(21),x(22),x(23),x(24)));
    t(4)                                := th_elt((x(15),x(16),x(17),x(18),x(19),x(0),x(1),x(2),x(3),x(4)));
    for i in 0 to 24 loop
      x2(i)                             := x(i) xor t(i/5);
    end loop;
    return x2;
  end theta;
  
  constant R                            : nat_array_25 := (0,36,3,41,18,1,44,10,45,2,62,6,43,15,61,28,55,25,21,56,27,20,39,8,14);
  
  function rho(x: word64_array25) return word64_array25 is
    variable x2                         : word64_array25;
  begin
    for i in 0 to 24 loop
      x2(i)                             := rotl(x(i),R(i));
    end loop;
    return x2;
  end rho;
  
  function khi_x0(x: word64_array3) return word64 is
  begin
    return word64(x(0) xor (x(1) or x(2)));
  end khi_x0;
  
  function khi_xa(x: word64_array3) return word64 is
  begin
    return word64(x(0) xor (x(1) and x(2)));
  end khi_xa;
  
  function khi(x: word64_array25) return word64_array25 is
    variable x2                         : word64_array25;
    variable t                          : word64;
  begin
    t                                   := not x(10);
    x2(0)                               := khi_x0( (x(0), x(5),x(10)));
    x2(5)                               := khi_x0( (x(5),    t,x(15)));
    x2(10)                              := khi_xa((x(10),x(15),x(20)));
    x2(15)                              := khi_x0((x(15),x(20), x(0)));
    x2(20)                              := khi_xa((x(20), x(0), x(5)));
    t                                   := not x(21);
    x2(1)                               := khi_x0(( x(1), x(6),x(11)));
    x2(6)                               := khi_xa(( x(6),x(11),x(16)));
    x2(11)                              := khi_x0((x(11),x(16),    t));
    x2(16)                              := khi_x0((x(16),x(21), x(1)));
    x2(21)                              := khi_xa((x(21), x(1), x(6)));
    t                                   := not x(17);
    x2(2)                               := khi_x0(( x(2), x(7),x(12)));
    x2(7)                               := khi_xa(( x(7),x(12),x(17)));
    x2(12)                              := khi_xa((x(12),    t,x(22)));
    x2(17)                              := khi_x0((    t,x(22), x(2)));
    x2(22)                              := khi_xa((x(22), x(2), x(7)));    
    t                                   := not x(18);
    x2(3)                               := khi_xa(( x(3), x(8),x(13)));
    x2(8)                               := khi_x0(( x(8),x(13),x(18)));
    x2(13)                              := khi_x0((x(13),    t,x(23)));
    x2(18)                              := khi_xa((    t,x(23), x(3)));
    x2(23)                              := khi_x0((x(23), x(3), x(8)));
    t                                   := not x(9);
    x2(4)                               := khi_xa(( x(4),    t,x(14)));
    x2(9)                               := khi_x0((    t,x(14),x(19)));
    x2(14)                              := khi_xa((x(14),x(19),x(24)));
    x2(19)                              := khi_x0((x(19),x(24), x(4)));
    x2(24)                              := khi_xa((x(24), x(4), x(9)));
    return x2;
  end khi;
  
  constant IND : array_24_nat_array_25  := ((0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24),
                                            (0,15,5,20,10,6,21,11,1,16,12,2,17,7,22,18,8,23,13,3,24,14,4,19,9),
                                            (0,18,6,24,12,21,14,2,15,8,17,5,23,11,4,13,1,19,7,20,9,22,10,3,16),
                                            (0,13,21,9,17,14,22,5,18,1,23,6,19,2,10,7,15,3,11,24,16,4,12,20,8),
                                            (0,7,14,16,23,22,4,6,13,15,19,21,3,5,12,11,18,20,2,9,8,10,17,24,1),
                                            (0,11,22,8,19,4,10,21,7,18,3,14,20,6,17,2,13,24,5,16,1,12,23,9,15),
                                            (0,2,4,1,3,10,12,14,11,13,20,22,24,21,23,5,7,9,6,8,15,17,19,16,18),
                                            (0,5,10,15,20,12,17,22,2,7,24,4,9,14,19,6,11,16,21,1,18,23,3,8,13),
                                            (0,6,12,18,24,17,23,4,5,11,9,10,16,22,3,21,2,8,14,15,13,19,20,1,7),
                                            (0,21,17,13,9,23,19,10,6,2,16,12,8,4,20,14,5,1,22,18,7,3,24,15,11),
                                            (0,14,23,7,16,19,3,12,21,5,8,17,1,10,24,22,6,15,4,13,11,20,9,18,2),
                                            (0,22,19,11,8,3,20,17,14,6,1,23,15,12,9,4,21,18,10,7,2,24,16,13,5),
                                            (0,4,3,2,1,20,24,23,22,21,15,19,18,17,16,10,14,13,12,11,5,9,8,7,6),
                                            (0,10,20,5,15,24,9,19,4,14,18,3,13,23,8,12,22,7,17,2,6,16,1,11,21),
                                            (0,12,24,6,18,9,16,3,10,22,13,20,7,19,1,17,4,11,23,5,21,8,15,2,14),
                                            (0,17,9,21,13,16,8,20,12,4,7,24,11,3,15,23,10,2,19,6,14,1,18,5,22),
                                            (0,23,16,14,7,8,1,24,17,10,11,9,2,20,18,19,12,5,3,21,22,15,13,6,4),
                                            (0,19,8,22,11,1,15,9,23,12,2,16,5,24,13,3,17,6,20,14,4,18,7,21,10),
                                            (0,3,1,4,2,15,18,16,19,17,5,8,6,9,7,20,23,21,24,22,10,13,11,14,12),
                                            (0,20,15,10,5,18,13,8,3,23,6,1,21,16,11,24,19,14,9,4,12,7,2,22,17),
                                            (0,24,18,12,6,13,7,1,20,19,21,15,14,8,2,9,3,22,16,10,17,11,5,4,23),
                                            (0,9,13,17,21,7,11,15,24,3,14,18,22,1,5,16,20,4,8,12,23,2,6,10,19),
                                            (0,16,7,23,14,11,2,18,9,20,22,13,4,15,6,8,24,10,1,17,19,5,21,12,3),
                                            (0,8,11,19,22,2,5,13,16,24,4,7,10,18,21,1,9,12,15,23,3,6,14,17,20));
    constant RC                           : word64_array24 := (X"0000000000000001", X"0000000000008082",
                                                               X"800000000000808A", X"8000000080008000",
                                                               X"000000000000808B", X"0000000080000001",
                                                               X"8000000080008081", X"8000000000008009",
                                                               X"000000000000008A", X"0000000000000088",
                                                               X"0000000080008009", X"000000008000000A",
                                                               X"000000008000808B", X"800000000000008B",
                                                               X"8000000000008089", X"8000000000008003",
                                                               X"8000000000008002", X"8000000000000080",
                                                               X"000000000000800A", X"800000008000000A",
                                                               X"8000000080008081", X"8000000000008080",
                                                               X"0000000080000001", X"8000000080008008");
  
  function kf_elt(x: word64_array25; i: natural; j: natural; k: natural) return word64_array25 is
    variable x2                         : word64_array25;
    variable x3                         : word64_array25;
    variable x4                         : word64_array25;
    variable x5                         : word64_array25;
    variable x6                         : word64_array25;
  begin
    for l in 0 to 24 loop
      x2(l)                             := x(IND(i)(l));
    end loop;
    x2                                  := theta(x2);
    x2                                  := rho(x2);
    for l in 0 to 24 loop
      x3(IND(i)(l))                     := x2(l);
    end loop;
    for l in 0 to 24 loop
      x4(l)                             := x3(IND(j)(l));
    end loop;
    x4                                  := khi(x4);
    for l in 0 to 24 loop
      x5(IND(j)(l))                     := x4(l);
    end loop;
    x5(0)                               := x5(0) xor RC(k);
    x6                                  := x5;
    if i = 7 then
      x6(1)                             := x5(6);
      x6(6)                             := x5(23);
      x6(23)                            := x5(1);
      x6(2)                             := x5(12);
      x6(12)                            := x5(16);
      x6(16)                            := x5(2);
      x6(3)                             := x5(18);
      x6(18)                            := x5(14);
      x6(14)                            := x5(3);
      x6(4)                             := x5(24);
      x6(24)                            := x5(7);
      x6(7)                             := x5(4);
      x6(5)                             := x5(17);
      x6(17)                            := x5(8);
      x6(8)                             := x5(5);
      x6(9)                             := x5(11);
      x6(11)                            := x5(10);
      x6(10)                            := x5(9);
      x6(13)                            := x5(22);
      x6(22)                            := x5(20);
      x6(20)                            := x5(13);
      x6(15)                            := x5(21);
      x6(21)                            := x5(19);
      x6(19)                            := x5(15);
    end if;
    return x6;
  end kf_elt;
  
  function keccak_f(x: word64_array25) return word64_array25 is
    variable x2                         : word64_array25;
  begin
    x2                                  := x;
    for i in 0 to 23 loop
      x2                                := kf_elt(x2,i mod 8,(i mod 8)+1,i);
    end loop;
    return x2;
  end keccak_f;
  
  function gen_h(x: word64_array25) return word64_array25 is
    variable x2                         : word64_array25;
  begin
    for i in 0 to 24 loop
      x2(i)                             := x((i mod 5)*5 + i/5);
    end loop;
    x2(1)                               := not x2(1);
    x2(2)                               := not x2(2);
    x2(8)                               := not x2(8);
    x2(12)                              := not x2(12);
    x2(17)                              := not x2(17);
    x2(20)                              := not x2(20);
    return x2;
  end function gen_h;
  
  constant IV                           : word64_array25 := (X"0000000000000000",X"0000000000000000",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"FFFFFFFFFFFFFFFF",X"FFFFFFFFFFFFFFFF",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"FFFFFFFFFFFFFFFF",X"0000000000000000",
                                                             X"FFFFFFFFFFFFFFFF",X"FFFFFFFFFFFFFFFF",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"FFFFFFFFFFFFFFFF",X"0000000000000000",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"0000000000000000");
  constant PADDING                      : word64 := X"8000000000000001";
  
  signal keccak512_state_next           : keccak512_state;
  signal data_in_array                  : word64_array8;
  signal h                              : word64_array25;
  signal done                           : std_logic;
  
  signal q_keccak512_state              : keccak512_state;
  signal q_h                            : word64_array25;
  
begin

  hash_new                              <= done;
  
  output_mapping : for i in 0 to 7 generate
    hash((i+1)*64-1 downto i*64)        <= q_h(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 7 generate
    data_in_array(i)                    <= data_in((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  keccak512_proc : process(q_keccak512_state, q_h, start, data_in_array)
  begin
    keccak512_state_next                <= q_keccak512_state;
    h                                   <= q_h;
    done                                <= '0';
    case q_keccak512_state is
    when IDLE =>
      if start = '1' then
        h                               <= IV;
        h(0)                            <= IV(0) xor data_in_array(0);
        h(5)                            <= IV(5) xor data_in_array(1);
        h(10)                           <= IV(10) xor data_in_array(2);
        h(15)                           <= IV(15) xor data_in_array(3);
        h(20)                           <= IV(20) xor data_in_array(4);
        h(1)                            <= IV(1) xor data_in_array(5);
        h(6)                            <= IV(6) xor data_in_array(6);
        h(11)                           <= IV(11) xor data_in_array(7);
        h(16)                           <= IV(16) xor PADDING;
        keccak512_state_next            <= EXEC;
      end if;
    when EXEC =>
      h                                 <= keccak_f(q_h);
      keccak512_state_next              <= H_GEN;
    when H_GEN =>
      h                                 <= gen_h(q_h);
      keccak512_state_next              <= FINISH;
    when FINISH =>
      done                              <= '1';
      keccak512_state_next              <= IDLE;
    end case;
  end process keccak512_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_keccak512_state                 <= IDLE;
    elsif rising_edge(clk) then
      q_keccak512_state                 <= keccak512_state_next;
      q_h                               <= h;
    end if;
  end process registers;
  
end architecture keccak512_reference_rtl;