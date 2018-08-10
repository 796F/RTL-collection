-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.groestl_pkg.all;

-- Possible generics values: 
-- hs = {HASH_SIZE_256, HASH_SIZE_512} 

entity groestl_control_pq is		
	generic ( 
	log2clk_ratio : integer := 1;
	hs : integer:=HASH_SIZE_256;
	arch : integer := GROESTL_ARCH_PQ_QPPL;
	ur :integer :=2
	);
	port (					
		rst						: in std_logic;
		clk						: in std_logic;
		io_clk 					: in std_logic;
		ein						:out std_logic;
		c						: in std_logic_vector(w-1 downto 0); 
		wr_c 					: out std_logic;
		wr_seg 					: out std_logic;
		en_ctr					: out std_logic;
		en_len					: out std_logic;		
		sel_out					: out std_logic;		
		ls_rs_flag				: out std_logic;	
		final_segment			: in std_logic;	
		last_block				: in std_logic;	
		underflow				: in std_logic;			
		finalization			: out std_logic;
		init1					: out std_logic;
		init2					: out std_logic;
		init3					: out std_logic;  
		last_cycle				:out std_logic;
		load_ctr				: out std_logic;
		p_mode					: out std_logic;
		wr_ctr					: out std_logic;
		wr_result				: out std_logic;
		wr_state				: out std_logic;
		eo 						: out std_logic;
		src_ready				: in std_logic;
		src_read				: out std_logic;
		dst_ready 				: in std_logic;
		dst_write				: out std_logic);				 
end groestl_control_pq;

architecture struct of groestl_control_pq is				   	 
	-- fsm1
	signal block_ready_set, msg_end_set, load_next_block : std_logic;	
	-- fsm2						 
		-- fsm1 communications
	signal block_ready_clr, msg_end_clr : std_logic; 
	signal block_ready, msg_end : std_logic; 
		-- fsm2 communications
	signal output_write_set, output_busy_set : std_logic;
	signal output_busy : std_logic;  
	
	signal output_write : std_logic; 
	signal output_write_clr, output_busy_clr : std_logic; 	   
	
	signal sync_s : std_logic;						
	signal block_ready_clr_sync, msg_end_clr_sync : std_logic;
	signal output_write_set_sync, output_busy_set_sync : std_logic;
	signal ein_wire	:std_logic;			  
	signal wr_c_wire :std_logic;
	signal bf_wire : std_logic; 
	signal wr_len_wire :std_logic; 
	signal eo_wire,  src_read_wire, dst_write_wire : std_logic;	
	signal first_block_wire, no_init_set, no_init_clr, no_init 	:std_logic;    
	signal sel_out_wire, ena_ctr_wire, msg_end_set_valid: std_logic;   	
	signal finalization_wire, init1_wire, init2_wire, init3_wire, load_ctr_wire :std_logic;
	signal p_mode_wire, wr_ctr_wire, wr_result_wire, wr_state_wire :std_logic;
	signal load_block_invalid, done, wr_seg_wire, ls_rs_set, wfl2, ls_rs_flag_wire :std_logic;
	signal mes1_reg, mes2_reg, lb_wire, msg_end_set_wire, msg_end_set_fsm1, last_cycle_wire : std_logic;
	
begin
	
 	
ctrl_13_256_gen: if hs=HASH_SIZE_256 generate	   
	
	fsm1_gen : entity work.groestl_fsm1(nocounter) 
		generic map (mw=>GROESTL_DATA_SIZE_SMALL)
		port map (io_clk => io_clk, rst => rst, c => c, wr_c=>wr_c_wire, wr_len=>wr_len_wire, 
		ein => ein_wire, sync => sync_s, load_next_block => load_next_block, last_block=>last_block, 
		done=>done, block_ready_set => block_ready_set, msg_end_set => msg_end_set_fsm1, 
		src_ready => src_ready, src_read => src_read_wire, wr_seg=>wr_seg_wire, final_segment=>final_segment, 
		ls_rs_set=>ls_rs_set, wfl2=>wfl2, msg_end=>msg_end);	
			
	fsm3_gen : entity work.groestl_fsm3(beh) 
		generic map (hs=>HASH_SIZE_256)
		port map (io_clk => io_clk, rst => rst, eo => eo_wire, sel_out=>sel_out_wire, output_write => output_write, 
		output_write_clr => output_write_clr, output_busy_clr => output_busy_clr, dst_ready => dst_ready, 
		dst_write => dst_write_wire);
end generate;

ctrl_fx2_256_gen: if (hs=HASH_SIZE_256) and (arch=GROESTL_ARCH_PQ_QPPL)  generate 

	fsm2_gen : entity work.groestl_fsm2_pq(fx2_256) 
		generic	map (hs=>hs)	
		port map (clk => clk, rst => rst, bf=>bf_wire, ena_ctr=>ena_ctr_wire, first_block_in=>first_block_wire, 
		underflow=>underflow, last_block=>last_block, p_mode=>p_mode_wire, wr_result=>wr_result_wire, 
		final=>finalization_wire, init1=>init1_wire, init2=>init2_wire, init3=>init3_wire, last_cycle=>last_cycle_wire, 
		load_ctr=>load_ctr_wire, wr_ctr=>wr_ctr_wire, wr_state=>wr_state_wire, done=>done, 
		load_block_invalid=>load_block_invalid, block_ready_clr => block_ready_clr, msg_end_clr => msg_end_clr, 
		block_ready => block_ready, msg_end => msg_end, output_write_set => output_write_set,
		output_busy_set => output_busy_set, output_busy => output_busy, wfl2=>wfl2, ls_rs_flag=>ls_rs_flag_wire,
		no_init_set=>no_init_set, no_init_clr=>no_init_clr, no_init=>no_init); 	

