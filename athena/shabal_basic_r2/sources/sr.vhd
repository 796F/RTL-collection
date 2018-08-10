-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;

entity sr is
	port (	   
		clk : in std_logic;
		set, clr : in std_logic;
		o : out std_logic					 
	);
end entity sr;

architecture struct of sr is

begin	   
	srreg_gen : process ( clk )
	begin
		if rising_edge( clk ) then 
			if clr = '1' then
				o <= '0';
			elsif set = '1' then
				o <= '1';
			end if;
		end if;
	end process;
	
end struct;