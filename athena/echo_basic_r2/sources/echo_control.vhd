-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.echo_pkg.all;

-- control module for 256 variant
-- possible values of generics hs = {HASH_SIZE_256, HASH_SIZE_512}

entity echo_control is		
	generic ( 
		hs : integer:= HASH_SIZE_256
	);
	port (					
		rst				: in std_logic;
		clk				: in std_logic;
		io_clk 			: in std_logic;
		ein				: out std_logic;		
		c				: in std_logic_vector(w-1 downto 0); 
		wr_c 			: out std_logic;
		wr_seg 			: out std_logic; 
		ctr				: out std_logic;
		sel_rd 			: out std_logic_vector(1 downto 0);
		er, lo, sf  	: out std_logic;
		bf				: out std_logic;	 
		wr_key			: out std_logic;
		wr_len			: out std_logic;
		wr_new_block	: out std_logic;
		final_segment	: in std_logic;	
		ls_rs_flag		: out std_logic;		
		last_block		: in std_logic;	
		bf_early		: out std_logic;	 	
		big_final_mode 	: out std_logic_vector(1 downto 0);
		underflow		: in std_logic;	
		first_block		: out std_logic;
		eo 				: out std_logic;
		src_ready		: in std_logic;
		src_read		: out std_logic;
		dst_ready 		: in std_logic;
		dst_write		: out std_logic);				 
end echo_control;

architecture struct of echo_control is				   	 
	signal block_ready_set, msg_end_set, load_next_block : std_logic;	
	signal block_ready_clr, msg_end_clr : std_logic; --out
	signal block_ready, msg_end : std_logic; --in
	signal output_write_set, output_busy_set : std_logic; --out
	signal output_busy : std_logic; --in 
	signal output_write : std_logic; -- in
	signal output_write_clr, output_busy_clr : std_logic; --out	   
	signal sync_s : std_logic;						
	signal block_ready_clr_sync, msg_end_clr_sync : std_logic;
	signal output_write_set_sync, output_busy_set_sync : std_logic;
	signal ein_wire	:std_logic;
	signal  ctr_wire, er_wire, lo_wire, wr_c_wire :std_logic;
	signal sel_rd_wire, big_final_mode_wire  :std_logic_vector(1 downto 0);
	signal sf_wire,   bf_wire : std_logic; 
	signal wr_key_wire,  wr_len_wire :std_logic; 
	signal wr_new_block_wire, eo_wire, src_read_wire, dst_write_wire: std_logic;	
	signal first_block_wire, first_block_in, bf_early_wire, wr_seg_wire, wfl2, ls_rs_set, ls_rs_flag_wire, 
	no_init_set, no_init_clr, no_init, msg_end_set_valid 	:std_logic; 

begin
	
ctrl256: if hs = HASH_SIZE_256 generate	
	fsm1_gen : entity work.echo_fsm1(nocounter) 
		generic map(mw=>ECHO_DATA_SIZE_BIG)
		port map (io_clk => io_clk, rst => rst, c => c, wr_c=>wr_c_wire, wr_len=>wr_len_wire, ein => ein_wire, load_next_block => load_next_block, 
		last_block=>last_block, block_ready_set => block_ready_set, msg_end_set => msg_end_set,src_ready => src_ready, src_read => src_read_wire,
		wr_seg=>wr_seg_wire, final_segment=>final_segment, wfl2=>wfl2, msg_end=>msg_end, ls_rs_set=>ls_rs_set);	 
	
	fsm2_gen : entity work.echo_fsm2(beh256) 
		port map (clk => clk, rst => rst, er => er_wire, lo => lo_wire, sf => sf_wire, bf=>bf_wire,  ctr=>ctr_wire, sel_rd=>sel_rd_wire, 
		wr_new_block=>wr_new_block_wire, underflow=>underflow, last_block=>last_block, wr_key=>wr_key_wire, block_ready_clr => block_ready_clr, 
		msg_end_clr => msg_end_clr, block_ready => block_ready, msg_end => msg_end, output_write_set => output_write_set, bf_early=>bf_early_wire,
		big_final_mode =>	big_final_mode_wire, output_busy_set => output_busy_set, output_busy => output_busy, wfl2=>wfl2, ls_rs_flag=>ls_rs_flag_wire, 
		no_init_set=>no_init_set, no_init_clr=>no_init_clr, no_init=>no_init, first_block_in=>first_block_wire); 
	
	fsm3_gen : entity work.echo_fsm3(beh256) 
		port map (io_clk => io_clk, rst => rst, eo => eo_wire, output_write => output_write, output_write_clr => output_write_clr, 
		output_busy_clr => output_busy_clr, dst_ready => dst_ready, dst_write => dst_write_wire);	 
	end generate;
	
	
