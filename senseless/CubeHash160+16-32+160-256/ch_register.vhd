--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ch_register is

port (  clk        : in  std_logic;
        state_in   : in  std_logic_vector(1023 downto 0);
        state_out  : out std_logic_vector(1023 downto 0)
     );

end ch_register;

architecture rtl of ch_register is

begin  -- Rtl

    begReg: process( clk )
    begin
        if rising_edge( clk ) then
            state_out <= state_in;
        end if;
    end process;

end rtl;
