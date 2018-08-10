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

entity shavite3_double_key_gen is
generic (rom_style:integer:=DISTRIBUTED; aes_round_style:integer:=AES_ROUND_BASIC);
port(
	clk				:in std_logic;
	rst				:in std_logic;
	en				:in std_logic;
	sel_aes			:in std_logic; 
	sel_init 		:in std_logic; 	 
	sel_key			:in std_logic_vector(1 downto 0);
	sel_con			:in std_logic_vector(3 downto 0);					 
	input			:in std_logic_vector(2*AES_BLOCK_SIZE-1 downto 0);
	salt			:in std_logic_vector(4*AES_BLOCK_SIZE-1 downto 0);
	cnt				:in std_logic_vector(AES_BLOCK_SIZE-1 downto 0); 
	keyx_left	 	:out std_logic_vector(AES_BLOCK_SIZE-1 downto 0);
	key_left		:out std_logic_vector(AES_BLOCK_SIZE-1 downto 0);
	keyx_right	 	:out std_logic_vector(AES_BLOCK_SIZE-1 downto 0);
	key_right		:out std_logic_vector(AES_BLOCK_SIZE-1 downto 0));
end shavite3_double_key_gen;

architecture shavite3_double_key_gen of shavite3_double_key_gen is
constant zero : std_logic_vector(AES_BLOCK_SIZE-1 downto 0):= (others=>'0');
constant ones : std_logic_vector(AES_BLOCK_SIZE-1 downto 0):= (others=>'0');
constant qzero : std_logic_vector(AES_BLOCK_SIZE/4-1 downto 0):= (others=>'0');
signal level_after_aes, from_xor, first_level_mux 	:matrix_double;
signal reg_out, reg_in 	:matrix_double2;
constant zero32 :std_logic_vector(AES_BLOCK_SIZE/4-1 downto 0):=(others=>'0'); 
signal con_cnt1, con_cnt2, con_cnt3, con_cnt4, con_cnt5, con_cnt6, con_cnt7, con_cnt8  :std_logic_vector(AES_BLOCK_SIZE/4-1 downto 0);
signal to_aes_left, to_aes_right, from_aes_left, from_aes_right, salt_to_xor_left, salt_to_xor_right :std_logic_vector(AES_BLOCK_SIZE-1 downto 0);

begin	 	

	sa_mux: for i in 1 to 8 generate 
		first_level_mux(i) <= level_after_aes(i) when sel_aes='1' else from_xor(i);
	end generate;
	
	sa_mux_rest: for i in 9 to 32 generate
		reg_in(i) <= reg_out(i-8);
	end generate;	
		
	si_mux: for i in 1 to 8 generate	
		reg_in(i) <= input(32*(i)-1 downto 32*(i-1)) when sel_init ='1' else first_level_mux(i);
	end generate;

	-- key scheduling storage registers	
	rg_gen: for i in 1 to 32 generate
		rs: regn generic map (N=>AES_BLOCK_SIZE/4, init=>qzero) port map (clk=>clk, rst=>rst, en=>en, input=>reg_in(i), output=>reg_out(i));
	end generate;	
		
	salt_to_xor_left <=  salt(4*AES_BLOCK_SIZE-1 downto 3*AES_BLOCK_SIZE) xor salt(2*AES_BLOCK_SIZE-1 downto AES_BLOCK_SIZE);
	salt_to_xor_right <=  salt(3*AES_BLOCK_SIZE-1 downto 2*AES_BLOCK_SIZE) xor salt(AES_BLOCK_SIZE-1 downto 0);

	to_aes_left <= (reg_out(31) & reg_out(30) & reg_out(29) & reg_out(32)) xor salt_to_xor_left; 
	to_aes_right <= (reg_out(27) & reg_out(26) & reg_out(25) & reg_out(28)) xor salt_to_xor_right; 
 
	-- AES round implementation (non linear part)
basic_gen: if aes_round_style=AES_ROUND_BASIC generate	
	aes_rd_left : entity work.aes_round(basic) generic map (rom_style=>rom_style) port map (key=>zero, input=>to_aes_left, output=>from_aes_left); 
	aes_rd_right : entity work.aes_round(basic) generic map (rom_style=>rom_style) port map (key=>zero, input=>to_aes_right, output=>from_aes_right); 
end generate;	
	
