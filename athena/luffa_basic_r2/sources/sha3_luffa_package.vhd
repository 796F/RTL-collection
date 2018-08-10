-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;	 
use work.sha3_pkg.all;

package sha3_luffa_package is


	constant b 		: integer := 256;		-- DO NOT CHANGE THIS VALUE. This is the size of vector array and should remained fix at 256 for luffa.
	constant mw		: integer := 256;		-- message width	
	constant wd		: integer := 32;		-- datapath width (32 bits)
	
	-- Array size (the size of array trees), use 3 for 256 hash, 4 for 384 and 5 for 512.											 
	
	constant bseg			: integer := b/wd;
   
	constant bzeros : std_logic_vector(b-1 downto 0) := (others => '0');
	
	
	
	type vector_array is array (natural range <>) of STD_LOGIC_VECTOR(255 downto 0);
	type vector_constant_array is array (natural range <>) of STD_LOGIC_VECTOR(31 downto 0);
	
	type sigma_type is array (1 to 4) of integer range 0 to 31;
	constant sigma : sigma_type := (2, 14, 10, 1);
											
	-- Luffa's starting variables
	type starting_variables is array (0 to 4) of STD_LOGIC_VECTOR (255 downto 0);
	constant IV : starting_variables := 	((X"6D251E6944B051E04EAA6FB4DBF784656E29201190152DF4EE058139DEF610BB"),
											(X"C3B44B95D9D2F25670EEE9A0DE099FA35D9B05578FC944B3CF1CCF0E746CD581"),
											(X"F7EFC89D5DBA578104016CE5AD659C050306194F666D183624AA230A8B264AE7"),
											(X"858075D536D79CCEE571F7D7204B1F6735870C6A57E9E92314BCB8087CDE72CE"),
											(X"6C68E9BE5EC41E22C825B7C7AFFB4363F5DF39990FC688F1B07224CC03E86CEA"));
  
	-- Luffa's initial values from constant generator
	type initial_values is array (0 to 4, 0 to 7) of STD_LOGIC_VECTOR(31 downto 0);
	constant c0_constants : initial_values :=	((X"303994A6", X"C0E65299", X"6CC33A12", X"DC56983E", X"1E00108F", X"7800423D", X"8F5B7882", X"96E1DB12"),
									(X"B6DE10ED", X"70F47AAE", X"0707A3D4", X"1C1E8F51", X"707A3D45", X"AEB28562", X"BACA1589", X"40A46F3E"),
									(X"FC20D9D2", X"34552E25", X"7AD8818F", X"8438764A", X"BB6DE032", X"EDB780C8", X"D9847356", X"A2C78434"),
									(X"B213AFA5", X"C84EBE95", X"4E608A22", X"56D858FE", X"343B138F", X"D0EC4E3D", X"2CEB4882", X"B3AD2208"),
									(X"F0D2E9E3", X"AC11D7FA", X"1BCB66F2", X"6F2D9BC9", X"78602649", X"8EDAE952", X"3B6BA548", X"EDAE9520"));
	
	constant c4_constants : initial_values :=	((X"E0337818", X"441BA90D", X"7F34D442", X"9389217F", X"E5A8BCE6", X"5274BAF4", X"26889BA7", X"9A226E9D"),
									(X"01685F3D", X"05A17CF4", X"BD09CACA", X"F4272B28", X"144AE5CC", X"FAA7AE2B", X"2E48F1C1", X"B923C704"),
									(X"E25E72C1", X"E623BB72", X"5C58A4A4", X"1E38E2E7", X"78E38B9D", X"27586719", X"36EDA57F", X"703AACE7"),
									(X"E028C9BF", X"44756F91", X"7E8FCE32", X"956548BE", X"FE191BE2", X"3CB226E5", X"5944A28E", X"A1C4C355"),
									(X"5090D577", X"2D1925AB", X"B46496AC", X"D1925AB0", X"29131AB6", X"0FC053C3", X"3F014F0C", X"FC053C31"));
	
	-- Luffa's sbox for subscrumb function
	type sbox is array (0 to 15) of STD_LOGIC_VECTOR (3 downto 0);
	constant sbox_rom : sbox :=	(	("1101"),
									("1110"),
									("0000"),
									("0001"),
									("0101"),
									("1010"),
									("0111"),
									("0110"),
									("1011"),
									("0011"),
									("1001"),
									("1100"),
									("1111"),
									("1000"),
									("0010"),
									("0100"));
										 
	-- declare functions and procedure	
	type std_logic_matrix is array (bseg-1 downto 0) of std_logic_vector(wd - 1 downto 0) ;
	function wordmatrix2blk_inv  	(signal x : in std_logic_matrix) return std_logic_vector;
	function blk2wordmatrix_inv  	(signal x : in std_logic_vector(b-1 downto 0) ) return std_logic_matrix;  
	
	function get_arraysize ( h : integer ) return integer ;
end sha3_luffa_package;

package body sha3_luffa_package is
	function wordmatrix2blk_inv  (signal x : in std_logic_matrix) return std_logic_vector is
		variable retval : std_logic_vector(b-1 downto 0);
	begin
		for i in 0 to bseg-1 loop
			retval(wd*(i+1) - 1 downto wd*i) := x(bseg-1-i);
		end loop;
		return retval; 
	end wordmatrix2blk_inv;


	function blk2wordmatrix_inv  (signal x : in std_logic_vector(b-1 downto 0) ) return std_logic_matrix is
		variable retval : std_logic_matrix;
	begin
		for i in 0 to bseg-1 loop
			retval(bseg-1-i) := x(wd*(i+1) - 1 downto wd*i);
		end loop;
		return retval;
	end blk2wordmatrix_inv;	
	
	function get_arraysize ( h : integer ) return integer is
	begin
		if ( h = 256 ) then
			return ( 3 );
		elsif ( h = 384 ) then
			return ( 4 );
		else
			return ( 5 );
		end if;
	end get_arraysize;
end package body sha3_luffa_package;