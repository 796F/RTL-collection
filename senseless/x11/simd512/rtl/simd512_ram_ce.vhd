--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simd512_ram_ce is
port (
  clk                                   : in std_logic;
  clk_en                                : in std_logic;
  clr                                   : in std_logic;
  d_in_all                              : in std_logic_vector(8191 downto 0);
  d_in                                  : in std_logic_vector(511 downto 0);
  addr                                  : in std_logic_vector(3 downto 0);
  we_all                                : in std_logic;
  we                                    : in std_logic;
  d_out_all                             : out std_logic_vector(8191 downto 0);
  d_out                                 : out std_logic_vector(511 downto 0)
);
end entity simd512_ram_ce;

architecture simd512_ram_ce_rtl of simd512_ram_ce is
  
  alias slv is std_logic_vector;
  subtype word512 is slv(511 downto 0);
  type word512_array16 is array(0 to 15) of word512;
  
  constant ZEROS512                     : word512 := (others => '0');
  constant ZEROS512_ARRAY16             : word512_array16 := (others => ZEROS512);
  
  signal d_in_array                     : word512_array16;
  
  signal q_data                         : word512_array16;
  signal q_16_words                     : word512;
  
begin
  
  output_mapping : for i in 0 to 15 generate
    d_out_all((i+1)*512-1 downto i*512) <= q_data(i);
  end generate output_mapping;
  
  d_out                                 <= q_16_words;
  
  input_mapping : for i in 0 to 15 generate
    d_in_array(i)                       <= d_in_all((i+1)*512-1 downto i*512);
  end generate input_mapping;
  
  registers: process(clk)
  begin
    if rising_edge(clk) then
      if clk_en = '1' then
        if clr = '1' then
          q_data                        <= ZEROS512_ARRAY16;
          q_16_words                    <= (others => '0');
        elsif we_all = '1' then
          q_data                        <= d_in_array;
          q_16_words                    <= d_in_array(to_integer(unsigned(addr)));
        elsif we = '1' then
          q_data(to_integer(unsigned(addr))) <= d_in;
          q_16_words                    <= d_in;
        else
          q_16_words                    <= q_data(to_integer(unsigned(addr)));
        end if;
      end if;
    end if;
  end process registers;
  
end architecture simd512_ram_ce_rtl;
  