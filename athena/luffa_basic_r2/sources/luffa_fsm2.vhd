library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;
use work.sha3_luffa_package.all;

entity luffa_fsm2 is  
	generic ( h : integer := 256; round_length : integer := 3 );
	port (
		-- global
		clk : in std_logic;
		rst : in std_logic;
		
		-- datapath
		sstep_init, sfinal : out std_logic;
		er, lo, sf, eo_fsm2 : out std_logic; 	
		round : out std_logic_vector(round_length-1 downto 0);
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
end luffa_fsm2;


-- ////////////////////////
-- ////////////////////////
-- ////////////////////////

architecture beh of luffa_fsm2 is
begin
	h256 : if ( h = 256 ) generate
		fsm2_gen : entity work.luffa_fsm2(h256) 
		generic map ( round_length => round_length )
		port map (
			clk => clk, rst => rst, 
			er => er, lo => lo, sf => sf, sfinal => sfinal, sstep_init => sstep_init, round => round,eo_fsm2 => eo_fsm2,
			block_ready_clr => block_ready_clr, msg_end_clr => msg_end_clr, block_ready => block_ready, msg_end => msg_end,
			output_write_set => output_write_set, output_busy_set => output_busy_set, output_busy => output_busy
		); 
	end generate;			 

	h512 : if ( h = 512 ) generate
		fsm2_gen : entity work.luffa_fsm2(h512) 
		generic map ( round_length => round_length )
		port map (
			clk => clk, rst => rst, 
			er => er, lo => lo, sf => sf, sfinal => sfinal, sstep_init => sstep_init, round => round,eo_fsm2 => eo_fsm2,
			block_ready_clr => block_ready_clr, msg_end_clr => msg_end_clr, block_ready => block_ready, msg_end => msg_end,
			output_write_set => output_write_set, output_busy_set => output_busy_set, output_busy => output_busy
		); 
	end generate;
end beh;

-- ////////////////////////
-- ///    h512 	/////////
-- ////////////////////////

architecture h512 of luffa_fsm2 is	

	constant roundnr 		: integer := 9;	
	constant log2roundnr 	: integer := log2( roundnr );			
	constant log2roundnrzeros	: std_logic_vector(log2roundnr-1 downto 0) := (others => '0');
	
	 
	type state_type is ( wait_for_sync, idle, process_data, finalization, output_data );
	signal cstate, nstate : state_type;
	
	signal round_s : std_logic_vector(log2roundnr-1 downto 0);
	signal ziroundnr, li, ei : std_logic;
	signal sfinal_s, output_data_s, block_load_s, rload_s, rload_s_init : std_logic;						 
	--================
	
	type state_type2 is (first_block, wait_for_msg_end, wait_for_last_block);
	signal c2state, n2state : state_type2;			
	
	signal efinalcnt, finalcnt, cfinalcnt : std_logic;
begin	
	-- fsm2 counter
	proc_counter_gen : countern generic map ( N => log2roundnr ) port map ( clk => clk, rst => '0', load => li, en => ei, input => log2roundnrzeros, output => round_s);
	ziroundnr <= '1' when round_s = roundnr-1 else '0';	 
	round <= round_s(round_length-1 downto 0);
	finalgen : d_ff port map ( clk => clk, ena => efinalcnt, rst => cfinalcnt, d => '1', q => finalcnt );	
	
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
	
	nstate_proc : process ( cstate, msg_end, output_busy, block_ready, ziroundnr, finalcnt )
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
				elsif (ziroundnr = '1' and msg_end = '1') then
					nstate <= finalization;
				else
					nstate <= idle;
				end if;				 
			when finalization =>
				if ( ziroundnr = '0'  ) then				
					nstate <= finalization;
				elsif ( ziroundnr = '1' and output_busy = '1' ) then
					nstate <= output_data;
				elsif (ziroundnr = '1'  and output_busy = '0' and finalcnt = '0') then
					nstate <= finalization;
				else
					nstate <= idle;
				end if;
			when output_data =>
				if ( output_busy = '1' ) then
					nstate <= output_data;
				elsif ( finalcnt = '0' ) then
					nstate <= finalization;		  
				elsif ( block_ready = '1' ) then
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
	eo_fsm2				<= output_data_s;
	
	block_load_s		<= '1' when ((cstate = idle and block_ready = '1') or 
									(cstate = process_data and ziroundnr = '1' and msg_end = '0' and block_ready = '1') or
						  			(cstate = output_data and finalcnt = '1' and output_busy = '0' and block_ready = '1')) else '0';
	block_ready_clr <= block_load_s;
	
	efinalcnt <= '1' when (cstate = finalization and ziroundnr = '1' ) else '0';
	cfinalcnt <= '1' when (cstate = process_data and ziroundnr = '1' and msg_end = '1') else '0';
	sfinal_s <= '1' when  ((cstate = process_data and ziroundnr = '1' and msg_end = '1') or 
							(cstate = finalization and ziroundnr = '1' and output_busy = '0' and finalcnt = '0') or
							(cstate = output_data and output_busy = '0' and finalcnt = '0')) else '0';
	sfinal <= sfinal_s;
	
	rload_s <= '1' when ((cstate = process_data and ziroundnr = '0') or
						(cstate = finalization and ziroundnr = '0')) else '0';
	ei <= rload_s;
		
	rload_s_init <= '1' when ((cstate = idle and block_ready = '1') or 
							  (cstate = process_data and ziroundnr = '1' and (msg_end = '1' or (msg_end = '0' and block_ready = '1'))) or
							  (cstate = finalization and ziroundnr = '1' and output_busy = '0') or
							  (cstate = output_data and finalcnt = '1' and output_busy = '0' and block_ready = '1')) else '0';
	li <= rload_s_init;	
	
	
	er 		<= rload_s or rload_s_init;
	
	msg_end_clr <= '1' when ((cstate = finalization and ziroundnr = '1' and finalcnt = '1' and output_busy = '0') or  
							 (cstate = output_data and finalcnt = '1' and output_busy = '0')) else '0';
	
	sstep_init <= block_load_s or sfinal_s;
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
	
	small_fsm_transition : process ( c2state, block_load_s, msg_end,output_data_s ) 
	begin
		case c2state is 	 
			when first_block =>
				if ( block_load_s = '1' ) then
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
				if ( finalcnt = '1' and output_data_s = '1' ) then
					n2state <= first_block;
				else 
				   	n2state <= wait_for_last_block;
				end if;
		end case;
	end process;		
	
	sf <= '1' when (c2state = first_block and block_load_s = '1') else '0';
	
end h512;
		
-- ///////////////////////
-- /////  h256		//////
-- ///////////////////////


architecture h256 of luffa_fsm2 is					 
	constant roundnr 		: integer := 9;
	constant log2roundnr 	: integer := log2( roundnr );			
 	constant log2roundnrzeros	: std_logic_vector(log2roundnr-1 downto 0) := (others => '0');
	
	 
	type state_type is ( idle, process_data, finalization, output_data );
	signal cstate, nstate : state_type;
	
	signal round_s : std_logic_vector(log2roundnr-1 downto 0);
	signal ziroundnr, li, ei : std_logic;
	signal output_data_s, block_load_s, final_s : std_logic;						 
	--================
	
	type state_type2 is (first_block, wait_for_msg_end, wait_for_last_block);
	signal c2state, n2state : state_type2;
begin	
	-- fsm2 counter
	proc_counter_gen : countern generic map ( N => log2roundnr ) port map ( clk => clk, rst => '0', load => li, en => ei, input => log2roundnrzeros, output => round_s);
	ziroundnr <= '1' when round_s = roundnr-1 else '0';	 
	
	round <= round_s(round_length-1 downto 0);		

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
	
	nstate_proc : process ( cstate, msg_end, output_busy, block_ready, ziroundnr )
	begin
		case cstate is	 
			when idle =>			   
					if ( block_ready = '1' ) then
						nstate <= process_data;
					else
						nstate <= idle;
					end if;
			when process_data =>
				if (( ziroundnr = '0' ) or (ziroundnr = '1' and msg_end = '0' and block_ready = '1')) then				
					nstate <= process_data;					
				elsif (ziroundnr = '1' and msg_end = '1') then
					nstate <= finalization;
				else
					nstate <= idle;
				end if;				 
			when finalization =>
				if ziroundnr = '0' then
					nstate <= finalization;
				elsif (ziroundnr = '1' and output_busy = '1') then
					nstate <= output_data;				
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
	
	
	---- output logics

	output_data_s <= '1' when ((cstate = finalization and ziroundnr = '1' and output_busy = '0') or 
							  (cstate = output_data and output_busy = '0')) else '0';
	output_write_set	<= output_data_s;
	output_busy_set 	<= output_data_s;
	lo 					<= output_data_s;
	eo_fsm2				<= output_data_s;
	
	block_load_s		<= '1' when ((cstate = idle and block_ready = '1') or 
									(cstate = process_data and ziroundnr = '1' and msg_end = '0' and block_ready = '1') or									
									(cstate = output_data and block_ready = '1')) else '0';
	block_ready_clr <= block_load_s;

	final_s <= '1' when (cstate = process_data and ziroundnr = '1' and msg_end = '1') else '0';
	sfinal <= final_s;
	
	ei <= '1' when ((cstate = process_data and ziroundnr = '0') or
					(cstate = finalization and ziroundnr = '0')) else '0';		
	li <= '1' when 	((cstate = idle and block_ready = '1') or 
					(cstate = process_data and ziroundnr = '1') or
					(cstate = finalization and ziroundnr = '1')) else '0';
		
	er <= '1' when ((cstate = idle and block_ready = '1') or   
				(cstate = process_data and ziroundnr = '0') or
				(cstate = process_data and ziroundnr = '1' and msg_end = '1') or
				(cstate = process_data and ziroundnr = '1' and msg_end = '0' and block_ready = '1') or
				(cstate = finalization )) else '0';
	
	msg_end_clr <= '1' when (cstate = finalization and ziroundnr = '1') else '0';
	
	sstep_init <= block_load_s or final_s;
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
				else
					n2state <= first_block;
				end if;
		end case;
	end process;		
	
	sf <= '1' when (c2state = first_block and block_ready = '1') else '0';
	
end h256;
		
		

		