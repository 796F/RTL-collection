--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bmw512_reference is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  data_in                               : in std_logic_vector(511 downto 0);
  hash                                  : out std_logic_vector(511 downto 0);
  hash_new                              : out std_logic
);
end entity bmw512_reference;

architecture bmw512_reference_rtl of bmw512_reference is
  
  alias slv is std_logic_vector;
  subtype word64 is slv(63 downto 0);
  type nat_array_16_16 is array(0 to 15, 0 to 15) of natural;
  type nat_array_16_7 is array(0 to 15, 0 to 6) of natural;
  type nat_array_8 is array(0 to 7) of natural;
  type bmw512_state is (IDLE, HASH_COMP_F0_0, HASH_COMP_F0_1, HASH_COMP_F1, HASH_COMP_F2_0, HASH_COMP_F2_1, HASH_COMP_F2_2,
                        FINALIZATION_F0_0, FINALIZATION_F0_1, FINALIZATION_F1, FINALIZATION_F2_0, FINALIZATION_F2_1, FINALIZATION_F2_2,
                        FINISH);
                        
  constant zeros64 : word64 := (others => '0');
  
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
  
  function s(x: word64; n: natural) return word64 is
  begin
    case n is
    when 0      => return word64(shr(x,1) xor shl(x,3) xor rotl(x,4) xor rotl(x,37));
    when 1      => return word64(shr(x,1) xor shl(x,2) xor rotl(x,13) xor rotl(x,43));
    when 2      => return word64(shr(x,2) xor shl(x,1) xor rotl(x,19) xor rotl(x,53));
    when 3      => return word64(shr(x,2) xor shl(x,2) xor rotl(x,28) xor rotl(x,59));
    when 4      => return word64(shr(x,1) xor x);
    when others => return word64(shr(x,2) xor x);
    end case;
  end s;
  
  function r(x: word64; n: natural) return word64 is
  begin
    case n is
    when 1      => return rotl(x,5);
    when 2      => return rotl(x,11);
    when 3      => return rotl(x,27);
    when 4      => return rotl(x,32);
    when 5      => return rotl(x,37);
    when 6      => return rotl(x,43);
    when others => return rotl(x,53);
    end case;
  end r;
  
  type word64_array32 is array(0 to 31) of word64;
  type word64_array16 is array(0 to 15) of word64;
  type word64_array8 is array(0 to 7) of word64;
  
  function combine_arrays(x: word64_array16; y: word64_array16) return word64_array32 is
    variable combined_array             : word64_array32;
  begin
    for i in 0 to 15 loop
      combined_array(i)                 := x(i);
      combined_array(i+16)              := y(i);
    end loop;
    return combined_array;
  end combine_arrays;
  
  function bt_1(m: word64_array16; h: word64_array16) return word64_array16 is
    variable w                          : word64_array16;
  begin
    w(0)                                := word64(unsigned(m(5)  xor h(5))  - unsigned(m(7) xor h(7)) + unsigned(m(10) xor h(10)) + unsigned(m(13) xor h(13)) + unsigned(m(14) xor h(14)));
    w(1)                                := word64(unsigned(m(6)  xor h(6))  - unsigned(m(8) xor h(8)) + unsigned(m(11) xor h(11)) + unsigned(m(14) xor h(14)) - unsigned(m(15) xor h(15)));
    w(2)                                := word64(unsigned(m(0)  xor h(0))  + unsigned(m(7) xor h(7)) + unsigned(m(9)  xor h(9))  - unsigned(m(12) xor h(12)) + unsigned(m(15) xor h(15)));
    w(3)                                := word64(unsigned(m(0)  xor h(0))  - unsigned(m(1) xor h(1)) + unsigned(m(8)  xor h(8))  - unsigned(m(10) xor h(10)) + unsigned(m(13) xor h(13)));
    w(4)                                := word64(unsigned(m(1)  xor h(1))  + unsigned(m(2) xor h(2)) + unsigned(m(9)  xor h(9))  - unsigned(m(11) xor h(11)) - unsigned(m(14) xor h(14)));
    w(5)                                := word64(unsigned(m(3)  xor h(3))  - unsigned(m(2) xor h(2)) + unsigned(m(10) xor h(10)) - unsigned(m(12) xor h(12)) + unsigned(m(15) xor h(15)));
    w(6)                                := word64(unsigned(m(4)  xor h(4))  - unsigned(m(0) xor h(0)) - unsigned(m(3)  xor h(3))  - unsigned(m(11) xor h(11)) + unsigned(m(13) xor h(13)));
    w(7)                                := word64(unsigned(m(1)  xor h(1))  - unsigned(m(4) xor h(4)) - unsigned(m(5)  xor h(5))  - unsigned(m(12) xor h(12)) - unsigned(m(14) xor h(14)));
    w(8)                                := word64(unsigned(m(2)  xor h(2))  - unsigned(m(5) xor h(5)) - unsigned(m(6)  xor h(6))  + unsigned(m(13) xor h(13)) - unsigned(m(15) xor h(15)));
    w(9)                                := word64(unsigned(m(0)  xor h(0))  - unsigned(m(3) xor h(3)) + unsigned(m(6)  xor h(6))  - unsigned(m(7)  xor h(7))  + unsigned(m(14) xor h(14)));
    w(10)                               := word64(unsigned(m(8)  xor h(8))  - unsigned(m(1) xor h(1)) - unsigned(m(4)  xor h(4))  - unsigned(m(7)  xor h(7))  + unsigned(m(15) xor h(15)));
    w(11)                               := word64(unsigned(m(8)  xor h(8))  - unsigned(m(0) xor h(0)) - unsigned(m(2)  xor h(2))  - unsigned(m(5)  xor h(5))  + unsigned(m(9)  xor h(9)));
    w(12)                               := word64(unsigned(m(1)  xor h(1))  + unsigned(m(3) xor h(3)) - unsigned(m(6)  xor h(6))  - unsigned(m(9)  xor h(9))  + unsigned(m(10) xor h(10)));
    w(13)                               := word64(unsigned(m(2)  xor h(2))  + unsigned(m(4) xor h(4)) + unsigned(m(7)  xor h(7))  + unsigned(m(10) xor h(10)) + unsigned(m(11) xor h(11)));
    w(14)                               := word64(unsigned(m(3)  xor h(3))  - unsigned(m(5) xor h(5)) + unsigned(m(8)  xor h(8))  - unsigned(m(11) xor h(11)) - unsigned(m(12) xor h(12)));
    w(15)                               := word64(unsigned(m(12) xor h(12)) - unsigned(m(4) xor h(4)) - unsigned(m(6)  xor h(6))  - unsigned(m(9) xor h(9))   + unsigned(m(13) xor h(13)));
    return w;
  end bt_1;
  
  function bt_2(w: word64_array16; h: word64_array16) return word64_array16 is
    variable q                          : word64_array16;
  begin
    for i in 0 to 15 loop
      q(i)                              := word64(unsigned(s(w(i),i mod 5)) + unsigned(h((i+1) mod 16)));
    end loop;    
    return q;
  end bt_2;
  
  function k(j: natural) return word64 is
    variable k_int                      : slv(127 downto 0);
  begin
    k_int                               := slv(to_unsigned(j,64) * X"0555555555555555");
    return k_int(63 downto 0);
  end k;
  
  function add_el(m: word64_array16; h: word64_array16; j: natural) return word64 is
  begin
    return word64(slv(unsigned(rotl(m(j),(j mod 16)+1)) + unsigned(rotl(m((j+3) mod 16),((j+3) mod 16)+1)) - unsigned(rotl(m((j+10) mod 16),((j+10) mod 16)+1)) + unsigned(k(j+16))) xor h((j+7) mod 16));
  end add_el;
  
  function expand_1(q: word64_array32; m: word64_array16; h: word64_array16; j: natural) return word64 is
  begin
    return word64(unsigned(s(q(j-16),1)) + unsigned(s(q(j-15),2)) + unsigned(s(q(j-14),3)) + unsigned(s(q(j-13),0)) +
                  unsigned(s(q(j-12),1)) + unsigned(s(q(j-11),2)) + unsigned(s(q(j-10),3)) + unsigned(s(q(j-9),0))  + 
                  unsigned(s(q(j-8),1))  + unsigned(s(q(j-7),2))  + unsigned(s(q(j-6),3))  + unsigned(s(q(j-5),0))  +
                  unsigned(s(q(j-4),1))  + unsigned(s(q(j-3),2))  + unsigned(s(q(j-2),3))  + unsigned(s(q(j-1),0))  +
                  unsigned(add_el(m,h,j-16)));
  end expand_1;
  
  function expand_2(q: word64_array32; m: word64_array16; h: word64_array16; j: natural) return word64 is
  begin
    return word64(unsigned(q(j-16)) + unsigned(r(q(j-15),1)) + unsigned(q(j-14))     + unsigned(r(q(j-13),2)) +
                  unsigned(q(j-12)) + unsigned(r(q(j-11),3)) + unsigned(q(j-10))     + unsigned(r(q(j-9),4))  +
                  unsigned(q(j-8))  + unsigned(r(q(j-7),5))  + unsigned(q(j-6))      + unsigned(r(q(j-5),6))  +
                  unsigned(q(j-4))  + unsigned(r(q(j-3),7))  + unsigned(s(q(j-2),4)) + unsigned(s(q(j-1),5))  +
                  unsigned(add_el(m,h,j-16)));
  end expand_2;
  
  function f1(m: word64_array16; h: word64_array16; qpa: word64_array16) return word64_array16 is
    variable qpb                        : word64_array16;
  begin
    for i in 0 to 1 loop
      qpb(i)                            := expand_1(combine_arrays(qpa,qpb), m, h, i+16); 
    end loop;
    for i in 2 to 15 loop
      qpb(i)                            := expand_2(combine_arrays(qpa,qpb), m, h, i+16);
    end loop;
    return qpb;
  end f1;
  
  function f2(m: word64_array16; qpa: word64_array16; qpb: word64_array16; xl: word64; xh: word64) return word64_array16 is
    variable h                          : word64_array16;  
  begin
    h(0)                                := word64(unsigned(shl(xh,5)  xor shr(qpb(0),5) xor m(0)) + unsigned(xl xor qpb(8) xor qpa(0)));
    h(1)                                := word64(unsigned(shr(xh,7)  xor shl(qpb(1),8) xor m(1)) + unsigned(xl xor qpb(9) xor qpa(1)));
    h(2)                                := word64(unsigned(shr(xh,5)  xor shl(qpb(2),5) xor m(2)) + unsigned(xl xor qpb(10) xor qpa(2)));
    h(3)                                := word64(unsigned(shr(xh,1)  xor shl(qpb(3),5) xor m(3)) + unsigned(xl xor qpb(11) xor qpa(3)));
    h(4)                                := word64(unsigned(shr(xh,3)  xor     qpb(4)    xor m(4)) + unsigned(xl xor qpb(12) xor qpa(4)));
    h(5)                                := word64(unsigned(shl(xh,6)  xor shr(qpb(5),6) xor m(5)) + unsigned(xl xor qpb(13) xor qpa(5)));
    h(6)                                := word64(unsigned(shr(xh,4)  xor shl(qpb(6),6) xor m(6)) + unsigned(xl xor qpb(14) xor qpa(6)));
    h(7)                                := word64(unsigned(shr(xh,11) xor shl(qpb(7),2) xor m(7)) + unsigned(xl xor qpb(15) xor qpa(7)));
    h(8)                                := word64(unsigned(rotl(h(4),9))  + unsigned(xh xor qpb(8)  xor m(8))  + unsigned(shl(xl,8) xor qpb(7) xor qpa(8)));
    h(9)                                := word64(unsigned(rotl(h(5),10)) + unsigned(xh xor qpb(9)  xor m(9))  + unsigned(shr(xl,6) xor qpb(0) xor qpa(9)));
    h(10)                               := word64(unsigned(rotl(h(6),11)) + unsigned(xh xor qpb(10) xor m(10)) + unsigned(shl(xl,6) xor qpb(1) xor qpa(10)));
    h(11)                               := word64(unsigned(rotl(h(7),12)) + unsigned(xh xor qpb(11) xor m(11)) + unsigned(shl(xl,4) xor qpb(2) xor qpa(11)));
    h(12)                               := word64(unsigned(rotl(h(0),13)) + unsigned(xh xor qpb(12) xor m(12)) + unsigned(shr(xl,3) xor qpb(3) xor qpa(12)));
    h(13)                               := word64(unsigned(rotl(h(1),14)) + unsigned(xh xor qpb(13) xor m(13)) + unsigned(shr(xl,4) xor qpb(4) xor qpa(13)));
    h(14)                               := word64(unsigned(rotl(h(2),15)) + unsigned(xh xor qpb(14) xor m(14)) + unsigned(shr(xl,7) xor qpb(5) xor qpa(14)));
    h(15)                               := word64(unsigned(rotl(h(3),16)) + unsigned(xh xor qpb(15) xor m(15)) + unsigned(shr(xl,2) xor qpb(6) xor qpa(15)));
    return h;
  end f2;
  
  constant IV                           : word64_array16 := (X"8081828384858687", X"88898A8B8C8D8E8F",
                                                             X"9091929394959697", X"98999A9B9C9D9E9F",
                                                             X"A0A1A2A3A4A5A6A7", X"A8A9AAABACADAEAF",
                                                             X"B0B1B2B3B4B5B6B7", X"B8B9BABBBCBDBEBF",
                                                             X"C0C1C2C3C4C5C6C7", X"C8C9CACBCCCDCECF",
                                                             X"D0D1D2D3D4D5D6D7", X"D8D9DADBDCDDDEDF",
                                                             X"E0E1E2E3E4E5E6E7", X"E8E9EAEBECEDEEEF",
                                                             X"F0F1F2F3F4F5F6F7", X"F8F9FAFBFCFDFEFF");
  constant FINAL                        : word64_array16 := (X"AAAAAAAAAAAAAAA0", X"AAAAAAAAAAAAAAA1",
                                                             X"AAAAAAAAAAAAAAA2", X"AAAAAAAAAAAAAAA3",
                                                             X"AAAAAAAAAAAAAAA4", X"AAAAAAAAAAAAAAA5",
                                                             X"AAAAAAAAAAAAAAA6", X"AAAAAAAAAAAAAAA7",
                                                             X"AAAAAAAAAAAAAAA8", X"AAAAAAAAAAAAAAA9",
                                                             X"AAAAAAAAAAAAAAAA", X"AAAAAAAAAAAAAAAB",
                                                             X"AAAAAAAAAAAAAAAC", X"AAAAAAAAAAAAAAAD",
                                                             X"AAAAAAAAAAAAAAAE", X"AAAAAAAAAAAAAAAF");
  constant PADDING                      : word64_array8 := (X"0000000000000080", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000200");

  signal bmw512_state_next              : bmw512_state;
  signal data_in_array                  : word64_array8;
  signal m                              : word64_array16;
  signal done                           : std_logic;
  signal h                              : word64_array16;
  signal qpa                            : word64_array16;
  signal qpb                            : word64_array16;
  signal xl                             : word64;
  signal xh                             : word64;
  
  signal q_bmw512_state                 : bmw512_state;
  signal q_m                            : word64_array16;
  signal q_done                         : std_logic;
  signal q_h                            : word64_array16;
  signal q_qpa                          : word64_array16;
  signal q_qpb                          : word64_array16;
  signal q_xl                           : word64;
  signal q_xh                           : word64;
  
begin

  hash_new                              <= q_done;
  
  output_mapping : for i in 0 to 7 generate
    hash((i+1)*64-1 downto i*64)        <= q_h(i+8);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 7 generate
    data_in_array(i)                    <= data_in((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  bmw512_proc : process(q_bmw512_state, q_m, q_h, q_qpa, q_qpb, q_xl, q_xh, data_in_array, start)
  begin
    bmw512_state_next                   <= q_bmw512_state;
    m                                   <= q_m;
    h                                   <= q_h;
    qpa                                 <= q_qpa;
    qpb                                 <= q_qpb;
    xl                                  <= q_xl;
    xh                                  <= q_xh;
    done                                <= '0';
    case q_bmw512_state is
    when IDLE =>
      for i in 0 to 7 loop
        m(i)                            <= data_in_array(i);
      end loop;
      for i in 8 to 15 loop
        m(i)                            <= PADDING(i-8);
      end loop;
      for i in 0 to 15 loop
        h(i)                            <= IV(i);
      end loop;
      if start = '1' then
        bmw512_state_next               <= HASH_COMP_F0_0;
      end if;
    when HASH_COMP_F0_0 =>
      qpa                               <= bt_1(q_m, q_h);
      bmw512_state_next                 <= HASH_COMP_F0_1;
    when HASH_COMP_F0_1 =>
      qpa                               <= bt_2(q_qpa, q_h);
      bmw512_state_next                 <= HASH_COMP_F1;
    when HASH_COMP_F1 =>
      qpb                               <= f1(q_m, q_h, q_qpa);
      bmw512_state_next                 <= HASH_COMP_F2_0;
    when HASH_COMP_F2_0 =>
      xl                                <= q_qpb(0) xor q_qpb(1) xor q_qpb(2) xor q_qpb(3) xor q_qpb(4) xor q_qpb(5) xor q_qpb(6) xor q_qpb(7);
      bmw512_state_next                 <= HASH_COMP_F2_1;
    when HASH_COMP_F2_1 =>
      xh                                <= q_xl xor q_qpb(8) xor q_qpb(9) xor q_qpb(10) xor q_qpb(11) xor q_qpb(12) xor q_qpb(13) xor q_qpb(14) xor q_qpb(15);
      bmw512_state_next                 <= HASH_COMP_F2_2;
    when HASH_COMP_F2_2 =>
      h                                 <= f2(q_m, q_qpa, q_qpb, q_xl, q_xh);
      bmw512_state_next                 <= FINALIZATION_F0_0;
    when FINALIZATION_F0_0 =>
      qpa                               <= bt_1(q_h, FINAL);
      bmw512_state_next                 <= FINALIZATION_F0_1;
    when FINALIZATION_F0_1 =>
      qpa                               <= bt_2(q_qpa, FINAL);
      bmw512_state_next                 <= FINALIZATION_F1;
    when FINALIZATION_F1   =>
      qpb                               <= f1(q_h, FINAL, q_qpa);
      bmw512_state_next                 <= FINALIZATION_F2_0;
    when FINALIZATION_F2_0 =>
      xl                                <= q_qpb(0) xor q_qpb(1) xor q_qpb(2) xor q_qpb(3) xor q_qpb(4) xor q_qpb(5) xor q_qpb(6) xor q_qpb(7);
      bmw512_state_next                 <= FINALIZATION_F2_1;
    when FINALIZATION_F2_1 =>
      xh                                <= q_xl xor q_qpb(8) xor q_qpb(9) xor q_qpb(10) xor q_qpb(11) xor q_qpb(12) xor q_qpb(13) xor q_qpb(14) xor q_qpb(15);
      bmw512_state_next                 <= FINALIZATION_F2_2;
    when FINALIZATION_F2_2 =>
      h                                 <= f2(q_h, q_qpa, q_qpb, q_xl, q_xh);
      bmw512_state_next                 <= FINISH;
    when FINISH =>
      done                              <= '1';
      bmw512_state_next                 <= IDLE;
    end case;
  end process bmw512_proc;

  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_bmw512_state                    <= IDLE;
      q_done                            <= '0';
    elsif rising_edge(clk) then
      q_bmw512_state                    <= bmw512_state_next;
      q_m                               <= m;
      q_done                            <= done;
      q_h                               <= h;
      q_qpa                             <= qpa;
      q_qpb                             <= qpb;
      q_xl                              <= xl;
      q_xh                              <= xh;
    end if;
  end process registers;
  
end architecture bmw512_reference_rtl;