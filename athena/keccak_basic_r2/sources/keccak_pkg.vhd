-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;


package keccak_pkg is
 
 -- Keccak parameters 
constant KECCAK_STATE 			: integer := 1600;	
constant KECCAK256_CAPACITY 	: integer := 1088;
constant KECCAK512_CAPACITY 	: integer := 576;

-- width of the interface ports
constant w						: integer := 64;   
constant LOG2_W 				: integer := 6;
constant log2roundnr_final256 	: integer := 6; 
constant KECCAK256_WORDS 		: integer:=  KECCAK256_CAPACITY/w;
constant KECCAK512_WORDS 		: integer:=  KECCAK512_CAPACITY/w;
 
		 
-- number of rounds of Keccak 		 
constant roundnr256	 			: integer := 24;
constant roundnr_final 			: integer := 1;

-- Keccak data types 
type plane  is array (4 downto 0) of std_logic_vector(63 downto 0);
type state 	is array (4 downto 0) of plane;

end keccak_pkg;

package body keccak_pkg is
end package body keccak_pkg;