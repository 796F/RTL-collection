-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;
use work.sha3_skein_package.all;

entity skein_fsm2 is  
	generic ( round_unrolled : integer := 4 );
	port (
		-- global
		clk : in std_logic;
		rst : in std_logic;
		
		-- datapath
		slast, sfinal, snb : out std_logic;
		er, etweak, lo, sf : out std_logic; 	

		-- control				   
			--fsm1 hand shake signals
		block_ready_clr : out std_logic;		
		msg_end_clr 	: out std_logic;
		
		block_ready		: in std_logic;
		msg_end 		: in std_logic;	
		final_block 	: in std_logic;		
			--fsm3 handshake signals
		output_write_set : out std_logic;
		output_busy_set  : out std_logic;
		output_busy		 : in  std_logic
	);							   
end skein_fsm2;

architecture beh of skein_fsm2 is  

	constant total_roundnr	: integer := 72;		
	constant roundnr 		: integer := total_roundnr/round_unrolled + 1;
	constant log2roundnr 	: integer := log2( roundnr ) + 1;
	constant log2roundnrzeros	: std_logic_vector(log2roundnr-1 downto 0) := (others => '0');
	
	type state_type is ( idle, process_data, finalization, output_data );
	signal cstate, nstate : state_type;
	
	signal round_s : std_logic_vector(log2roundnr-1 downto 0);
	signal ziroundnr, li, ei, er_s, snb_s : std_logic;
	signal output_data_s, block_load_s, rload_s, rload_s_init : std_logic;						 
	
	signal sfinal_s, slast_s : std_logic;
	signal final_block_done, set_final_block_done, clr_final_block_done : std_logic;
	--================
	
	type state_type2 is (first_block, wait_for_msg_end, wait_for_last_block);
	signal c2state, n2state : state_type2;
 
begin
	sr_final_block_done : sr_reg 
	port map ( rst => rst, clk => clk, set => set_final_block_done, clr => clr_final_block_done, output => final_block_done);
	
	etweak <= er_s;
	
	-- fsm2 counter
	proc_counter_gen : countern generic map ( N => log2roundnr ) port map ( clk => clk, rst => rst, load => li, en => ei, input => log2roundnrzeros, output => round_s);
	ziroundnr <= '1' when round_s = roundnr-1 else '0';	
	
	-- state process
	cstate_proc : process ( clk )
	begin
		if rising_edge( clk ) then 
			if rst = '1' then
				cstate <= idle;
			else
				cstate <= nstate;
			end if;
		end if;
	end process;
	
	nstate_proc : process ( cstate, msg_end, output_busy, block_ready, ziroundnr, final_block, final_block_done )
	begin
		case cstate is	 	
			when idle =>
				if ( block_ready = '1' ) then
					nstate <= process_data;
				else
					nstate <= idle;
				end if;	    
			when process_data =>
				if (( ziroundnr = '0' ) or (ziroundnr = '1' and final_block_done = '0' and block_ready = '1')) then				
					nstate <= process_data;					
				elsif (ziroundnr = '1' and  final_block_done = '1') then
					nstate <= finalization;
				else
					nstate <= idle;
				end if;				 
			when finalization =>
				if ziroundnr = '0' then
					nstate <= finalization;
				elsif (ziroundnr = '1' and output_busy = '1') then
					nstate <= output_data;
				elsif (ziroundnr = '1' and output_busy = '0' and block_ready = '1') then
					nstate <= process_data;
				else
					nstate <= idle;
				end if;
			when output_data =>
				if ( output_busy = '1' ) then
					nstate <= output_data;
				elsif (block_ready = '1') then
					nstate <= process_data;			  
				else 
					nstate <= idle;
				end if;				
		end case;
	end process;
	
	---- output logic
	output_data_s <= '1' when ((cstate = finalization and ziroundnr = '1' and output_busy = '0') or 
							  (cstate = output_data and output_busy = '0')) else '0';
	output_write_set	<= output_data_s;
	output_busy_set 	<= output_data_s;
	lo 					<= output_data_s;

	
	block_load_s		<= '1' when ((cstate = idle and block_ready = '1') or 
									(cstate = process_data and ziroundnr = '1' and final_block_done = '0' and block_ready = '1') or
									(cstate = finalization and ziroundnr = '1' and output_busy = '0' and block_ready = '1') or
									(cstate = output_data and block_ready = '1')) else '0';
	block_ready_clr <= block_load_s;

	rload_s <= '1' when ((cstate = process_data and ziroundnr = '0') or
						(cstate = finalization and ziroundnr = '0')) else '0';
	ei <= rload_s;
		
	rload_s_init <= '1' when (	(cstate = idle and block_ready = '1') or 
								(cstate = process_data and ziroundnr = '1' and final_block_done = '0' and block_ready = '1') or
							  	(cstate = finalization and ziroundnr = '1' and output_busy = '0' and block_ready = '1') or
								(cstate = output_data and output_busy = '0' and block_ready = '1')) else '0';
	li <= rload_s_init or sfinal_s;	
	
	er_s 		<= rload_s or rload_s_init or sfinal_s;
	er <= er_s;
	
	slast_s <= '1' when ((cstate = idle and block_ready = '1' and final_block = '1') or 
						 (cstate = process_data and ziroundnr = '1' and final_block = '1' and final_block_done = '0') or
						 (cstate = finalization and ziroundnr = '1' and output_busy = '0' and block_ready = '1' and final_block = '1') or
						 (cstate = output_data  and output_busy = '0' and block_ready = '1' and final_block = '1')) else '0';	
	slast <= slast_s;
	set_final_block_done <= slast_s;
	
	
	sfinal_s <= '1' when (cstate = process_data and ziroundnr = '1' and final_block_done = '1') else '0';
	msg_end_clr <= sfinal_s;	  
	clr_final_block_done <= sfinal_s;
	sfinal <= sfinal_s;	
	snb_s <= block_load_s or sfinal_s;		
	snb <= snb_s;
	-- =========================================
	
	-- small fsm
	small_fsm_proc : process ( clk )
	begin
		if rising_edge( clk ) then 
			if rst = '1' then
				c2state <= first_block;
			else
				c2state <= n2state;
			end if;
		end if;
	end process;					   
	
	small_fsm_transition : process ( c2state, block_ready, msg_end,output_data_s ) 
	begin
		case c2state is 	 
			when first_block =>
				if ( block_ready = '1' ) then
					n2state <= wait_for_msg_end;
				else
					n2state <= first_block;
				end if;
			when wait_for_msg_end =>
				if ( msg_end = '1' ) then
					n2state <= wait_for_last_block;
				else
					n2state <= wait_for_msg_end;
				end if;
			when wait_for_last_block =>
				if ( output_data_s = '0' ) then
					n2state <= wait_for_last_block;
				elsif ( block_ready = '1' ) then
					n2state <= wait_for_msg_end;
				else
					n2state <= first_block;
				end if;
		end case;
	end process;		
	
	sf <= '1' when ((c2state = first_block and block_ready = '1') or (c2state = wait_for_last_block and output_data_s = '1' and block_ready = '1')) else '0';
	
end beh;
		
		
		