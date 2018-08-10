-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

--    				if (y[i] > 128)
--      				y[i] -= 257;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lift is
    port ( i : in  STD_LOGIC_VECTOR (8 downto 0);		   
           o : out  STD_LOGIC_VECTOR (15 downto 0));
end lift;

architecture struct of lift is		  
	signal sub : std_logic_vector(7 downto 0);
begin	   										
	sub <= i(7 downto 0) - '1';
	
	o <=  "0000000" & i when i <= 128 else  x"FF" & sub;

end struct;