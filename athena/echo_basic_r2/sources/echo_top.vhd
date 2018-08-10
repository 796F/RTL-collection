-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_pkg.all;
use work.echo_pkg.all;

-- Possible generic values: 
--      hs = {HASH_SIZE_256, HASH_SIZE_512},  
--      aes_round_style = {AES_ROUND_BASIC, AES_ROUND_TBOX} and 
--      rom_style = {DISTRIBUTED, COMBINATIONAL}	
--
-- Note: rom_style refers to the type of rom being used in SBOX implementation
--
-- All combinations are allowed, but rom_style generic is not used when aes_round_style = AES_ROUND_TBOX

entity echo_top is		
	generic (
        rom_style:integer:=DISTRIBUTED; 
        hs :integer := HASH_SIZE_256;  
        aes_round_style:integer:=AES_ROUND_BASIC
    ); 
	port (		
		rst 		: in std_logic;
		clk 		: in std_logic;
		src_ready 	: in std_logic;
		src_read  	: out std_logic;
		dst_ready 	: in std_logic;
		dst_write 	: out std_logic;		
		din			: in std_logic_vector(w-1 downto 0);
		dout		: out std_logic_vector(w-1 downto 0));	   
end echo_top;

architecture struct of echo_top is 
	signal ein: std_logic;
	signal c : std_logic_vector(w-1 downto 0);
	signal er, lo, sf, bf : std_logic;
	signal eo : std_logic;
	signal wr_ctr : std_logic;		 
	signal sel_rd, big_final_mode : std_logic_vector(1 downto 0);
	signal wr_key : std_logic;
	signal wr_c : std_logic;	
	signal wr_len : std_logic;
	signal wr_new_block : std_logic;
	signal last_block : std_logic;
	signal underflow : std_logic;
	signal first_block : std_logic;
	signal bf_early : std_logic;
	signal ls_rs_flag : std_logic;	
	signal final_segment : std_logic;
	signal wr_seg : std_logic;								 
	
begin
	control_gen : entity work.echo_control(struct) 
	generic map ( hs=>hs )
	port map (rst => rst, clk => clk, io_clk => clk, src_ready => src_ready, src_read => src_read, dst_ready => dst_ready, 
	dst_write => dst_write, c => c, ein => ein,  wr_c=>wr_c, sel_rd=>sel_rd, ctr=>wr_ctr, er => er, lo => lo, sf => sf,  bf=>bf,  
	bf_early=>bf_early, wr_key=>wr_key, wr_len=>wr_len, wr_new_block=>wr_new_block, last_block=>last_block, 
	big_final_mode =>big_final_mode,underflow=>underflow, first_block=>first_block, eo => eo, final_segment=>final_segment, wr_seg=>wr_seg,
	ls_rs_flag=>ls_rs_flag);

	a256_gen: if hs= HASH_SIZE_256 generate	
	datapath_gen256 : entity work.echo_datapath(struct256) 
	generic map (rom_style=>rom_style, hs=>HASH_SIZE_256, aes_round_style=>aes_round_style ) 
	port map ( clk => clk, io_clk => clk, rst=>rst, din => din, dout => dout, c => c, ein => ein,  wr_c=>wr_c, bf=>bf, bf_early=>bf_early, 
	wr_key=>wr_key, sel_rd=>sel_rd, wr_ctr=>wr_ctr, er => er, lo => lo, sf => sf, wr_len=>wr_len, wr_new_block=>wr_new_block, 
	big_final_mode =>	big_final_mode, last_block=>last_block, underflow=>underflow,  first_block=>first_block, eo => eo, final_segment=>final_segment, 
	wr_seg=>wr_seg, ls_rs_flag=>ls_rs_flag);
	end generate;	
	
	a512_gen: if hs= HASH_SIZE_512 generate
	datapath_gen512 : entity work.echo_datapath(struct512) 
	generic map (rom_style=>rom_style, hs=>HASH_SIZE_512, aes_round_style=>aes_round_style ) 
	port map ( clk => clk, io_clk => clk, rst=>rst, din => din, dout => dout, c => c, ein => ein,  wr_c=>wr_c, bf=>bf, bf_early=>bf_early, 
	wr_key=>wr_key, sel_rd=>sel_rd, wr_ctr=>wr_ctr, er => er, lo => lo, sf => sf, wr_len=>wr_len, wr_new_block=>wr_new_block, 
	big_final_mode =>	big_final_mode, last_block=>last_block, underflow=>underflow, first_block=>first_block, eo => eo, final_segment=>final_segment, 
	wr_seg=>wr_seg, ls_rs_flag=>ls_rs_flag);
	end generate;	
	
	
end struct;
	
	