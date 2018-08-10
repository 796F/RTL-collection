-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_pkg.all;

-- parallel counter

entity pc is 
	generic (n :integer :=32);
	port (
		a		: in std_logic_vector(n-1 downto 0);
		b		: in std_logic_vector(n-1 downto 0);
		c		: in std_logic_vector(n-1 downto 0);
		d		: in std_logic_vector(n-1 downto 0);
		e		: in std_logic_vector(n-1 downto 0);
		s0		: out std_logic_vector(n-1 downto 0);
		s1		: out std_logic_vector(n downto 1);
		s2		: out std_logic_vector(n+1 downto 2)
	);
end pc;

architecture pc of pc is 						 
	signal cfa, cha : std_logic_vector(n-1 downto 0);	-- Carry of Full Adder (CFA) and Carry of Half Adder (CHA)
	signal sfa, sha : std_logic_vector(n-1 downto 0);	-- Sum of Full Adder (SFA) and Sum of Half Adder (SHA)
	signal tmp1, tmp2 : std_logic_vector(n-1 downto 0);
begin
	
	csa_instance1:	
		for i in 0 to n-1 generate 											  
			sfa(i) <= a(i) xor b(i) xor c(i);
			sha(i) <= d(i) xor e(i);
			
			twobitsbefore_end: if i < n generate
				s2(i+2) <= (cfa(i) and cha(i)) or (tmp1(i) and tmp2(i));
			end generate;
			
			onebitbefore_end: if i < n generate
				cfa(i) <= (a(i) and b(i)) or (a(i) and c(i)) or (b(i) and c(i));
				cha(i) <= d(i) and e(i);
				tmp1(i)	<= sha(i) and sfa(i);
				tmp2(i) <= cfa(i) xor cha(i);
				s1(i+1) <= tmp1(i) xor tmp2(i);
			end generate;

			s0(i) 	<= sha(i) xor sfa(i);
		end generate;	
		
end pc;

