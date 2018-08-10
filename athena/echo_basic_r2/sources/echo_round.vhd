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

entity echo_round is
generic ( rom_style:integer:=DISTRIBUTED; aes_round_style:integer:=AES_ROUND_BASIC);	 
port(
	clk				:in std_logic;
	sel				:in std_logic_vector(1 downto 0);
	input			:in std_logic_vector(ECHO_STATE_SIZE-1 downto 0);
	key				:in std_logic_vector(ECHO_QWORD_SIZE/2-1 downto 0);
	salt			:in std_logic_vector(ECHO_QWORD_SIZE-1 downto 0);
	to_big_final	:out std_logic_vector(ECHO_STATE_SIZE-1 downto 0);
	output			:out std_logic_vector(ECHO_STATE_SIZE-1 downto 0));
end echo_round;

architecture echo_round of echo_round is
signal bsw_output	:std_logic_vector(ECHO_STATE_SIZE-1 downto 0);
signal bmc_output, after_bsr	:std_logic_vector(ECHO_STATE_SIZE-1 downto 0);

begin	 	

		-- 2/3 verticaly folded ECHO round
bsw	:	entity work.echo_big_subword(echo_big_subword) 	
		generic map (rom_style=>rom_style, aes_round_style=>aes_round_style )
		port map (clk=>clk, sel=> sel(0), input=>input, key_one=>key, key_two=>salt, output=>bsw_output);

bsr	:	entity work.aes_shiftrow(aes_shiftrow) 	
		generic map (n=>ECHO_STATE_SIZE, s=>ECHO_QWORD_SIZE ) 
		port map (input=>input, output=>after_bsr);
bmc	:	entity work.echo_big_mixcolumn(echo_big_mixcolumn)	
		port map (input=>after_bsr, output=>bmc_output); 

output <= bmc_output when sel(1)='1'else bsw_output;
to_big_final <= bmc_output;
	
end echo_round;