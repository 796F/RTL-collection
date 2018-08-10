-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.sha3_simd_package.all;

entity simd_control_twoclk is		
	generic ( 	   			
		fr : integer := 2;
		b : integer := 512;
		w : integer := 64;
		h : integer := 256;
		feistels : integer := 4
	);
	port (					
		rst			: in std_logic;
		clk			: in std_logic;
		io_clk 		: in std_logic;
		
		-- datapath signals
			--fsm1
		ein, ec, lc, em			: out std_logic;		
		zclblock, final_segment 	: in std_logic;	  
		
			--ntt
		ctrl_ntt : out std_logic_vector(6 downto 0);			
		
			--fsm2
		er, lo, sf  :  out std_logic;
		eh, slr, sphi  : out std_logic;		
		ctrl_cp : out std_logic_vector(2 downto 0);
		sa  : out std_logic_vector(log2(feistels)-1 downto 0);
		spi : out std_logic_vector(1 downto 0);
			-- FSM3
		eout 			: out std_logic;
		
		-- fifo signals
		src_ready	: in std_logic;
		src_read	: out std_logic;
		dst_ready 	: in std_logic;
		dst_write	: out std_logic
	);				 
end simd_control_twoclk;

architecture struct of simd_control_twoclk is				   	 
	-- fsm1
	signal block_ready_set, msg_end_set, load_next_block : std_logic;	
	-- ntt 
		-- fsm1 communications
	signal block_ready_clr, msg_end_clr : std_logic; --out
	signal block_ready, msg_end : std_logic; --in	 
	signal msg_end_set_s, msg_end_set_delay : std_logic; -- handshake delay
		-- fsm2 comm						  
	signal ntt_ready_set, ntt_end_set : std_logic;
	signal ntt_ready, ntt_end : std_logic;
	-- fsm2							 
	
		-- ntt comm
	signal ntt_ready_clr, ntt_end_clr : std_logic; 
		-- fsm3 communications
	signal output_write_set, output_busy_set : std_logic; --out
	signal output_busy : std_logic; --in 
	
	-- fsm3		
	signal eo, lo_s : std_logic;
	signal output_write : std_logic; -- in
	signal output_write_clr, output_busy_clr : std_logic; --out	   
	

	-- sync sigs					
	signal block_ready_clr_sync, msg_end_clr_sync : std_logic;
	signal output_write_set_sync, output_busy_set_sync : std_logic;
	signal sync : std_logic;
	
	-- register output
	-- fsm1
	signal ein_s, ec_s, lc_s		:  std_logic;				
	-- ntt
	signal ctrl_ntt_s 				: std_logic_vector(6 downto 0);				
	--fsm2
	signal er_s, sf_s  				: std_logic;
	signal eh_s, slr_s, sphi_s  	: std_logic;		
	signal ctrl_cp_s 				: std_logic_vector(2 downto 0);
	signal sa_s						: std_logic_vector(log2(feistels)-1 downto 0);
	signal spi_s 					: std_logic_vector(1 downto 0);
	-- FSM3
	signal eout_s,	dst_write_s		:  std_logic;	  
	
