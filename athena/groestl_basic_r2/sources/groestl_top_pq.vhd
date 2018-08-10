-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_pkg.all;
use work.groestl_pkg.all;	 

-- Possible generic values: 
--      hs = {HASH_SIZE_256, HASH_SIZE_512}, 
--      rom_style = {DISTRIBUTED, COMBINATIONAL}
--
-- Note: rom_style refers to the type of rom being used in SBOX implementation
-- 
-- All combinations are allowed				


entity groestl_top_pq is		
	generic (
		rom_style	:integer	:= DISTRIBUTED;
		hs 			:integer 	:= HASH_SIZE_256); 
	port (		
		rst 		: in std_logic;
		clk 		: in std_logic;
		src_ready 	: in std_logic;
		src_read  	: out std_logic;
		dst_ready 	: in std_logic;
		dst_write 	: out std_logic;		
		din			: in std_logic_vector(w-1 downto 0);
		dout		: out std_logic_vector(w-1 downto 0)
	);	   
end groestl_top_pq;


architecture struct of groestl_top_pq is  

signal ein, init1, init2, init3, finalization, wr_state, wr_result	:std_logic;
signal load_ctr, wr_ctr, p_mode, sel_out, eout, wr_c, en_len, en_ctr, last_block, 
wr_seg, final_segment, ls_rs_flag, last_cycle	:std_logic;
signal c	:std_logic_vector(63 downto 0);  

begin

	
dp_fx2_256_gen: if (hs=HASH_SIZE_256) generate
dp_fx2_256 : entity work.groestl_datapath_pq(folded_x2) 
		generic map(n=>GROESTL_DATA_SIZE_SMALL, hs=> HASH_SIZE_256)
		port map (clk=>clk, rst=>rst, ein=>ein, init1=>init1, init2=>init2, init3=>init3, finalization=>finalization, last_cycle=>last_cycle,
		wr_state=>wr_state, wr_result=>wr_result, load_ctr=>load_ctr, wr_ctr=>wr_ctr, p_mode=>p_mode, sel_out=>sel_out, 
		eout=>eout, wr_c=>wr_c, wr_seg=>wr_seg, en_len=>en_len,	en_ctr=>en_ctr,	last_block=>last_block,	c=>c, din=>din, dout=>dout, 
		final_segment=>final_segment, ls_rs_flag=>ls_rs_flag);	  	
end generate;	

dp_fx2_512_gen: if (hs=HASH_SIZE_512)  generate	
dp512 : entity work.groestl_datapath_pq(folded_x2) 
		generic map(n=>GROESTL_DATA_SIZE_BIG, hs=> HASH_SIZE_512)
		port map ( clk=>clk, rst=>rst, ein=>ein, init1=>init1, init2=>init2, init3=>init3, finalization=>finalization, last_cycle=>last_cycle, 
		wr_state=>wr_state, wr_result=>wr_result, load_ctr=>load_ctr, wr_ctr=>wr_ctr, p_mode=>p_mode, sel_out=>sel_out, 
		eout=>eout, wr_c=>wr_c, wr_seg=>wr_seg, en_len=>en_len,	en_ctr=>en_ctr,	last_block=>last_block,	c=>c, din=>din, dout=>dout,
		final_segment=>final_segment, ls_rs_flag=>ls_rs_flag);	  	
end generate;
		
ctrl : entity work.groestl_control_pq(struct) 
		generic map(hs=>hs, arch=>GROESTL_ARCH_PQ_QPPL)
		port map ( clk	=> clk, io_clk =>clk, rst=>rst, ein	=> ein, c=>c, wr_seg=>wr_seg, wr_c =>wr_c, en_ctr => en_ctr, en_len =>en_len, 
		last_block =>last_block, underflow =>'0', init1=>init1, init2=>init2, init3=>init3, finalization=>finalization, last_cycle=>last_cycle,
		wr_state=>wr_state, wr_result=>wr_result, load_ctr=>load_ctr, wr_ctr=>wr_ctr, p_mode=>p_mode, sel_out=>sel_out, 
		eo =>eout, src_ready=>src_ready, src_read=>src_read, dst_ready=>dst_ready, dst_write=>dst_write, 
		final_segment=>final_segment, ls_rs_flag=>ls_rs_flag);
		
end struct;
	
	