tbox_gen: if aes_round_style=AES_ROUND_TBOX generate	
	aes_rd_left : entity work.aes_round(tbox) generic map (rom_style=>rom_style) port map (key=>zero, input=>to_aes_left, output=>from_aes_left); 
	aes_rd_right : entity work.aes_round(tbox) generic map (rom_style=>rom_style) port map (key=>zero, input=>to_aes_right, output=>from_aes_right); 
end generate;	

	-- counters and inverted counters values xored with intermediate values 
	with sel_con(3 downto 2) select
		con_cnt8 <= cnt(127 downto 96) when "10",
			    cnt(95 downto 64) when "01", 
			    qzero when others;	

	level_after_aes(8) <= from_aes_left(127 downto 96) xor reg_out(4) xor con_cnt8;

	with sel_con(3 downto 2) select
		con_cnt7 <= cnt(127 downto 96) when "01",
			    cnt(95 downto 64) when "10", 
			    qzero when others;	
	level_after_aes(7) <= from_aes_left(95 downto 64) xor reg_out(3) xor con_cnt7;

	with sel_con(3 downto 2) select
		con_cnt6 <= cnt(63 downto 32) when "10",
			    cnt(31 downto 0) when "01", 
			    qzero when others;	

	level_after_aes(6) <= from_aes_left(63 downto 32) xor reg_out(2) xor con_cnt6;

	with sel_con(3 downto 2) select
		con_cnt5 <= (not cnt(63 downto 32)) when "01",
			    (not cnt(31 downto 0)) when "10", 
			    qzero when others;	

	level_after_aes(5) <= from_aes_left(31 downto 0) xor reg_out(1) xor con_cnt5;


	with sel_con(1 downto 0) select
		con_cnt4 <= cnt(31 downto 0) when "10",
			    cnt(63 downto 32) when "01", 
			    qzero when others;	

	level_after_aes(4) <= from_aes_right(127 downto 96) xor level_after_aes(8) xor con_cnt4;

	with sel_con(1 downto 0) select
		con_cnt3 <= cnt(63 downto 32) when "10",
			    cnt(31 downto 0) when "01", 
			    qzero when others;	
	level_after_aes(3) <= from_aes_right(95 downto 64) xor level_after_aes(7) xor con_cnt3;

	with sel_con(1 downto 0) select
		con_cnt2 <= cnt(95 downto 64) when "10",
			    cnt(127 downto 96) when "01", 
			    qzero when others;	

	level_after_aes(2) <= from_aes_right(63 downto 32) xor level_after_aes(6) xor con_cnt2;


	with sel_con(1 downto 0) select
		con_cnt1 <= (not cnt(127 downto 96)) when "10",
			    (not cnt(95 downto 64)) when "01", 
			    qzero when others;	

	level_after_aes(1) <= from_aes_right(31 downto 0) xor level_after_aes(5) xor con_cnt1;

	from_xor(1) <= reg_out(25) xor from_xor(8);
	from_xor(2) <= reg_out(26) xor reg_out(1);
	from_xor(3) <= reg_out(27) xor reg_out(2);
	from_xor(4) <= reg_out(28) xor reg_out(3);
	from_xor(5) <= reg_out(29) xor reg_out(4);
	from_xor(6) <= reg_out(30) xor reg_out(5);
	from_xor(7) <= reg_out(31) xor reg_out(6);
	from_xor(8) <= reg_out(32) xor reg_out(7);

	-- keys to SHAvite-3 rounds
	keyx_right <= reg_out(8) & reg_out(7) & reg_out(6) & reg_out(5) ;
	
	keyx_left <= reg_out(24) & reg_out(23) & reg_out(22) & reg_out(21) ;	 
	
	with sel_key select
		key_left <= (reg_out(20) & reg_out(19) & reg_out(18) & reg_out(17)) when "00",
					(reg_out(24) & reg_out(23) & reg_out(22) & reg_out(21)) when "01",	   
					(reg_out(28) & reg_out(27) & reg_out(26) & reg_out(25)) when "10",
					ones when others;

					
	with sel_key select
		key_right <= (reg_out(4) & reg_out(3) & reg_out(2) & reg_out(1)) when "00",
					(reg_out(8) & reg_out(7) & reg_out(6) & reg_out(5)) when "01",	   
					(reg_out(12) & reg_out(11) & reg_out(10) & reg_out(9)) when "10",
					ones when others;
										
end shavite3_double_key_gen;