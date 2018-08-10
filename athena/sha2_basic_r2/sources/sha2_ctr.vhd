-- =====================================================================
-- Copyright © 2010-11 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.sha2_pkg.all;

entity sha2_ctr is 
generic (
	s 		: integer :=2; 	-- size of counter 
	r		: integer:=2; 	-- counter limit 
	step	: integer:=1);	-- stepping 
port(
	clk		:in std_logic;
	reset 		:in std_logic;
	ena 		:in std_logic;
	ctr		:out std_logic_vector(s-1 downto 0));
end sha2_ctr;

architecture sha2_ctr of sha2_ctr is 
	signal reg	:std_logic_vector(s-1 downto 0);
begin

process(clk, reset)
begin
	if reset='1' then 
		reg<= (others =>'0');
	elsif (clk'event and clk='1') then 
		if ena = '1' then
			if (reg=std_logic_vector(conv_unsigned(r, s))) then
				reg<= (others =>'0');		
			else 	
				reg <=reg+step;
			end if;

		end if;

	end if;
end process;
	
	ctr <= reg;
	
end sha2_ctr;
