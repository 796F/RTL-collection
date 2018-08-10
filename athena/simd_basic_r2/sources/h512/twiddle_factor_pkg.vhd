-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;  
use ieee.std_logic_unsigned.all;

package twiddle_factor_pkg is
	type ntt_in_type is array (natural range <> ) of std_logic_vector(7 downto 0);
	type ntt_out_type is array (natural range <> ) of std_logic_vector(8 downto 0);
		
	-- ntt
	type ptsx10 is array (natural range <>) OF std_logic_vector(9 downto 0);
	type halfptsx8 is array (natural range <>) OF std_logic_vector(7 downto 0);	
	
	-- concat permute
	type array_4x32 is array (0 to 3) OF std_logic_vector(31 downto 0);		
	--type array_w_base is array(natural range <>) of std_logic_vector(31 downto 0);
	type array_w is array (natural range <>, natural range <>) of std_logic_vector(31 downto 0);
	
	type permute_rom_type is array (0 to 31) of integer;
	constant permute_rom : permute_rom_type :=
	(4,  6,  0,  2,  7,  5,  3,  1,
	 15, 11, 12, 8,  9,  13, 10, 14,
	 17, 18, 23, 20, 22, 21, 16, 19,
	 30, 24, 25, 31, 27, 29, 28, 26);
	   
	function af_gen( h: integer; final : integer; pts : integer) return ptsx10;
	function twiddle_gen(point : integer; pts : integer) return halfptsx8; 
	function zero_nttout_gen (pts : integer ) return ntt_out_type;
	function twiddle_factor_gen( pts : integer ) return halfptsx8;
	function reverse_bits (a: std_logic_vector; size : integer) return std_logic_vector;	
	
	component mod257 is
	    port ( i : in  STD_LOGIC_VECTOR (16 downto 0);
	           o : out  STD_LOGIC_VECTOR (8 downto 0));
	end component;		
end twiddle_factor_pkg;			

package body twiddle_factor_pkg is
	function reverse_bits (a: std_logic_vector; size : integer) return std_logic_vector is
		variable result: std_logic_vector(size-1 downto 0);
	begin
		for i in 0 to size-1 loop
			result(size-1-i) := a(i);
		end loop;
		return result;
	end reverse_bits; 


	function af_gen ( h : integer; final : integer; pts : integer ) return ptsx10 is
		variable y : ptsx10(0 to pts-1);		
		variable beta_i : std_logic_vector(17 downto 0);
		variable beta : std_logic_vector(7 downto 0);
	begin												  
		if ( h = 256 ) then
			beta := conv_std_logic_vector(98,8);
		else
			beta := conv_std_logic_vector(163,8);
		end if;
		
		y(0) := conv_std_logic_vector(1,10);
		
		for i in 1 to pts-1 loop
			beta_i := y(i-1) * beta;						
			beta_i := conv_std_logic_vector((conv_integer(beta_i) mod 257),18);
			
			y(i) := beta_i(9 downto 0);
			
		end loop;
		
		if ( final = 1 ) then
			if ( h = 256 ) then
				beta := conv_std_logic_vector(58,8);
			else
				beta := conv_std_logic_vector(40,8);
			end if;
		
			beta_i := "000000000000000001";
			for i in 0 to pts-1 loop
				y(i) := y(i) + beta_i(9 downto 0);						 
				beta_i := beta_i(9 downto 0) * beta;
				beta_i := conv_std_logic_vector((conv_integer(beta_i) mod 257),18);
			end loop;			
		end if;
		
		return y;
	end af_gen;										   
	
	
	function zero_nttout_gen ( pts : integer ) return ntt_out_type is
		variable y : ntt_out_type( 0 to pts-1 );
	begin
		for i in 0 to pts-1 loop
			y(i) := (others => '0');
		end loop;			  
		return y;
	end zero_nttout_gen;
	
	-- generate twiddle factor for each stage from twiddle_factor_gen function (technically, this is just a rearranging function to insert the correct twiddle factor into the rearranged butterfly)
	function twiddle_gen(point : integer; pts : integer) return halfptsx8 is
		variable twiddle_factor : halfptsx8( 0 to pts/2 -1 ) := twiddle_factor_gen( pts );
		variable y : halfptsx8( 0 to pts/2 -1 );			 
		variable step : integer := (pts/point);
		variable cur_step : integer := 0;
	begin							
		if ( step = pts/2 ) then
			step := 0;
		end if;
		for i in 0 to pts/2-1 loop
			y(i) := twiddle_factor(cur_step);
			cur_step := cur_step + step;
			if (cur_step >= pts/2) then
				cur_step := cur_step - pts/2;
			end if;
		end loop;
		
		return y;
	end twiddle_gen;			  
	
	function twiddle_factor_gen( pts : integer ) return halfptsx8 is
		variable a : integer ;
		variable ret : halfptsx8( 0 to pts/2 -1 );	
		variable temp : integer ;
	begin
		if ( pts = 128 ) then
			a := 139;
		else 
			a := 41;
		end if;
		ret(0) := x"01";
		
		for i in 1 to pts/2-1 loop				 
			temp := (conv_integer(ret(i-1))*a) mod 257;
			ret(i) := conv_std_logic_vector( temp , 8 );
		end loop;
		return ( ret );		
	end twiddle_factor_gen;
end package body;


	