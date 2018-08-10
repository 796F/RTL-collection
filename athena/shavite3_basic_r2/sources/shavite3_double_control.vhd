-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.shavite3_pkg.all;

-- control module for 512 variant
entity shavite3_double_control is		
	port (					
		clk						: in std_logic;
		io_clk 					: in std_logic;
		rst						: in std_logic;
		ein						: out std_logic;
		c						: in std_logic_vector(w-1 downto 0); 
		wr_c 					: out std_logic; 		
		wr_seg 					: out std_logic; 
		en_ctr					: out std_logic;
		sel_rd 					: out std_logic_vector(1 downto 0);
		data_sel				: out std_logic_vector(1 downto 0); 
		en_keygen				: out std_logic; 
		sel_init_kg				: out std_logic;
		sel_init_state			: out std_logic;							
		en_len					: out std_logic;
		wr_result				: out std_logic;
		sel_aes					: out std_logic;
		sel_key					: out std_logic_vector(1 downto 0);
		sel_con					: out std_logic_vector(3 downto 0);
		en_in_round				: out std_logic;  	
		en_state				: out std_logic; 	
		sel_out					: out std_logic;
		final_segment			: in std_logic;	
		ls_rs_flag				: out std_logic;
		last_block				: in std_logic;	
		eo 						: out std_logic;
		src_ready				: in std_logic;
		src_read				: out std_logic;
		dst_ready 				: in std_logic;
		dst_write				: out std_logic);				 
end shavite3_double_control;

architecture struct of shavite3_double_control is				   	 
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
	signal wr_c_wire :std_logic;
	signal sel_rd_wire :std_logic_vector(1 downto 0);
	signal bf_wire : std_logic; 
	signal wr_len_wire :std_logic; 
	signal eo_wire, src_read_wire, dst_write_wire : std_logic;	
	signal first_block_wire, wr_result_wire	:std_logic;    
	signal sel_init_kg_wire, en_keygen_wire, sel_aes_wire	:std_logic; 
	signal sel_key_wire, data_sel_wire		:std_logic_vector(1 downto 0); 
	signal sel_con_wire		:std_logic_vector(3 downto 0); 
	signal  en_state_wire, sel_init_state_wire, en_in_round_wire :std_logic; 
	signal sel_init_st, sel_out_wire, ena_ctr_wire, wr_seg_wire, wfl2, ls_rs_set, ls_rs_flag_wire, 
	no_init_set, no_init_clr, no_init, msg_end_set_valid: std_logic;   
	
begin	
		
	fsm1_gen : entity work.shavite3_fsm1(nocounter) 
		generic map (mw=>SHAVITE3_STATE_SIZE_512)
		port map (
		io_clk => io_clk, rst => rst, wr_seg=>wr_seg_wire, final_segment=>final_segment, 
		c => c, wr_c=>wr_c_wire, wr_len=>wr_len_wire, ein => ein_wire, ls_rs_set=>ls_rs_set, load_next_block => load_next_block, 
		last_block=>last_block, block_ready_set => block_ready_set,wfl2=>wfl2, msg_end_set => msg_end_set, msg_end=>msg_end, 
		src_ready => src_ready, src_read => src_read_wire);
	
	fsm2_gen : entity work.shavite3_double_fsm2(beh) 
		port map ( clk => clk, rst => rst,   bf=>bf_wire, ena_ctr=>ena_ctr_wire,  sel_rd=>sel_rd_wire, sel_init_kg=>sel_init_kg_wire, 
		sel_init_state=>sel_init_state_wire, en_keygen=>en_keygen_wire, sel_aes=>sel_aes_wire, sel_key=>sel_key_wire, sel_con=>sel_con_wire,  
		data_sel=>data_sel_wire, en_state=>en_state_wire, en_in_round=>en_in_round_wire, wr_result=>wr_result_wire, first_block_in=>first_block_wire, 
		wfl2=>wfl2, ls_rs_flag=>ls_rs_flag_wire, no_init_set=>no_init_set, no_init_clr=>no_init_clr, no_init=>no_init, last_block=>last_block, 
		block_ready_clr => block_ready_clr, msg_end_clr => msg_end_clr, block_ready => block_ready, msg_end => msg_end, 
		output_write_set => output_write_set, output_busy_set => output_busy_set, output_busy => output_busy); 	 
	
	
	fsm3_gen : entity work.shavite3_fsm3(beh) 
		generic map (hs=>HASH_SIZE_512)
		port map ( io_clk => io_clk, rst => rst, eo => eo_wire, sel_out=>sel_out_wire, output_write => output_write, 
		output_write_clr => output_write_clr, output_busy_clr => output_busy_clr, dst_ready => dst_ready, dst_write => dst_write_wire);	 
			
	sync_s <= VCC;
	
	load_next_block <= ((not block_ready) or (block_ready_clr and sync_s));
	block_ready_clr_sync 	<= block_ready_clr and sync_s;	 
	msg_end_clr_sync 		<= msg_end_clr and sync_s;
	output_write_set_sync 	<= output_write_set and sync_s;
	output_busy_set_sync 	<= output_busy_set and sync_s;

	-- flags for handshaking three FSMs	
	sr_blk_ready : sr_reg 
	port map ( rst => rst, clk => io_clk, set => block_ready_set, clr => block_ready_clr_sync, output => block_ready);
	
	msg_end_set_valid <= '1' when (msg_end_set='1') and (ls_rs_flag_wire='1') else '0';
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
	
	eo <= eo_wire; 
	sel_init_st <= VCC when (sel_init_state_wire=VCC and first_block_wire=VCC) else GND;
	sel_out <= sel_out_wire;

	-- output signal registered		
	d01 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => ein_wire, q => ein );
	d02 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => ena_ctr_wire, q => en_ctr );
	d03 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => sel_rd_wire(0), q => sel_rd(0) );
	d04 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => sel_rd_wire(1), q => sel_rd(1) );
	d05 : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => wr_len_wire, q =>en_len );
	d06 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => wr_c_wire, q =>wr_c );	
	d07 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => dst_write_wire, q =>dst_write );
	d08 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => sel_init_kg_wire, q =>sel_init_kg );
	d09 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => en_keygen_wire, q =>en_keygen );
	d11 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => sel_aes_wire, q =>sel_aes );
	d12 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => sel_con_wire(0), q =>sel_con(0) );
	d13 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => sel_con_wire(1), q =>sel_con(1) );
	d14 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => sel_con_wire(2), q =>sel_con(2) );
	d15 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => sel_con_wire(3), q =>sel_con(3) );
	d16 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => sel_key_wire(0), q =>sel_key(0));
	d17 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => sel_key_wire(1), q =>sel_key(1));
	d18 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => data_sel_wire(0), q =>data_sel(0));
	d19 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => data_sel_wire(1), q =>data_sel(1));  		
	d20 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => en_state_wire, q =>en_state);	
	d21 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => sel_init_st, q =>sel_init_state);
 	d22 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => en_in_round_wire, q =>en_in_round);
 	d23 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => wr_result_wire, q =>wr_result);	  
	d24 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => wr_seg_wire, q =>wr_seg );
	d25 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => src_read_wire, q =>src_read );
 	d26 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => ls_rs_flag_wire, q =>ls_rs_flag);	  			

end struct;