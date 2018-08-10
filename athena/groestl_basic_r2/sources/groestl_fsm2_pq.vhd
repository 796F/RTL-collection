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

-- Groestl fsm2 is responsible for Groestl computation processing 
-- Possible generics values: 
-- hs = {HASH_SIZE_256, HASH_SIZE_512} 

entity groestl_fsm2_pq is
	generic (hs : integer:=HASH_SIZE_256);
	port (
		clk 					: in std_logic;
		rst 					: in std_logic;
		bf						: out std_logic;	
		ena_ctr 				: out std_logic;
		first_block_in			: in std_logic; 
		underflow				: in std_logic;  
		wfl2					: in std_logic;		
		last_block				: in std_logic;  
		final					: out std_logic;
		init1					: out std_logic;
		init2					: out std_logic;
		init3					: out std_logic;  
		last_cycle				:out std_logic;
		load_ctr				: out std_logic;
		p_mode					: out std_logic;
		wr_ctr					: out std_logic;
		wr_result				: out std_logic;
		wr_state				: out std_logic;
		done					: out std_logic;
		load_block_invalid		: out std_logic;
		block_ready_clr 		: out std_logic;		
		msg_end_clr 			: out std_logic;
		block_ready				: in std_logic;
		msg_end 				: in std_logic;	  
		ls_rs_flag				:in std_logic; 
		no_init_set				: out std_logic;
		no_init_clr				: out std_logic;	
		no_init					: in std_logic;
		output_write_set 		: out std_logic;
		output_busy_set  		: out std_logic;
		output_busy		 		: in  std_logic);							   
end groestl_fsm2_pq;

-- architecture for 256 version
architecture fx2_256 of groestl_fsm2_pq is
   type state_type is ( wait_for_sync, idle,  process_data, finalization, finalization_delay, finalization_delay2, output_data );
   signal cstate, nstate : state_type; 
   signal round : std_logic_vector(pq_log2roundnr_final256-1 downto 0);
   signal ziroundnr, ziroundnr_final, li, ei : std_logic;
   signal output_data_s, block_load_s, rload_s, rload_s_init : std_logic;						 
   type state_type2 is (first_block, wait_for_msg_end, wait_for_last_block);
   signal c2state, n2state : state_type2;
   constant zero :std_logic_vector(pq_log2roundnr_final256-1 downto 0):=(others => '0');
   signal block_load_s_wire : std_logic;

   begin	
	-- fsm2 counter	 
	proc_counter_gen : countern generic map ( N => pq_log2roundnr_final256 ) port map ( clk => clk, rst => '0', load => li, en => ei, input => zero, output => round);
		
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
	-- transitions states proces
	nstate_proc : process ( cstate, msg_end, output_busy, block_ready, ziroundnr_final, ziroundnr, underflow, last_block )
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
				elsif (ziroundnr = '1' and msg_end = '1' and ((underflow='1') or (last_block='1'))) then
					nstate <= finalization;
				elsif (underflow='1') or (last_block='1')then
					nstate <= finalization;

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
	
							  
	block_ready_clr <= block_load_s;

		
	rload_s <= '1' when ((cstate = process_data and ziroundnr = '0') or
						(cstate = finalization and ziroundnr_final = '0')) else '0';
	ei <= rload_s or rload_s_init;
		
	rload_s_init <= '1' when ((cstate = idle and block_ready = '1') or 
							  (cstate = process_data and ziroundnr = '1') or
							  (cstate = finalization and ziroundnr_final = '1')) else '0';
	li <= rload_s_init;	
			
	msg_end_clr <= '1' when (cstate = finalization and ziroundnr_final = '1') else '0';
	
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
	

	ziroundnr <= '1' when round = pq_roundnr256-1 else '0';
	ziroundnr_final  <= '1' when round = pq_roundnr_final256-1 else '0';	   
	bf <= '1' when (round= "00010100") and (cstate=process_data) else '0';	   		
	wr_state <= '1' when ( (round < "010111") and (cstate=process_data)) or ((round < "010111") and (cstate=finalization))else '0';
	wr_ctr <= '1'when (((round(0)='1')and (not (round="010011")) ) and (cstate=process_data)) or 
	((round(0)='1') and (not (round="010100")) and (cstate=finalization)) else '0';	 
	 
	ena_ctr <= '1' when	 (round="000000") and (cstate=process_data)else '0';		 
		
	p_mode <= '1' when ((round(0)='1') or (round="010100") or (cstate=finalization)) else '0';
	load_ctr <= '1' when (((round="000000")  or (round="010011") )and(cstate=process_data)) or (( (round="010011") )and(cstate=finalization))  else '0';
	init1 <= '1' when (round="000000") and (cstate=process_data)else '0';
	init2 <= '1' when ((round="000000")  or (round="000001"))and (cstate=process_data) else '0';
	init3 <= '1' when (round="000000")  and (cstate=process_data)else '0';
	final <= '1' when ((round="010100") and (cstate=process_data)) or ((round="010100") and (cstate=finalization))  else '0';	
	wr_result <= '1' when ((((round="000000")and (first_block_in='1'))or(round="010011") or(round="010100"))and (cstate=process_data)) or ((round="010011") and (cstate=finalization)) else '0'; 
	load_block_invalid <= '1' when  (last_block='1') or (cstate=finalization) else '0';	
	done <= '1' when (round="001111") and (cstate=finalization) else '0';	

	block_load_s_wire <= '1' when  (round = "00001011")  else '0';							  
 	bls_reg_reg 	: d_ff port map ( clk => clk, ena => VCC, rst => GND, d => block_load_s_wire, q => block_load_s );

	 no_init_set <=  '1' when (round="010010") else '0';
	no_init_clr <= 	'1' when (cstate = finalization) and (round="010010")else '0';
	last_cycle <= '1' when (cstate=process_data) and (round="010100") else '0';	
		
