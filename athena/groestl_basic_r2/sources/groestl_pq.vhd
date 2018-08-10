-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;   
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.groestl_pkg.all;

-- possible generics values: hs = {GROESTL_DATA_SIZE_SMALL, GROESTL_DATA_SIZE_BIG}
-- rom_style = {DISTRIBUTED, COMBINATIONAL}
-- all combinations are allowed 

entity groestl_pq is
generic (n:integer := GROESTL_DATA_SIZE_SMALL; rom_style : integer := DISTRIBUTED);
port( 
	clk				: in std_logic;
	rst				: in std_logic;
	p_mode			: in std_logic;	
	round			: in std_logic_vector(7 downto 0);
	input 			: in std_logic_vector(n-1 downto 0);
   	output 			: out std_logic_vector(n-1 downto 0));
end groestl_pq;
  
-- quasi-pipelining implementation of PQ function  
architecture pipelined of groestl_pq is

signal	after_subbyte		: std_logic_vector(n-1 downto 0);
signal	addcons			: std_logic_vector(n-1 downto 0);
signal	after_reg		: std_logic_vector(n-1 downto 0);
signal	after_shiftrow		: std_logic_vector(n-1 downto 0);
constant zero			: std_logic_vector(n-1 downto 0):=(others=>'0'); 

begin
	
gen256: if n=GROESTL_DATA_SIZE_SMALL generate
	addcons(511 downto 504) <= input(511 downto 504)  xor round when p_mode = '1' else input(511 downto 504);
	addcons(503 downto 456) <= input(503 downto 456);
	addcons(455 downto 448) <= input(455 downto 448) when p_mode = '1' else (not input(455 downto 448) xor round);
	addcons(447 downto 0) <= input(447 downto 0);
end generate;			  		  

gen512: if n=GROESTL_DATA_SIZE_BIG generate	   
	addcons(1023 downto 1016) <= input(1023 downto 1016)  xor round when p_mode = '1' else input(1023 downto 1016);
	addcons(1015 downto 968) <= input(1015 downto 968);
	addcons(967 downto 960) <= input(967 downto 960) when p_mode = '1' else (not input(967 downto 960) xor (round));
	addcons(959 downto 0) <= input(959 downto 0);
end generate;
	
	sbox_gen: for i in 0 to n/AES_SBOX_SIZE - 1  generate
	sbox	: aes_sbox 	generic map (rom_style=>rom_style)
			port map (	 
				input=>addcons(AES_SBOX_SIZE*i + 7 downto AES_SBOX_SIZE*i), 
				output=>after_subbyte(AES_SBOX_SIZE*i+7 downto AES_SBOX_SIZE*i));	
	end generate;	

	pl_reg		: regn generic map (n=>n, init=>zero) port map (clk=>clk, rst=>rst, en=>VCC, input=>after_subbyte, output=>after_reg);

	sr			:entity work.groestl_shiftrow(groestl_shiftrow)	generic map (n=>n)port map (input=>after_reg, output=>after_shiftrow);

mc256: if n=GROESTL_DATA_SIZE_SMALL generate	
	mc			: entity work.groestl_mixbytes(groestl_mixbytes)	
					port map (input=>after_shiftrow,  output=>output);	
end generate;

mc512: if n=GROESTL_DATA_SIZE_BIG generate	
	mc_left			: entity work.groestl_mixbytes(groestl_mixbytes) 
					port map (input=>after_shiftrow(1023 downto 512),  output=>output(1023 downto 512));	
	mc_right		: entity work.groestl_mixbytes(groestl_mixbytes) 
					port map (input=>after_shiftrow(511 downto 0),  output=>output(511 downto 0));	

end generate;

end pipelined; 			 	   

-- combinational implementiation of PQ function - there is no pipelining register 

architecture combinational of groestl_pq is

signal	after_subbyte		: std_logic_vector(n-1 downto 0);
signal	addcons			: std_logic_vector(n-1 downto 0);
signal	after_reg		: std_logic_vector(n-1 downto 0);
signal	after_shiftrow		: std_logic_vector(n-1 downto 0);
constant zero			: std_logic_vector(n-1 downto 0):=(others=>'0'); 

begin
	
	
gen256: if n=GROESTL_DATA_SIZE_SMALL generate	
	addcons(511 downto 504) <= input(511 downto 504)  xor round when p_mode = '1' else input(511 downto 504);
	addcons(503 downto 456) <= input(503 downto 456);
	addcons(455 downto 448) <= input(455 downto 448) when p_mode = '1' else (not input(455 downto 448) xor round);
	addcons(447 downto 0) <= input(447 downto 0);
end generate;			  		  


gen512: if n=GROESTL_DATA_SIZE_BIG generate	   
	addcons(1023 downto 1016) <= input(1023 downto 1016)  xor round when p_mode = '1' else input(1023 downto 1016);
	addcons(1015 downto 968) <= input(1015 downto 968);
	addcons(967 downto 960) <= input(967 downto 960) when p_mode = '1' else (not input(967 downto 960) xor (round));
	addcons(959 downto 0) <= input(959 downto 0);
end generate;
	
	
	sbox_gen: for i in 0 to n/AES_SBOX_SIZE - 1  generate
	sbox	: aes_sbox 	generic map (rom_style=>rom_style)
			port map (	 
				input=>addcons(AES_SBOX_SIZE*i + 7 downto AES_SBOX_SIZE*i), 
				output=>after_subbyte(AES_SBOX_SIZE*i+7 downto AES_SBOX_SIZE*i));	
	end generate;	

		sr	: entity work.groestl_shiftrow(groestl_shiftrow)	
				generic map (n=>n)
				port map (input=>after_subbyte, output=>after_shiftrow);

mc256: if n=GROESTL_DATA_SIZE_SMALL generate	
	mc			: entity work.groestl_mixbytes(groestl_mixbytes)	
				port map (input=>after_shiftrow,  output=>output);	
end generate;

mc512: if n=GROESTL_DATA_SIZE_BIG generate	
	mc_left			: entity work.groestl_mixbytes(groestl_mixbytes)	
						port map (input=>after_shiftrow(1023 downto 512),  output=>output(1023 downto 512));	
	mc_right		: entity work.groestl_mixbytes(groestl_mixbytes)
						port map (input=>after_shiftrow(511 downto 0),  output=>output(511 downto 0));	

end generate;

	
end combinational; 