-- =====================================================================
-- Copyright © 2010-11 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_pkg.all;	
use work.sha2_pkg.all;

entity sha2_sigma_func is
generic( 
	n 		: integer :=HASH_SIZE_256/SHA2_WORDS_NUM; 		-- size of basic operation
	func 		: string :="ms"; 		-- message scheduler or compression function
	a 		: integer:=ARCH32_CF0_1;	-- rotation values are different for MS and for CF  	 	
	b 		: integer:=ARCH32_CF0_2; 
	c 		: integer:=ARCH32_CF0_3);
port(
	x		:in std_logic_vector(n-1 downto 0);
	o		:out std_logic_vector(n-1 downto 0));
end sha2_sigma_func;

architecture sha2_sigma_func of sha2_sigma_func is
	signal tmp	:std_logic_vector(c-1 downto 0);
begin										  
	
ms:	if func="ms" generate
			tmp <= (others=>'0');
	end generate;

cf:	if func="cf" generate
			tmp <= x(c-1 downto 0);
	end generate;
			
			o <= (x(a-1 downto 0) & x(n-1 downto a))
		 	xor (x(b-1 downto 0) & x(n-1 downto b))
	 		xor (tmp & x(n-1 downto c));
						
end sha2_sigma_func;
