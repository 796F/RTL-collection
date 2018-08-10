-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.sha3_hamsi_package.all;

entity hamsi_control is		
	generic ( 		 
		w : integer := 32;
		mw : integer := 32;
		h : integer := 256;	 
		roundnr : integer := 3;
		roundnr_final : integer := 6;
		log2roundnr_final : integer := 3
	);
	port (					
		rst			: in std_logic;
		clk			: in std_logic;
		
		-- datapath signals
		--fsm1				   
		
		ein, ec, lc				: out std_logic;		
		final_segment, zc0		: in std_logic;		
		
			--fsm2
		er, sf  :  out std_logic;
		
		eh	: out std_logic;
		sfinal : out std_logic;
		sr_init : out std_logic;  
		roundc : out std_logic_vector(log2roundnr_final-1 downto 0);
		lo : out std_logic;
			-- FSM3
		eout 			: out std_logic;			
		
		-- fifo signals
		src_ready	: in std_logic;
		src_read	: out std_logic;
		dst_ready 	: in std_logic;
		dst_write	: out std_logic
	);				 
end hamsi_control;

architecture struct of hamsi_control is				   	 
	-- fsm1
	signal block_ready_set, msg_end_set, load_next_block : std_logic;	  
		-- regout
	signal ein_s, ec_s, lc_s : std_logic;
	-- fsm2						 
		-- fsm1 communications
	signal block_ready_clr, msg_end_clr : std_logic; --out
	signal block_ready, msg_end, last_block : std_logic; --in
		-- fsm2 communications
	signal output_write_set, output_busy_set : std_logic; --out
	signal output_busy : std_logic; --in 					 
		--reg out
	signal er_s, sf_s, eh_s, sfinal_s, sr_init_s, lo_s : std_logic;
	signal roundc_s : std_logic_vector(log2roundnr_final-1 downto 0);
	
	-- fsm3										
	signal output_write : std_logic; -- in
	signal output_write_clr, output_busy_clr : std_logic; --out	 
	
	signal eo, eout_s, dst_write_s : std_logic;
	
	-- sync sig
	signal block_ready_clr_sync, msg_end_clr_sync : std_logic;
	signal output_write_set_sync, output_busy_set_sync : std_logic;	 
	
	constant log2roundnr_finalzeros : std_logic_vector(log2roundnr_final-1 downto 0) := (others => '0');
begin
	
	fsm1_gen : entity work.hamsi_fsm1(nocounter) 
		generic map ( w => w, mw => mw )
		port map (
		clk => clk, rst => rst, 
		zc0 => zc0, ein => ein_s, ec => ec_s, lc => lc_s,final_segment => final_segment,  
		load_next_block => load_next_block, block_ready_set => block_ready_set, msg_end_set => msg_end_set,
		src_ready => src_ready, src_read => src_read, last_block => last_block
	);	 
	
	fsm2_gen : entity work.hamsi_fsm2(beh) 
		generic map ( roundnr => roundnr, roundnr_final =>	roundnr_final, log2roundnr_final =>	log2roundnr_final)
		port map (
		clk => clk, rst => rst, 
		er => er_s,  lo => lo_s, sf => sf_s, eh => eh_s, sfinal => sfinal_s, sr_init => sr_init_s, roundc => roundc_s,
		block_ready_clr => block_ready_clr, msg_end_clr => msg_end_clr, block_ready => block_ready, msg_end => msg_end, last_block => last_block, 
		output_write_set => output_write_set, output_busy_set => output_busy_set, output_busy => output_busy
	); 
	
	fsm3_gen : entity work.sha3_fsm3(beh) 
	generic map ( h => h, w => w )
	port map (
		clk => clk, rst => rst, 
		eo => eo, 
		output_write => output_write, output_write_clr => output_write_clr, output_busy_clr => output_busy_clr,
		dst_ready => dst_ready, dst_write => dst_write_s
	);	 
					   			   
	load_next_block <= (not block_ready);
	block_ready_clr_sync 	<= block_ready_clr;	 
	msg_end_clr_sync 		<= msg_end_clr;
	output_write_set_sync 	<= output_write_set;
	output_busy_set_sync 	<= output_busy_set;
	
	
	-- DATAPATH OUTPUT REGISTERS
		--fsm1 
	--d11 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => ein_s, q => ein );	
--	d12 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => ec_s, q => ec );	
--	d13 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => lc_s, q => lc );		 
--	
	ein <= ein_s;
	ec <= ec_s;
	lc <= lc_s;
	
		--fsm2
	d20 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => sf_s, q => sf );	
	d21 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => er_s, q => er );	
	d22 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => lo_s, q => lo );	
	d23 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => sfinal_s, q => sfinal );	
	d24 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => sr_init_s, q => sr_init );	
	d25 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => eh_s, q => eh );	 
	r26 : regn generic map ( N => log2roundnr_final, init => log2roundnr_finalzeros ) port map ( clk => clk, rst => '0', en => '1', input => roundc_s, output => roundc ); 
		--fsm3 
	eout_s <= eo or lo_s; 
	d31 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => eout_s, q => eout );
	d32 : d_ff port map ( clk => clk, ena => '1', rst => '0', d => dst_write_s, q => dst_write );
	
		
	
	sr_blk_ready : sr_reg 
	port map ( rst => rst, clk => clk, set => block_ready_set, clr => block_ready_clr_sync, output => block_ready);
	
	sr_msg_end : sr_reg 
	port map ( rst => rst, clk => clk, set => msg_end_set, clr => msg_end_clr_sync, output => msg_end);
	
	sr_output_write : sr_reg 
	port map ( rst => rst, clk => clk, set => output_write_set_sync, clr => output_write_clr, output => output_write );
	
	sr_output_busy : sr_reg  
	port map ( rst => rst, clk => clk, set => output_busy_set_sync, clr => output_busy_clr, output => output_busy );

end struct;