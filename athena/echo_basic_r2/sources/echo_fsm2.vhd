-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;
use work.echo_pkg.all;

-- ECHO fsm2 is responsible for ECHO computation processing

entity echo_fsm2 is 	
	port (
		clk 				: in std_logic;
		rst 				: in std_logic;
		er					: out std_logic; 
		lo					: out std_logic; 
		sf 					: out std_logic; 
		bf					: out std_logic;	
		ctr	 				: out std_logic;					
		sel_rd 				: out std_logic_vector(1 downto 0);
		first_block_in		: in std_logic; 
		wr_new_block		: out std_logic;  
		wr_key  			: out std_logic;	 
		bf_early			: out std_logic;
		big_final_mode 		: out std_logic_vector(1 downto 0);
		underflow			: in std_logic;  
		last_block			: in std_logic;    
		wfl2				: in std_logic;
		block_ready_clr 	: out std_logic;		
		msg_end_clr 		: out std_logic;
		block_ready			: in std_logic;
		msg_end 			: in std_logic;	
		ls_rs_flag			: in std_logic; 
		no_init_set			: out std_logic;
		no_init_clr			: out std_logic;	
		no_init				: in std_logic;
		output_write_set 	: out std_logic;
		output_busy_set  	: out std_logic;
		output_busy		 	: in  std_logic);							   
end echo_fsm2;

architecture beh256 of echo_fsm2 is
   type state_type is ( wait_for_sync, idle,  wr_len_st,  process_data, finalization, finalization_delay, finalization_delay2, output_data );
   signal cstate, nstate : state_type;  
   signal round : std_logic_vector(log2roundnr_final256-1 downto 0);
   signal ziroundnr, ziroundnr_final, li, ei : std_logic;
   signal output_data_s, block_load_s, rload_s, rload_s_init : std_logic;						 
   type state_type2 is (first_block, wait_for_msg_end, wait_for_last_block);
   signal c2state, n2state : state_type2; 
   constant zero :std_logic_vector(log2roundnr_final256-1 downto 0):=(others => '0');

