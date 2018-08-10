--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity sk_sreg is

port (  clk     : in  std_logic;
        st_in   : in  std_logic_vector(511 downto 0);
        st_out  : out std_logic_vector(511 downto 0)
     );

end sk_sreg;

architecture rtl of sk_sreg is

begin  -- Rtl

    begReg: process( clk )
    begin
        if rising_edge( clk ) then
            st_out <= st_in;
        end if;
    end process;

end rtl;