begin
	
	fsm1_gen : entity work.simd_fsm1_twoclk(counter) 
		generic map ( mw => b, w => w )
		port map (
		io_clk => io_clk, rst => rst, 
		zclblock => zclblock, final_segment => final_segment, ein => ein, ec => ec, lc => lc, em => em,
		load_next_block => load_next_block, block_ready_set => block_ready_set, msg_end_set => msg_end_set_delay,
		src_ready => src_ready, src_read => src_read
	);																											
	
	
	
	ntt_ctrl_gen : entity work.simd_ntt_ctrl(beh) 
		generic map ( feistels => feistels )
		port map (
		clk => clk, rst => rst,			 
		ctrl_ntt => ctrl_ntt_s,
		block_ready_clr => block_ready_clr, msg_end_clr => msg_end_clr, block_ready => block_ready, msg_end => msg_end, 
		ntt_ready_set => ntt_ready_set, ntt_ready => ntt_ready, ntt_end_set => ntt_end_set
	);
	
	fsm2_gen : entity work.simd_fsm2(beh) 
		generic map ( feistels => feistels )
		port map (
		clk => clk, rst => rst, 
		er => er_s, lo => lo_s, sf => sf_s, slr => slr_s, eh => eh_s, ctrl_cp => ctrl_cp_s, sphi => sphi_s, sa => sa_s, spi => spi_s,
		ntt_ready_clr => ntt_ready_clr, ntt_ready => ntt_ready, ntt_end_clr => ntt_end_clr, ntt_end => ntt_end,
		output_write_set => output_write_set, output_busy_set => output_busy_set, output_busy => output_busy
	); 
	
	fsm3_gen : entity work.sha3_fsm3(beh) 
		generic map ( w => w , h => h )
		port map (
		clk => io_clk, rst => rst, 
		eo => eo, 
		output_write => output_write, output_write_clr => output_write_clr, output_busy_clr => output_busy_clr,
		dst_ready => dst_ready, dst_write => dst_write_s
	);	 
	
	sync_gen : entity work.sync_clock(struct) generic map ( fr => fr ) port map ( rst => rst, slow_clock => clk, fast_clock => io_clk, sync => sync );	
	load_next_block <= ((not block_ready) or (block_ready_clr and sync));
	block_ready_clr_sync 	<= block_ready_clr and sync;	 
	msg_end_clr_sync 		<= msg_end_clr and sync;				
	output_write_set_sync 	<= output_write_set and sync;
	output_busy_set_sync 	<= output_busy_set and sync;	
	eout_s <= eo or (lo_s and sync);	   
	
	process( clk )
	begin
		if rising_edge( clk ) then
			-- fsm 1
			-- ntt
			ctrl_ntt <= ctrl_ntt_s;
			--fsm2
			er <= er_s; 
			sf <= sf_s;
			eh <= eh_s; 
			slr <= slr_s; 
			sphi <= sphi_s;
			ctrl_cp <= ctrl_cp_s;
			sa <= sa_s; 
			spi <= spi_s;
			-- fsm3
			lo <= lo_s;		 
			dst_write <= dst_write_s;
		end if;		
	end process;
	
	process ( io_clk )
	begin
		if rising_edge ( io_clk ) then
			eout <= eout_s;	 				 
			
			
		end if;
	end process;
	
	-- HANDSHAKE UNITS
		-- make sure that the msg_end_set is active only at the subsequent clock of the slow clock
		-- while not holding FSM1 state transition back.
	sr_msg_end_set : sr_reg 
	port map ( rst => rst, clk => io_clk, set => msg_end_set_delay, clr => sync, output => msg_end_set_s);
	msg_end_set <= msg_end_set_s and sync;
	
	----
	sr_blk_ready : sr_reg 
	port map ( rst => rst, clk => io_clk, set => block_ready_set, clr => block_ready_clr_sync, output => block_ready);
	
	sr_msg_end : sr_reg 
	port map ( rst => rst, clk => io_clk, set => msg_end_set, clr => msg_end_clr_sync, output => msg_end);
	
	--- synchronization between ntt ctrl and fsm2 should be at the level of clk not, sync_clk
	sr_ntt_ready : sr_reg 
	port map ( rst => rst, clk => clk, set => ntt_ready_set, clr => ntt_ready_clr, output => ntt_ready);	
	
	sr_ntt_end : sr_reg 
	port map ( rst => rst, clk => clk, set => ntt_end_set, clr => ntt_end_clr, output => ntt_end);	
	---
	sr_output_write : sr_reg 
	port map ( rst => rst, clk => io_clk, set => output_write_set_sync, clr => output_write_clr, output => output_write );
	
	sr_output_busy : sr_reg  
	port map ( rst => rst, clk => io_clk, set => output_busy_set_sync, clr => output_busy_clr, output => output_busy );
end struct;