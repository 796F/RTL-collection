-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_pkg.all;
use work.sha3_luffa_package.all;

entity luffa_mixword is 
	port	(xk : in std_logic_vector(31 downto 0);
			xk4 : in std_logic_vector(31 downto 0);
			yk : out std_logic_vector(31 downto 0);
			yk4 : out std_logic_vector(31 downto 0));
end  luffa_mixword;


architecture struct of luffa_mixword is

	signal s1 : std_logic_vector(31 downto 0);
	signal s2 : std_logic_vector(31 downto 0);
	signal s3 : std_logic_vector(31 downto 0);
	signal s4 : std_logic_vector(31 downto 0);
	signal s5 : std_logic_vector(31 downto 0);
	signal s6 : std_logic_vector(31 downto 0);

begin
	s1 <= xk xor xk4;
	s2 <= rolx(xk, sigma(1)); 
	s3 <= s2 xor s1;
	s4 <= rolx(s1, sigma(2));
	s5 <= s4 xor s3;
	s6 <= rolx(s3, sigma(3));
	yk <= s6 xor s5;
	yk4<= rolx(s5, sigma(4));  
end struct;