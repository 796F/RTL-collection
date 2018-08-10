--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak512_ram_mr is
port (
  clk                                   : in std_logic;
  data                                  : in std_logic_vector(1599 downto 0);
  addr                                  : in std_logic_vector(124 downto 0); 
  we                                    : in std_logic;
  q                                     : out std_logic_vector(1599 downto 0)
);
end entity keccak512_ram_mr;

architecture keccak512_ram_mr_rtl of keccak512_ram_mr is
  
  alias slv is std_logic_vector;  
  subtype word64 is slv(63 downto 0);
  subtype word5 is slv(4 downto 0);
  type word64_array25 is array(0 to 24) of word64;
  type word5_array25 is array(0 to 24) of word5;
  
  signal data_array                     : word64_array25;
  signal addr_array                     : word5_array25;
  
  signal q_data                         : word64_array25;
  signal q_data_reordered               : word64_array25;
  
begin
  
  output_mapping : for i in 0 to 24 generate
    q((i+1)*64-1 downto i*64)           <= q_data_reordered(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 24 generate
    data_array(i)                       <= data((i+1)*64-1 downto i*64);
    addr_array(i)                       <= addr((i+1)*5-1 downto i*5);
  end generate input_mapping;
  
  registers: process(clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        q_data                          <= data_array;
      end if;
      for i in 0 to 24 loop
        q_data_reordered(i)             <= q_data(to_integer(unsigned(addr_array(i))));
      end loop;
    end if;
  end process registers;
  
end architecture keccak512_ram_mr_rtl;
  