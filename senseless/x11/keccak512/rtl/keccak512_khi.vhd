--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak512_khi is
port (
  clk                                   : in std_logic;
  start                                 : in std_logic;
  x_in                                  : in std_logic_vector(1599 downto 0);
  x_out                                 : out std_logic_vector(1599 downto 0);
  x_new                                 : out std_logic
);
end entity keccak512_khi;

architecture keccak512_khi_rtl of keccak512_khi is
  
  alias slv is std_logic_vector;
  
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  
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
  type word64_array3 is array(0 to 2) of word64;
  
  function khi_x0_xa(x: word64_array3; a: std_logic) return word64 is
    variable b                          : word64;
  begin
    if a = '0' then
      b                                 := x(1) or x(2);
    else
      b                                 := x(1) and x(2);
    end if;
    return word64(x(0) xor b);
  end khi_x0_xa;
  
  signal x                              : word64_array25;
  signal x2                             : word64_array25;  
  
  signal q_count                        : unsigned(4 downto 0);
  signal q_x2                           : word64_array25;
  signal q_done                         : slv(1 downto 0);
  
begin

  x_new                                 <= q_done(1);
  
  output_mapping : for i in 0 to 24 generate
    x_out((i+1)*64-1 downto i*64)       <= q_x2(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 24 generate
    x(i)                                <= x_in((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  khi_proc : process(q_count, q_x2, x)
    variable t                          : word64;
  begin
    x2                                  <= q_x2;
    t                                   := (others => '0');
    case q_count is
    when "00000" =>
      x2(0)                             <= khi_x0_xa( (x(0), x(5),x(10)),'0');
    when "00001" =>
      t                                 := not x(10);
      x2(5)                             <= khi_x0_xa( (x(5),    t,x(15)),'0');  
    when "00010" =>
      x2(10)                            <= khi_x0_xa((x(10),x(15),x(20)),'1');
    when "00011" =>
      x2(15)                            <= khi_x0_xa((x(15),x(20), x(0)),'0');
    when "00100" =>
      x2(20)                            <= khi_x0_xa((x(20), x(0), x(5)),'1');
    when "00101" =>  
      x2(1)                             <= khi_x0_xa(( x(1), x(6),x(11)),'0');
    when "00110" =>
      x2(6)                             <= khi_x0_xa(( x(6),x(11),x(16)),'1');
    when "00111" =>
      t                                 := not x(21);
      x2(11)                            <= khi_x0_xa((x(11),x(16),    t),'0');
    when "01000" =>
      x2(16)                            <= khi_x0_xa((x(16),x(21), x(1)),'0');
    when "01001" =>
      x2(21)                            <= khi_x0_xa((x(21), x(1), x(6)),'1');
    when "01010" =>
      x2(2)                             <= khi_x0_xa(( x(2), x(7),x(12)),'0');
    when "01011" =>
      x2(7)                             <= khi_x0_xa(( x(7),x(12),x(17)),'1');
    when "01100" =>
      t                                 := not x(17);
      x2(12)                            <= khi_x0_xa((x(12),    t,x(22)),'1');
    when "01101" =>
      t                                 := not x(17);
      x2(17)                            <= khi_x0_xa((    t,x(22), x(2)),'0');
    when "01110" =>
      x2(22)                            <= khi_x0_xa((x(22), x(2), x(7)),'1');
    when "01111" =>
      x2(3)                             <= khi_x0_xa(( x(3), x(8),x(13)),'1');
    when "10000" =>
      x2(8)                             <= khi_x0_xa(( x(8),x(13),x(18)),'0');
    when "10001" =>
      t                                 := not x(18);
      x2(13)                            <= khi_x0_xa((x(13),    t,x(23)),'0');
    when "10010" =>
      t                                 := not x(18);
      x2(18)                            <= khi_x0_xa((    t,x(23), x(3)),'1');
    when "10011" =>
      x2(23)                            <= khi_x0_xa((x(23), x(3), x(8)),'0');
    when "10100" =>
      t                                 := not x(9);
      x2(4)                             <= khi_x0_xa(( x(4),    t,x(14)),'1');
    when "10101" =>
      t                                 := not x(9);
      x2(9)                             <= khi_x0_xa((    t,x(14),x(19)),'0');
    when "10110" =>
      x2(14)                            <= khi_x0_xa((x(14),x(19),x(24)),'1');
    when "10111" =>
      x2(19)                            <= khi_x0_xa((x(19),x(24), x(4)),'0');
    when "11000" =>
      x2(24)                            <= khi_x0_xa((x(24), x(4), x(9)),'1');
    when others =>
      null;
    end case;
  end process khi_proc;
  
  registers : process(clk) is
  begin
    if rising_edge(clk) then
      q_x2                              <= x2;
      if start = '1' then
        q_count                         <= (others => '0');
      elsif q_count /= 24 then
        q_count                         <= q_count + 1;
      end if;
      if q_count = 23 then
        q_done                          <= "01";
      else
        q_done                          <= q_done(0) & '0';
      end if;
    end if;
  end process registers;
  
end architecture keccak512_khi_rtl;