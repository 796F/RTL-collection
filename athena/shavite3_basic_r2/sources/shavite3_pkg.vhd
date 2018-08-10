-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all; 
use work.sha3_pkg.all;

package shavite3_pkg is
-- supported sizes of message digests
constant SHAVITE3_STATE_SIZE_256			:integer:=512;	
constant SHAVITE3_STATE_SIZE_512			:integer:=1024;	
constant SHAVITE3_WORD_SIZE					:integer:=32;	 
-- initialization vectors
constant SHAVITE3_INIT_VALUE_256			:std_logic_vector(255 downto 0) := x"3EECF551_BF10819B_E6DC8559_F3E23FD5_431AEC73_79E3F731_98325F05_A92A31F1";
constant SHAVITE3_INIT_VALUE_512			:std_logic_vector(511 downto 0) := x"6A14BA06EB784EBDAB3C013063473C2DFA564CEB336D2629E24E213EDBD15E125DA35195FEC384E7BE0B4A116666ADE6B4FFED9DF3E9C1F45E683CFAF34CD4E9";  
constant SHAVITE3_TEMPORARY_SALT_256		:std_logic_vector(255 downto 0) := (others=>'0'); 
constant SHAVITE3_TEMPORARY_SALT_512		:std_logic_vector(511 downto 0) := (others=>'0');   
constant w		: integer := 64;		-- message interface	
-- number of rounds of respective varians
constant roundnr512 		: integer := 59;
constant roundnr256 		: integer := 38;
constant roundnr_final 	: integer := 1;
constant log2roundnr_final256	: integer := 6;--log2( roundnr256 );
constant log2roundnr_final512	: integer := 6;--log2( roundnr512 );
		
type matrix is array (1 to 4) of std_logic_vector(31 downto 0); 
type matrix2 is array (1 to 16) of std_logic_vector(31 downto 0); 

type matrix_double is array (1 to 8) of std_logic_vector(31 downto 0); 
type matrix_double2 is array (1 to 32) of std_logic_vector(31 downto 0); 

end shavite3_pkg;

package body shavite3_pkg is
end package body shavite3_pkg;