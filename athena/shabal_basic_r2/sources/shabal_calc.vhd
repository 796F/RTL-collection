library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sha3_shabal_package.all;
use work.sha3_pkg.all;

entity shabal_calc is	 	
	port (
		a0  : in std_logic_vector(31 downto 0);	
		a11 : in std_logic_vector(31 downto 0);
		c8 : in std_logic_vector(31 downto 0);
		m0 : in std_logic_vector(31 downto 0);
		b0, bo1, bo2, bo3 : in std_logic_vector(31 downto 0);
		
		new_a, new_b : out std_logic_vector(31 downto 0)
	);				  
end shabal_calc;

architecture struct of shabal_calc is 

	signal xor1 : std_logic_vector(31 downto 0);	 
	signal temp1 : std_logic_vector(29 downto 0);
	signal temp2 : std_logic_vector(30 downto 0);
	signal a11r, vv, uu : std_logic_vector(31 downto 0);  
	signal bxor, b0r :  std_logic_vector(31 downto 0);  		 
	
begin	   	
		a11r <= rolx(a11,15);
		temp1 <= a11r(29 downto 0) + a11r(31 downto 2);
	   	vv <= temp1 & a11r(1 downto 0);		
		xor1 <= vv xor a0 xor c8;
		temp2 <= xor1(30 downto 0) + xor1(31 downto 1);
		uu <= temp2 & xor1(0);
		bxor <= bo1 xor (bo2 and (not bo3));
		new_a <= uu xor m0 xor bxor;
		b0r <= rolx(b0,1);
		new_b <= uu xor m0 xor bxor xor (not b0r);
end struct;