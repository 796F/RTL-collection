-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;

-- synchronous reset D flip-flop 

entity d_ff is 
port(
	clk		: in std_logic;
	ena		: in std_logic;
	rst		: in std_logic;
	d		: in std_logic;
	q		: out std_logic);
end d_ff;

architecture d_ff of d_ff is 
signal r	:std_logic;
begin
	
reg: 	process(clk)
		begin

			if (clk'event and clk='1') then 
				if rst ='1' then
					r <= '0'; 
				elsif ena = '1' then
					r <= d; 
				end if;
			end if; 

		end process;
	  q<=r;
end d_ff;

