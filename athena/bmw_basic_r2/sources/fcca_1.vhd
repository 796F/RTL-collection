-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- ======================================================================

library ieee;
use ieee.std_logic_1164.all;   
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;


entity fcca is 
	generic (		
		n : integer := 64);
	port(
		a : in std_logic_vector(n-1 downto 0);
		b : in std_logic_vector(n-1 downto 0);
		s : out std_logic_vector(n-1 downto 0)
	);		
end fcca;

architecture struct of fcca is 
	signal gp : std_logic_vector(N/4-1 downto 1); -- group propagate
	signal gg : std_logic_vector(N/4-1 downto 1); -- group generate
	signal c : std_logic_vector(N/4 downto 1);
begin
												 
	-- Note : for cin = 0, c(1) = gg(0) = a(1)b(1) ^ [{a(1) xor b(1)} {a(0)b(0)}]
	c(1) <= (a(1) and b(1)) or ((a(1) xor b(1)) and (a(0) and b(0)));
	gen : for i in 1 to N/4-1 generate
		gg(i) <= (a(i*2+1) and b(i*2+1)) or ((a(i*2+1) xor b(i*2+1)) and (a(i*2) and b(i*2)));
		gp(i) <= ((a(i*2+1) xor b(i*2+1)) and (a(i*2) xor b(i*2)));			
		c(i+1) <= gg(i) or (gp(i) and c(i));				
	end generate;
	
	s(N/2-1 downto 0) <= a(N/2-1 downto 0) + b(N/2-1 downto 0);
	s(N-1 downto N/2) <= a(N-1 downto N/2) + b(N-1 downto N/2) + c(N/4);

end struct;