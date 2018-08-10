-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;   
use ieee.numeric_std.all;
use work.sha3_pkg.all;

-- Streightforward implementation of ShiftRow function 
-- n and s values are implemented as generics, because 
-- aes_shiftrow function is used in two different flavors: 
-- like in AES (SHAvite-3, ECHO) and as a part of shiftwords
-- (ECHO)

entity aes_shiftrow is
generic (n	:integer := AES_BLOCK_SIZE;	s :integer := AES_SBOX_SIZE);
port( 
		input 		: in std_logic_vector(n-1 downto 0);
        output 		: out std_logic_vector(n-1 downto 0));
end aes_shiftrow;
  
architecture aes_shiftrow of aes_shiftrow is

begin

output(16*s-1 downto 15*s) <= input(16*s-1 downto 15*s);
output(15*s-1 downto 14*s) <= input(11*s-1 downto 10*s);			
output(14*s-1 downto 13*s) <= input(6*s-1 downto 5*s);			
output(13*s-1 downto 12*s) <= input(s-1 downto 0);	

output(12*s-1 downto 11*s) <= input(12*s-1 downto 11*s);			
output(11*s-1 downto 10*s) <= input(7*s-1 downto 6*s);			
output(10*s-1 downto 9*s) <= input(2*s-1 downto 1*s);			
output(9*s-1 downto 8*s) <= input(13*s-1 downto 12*s);

output(8*s-1 downto 7*s) <= input(8*s-1 downto 7*s);			
output(7*s-1 downto 6*s) <= input(3*s-1 downto 2*s);			
output(6*s-1 downto 5*s) <= input(14*s-1 downto 13*s);			
output(5*s-1 downto 4*s) <= input(9*s-1 downto 8*s);

output(4*s-1 downto 3*s) <= input(4*s-1 downto 3*s);			
output(3*s-1 downto 2*s) <=input(15*s-1 downto 14*s);			
output(2*s-1 downto 1*s) <= input(10*s-1 downto 9*s);			
output(s-1 downto 0) <= input(5*s-1 downto 4*s);

end aes_shiftrow; 
