--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bmw512_f1_ce is
port (
  clk                                   : in std_logic;
  clk_en                                : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  m                                     : in std_logic_vector(1023 downto 0);
  h                                     : in std_logic_vector(1023 downto 0);
  qpa                                   : in std_logic_vector(1023 downto 0);
  qpb                                   : out std_logic_vector(1023 downto 0);
  qpb_new                               : out std_logic
);
end entity bmw512_f1_ce;

architecture bmw512_f1_ce_rtl of bmw512_f1_ce is
  
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
  type uword64_array18 is array(0 to 17) of uword64;
  
  function combine_arrays(x: word64_array16; y: word64_array16) return word64_array32 is
    variable combined_array             : word64_array32;
  begin
    for i in 0 to 15 loop
      combined_array(i)                 := x(i);
      combined_array(i+16)              := y(i);
    end loop;
    return combined_array;
  end combine_arrays;
  
  function k(j: natural) return word64 is
    variable k_int                      : slv(127 downto 0);
  begin
    k_int                               := slv(to_unsigned(j,64) * X"0555555555555555");
    return k_int(63 downto 0);
  end k;

  signal m_int                          : word64_array16;
  signal h_int                          : word64_array16;
  signal qpa_int                        : word64_array16;
  signal qpb_int                        : word64_array16;
  signal qp                             : word64_array32;
  
  signal q_loop_count                   : unsigned(4 downto 0);
  signal q_done                         : std_logic;
  signal q_qpb                          : word64_array16;
  
