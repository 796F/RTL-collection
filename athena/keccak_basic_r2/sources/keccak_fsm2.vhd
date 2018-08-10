-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;
use work.keccak_pkg.all;

-- keccak fsm2 is responsible for keccak computation processing 

entity keccak_fsm2 is  
generic (hs:integer:=HASH_SIZE_256);	
	port (
		clk 					: in std_logic;
		rst 					: in std_logic;
		ena_ctr 				: out std_logic;
		wr_state				: out std_logic;
		sel_xor 				: out std_logic;
		sel_final				: out std_logic;
		ld_rdctr				: out std_logic;
		en_rdctr 				: out std_logic; 
		last_block				: in std_logic;  
		wfl2					: in std_logic;
		block_ready_clr 		: out std_logic;		
		msg_end_clr 			: out std_logic;
		block_ready				: in std_logic;
		msg_end 				: in std_logic;
		ls_rs_flag				: in std_logic; 
		no_init_set				: out std_logic;
		no_init_clr				: out std_logic;	
		no_init					: in std_logic;
		output_write_set 		: out std_logic;
		output_busy_set  		: out std_logic;
		output_busy		 		: in  std_logic);							   
end keccak_fsm2;

architecture beh of keccak_fsm2 is
   type state_type is ( wait_for_sync, idle,  process_data, finalization,  output_data );
   signal cstate, nstate : state_type;   
   signal round : std_logic_vector(log2roundnr_final256-1 downto 0);
   signal ziroundnr, ziroundnr_final, li, ei : std_logic;
   signal output_data_s, block_load_s, rload_s, rload_s_init : std_logic;						 
   type state_type2 is (first_block, wait_for_msg_end, wait_for_last_block);
   signal c2state, n2state : state_type2;   
   constant zero :std_logic_vector(log2roundnr_final256-1 downto 0):=(others => '0');
begin	

	-- round's counter 
	proc_counter_gen : countern generic map ( N => log2roundnr_final256 ) port map ( clk => clk, rst => rst, load => li, en => ei, input => zero, output => round);

		
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
	
	nstate_proc : process ( cstate, msg_end, output_busy, block_ready, ziroundnr_final, ziroundnr, last_block, ls_rs_flag )
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
				
				if (( ziroundnr = '0' ) or (ziroundnr = '1' and msg_end = '0' and block_ready = '1')) then				
					nstate <= process_data;					
				elsif (ziroundnr = '1' and msg_end = '1' and (last_block='1')) then
					nstate <= finalization;
				elsif (last_block='1')  and (ls_rs_flag='1') then
					nstate <= finalization;	
				elsif (ls_rs_flag='0') then
					nstate <= idle;					
				else	
					nstate <= idle;
				end if;	
				
			when finalization =>
				if ziroundnr_final = '0' then
					nstate <= finalization;
				elsif (ziroundnr_final = '1' and output_busy = '1') then
					nstate <= output_data;
				elsif (ziroundnr_final = '1' and output_busy = '0' and block_ready = '1') then
					nstate <= idle; 
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
				
			when others => 
				nstate <= idle; 
		end case;
	end process;
	
	
	output_data_s <= '1' when ((cstate = finalization and ziroundnr_final = '1' and output_busy = '0') or 
						(cstate = output_data and output_busy = '0')) else '0';	 
		
	output_write_set	<= output_data_s;
	output_busy_set 	<= output_data_s;
	
bl_hs256: if hs=HASH_SIZE_256 generate							  
	block_load_s <= '1' when  ((round = "00010110") and wfl2='0') or ((round = "00000110") and wfl2='1') else '0';							  
end generate;		

bl_hs512: if hs=HASH_SIZE_512 generate							  
	block_load_s <= '1' when  ((round = "00010110") and wfl2='0') or ((round = "00001110") and wfl2='1') else '0';							  
end generate;		

		
	block_ready_clr <= block_load_s;
		
	rload_s <= '1' when ((cstate = process_data and ziroundnr = '0') or
						(cstate = finalization and ziroundnr_final = '0')) else '0';
	ei <= rload_s or rload_s_init;
		
	rload_s_init <= '1' when ((cstate = idle and block_ready = '1') or 
							  (cstate = process_data and ziroundnr = '1') or
							  (cstate = finalization and ziroundnr_final = '1')) else '0';
	li <= rload_s_init;	
	
ctr_hs256: if hs=HASH_SIZE_256 generate	
	ena_ctr <= '1' when	 (round="010000") else '0';
end generate;

ctr_hs512: if hs=HASH_SIZE_512 generate	
	ena_ctr <= '1' when	 (round="010000") else '0';
end generate;
		
		
	msg_end_clr <= '1' when (cstate = finalization and ziroundnr_final = '1') else '0';
	
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
	
	small_fsm_transition : process ( c2state, block_ready, msg_end, output_data_s ) 
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
	
	-- output signals from fsm2
	ziroundnr <= '1' when round = roundnr256-1 else '0';
	ziroundnr_final  <= '1' when round = roundnr_final-1 else '0';	   
				
	wr_state <= '1' when 	 (cstate=process_data) else '0';								
																
	sel_xor <= '1' when (round="00000000") and (cstate=process_data) and (no_init='1')else '0';	
	
		
	sel_final	<= '1' when (round="00000000") and (cstate=process_data) else '0';			

	ld_rdctr<= '1' when ((round="00000000") ) and (cstate=process_data) else '0';				

	en_rdctr <= '1' when (round>"00000000") and (round<"00011000") and(cstate=process_data) else '0';				 
				
	no_init_set <=  '1' when (round="010101") else '0';
	no_init_clr <= 	'1' when (cstate = finalization)else '0';

end beh;
		
		
