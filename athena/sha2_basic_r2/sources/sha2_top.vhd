-- =====================================================================
-- Copyright © 2010-11 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_pkg.all;	
use work.sha2_pkg.all;	

-- Possible generics values: 
--      hs = {HASH_SIZE_256, HASH_SIZE_512}

entity sha2_top is
generic( hs : integer :=HASH_SIZE_256);
port (
    	clk					:in std_logic;
    	rst					:in std_logic;
    	din					:in std_logic_vector(hs/STATE_REG_NUM-1 downto 0); 
    	src_read				:out std_logic;
    	src_ready				:in std_logic;
    	dout					:out std_logic_vector(hs/STATE_REG_NUM-1 downto 0); 
    	dst_write				:out std_logic;
    	dst_ready				:in std_logic);
end sha2_top;

architecture rs_arch of sha2_top is 		   	   

signal z16_reg				:std_logic;
signal zlast_reg			:std_logic;
signal sel2_reg				:std_logic;
signal sel_reg				:std_logic;
signal wr_data_reg			:std_logic;					
signal wr_state_reg			:std_logic;				
signal wr_len_reg			:std_logic;				
signal wr_result_reg		:std_logic;				
signal ctr_ena_reg			:std_logic;
signal lb_reg				:std_logic;
signal dst_write_reg		:std_logic;
signal o8_reg				:std_logic;	
signal ctrl_rst_reg			:std_logic;
signal rst_reg				:std_logic;
signal src_ready_reg		:std_logic;
signal rst_flags_reg		:std_logic;
signal kr_wr_wire			:std_logic;	 
--signal wr_lb_reg			:std_logic;
--signal wr_md_reg			:std_logic;	 
signal wr_chctr_reg			:std_logic;
signal msg_done_reg			:std_logic;
signal  sel_gh_reg			:std_logic;	
signal  sel_gh_reg2			:std_logic;	
signal  skip_word			:std_logic;	


	
begin


src_ready_reg <=  not src_ready;

rsc0: 	entity work.sha2_control_rs(zws)	
		generic map (fifo_mode=>ZERO_WAIT_STATE)
		port map(clk=>clk, rst=>rst, z16=>z16_reg, zlast=>zlast_reg, o8=>o8_reg, skip_word=>skip_word, sel2=>sel2_reg, sel=>sel_reg, sel_gh=>sel_gh_reg,	
		sel_gh2=>sel_gh_reg2, src_read=>src_read, src_ready=>src_ready_reg, dst_write=>dst_write_reg, dst_ready=>dst_ready, wr_data=>wr_data_reg, 
		kw_wr=> kr_wr_wire, wr_state=>wr_state_reg, wr_result=>wr_result_reg, wr_len=>wr_len_reg, last_block=>lb_reg, msg_done=>msg_done_reg, 
		ctr_ena=>ctr_ena_reg, ctrl_rst=>ctrl_rst_reg,  wr_chctr=>wr_chctr_reg,  rst_flags=>rst_flags_reg);	


dp256_gen : if hs=HASH_SIZE_256 generate
datapath: entity work.sha2_datapath_rs(sha2_datapath_rs) 
		generic map (n=>BLOCK_SIZE_512/SHA2_WORDS_NUM, s=>LOG_2_8, flag=>HASH_BLOCKS_256-1, a=>LOG_2_64, r=>ROUNDS_64, cs=>LOG_2_512)
		port map (clk=>clk, rst=>rst_reg, wr_state=>wr_state_reg, wr_result=>wr_result_reg, wr_data=>wr_data_reg, kw_wr=> kr_wr_wire, wr_len=>wr_len_reg, sel=>sel_reg,				  
		sel2=>sel2_reg,	sel_gh=>sel_gh_reg, sel_gh2=>sel_gh_reg2, ctr_ena=>ctr_ena_reg,	z16=>z16_reg, zlast=>zlast_reg, skip_word=>skip_word, o8=>o8_reg, dst_write=>dst_write_reg, 
		data=>din, dataout=>dout, wr_chctr=>wr_chctr_reg, last_block=>lb_reg, msg_done=>msg_done_reg,  rst_flags=>rst_flags_reg);
end generate;

dp512_gen : if hs=HASH_SIZE_512 generate
datapath: entity work.sha2_datapath_rs(sha2_datapath_rs) 
		generic map (n=>BLOCK_SIZE_1024/SHA2_WORDS_NUM, s=>LOG_2_8, flag=>HASH_BLOCKS_512-1, a=>LOG_2_80, r=>ROUNDS_80, cs=>LOG_2_1024)
		port map (clk=>clk, rst=>rst_reg, wr_state=>wr_state_reg, wr_result=>wr_result_reg, wr_data=>wr_data_reg, kw_wr=> kr_wr_wire, wr_len=>wr_len_reg, sel=>sel_reg,				  
		sel2=>sel2_reg,	sel_gh=>sel_gh_reg, sel_gh2=>sel_gh_reg2, ctr_ena=>ctr_ena_reg,	z16=>z16_reg, zlast=>zlast_reg, skip_word=>skip_word, o8=>o8_reg, dst_write=>dst_write_reg, 
		data=>din, dataout=>dout, wr_chctr=>wr_chctr_reg, last_block=>lb_reg, msg_done=>msg_done_reg, rst_flags=>rst_flags_reg);
end generate;

		
rst_reg <= ctrl_rst_reg or rst;
dst_write <= dst_write_reg;

end rs_arch;
