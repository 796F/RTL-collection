-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;	 
use work.sha3_pkg.all;

package sha3_cubehash_package is
	-- ===================
	-- Depending parameter values, use the following :
	-- ===================
	-- for r/b-h = 16/32-256 
	-- roundnr = r = 16
	-- mw = b*8 = 32*8 = 256
	-- h = h = 256
	-- ===================
	constant b		: integer := 1024;
	constant iw		: integer := 32;
	
	
	constant bseg			: integer := b/64;
	constant bzeros			: std_logic_vector(b-1 downto 0) := (others => '0');
	
	--type std_logic_matrix is array (bseg-1 downto 0) of std_logic_vector(w - 1 downto 0) ;
	
	-- iv	   
	-- iv = r , b, h
	constant iv_16_32_256  : std_logic_vector (b-1 downto 0):= (
							x"b4d42bea" & x"9ff2d6cc" & x"717e1163" & x"ae1e4835" & x"5b2d5122" & x"634ed9e5" & x"3141627e" & x"be12ccf4" &
							x"96b6d0c2" & x"7020af42" & x"350c72d0" & x"8cda6133" & x"a4eccc28" & x"83adf88e" & x"00ac8046" & x"abfbe540" &
							x"c34190d8" & x"d5fb0761" & x"419d856c" & x"7966b2f0" & x"49253909" & x"0356a25f" & x"fd92c865" & x"8562cb93" &
							x"aeb5f22a" & x"604e4b9e" & x"ddbf4a77" & x"25472585" & x"eb5a8115" & x"d6aab64a" & x"aff8da9c" & x"0a2c03d6"); 
										 
	constant iv_16_32_512  : std_logic_vector (b-1 downto 0):= (
							x"612aea2a" & x"d494f450" & x"8b8b532d" & x"3ed86741" & x"1323ee3f" & x"8ccf01c7" & x"8e9639cc" & x"9556ac50" &
							x"87c7424d" & x"b3a847a6" & x"ef0bcf97" & x"37455b82" & x"d264f8ee" & x"c49020f2" & x"33cde5d0" & x"ae1139a2" &
							x"d998d3fc" & x"85e48f14" & x"ef7b011b" & x"324544b6" & x"5961536a" & x"1c78f52f" & x"3479fa91" & x"a9deba0d" &
							x"2b8a5cd6" & x"750ea7a5" & x"5624c6b1" & x"766579bc" & x"f7c82119" & x"f19a98e7" & x"46d29577" & x"443b3ed4"); 
	-- declare functions and procedure	
	function get_iv ( hashsize : integer ) return std_logic_vector;
end sha3_cubehash_package;


package body sha3_cubehash_package is						
	function get_iv ( hashsize : integer ) return std_logic_vector is
	begin
		if ( hashsize = 256 ) then
			return ( switch_endian_byte( iv_16_32_256, b , iw) );
		elsif ( hashsize = 512 )  then
			return ( switch_endian_byte( iv_16_32_512, b , iw) );
		else
			return bzeros;
		end if;
	end function get_iv;										    
end sha3_cubehash_package;
