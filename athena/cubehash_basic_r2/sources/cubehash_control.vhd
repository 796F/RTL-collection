-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.sha3_cubehash_package.all;

entity cubehash_control is		
	generic ( 		   
		w : integer := 64;
		h : integer := HASH_SIZE_256;		 
		mw : integer := 256 
	);
	port (					
		rst			: in std_logic;
		clk			: in std_logic;
		
		-- datapath signals
			--fsm1
		ein, ec, lc			: out std_logic;		
		zc0, final_segment : in std_logic;		
		
			--fsm2
		er, lo, sf  :  out std_logic;
		sm, sfinal  : out std_logic;
		
			-- FSM3
		eout 			: out std_logic;
		
		-- fifo signals
		src_ready	: in std_logic;
		src_read	: out std_logic;
		dst_ready 	: in std_logic;
		dst_write	: out std_logic
	);				 
end cubehash_control;

architecture struct of cubehash_control is				   	 
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
	signal eo : std_logic;
	signal output_write : std_logic; -- in
	signal output_write_clr, output_busy_clr : std_logic; --out	   
	
	-- REGISTERED OUTPUTS datapath
		-- fsm1	
		-- fsm2
	signal er_s, lo_s, sf_s, sm_s, sfinal_s  :  std_logic;
		-- fsm3
	signal eout_s, dst_write_s : std_logic;		
	
	
	-- sync sigs					
	signal block_ready_clr_sync, msg_end_clr_sync : std_logic;
	signal output_write_set_sync, output_busy_set_sync : std_logic;				 
	signal output_write_sync : std_logic;
begin
	
	fsm1_gen : entity work.cubehash_fsm1(nocounter) 
	generic map ( mw => mw, w => w )
	port map (
		clk => clk, rst => rst, 
		zc0 => zc0, final_segment => final_segment, ein => ein, ec => ec, lc => lc, 
		load_next_block => load_next_block, block_ready_set => block_ready_set, msg_end_set => msg_end_set,
		src_ready => src_ready, src_read => src_read
	);	 
	
	fsm2_gen : entity work.cubehash_fsm2(beh)
	port map (
		clk => clk, rst => rst, 
		er => er_s, lo => lo_s, sf => sf_s, sfinal => sfinal_s, sm => sm_s,
		block_ready_clr => block_ready_clr, msg_end_clr => msg_end_clr, block_ready => block_ready, msg_end => msg_end,
		output_write_set => output_write_set, output_busy_set => output_busy_set, output_busy => output_busy
	); 
	
	fsm3_gen : entity work.sha3_fsm3(beh) 
	generic map ( h => h, w => w )
	port map (
		clk => clk, rst => rst, 
		eo => eo, 
		output_write => output_write_sync, output_write_clr => output_write_clr, output_busy_clr => output_busy_clr,
		dst_ready => dst_ready, dst_write => dst_write_s
	);	 

	load_next_block <= (not block_ready);
	block_ready_clr_sync 	<= block_ready_clr;	 
	msg_end_clr_sync 		<= msg_end_clr;
	output_write_set_sync 	<= output_write_set;
	output_busy_set_sync 	<= output_busy_set;
	output_write_sync <= output_write;
	eout_s <= eo or lo_s;	

	
	-- REGISTERED OUTPUTS
		--fsm1
	    --fsm2
	d21 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => er_s, q => er );	
	d22 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => lo_s, q => lo );	
	d23 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => sf_s, q => sf );	
	d24 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => sm_s, q => sm );	
	d25 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => sfinal_s, q => sfinal );	
		--fsm3
	d31 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => eout_s, q => eout );
	d32 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => dst_write_s, q => dst_write );
	
	
	-- HANDSHAKE UNITS
	sr_blk_ready : sr_reg 
	port map ( rst => rst, clk => clk, set => block_ready_set, clr => block_ready_clr_sync, output => block_ready);
	
	sr_msg_end : sr_reg 
	port map ( rst => rst, clk => clk, set => msg_end_set, clr => msg_end_clr_sync, output => msg_end);
	
	sr_output_write : sr_reg 
	port map ( rst => rst, clk => clk, set => output_write_set_sync, clr => output_write_clr, output => output_write );
	
	sr_output_busy : sr_reg  
	port map ( rst => rst, clk => clk, set => output_busy_set_sync, clr => output_busy_clr, output => output_busy );

end struct;