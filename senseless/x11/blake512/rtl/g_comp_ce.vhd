--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g_comp_ce is
port (
  clk           : in std_logic;
  clk_en        : in std_logic;
  reset         : in std_logic;
  start         : in std_logic;
  m0            : in std_logic_vector(63 downto 0);
  m1            : in std_logic_vector(63 downto 0);
  c0            : in std_logic_vector(63 downto 0);
  c1            : in std_logic_vector(63 downto 0);
  a             : in std_logic_vector(63 downto 0);
  b             : in std_logic_vector(63 downto 0);
  c             : in std_logic_vector(63 downto 0);
  d             : in std_logic_vector(63 downto 0);
  a_out         : out std_logic_vector(63 downto 0);
  b_out         : out std_logic_vector(63 downto 0);
  c_out         : out std_logic_vector(63 downto 0);
  d_out         : out std_logic_vector(63 downto 0)
);
end entity g_comp_ce;

architecture g_comp_ce_rtl of g_comp_ce is
  
  alias slv is std_logic_vector;
  subtype word64 is unsigned(63 downto 0);           
  
  function rotr(x: word64; n: natural) return word64 is
  begin
    return word64(x(n-1 downto 0) & x(x'high downto n));
  end rotr;
  
  signal a1_int : word64;
  signal a2_int : word64;
  signal b1_int : word64;
  signal b2_int : word64;
  signal c1_int : word64;
  signal c2_int : word64;
  signal d1_int : word64;
  signal d2_int : word64;
  
begin

  a_out         <= slv(a2_int);
  b_out         <= slv(b2_int);
  c_out         <= slv(c2_int);
  d_out         <= slv(d2_int);

  a1_int        <= unsigned(a) + unsigned(b) + (unsigned(m0) xor unsigned(c1));
  d1_int        <= rotr(unsigned(d) xor a1_int, 32);
  c1_int        <= unsigned(c) + d1_int;
  b1_int        <= rotr(unsigned(b) xor c1_int, 25);
  a2_int        <= a1_int + b1_int + (unsigned(m1) xor unsigned(c0));
  d2_int        <= rotr(d1_int xor a2_int, 16);
  c2_int        <= c1_int + d2_int;
  b2_int        <= rotr(b1_int xor c2_int,11);

  -- g_comp_proc is
  -- begin
  
  -- end process g_comp_proc;

  -- registers : process(clk, reset) is
  -- begin
    -- if reset = '1' then

    -- elsif rising_edge(clk) then

    -- end if;
  -- end process registers;
  
end architecture g_comp_ce_rtl;