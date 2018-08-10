-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_arith.all;
use work.sha3_pkg.all;
use work.sha3_simd_package.all;

entity simd_fsm2 is
	generic (
		feistels : integer := 4 );
	port (
		-- global
		clk : in std_logic;
		rst : in std_logic;
		
		-- datapath
		er, lo, sf  :  out std_logic;
		eh, slr, sphi  : out std_logic;		
		ctrl_cp : out std_logic_vector(2 downto 0);
		sa	: out std_logic_vector(log2(feistels)-1 downto 0);
		spi : out std_logic_vector(1 downto 0);
		
		-- control				   
			--fsm1 hand shake signals
		ntt_ready_clr : out std_logic;		
		ntt_end_clr 	: out std_logic;
		
		ntt_ready		: in std_logic;
		ntt_end 		: in std_logic;	
				
			--fsm3 handshake signals
		output_write_set : out std_logic;
		output_busy_set  : out std_logic;
		output_busy		 : in  std_logic
	);							   
end simd_fsm2;

architecture beh of simd_fsm2 is 
	constant roundnr : integer := 9;
	constant log2roundnr 	: integer := log2( roundnr );  
	constant log2roundnrzeros	: std_logic_vector(log2roundnr-1 downto 0) := (others => '0');
	
   type state_type is ( idle, process_data, wait_for_msg, output_data );
   signal cstate, nstate : state_type;
   
   signal pc : std_logic_vector(log2roundnr-1 downto 0);
   signal pc_delay : std_logic_vector(1 downto 0);
   signal ziroundnr, li, ei : std_logic;
   signal output_data_s, block_load_s, int_rload : std_logic;						 
   
   signal shfreg_a, ctrl_cp_s : std_logic_vector(2 downto 0);	  	
   signal eom, eom_set, eom_clr : std_logic; 
   signal lsa : std_logic;
   --================  
   type state_type2 is (first_block, wait_for_eom, wait_for_last_block);
   signal c2state, n2state : state_type2;
   signal sf_s : std_logic;
   
   
