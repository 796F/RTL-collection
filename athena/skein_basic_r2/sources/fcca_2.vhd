-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- ======================================================================

library ieee;
use ieee.std_logic_1164.all;   
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;

library UNISIM;
use UNISIM.VComponents.all;

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
	LUT4_inst : LUT4
		-- synthesis translate off
		generic map (
		INIT => X"F880") -- Specify LUT Contents
		-- synthesis translate on
		port map (
		O => c(1), 	 -- p
		I0 => a(0),   -- LUT input
		I1 => b(0),   -- LUT input
		I2 => a(1), -- LUT input
		I3 => b(1)
	);
		
	gen : for i in 1 to N/4-1 generate
		
		LUT6_2_inst : LUT6_2
			-- synthesis translate off
			generic map (
			INIT => X"000006600000F880") -- Specify LUT Contents : Content Location 16-31,48-63 are unused			
			-- synthesis translate on
			port map (
			O6 => gp(i),	-- 0-15 = X"0660" (47 downto 32)
			O5 => gg(i),	-- 32-47 = X"F880" (15 downto 0)
			I0 => a(i*2),   
			I1 => b(i*2),   
			I2 => a(i*2+1), 
			I3 => b(i*2+1),
			I4 => '0',
			I5 => '1' 
		);

		
		muxcy_int : MUXCY
		port map (
		s => gp(i),
		di => gg(i),
		ci => c(i),
		o => c(i+1));			
	end generate;
	
	s(N/2-1 downto 0) <= a(N/2-1 downto 0) + b(N/2-1 downto 0);
	s(N-1 downto N/2) <= a(N-1 downto N/2) + b(N-1 downto N/2) + c(N/4);
	

end struct;