-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mod257 is
    port ( i : in  STD_LOGIC_VECTOR (16 downto 0);
           o : out  STD_LOGIC_VECTOR (8 downto 0));
end mod257;

architecture struct of mod257 is

	signal xl:std_logic_vector(7 downto 0);
	signal xh:std_logic_vector(8 downto 0);
	signal a,b: std_logic_vector(8 downto 0);
	signal t1,t2,t3: std_logic_vector(8 downto 0);
	signal cy:std_logic;

begin
	
	xl<=i(7 downto 0);
	xh<=i(16 downto 8);
	
	t1 <= '0'&xl;
	t2 <= xh;
	t3 <= t1-t2;
	
	a <= t3(8 downto 0);
	
	b <= t3 + "100000001";  --  b = a+ 257;
	
	cy <= t3(8);
	
	o <= a when cy='0' else   b; 
	

end struct;

