--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bmw512_f0 is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  m                                     : in std_logic_vector(1023 downto 0);
  h                                     : in std_logic_vector(1023 downto 0);
  qpa                                   : out std_logic_vector(1023 downto 0);
  qpa_new                               : out std_logic
);
end entity bmw512_f0;

architecture bmw512_f0_rtl of bmw512_f0 is
  
  alias slv is std_logic_vector;
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
                        
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
  
  type word64_array16 is array(0 to 15) of word64;
  type uword64_array16 is array(0 to 15) of uword64;
  
  signal m_int                          : word64_array16;
  signal h_int                          : word64_array16;
  signal qpa_int                        : uword64_array16;
  signal done                           : std_logic;
  
  signal q_loop_count                   : unsigned(4 downto 0);
  signal q_done                         : std_logic;
  signal q_qpa                          : uword64_array16;
  
begin

  qpa_new                               <= q_done;
  
  output_mapping : for i in 0 to 15 generate
    qpa((i+1)*64-1 downto i*64)         <= slv(q_qpa(i));
  end generate output_mapping;
  
  input_mapping : for i in 0 to 15 generate
    m_int(i)                            <= m((i+1)*64-1 downto i*64);
    h_int(i)                            <= h((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  bmw512_f0_proc : process(q_loop_count, q_qpa, m_int, h_int)
    variable w_0                        : uword64;
    variable w_1                        : uword64;
    variable w_2                        : uword64;
    variable w_3                        : uword64;
    variable w                          : word64;
  begin
    qpa_int                             <= q_qpa;
    done                                <= '0';
    case q_loop_count is
    when "00000" =>
      -- w(0)                           := word64(unsigned(m_int(5)  xor h_int(5)) - unsigned(m_int(7) xor h_int(7)) + unsigned(m_int(10) xor h_int(10)) + unsigned(m_int(13) xor h_int(13)) + unsigned(m_int(14) xor h_int(14)));
      w_0                               := unsigned(m_int(5)  xor h_int(5))  - unsigned(m_int(7) xor h_int(7));
      w_1                               := unsigned(m_int(10) xor h_int(10)) + unsigned(m_int(13) xor h_int(13));
      w_2                               := unsigned(m_int(14) xor h_int(14));
      w_3                               := w_1 + w_2;
      w                                 := slv(w_0 + w_3);
      qpa_int(0)                        <= unsigned(s(w,0 mod 5)) + unsigned(h_int((0+1) mod 16));
    when "00001" =>
      -- w(1)                           := word64(unsigned(m_int(6)  xor h_int(6)) - unsigned(m_int(8) xor h_int(8)) + unsigned(m_int(11) xor h_int(11)) + unsigned(m_int(14) xor h_int(14)) - unsigned(m_int(15) xor h_int(15)));
      w_0                               := unsigned(m_int(6)  xor h_int(6))  - unsigned(m_int(8) xor h_int(8));
      w_1                               := unsigned(m_int(11) xor h_int(11)) + unsigned(m_int(14) xor h_int(14));
      w_2                               := unsigned(m_int(15) xor h_int(15));
      w_3                               := w_1 - w_2;
      w                                 := slv(w_0 + w_3);
      qpa_int(1)                        <= unsigned(s(w,1 mod 5)) + unsigned(h_int((1+1) mod 16));
    when "00010" =>
      -- w(2)                           := word64(unsigned(m_int(0)  xor h_int(0)) + unsigned(m_int(7) xor h_int(7)) + unsigned(m_int(9)  xor h_int(9))  - unsigned(m_int(12) xor h_int(12)) + unsigned(m_int(15) xor h_int(15)));
      w_0                               := unsigned(m_int(0)  xor h_int(0))  + unsigned(m_int(7) xor h_int(7));
      w_1                               := unsigned(m_int(9)  xor h_int(9))  - unsigned(m_int(12) xor h_int(12));
      w_2                               := unsigned(m_int(15) xor h_int(15));
      w_3                               := w_1 + w_2;
      w                                 := slv(w_0 + w_3);
      qpa_int(2)                        <= unsigned(s(w,2 mod 5)) + unsigned(h_int((2+1) mod 16));
    when "00011" =>
      -- w(3)                           := word64(unsigned(m_int(0)  xor h_int(0)) - unsigned(m_int(1) xor h_int(1)) + unsigned(m_int(8)  xor h_int(8))  - unsigned(m_int(10) xor h_int(10)) + unsigned(m_int(13) xor h_int(13)));
      w_0                               := unsigned(m_int(0)  xor h_int(0))  - unsigned(m_int(1) xor h_int(1));
      w_1                               := unsigned(m_int(8)  xor h_int(8))  - unsigned(m_int(10) xor h_int(10));
      w_2                               := unsigned(m_int(13) xor h_int(13));
      w_3                               := w_1 + w_2;
      w                                 := slv(w_0 + w_3);
      qpa_int(3)                        <= unsigned(s(w,3 mod 5)) + unsigned(h_int((3+1) mod 16));
    when "00100" =>
      -- w(4)                           := word64(unsigned(m_int(1)  xor h_int(1)) + unsigned(m_int(2) xor h_int(2)) + unsigned(m_int(9)  xor h_int(9))  - unsigned(m_int(11) xor h_int(11)) - unsigned(m_int(14) xor h_int(14)));
      w_0                               := unsigned(m_int(1)  xor h_int(1))  + unsigned(m_int(2) xor h_int(2));
      w_1                               := unsigned(m_int(9)  xor h_int(9))  - unsigned(m_int(11) xor h_int(11));
      w_2                               := unsigned(m_int(14) xor h_int(14));
      w_3                               := w_1 - w_2;
      w                                 := slv(w_0 + w_3);
      qpa_int(4)                        <= unsigned(s(w,4 mod 5)) + unsigned(h_int((4+1) mod 16));
    when "00101" =>
      -- w(5)                           := word64(unsigned(m_int(3)  xor h_int(3)) - unsigned(m_int(2) xor h_int(2)) + unsigned(m_int(10) xor h_int(10)) - unsigned(m_int(12) xor h_int(12)) + unsigned(m_int(15) xor h_int(15)));
      w_0                               := unsigned(m_int(3)  xor h_int(3))  - unsigned(m_int(2) xor h_int(2));
      w_1                               := unsigned(m_int(10) xor h_int(10)) - unsigned(m_int(12) xor h_int(12));
      w_2                               := unsigned(m_int(15) xor h_int(15));
      w_3                               := w_1 + w_2;
      w                                 := slv(w_0 + w_3);
      qpa_int(5)                        <= unsigned(s(w,5 mod 5)) + unsigned(h_int((5+1) mod 16));
    when "00110" =>
      -- w(6)                           := word64(unsigned(m_int(4)  xor h_int(4)) - unsigned(m_int(0) xor h_int(0)) - unsigned(m_int(3)  xor h_int(3))  - unsigned(m_int(11) xor h_int(11)) + unsigned(m_int(13) xor h_int(13)));
      w_0                               := unsigned(m_int(4)  xor h_int(4))  - unsigned(m_int(0) xor h_int(0));
      w_1                               := unsigned(m_int(3)  xor h_int(3))  + unsigned(m_int(11) xor h_int(11));
      w_2                               := unsigned(m_int(13) xor h_int(13));
      w_3                               := w_1 - w_2;
      w                                 := slv(w_0 - w_3);
      qpa_int(6)                        <= unsigned(s(w,6 mod 5)) + unsigned(h_int((6+1) mod 16));
    when "00111" =>
      -- w(7)                           := word64(unsigned(m_int(1)  xor h_int(1)) - unsigned(m_int(4) xor h_int(4)) - unsigned(m_int(5)  xor h_int(5))  - unsigned(m_int(12) xor h_int(12)) - unsigned(m_int(14) xor h_int(14)));
      w_0                               := unsigned(m_int(1)  xor h_int(1))  - unsigned(m_int(4) xor h_int(4));
      w_1                               := unsigned(m_int(5)  xor h_int(5))  + unsigned(m_int(12) xor h_int(12));
      w_2                               := unsigned(m_int(14) xor h_int(14));
      w_3                               := w_1 + w_2;
      w                                 := slv(w_0 - w_3);
      qpa_int(7)                        <= unsigned(s(w,7 mod 5)) + unsigned(h_int((7+1) mod 16));
    when "01000" =>
      -- w(8)                           := word64(unsigned(m_int(2)  xor h_int(2)) - unsigned(m_int(5) xor h_int(5)) - unsigned(m_int(6)  xor h_int(6))  + unsigned(m_int(13) xor h_int(13)) - unsigned(m_int(15) xor h_int(15)));
      w_0                               := unsigned(m_int(2)  xor h_int(2))  - unsigned(m_int(5) xor h_int(5));
      w_1                               := unsigned(m_int(6)  xor h_int(6))  - unsigned(m_int(13) xor h_int(13));
      w_2                               := unsigned(m_int(15) xor h_int(15));
      w_3                               := w_1 + w_2;
      w                                 := slv(w_0 - w_3);
      qpa_int(8)                        <= unsigned(s(w,8 mod 5)) + unsigned(h_int((8+1) mod 16));
    when "01001" =>
      -- w(9)                           := word64(unsigned(m_int(0)  xor h_int(0)) - unsigned(m_int(3) xor h_int(3)) + unsigned(m_int(6)  xor h_int(6))  - unsigned(m_int(7)  xor h_int(7))  + unsigned(m_int(14) xor h_int(14)));
      w_0                               := unsigned(m_int(0)  xor h_int(0))  - unsigned(m_int(3) xor h_int(3));
      w_1                               := unsigned(m_int(6)  xor h_int(6))  - unsigned(m_int(7)  xor h_int(7));
      w_2                               := unsigned(m_int(14) xor h_int(14));
      w_3                               := w_1 + w_2;
      w                                 := slv(w_0 + w_3);
      qpa_int(9)                        <= unsigned(s(w,9 mod 5)) + unsigned(h_int((9+1) mod 16));
    when "01010" =>
      -- w(10)                          := word64(unsigned(m_int(8)  xor h_int(8)) - unsigned(m_int(1) xor h_int(1)) - unsigned(m_int(4)  xor h_int(4))  - unsigned(m_int(7)  xor h_int(7))  + unsigned(m_int(15) xor h_int(15)));
      w_0                               := unsigned(m_int(8)  xor h_int(8))  - unsigned(m_int(1) xor h_int(1));
      w_1                               := unsigned(m_int(4)  xor h_int(4))  + unsigned(m_int(7)  xor h_int(7));
      w_2                               := unsigned(m_int(15) xor h_int(15));
      w_3                               := w_1 - w_2;
      w                                 := slv(w_0 - w_3);
      qpa_int(10)                       <= unsigned(s(w,10 mod 5)) + unsigned(h_int((10+1) mod 16));
    when "01011" =>
      -- w(11)                          := word64(unsigned(m_int(8)  xor h_int(8)) - unsigned(m_int(0) xor h_int(0)) - unsigned(m_int(2)  xor h_int(2))  - unsigned(m_int(5)  xor h_int(5))  + unsigned(m_int(9)  xor h_int(9)));
      w_0                               := unsigned(m_int(8)  xor h_int(8))  - unsigned(m_int(0) xor h_int(0));
      w_1                               := unsigned(m_int(2)  xor h_int(2))  + unsigned(m_int(5)  xor h_int(5));
      w_2                               := unsigned(m_int(9)  xor h_int(9));
      w_3                               := w_1 - w_2;
      w                                 := slv(w_0 - w_3);
      qpa_int(11)                       <= unsigned(s(w,11 mod 5)) + unsigned(h_int((11+1) mod 16));
    when "01100" =>
      -- w(12)                          := word64(unsigned(m_int(1)  xor h_int(1)) + unsigned(m_int(3) xor h_int(3)) - unsigned(m_int(6)  xor h_int(6))  - unsigned(m_int(9)  xor h_int(9))  + unsigned(m_int(10) xor h_int(10)));
      w_0                               := unsigned(m_int(1)  xor h_int(1))  + unsigned(m_int(3) xor h_int(3));
      w_1                               := unsigned(m_int(6)  xor h_int(6))  + unsigned(m_int(9)  xor h_int(9));
      w_2                               := unsigned(m_int(10) xor h_int(10));
      w_3                               := w_1 - w_2;
      w                                 := slv(w_0 - w_3);
      qpa_int(12)                       <= unsigned(s(w,12 mod 5)) + unsigned(h_int((12+1) mod 16));
    when "01101" =>
      -- w(13)                          := word64(unsigned(m_int(2)  xor h_int(2)) + unsigned(m_int(4) xor h_int(4)) + unsigned(m_int(7)  xor h_int(7))  + unsigned(m_int(10) xor h_int(10)) + unsigned(m_int(11) xor h_int(11)));
      w_0                               := unsigned(m_int(2)  xor h_int(2))  + unsigned(m_int(4) xor h_int(4));
      w_1                               := unsigned(m_int(7)  xor h_int(7))  + unsigned(m_int(10) xor h_int(10));
      w_2                               := unsigned(m_int(11) xor h_int(11));
      w_3                               := w_1 + w_2;
      w                                 := slv(w_0 + w_3);
      qpa_int(13)                       <= unsigned(s(w,13 mod 5)) + unsigned(h_int((13+1) mod 16));
    when "01110" =>
      -- w(14)                          := word64(unsigned(m_int(3)  xor h_int(3)) - unsigned(m_int(5) xor h_int(5)) + unsigned(m_int(8)  xor h_int(8))  - unsigned(m_int(11) xor h_int(11)) - unsigned(m_int(12) xor h_int(12)));
      w_0                               := unsigned(m_int(3)  xor h_int(3))  - unsigned(m_int(5) xor h_int(5));
      w_1                               := unsigned(m_int(8)  xor h_int(8))  - unsigned(m_int(11) xor h_int(11));
      w_2                               := unsigned(m_int(12) xor h_int(12));
      w_3                               := w_1 - w_2;
      w                                 := slv(w_0 + w_3);
      qpa_int(14)                       <= unsigned(s(w,14 mod 5)) + unsigned(h_int((14+1) mod 16));
    when "01111" =>
      -- w(15)                          := word64(unsigned(m_int(12) xor h_int(12)) - unsigned(m_int(4) xor h_int(4)) - unsigned(m_int(6)  xor h_int(6))  - unsigned(m_int(9) xor h_int(9))   + unsigned(m_int(13) xor h_int(13)));
      w_0                               := unsigned(m_int(12) xor h_int(12)) - unsigned(m_int(4) xor h_int(4));
      w_1                               := unsigned(m_int(6)  xor h_int(6))  + unsigned(m_int(9) xor h_int(9));
      w_2                               := unsigned(m_int(13) xor h_int(13));
      w_3                               := w_1 - w_2;
      w                                 := slv(w_0 - w_3);
      qpa_int(15)                       <= unsigned(s(w,15 mod 5)) + unsigned(h_int((15+1) mod 16));
      done                              <= '1';
    when others =>
      null;
    end case;
  end process bmw512_f0_proc;

  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_loop_count                      <= (q_loop_count'high => '1', 0 => '1', others => '0');
      q_done                            <= '0';
    elsif rising_edge(clk) then
      q_qpa                             <= qpa_int;
      if start = '1' then
        q_loop_count                    <= (others => '0');
      -- q_loop_count stops at B"10001"
      elsif ((q_loop_count(q_loop_count'high) and q_loop_count(0)) /= '1') then
        q_loop_count                    <= q_loop_count + 1;
      end if;
      -- q_done asserted for 1 clock cycle when q_loop_count = B"10000"
      q_done                            <= done;
    end if;
  end process registers;
  
end architecture bmw512_f0_rtl;