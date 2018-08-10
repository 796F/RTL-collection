-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;

-- down countern 

entity decountern is
	generic ( 		
		n : integer := 64;
		sub : integer := 1
	);
	port ( 	  
		clk 	: in std_logic;
		rst		: in std_logic;
	    load 	: in std_logic;
	    en 		: in std_logic; 
		input  	: in std_logic_vector(n-1 downto 0);
		--sub		: in std_logic_vector(n-1 downto 0);
        output  : out std_logic_vector(n-1 downto 0)
	);
end decountern;

architecture struct of decountern is
   signal temp : std_logic_vector(n-1 downto 0);
begin
	
	gen : process( clk )
	begin
		if rising_edge( clk ) then
			if ( rst = '1' ) then
				temp <= (others => '0');
			elsif (load = '1' ) then
				temp <= input;
			elsif ( en = '1' ) then
				temp <= temp - sub;
			end if;
		end if;
	end process;  
	output <= temp;
end struct;