begin	
	-- fsm2 counter
	round_counter_gen : countern generic map ( N => log2roundnr ) port map ( clk => clk, rst => '0', load => li, en => ei, input => conv_std_logic_vector(1,log2roundnr), output => pc);
	ziroundnr <= '1' when pc = conv_std_logic_vector(roundnr,log2roundnr) else '0';
	spi_gen : regn generic map ( N => 2, init => "00" ) port map ( clk => clk, rst => '0', en => '1', input => ctrl_cp_s(2 downto 1), output => pc_delay );
	
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
	
	nstate_proc : process ( cstate, eom, output_busy, ntt_ready, ziroundnr )
	begin
		case cstate is	 
			when idle =>
				if ( ntt_ready = '1' ) then
					nstate <= process_data;
				else
					nstate <= idle;
				end if;	    
			when process_data =>
				if (( ziroundnr = '0' ) or (ziroundnr = '1' and eom = '0' and ntt_ready = '1') or (ziroundnr = '1' and eom = '1' and output_busy = '0' and ntt_ready = '1' )) then
					nstate <= process_data;	
				elsif (ziroundnr = '1' and eom = '0' and ntt_ready = '0') then
					nstate <= wait_for_msg;
				elsif (ziroundnr = '1' and eom = '1' and output_busy = '1') then
					nstate <= output_data;
				elsif (ziroundnr = '1' and eom = '1' and output_busy = '0' and ntt_ready = '0' ) then
					nstate <= idle;
				end if;
			when wait_for_msg =>
				if (ntt_ready = '1') then
					nstate <= process_data;
				else
					nstate <= wait_for_msg;
				end if;
			when output_data =>
				if ( output_busy = '1' ) then
					nstate <= output_data;
				elsif (ntt_ready = '1') then
					nstate <= process_data;			  
				else 
					nstate <= idle;
				end if;				
		end case;
	end process;
	
	
	---- output logic																						 																  	
	output_data_s <= '1' when ((cstate = process_data and ziroundnr = '1' and eom = '1' and output_busy = '0') or 
								  (cstate = output_data and output_busy = '0')) else '0';
	output_write_set	<= output_data_s;
	output_busy_set 	<= output_data_s;
	lo 					<= output_data_s;
		
	block_load_s		<= '1' when ((cstate = idle and ntt_ready = '1') or 
									(cstate = process_data and ziroundnr = '1' and eom = '0' and ntt_ready = '1') or
									(cstate = process_data and ziroundnr = '1' and eom = '1' and output_busy = '0' and ntt_ready = '1') or
									(cstate = wait_for_msg and ntt_ready = '1') or 
									(cstate = output_data and ntt_ready = '1')) else '0';
	ntt_ready_clr <= block_load_s;
	li <= block_load_s;
	
	int_rload <= '1' when (cstate = process_data and ziroundnr = '0') else '0';
	ei <= int_rload;
		
	er 		<= int_rload or block_load_s;
	
	ntt_end_clr <= eom_set;	   
	
	eom_gen : process( clk ) 
	begin
		if rising_edge ( clk ) then
			if eom_clr = '1' then
				eom <= '0';
			elsif eom_set = '1' then
				eom <= '1'; 
			end if;
		end if;
	end process;
	eom_set <= '1' when ((cstate = idle and ntt_ready = '1' and ntt_end = '1') or
						(cstate = wait_for_msg and ntt_ready = '1' and ntt_end = '1') or
						(cstate = process_data and ziroundnr = '1' and ntt_end = '1' and ntt_ready ='1')) else '0';
	eom_clr <= '1' when (cstate = process_data and ziroundnr = '1' and eom = '1') or (rst = '1') else '0';
	
	slr 	<= '1' when ((cstate = process_data and ziroundnr = '1' and ((eom = '1') or (eom = '0' and ntt_ready = '1'))) or (cstate = wait_for_msg and ntt_ready = '1')) else '0';
	eh 		<= block_load_s or sf_s;
	
	ctrl_cp_s <= "000" when block_load_s = '1' else pc(2 downto 0);
	ctrl_cp <= ctrl_cp_s;
	sa 		<= shfreg_a(2 downto 2-(log2(feistels)-1));
	
	sphi 	<= not pc(0);
	spi 	<= pc_delay;
	
	sa_feistels4 : if ( feistels = 4 ) generate
		sa_gen : process( clk )
		begin
			if rising_edge( clk ) then
				if (li = '1') then
					shfreg_a <= "001";
				elsif (ei = '1') then
					shfreg_a <= shfreg_a(1 downto 0) & shfreg_a(2);
				end if;
			end if;
		end process;	   	  
	end generate;
	sa_feistels8 : if (feistels = 8) generate
		sa_gen : countern generic map ( N => log2(feistels) ) port map ( clk => clk, rst => '0', load => lsa, en => ei, input => conv_std_logic_vector(0,log2(feistels)), output => shfreg_a);
		lsa <= '1' when ((shfreg_a = "110") or (li = '1')) else '0';
	end generate;		 
	
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
	
	small_fsm_transition : process ( c2state, ntt_ready, eom, output_data_s ) 
	begin
		case c2state is 	 
			when first_block =>
				if ( ntt_ready = '1' ) then
					n2state <= wait_for_eom;
				else
					n2state <= first_block;
				end if;
			when wait_for_eom =>
				if ( eom = '1' ) then
					n2state <= wait_for_last_block;
				else
					n2state <= wait_for_eom;
				end if;
			when wait_for_last_block =>
				if ( output_data_s = '0' ) then
					n2state <= wait_for_last_block;
				elsif ( ntt_ready = '1' ) then
					n2state <= wait_for_eom;
				else
					n2state <= first_block;
				end if;
		end case;
	end process;		
	
	sf_s <= '1' when ((c2state = first_block and ntt_ready = '1') or (c2state = wait_for_last_block and output_data_s = '1' and ntt_ready = '1')) else '0';
	sf <= sf_s;
end beh;
		
		
		