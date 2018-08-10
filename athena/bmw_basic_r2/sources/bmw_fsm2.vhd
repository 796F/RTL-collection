-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_arith.all;
use work.sha3_pkg.all;
use work.sha3_bmw_package.all;

entity bmw_fsm2 is 
	port (
		-- global
		clk : in std_logic;
		rst : in std_logic;
		
		-- datapath
		er : out std_logic;	
		sf : out std_logic;
		sl : out std_logic;
		eh : out std_logic;
		lo : out std_logic;	
		
		-- control				   
			--fsm1 hand shake signals
		block_ready_clr : out std_logic;		
		msg_end_clr 	: out std_logic;
		
		block_ready		: in std_logic;
		msg_end 		: in std_logic;	
				
			--fsm3 handshake signals
		output_write_set : out std_logic;
		output_busy_set  : out std_logic;
		output_busy		 : in  std_logic
	);							   
end bmw_fsm2;

architecture beh of bmw_fsm2 is
   type state_type is ( wait_for_sync, idle, process_data, finalization, output_data );
   signal cstate, nstate : state_type;
   
   signal output_data_sigs, load_sigs1 : std_logic;						 
   --================
   
  type state_type2 is (first_block, wait_for_msg_end, wait_for_last_block);
   signal c2state, n2state : state_type2;
   
   
   
begin
	-- state process
	cstate_proc : process ( clk )
	begin
		if rising_edge( clk ) then 
			if rst = '1' then
				cstate <= wait_for_sync;
			else
				cstate <= nstate;
			end if;
		end if;
	end process;
	
	nstate_proc : process ( cstate, msg_end, output_busy, block_ready )
	begin
		case cstate is	 
			when wait_for_sync =>
				nstate <= idle;
			when idle =>
				if ( block_ready = '1' ) then
					nstate <= process_data;
				else
					nstate <= idle;
				end if;				
			when process_data =>
				if (msg_end = '0' and block_ready = '1') then
					nstate <= process_data;
				elsif (msg_end = '1') then
					nstate <= finalization;
				else
					nstate <= idle;
				end if;	
			when finalization =>
				if (output_busy = '0' and block_ready = '0') then
					nstate <= idle;								 
				elsif (output_busy = '0' and block_ready = '1') then
					nstate <= process_data;
				else
					nstate <= output_data;
				end if;
			when output_data =>
				if ( output_busy = '1' ) then
					nstate <= output_data;
				else
					nstate <= idle;
				end if;				
		end case;
	end process;
	
	
	---- output logic
	
	output_data_sigs <= '1' when ((cstate = finalization and output_busy = '0') or (cstate = output_data and output_busy = '0')) else '0';
	output_write_set	<= output_data_sigs;
	output_busy_set 	<= output_data_sigs;
	lo 					<= output_data_sigs;

	load_sigs1 <= '1' when ((cstate = idle and block_ready = '1' ) or 
							(cstate = process_data and msg_end = '0' and block_ready = '1') or
							(cstate = finalization and output_busy = '0' and block_ready = '1')) else '0';	
	block_ready_clr <= load_sigs1;
	er <= '1' when (load_sigs1 = '1' or cstate = process_data) else '0';
	
	eh <= '1' when (cstate = process_data) else '0';
	sl <= '1' when (cstate = process_data and msg_end = '1') else '0';
	msg_end_clr <= '1' when (cstate = finalization) else '0';
	
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
	
	small_fsm_transition : process ( c2state, block_ready, msg_end, output_data_sigs ) 
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
				if ( output_data_sigs = '0' ) then
					n2state <= wait_for_last_block;
				elsif ( block_ready = '1' ) then
					n2state <= wait_for_msg_end;
				else
					n2state <= first_block;
				end if;
		end case;
	end process;		
	
	sf <= '1' when ((c2state = first_block and block_ready = '1') or (c2state = wait_for_last_block and output_data_sigs = '1' and block_ready = '1')) else '0';
	
	
end beh;
		
		
		