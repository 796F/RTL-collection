-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_pkg.all;
use work.shavite3_pkg.all;

-- possible generics values: 
-- aes_round_style = {AES_ROUND_BASIC, AES_ROUND_TBOX} and 
-- rom_style = {DISTRIBUTED, COMBINATIONAL}	
-- all combinations allowed, but with TBOX implementation rom_style generic is not used 

entity shavite3_512 is		
	generic ( rom_style:integer:=DISTRIBUTED; aes_round_style:integer:=AES_ROUND_BASIC); 
	port (		
		clk 			: in std_logic;
		rst 			: in std_logic;
		src_ready 		: in std_logic;
		src_read  		: out std_logic;
		dst_ready 		: in std_logic;
		dst_write 		: out std_logic;		
		din				: in std_logic_vector(w-1 downto 0);
		dout			: out std_logic_vector(w-1 downto 0));	   
end shavite3_512;

architecture struct of shavite3_512 is 
	
signal	ein					: std_logic;	
signal	en_keygen			: std_logic;
signal	sel_init_kg			: std_logic;
signal	sel_init_state		: std_logic;
signal	sel_aes				: std_logic;
signal	eout				: std_logic;	
signal	en_len				: std_logic;
signal	en_ctr				: std_logic; 
signal	en_in_round			: std_logic; 	
signal	en_state			: std_logic;	
signal	sel_out				: std_logic;
signal	wr_c				: std_logic;
signal	wr_seg				: std_logic;
signal	last_block			: std_logic;	
signal	wr_result		 	: std_logic;
signal  final_segment		: std_logic;
signal  ls_rs_flag			: std_logic;	
signal	sel_rd				: std_logic_vector(1 downto 0);
signal	data_sel			: std_logic_vector(1 downto 0);
signal	sel_key				: std_logic_vector(1 downto 0);
signal	sel_con				: std_logic_vector(3 downto 0);
signal  c					: std_logic_vector(w-1 downto 0);

begin

shavitedp: 
	entity work.shavite3_double_datapath(struct) 	
	generic map ( rom_style=>rom_style)
	port map (clk =>clk, rst =>rst,  wr_c=>wr_c, wr_seg=>wr_seg, ein =>ein, din=>din, dout =>dout, data_sel=>data_sel, en_keygen=>en_keygen, 
	sel_init_kg=>sel_init_kg, sel_init_state=>sel_init_state, sel_aes=>sel_aes, sel_key=>sel_key, sel_con=>sel_con, en_ctr=>en_ctr, 
	en_in_round=>en_in_round, sel_rd=>sel_rd, eout=>eout, en_len=>en_len, wr_result=>wr_result,  sel_out=>sel_out, c=>c, en_state=>en_state,
	last_block=>last_block, ls_rs_flag=>ls_rs_flag, final_segment=>final_segment);		 	  
				
shavite3_ctrl: 
	entity work.shavite3_double_control(struct) 
	port map ( clk=>clk, rst=>rst, io_clk => clk, wr_c=>wr_c, wr_seg=>wr_seg, c=>c, src_ready=>src_ready, dst_ready=>dst_ready, src_read=>src_read, 
	dst_write=>dst_write, ein=>ein, data_sel=>data_sel, en_keygen=>en_keygen, sel_init_kg=>sel_init_kg, sel_init_state=>sel_init_state, 
	ls_rs_flag=>ls_rs_flag, sel_aes	=>sel_aes, eo=>eout, en_len=>en_len, wr_result=>wr_result, sel_key=>sel_key, sel_con=>sel_con, en_ctr=>en_ctr, 
	en_in_round=>en_in_round, en_state=>en_state, sel_out=>sel_out, last_block=>last_block, final_segment=>final_segment, sel_rd=>sel_rd);

end struct;
	
	