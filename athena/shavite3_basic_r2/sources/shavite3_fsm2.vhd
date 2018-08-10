-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;
use work.shavite3_pkg.all;

-- Shavite-3 fsm2 is responsible for Shavite-3 (256 variant) computation processing 

entity shavite3_fsm2 is 
	port (
		clk 				: in std_logic;
		rst 				: in std_logic;
		bf					: out std_logic;	
		ena_ctr 			: out std_logic;
		sel_rd 				: out std_logic_vector(1 downto 0);
		first_block_in		:in std_logic; 
		sel_init_kg			: out std_logic;  
		en_keygen			: out std_logic;
		sel_aes		   		: out std_logic;
		sel_con_1			: out std_logic_vector(1 downto 0);
		sel_con_2			: out std_logic_vector(1 downto 0);
		sel_con_3			: out std_logic;
		sel_con_4			: out std_logic;
		data_sel			: out std_logic_vector(1 downto 0);	
		sel_init_state		: out std_logic;
		en_in_round			: out std_logic;
		en_state			: out std_logic;
		wr_result			: out std_logic;
		last_block			: in std_logic;  
		wfl2				: in std_logic;
		block_ready_clr 	: out std_logic;		
		msg_end_clr 		: out std_logic;
		block_ready			: in std_logic;
		msg_end 			: in std_logic;
		ls_rs_flag			:in std_logic; 
		no_init_set			: out std_logic;
		no_init_clr			: out std_logic;	
		no_init				: in std_logic;
		output_write_set 	: out std_logic;
		output_busy_set  	: out std_logic;
		output_busy		 	: in  std_logic);							   
end shavite3_fsm2;

architecture beh of shavite3_fsm2 is
   type state_type is ( wait_for_sync, idle, process_data, finalization, output_data );
   signal cstate, nstate : state_type;   
   signal round : std_logic_vector(log2roundnr_final256-1 downto 0);
   signal ziroundnr, ziroundnr_final, li, ei : std_logic;
   signal output_data_s, block_load_s, rload_s, rload_s_init : std_logic;						 
   type state_type2 is (first_block, wait_for_msg_end, wait_for_last_block);
   signal c2state, n2state : state_type2;   
   constant zero :std_logic_vector(log2roundnr_final256-1 downto 0):=(others => '0');
begin	

	proc_counter_gen : countern generic map ( N => log2roundnr_final256 ) port map ( clk => clk, rst => '0', load => li, en => ei, input => zero, output => round);
	
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
	
	nstate_proc : process ( cstate, msg_end, output_busy, block_ready, ziroundnr_final, ziroundnr, last_block, ls_rs_flag )
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
				elsif (ziroundnr = '1' and msg_end = '1' and (last_block='1')) then
					nstate <= finalization;
				elsif (last_block='1') and (ls_rs_flag='1')then
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
	
	block_load_s <= '1' when  ((round = "00100100") and wfl2='0') or ((round = "00011101") and wfl2='1') else '0';							  
								  
	block_ready_clr <= block_load_s;
		
	rload_s <= '1' when ((cstate = process_data and ziroundnr = '0') or
						(cstate = finalization and ziroundnr_final = '0')) else '0';
	ei <= rload_s or rload_s_init;
		
	rload_s_init <= '1' when ((cstate = idle and block_ready = '1') or 
							  (cstate = process_data and ziroundnr = '1') or
							  (cstate = finalization and ziroundnr_final = '1')) else '0';
	li <= rload_s_init;	
	
	ena_ctr <= '1' when	 (round="100010") else '0';
	
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
	
		
	ziroundnr <= '1' when round = roundnr256-1 else '0';
	ziroundnr_final  <= '1' when round = roundnr_final-1 else '0';	   
	bf <= '1' when round= "00011000" else '0';	   
				
	wr_result <= '1' when (round="100101") else '0'; 	
	
	sel_init_kg <= '1' when (cstate=process_data and round="00000000") or (round="00000001")or (round="00000010")or (round="00000011") else '0';	

	en_keygen <= '1' when (cstate=process_data) else '0';

	sel_aes <= '1' when (round="00000100") or (round="00000101") or (round="00000110") or (round="00000111") or 		
						(round="00001100") or (round="00001101") or (round="00001110") or (round="00001111") or
						(round="00010100") or (round="00010101") or (round="00010110") or (round="00010111") or
						(round="00011100") or (round="00011101") or (round="00011110") or (round="00011111") else '0';
		
	 with round(5 downto 0) select 
	 	sel_con_1 <= 	"01" when "010101",
							"11" when "011111",
							"00" when others;
						
	 with round(5 downto 0) select 
	 	sel_con_2 <= 	"01" when "001110",
							"11" when "010101",
							"00" when others;	
											   
	sel_con_3 <= '1' when round="00000100" else '0';
				
	sel_con_4 <= '1' when round="00000100" or round="00011111" else '0';
	
				
	with round(5 downto 0) select 
	 	data_sel <= 	"01" when "000001", "10" when "000010", "11" when "000011", "00" when others;	
											
	sel_init_state <= '1' when (round="0000001") and (no_init='0') else '0';
				
	en_in_round	<= '1' when (round="000010") or (round="000011")or (round="000101") or (round="000110")or
							(round="001000") or (round="001001")or (round="001011") or (round="001100")or	 
							(round="001110") or (round="001111")or (round="010001") or (round="010010")or	 
							(round="010100") or (round="010101")or (round="010111") or (round="011000")or
							(round="011010") or (round="011011")or (round="011101") or (round="011110")or
							(round="100000") or	(round="100001")or (round="100011") or (round="100100")else '0';
								
									
	en_state <= '1' when 	((round="000001") and ((first_block_in='1')and (no_init='0')))   
							or(round="000100") or (round="000111")or (round="001010")or (round="001101")or
							(round="010000") or (round="010011")or (round="010110")or (round="011001")or				
							(round="011100") or	(round="011111")or (round="100010")or (round="100101")else '0';						
									
	with round(5 downto 0) select	
	sel_rd <= 	"01" when "000011",	"10" when "000100", "01" when "000110", "10" when "000111",	
				"01" when "001001",	"10" when "001010", "01" when "001100",	"10" when "001101",	
				"01" when "001111",	"10" when "010000",	"01" when "010010",	"10" when "010011",	
				"01" when "010101",	"10" when "010110",	"01" when "011000",	"10" when "011001",	
				"01" when "011011",	"10" when "011100",	"01" when "011110",	"10" when "011111",
				"01" when "100001",	"10" when "100010",	"01" when "100100",	"10" when "100101",		
				"00" when others;  	
				
	no_init_set <=  '1' when (round="100101") else '0';
	no_init_clr <= 	'1' when (cstate = finalization)else '0';

end beh;
		
		