begin	

	-- fsm2 counter
	proc_counter_gen : countern generic map ( N => log2roundnr_final256 ) port map ( clk => clk, rst => '0', load => li, en => ei, input => zero, output => round);

		
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
	
	nstate_proc : process ( cstate, msg_end, output_busy, block_ready, ziroundnr_final, ziroundnr, underflow, last_block, ls_rs_flag )
	begin
		case cstate is	 
			when wait_for_sync =>
				nstate <= idle;
			when idle =>
				if ( block_ready = '1' ) then
					nstate <= wr_len_st;
				else
					nstate <= idle;
				end if;	
				
				
			when wr_len_st =>
					nstate <= process_data;
													
			when process_data =>
					
				if (( ziroundnr = '0' ) or (ziroundnr = '1' and msg_end = '0' and block_ready = '1')) then				
					nstate <= process_data;					
				elsif (ziroundnr = '1' and msg_end = '1' and ((underflow='1') or (last_block='1'))) then
					nstate <= finalization;
				elsif ((underflow='1') or (last_block='1'))and (ls_rs_flag='1')then
					nstate <= finalization;	   
				elsif ls_rs_flag='0' then 
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
	
	
	wr_new_block <= '1' when round= x"14" else '0';	--15
		
	output_data_s <= '1' when ((cstate = finalization and ziroundnr_final = '1' and output_busy = '0') or 
						(cstate = output_data and output_busy = '0')) else '0';	 
		
	output_write_set	<= output_data_s;
	output_busy_set 	<= output_data_s;
								  
	block_load_s <= '1' when  ((round = x"18")and wfl2='0') or ((round = x"01") and wfl2='1') else '0';	--17
								  
	block_ready_clr <= block_load_s;
		
		
	rload_s <= '1' when ((cstate = process_data and ziroundnr = '0') or
						(cstate = finalization and ziroundnr_final = '0')) else '0';
	ei <= rload_s or rload_s_init;
		
	rload_s_init <= '1' when ((cstate = idle and block_ready = '1') or 
							  (cstate = process_data and ziroundnr = '1') or
							  (cstate = finalization and ziroundnr_final = '1')) else '0';
	li <= rload_s_init;	
	
	
	er 		<= '1' when (cstate=wr_len_st)  or (cstate=finalization)  or (cstate=process_data) else '0';  --rload_s or rload_s_init;	  
	
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
	
	
	sf <= '1' when (cstate=wr_len_st) or (round=x"19") else '0';--rload_s_init;--'1' when rload_s='1' and (round = "00000") else '0';

	
	lo <= '1' when ((c2state = first_block and block_ready = '1') or (c2state = wait_for_last_block and output_data_s = '1' and block_ready = '1')) else '0';
 
		
	ziroundnr <= '1' when round = roundnr256-1 else '0';
	ziroundnr_final  <= '1' when round = roundnr_final256-1 else '0';	   
	bf <= '1' when (round= x"17") else '0';	   
	big_final_mode <= "11" when (cstate=wr_len_st)or (round=x"19") else "00";		
	bf_early <= '1' when (cstate=wr_len_st) or (round=x"19")else '0';  
	
	ctr <= '1' when ((round = x"0") and (cstate=process_data)) or (round = x"3") or (round = x"6")
					or (round = x"9") or (round = x"c") or (round = x"0f") or (round = x"12")
	else '0'; 
	
	
	wr_key <= '1' when (cstate=idle and block_ready='1') or	(cstate=wr_len_st) or (cstate=process_data) or (cstate=finalization) else '0';
		
		
	with round(4 downto 0) select	
	sel_rd <= "00" when "00000",
	"01" when "00001",
	"10" when "00010",
	"00" when "00011",
	"01" when "00100",
	"10" when "00101",
	"00" when "00110",
	"01" when "00111",
	"10" when "01000",  
	"00" when "01001",
	"01" when "01010",
	"10" when "01011",	
	"00" when "01100",
	"01" when "01101",
	"10" when "01110",	
	"00" when "01111",	
	"01" when "10000",
	"10" when "10001",
	"00" when "10010",
	"01" when "10011",
	"10" when "10100",
	"00" when "10101",
	"01" when "10110",
	"10" when "10111",
	--"10" when "10111",
	
	"00" when others;  
	
	no_init_set <=  '1' when (round=x"16") else '0'; --17
	no_init_clr <= 	'1' when (cstate = finalization)else '0';

end beh256;


architecture beh512 of echo_fsm2 is
   type state_type is ( wait_for_sync, idle, wait1, wait2, wr_len_st,  process_data, finalization, finalization_delay, finalization_delay2, output_data );
   signal cstate, nstate : state_type; 
   signal round : std_logic_vector(log2roundnr_final512-1 downto 0);
   signal ziroundnr, ziroundnr_final, li, ei : std_logic;
   signal output_data_s, block_load_s, rload_s, rload_s_init : std_logic;						 
   --================
   type state_type2 is (first_block, wait_for_msg_end, wait_for_last_block);
   signal c2state, n2state : state_type2;
   constant zero :std_logic_vector(log2roundnr_final512-1 downto 0):=(others => '0');

