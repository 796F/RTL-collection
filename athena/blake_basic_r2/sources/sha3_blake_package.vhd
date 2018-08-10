-- =========================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =========================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;	 
use work.sha3_pkg.all;

package sha3_blake_package is			

		-- iv
	constant iv_224  : std_logic_vector (255 downto 0):= (
						x"BEFA4FA4" & x"64F98FA7" & x"68581511" & x"FFC00B31" & 
						x"F70E5939" & x"3070DD17" & x"367CD507" & x"C1059ED8");
	constant iv_256  : std_logic_vector (255 downto 0):= (
						x"5BE0CD19" & x"1F83D9AB" & x"9B05688C" & x"510E527F" & 
						x"A54FF53A" & x"3C6EF372" & x"BB67AE85" & x"6A09E667" );
	constant iv_384  : std_logic_vector (511 downto 0):= (
						x"47B5481DBEFA4FA4" & x"DB0C2E0D64F98FA7" & x"8EB44A8768581511" &x"67332667FFC00B31" &
						x"152FECD8F70E5939" & x"9159015A3070DD17" & x"629A292A367CD507" & x"CBBB9D5DC1059ED8" );
	constant iv_512  : std_logic_vector (511 downto 0):= (
						x"5BE0CD19137E2179" & x"1F83D9ABFB41BD6B" & x"9B05688C2B3E6C1F" &  x"510E527FADE682D1" & 
						x"A54FF53A5F1D36F1" & x"3C6EF372FE94F82B" & x"BB67AE8584CAA73B" & x"6A09E667F3BCC908");
						
		-- constant			
	constant const32 : std_logic_vector(511 downto 0) := (
						x"B5470917" & x"3F84D5B5" & x"C97C50DD" & x"C0AC29B7" & 
						x"34E90C6C" & x"BE5466CF" & x"38D01377" & x"452821E6" & 
						x"EC4E6C89" & x"082EFA98" & x"299F31D0" & x"A4093822" & 
						x"03707344" & x"13198A2E" & x"85A308D3" & x"243F6A88" );
						
	constant const64 : std_logic_vector(1023 downto 0) := (
						x"636920D871574E69" & x"0801F2E2858EFC16" & x"24A19947B3916CF7" & x"BA7C9045F12C7F99" &
						x"B8E1AFED6A267E96" & x"2FFD72DBD01ADFB7" & x"D1310BA698DFB5AC" & x"9216D5D98979FB1B" & 
						x"3F84D5B5B5470917" & x"C0AC29B7C97C50DD" & x"BE5466CF34E90C6C" & x"452821E638D01377" &
						x"082EFA98EC4E6C89" & x"A4093822299F31D0" & x"13198A2E03707344" & x"243F6A8885A308D3" );
						 
	 
						
	type g_rot_type is array (0 to 3) of integer;
	constant g_rot_arch32 : g_rot_type := (16, 12, 8, 7);
	constant g_rot_arch64 : g_rot_type := (32, 25, 16, 11);
						 
	type permute_type is array (0 to 9, 0 to 15) of integer;

	constant permute_array    : permute_type :=  ((0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
	                                             (14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3),
	                                             (11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4),
	                                             (7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8),
	                                             (9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13),
	                                             (2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9),
	                                             (12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11),
	                                             (13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10),
	                                             (6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5),
	                                             (10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0));		
												 
	function get_b ( h : integer ) return integer;
	function get_iw ( h : integer ) return integer;	 
	function get_iv ( h : integer; iw : integer) return std_logic_vector; 
	function get_cons ( h : integer; b : integer ; iw : integer) return std_logic_vector; 
	function get_roundnr ( h : integer ) return integer;   
end sha3_blake_package;							  
	



package body sha3_blake_package is						 
	function get_b ( h : integer ) return integer is
	begin
		if ( h <= 256 ) then
			return ( 512 );
		else 
			return ( 1024 );
		end if;
	end function get_b;
	
	function get_iw ( h : integer ) return integer is
	begin
		if ( h <= 256 ) then
			return ( 32 );
		else 
			return ( 64 );
		end if;
	end function get_iw;	  			 
	
	function get_iv ( h : integer; iw : integer) return std_logic_vector is 
	begin
		if ( h = 224 ) then
			return ( switch_endian_word(iv_224,256,iw) );
		elsif ( h = 256 ) then
			return (switch_endian_word( iv_256,256,iw) );
		elsif ( h = 384 ) then
			return (switch_endian_word( iv_384,384,iw) );
		elsif ( h = 512 ) then
			return (switch_endian_word( iv_512,512,iw) );	 
		else
			return "000";
		end if;
	end function get_iv;	
	
	function get_cons ( h : integer; b : integer ; iw : integer) return std_logic_vector is
	begin
		if ( h <= 256 ) then
			return ( switch_endian_word(const32,b,iw) );
		else 
			return ( switch_endian_word(const64,b,iw) );
		end if;
	end function get_cons;	  			
	 
	function get_roundnr ( h : integer ) return integer is
	begin
		if ( h <= 256 ) then
			return ( 10 );
		else 
			return ( 14 );
		end if;
	end function get_roundnr;
		
end package body;