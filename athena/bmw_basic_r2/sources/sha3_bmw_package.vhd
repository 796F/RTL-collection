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

package sha3_bmw_package is	
	constant expand_1_rounds : integer := 2;
	
	constant const_final_32 : std_logic_vector(511 downto 0) := 
							( x"aaaaaaa0" & x"aaaaaaa1" & x"aaaaaaa2" & x"aaaaaaa3" &
							  x"aaaaaaa4" & x"aaaaaaa5" & x"aaaaaaa6" & x"aaaaaaa7" &
							  x"aaaaaaa8" & x"aaaaaaa9" & x"aaaaaaaa" & x"aaaaaaab" &
							  x"aaaaaaac" & x"aaaaaaad" & x"aaaaaaae" & x"aaaaaaaf" );
							  
	constant const_final_64 : std_logic_vector(1023 downto 0) := 
							( x"aaaaaaaaaaaaaaa0" & x"aaaaaaaaaaaaaaa1" & x"aaaaaaaaaaaaaaa2" & x"aaaaaaaaaaaaaaa3" &
							  x"aaaaaaaaaaaaaaa4" & x"aaaaaaaaaaaaaaa5" & x"aaaaaaaaaaaaaaa6" & x"aaaaaaaaaaaaaaa7" &
							  x"aaaaaaaaaaaaaaa8" & x"aaaaaaaaaaaaaaa9" & x"aaaaaaaaaaaaaaaa" & x"aaaaaaaaaaaaaaab" &
							  x"aaaaaaaaaaaaaaac" & x"aaaaaaaaaaaaaaad" & x"aaaaaaaaaaaaaaae" & x"aaaaaaaaaaaaaaaf" );							  
							
	constant h_init_224: std_logic_vector(511 downto 0) := 
							( x"00010203" & x"04050607" & x"08090a0b" & x"0c0d0e0f" &
							  x"10111213" & x"14151617" & x"18191a1b" & x"1c1d1e1f" &
							  x"20212223" & x"24252627" & x"28292a2b" & x"2c2d2e2f" &
							  x"30313233" & x"34353637" & x"38393a3b" & x"3c3d3e3f" );

	constant h_init_256: std_logic_vector(511 downto 0) := 
							( x"40414243" & x"44454647" & x"48494a4b" & x"4c4d4e4f" & 
							  x"50515253" & x"54555657" & x"58595a5b" & x"5c5d5e5f" & 
							  x"60616263" & x"64656667" & x"68696a6b" & x"6c6d6e6f" & 
							  x"70717273" & x"74757677" & x"78797a7b" & x"7c7d7e7f" );

	constant h_init_384: std_logic_vector(1023 downto 0) := 
							( x"0001020304050607" & x"08090a0b0c0d0e0f" & 
							  x"1011121314151617" & x"18191a1b1c1d1e1f" & 
							  x"2021222324252627" & x"28292a2b2c2d2e2f" & 
							  x"3031323334353637" & x"38393a3b3c3d3e3f" &
							  x"4041424344454647" & x"48494a4b4c4d4e4f" & 
							  x"5051525354555657" & x"58595a5b5c5d5e5f" & 
							  x"6061626364656667" & x"68696a6b6c6d6e6f" & 
							  x"7071727374757677" & x"78797a7b7c7d7e7f" );
							  
	constant h_init_512: std_logic_vector(1023 downto 0) := 
							( x"8081828384858687" & x"88898a8b8c8d8e8f" & 
							  x"9091929394959697" & x"98999a9b9c9d9e9f" & 
							  x"a0a1a2a3a4a5a6a7" & x"a8a9aaabacadaeaf" & 
							  x"b0b1b2b3b4b5b6b7" & x"b8b9babbbcbdbebf" &
							  x"c0c1c2c3c4c5c6c7" & x"c8c9cacbcccdcecf" & 
							  x"d0d1d2d3d4d5d6d7" & x"d8d9dadbdcdddedf" & 
							  x"e0e1e2e3e4e5e6e7" & x"e8e9eaebecedeeef" & 
							  x"f0f1f2f3f4f5f6f7" & x"f8f9fafbfcfdfeff" );

	function get_kj  (b : integer; iw : integer) return std_logic_vector;
	function get_b 	( h : integer ) return integer;
	function get_iw ( h : integer ) return integer;
	function get_hinit ( h : integer ) return std_logic_vector;
	function get_const ( h : integer ) return std_logic_vector;
	
	component bmw_adders is
	generic (adder_type:integer:=FCCA_BASED; n : integer := 32);
	port 
	(
		ina 	: in std_logic_vector(n-1 downto 0);				 
		inb 	: in std_logic_vector(n-1 downto 0);				 
		inc 	: in std_logic_vector(n-1 downto 0);				 
		ind 	: in std_logic_vector(n-1 downto 0);				 
		ine 	: in std_logic_vector(n-1 downto 0);				 
		inf 	: in std_logic_vector(n-1 downto 0);				 
		ing 	: in std_logic_vector(n-1 downto 0);				 
		inh 	: in std_logic_vector(n-1 downto 0);				 
		ini 	: in std_logic_vector(n-1 downto 0);				 
		inj 	: in std_logic_vector(n-1 downto 0);				 
		ink 	: in std_logic_vector(n-1 downto 0);				 
		inl 	: in std_logic_vector(n-1 downto 0);				 
		inm 	: in std_logic_vector(n-1 downto 0);				 
		inn 	: in std_logic_vector(n-1 downto 0);				 
		ino 	: in std_logic_vector(n-1 downto 0);				 
		inp 	: in std_logic_vector(n-1 downto 0);				 
		inq 	: in std_logic_vector(n-1 downto 0);				 
		output 	: out std_logic_vector(n-1 downto 0));
	end component;
	
	
