-- =========================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =========================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.sha3_blake_package.all;

entity blake_control is		
	generic ( 	 	   		
		iw : integer := 32;
		b : integer := 512;
		h : integer := 256;
		w : integer := 64
	);
	port (					
		rst			: in std_logic;
		clk			: in std_logic;		
		
		-- datapath signals
		--fsm1		   
		extra_block : in std_logic;		
		ein, ec, lc, lc2		: out std_logic;		
		zclblock, zcblock		: in std_logic;
		dt, eth, etl		: out std_logic;
		final_segment 			: in std_logic;
		lm : out std_logic;
		
			--fsm2
		er, em, lo, sf, slr : out std_logic;
		round 		: out std_logic_vector(4 downto 0);
		
			-- FSM3
		eo 			: out std_logic;			
		
		-- fifo signals
		src_ready	: in std_logic;
		src_read	: out std_logic;
		dst_ready 	: in std_logic;
		dst_write	: out std_logic
	);				 
end blake_control;

architecture struct of blake_control is				   	 
	-- fsm1
	signal block_ready_set, msg_end_set, load_next_block : std_logic;	
	-- fsm2						
		-- fsm1 communications		
	signal block_ready_clr, msg_end_clr, computing : std_logic; --out
	signal block_ready, msg_end : std_logic; --in
		-- fsm2 communications
	signal output_write_set, output_busy_set : std_logic; --out
	signal output_busy : std_logic; --in 
	
	-- fsm3										
	signal output_write : std_logic; -- in
	signal output_write_clr, output_busy_clr : std_logic; --out	   
							
	signal block_ready_clr_sync, msg_end_clr_sync : std_logic;
	signal output_write_set_sync, output_busy_set_sync : std_logic;
begin
	
	fsm1_gen : entity work.blake_fsm1(counter)
		generic map (b => b,  w => w, h => h )
		port map (
		clk => clk, rst => rst, 
		final_segment => final_segment, zclblock => zclblock, zcblock => zcblock, ein => ein, ec => ec, lc => lc, eth => eth, dt => dt, etl => etl,		   
			extra_block => extra_block, lc2 => lc2, lm => lm,
		load_next_block => load_next_block, block_ready_set => block_ready_set, msg_end_set => msg_end_set, computing => computing,
		src_ready => src_ready, src_read => src_read 
	);	 
	
	fsm2_gen : entity work.blake_fsm2(beh) 
		generic map ( h => h )
		port map (
		clk => clk, rst => rst, 
		er => er, em => em, lo => lo, sf => sf, slr => slr, round => round,
		block_ready_clr => block_ready_clr, msg_end_clr => msg_end_clr, block_ready => block_ready, msg_end => msg_end, computing => computing,
		output_write_set => output_write_set, output_busy_set => output_busy_set, output_busy => output_busy
	); 
	
	fsm3_gen : entity work.sha3_fsm3(beh)
		generic map ( h => h, w => w )
		port map (
		clk => clk, rst => rst, 
		eo => eo, 
		output_write => output_write, output_write_clr => output_write_clr, output_busy_clr => output_busy_clr,
		dst_ready => dst_ready, dst_write => dst_write
	);	 
	
	
	load_next_block <= (not block_ready) or block_ready_clr;
	block_ready_clr_sync 	<= block_ready_clr;
	msg_end_clr_sync 		<= msg_end_clr;
	output_write_set_sync 	<= output_write_set;
	output_busy_set_sync 	<= output_busy_set;
	
	sr_blk_ready : sr_reg 
	port map ( rst => rst, clk => clk, set => block_ready_set, clr => block_ready_clr_sync, output => block_ready);
	
	sr_msg_end : sr_reg 
	port map ( rst => rst, clk => clk, set => msg_end_set, clr => msg_end_clr_sync, output => msg_end);
	
	sr_output_write : sr_reg 
	port map ( rst => rst, clk => clk, set => output_write_set_sync, clr => output_write_clr, output => output_write );
	
	sr_output_busy : sr_reg  
	port map ( rst => rst, clk => clk, set => output_busy_set_sync, clr => output_busy_clr, output => output_busy );

end struct;