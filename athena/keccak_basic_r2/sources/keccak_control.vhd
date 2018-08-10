-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.keccak_pkg.all;

-- Possible generics values: 
-- hs = {HASH_SIZE_256, HASH_SIZE_512} 

entity keccak_control is
	generic (hs : integer := HASH_SIZE_256);
	port (					
		clk						: in std_logic;
		io_clk 					: in std_logic;
		rst						: in std_logic;
		ein						: out std_logic;
		wr_c 					: out std_logic; 
		en_ctr					: out std_logic;
		en_len					: out std_logic; 
		sel_xor 				: out std_logic;
		sel_final				: out std_logic;
		ld_rdctr				: out std_logic;
		en_rdctr 				: out std_logic; 
		wr_state				: out std_logic; 	
		sel_out					: out std_logic;
		final_segment			: in std_logic;	
		last_block				: in std_logic;	
		eo 						: out std_logic;
		src_ready				: in std_logic;
		src_read				: out std_logic;
		dst_ready 				: in std_logic;
		dst_write				: out std_logic;
		c						: in std_logic_vector(w-1 downto 0));				 
end keccak_control;

architecture struct of keccak_control is				   	 
	signal block_ready_set, msg_end_set, load_next_block : std_logic;	
	signal block_ready_clr, msg_end_clr : std_logic; 
	signal block_ready, msg_end : std_logic; 
	signal output_write_set, output_busy_set : std_logic; 
	signal output_busy : std_logic; 
	signal output_write : std_logic;
	signal output_write_clr, output_busy_clr : std_logic; 	   
	signal sync_s : std_logic;						
	signal block_ready_clr_sync, msg_end_clr_sync : std_logic;
	signal output_write_set_sync, output_busy_set_sync : std_logic;
	signal ein_wire	:std_logic;			 
	signal  wr_c_wire :std_logic;
	signal wr_len_wire :std_logic; 
	signal eo_wire, src_read_wire, dst_write_wire : std_logic;	
	signal sel_out_wire, ena_ctr_wire, wfl2,  ls_rs_set, ls_rs_flag_wire,
	no_init_set, no_init_clr, no_init, msg_end_set_valid: std_logic;
	signal sel_xor_wire, wr_state_wire 				: std_logic;
	signal sel_final_wire				: std_logic;
	signal ld_rdctr_wire				: std_logic;
	signal en_rdctr_wire 				: std_logic; 
begin

ctrl256_gen: if hs= HASH_SIZE_256 generate	
	fsm1_gen : entity work.keccak_fsm1(nocounter) 
		generic map (mw=>KECCAK256_CAPACITY)
		port map (io_clk => io_clk, rst => rst, final_segment=>final_segment, c => c, wr_c=>wr_c_wire, wr_len=>wr_len_wire, 
		ein => ein_wire, load_next_block => load_next_block, last_block=>last_block, block_ready_set => block_ready_set,
		wfl2=>wfl2, msg_end_set => msg_end_set, ls_rs_set=>ls_rs_set, src_ready => src_ready, src_read => src_read_wire);	 
end generate;

ctrl512_gen: if hs= HASH_SIZE_512 generate	
	fsm1_gen : entity work.keccak_fsm1(nocounter) 
		generic map (mw=>KECCAK512_CAPACITY)
		port map (io_clk => io_clk, rst => rst, final_segment=>final_segment, c => c, wr_c=>wr_c_wire, wr_len=>wr_len_wire, 
		ein => ein_wire, load_next_block => load_next_block, last_block=>last_block, block_ready_set => block_ready_set,
		wfl2=>wfl2, msg_end_set => msg_end_set, ls_rs_set=>ls_rs_set, src_ready => src_ready, src_read => src_read_wire);	 
