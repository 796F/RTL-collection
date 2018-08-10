--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity groestl512_reference is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  data_in                               : in std_logic_vector(511 downto 0);
  hash                                  : out std_logic_vector(511 downto 0);
  hash_new                              : out std_logic
);
end entity groestl512_reference;

architecture groestl512_reference_rtl of groestl512_reference is
  
  alias slv is std_logic_vector;
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  subtype natural_0_7 is natural range 0 to 7;
  type nat_array_8 is array(0 to 7) of natural;
  type groestl512_state is (IDLE, EXEC_0, EXEC_1, EXEC_2, EXEC_3, EXEC_4, FINISH);
                        
  constant zeros64 : word64 := (others => '0');
  
  function byte_sel(x: word64; n: natural_0_7) return unsigned is
  begin
    return unsigned(x((n+1)*8-1 downto n*8));
  end byte_sel;
  
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
  
  function pc64(j: word64; r: natural) return word64 is
  begin
    return slv(unsigned(j) + to_unsigned(r,64));
  end function pc64;
  
  function qc64(j: word64; r: natural) return word64 is
  begin
    return word64(shl(slv(to_unsigned(r,64)),56) xnor shl(slv(j),56));
  end function qc64;
  
  type word64_array256 is array(0 to 255) of word64;
  type word64_array32 is array(0 to 31) of word64;
  type word64_array16 is array(0 to 15) of word64;
  type word64_array8 is array(0 to 7) of word64;
  
  constant IV                           : word64_array16 := (X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0002000000000000");
  constant PADDING                      : word64_array8 := (X"0000000000000080", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0100000000000000");
  constant T0                           : word64_array256 := (X"c632f4a5f497a5c6", X"f86f978497eb84f8",
                                                              X"ee5eb099b0c799ee", X"f67a8c8d8cf78df6",
                                                            	X"ffe8170d17e50dff", X"d60adcbddcb7bdd6",
	                                                            X"de16c8b1c8a7b1de", X"916dfc54fc395491",
	                                                            X"6090f050f0c05060", X"0207050305040302",
	                                                            X"ce2ee0a9e087a9ce", X"56d1877d87ac7d56",
	                                                            X"e7cc2b192bd519e7", X"b513a662a67162b5",
	                                                            X"4d7c31e6319ae64d", X"ec59b59ab5c39aec",
	                                                            X"8f40cf45cf05458f", X"1fa3bc9dbc3e9d1f",
	                                                            X"8949c040c0094089", X"fa68928792ef87fa",
	                                                            X"efd03f153fc515ef", X"b29426eb267febb2",
	                                                            X"8ece40c94007c98e", X"fbe61d0b1ded0bfb",
	                                                            X"416e2fec2f82ec41", X"b31aa967a97d67b3",
	                                                            X"5f431cfd1cbefd5f", X"456025ea258aea45",
	                                                            X"23f9dabfda46bf23", X"535102f702a6f753",
	                                                            X"e445a196a1d396e4", X"9b76ed5bed2d5b9b",
	                                                            X"75285dc25deac275", X"e1c5241c24d91ce1",
	                                                            X"3dd4e9aee97aae3d", X"4cf2be6abe986a4c",
	                                                            X"6c82ee5aeed85a6c", X"7ebdc341c3fc417e",
	                                                            X"f5f3060206f102f5", X"8352d14fd11d4f83",
	                                                            X"688ce45ce4d05c68", X"515607f407a2f451",
	                                                            X"d18d5c345cb934d1", X"f9e1180818e908f9",
	                                                            X"e24cae93aedf93e2", X"ab3e9573954d73ab",
	                                                            X"6297f553f5c45362", X"2a6b413f41543f2a",
	                                                            X"081c140c14100c08", X"9563f652f6315295",
	                                                            X"46e9af65af8c6546", X"9d7fe25ee2215e9d",
	                                                            X"3048782878602830", X"37cff8a1f86ea137",
	                                                            X"0a1b110f11140f0a", X"2febc4b5c45eb52f",
	                                                            X"0e151b091b1c090e", X"247e5a365a483624",
	                                                            X"1badb69bb6369b1b", X"df98473d47a53ddf",
	                                                            X"cda76a266a8126cd", X"4ef5bb69bb9c694e",
	                                                            X"7f334ccd4cfecd7f", X"ea50ba9fbacf9fea",
	                                                            X"123f2d1b2d241b12", X"1da4b99eb93a9e1d",
	                                                            X"58c49c749cb07458", X"3446722e72682e34",
	                                                            X"3641772d776c2d36", X"dc11cdb2cda3b2dc",
	                                                            X"b49d29ee2973eeb4", X"5b4d16fb16b6fb5b",
	                                                            X"a4a501f60153f6a4", X"76a1d74dd7ec4d76",
	                                                            X"b714a361a37561b7", X"7d3449ce49face7d",
	                                                            X"52df8d7b8da47b52", X"dd9f423e42a13edd",
	                                                            X"5ecd937193bc715e", X"13b1a297a2269713",
	                                                            X"a6a204f50457f5a6", X"b901b868b86968b9",
	                                                            X"0000000000000000", X"c1b5742c74992cc1",
	                                                            X"40e0a060a0806040", X"e3c2211f21dd1fe3",
	                                                            X"793a43c843f2c879", X"b69a2ced2c77edb6",
	                                                            X"d40dd9bed9b3bed4", X"8d47ca46ca01468d",
	                                                            X"671770d970ced967", X"72afdd4bdde44b72",
	                                                            X"94ed79de7933de94", X"98ff67d4672bd498",
	                                                            X"b09323e8237be8b0", X"855bde4ade114a85",
	                                                            X"bb06bd6bbd6d6bbb", X"c5bb7e2a7e912ac5",
	                                                            X"4f7b34e5349ee54f", X"edd73a163ac116ed",
	                                                            X"86d254c55417c586", X"9af862d7622fd79a",
	                                                            X"6699ff55ffcc5566", X"11b6a794a7229411",
	                                                            X"8ac04acf4a0fcf8a", X"e9d9301030c910e9",
	                                                            X"040e0a060a080604", X"fe66988198e781fe",
	                                                            X"a0ab0bf00b5bf0a0", X"78b4cc44ccf04478",
	                                                            X"25f0d5bad54aba25", X"4b753ee33e96e34b",
	                                                            X"a2ac0ef30e5ff3a2", X"5d4419fe19bafe5d",
	                                                            X"80db5bc05b1bc080", X"0580858a850a8a05",
	                                                            X"3fd3ecadec7ead3f", X"21fedfbcdf42bc21",
	                                                            X"70a8d848d8e04870", X"f1fd0c040cf904f1",
	                                                            X"63197adf7ac6df63", X"772f58c158eec177",
	                                                            X"af309f759f4575af", X"42e7a563a5846342",
	                                                            X"2070503050403020", X"e5cb2e1a2ed11ae5",
	                                                            X"fdef120e12e10efd", X"bf08b76db7656dbf",
	                                                            X"8155d44cd4194c81", X"18243c143c301418",
	                                                            X"26795f355f4c3526", X"c3b2712f719d2fc3",
	                                                            X"be8638e13867e1be", X"35c8fda2fd6aa235",
	                                                            X"88c74fcc4f0bcc88", X"2e654b394b5c392e",
	                                                            X"936af957f93d5793", X"55580df20daaf255",
	                                                            X"fc619d829de382fc", X"7ab3c947c9f4477a",
	                                                            X"c827efacef8bacc8", X"ba8832e7326fe7ba",
	                                                            X"324f7d2b7d642b32", X"e642a495a4d795e6",
	                                                            X"c03bfba0fb9ba0c0", X"19aab398b3329819",
	                                                            X"9ef668d16827d19e", X"a322817f815d7fa3",
	                                                            X"44eeaa66aa886644", X"54d6827e82a87e54",
	                                                            X"3bdde6abe676ab3b", X"0b959e839e16830b",
	                                                            X"8cc945ca4503ca8c", X"c7bc7b297b9529c7",
	                                                            X"6b056ed36ed6d36b", X"286c443c44503c28",
	                                                            X"a72c8b798b5579a7", X"bc813de23d63e2bc",
	                                                            X"1631271d272c1d16", X"ad379a769a4176ad",
                                                              X"db964d3b4dad3bdb", X"649efa56fac85664",
                                                              X"74a6d24ed2e84e74", X"1436221e22281e14",
                                                              X"92e476db763fdb92", X"0c121e0a1e180a0c",
                                                              X"48fcb46cb4906c48", X"b88f37e4376be4b8",
                                                              X"9f78e75de7255d9f", X"bd0fb26eb2616ebd",
                                                              X"43692aef2a86ef43", X"c435f1a6f193a6c4",
                                                              X"39dae3a8e372a839", X"31c6f7a4f762a431",
                                                              X"d38a593759bd37d3", X"f274868b86ff8bf2",
                                                              X"d583563256b132d5", X"8b4ec543c50d438b",
                                                              X"6e85eb59ebdc596e", X"da18c2b7c2afb7da",
                                                              X"018e8f8c8f028c01", X"b11dac64ac7964b1",
                                                              X"9cf16dd26d23d29c", X"49723be03b92e049",
                                                              X"d81fc7b4c7abb4d8", X"acb915fa1543faac",
                                                              X"f3fa090709fd07f3", X"cfa06f256f8525cf",
                                                              X"ca20eaafea8fafca", X"f47d898e89f38ef4",
                                                              X"476720e9208ee947", X"1038281828201810",
                                                              X"6f0b64d564ded56f", X"f073838883fb88f0",
                                                              X"4afbb16fb1946f4a", X"5cca967296b8725c",
                                                              X"38546c246c702438", X"575f08f108aef157",
                                                              X"732152c752e6c773", X"9764f351f3355197",
                                                              X"cbae6523658d23cb", X"a125847c84597ca1",
                                                              X"e857bf9cbfcb9ce8", X"3e5d6321637c213e",
                                                              X"96ea7cdd7c37dd96", X"611e7fdc7fc2dc61",
                                                              X"0d9c9186911a860d", X"0f9b9485941e850f",
                                                              X"e04bab90abdb90e0", X"7cbac642c6f8427c",
                                                              X"712657c457e2c471", X"cc29e5aae583aacc",
                                                              X"90e373d8733bd890", X"06090f050f0c0506",
                                                              X"f7f4030103f501f7", X"1c2a36123638121c",
                                                              X"c23cfea3fe9fa3c2", X"6a8be15fe1d45f6a",
                                                              X"aebe10f91047f9ae", X"69026bd06bd2d069",
                                                              X"17bfa891a82e9117", X"9971e858e8295899",
                                                              X"3a5369276974273a", X"27f7d0b9d04eb927",
                                                              X"d991483848a938d9", X"ebde351335cd13eb",
                                                              X"2be5ceb3ce56b32b", X"2277553355443322",
                                                              X"d204d6bbd6bfbbd2", X"a9399070904970a9",
                                                              X"07878089800e8907", X"33c1f2a7f266a733",
                                                              X"2decc1b6c15ab62d", X"3c5a66226678223c",
                                                              X"15b8ad92ad2a9215", X"c9a96020608920c9",
                                                              X"875cdb49db154987", X"aab01aff1a4fffaa",
                                                              X"50d8887888a07850", X"a52b8e7a8e517aa5",
                                                              X"03898a8f8a068f03", X"594a13f813b2f859",
                                                              X"09929b809b128009", X"1a2339173934171a",
                                                              X"651075da75cada65", X"d784533153b531d7",
                                                              X"84d551c65113c684", X"d003d3b8d3bbb8d0",
                                                              X"82dc5ec35e1fc382", X"29e2cbb0cb52b029",
                                                              X"5ac3997799b4775a", X"1e2d3311333c111e",
                                                              X"7b3d46cb46f6cb7b", X"a8b71ffc1f4bfca8",
                                                              X"6d0c61d661dad66d", X"2c624e3a4e583a2c");
                                                              
  function t0_i(a: word64_array16; b_i: natural; s: natural; r: natural) return word64 is
  begin
    return rotl(endian_swap(T0(to_integer(byte_sel(a(b_i),s)))),r);
  end function t0_i;
  
  function t4_i(a: word64_array16; b_i: natural; s: natural; r: natural) return word64 is
  begin
    return rotl(rotr(endian_swap(T0(to_integer(byte_sel(a(b_i),s)))),32),r);
  end function t4_i;
  
  function rtt(a: word64_array16; b: nat_array_8) return word64 is
  begin
    return word64(t0_i(a,b(0),0,0) xor t0_i(a,b(1),1,8) xor t0_i(a,b(2),2,16) xor t0_i(a,b(3),3,24) xor t4_i(a,b(4),4,0) xor t4_i(a,b(5),5,8) xor t4_i(a,b(6),6,16) xor t4_i(a,b(7),7,24));
  end function rtt;
  
  function round_p(a: word64_array16; r: natural) return word64_array16 is
    variable b                          : word64_array16;
    variable t                          : word64_array16;
  begin
    for i in 0 to 15 loop
      b(i)                              := a(i) xor pc64(shl(slv(to_unsigned(i,64)),4),r);
    end loop;
    for i in 0 to 3 loop
      t(i*4)                            := rtt(b, ((i*4+0) mod 16,(i*4+1) mod 16,(i*4+2) mod 16,(i*4+3) mod 16,(i*4+4) mod 16,(i*4+5) mod 16,(i*4+6) mod 16,(i*4+11) mod 16));
      t(i*4+1)                          := rtt(b, ((i*4+1) mod 16,(i*4+2) mod 16,(i*4+3) mod 16,(i*4+4) mod 16,(i*4+5) mod 16,(i*4+6) mod 16,(i*4+7) mod 16,(i*4+12) mod 16));
      t(i*4+2)                          := rtt(b, ((i*4+2) mod 16,(i*4+3) mod 16,(i*4+4) mod 16,(i*4+5) mod 16,(i*4+6) mod 16,(i*4+7) mod 16,(i*4+8) mod 16,(i*4+13) mod 16));
      t(i*4+3)                          := rtt(b, ((i*4+3) mod 16,(i*4+4) mod 16,(i*4+5) mod 16,(i*4+6) mod 16,(i*4+7) mod 16,(i*4+8) mod 16,(i*4+9) mod 16,(i*4+14) mod 16));
    end loop;
    return t;
  end function round_p;
  
  function round_q(a: word64_array16; r: natural) return word64_array16 is
    variable b                          : word64_array16;
    variable t                          : word64_array16;
  begin
    for i in 0 to 15 loop
      b(i)                              := a(i) xor qc64(shl(slv(to_unsigned(i,64)),4),r);
    end loop;
    for i in 0 to 3 loop
      t(i*4)                            := rtt(b, ((i*4+1) mod 16,(i*4+3) mod 16,(i*4+5) mod 16,(i*4+11) mod 16,(i*4+0) mod 16,(i*4+2) mod 16,(i*4+4) mod 16,(i*4+6) mod 16));
      t(i*4+1)                          := rtt(b, ((i*4+2) mod 16,(i*4+4) mod 16,(i*4+6) mod 16,(i*4+12) mod 16,(i*4+1) mod 16,(i*4+3) mod 16,(i*4+5) mod 16,(i*4+7) mod 16));
      t(i*4+2)                          := rtt(b, ((i*4+3) mod 16,(i*4+5) mod 16,(i*4+7) mod 16,(i*4+13) mod 16,(i*4+2) mod 16,(i*4+4) mod 16,(i*4+6) mod 16,(i*4+8) mod 16));
      t(i*4+3)                          := rtt(b, ((i*4+4) mod 16,(i*4+6) mod 16,(i*4+8) mod 16,(i*4+14) mod 16,(i*4+3) mod 16,(i*4+5) mod 16,(i*4+7) mod 16,(i*4+9) mod 16));
    end loop;
    return t;
  end function round_q;
  
  function perm_p(a: word64_array16) return word64_array16 is
    variable t                          : word64_array16;
  begin
    t                                   := a;
    for i in 0 to 13 loop
      t                                 := round_p(t, i);
    end loop;
    return t;
  end function perm_p;
  
  function perm_q(a: word64_array16) return word64_array16 is
    variable t                          : word64_array16;
  begin
    t                                   := a;
    for i in 0 to 13 loop
      t                                 := round_q(t, i);
    end loop;
    return t;
  end function perm_q;
  
  signal groestl512_state_next          : groestl512_state;
  signal data_in_array                  : word64_array8;
  signal m                              : word64_array16;
  signal h                              : word64_array16;
  signal g                              : word64_array16;
  signal done                           : std_logic;
  
  signal q_groestl512_state             : groestl512_state;
  signal q_m                            : word64_array16;
  signal q_h                            : word64_array16;
  signal q_g                            : word64_array16;
  
begin

  hash_new                              <= done;
  
  output_mapping : for i in 0 to 7 generate
    hash((i+1)*64-1 downto i*64)        <= q_h(i+8);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 7 generate
    data_in_array(i)                    <= data_in((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  groestl512_proc : process(q_groestl512_state, q_m, q_h, q_g, data_in_array, start)
  begin
    groestl512_state_next               <= q_groestl512_state;
    m                                   <= q_m;
    h                                   <= q_h;
    g                                   <= q_g;
    done                                <= '0';
    case q_groestl512_state is
    when IDLE =>
      for i in 0 to 7 loop
        m(i)                            <= data_in_array(i);
      end loop;
      for i in 8 to 15 loop
        m(i)                            <= PADDING(i-8);
      end loop;
      g(15)                             <= PADDING(7) xor IV(15);
      for i in 0 to 7 loop
        g(i)                            <= data_in_array(i);
      end loop;
      for i in 8 to 14 loop
        g(i)                            <= PADDING(i-8);
      end loop;
      if start = '1' then
        for i in 0 to 15 loop
          h(i)                          <= IV(i);
        end loop;
        groestl512_state_next           <= EXEC_0;
      end if;
    when EXEC_0 =>
      g                                 <= perm_p(q_g);
      groestl512_state_next             <= EXEC_1;
    when EXEC_1 =>
      m                                 <= perm_q(q_m);
      groestl512_state_next             <= EXEC_2;
    when EXEC_2 =>
      for i in 0 to 15 loop
        h(i)                            <= q_h(i) xor q_g(i) xor q_m(i);
      end loop;
      groestl512_state_next             <= EXEC_3;
    when EXEC_3 =>
      g                                 <= perm_p(q_h);
      groestl512_state_next             <= EXEC_4;
    when EXEC_4 =>
      for i in 0 to 15 loop
        h(i)                            <= q_h(i) xor q_g(i);
      end loop;    
      groestl512_state_next             <= FINISH;
    when FINISH =>
      done                              <= '1';
      groestl512_state_next             <= IDLE;
    end case;
  end process groestl512_proc;

  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_groestl512_state                <= IDLE;
    elsif rising_edge(clk) then
      q_groestl512_state                <= groestl512_state_next;
      q_m                               <= m;
      q_h                               <= h;
      q_g                               <= g;
    end if;
  end process registers;
  
end architecture groestl512_reference_rtl;