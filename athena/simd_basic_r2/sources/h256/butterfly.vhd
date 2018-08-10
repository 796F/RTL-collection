-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.twiddle_factor_pkg.all;

entity butterfly is
    Port ( x0 : in  STD_LOGIC_VECTOR (8 downto 0);
           x1 : in  STD_LOGIC_VECTOR (8 downto 0);
           tw : in  STD_LOGIC_VECTOR (7 downto 0);	  
           y0 : out  STD_LOGIC_VECTOR (8 downto 0);
           y1 : out  STD_LOGIC_VECTOR (8 downto 0));
end butterfly;

architecture struct of butterfly is
	signal temp1,temp2,temp7,temp8 : std_logic_vector(16 downto 0);
	signal temp3,temp4 : std_logic_vector(8 downto 0);
	signal temp5,temp6,a,b,c,d : std_logic_vector(9 downto 0);

begin

	temp1<=x1*tw; 	
	mod1: mod257 port map ( i =>temp1, o =>temp3 );
	temp2<=temp3&"00000000";	
	mod2: mod257 port map ( i =>temp2, o =>temp4 );

	a<='0'&temp4;
	b<='0'&x0;
	temp6<=a+b;
	temp7<="0000000"&temp6;--before mod, making the input signal to mod 18 bits so as to be general mod component
	mod3: mod257 port map ( i =>temp7, o => y1 );
	
	c<='0'&temp3;
	d<='0'&x0;
	temp5<=c+d;
	temp8<="0000000"&temp5;
	mod4: mod257 port map ( i =>temp8, o => y0 );
		  
end struct;

