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

entity hamsi_fsm2 is  
	generic ( roundnr : integer := 3;
			roundnr_final : integer := 6;
			log2roundnr_final : integer := 3 );
	port (
		-- global
		clk : in std_logic;
		rst : in std_logic;
		
		-- datapath
		er, sf : out std_logic; 	
		
		eh	: out std_logic;
		sfinal : out std_logic;
		sr_init : out std_logic;
		roundc : out std_logic_vector(log2roundnr_final-1 downto 0);
		lo : out std_logic;
		-- control				   
			--fsm1 hand shake signals
		block_ready_clr : out std_logic;		
		msg_end_clr 	: out std_logic;
		
		block_ready		: in std_logic;
		msg_end 		: in std_logic;	
		last_block		: in std_logic;
				
			--fsm3 handshake signals
		output_write_set : out std_logic;
		output_busy_set  : out std_logic;
		output_busy		 : in  std_logic
	);							   
end hamsi_fsm2;

architecture beh of hamsi_fsm2 is
	type state_type is ( idle, xblock, lblock, output_data );
	signal cstate, nstate : state_type;
	
	-- round counter
	signal roundc_s : std_logic_vector(log2roundnr_final-1 downto 0);
	signal ziroundnr, ziroundnr_final, li, ei : std_logic;
	
	signal output_data_s, block_load_s, ei_s : std_logic;						 
	--================
	
	type state_type2 is (first_block, wait_for_msg_end, wait_for_last_block);
	signal c2state, n2state : state_type2;	  
   
   		
	constant log2roundnr_finalzeros : std_logic_vector(log2roundnr_final-1 downto 0) := (others => '0');
   
begin	
	-- fsm2 counters
		-- round counter
		rc_gen : countern generic map ( N => log2roundnr_final ) port map ( clk => clk, rst => '0', load => li, en => ei, input => log2roundnr_finalzeros, output => roundc_s);
		ziroundnr <= '1' when roundc_s = roundnr-1 else '0';
		ziroundnr_final  <= '1' when roundc_s = roundnr_final-1 else '0';	
		roundc <= roundc_s;
																			  
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
	
	nstate_proc : process ( cstate, last_block, output_busy, block_ready, ziroundnr_final, ziroundnr )
	begin
		case cstate is	 
			when idle =>
				if (( block_ready = '1' ) and (last_block = '0')) then
					nstate <= xblock;
				elsif (( block_ready = '1' ) and (last_block = '1')) then
					nstate <= lblock;
				else
					nstate <= idle;
				end if;	    
			when xblock =>
				if ( ziroundnr = '1' and block_ready = '0')	then
					nstate <= idle;					
				elsif ( ziroundnr = '1' and block_ready = '1' and last_block = '1')	then
					nstate <= lblock;
				else
					nstate <= xblock;
				end if;				 
			when lblock => 
				if (ziroundnr_final = '0') then
					nstate <= lblock;
				elsif (ziroundnr_final = '1' and output_busy = '1')	then
					nstate <= output_data;
				elsif (ziroundnr_final = '1' and output_busy = '0' and block_ready = '0' ) then
					nstate <= idle;				
				elsif (ziroundnr_final = '1' and output_busy = '0' and block_ready = '1' and last_block = '0' ) then
					nstate <= xblock;
				else
					nstate <= lblock;
				end if;
			when output_data =>
				if ( output_busy = '1' ) then
					nstate <= output_data;
				elsif ( block_ready = '0' ) then
					nstate <= idle;				
				elsif ( last_block = '0' ) then 
					nstate <= xblock;
				else 
					nstate <= lblock;
				end if;				
		end case;
	end process;
	
	
	---- output logic
	output_data_s <= '1' when ((cstate = lblock and ziroundnr_final = '1' and output_busy = '0') or 
							  (cstate = output_data and output_busy = '0')) else '0';
	output_write_set	<= output_data_s;
	output_busy_set 	<= output_data_s;
	
	
	block_load_s		<= '1' when ((cstate = idle and block_ready = '1') or 
									(cstate = xblock and ziroundnr = '1' and block_ready = '1') or
							  		(cstate = lblock and ziroundnr_final = '1' and output_busy = '0' and block_ready = '1') or 
									(cstate = output_data and output_busy = '0' and block_ready = '1')) else '0';
	block_ready_clr <= block_load_s; 	
	sr_init <= block_load_s;
	li <= block_load_s;
	
	ei_s <= '1' when ((cstate = xblock and ziroundnr = '0') or
					 (cstate = lblock and ziroundnr_final = '0')) else '0';
	ei <= ei_s;				  
	
	eh <= '1' when ((block_load_s = '1') or 
					(cstate = lblock and ziroundnr_final = '1')) else '0';	  							
						
	er <= '1' when ((cstate = idle and block_ready = '1') or
					(cstate = xblock and ziroundnr = '0') or
					(cstate = xblock and ziroundnr = '1' and block_ready = '1') or
					(cstate = lblock and ziroundnr_final = '0') or
					(cstate = lblock and ziroundnr_final = '1' and output_busy = '0' and block_ready = '1') or 
					(cstate = output_data and output_busy = '0' and block_ready = '1')) else '0';
	lo <= '1' when ((cstate = lblock and ziroundnr_final = '1' and output_busy = '0') or 
					(cstate = output_data and output_busy = '0')) else '0';	  							
	
	sfinal <= '1' when (cstate = lblock) else '0';			
						
	msg_end_clr <= '1' when (cstate = lblock and ziroundnr_final = '1') else '0';
	
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
	
	sf <= '1' when ((c2state = first_block and block_ready = '1') or (c2state = wait_for_last_block and output_data_s = '1' and block_ready = '1')) else '0';
	
end beh;
		
		
		