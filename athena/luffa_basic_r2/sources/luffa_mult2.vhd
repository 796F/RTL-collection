-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;


entity luffa_mult2 is
	port (	input : in std_logic_vector(255 downto 0);
			output : out std_logic_vector (255 downto 0));
end luffa_mult2;

architecture struct of luffa_mult2 is

begin
	output(31 downto 0) <= input(63 downto 32);
	output(63 downto 32) <= input(95 downto 64);
	output(95 downto 64) <= input(127 downto 96);
	output(127 downto 96) <= input(159 downto 128) xor input(31 downto 0);
	output(159 downto 128) <= input(191 downto 160) xor input(31 downto 0); 
	output(191 downto 160) <= input(223 downto 192);
	output(223 downto 192) <= input(255 downto 224) xor input(31 downto 0);
	output(255 downto 224)<= input(31 downto 0);
end struct;