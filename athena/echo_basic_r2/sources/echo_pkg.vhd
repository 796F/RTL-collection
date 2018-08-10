-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all; 
use work.sha3_pkg.all;

package echo_pkg is

constant ECHO_STATE_SIZE				:integer:=2048;	
constant ECHO_DATA_SIZE_BIG				:integer:=1536;
constant ECHO_DATA_SIZE_SMALL			:integer:=1024;
constant ECHO_QWORD_SIZE				:integer:=128;
constant ECHO_WORD_SIZE					:integer:=ECHO_QWORD_SIZE/4;	 
-- initialization vectors
constant ECHO_INIT_VALUE_224			:std_logic_vector(ECHO_QWORD_SIZE-1 downto 0) := x"E0000000000000000000000000000000";
constant ECHO_INIT_VALUE_256			:std_logic_vector(ECHO_QWORD_SIZE-1 downto 0) := x"00010000000000000000000000000000";
constant ECHO_INIT_VALUE_384			:std_logic_vector(ECHO_QWORD_SIZE-1 downto 0) := x"80010000000000000000000000000000";
constant ECHO_INIT_VALUE_512			:std_logic_vector(ECHO_QWORD_SIZE-1 downto 0) := x"00020000000000000000000000000000";
constant ECHO_TEMPORARY_SALT			:std_logic_vector(ECHO_QWORD_SIZE-1 downto 0) := x"00000000000000000000000000000000";  

constant ECHO_BIG_HEX_DATA_SIZE			:std_logic_vector(63 downto 0):= x"00000000_00000600";
constant ECHO_SMALL_HEX_DATA_SIZE		:std_logic_vector(63 downto 0):= x"00000000_00000400";

-- architectures of ECHO
constant ECHO_ARCH_BASIC_LOOP			:integer:=1;		
constant ECHO_ARCH_FOLDx4				:integer:=4;
constant ECHO_ARCH_FOLDx8				:integer:=8;
constant ECHO_ARCH_FOLDx16				:integer:=16;
constant ECHO_ARCH_FOLDx2_3			:integer:=2;

constant b		: integer := ECHO_STATE_SIZE;
constant w		: integer := 64;		-- message interface	
	
-- number of clock cycles per architecture	
constant roundnr256 			: integer := 26;
constant roundnr_final256 		: integer := 1;
constant log2roundnr_final256	: integer := log2( roundnr256);
	
constant roundnr512 			: integer := 32;
constant roundnr_final512 		: integer := 1;
constant log2roundnr_final512	: integer := log2( roundnr512)+1;

constant bseg			: integer := b/w;
	
constant bzeros			: std_logic_vector(b-1 downto 0) := (others => '0');
constant wzeros			: std_logic_vector(w-1 downto 0) := (others => '0');
	
end echo_pkg;

package body echo_pkg is
end package body echo_pkg;