end fx2_256;

-- architecture for 512 version 
architecture fx2_512 of groestl_fsm2_pq is
   type state_type is ( wait_for_sync, idle,  process_data, finalization, finalization_delay, finalization_delay2, output_data );
   signal cstate, nstate : state_type;
   
   signal round : std_logic_vector(pq_log2roundnr_final512-1 downto 0);
   signal ziroundnr, ziroundnr_final, li, ei : std_logic;
   signal output_data_s, block_load_s, rload_s, rload_s_init : std_logic;						 
   --================
   
   type state_type2 is (first_block, wait_for_msg_end, wait_for_last_block);
   signal c2state, n2state : state_type2;
   
   constant zero :std_logic_vector(pq_log2roundnr_final512-1 downto 0):=(others => '0');
   signal block_load_s_wire : std_logic ;
begin	
	-- fsm2 counter	 
	proc_counter_gen : countern generic map ( N => pq_log2roundnr_final512 ) port map ( clk => clk, rst => '0', load => li, en => ei, input => zero, output => round);

		
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
	-- states transistion process 
	nstate_proc : process ( cstate, msg_end, output_busy, block_ready, ziroundnr_final, ziroundnr, underflow, last_block )
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
				elsif (ziroundnr = '1' and msg_end = '1' and ((underflow='1') or (last_block='1'))) then
					nstate <= finalization;
				elsif (underflow='1') or (last_block='1')then
					nstate <= finalization;

				else	
					nstate <= idle;
				end if;	
				
			when finalization =>
				if ziroundnr_final = '0' then
					nstate <= finalization;
				elsif (ziroundnr_final = '1' and output_busy = '1') then
					nstate <= output_data;
				elsif (ziroundnr_final = '1' and output_busy = '0' and block_ready = '1') then
					nstate <= idle; --process_data;
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
	
							  
	block_ready_clr <= block_load_s;

		
	rload_s <= '1' when ((cstate = process_data and ziroundnr = '0') or
						(cstate = finalization and ziroundnr_final = '0')) else '0';
	ei <= rload_s or rload_s_init;
		
	rload_s_init <= '1' when ((cstate = idle and block_ready = '1') or 
							  (cstate = process_data and ziroundnr = '1') or
							  (cstate = finalization and ziroundnr_final = '1')) else '0';
	li <= rload_s_init;	
			
	msg_end_clr <= '1' when (cstate = finalization and ziroundnr_final = '1') else '0';
	
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
	
	
	 	ziroundnr <= '1' when round = pq_roundnr512-1 else '0';
	ziroundnr_final  <= '1' when round = pq_roundnr_final512-1 else '0';	   
	bf <= '1' when (round= "00011100") and (cstate=process_data) else '0';	   		
	wr_state <= '1' when ( (round < "011111") and (cstate=process_data)) or ((round < "011111") and (cstate=finalization))else '0';
	wr_ctr <= '1'when (((round(0)='1')and (not (round="011011")) ) and (cstate=process_data)) or 
	((round(0)='1') and (not (round="011011")) and (cstate=finalization)) else '0';	 
	ena_ctr <= '1' when	 (round="000000") and (cstate=process_data)else '0';		 
		
	p_mode <= '1' when ((round(0)='1') or (round="011100") or (cstate=finalization)) else '0';
	load_ctr <= '1' when (((round="000000")  or (round="011011") )and(cstate=process_data)) or (( (round="011011") )and(cstate=finalization))  else '0';
	init1 <= '1' when (round="000000") and (cstate=process_data)else '0';
	init2 <= '1' when ((round="000000")  or (round="000001"))and (cstate=process_data) else '0';
	init3 <= '1' when (round="000000")  and (cstate=process_data)else '0';
	final <= '1' when ((round="011100") and (cstate=process_data)) or ((round="011100") and (cstate=finalization))  else '0';	
	wr_result <= '1' when ((((round="000000")and (first_block_in='1'))or(round="011011") or(round="011100"))and (cstate=process_data)) or ((round="011011") and (cstate=finalization)) else '0'; 
	load_block_invalid <= '1' when  (last_block='1') or (cstate=finalization) else '0';	
	done <= '1' when (round="010111") and (cstate=finalization) else '0';	
	--block_load_s_wire <= '1' when  (round = "00010011")  else '0';	
	block_load_s_wire <= '1' when  (round = "00001011")  else '0';	
		
 	bls_reg_reg 	: d_ff port map ( clk => clk, ena => VCC, rst => GND, d => block_load_s_wire, q => block_load_s );

 	no_init_set <=  '1' when (round="011010") else '0';
	no_init_clr <= 	'1' when (cstate = finalization) and (round="011010")else '0';
  	last_cycle <= '1' when (cstate=process_data) and (round="011100") else '0';	
	
end fx2_512;
		