end generate;
		
		
	fsm2_gen : entity work.keccak_fsm2(beh)
		generic map (hs=>hs)
		port map ( clk => clk, rst => rst,  ena_ctr=>ena_ctr_wire, wr_state=>wr_state_wire, ls_rs_flag=>ls_rs_flag_wire, 
		last_block=>last_block, wfl2=>wfl2, block_ready_clr => block_ready_clr, msg_end_clr => msg_end_clr, 
		block_ready => block_ready, msg_end => msg_end, output_write_set => output_write_set, output_busy_set => output_busy_set, 
		output_busy => output_busy, no_init_set=>no_init_set, no_init_clr=>no_init_clr, no_init=>no_init, sel_xor=>sel_xor_wire,
		sel_final =>sel_final_wire, ld_rdctr=>ld_rdctr_wire, en_rdctr=>en_rdctr_wire); 

  	fsm3_gen : entity work.keccak_fsm3(beh) 
		generic map (hs=>hs)
		port map (io_clk => io_clk, rst => rst, eo => eo_wire, sel_out=>sel_out_wire, output_write => output_write, 
		output_write_clr => output_write_clr, output_busy_clr => output_busy_clr, dst_ready => dst_ready, dst_write => dst_write_wire);	 
		
			
	sync_s <= VCC;
	
	load_next_block <= ((not block_ready) or (block_ready_clr and sync_s));
	block_ready_clr_sync 	<= block_ready_clr and sync_s;	 
	msg_end_clr_sync 		<= msg_end_clr and sync_s;
	output_write_set_sync 	<= output_write_set and sync_s;
	output_busy_set_sync 	<= output_busy_set and sync_s;
	
	-- flags of controller which enables handshaking between fsm's
	
	sr_blk_ready : sr_reg 
	port map ( rst => rst, clk => io_clk, set => block_ready_set, clr => block_ready_clr_sync, output => block_ready);
	
	msg_end_set_valid <= '1' when (msg_end_set='1')and (ls_rs_flag_wire='1')  else '0';
	sr_msg_end : sr_reg 
	port map ( rst => rst, clk => io_clk, set => msg_end_set_valid, clr => msg_end_clr_sync, output => msg_end);
	
	sr_output_write : sr_reg 
	port map ( rst => rst, clk => io_clk, set => output_write_set_sync, clr => output_write_clr, output => output_write );
	
	sr_output_busy : sr_reg  
	port map ( rst => rst, clk => io_clk, set => output_busy_set_sync, clr => output_busy_clr, output => output_busy );
	
	last_segment_in_random_split : sr_reg 
	port map ( rst => rst, clk => io_clk, set => ls_rs_set, clr => no_init_clr, output => ls_rs_flag_wire);  
																
	no_init_flag : sr_reg 
	port map ( rst => rst, clk => io_clk, set => no_init_set, clr => no_init_clr, output => no_init);  
	
	eo <= eo_wire; 
	sel_out <= sel_out_wire;

	-- output signals are registered 	
	d01 : d_ff port map ( clk => io_clk, ena => VCC, rst => rst, d => ein_wire, q => ein );
	d02 : d_ff port map ( clk => clk, ena => VCC, rst => rst, d => ena_ctr_wire, q => en_ctr );
	d03 : d_ff port map ( clk => clk, ena => VCC, rst => rst, d => wr_len_wire, q =>en_len );
	d04 : d_ff port map ( clk => io_clk, ena => VCC, rst => rst, d => wr_c_wire, q =>wr_c );

	d06 : d_ff port map ( clk => io_clk, ena => VCC, rst => rst, d => src_read_wire, q =>src_read );
	d07 : d_ff port map ( clk => io_clk, ena => VCC, rst => rst, d => dst_write_wire, q =>dst_write );
	d08 : d_ff port map ( clk => io_clk, ena => VCC, rst => rst, d => wr_state_wire, q =>wr_state);
	d09 : d_ff port map ( clk => io_clk, ena => VCC, rst => rst, d => sel_xor_wire, q =>sel_xor);	  
	d10 : d_ff port map ( clk => io_clk, ena => VCC, rst => rst, d => sel_final_wire, q =>sel_final);	  
	d11 : d_ff port map ( clk => io_clk, ena => VCC, rst => rst, d => ld_rdctr_wire, q =>ld_rdctr);	  
	d12 : d_ff port map ( clk => io_clk, ena => VCC, rst => rst, d => en_rdctr_wire, q =>en_rdctr);	  
	 
		
end struct;