ctrl512: if hs = HASH_SIZE_512 generate	
	fsm1_gen : entity work.echo_fsm1(nocounter) 
		generic map(mw=>ECHO_DATA_SIZE_SMALL)
		port map (io_clk => io_clk, rst => rst, c => c, wr_c=>wr_c_wire, wr_len=>wr_len_wire, ein => ein_wire, load_next_block => load_next_block, 
		last_block=>last_block, block_ready_set => block_ready_set, msg_end_set => msg_end_set,src_ready => src_ready, src_read => src_read_wire,
		wr_seg=>wr_seg_wire, final_segment=>final_segment, wfl2=>wfl2, msg_end=>msg_end, ls_rs_set=>ls_rs_set);	 
	
	fsm2_gen : entity work.echo_fsm2(beh512) 
		port map (clk => clk, rst => rst, er => er_wire, lo => lo_wire, sf => sf_wire,  bf=>bf_wire, ctr=>ctr_wire, sel_rd=>sel_rd_wire, 
		wr_new_block=>wr_new_block_wire, underflow=>underflow, last_block=>last_block, wr_key=>wr_key_wire,  block_ready_clr => block_ready_clr, 
		msg_end_clr => msg_end_clr, block_ready => block_ready, msg_end => msg_end, output_write_set => output_write_set, bf_early=>bf_early_wire,
		big_final_mode =>	big_final_mode_wire, output_busy_set => output_busy_set, output_busy => output_busy, wfl2=>wfl2, ls_rs_flag=>ls_rs_flag_wire, 
		no_init_set=>no_init_set, no_init_clr=>no_init_clr, no_init=>no_init, first_block_in=>first_block_wire); 
	
	fsm3_gen : entity work.echo_fsm3(beh512) 
		port map (io_clk => io_clk, rst => rst, eo => eo_wire, output_write => output_write, output_write_clr => output_write_clr, 
		output_busy_clr => output_busy_clr, dst_ready => dst_ready, dst_write => dst_write_wire);	 
	end generate;	
	 		
	sync_s <= VCC;
	
	load_next_block <= ((not block_ready) or (block_ready_clr and sync_s));
	block_ready_clr_sync 	<= block_ready_clr and sync_s;	 
	msg_end_clr_sync 		<= msg_end_clr and sync_s;
	output_write_set_sync 	<= output_write_set and sync_s;
	output_busy_set_sync 	<= output_busy_set and sync_s;
	
	-- FSM handshaking flags 	
	sr_blk_ready : sr_reg 
	port map ( rst => rst, clk => io_clk, set => block_ready_set, clr => block_ready_clr_sync, output => block_ready);
	
	msg_end_set_valid <= VCC when (msg_end_set=VCC) and (ls_rs_flag_wire=VCC) else GND;
	sr_msg_end : sr_reg 
	port map ( rst => rst, clk => io_clk, set => msg_end_set_valid, clr => msg_end_clr_sync, output => msg_end);
	
	sr_output_write : sr_reg 
	port map ( rst => rst, clk => io_clk, set => output_write_set_sync, clr => output_write_clr, output => output_write );
	
	sr_output_busy : sr_reg  
	port map ( rst => rst, clk => io_clk, set => output_busy_set_sync, clr => output_busy_clr, output => output_busy );
	
	sr_first_block : sr_reg  
	port map ( rst => rst, clk => io_clk, set => wr_c_wire, clr => bf_wire, output => first_block_wire );
	
	last_segment_in_random_split : sr_reg 
	port map ( rst => rst, clk => io_clk, set => ls_rs_set, clr => no_init_clr, output => ls_rs_flag_wire);  
																
	no_init_flag : sr_reg 
	port map ( rst => rst, clk => io_clk, set => no_init_set, clr => no_init_clr, output => no_init);  	
	
	-- output signals are registered
	d01 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => ein_wire, q => ein );
	d02 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => ctr_wire, q => ctr );
	d03 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => sel_rd_wire(0), q => sel_rd(0) );
	d04 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => sel_rd_wire(1), q => sel_rd(1) );
	d05 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => er_wire, q =>er );
	d06 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => lo_wire, q =>lo );
	d07 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => sf_wire, q =>sf );
	d08 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => bf_wire, q =>bf );
	d09 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => wr_key_wire, q =>wr_key ); 
	d10 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => wr_len_wire, q =>wr_len );
	d11 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => wr_new_block_wire, q =>wr_new_block );
	d12 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => eo_wire, q =>eo );
	d13 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => wr_c_wire, q =>wr_c );
	d14 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => src_read_wire, q =>src_read );
	d15 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => dst_write_wire, q =>dst_write );
	d16 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => first_block_wire, q =>first_block );
	d17 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => big_final_mode_wire(0), q =>big_final_mode(0) );
	d18 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => big_final_mode_wire(1), q =>big_final_mode(1) );
	d19 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => bf_early_wire, q =>bf_early );
	d20 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => wr_seg_wire, q =>wr_seg );
    d21 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => ls_rs_flag_wire, q =>ls_rs_flag);	   						
		
end struct;