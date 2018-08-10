-- =====================================================================
-- Copyright © 2010-11 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;  
use work.sha3_pkg.all;
use work.sha2_pkg.all;


entity sha2_ch_func is
generic( n : integer :=HASH_SIZE_256/SHA2_WORDS_NUM);
port(
	x		:in std_logic_vector(n-1 downto 0);
	y		:in std_logic_vector(n-1 downto 0);
	z		:in std_logic_vector(n-1 downto 0);
	o		:out std_logic_vector(n-1 downto 0));
end sha2_ch_func;

architecture sha2_ch_func of sha2_ch_func is
begin

	o <= (x and y) xor ((not x) and z);
end sha2_ch_func; 

