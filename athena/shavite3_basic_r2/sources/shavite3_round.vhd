-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;
use work.shavite3_pkg.all;

-- possible generics values: 
-- aes_round_style = {AES_ROUND_BASIC, AES_ROUND_TBOX} and 
-- rom_style = {DISTRIBUTED, COMBINATIONAL}	
-- all combinations allowed, but with TBOX implementation rom_style generic is not used 

entity shavite3_round is
generic (rom_style:integer:=DISTRIBUTED; aes_round_style:integer:=AES_ROUND_BASIC);
port(
	clk				:in std_logic;	
	rst				:in std_logic;
	input			:in std_logic_vector(HASH_SIZE_256-1 downto 0);
	en				:in std_logic;
	sel_rd			:in std_logic_vector(1 downto 0);
	keyx			:in std_logic_vector(HASH_SIZE_256/2-1 downto 0);
	key				:in std_logic_vector(HASH_SIZE_256/2-1 downto 0);
	output			:out std_logic_vector(HASH_SIZE_256-1 downto 0));
end shavite3_round;

architecture shavite3_round of shavite3_round is
signal to_aes, from_aes, to_first_round, from_reg, after_xor : std_logic_vector(HASH_SIZE_256/2-1 downto 0);
constant last_key : std_logic_vector(HASH_SIZE_256/2-1 downto 0):=(others=>'0');	
signal	rdkey	: std_logic_vector(HASH_SIZE_256/2-1 downto 0); 
constant zero : std_logic_vector(HASH_SIZE_256/2-1 downto 0):=(others=>'0'); 
begin	 	
	-- keyx value xor with input to original SHAvite-3 round function
	to_first_round <= input(HASH_SIZE_256/2-1 downto 0) xor keyx;
	
	-- to aes round we are sending either - original input value or intermediate value from register
	to_aes <= to_first_round when sel_rd ="00" else from_reg;	
	
	-- last key is differenet - it is not comming from key generation 
	rdkey <= key when sel_rd(1)='0' else last_key;	
		
	-- implementation of AES round 	
basic_gen: if aes_round_style=AES_ROUND_BASIC generate 		
	ar1 : entity work.aes_round(basic) 
	generic map (rom_style=>rom_style)
	port map (input=>to_aes, output=>from_aes, key=>rdkey);
end generate;

tbox_gen: if aes_round_style=AES_ROUND_TBOX generate 		
	ar1 : entity work.aes_round(tbox) 
	generic map (rom_style=>rom_style)
	port map (input=>to_aes, output=>from_aes, key=>rdkey);
end generate;
		
	-- intermediate values storage register (we folded original round of SHAvite-3)	
	r : regn 
	generic map(N=>HASH_SIZE_256/2, init=>zero) 
	port map (clk=>clk, rst=>rst, en=>en, input=>from_aes, output=>from_reg);	
	
	after_xor <= from_aes xor input(HASH_SIZE_256-1 downto HASH_SIZE_256/2); 
	
	-- output from round 
	output <= input(HASH_SIZE_256/2-1 downto 0) & after_xor;
	
end shavite3_round;