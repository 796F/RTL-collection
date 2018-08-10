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

package sha3_simd_package is
	constant iw		: integer := 32;		-- DO NOT CHANGE VALUE: internal width is always 34 bits
	constant iwzeros		: std_logic_vector(iw-1 downto 0) := (others => '0');
	
	type step_permute_type is array(0 to 2, 0 to 3) of integer;
	constant step_permute256 : step_permute_type :=  ( (1,0,3,2), (2,3,0,1),
													(3,2,1,0));
	type step_permute_type512 is array(0 to 6, 0 to 7) of integer;
	constant step_permute512 : step_permute_type512 :=  ( (1,0,3,2,5,4,7,6), (6,7,4,5,2,3,0,1),
													(2,3,0,1,6,7,4,5), (3,2,1,0,7,6,5,4),
													(5,4,7,6,1,0,3,2), (7,6,5,4,3,2,1,0),
													(4,5,6,7,0,1,2,3) );
	
	type array_4x5 is array(0 to 3) of std_logic_vector(4 downto 0);	
	type array_4x4x5 is array(0 to 3) of array_4x5;	
	constant pi_cons : array_4x4x5 := (	(	"00011", "10111", "10001", "11011"),
										(	"11100", "10011", "10110", "00111"),
										(	"11101", "01001", "01111", "00101"),
										(	"00100", "01101", "01010", "11001"));						
	
	constant hinit256 : std_logic_vector(511 downto 0) := (	x"4d567983" & x"07190ba9" & x"8474577b" & x"39d726e9" &
															x"aaf3d925" & x"3ee20b03" & x"afd5e751" & x"c96006d3" &
															x"c2c2ba14" & x"49b3bcb4" & x"f67caf46" & x"668626c9" &
															x"e2eaa8d2" & x"1ff47833" & x"d0c661a5" & x"55693de1" );  			  
	constant hinit224 : std_logic_vector(511 downto 0) := ( x"33586e9f" & x"12fff033" & x"b2d9f64d" & x"6f8fea53" &
															x"de943106" & x"2742e439" & x"4fbab5ac" & x"62b9ff96" &
															x"22e7b0af" & x"c862b3a8" & x"33e00cdc" & x"236b86a6" &
															x"f64ae77c" & x"fa373b76" & x"7dc1ee5b" & x"7fb29ce8" );															
	constant hinit384 : std_logic_vector(1023 downto 0) := (	x"8a36eebc" & x"94a3bd90" & x"d1537b83" & x"b25b070b" &
															x"f463f1b5" & x"b6f81e20" & x"0055c339" & x"b4d144d1" &
															x"7360ca61" & x"18361a03" & x"17dcb4b9" & x"3414c45a" &
															x"a699a9d2" & x"e39e9664" & x"468bfe77" & x"51d062f8" &
															x"b9e3bfe8" & x"63bece2a" & x"8fe506b9" & x"f8cc4ac2" &
															x"7ae11542" & x"b1aadda1" & x"64b06794" & x"28d2f462" &
															x"e64071ec" & x"1deb91a8" & x"8ac8db23" & x"3f782ab5" &
															x"039b5cb8" & x"71ddd962" & x"fade2cea" & x"1416df71" );	  
	constant hinit512 : std_logic_vector(1023 downto 0) := ( x"0ba16b95" & x"72f999ad" & x"9fecc2ae" & x"ba3264fc" &
															x"5e894929" & x"8e9f30e5" & x"2f1daa37" & x"f0f2c558" &
															x"ac506643" & x"a90635a5" & x"e25b878b" & x"aab7878f" &
															x"88817f7a" & x"0a02892b" & x"559a7550" & x"598f657e" &
															x"7eef60a1" & x"6b70e3e8" & x"9c1714d1" & x"b958e2a8" &
															x"ab02675e" & x"ed1c014f" & x"cd8d65bb" & x"fdb7a257" &
															x"09254899" & x"d699c7bc" & x"9019b6dc" & x"2b9022e4" &
															x"8fa14956" & x"21bf9bd3" & x"b94d0943" & x"6ffddc22" );															
															
	-- segments


	function get_b ( h : integer ) return integer;
	function get_pts ( h : integer ) return integer;   
	function get_feistels ( h : integer ) return integer;	 
	function get_init ( h : integer ) return std_logic_vector;
end sha3_simd_package;

package body sha3_simd_package is
	function get_b ( h : integer ) return integer is
	begin
		if ( h = 256 or h = 224) then
			return ( 512 );
		else
			return ( 1024 ) ;
		end if;
	end get_b;	
	
	function get_pts ( h : integer ) return integer is
	begin
		if ( h = 256 or h = 224) then
			return ( 128 );
		else
			return ( 256 ) ;
		end if;
	end get_pts;	
	
	function get_feistels ( h : integer ) return integer is
	begin
		if ( h = 256 or h = 224) then
			return ( 4 );
		else
			return ( 8 ) ;
		end if;
	end get_feistels;	  
	
	function get_init ( h : integer ) return std_logic_vector is
	begin
		if ( h = 256 ) then
			return ( hinit256 );
		elsif ( h = 224) then
			return ( hinit224 );	
		elsif ( h = 384 ) then
			return ( hinit384 );
		else
			return ( hinit512 );
		end if;
	end get_init;
end package body sha3_simd_package;