begin

  qpb_new                               <= q_done;
  
  output_mapping : for i in 0 to 15 generate
    qpb((i+1)*64-1 downto i*64)         <= q_qpb(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 15 generate
    m_int(i)                            <= m((i+1)*64-1 downto i*64);
    h_int(i)                            <= h((i+1)*64-1 downto i*64);
    qpa_int(i)                          <= qpa((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  qp                                    <= combine_arrays(qpa_int, q_qpb);
  
  bmw512_f1_proc : process(q_loop_count, q_qpb, qp, m_int, h_int)
    variable i                          : integer;
    variable qpb_var_8                  : uword64;
    variable qpb_var_9                  : uword64;
    variable qpb_var                    : uword64_array18;
  begin
    qpb_int                             <= q_qpb;
    -- the below code is included for compatibility with Vivado which gives error "[Synth 8-561] range expression could not be resolved to a constant"
    case q_loop_count is
    when "00000" =>
      qpb_var_8                         := unsigned(rotl(m_int(0),((0 mod 16)+1))) + unsigned(rotl(m_int((0+3) mod 16),((0+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((0+10) mod 16),((0+10) mod 16)+1)) - unsigned(k(0+16));
    when "00001" =>
      qpb_var_8                         := unsigned(rotl(m_int(1),((1 mod 16)+1))) + unsigned(rotl(m_int((1+3) mod 16),((1+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((1+10) mod 16),((1+10) mod 16)+1)) - unsigned(k(1+16));
    when "00010" =>
      qpb_var_8                         := unsigned(rotl(m_int(2),((2 mod 16)+1))) + unsigned(rotl(m_int((2+3) mod 16),((2+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((2+10) mod 16),((2+10) mod 16)+1)) - unsigned(k(2+16));
    when "00011" =>
      qpb_var_8                         := unsigned(rotl(m_int(3),((3 mod 16)+1))) + unsigned(rotl(m_int((3+3) mod 16),((3+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((3+10) mod 16),((3+10) mod 16)+1)) - unsigned(k(3+16));
    when "00100" =>
      qpb_var_8                         := unsigned(rotl(m_int(4),((4 mod 16)+1))) + unsigned(rotl(m_int((4+3) mod 16),((4+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((4+10) mod 16),((4+10) mod 16)+1)) - unsigned(k(4+16));
    when "00101" =>
      qpb_var_8                         := unsigned(rotl(m_int(5),((5 mod 16)+1))) + unsigned(rotl(m_int((5+3) mod 16),((5+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((5+10) mod 16),((5+10) mod 16)+1)) - unsigned(k(5+16));
    when "00110" =>
      qpb_var_8                         := unsigned(rotl(m_int(6),((6 mod 16)+1))) + unsigned(rotl(m_int((6+3) mod 16),((6+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((6+10) mod 16),((6+10) mod 16)+1)) - unsigned(k(6+16));
    when "00111" =>
      qpb_var_8                         := unsigned(rotl(m_int(7),((7 mod 16)+1))) + unsigned(rotl(m_int((7+3) mod 16),((7+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((7+10) mod 16),((7+10) mod 16)+1)) - unsigned(k(7+16));
    when "01000" =>
      qpb_var_8                         := unsigned(rotl(m_int(8),((8 mod 16)+1))) + unsigned(rotl(m_int((8+3) mod 16),((8+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((8+10) mod 16),((8+10) mod 16)+1)) - unsigned(k(8+16));
    when "01001" =>
      qpb_var_8                         := unsigned(rotl(m_int(9),((9 mod 16)+1))) + unsigned(rotl(m_int((9+3) mod 16),((9+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((9+10) mod 16),((9+10) mod 16)+1)) - unsigned(k(9+16));
    when "01010" =>
      qpb_var_8                         := unsigned(rotl(m_int(10),((10 mod 16)+1))) + unsigned(rotl(m_int((10+3) mod 16),((10+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((10+10) mod 16),((10+10) mod 16)+1)) - unsigned(k(10+16));
    when "01011" =>
      qpb_var_8                         := unsigned(rotl(m_int(11),((11 mod 16)+1))) + unsigned(rotl(m_int((11+3) mod 16),((11+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((11+10) mod 16),((11+10) mod 16)+1)) - unsigned(k(11+16));
    when "01100" =>
      qpb_var_8                         := unsigned(rotl(m_int(12),((12 mod 16)+1))) + unsigned(rotl(m_int((12+3) mod 16),((12+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((12+10) mod 16),((12+10) mod 16)+1)) - unsigned(k(12+16));
    when "01101" =>
      qpb_var_8                         := unsigned(rotl(m_int(13),((13 mod 16)+1))) + unsigned(rotl(m_int((13+3) mod 16),((13+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((13+10) mod 16),((13+10) mod 16)+1)) - unsigned(k(13+16));
    when "01110" =>
      qpb_var_8                         := unsigned(rotl(m_int(14),((14 mod 16)+1))) + unsigned(rotl(m_int((14+3) mod 16),((14+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((14+10) mod 16),((14+10) mod 16)+1)) - unsigned(k(14+16));
    when "01111" =>
      qpb_var_8                         := unsigned(rotl(m_int(15),((15 mod 16)+1))) + unsigned(rotl(m_int((15+3) mod 16),((15+3) mod 16)+1));
      qpb_var_9                         := unsigned(rotl(m_int((15+10) mod 16),((15+10) mod 16)+1)) - unsigned(k(15+16));
    when others =>
      qpb_var_8                         := (others => '0');
      qpb_var_9                         := (others => '0');
    end case;
    -- the above code is included for compatibility with Vivado which gives error "[Synth 8-561] range expression could not be resolved to a constant"
    case q_loop_count is
    when "00000" | "00001" =>
      -- expand_1
      -- qpb(i) <= unsigned(s(q(i),1))    + unsigned(s(q(i+1),2))  + unsigned(s(q(i+2),3))  + unsigned(s(q(i+3),0))  +
      --           unsigned(s(q(i+4),1))  + unsigned(s(q(i+5),2))  + unsigned(s(q(i+6),3))  + unsigned(s(q(i+7),0))  + 
      --           unsigned(s(q(i+8),1))  + unsigned(s(q(i+9),2))  + unsigned(s(q(i+10),3)) + unsigned(s(q(i+11),0)) +
      --           unsigned(s(q(i+12),1)) + unsigned(s(q(i+13),2)) + unsigned(s(q(i+14),3)) + unsigned(s(q(i+15),0)) +
      --           unsigned(add_el(m,h,i)));
      -- add_el := slv(unsigned(rotl(m(i),(i mod 16)+1)) + unsigned(rotl(m((i+3) mod 16),((i+3) mod 16)+1)) - unsigned(rotl(m((i+10) mod 16),((i+10) mod 16)+1)) + unsigned(k(i+16))) xor h((i+7) mod 16));
      i                                 := natural(to_integer(q_loop_count));
      qpb_var(0)                        := unsigned(s(qp(i),1))    + unsigned(s(qp(i+1),2));
      qpb_var(1)                        := unsigned(s(qp(i+2),3))  + unsigned(s(qp(i+3),0));
      qpb_var(2)                        := unsigned(s(qp(i+4),1))  + unsigned(s(qp(i+5),2));
      qpb_var(3)                        := unsigned(s(qp(i+6),3))  + unsigned(s(qp(i+7),0));
      qpb_var(4)                        := unsigned(s(qp(i+8),1))  + unsigned(s(qp(i+9),2));
      qpb_var(5)                        := unsigned(s(qp(i+10),3)) + unsigned(s(qp(i+11),0));
      qpb_var(6)                        := unsigned(s(qp(i+12),1)) + unsigned(s(qp(i+13),2));
      qpb_var(7)                        := unsigned(s(qp(i+14),3)) + unsigned(s(qp(i+15),0));
      --qpb_var(8)                        := unsigned(rotl(m_int(i),((i mod 16)+1))) + unsigned(rotl(m_int((i+3) mod 16),((i+3) mod 16)+1));
      --qpb_var(9)                        := unsigned(rotl(m_int((i+10) mod 16),((i+10) mod 16)+1)) - unsigned(k(i+16));
      qpb_var(8)                        := qpb_var_8;
      qpb_var(9)                        := qpb_var_9;
      qpb_var(10)                       := qpb_var(0) + qpb_var(1);
      qpb_var(11)                       := qpb_var(2) + qpb_var(3);
      qpb_var(12)                       := qpb_var(4) + qpb_var(5);
      qpb_var(13)                       := qpb_var(6) + qpb_var(7);
      qpb_var(14)                       := unsigned(slv(qpb_var(8) - qpb_var(9)) xor h_int((i+7) mod 16));
      qpb_var(15)                       := qpb_var(10) + qpb_var(11);
      qpb_var(16)                       := qpb_var(12) + qpb_var(13);
      qpb_var(17)                       := qpb_var(15) + qpb_var(16);
      qpb_int(i)                        <= slv(qpb_var(17) + qpb_var(14));
    when "00010" | "00011" | "00100" | "00101" |
         "00110" | "00111" | "01000" | "01001" |
         "01010" | "01011" | "01100" | "01101" |
         "01110" | "01111" =>
      -- expand_2
      -- qpb(i) <= unsigned(q(i))    + unsigned(r(q(i+1),1))  + unsigned(q(i+2))       + unsigned(r(q(i+3),2))  +
      --           unsigned(q(i+4))  + unsigned(r(q(i+5),3))  + unsigned(q(i+6))       + unsigned(r(q(i+7),4))  +
      --           unsigned(q(i+8))  + unsigned(r(q(i+9),5))  + unsigned(q(i+10))      + unsigned(r(q(i+11),6)) +
      --           unsigned(q(i+12)) + unsigned(r(q(i+13),7)) + unsigned(s(q(i+14),4)) + unsigned(s(q(i+15),5)) +
      --           unsigned(add_el(m,h,i)));
      -- add_el := slv(unsigned(rotl(m(i),(i mod 16)+1)) + unsigned(rotl(m((i+3) mod 16),((i+3) mod 16)+1)) - unsigned(rotl(m((i+10) mod 16),((i+10) mod 16)+1)) + unsigned(k(i+16))) xor h((i+7) mod 16));
      i                                 := to_integer(q_loop_count);
      qpb_var(0)                        := unsigned(qp(i))         + unsigned(r(qp(i+1),1));
      qpb_var(1)                        := unsigned(qp(i+2))       + unsigned(r(qp(i+3),2));
      qpb_var(2)                        := unsigned(qp(i+4))       + unsigned(r(qp(i+5),3));
      qpb_var(3)                        := unsigned(qp(i+6))       + unsigned(r(qp(i+7),4));
      qpb_var(4)                        := unsigned(qp(i+8))       + unsigned(r(qp(i+9),5));
      qpb_var(5)                        := unsigned(qp(i+10))      + unsigned(r(qp(i+11),6));
      qpb_var(6)                        := unsigned(qp(i+12))      + unsigned(r(qp(i+13),7));
      qpb_var(7)                        := unsigned(s(qp(i+14),4)) + unsigned(s(qp(i+15),5));
      --qpb_var(8)                        := unsigned(rotl(m_int(i),((i mod 16)+1))) + unsigned(rotl(m_int((i+3) mod 16),((i+3) mod 16)+1));
      --qpb_var(9)                        := unsigned(rotl(m_int((i+10) mod 16),((i+10) mod 16)+1)) - unsigned(k(i+16));
      qpb_var(8)                        := qpb_var_8;
      qpb_var(9)                        := qpb_var_9;
      qpb_var(10)                       := qpb_var(0) + qpb_var(1);
      qpb_var(11)                       := qpb_var(2) + qpb_var(3);
      qpb_var(12)                       := qpb_var(4) + qpb_var(5);
      qpb_var(13)                       := qpb_var(6) + qpb_var(7);
      qpb_var(14)                       := unsigned(slv(qpb_var(8) - qpb_var(9)) xor h_int((i+7) mod 16));
      qpb_var(15)                       := qpb_var(10) + qpb_var(11);
      qpb_var(16)                       := qpb_var(12) + qpb_var(13);
      qpb_var(17)                       := qpb_var(15) + qpb_var(16);
      qpb_int(i)                        <= slv(qpb_var(17) + qpb_var(14));
    when others =>
      null;
    end case;
  end process bmw512_f1_proc;

  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_loop_count                      <= (q_loop_count'high => '1', 0 => '1', others => '0');
      q_done                            <= '0';
    elsif rising_edge(clk) then
      if clk_en = '1' then
        q_qpb                           <= qpb_int;
        if start = '1' then
          q_loop_count                  <= (others => '0');
        -- q_loop_count stops at B"10001"
        elsif ((q_loop_count(q_loop_count'high) and q_loop_count(0)) /= '1') then
          q_loop_count                  <= q_loop_count + 1;
        end if;
        -- q_done asserted for 1 clock cycle when q_loop_count = B"10000"
        if q_loop_count = 15 then
          q_done                        <= '1';
        else
          q_done                        <= '0';
        end if;
      end if;
    end if;
  end process registers;
  
end architecture bmw512_f1_ce_rtl;