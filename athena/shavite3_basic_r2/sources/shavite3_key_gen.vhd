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

entity shavite3_key_gen is
generic (rom_style:integer:=DISTRIBUTED;aes_round_style:integer:=AES_ROUND_BASIC);
port(
	clk				:in std_logic;
	rst				:in std_logic;
	en				:in std_logic;
	sel_aes			:in std_logic; 
	sel_init 		:in std_logic; 
	sel_con_cnt1	:in std_logic_vector(1 downto 0);	
	sel_con_cnt2	:in std_logic_vector(1 downto 0);
	sel_con_cnt3	:in std_logic;
	sel_con_cnt4	:in std_logic;					 
	input			:in std_logic_vector(AES_BLOCK_SIZE-1 downto 0);
	salt			:in std_logic_vector(2*AES_BLOCK_SIZE-1 downto 0);
	cnt				:in std_logic_vector(63 downto 0); 
	keyx		 	:out std_logic_vector(AES_BLOCK_SIZE-1 downto 0);
	key				:out std_logic_vector(AES_BLOCK_SIZE-1 downto 0));
end shavite3_key_gen;

architecture shavite3_key_gen of shavite3_key_gen is
constant zero : std_logic_vector(AES_BLOCK_SIZE-1 downto 0):= (others=>'0');
constant qzero : std_logic_vector(AES_BLOCK_SIZE/4-1 downto 0):= (others=>'0');
signal first_level_mux, level_after_aes, from_xor	:matrix;
signal reg_out, reg_in :matrix2;
constant zero32 :std_logic_vector(AES_BLOCK_SIZE/4-1 downto 0):=(others=>'0'); 
signal con_cnt4, con_cnt3, con_cnt2o, con_cnt2e, con_cnt2, con_cnt1, con_cnt1o, con_cnt1e  :std_logic_vector(AES_BLOCK_SIZE/4-1 downto 0);
signal to_aes, from_aes, salt_to_xor :std_logic_vector(AES_BLOCK_SIZE-1 downto 0);

begin	 	
	
	sa_mux: for i in 1 to 4 generate 
		first_level_mux(i) <= level_after_aes(i) when sel_aes='1' else from_xor(i);
	end generate;
	
	si_mux: for i in 1 to 4 generate	
		reg_in(i) <= input(32*(i)-1 downto 32*(i-1)) when sel_init ='1' else first_level_mux(i);
	end generate;
	
	sa_mux_rest: for i in 5 to 16 generate
		reg_in(i) <= reg_out(i-4);
	end generate;
	
	-- key scheduling storage registers 
	rg_gen: for i in 1 to 16 generate
		rs: regn generic map (N=>AES_BLOCK_SIZE/4, init=>qzero) port map (clk=>clk, rst=>rst, en=>en, input=>reg_in(i), output=>reg_out(i));
	end generate;

	salt_to_xor <=  salt(2*AES_BLOCK_SIZE-1 downto AES_BLOCK_SIZE) xor salt(AES_BLOCK_SIZE-1 downto 0);

	to_aes <= (reg_out(15) & reg_out(14) & reg_out(13) & reg_out(16)) xor salt_to_xor; 
 
	-- AES round implementation (non linear part)
basic_gen: if aes_round_style=AES_ROUND_BASIC generate 	
	aes_rd : entity work.aes_round(basic) generic map (rom_style=>rom_style) port map (key=>zero, input=>to_aes, output=>from_aes); 
end generate;

tbox_gen: if aes_round_style=AES_ROUND_TBOX generate 	
	aes_rd : entity work.aes_round(tbox) generic map (rom_style=>rom_style) port map (key=>zero, input=>to_aes, output=>from_aes); 
end generate;
	
	-- counters and inverted counters values xored with intermediate values 
	con_cnt4 <= cnt(63 downto 32) when sel_con_cnt4 = '1' else qzero;
	level_after_aes(4) <= from_aes(127 downto 96) xor reg_out(4) xor con_cnt4;

	con_cnt3 <= (not cnt(31 downto 0)) when sel_con_cnt3 = '1' else qzero;
	level_after_aes(3) <= from_aes(95 downto 64) xor reg_out(3) xor con_cnt3;

	con_cnt2o <= cnt(31 downto 0) when sel_con_cnt2(0) = '1' else qzero;
	con_cnt2e <= not cnt(63 downto 32) when sel_con_cnt2(0) = '1' else qzero;

	con_cnt2 <= con_cnt2o when sel_con_cnt2(1)='1' else con_cnt2e;	
	level_after_aes(2) <= from_aes(63 downto 32) xor reg_out(2) xor con_cnt2;

	con_cnt1o <= not cnt(31 downto 0) when sel_con_cnt1(0) = '1' else qzero;
	con_cnt1e <= not cnt(63 downto 32) when sel_con_cnt1(0) = '1' else qzero;

	con_cnt1 <= con_cnt1o when sel_con_cnt1(1)='1' else con_cnt1e;	
	level_after_aes(1) <= from_aes(31 downto 0) xor reg_out(1) xor con_cnt1;

	from_xor(1) <= reg_out(13) xor from_xor(4);
	from_xor(2) <= reg_out(14) xor reg_out(1);
	from_xor(3) <= reg_out(15) xor reg_out(2);
	from_xor(4) <= reg_out(16) xor reg_out(3);

	-- keys to SHAvite-3 rounds 
	keyx <= reg_out(8) & reg_out(7) & reg_out(6) & reg_out(5);
	key <= reg_out(4) & reg_out(3) & reg_out(2) & reg_out(1);
	

end shavite3_key_gen;