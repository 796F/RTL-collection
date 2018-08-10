-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sha3_hamsi_512cons.all;
use work.sha3_hamsi_256cons.all;
use work.sha3_hamsi_package.all;
use work.sha3_pkg.all;

entity hamsi_me is	  
	generic ( 	b : integer := 512;
				w : integer := 32;
				iw : integer := 32;
			  	h : integer := 256 );
	port (
		min : in std_logic_vector(w-1 downto 0);
	    msg : out std_logic_vector(b/2-1 downto 0) );
end entity;


-- //////////////////////////////////

architecture rom of hamsi_me is					  
	type std_logic_half_matrix is array (natural range <>) of std_logic_vector(iw-1 downto 0) ;
	constant bhalfseg		: integer := (b/2)/iw;	
	signal msgout : std_logic_half_matrix(0 to bhalfseg-1);	  
	
	function wordmatrix2halfblk  (signal x : in std_logic_half_matrix) return std_logic_vector is
		variable retval : std_logic_vector(b/2-1 downto 0);
	begin	
		for i in 0 to bhalfseg-1 loop
			retval(iw*(i+1) - 1 downto iw*i) := x(bhalfseg-1-i);
		end loop;
		return retval;
	end wordmatrix2halfblk;
	
begin	 
	h256 : if ( h = 256 ) generate
		expansion: for i in 0 to 7 generate			 --accessing G value matrix
		msgout(i) <= (g256(0)( conv_integer(unsigned(min(31 downto 24))), i)) xor 
					  g256(1)( conv_integer(unsigned(min(23 downto 16))), i) xor 
					  g256(2)( conv_integer(unsigned(min(15 downto 8))), i) xor 
					  g256(3)( conv_integer(unsigned(min(7 downto 0))), i); 
		end generate expansion;	  
	end generate;				  
	h512 : if ( h = 512 ) generate
		expansion: for i in 0 to 15 generate			 --accessing G value matrix
		msgout(i) <= (	g512(0)( conv_integer(unsigned(min(63 downto 56))), i) xor 
					    g512(1)( conv_integer(unsigned(min(55 downto 48))), i) xor 
						g512(2)( conv_integer(unsigned(min(47 downto 40))), i) xor 
						g512(3)( conv_integer(unsigned(min(39 downto 32))), i) xor 
						g512(4)( conv_integer(unsigned(min(31 downto 24))), i) xor 
						g512(5)( conv_integer(unsigned(min(23 downto 16))), i) xor 
				   		g512(6)( conv_integer(unsigned(min(15 downto 8))), i) xor 
				   		g512(7)( conv_integer(unsigned(min(7 downto 0))), i)); 
		end generate expansion;	  
	end generate;	 
	
	msg <= wordmatrix2halfblk( msgout );
end rom;

-- //////////////////////////////////

architecture generator of hamsi_me is	  
	constant bhalfseg		: integer := (b/2)/iw;
	constant bquarterseg	: integer := (b/4)/iw;
	type std_logic_half_matrix is array (natural range <>) of std_logic_vector(iw-1 downto 0) ;
	
	function wordmatrix2halfblk  (signal x : in std_logic_half_matrix) return std_logic_vector is
		variable retval : std_logic_vector(b/2-1 downto 0);
	begin	
		for i in 0 to bhalfseg-1 loop
			retval(iw*(i+1) - 1 downto iw*i) := x(bhalfseg-1-i);
		end loop;
		return retval;
	end wordmatrix2halfblk;
	
	type msgarray_type is array (0 to (b/iw)-1) of std_logic_vector(1 downto 0);
	signal msgarray : msgarray_type;
	
	type gf4_in_type is array (0 to b/iw-1, 0 to b/4-1) of std_logic_vector(3 downto 0);
	signal gf4_in : gf4_in_type;
	
	type gf4_out_type is array (0 to b/iw-1, 0 to b/4-1) of std_logic_vector(1 downto 0);
	signal gf4_out : gf4_out_type;
	
	type gf4_result_type is array ( 0 to b/iw-1, 0 to b/4-1 ) of std_logic_vector(1 downto 0);
	signal gf4_result : gf4_result_type;
	
	signal msgout : std_logic_half_matrix(0 to bhalfseg-1);	  
	signal m : std_logic_half_matrix(0 to bhalfseg-1);	
begin
	--convert message in into an array for easy processing
	msgarray_gen : for i in 0 to b/iw-1 generate
		msgarray((b/iw)-1-i) <= min(2*i + 1 downto 2*i);
	end generate;
	
	--multiplication between msg and generator matrix this is achieve by using sbox
	mult_gen1 : for j in 0 to b/4-1 generate			-- 0 to 128 for 256, and 224 bits digest size (blocksize = 512)
		mult_gen2 : for i in 0 to b/iw-1 generate		-- 0 to  16 for 256, and 224 bits digest size (blocksize = 512)	
			h256 : if ( h = 256 ) generate 
				gf4_in(i,j) <= msgarray(i) & generator256(i,j);
			end generate;
			h512 : if ( h = 512 ) generate
				gf4_in(i,j) <= msgarray(i) & conv_std_logic_vector(generator512(i,j),2);
			end generate;
			gf4_out(i,j) <= gf4_rom( conv_integer(unsigned(gf4_in(i,j))) );
		end generate;		
	end generate;

	-- xor the columns of result together to form M with the size of 1x(b/4), for 256 and 224 bits digest size M will have the size of 1x128
	mult_xor_gen1 : for j in 0 to b/4-1 generate
		gf4_result(0,j) <= gf4_out(0,j);
		mult_xor_gen2: for i in 1 to b/iw-1 generate
			gf4_result(i,j) <= gf4_result(i-1,j) xor gf4_out(i,j);
		end generate;
	end generate;
	
	-- form M		
	m_matrix_gen : for i in 0 to bhalfseg-1 generate
			m(i) <= gf4_result(b/iw-1,i*16) & gf4_result(b/iw-1,i*16+1) & gf4_result(b/iw-1,i*16+2) & gf4_result(b/iw-1,i*16+3) & 
					gf4_result(b/iw-1,i*16+4) & gf4_result(b/iw-1,i*16+5) & gf4_result(b/iw-1,i*16+6) & gf4_result(b/iw-1,i*16+7) & 
					gf4_result(b/iw-1,i*16+8) & gf4_result(b/iw-1,i*16+9) & gf4_result(b/iw-1,i*16+10) & gf4_result(b/iw-1,i*16+11) & 
					gf4_result(b/iw-1,i*16+12) & gf4_result(b/iw-1,i*16+13) & gf4_result(b/iw-1,i*16+14) & gf4_result(b/iw-1,i*16+15);
	end generate;
	
	-- get m from permute ( M ) ::: Refer to old specification of Hamsi (New specification is missing this step)
	output_gen1 : for i in 0 to bquarterseg-1 generate
		output_gen2 : for j in 0 to 16-1  generate
			msgout(i)(j) <= m(i)(2*j);
			msgout(i)(j+16) <= m(i+bquarterseg)(2*j);						
			msgout(i+bquarterseg)(j) <= m(i)(2*j+1);
			msgout(i+bquarterseg)(j+16) <= m(i+bquarterseg)(2*j+1);
		end generate;
	end generate;		  
	
	msg <= wordmatrix2halfblk( msgout );
end generator;