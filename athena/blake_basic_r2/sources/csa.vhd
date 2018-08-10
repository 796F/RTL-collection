-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;

-- carry save adder 

entity csa is 
generic (n :integer := 32);
port (
	a		: in std_logic_vector(n-1 downto 0);
	b		: in std_logic_vector(n-1 downto 0);
	cin		: in std_logic_vector(n-1 downto 0);
	s		: out std_logic_vector(n-1 downto 0);
	cout	: out std_logic_vector(n downto 1));
end csa;


architecture csa of csa is 

begin

csa_instance1:	for i in 0 to n-1 generate 
					cout(i+1) <= (a(i) and b(i)) or (a(i) and cin(i)) or (b(i) and cin(i));
					s(i) <= a(i) xor b(i) xor cin(i);
				end generate;
					
end csa;