end sha3_bmw_package;


package body sha3_bmw_package is
	function get_kj  (b : integer; iw : integer) return std_logic_vector is
		variable retval : std_logic_vector(b-1 downto 0);		
		variable init : std_logic_vector(iw-1 downto 0);
		variable kj : std_logic_vector(iw*2-1 downto 0); 
	begin
		if ( iw = 64 ) then
			init := x"0555555555555555";
		else
			init := x"05555555";
		end if;
		
		for i in 16 to 31 loop			
			kj := init*conv_std_logic_vector(i,iw);
			retval(b-1 - iw*(i mod 16) downto b-iw-iw*(i mod 16) ) := kj(iw-1 downto 0);
		end loop;
		return retval;
	end ;

	function get_b ( h : integer ) return integer is
	begin
		if ( h = 256 or h = 224 ) then
			return ( 512 );
		elsif ( h = 512 or h = 384 ) then
			return ( 1024 ) ;
		else
			return ( 0 );
		end if;
	end get_b;			   
	
	function get_iw ( h : integer ) return integer is
	begin
		if ( h = 256 or h = 224 ) then
			return ( 32 );
		elsif ( h = 512 or h = 384 ) then
			return ( 64 ) ;
		else
			return ( 0 );
		end if;
	end get_iw;
	
	function get_hinit ( h : integer ) return std_logic_vector is		
	begin
		if ( h = 224 ) then
			return ( h_init_224 );
		elsif ( h = 256 ) then
			return ( h_init_256 );
		elsif ( h = 384 ) then
			return ( h_init_384 );
		elsif ( h = 512 ) then 
			return ( h_init_512 );
		else -- error
			return ( "00" );
		end if;
	end get_hinit;
	
	function get_const ( h : integer ) return std_logic_vector is
	begin
		if ( h = 256 or h = 224 ) then
			return ( const_final_32 );
		elsif ( h = 512 or h = 384 ) then
			return ( const_final_64 ) ;
		else
			return ( "00" );
		end if;
	end get_const;
	
end sha3_bmw_package;
