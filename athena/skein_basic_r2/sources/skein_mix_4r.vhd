-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.sha3_skein_package.all;

entity skein_mix_4r is		
	generic ( adder_type : integer := SCCA_BASED;
			  rotate_0 : integer := 1; 
			  rotate_1 : integer := 2 );
	port ( 							 
		sel : in std_logic;
		a : in std_logic_vector(iw-1 downto 0);
		b : in std_logic_vector(iw-1 downto 0);
		c, d : out std_logic_vector(iw-1 downto 0) 
	);
end skein_mix_4r;

architecture struct of skein_mix_4r is
	signal temp : std_logic_vector(iw-1 downto 0);	  
	signal b_rotate :  std_logic_vector(iw-1 downto 0);
begin
	add_call1 : adder generic map ( adder_type => adder_type, n => 64 ) port map ( a => a, b => b, s => temp);
	c <= temp;			
	-- there is no rotate of value 0, so no need to do anything here.
	b_rotate <= rolx(b,rotate_0) when sel = '0' else rolx(b,rotate_1);
	d <= b_rotate xor temp;
end struct;