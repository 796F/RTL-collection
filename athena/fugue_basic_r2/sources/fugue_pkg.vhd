-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all; 
use work.sha3_pkg.all;

package fugue_pkg is

-- 	hardware architectures for Fugue
constant FUGUE_ARCH_BASIC_LOOP	:integer:=1;		
constant FUGUE_ARCH_UNROLL		:integer:=2;
constant FUGUE_ARCH_FOLDx2		:integer:=3;
constant FUGUE_ARCH_FOLDx4		:integer:=4;
constant FUGUE_ARCH_FOLDx8		:integer:=5;
constant FUGUE_ARCH_FOLDx16		:integer:=6;

-- types of Fugue round 
constant FUGUE_ROUND_BASIC		:integer:=1;
constant FUGUE_ROUND_TBOX		:integer:=2;
	
constant FUGUE_WORD_SIZE		:integer:=32;	
constant w						:integer:=FUGUE_WORD_SIZE;

constant FUGUE_INIT_224			:std_logic_vector(HASH_SIZE_224-1 downto 0) := x"0d12c9f457f786621ce039eecbe374e0627c12a115d2439a9a678dbd";
constant FUGUE_INIT_256			:std_logic_vector(HASH_SIZE_256-1 downto 0) := x"debd52e95f13716668f6d4e094b5b0d21d626cf9de29f9fb99e8499148c2f834";
constant FUGUE_INIT_384			:std_logic_vector(HASH_SIZE_384-1 downto 0) := x"0dec61aa1f2e2531c7b41da0850960004af45e219c5e1b749a3e69fa40b03e478aae02e5e0259ca97c5195bca195105c";
constant FUGUE_INIT_512			:std_logic_vector(HASH_SIZE_512-1 downto 0) := x"7ea5078875af16e6dbe4d3c527b09aac17f115d954cceeb60b02e806d1ef924ac9e2c6aa9813b2dd3858e6ca3f207f43e778ea25d6dd1f951dd16eda67353ee1";
	
type state is array (0 to 29) of std_logic_vector(FUGUE_WORD_SIZE-1 downto 0); 
type state_big is array (0 to 35) of std_logic_vector(FUGUE_WORD_SIZE-1 downto 0); 

end fugue_pkg;

package body fugue_pkg is

end package body fugue_pkg;