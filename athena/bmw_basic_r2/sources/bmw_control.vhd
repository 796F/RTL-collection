-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.sha3_bmw_package.all;

entity bmw_control is		
	generic ( 								
		w : integer := 64;	 
		h : integer := 256;		 
		fr : integer := 8
	);
	port (					
		rst			: in std_logic;
		clk			: in std_logic;
		io_clk 		: in std_logic;
		
		-- datapath signals
			--fsm1
		ec			: out std_logic;
		lc			: out std_logic;
		ein			: out std_logic;
		em 			: out std_logic;
		final_segment, zc0	: in std_logic;
		
			--fsm2
		sf   		: out std_logic;
		sl			: out std_logic;
		lo			: out std_logic;
		erprime		: out std_logic;   
		ehprime		: out std_logic;
			-- FSM3
		eout 			: out std_logic;			
		
		-- fifo signals
		src_ready	: in std_logic;
		src_read	: out std_logic;
		dst_ready 	: in std_logic;
		dst_write	: out std_logic
	);				 
end bmw_control;

architecture struct of bmw_control is	
	constant mw : integer := get_b ( h );
	-- fsm1
	signal block_ready_set, msg_end_set, load_next_block : std_logic;
	
	-- fsm2						
		-- fsm1 communications
	signal block_ready_clr, msg_end_clr : std_logic; --out
	signal block_ready, msg_end : std_logic; --in	
		-- fsm2 communications
	signal output_write_set, output_busy_set : std_logic; --out
	signal output_busy : std_logic; --in 
	
	-- fsm3	
	signal er_s, sl_s, sf_s, eh_s : std_logic;
	signal eo, lo_s, output_write : std_logic; -- in
	signal output_write_clr, output_busy_clr : std_logic; --out	   
	
	-- sync sigs
	signal sync : std_logic;
	signal block_ready_clr_sync, msg_end_clr_sync : std_logic;
	signal output_write_set_sync, output_busy_set_sync : std_logic;
begin
	
	fsm1_gen : entity work.bmw_fsm1(nocounter) 
	generic map ( mw => mw, w => w )	
	port map (
		io_clk => io_clk, rst => rst, 
		zc0 => zc0, final_segment => final_segment, ein => ein, lc => lc, ec => ec, em => em,
		load_next_block => load_next_block, block_ready_set => block_ready_set, msg_end_set => msg_end_set,
		src_ready => src_ready, src_read => src_read
	);	 
	
	fsm2_gen : entity work.bmw_fsm2(beh) port map (
		clk => clk, rst => rst, 
		er => er_s, eh => eh_s, sf => sf_s, sl => sl_s, lo => lo_s, 
		block_ready_clr => block_ready_clr, msg_end_clr => msg_end_clr, block_ready => block_ready, msg_end => msg_end,
		output_write_set => output_write_set, output_busy_set => output_busy_set, output_busy => output_busy
	); 
	
	fsm3_gen : entity work.sha3_fsm3(beh) 
	generic map ( h => h, w => w )	
	port map (
		clk => io_clk, rst => rst, 
		eo => eo, 
		output_write => output_write, output_write_clr => output_write_clr, output_busy_clr => output_busy_clr,
		dst_ready => dst_ready, dst_write => dst_write
	);	 
	
	sync_gen : entity work.sync_clock(struct) generic map ( fr => fr ) port map ( rst => rst, slow_clock => clk, fast_clock => io_clk, sync => sync );	
	
	erprime <= er_s or sl_s;	
	ehprime <= sf_s or eh_s or sl_s;
	eout <= eo or (lo_s and sync);
	sl <= sl_s;
	lo <= lo_s;					
	sf <= sf_s;
	
	load_next_block <= ((not block_ready) or (block_ready_clr and sync));
	block_ready_clr_sync 	<= block_ready_clr and sync;	 
	msg_end_clr_sync 		<= msg_end_clr and sync;
	output_write_set_sync 	<= output_write_set and sync;
	output_busy_set_sync 	<= output_busy_set and sync;	
	
	sr_blk_ready : sr_reg 
	port map ( rst => rst, clk => io_clk, set => block_ready_set, clr => block_ready_clr_sync, output => block_ready);
	
	sr_msg_end : sr_reg 
	port map ( rst => rst, clk => io_clk, set => msg_end_set, clr => msg_end_clr_sync, output => msg_end);
	
	sr_output_write : sr_reg 
	port map ( rst => rst, clk => io_clk, set => output_write_set_sync, clr => output_write_clr, output => output_write );
	
	sr_output_busy : sr_reg  
	port map ( rst => rst, clk => io_clk, set => output_busy_set_sync, clr => output_busy_clr, output => output_busy );
																																		 
end struct;