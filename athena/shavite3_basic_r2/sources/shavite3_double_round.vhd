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

entity shavite3_double_round is
generic (HASH_SIZE_256 :integer:=256; rom_style:integer:=DISTRIBUTED; aes_round_style:integer:=AES_ROUND_BASIC);
port(
	clk				:in std_logic;	
	rst				:in std_logic;
	input			:in std_logic_vector(2*HASH_SIZE_256-1 downto 0);
	en				:in std_logic;
	sel_rd			:in std_logic_vector(1 downto 0);
	keyx_left		:in std_logic_vector(HASH_SIZE_256/2-1 downto 0);
	key_left		:in std_logic_vector(HASH_SIZE_256/2-1 downto 0); 
	keyx_right		:in std_logic_vector(HASH_SIZE_256/2-1 downto 0);
	key_right		:in std_logic_vector(HASH_SIZE_256/2-1 downto 0); 
	output			:out std_logic_vector(2*HASH_SIZE_256-1 downto 0));
end shavite3_double_round;

architecture shavite3_double_round of shavite3_double_round is
	signal to_aes_left, to_aes_right, from_aes_left, from_aes_right, to_first_round_left, to_first_round_right : std_logic_vector(HASH_SIZE_256/2-1 downto 0);
	signal  from_reg_left, from_reg_right, after_xor_left, after_xor_right : std_logic_vector(HASH_SIZE_256/2-1 downto 0);
	constant last_key : std_logic_vector(HASH_SIZE_256-1 downto 0):=(others=>'0');	
	signal	rdkey	: std_logic_vector(HASH_SIZE_256-1 downto 0); 
	constant zero : std_logic_vector(HASH_SIZE_256-1 downto 0):=(others=>'0'); 

begin	 	
	-- keyx_left value xor with input to original SHAvite-3 round function
	to_first_round_left <= input(3*HASH_SIZE_256/2-1 downto HASH_SIZE_256) xor keyx_left;
		
	-- to aes round left we are sending either - original input value or intermediate value from register
	to_aes_left <= to_first_round_left when sel_rd ="00" else from_reg_left;	

	-- last key is differenet - it is not comming from key generation 
	rdkey(HASH_SIZE_256-1 downto HASH_SIZE_256/2) <= last_key(HASH_SIZE_256-1 downto HASH_SIZE_256/2) when sel_rd="11" else key_left;	
	
	-- implementation of AES round	
basic_left_gen: if aes_round_style=AES_ROUND_BASIC generate		
	ar1 : entity work.aes_round(basic) 
	generic map (rom_style=>rom_style)
	port map (input=>to_aes_left, output=>from_aes_left, key=>rdkey(HASH_SIZE_256-1 downto HASH_SIZE_256/2));
end generate;

tbox_left_gen: if aes_round_style=AES_ROUND_TBOX generate		
	ar1 : entity work.aes_round(tbox) 
	generic map (rom_style=>rom_style)
	port map (input=>to_aes_left, output=>from_aes_left, key=>rdkey(HASH_SIZE_256-1 downto HASH_SIZE_256/2));
end generate;

	-- intermediate values storage register (we folded original round of SHAvite-3)	
	lr : regn 
	generic map(N=>HASH_SIZE_256/2, init=>zero(HASH_SIZE_256/2-1 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>en, input=>from_aes_left, output=>from_reg_left);
	
	after_xor_left <= from_aes_left xor input(2*HASH_SIZE_256-1 downto 3*HASH_SIZE_256/2); 

	-- keyx_right value xor with input to original SHAvite-3 round function
	to_first_round_right <= input(HASH_SIZE_256/2-1 downto 0) xor keyx_right;
		
	-- to aes round right we are sending either - original input value or intermediate value from register
	to_aes_right <= to_first_round_right when sel_rd ="00" else from_reg_right;	

	-- last key is differenet - it is not comming from key generation 
	rdkey(HASH_SIZE_256/2-1 downto 0) <= last_key(HASH_SIZE_256/2-1 downto 0) when sel_rd="11" else key_right;	
	
	-- implementation of AES round		
basic_right_gen: if aes_round_style=AES_ROUND_BASIC generate		
	ar2_basic : entity work.aes_round(basic) 
	generic map (rom_style=>rom_style)
	port map (input=>to_aes_right, output=>from_aes_right, key=>rdkey(HASH_SIZE_256/2-1 downto 0));
end generate;	

tbox_right_gen: if aes_round_style=AES_ROUND_TBOX generate		
	ar2_tbox : entity work.aes_round(tbox) 
	generic map (rom_style=>rom_style)
	port map (input=>to_aes_right, output=>from_aes_right, key=>rdkey(HASH_SIZE_256/2-1 downto 0));
end generate;

	-- intermediate values storage register (we folded original round of SHAvite-3)	
	rr : regn 
	generic map(N=>HASH_SIZE_256/2, init=>zero(HASH_SIZE_256/2-1 downto 0))
	port map (clk=>clk, rst=>rst, en=>en, input=>from_aes_right, output=>from_reg_right);
	
	after_xor_right <= from_aes_right xor input(HASH_SIZE_256-1 downto HASH_SIZE_256/2); 
	
	-- output from the round 	
	output(2*HASH_SIZE_256-1 downto 3*HASH_SIZE_256/2) <= input(3*HASH_SIZE_256/2-1 downto HASH_SIZE_256);
	output(3*HASH_SIZE_256/2-1 downto HASH_SIZE_256) <= after_xor_right;
	output(HASH_SIZE_256-1 downto HASH_SIZE_256/2) <= input(HASH_SIZE_256/2-1 downto 0);
	output(HASH_SIZE_256/2-1 downto 0) <= after_xor_left;

end shavite3_double_round;