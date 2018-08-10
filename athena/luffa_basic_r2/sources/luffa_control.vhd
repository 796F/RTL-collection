-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

----------------------------------------------------------
------------ BASIC ARCHITECTURE 	----------------------
----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.sha3_luffa_package.all;

entity luffa_control is		
	generic ( 	  				  		
		h : integer := HASH_SIZE_256;
		w : integer := 64;	 
		round_length : integer := 3		
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
		sstep_init, sfinal  : out std_logic;
		round : out std_logic_vector(round_length-1 downto 0);
			-- FSM3
		eout 			: out std_logic;
		-- fifo signals
		src_ready	: in std_logic;
		src_read	: out std_logic;
		dst_ready 	: in std_logic;
		dst_write	: out std_logic
	);				 
end luffa_control;

architecture struct of luffa_control is				   	 
	-- fsm1
	signal block_ready_set, msg_end_set, load_next_block : std_logic;	
	signal ein_s, ec_s, lc_s : std_logic;
	-- fsm2						 
		-- fsm1 communications
	signal block_ready_clr, msg_end_clr : std_logic; --out
	signal block_ready, msg_end : std_logic; --in
		-- fsm2 communications					
	signal output_write_set, output_busy_set : std_logic; --out
	signal output_busy : std_logic; --in 		  
	
	signal er_s, lo_s, sf_s, sstep_init_s, sfinal_s, eo_fsm2_s : std_logic;   
	signal round_s : std_logic_vector(round_length-1 downto 0);
	
	-- fsm3		
	signal eo, dst_write_s, eout_s : std_logic;
	signal output_write : std_logic; -- in
	signal output_write_clr, output_busy_clr : std_logic; --out	   
	
	-- sync sigs						
	signal block_ready_clr_sync, msg_end_clr_sync : std_logic;
	signal output_write_set_sync, output_busy_set_sync : std_logic;
begin
	
	fsm1_gen : entity work.luffa_fsm1(nocounter)
	generic map ( w => w )
	port map (
		clk => clk, rst => rst, 
		zc0 => zc0, final_segment => final_segment, ein => ein_s, ec => ec_s, lc => lc_s,
		load_next_block => load_next_block, block_ready_set => block_ready_set, msg_end_set => msg_end_set,
		src_ready => src_ready, src_read => src_read
	);	 
	
	fsm2_gen : entity work.luffa_fsm2(beh) 
		generic map ( h => h, round_length => round_length )	
		port map (
		clk => clk, rst => rst, 
		er => er_s, lo => lo_s, sf => sf_s, sfinal => sfinal_s, sstep_init => sstep_init_s, round => round_s, eo_fsm2 => eo_fsm2_s,
		block_ready_clr => block_ready_clr, msg_end_clr => msg_end_clr, block_ready => block_ready, msg_end => msg_end,
		output_write_set => output_write_set, output_busy_set => output_busy_set, output_busy => output_busy
	); 
	
	-- fixed output hash size as 256 bits
	--	a 512-bit hash output size is equal to 2 writes of 256-bit hash outputsize
	fsm3_gen : entity work.sha3_fsm3(beh) 
	generic map ( h => HASH_SIZE_256, w => w )	 
	port map (
		clk => clk, rst => rst, 
		eo => eo, 
		output_write => output_write, output_write_clr => output_write_clr, output_busy_clr => output_busy_clr,
		dst_ready => dst_ready, dst_write => dst_write_s
	);	 
	
	load_next_block <= ((not block_ready));
	block_ready_clr_sync 	<= block_ready_clr;	 
	msg_end_clr_sync 		<= msg_end_clr ;
	output_write_set_sync 	<= output_write_set;
	output_busy_set_sync 	<= output_busy_set;
	eout_s <= eo or eo_fsm2_s; 			

	-- FSM1
	lc <= lc_s;
	ein <= ein_s;
	ec <= ec_s;		 
				
	-- DATAPATH OUTPUT REGISTERS														
	reg_control : process ( clk )
	begin
		if rising_edge ( clk ) then
			-- fsm1
			
			
			-- fsm2
			sf <= sf_s;
			er <= er_s;
			lo <= lo_s;
			sfinal <= sfinal_s;
			sstep_init <= sstep_init_s;
			round <= round_s;
			-- fsm3 
			eout <= eout_s;
			dst_write <= dst_write_s;
		end if;
	end process;
		--fsm3 
	

	
	sr_blk_ready : sr_reg 
	port map ( rst => rst, clk => clk, set => block_ready_set, clr => block_ready_clr_sync, output => block_ready);
	
	sr_msg_end : sr_reg 
	port map ( rst => rst, clk => clk, set => msg_end_set, clr => msg_end_clr_sync, output => msg_end);
	
	sr_output_write : sr_reg 
	port map ( rst => rst, clk => clk, set => output_write_set_sync, clr => output_write_clr, output => output_write );
	
	sr_output_busy : sr_reg  
	port map ( rst => rst, clk => clk, set => output_busy_set_sync, clr => output_busy_clr, output => output_busy );

end struct;



