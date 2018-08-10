--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak512_ram_sr is
port (
  clk                                   : in std_logic;
  data                                  : in std_logic_vector(63 downto 0);
  all_data                              : in std_logic_vector(1599 downto 0);
  addr                                  : in std_logic_vector(4 downto 0);
  we                                    : in std_logic;
  ad_we                                 : in std_logic;
  q                                     : out std_logic_vector(63 downto 0);
  all_q                                 : out std_logic_vector(1599 downto 0)
);
end entity keccak512_ram_sr;

architecture keccak512_ram_sr_rtl of keccak512_ram_sr is
  
  alias slv is std_logic_vector;  
  subtype word64 is slv(63 downto 0);
  type word64_array25 is array(0 to 24) of word64;
  
  signal all_data_array                 : word64_array25;
  
  signal q_ram_block                    : word64_array25;
  signal q_int                          : word64;
  
begin
  
  q                                     <= q_int;
  
  output_mapping : for i in 0 to 24 generate
    all_q((i+1)*64-1 downto i*64)       <= q_ram_block(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 24 generate
    all_data_array(i)                   <= all_data((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  registers: process(clk)
  begin
    if rising_edge(clk) then
      if ad_we = '1' then
        q_ram_block                     <= all_data_array;
      elsif we = '1' then
        q_ram_block(to_integer(unsigned(addr))) <= data;
      end if;
      q_int                             <= q_ram_block(to_integer(unsigned(addr)));
    end if;
  end process registers;
  
end architecture keccak512_ram_sr_rtl;
  