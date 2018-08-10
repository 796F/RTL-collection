-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;  
use ieee.std_logic_arith.all;
use work.sha3_pkg.all;

package sha3_skein_package is	
	constant iw				: integer := 64;		-- DO NOT CHANGE VALUE: internal width is always 64 bits
	constant iwzeros		: std_logic_vector(iw-1 downto 0) := (others => '0');
							 
	type round_array is array (natural range <>, natural range <>) of std_logic_vector(63 downto 0);
	type key_array is array (natural range <>) of std_logic_vector(63 downto 0); 
	-- constants
	constant key_const		: std_logic_vector(63 downto 0)	:= 	x"5555555555555555";
	constant key_iv_256_256	: std_logic_vector(255 downto 0):= 	x"164290A9D4EEEF1D" & x"8E7EAF44B1B0CD15" & x"A8BA0822F69D09AE" & x"0AF25C5E364A6468";	
	constant key_iv_512_256 : std_logic_vector(511 downto 0):= 	x"85A195B18B2264EC" & x"7A6DAC64C047C2B0" & x"E1A21465EE3FE124" & x"1D2117356504425A" & 
																x"C962DC0FC0046F2C" & x"8D5A3E904B1BE9C8" & x"AFB7174BBD8FEEE9" & x"7FE63D9BF94EDEB8"; 
	constant key_iv_512_512 : std_logic_vector(511 downto 0):= 	x"1A9A721C8A265CA5" & x"C9ABACF5AA853978" & x"4AF6652AB80A2883" & x"66F5E8A809A773C7" &
																x"7FA984B781BAAF5B" & x"0FE5D2D93233F397" & x"6E29F932DCB412D7" & x"D40CD9472F225C23";	

	
	constant TW_MSG_CONS : std_logic_vector(5 downto 0) := conv_std_logic_vector(48,6);
	constant TW_OUT_CONS : std_logic_vector(5 downto 0) := conv_std_logic_vector(63,6);
	
	type rot_type is array (natural range <>,natural range <>) of integer;	  

	constant rot_512 : rot_type(0 to 3,0 to 7) := ( 	(46, 33, 17, 44, 39, 13, 25,  8),(36, 27, 49,  9, 30, 50, 29, 35),
													(19, 14, 36, 54, 34, 10, 39, 56),(37, 42, 39, 56, 24, 17, 43, 22) );	
	
	type permute_type is array (natural range <>) of integer range 0 to 15;
	function get_perm ( b : integer ) return permute_type;
	function get_rot ( b : integer ) return rot_type;		
	function get_iv ( h : integer ) return std_logic_vector;
	
	
end sha3_skein_package;

package body sha3_skein_package is
	
	function get_perm ( b : integer ) return permute_type is						 
		constant perm_256 : permute_type(0 to 3) := (0, 3, 2 , 1);
		constant perm_512 : permute_type(0 to 7) := (2, 1, 4, 7, 6, 5, 0, 3);
		constant perm_1024 : permute_type(0 to 15)  := (0, 9, 2, 13, 6, 11, 4, 15, 10, 7, 12, 3, 14, 5, 8, 1);
	begin
		if ( b = 256 ) then
			return perm_256;
		elsif ( b = 512 ) then
			return perm_512;
		else
			return perm_1024;
		end if;
	end function get_perm;	  
	
	function get_rot ( b : integer ) return rot_type is						 
		constant rot_256 : rot_type(0 to 1,0 to 7) := (	(14, 52, 23, 5, 25, 46, 58, 32),(16, 57, 40, 37, 33, 12, 22, 32) );	 
		constant rot_512 : rot_type(0 to 3,0 to 7) := ( 	(46, 33, 17, 44, 39, 13, 25,  8),(36, 27, 49,  9, 30, 50, 29, 35),
													(19, 14, 36, 54, 34, 10, 39, 56),(37, 42, 39, 56, 24, 17, 43, 22) );
	begin
		if ( b = 256 ) then
			return rot_256;
		else
			return rot_512;
		end if;
	end function;
	
	function get_iv ( h : integer ) return std_logic_vector is						 
	begin
		if ( h = 256 ) then								 
			return switch_endian_word(key_iv_512_256,512,64);
		else
			return switch_endian_word(key_iv_512_512,512,64);
		end if;
	end function;
	
end package body;