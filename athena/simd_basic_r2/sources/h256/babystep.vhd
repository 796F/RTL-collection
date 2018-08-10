-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;  
use ieee.std_logic_unsigned.all;
use work.twiddle_factor_pkg.all;  
use work.sha3_simd_package.all;
use work.sha3_pkg.all;

entity babystep is
	generic ( row : integer := 0 );
	port ( 	ii 		: in  	array_4x32;
			spi : in std_logic_vector(1 downto 0);
			win, ain 	: in std_logic_vector(31 downto 0);
			sphi 	: in std_logic;	 
			oo		: out 	array_4x32 );	
end babystep;

architecture struct of babystep is
	signal phi, iff, maj : std_logic_vector(31 downto 0);
	signal a, b, c, add2, shfs : std_logic_vector(31 downto 0);
begin												  
	a <= ii(0);
	b <= ii(1);
	c <= ii(2);	
	
	iff <= (a and b) or ((not a) and c);
	maj <= (a and b) or (a and c) or (b and c);
	phi <= maj when sphi = '1' else iff;
	add2 <= (ii(3) + phi) + win;
	
	with spi select		
	oo(1) <= 	rolx(a,conv_integer(pi_cons(0)(row))) when "00",
				rolx(a,conv_integer(pi_cons(1)(row))) when "01",
				rolx(a,conv_integer(pi_cons(2)(row))) when "10",
				rolx(a,conv_integer(pi_cons(3)(row))) when others;
	
	oo(2) <= b;
	oo(3) <= c;
	with spi select		
	shfs <= 	rolx(add2,conv_integer(pi_cons(0)((row + 1) mod 4))) when "00",
				rolx(add2,conv_integer(pi_cons(1)((row + 1) mod 4))) when "01",
				rolx(add2,conv_integer(pi_cons(2)((row + 1) mod 4))) when "10",
				rolx(add2,conv_integer(pi_cons(3)((row + 1) mod 4))) when others;
	oo(0) <= ain + shfs;
end struct;