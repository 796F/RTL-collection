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
use work.echo_pkg.all;

-- possible generics values:  
-- aes_round_style = {AES_ROUND_BASIC, AES_ROUND_TBOX} and 
-- rom_style = {DISTRIBUTED, COMBINATIONAL}	
-- all combinations allowed, but with TBOX implementation rom_style generic is not used

entity echo_big_subword is
generic ( rom_style: integer:=DISTRIBUTED; aes_round_style:integer:=AES_ROUND_BASIC);	 
port(
	clk			:in std_logic; 
	sel			:in std_logic; 
	input		:in std_logic_vector(ECHO_STATE_SIZE-1 downto 0);
	key_one		:in std_logic_vector(ECHO_QWORD_SIZE/2-1 downto 0);
	key_two		:in std_logic_vector(ECHO_QWORD_SIZE-1 downto 0);
	output		:out std_logic_vector(ECHO_STATE_SIZE-1 downto 0));

end echo_big_subword;

architecture echo_big_subword of echo_big_subword is
type keys is array (0 to ECHO_STATE_SIZE/(ECHO_QWORD_SIZE)-1) of std_logic_vector(ECHO_QWORD_SIZE/2-1 downto 0); 
type big_keys is array (0 to ECHO_STATE_SIZE/(ECHO_QWORD_SIZE)-1) of std_logic_vector(ECHO_QWORD_SIZE-1 downto 0); 

signal rd_keya, iter_key, dbg	:keys;	
signal to_round : big_keys;
constant zero : std_logic_vector(127 downto 0):=(others=>'0'); 

begin	 	
  
level1: for i in 0 to ECHO_STATE_SIZE/(ECHO_QWORD_SIZE)-1 generate 
	
	-- calculation of subkeys 
	iter_key(i) <=  (key_one + (ECHO_STATE_SIZE/ECHO_QWORD_SIZE-i-1));	
	rd_keya(i) <= switch_endian_word(x=>iter_key(i), width=>ECHO_QWORD_SIZE/2, w=>8);	
	to_round(i) <= key_two   when sel='1' else dbg(i) & zero(63 downto 0); 
	
	-- subkeys registers 
	ctr_reg  : regn generic map(N=>64, init=>zero(63 downto 0)) port map (clk => clk, rst => '0', en => '1', input => rd_keya(i), output => dbg(i) );

	-- AES round implementation 
basic_gen: if aes_round_style=AES_ROUND_BASIC generate	
	aes_rd1		: entity work.aes_round(basic) 
		generic map (rom_style=>rom_style) 
		port map (key=>to_round(i)(ECHO_QWORD_SIZE-1 downto 0), input=>input(((i+1)*ECHO_QWORD_SIZE -1) downto (i*ECHO_QWORD_SIZE)), output=>output(((i+1)*ECHO_QWORD_SIZE-1) downto (i*ECHO_QWORD_SIZE)));	
end generate;	

tbox_gen: if aes_round_style=AES_ROUND_TBOX generate	
	aes_rd1		: entity work.aes_round(tbox) 
		generic map (rom_style=>rom_style) 
		port map (key=>to_round(i)(ECHO_QWORD_SIZE-1 downto 0), input=>input(((i+1)*ECHO_QWORD_SIZE -1) downto (i*ECHO_QWORD_SIZE)), output=>output(((i+1)*ECHO_QWORD_SIZE-1) downto (i*ECHO_QWORD_SIZE)));	
end generate;
		
end generate;

end echo_big_subword;