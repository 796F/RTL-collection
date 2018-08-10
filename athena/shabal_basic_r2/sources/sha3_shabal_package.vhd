-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_pkg.all;

package sha3_shabal_package is
	constant b : integer := 512;
	constant w : integer := 64;
	constant iw : integer := 32;
	constant mw : integer := 512;
	
	
	constant o1 : integer := 13;
	constant o2 : integer := 9;
	constant o3 : integer := 6;
	
	
	
	constant biseg			: integer := b/iw;		
	constant mwseg			: integer := mw/w;		
	constant log2mwseg 		: integer := log2( mwseg-1 );

	
	
	constant iwzeros 			: std_logic_vector(iw-1 downto 0) := (others => '0');
	constant log2mwsegzeros	: std_logic_vector(log2mwseg-1 downto 0) := (others => '0');
	
	type array_16x32 is array (0 to 15) of std_logic_vector(31 downto 0);
	type array_12x32 is array (0 to 11) of std_logic_vector(31 downto 0);
	
	
	
	constant a_iv_256 : array_12x32:=(	x"52f84552",x"e54b7999",x"2d8ee3ec",x"b9645191",
		                              	x"e0078b86",x"bb7c44c9",x"d2b5c1ca",x"b0d2eb8c",
									  	x"14ce5a45",x"22af50dc",x"effdbc6b",x"eb21b74a");									  
	constant a_iv_512: array_12x32:=(	x"20728DFD",x"46C0BD53",x"E782B699",x"55304632",
										x"71B4EF90",x"0EA9E82C",x"DBB930F1",x"FAD06B8B",
										x"BE0CAE40",x"8BD14410",x"76D2ADAC",x"28ACAB7F");
	constant a_iv_256_compact : array_16x32:= (	x"52f84552",x"e54b7999",x"2d8ee3ec",x"b9645191",
		                              	x"e0078b86",x"bb7c44c9",x"d2b5c1ca",x"b0d2eb8c",
									  	x"14ce5a45",x"22af50dc",x"effdbc6b",x"eb21b74a",
										x"00000000",x"00000000",x"00000000",x"00000000");
														
																						 
	constant a_iv_512_compact : array_16x32:=(	x"20728DFD",x"46C0BD53",x"E782B699",x"55304632",
										x"71B4EF90",x"0EA9E82C",x"DBB930F1",x"FAD06B8B",
										x"BE0CAE40",x"8BD14410",x"76D2ADAC",x"28ACAB7F",
										x"00000000",x"00000000",x"00000000",x"00000000");




	constant b_iv_256 : array_16x32:=(	x"b555c6ee",x"3e710596",x"a72a652f",x"9301515f",x"da28c1fa",x"696fd868",x"9cb6bf72",x"0afe4002",
										x"a6e03615",x"5138c1d4",x"be216306",x"b38b8890",x"3ea8b96b",x"3299ace4",x"30924dd4",x"55cb34a5");
	constant b_iv_512 : array_16x32:=(	x"C1099CB7",x"07B385F3",x"E7442C26",x"CC8AD640",x"EB6F56C7",x"1EA81AA9",x"73B9D314",x"1DE85D08",
										x"48910A5A",x"893B22DB",x"C5A0DF44",x"BBC4324E",x"72D2F240",x"75941D99",x"6D8BDE82",x"A1A7502B");
	
	constant c_iv_256 : array_16x32:=(	x"b405f031",x"c4233eba",x"b3733979",x"c0dd9d55",x"c51c28ae",x"a327b8e1",x"56c56167",x"ed614433",
	                                  	x"88b59d60",x"60e2ceba",x"758b4b8b",x"83e82a7f",x"bc968828",x"e6e00bf7",x"ba839e55",x"9b491c60");
	constant c_iv_512 : array_16x32:=(	x"D9BF68D1",x"58BAD750",x"56028CB2",x"8134F359",x"B5D469D8",x"941A8CC2",x"418B2A6E",x"04052780",
										x"7F07D787",x"5194358F",x"3C60D665",x"BE97D79A",x"950C3434",x"AED9A06D",x"2537DC8D",x"7CDB5969");

	function array2blk  	(signal x : in array_16x32) return std_logic_vector;
	function blk2array  	(signal x : in std_logic_vector(b-1 downto 0) ) return array_16x32;
	
	function get_a_iv ( h : integer ) return array_12x32;
	function get_a_iv_compact ( h : integer ) return array_16x32;
	function get_b_iv ( h : integer ) return array_16x32;
	function get_c_iv ( h : integer ) return array_16x32;
end package;

package body sha3_shabal_package is
	function array2blk  (signal x : in array_16x32) return std_logic_vector is
		variable retval : std_logic_vector(b-1 downto 0);
	begin
		for i in 0 to biseg-1 loop
			retval(iw*(i+1) - 1 downto iw*i) := x(biseg-1-i);
		end loop;
		return retval; 
	end array2blk;


	function blk2array  (signal x : in std_logic_vector(b-1 downto 0) ) return array_16x32 is
		variable retval : array_16x32;
	begin
		for i in 0 to biseg-1 loop
			retval(biseg-1-i) := x(iw*(i+1) - 1 downto iw*i);
		end loop;
		return retval;
	end blk2array;		
	
	function get_a_iv ( h : integer ) return array_12x32 is
	begin
		if ( h = 256 ) then
			return( a_iv_256 ) ;
		else
			return( a_iv_512 );
		end if;
	end get_a_iv;
	
	function get_a_iv_compact ( h : integer ) return array_16x32 is
	begin
		if ( h = 256 ) then
			return( a_iv_256_compact ) ;
		else
			return( a_iv_512_compact );
		end if;
	end get_a_iv_compact;
	
	function get_b_iv ( h : integer ) return array_16x32 is
	begin
		if ( h = 256 ) then
			return( b_iv_256 ) ;
		else
			return( b_iv_512 );
		end if;
	end get_b_iv;
	
	function get_c_iv ( h : integer ) return array_16x32 is
	begin
		if ( h = 256 ) then
			return( c_iv_256 ) ;
		else
			return( c_iv_512 );
		end if;
	end get_c_iv;
end sha3_shabal_package;