end generate;	   

ctrl_13_512: if hs=HASH_SIZE_512 generate	   
	
	fsm1_gen : entity work.groestl_fsm1(nocounter) 
		generic map (mw=>GROESTL_DATA_SIZE_BIG)
		port map (io_clk => io_clk, rst => rst, c => c, wr_c=>wr_c_wire, wr_len=>wr_len_wire, 
		ein => ein_wire, sync => sync_s, load_next_block => load_next_block, last_block=>last_block, 
		done=>done, block_ready_set => block_ready_set, msg_end_set => msg_end_set_fsm1, 
		src_ready => src_ready, src_read => src_read_wire, wr_seg=>wr_seg_wire, final_segment=>final_segment, 
		ls_rs_set=>ls_rs_set, wfl2=>wfl2, msg_end=>msg_end);
				
	fsm3_gen : entity work.groestl_fsm3(beh) 
		generic map (hs=>HASH_SIZE_512)
		port map (io_clk => io_clk, rst => rst, eo => eo_wire, sel_out=>sel_out_wire, 
		output_write => output_write, output_write_clr => output_write_clr, output_busy_clr => output_busy_clr,
		dst_ready => dst_ready, dst_write => dst_write_wire);	
end generate;
	
ctrl_fx2_512_gen: if (hs=HASH_SIZE_512) and (arch=GROESTL_ARCH_PQ_QPPL)  generate 
	fsm2_gen : entity work.groestl_fsm2_pq(fx2_512) 
		generic	map (hs=>hs)	
		port map (clk => clk, rst => rst, bf=>bf_wire, ena_ctr=>ena_ctr_wire, first_block_in=>first_block_wire, 
		underflow=>underflow, last_block=>last_block, p_mode=>p_mode_wire, wr_result=>wr_result_wire, 
		final=>finalization_wire, init1=>init1_wire, init2=>init2_wire, init3=>init3_wire, last_cycle=>last_cycle_wire,
		load_ctr=>load_ctr_wire, 
		wr_ctr=>wr_ctr_wire, wr_state=>wr_state_wire, done=>done, load_block_invalid=>load_block_invalid, 
		block_ready_clr => block_ready_clr, msg_end_clr => msg_end_clr, block_ready => block_ready, 
		msg_end => msg_end,output_write_set => output_write_set, output_busy_set => output_busy_set, 
		output_busy => output_busy, wfl2=>wfl2, ls_rs_flag=>ls_rs_flag_wire, no_init_set=>no_init_set, 
		no_init_clr=>no_init_clr, no_init=>no_init); 		 
end generate;	


	-- message_end_set_part --
	
	mes1 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => last_block, q => mes1_reg );
	mes2 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => mes1_reg, q => mes2_reg );
	
	lb_wire <= '1' when mes1_reg='1' and mes2_reg='0' else '0';
		
	msg_end_set_wire <= lb_wire or msg_end_set_fsm1; 
	mes_reg : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => msg_end_set_wire, q => msg_end_set );
	
		sync_s <= '1';
	
	load_next_block <= ((not block_ready) or (block_ready_clr and sync_s)) and not load_block_invalid;
	block_ready_clr_sync 	<= block_ready_clr and sync_s;	 
	msg_end_clr_sync 		<= msg_end_clr and sync_s;
	output_write_set_sync 	<= output_write_set and sync_s;
	output_busy_set_sync 	<= output_busy_set and sync_s;
	
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

	
out_reg : if (arch=GROESTL_ARCH_PQ_QPPL) or (arch=GROESTL_ARCH_PQ_U2) or (arch=GROESTL_ARCH_PQ_UX) generate

	d01 : d_ff port map ( clk => io_clk, ena => '1', rst => '0', d => ein_wire, q => ein );
	d02 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => ena_ctr_wire, q => en_ctr );
	d03 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => wr_len_wire, q =>en_len );
	  eo <= eo_wire; 
	d04 : d_ff port map ( clk => io_clk, ena => '1', rst => '0', d => wr_c_wire, q =>wr_c );
	src_read <= src_read_wire;
	d05 : d_ff port map ( clk => io_clk, ena => '1', rst => '0', d => dst_write_wire, q =>dst_write );
 
 	d06 : d_ff port map ( clk => io_clk, ena => '1', rst => '0', d => finalization_wire, q =>finalization);	  
	d07 : d_ff port map ( clk => io_clk, ena => '1', rst => '0', d => init1_wire, q =>init1);	  
	d08 : d_ff port map ( clk => io_clk, ena => '1', rst => '0', d => init2_wire, q =>init2);	  
	d09 : d_ff port map ( clk => io_clk, ena => '1', rst => '0', d => init3_wire, q =>init3);	  
	d10 : d_ff port map ( clk => io_clk, ena => '1', rst => '0', d => load_ctr_wire, q =>load_ctr);	  
	d11 : d_ff port map ( clk => io_clk, ena => '1', rst => '0', d => p_mode_wire, q =>p_mode);	  
	d12 : d_ff port map ( clk => io_clk, ena => '1', rst => '0', d => wr_ctr_wire, q =>wr_ctr);	  
	d13 : d_ff port map ( clk => io_clk, ena => '1', rst => '0', d => wr_result_wire, q =>wr_result);	  
	d14 : d_ff port map ( clk => io_clk, ena => '1', rst => '0', d => wr_state_wire, q =>wr_state);	 
	d15 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => wr_seg_wire, q =>wr_seg );
 	d16 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => ls_rs_flag_wire, q =>ls_rs_flag);	
	d17 : d_ff port map ( clk => io_clk, ena => VCC, rst => GND, d => last_cycle_wire, q =>last_cycle);	
	
end generate;	
  
	
	sel_out <= sel_out_wire;
							
				
end struct;