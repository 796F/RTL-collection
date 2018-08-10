-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;	
use work.sha3_pkg.all;
use work.keccak_pkg.all;

-- Possible generic values: 
--      hs = {HASH_SIZE_256, HASH_SIZE_512} 

entity keccak_top is		
generic (hs : integer := HASH_SIZE_256); 											
port (		
		rst 			: in std_logic;
		clk 			: in std_logic;
		src_ready 		: in std_logic;
		src_read  		: out std_logic;
		dst_ready 		: in std_logic;
		dst_write 		: out std_logic;		
		din				: in std_logic_vector(w-1 downto 0);
		dout			: out std_logic_vector(w-1 downto 0));	   
end keccak_top;


architecture struct of keccak_top is 
	signal ein: std_logic; 
	signal final_segment : std_logic;
	signal sel_xor, sel_final, wr_state, en_ctr :std_logic;
	signal c:  std_logic_vector(w-1 downto 0);
	signal wr_c, en_len, ld_rdctr, en_rdctr, sel_piso, 
	last_block,wr_piso  : std_logic;
begin
	
	control_gen : entity work.keccak_control(struct)
		generic map(hs=>hs)
		port map (clk =>clk, io_clk=>clk, rst=>rst, ein=>	ein, wr_c=>wr_c,  					 
		en_ctr=>en_ctr,  en_len=>en_len, sel_xor=>sel_xor, sel_final=>sel_final, ld_rdctr=>ld_rdctr, 
		en_rdctr=>en_rdctr,  wr_state=>wr_state, sel_out=>sel_piso,final_segment=>final_segment, 
		last_block=>last_block, eo=>wr_piso, src_ready=>src_ready,
		src_read=>src_read, dst_ready =>dst_ready,	dst_write=>dst_write, c=>c); 							

dp256_gen : if hs=HASH_SIZE_256 generate	
	datapath_gen : entity work.keccak_datapath(struct)
		generic map(hs=>HASH_SIZE_256, b=>KECCAK256_CAPACITY)
		port map (clk => clk, io_clk => clk, rst=>rst, din => din, dout => dout, wr_c=>wr_c,  
		en_len=>en_len, en_ctr=>en_ctr, ein=>ein, c=>c, sel_xor=>sel_xor, sel_final=>sel_final, 
		wr_state=>wr_state, ld_rdctr=>ld_rdctr, en_rdctr=>en_rdctr, sel_piso=>sel_piso, wr_piso	=>wr_piso, 
		final_segment=>final_segment, last_block=>last_block);	
end generate;

dp512_gen : if hs=HASH_SIZE_512 generate	
	datapath_gen : entity work.keccak_datapath(struct)
		generic map(hs=>HASH_SIZE_512, b=>KECCAK512_CAPACITY)
		port map (clk => clk, io_clk => clk, rst=>rst, din => din, dout => dout, wr_c=>wr_c,  
		en_len=>en_len, en_ctr=>en_ctr, ein=>ein, c=>c, sel_xor=>sel_xor, sel_final=>sel_final, 
		wr_state=>wr_state, ld_rdctr=>ld_rdctr, en_rdctr=>en_rdctr, sel_piso=>sel_piso, wr_piso	=>wr_piso, 
		final_segment=>final_segment, last_block=>last_block);	
end generate;

	
end struct;		