begin	

	-- fsm2 counter
	proc_counter_gen : countern generic map ( N => log2roundnr_final512 ) port map ( clk => clk, rst => '0', load => li, en => ei, input => zero, output => round);

		
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
	
	nstate_proc : process ( cstate, msg_end, output_busy, block_ready, ziroundnr_final, ziroundnr, underflow, last_block )
	begin
		case cstate is	 
			when wait_for_sync =>
				nstate <= idle;
			when idle =>
				if ( block_ready = '1' ) then
					nstate <= wr_len_st;
				else
					nstate <= idle;
				end if;	
				
			when wait1 =>
				nstate <= wait2;
				
			when wait2 => 	
					nstate <= wr_len_st;
				
			when wr_len_st =>
					nstate <= process_data;
									
				
			when process_data =>
			
				
				if (( ziroundnr = '0' ) or (ziroundnr = '1' and msg_end = '0' and block_ready = '1')) then				
					nstate <= process_data;					
				elsif (ziroundnr = '1' and msg_end = '1' and ((underflow='1') or (last_block='1'))) then
					nstate <= finalization;
				elsif ((underflow='1') or (last_block='1')) and (ls_rs_flag='1')then
					nstate <= finalization;	   
				elsif ls_rs_flag='0' then 
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
	
	
	wr_new_block <= '1' when round= x"1A" else '0';	
		
	---- output logic
	
	output_data_s <= '1' when ((cstate = finalization and ziroundnr_final = '1' and output_busy = '0') or 
						(cstate = output_data and output_busy = '0')) else '0';	 
		
	output_write_set	<= output_data_s;
	output_busy_set 	<= output_data_s;
	
									  
	--block_load_s <= '1' when  (round = x"1F") else '0';							  
	block_load_s <= '1' when  ((round = x"1E")and wfl2='0') or ((round = x"0F") and wfl2='1') else '0';	--17

		
	block_ready_clr <= block_load_s;
		
		
	rload_s <= '1' when ((cstate = process_data and ziroundnr = '0') or
						(cstate = finalization and ziroundnr_final = '0')) else '0';
	ei <= rload_s or rload_s_init;
		
	rload_s_init <= '1' when ((cstate = idle and block_ready = '1') or 
							  (cstate = process_data and ziroundnr = '1') or
							  (cstate = finalization and ziroundnr_final = '1')) else '0';
	li <= rload_s_init;	
	
	
	er 		<= '1' when (cstate=wr_len_st)  or (cstate=finalization)  or (cstate=process_data) else '0';  --rload_s or rload_s_init;	  
	
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
	
	sf <= '1' when (cstate=wr_len_st) or (round=x"1F") else '0';
	
	lo <= '1' when ((c2state = first_block and block_ready = '1') or (c2state = wait_for_last_block and output_data_s = '1' and block_ready = '1')) else '0';
 
		
			ziroundnr <= '1' when round = roundnr512-1 else '0';
	ziroundnr_final  <= '1' when round = roundnr_final512-1 else '0';	   
	bf <= '1' when round= x"1D" else '0';	   
	big_final_mode <= "11" when round = x"02" else "00";		
	bf_early <= '1' when (round= x"02") else '0';									   
		
	ctr <= '1' when ((round = x"0") and (cstate=process_data)) or (round = x"3") or (round = x"6")
	or (round = x"9") or (round = x"c") or (round = x"0f") or (round = x"12") 
	or (round = x"15") or (round = x"18") else '0'; 
	
	wr_key <= '1' when (cstate=idle and block_ready='1') or	(cstate=wr_len_st) or (cstate=process_data) or (cstate=finalization) else '0';
	
	with round(4 downto 0) select	
	sel_rd <= "00" when "00000",
	"01" when "00001",
	"10" when "00010",
	"00" when "00011",
	"01" when "00100",
	"10" when "00101",
	"00" when "00110",
	"01" when "00111",
	"10" when "01000",  
	"00" when "01001",
	"01" when "01010",
	"10" when "01011",	
	"00" when "01100",
	"01" when "01101",
	"10" when "01110",	
	"00" when "01111",	
	"01" when "10000",
	"10" when "10001",
	"00" when "10010",
	"01" when "10011",
	"10" when "10100",
	"00" when "10101",
	"01" when "10110",
	"10" when "10111",
	"00" when "11000",
	"01" when "11001",
	"10" when "11010",
	"00" when "11011",
	"01" when "11100",
	"10" when "11101",
	
	"00" when others;  
	no_init_set <=  '1' when (round=x"1c") else '0';
	no_init_clr <= 	'1' when (cstate = finalization)else '0';

end beh512;
		
		
		