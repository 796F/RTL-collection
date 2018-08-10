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

package sha3_hamsi_package is
	constant generator : integer := 1;
	constant rom : integer := 2;

	
	type array256 is array (0 to 7) of std_logic_vector(31 downto 0);
	type array512 is array (0 to 15) of std_logic_vector(31 downto 0);
	
	CONSTANT iv256 : std_logic_vector(255 downto 0) := (x"76657273" & x"69746569" & x"74204C65" & x"7576656E" & x"2C204465" & X"70617274" & x"656D656E" & x"7420456C" );	 --20556E69
	constant iv512 : std_logic_vector(511 downto 0) := 	(	x"73746565" & x"6c706172" & x"6b204172" & x"656e6265" &
															x"72672031" & x"302c2062" & x"75732032" & x"3434362c" &
															x"20422d33" & x"30303120" & x"4c657576" & x"656e2d48" &
															x"65766572" & x"6c65652c" & x"2042656c" & x"6769756d" );
	
	type sbox is array (0 to 15) of std_logic_vector (3 downto 0);
	constant sbox_rom : sbox :=	( 	x"8", x"6", x"7", x"9",
									x"3", x"C", x"A", x"F",
									x"D", x"1", x"E", x"4",
									x"0", x"B", x"5", x"2");	 
	type gf4 is array (0 to 15) of std_logic_vector(1 downto 0);									
	constant gf4_rom : gf4 := ( 	"00", "00", "00", "00",
									"00", "01", "10", "11",
									"00", "10", "11", "01",
									"00", "11", "01", "10");									
									
	TYPE alpha_values IS ARRAY (0 to 1, 0 to 31) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- constans used in P
	CONSTANT alpha_cons : alpha_values :=(
		(	X"FF00F0F0", X"CCCCAAAA", X"F0F0CCCC", X"FF00AAAA", 
			X"CCCCAAAA", X"F0F0FF00", X"AAAACCCC", X"F0F0FF00", 
			X"F0F0CCCC", X"AAAAFF00", X"CCCCFF00", X"AAAAF0F0",
			X"AAAAF0F0", X"FF00CCCC", X"CCCCF0F0", X"FF00AAAA",
			X"CCCCAAAA", X"FF00F0F0", X"FF00AAAA", X"F0F0CCCC", 
			X"F0F0FF00", X"CCCCAAAA", X"F0F0FF00", X"AAAACCCC", 
			X"AAAAFF00", X"F0F0CCCC", X"AAAAF0F0", X"CCCCFF00",
			X"FF00CCCC", X"AAAAF0F0", X"FF00AAAA", X"CCCCF0F0"),
		(	X"CAF9639C", X"0FF0F9C0", X"639C0FF0", X"CAF9F9C0", 
			X"0FF0F9C0", X"639CCAF9", X"F9C00FF0", X"639CCAF9",
			X"639C0FF0", X"F9C0CAF9", X"0FF0CAF9", X"F9C0639C",
			X"F9C0639C", X"CAF90FF0", X"0FF0639C", X"CAF9F9C0",
			X"0FF0F9C0", X"CAF9639C", X"CAF9F9C0", X"639C0FF0",
			X"639CCAF9", X"0FF0F9C0", X"639CCAF9", X"F9C00FF0", 
			X"F9C0CAF9", X"639C0FF0", X"F9C0639C", X"0FF0CAF9",
			X"CAF90FF0", X"F9C0639C", X"CAF9F9C0", X"0FF0639C")
	);				

	
	
	
	function get_b ( h : integer ) return integer;
	function get_iv ( h : integer ) return std_logic_vector;
	function get_round ( h : integer ) return integer;
	function get_round_final ( h : integer ) return integer;
end sha3_hamsi_package;


package body sha3_hamsi_package is	 	
	function get_b ( h : integer ) return integer is
	begin
		if ( h = 256 ) then
			return ( 512 );
		else 
			return ( 1024 );
		end if;
	end get_b;	 
	
	function get_iv ( h : integer ) return std_logic_vector is
	begin
		if ( h = 256 ) then
			return ( iv256 );
		else 
			return ( iv512 );
		end if;
	end get_iv;	 		
	
	function get_round ( h : integer ) return integer is
	begin
		if ( h = 256 ) then
			return ( 3 );
		else 
			return ( 6 );
		end if;
	end get_round;
	
	function get_round_final ( h : integer ) return integer is
	begin
		if ( h = 256 ) then
			return ( 6 );
		else 
			return ( 12 );
		end if;
	end get_round_final;
end sha3_hamsi_package;
