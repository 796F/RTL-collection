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
	signal reg_in, reg_out : std_logic_vector(n-1 downto 0);
	signal ctrl : std_logic; 
begin
	
	reg_in <= input when load = '1' else reg_out - sub;
	ctrl <= load or en;
	
	gen : process( clk )
	begin
		if rising_edge( clk ) then
			if ( rst = '1' ) then
				reg_out <= (others => '0');			
			elsif ( ctrl = '1' ) then
				reg_out <= reg_in;
			end if;
		end if;
	end process;  
	output <= reg_out;
end struct;					 