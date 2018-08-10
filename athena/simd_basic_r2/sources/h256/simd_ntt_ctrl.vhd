-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library IEEE;
use ieee.std_logic_1164.all;			
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all;
use work.sha3_simd_package.all;
use work.sha3_pkg.all;

entity simd_ntt_ctrl is
	generic ( feistels : integer := 4 );
	port (
	clk : in std_logic;
	rst : in std_logic;		
	
	-- datapath
	ctrl_ntt : out std_logic_vector(6 downto 0);	
	
	--fsm 1 handshake
	block_ready_clr, msg_end_clr : out std_logic;
	block_ready, msg_end : in std_logic;
	
	--fsm2 handshake
	ntt_ready_set : out std_logic;	
	ntt_end_set : out std_logic;
	ntt_ready : in std_logic
	);
end simd_ntt_ctrl;								

architecture beh of simd_ntt_ctrl is	 
	signal counter : std_logic_vector(2 downto 0);
	signal zi7 : std_logic;
	
	type ntt_fsm_type is (idle, process_ntt, hold_output);
	signal cstate, nstate : ntt_fsm_type;
	
	signal li, ei : std_logic;
	signal endsig, ntt_done, ntt_start, ntt_en, sfinal : std_logic;
begin	
	-- ntt counter
	ntt_counter_gen : countern generic map ( N => 3 ) port map ( clk => clk, rst => li, load => ntt_start, en => ei, input => "001", output => counter); 
	zi7_gen_feistels4 : if ( feistels = 4 ) generate
		zi7 <= '1' when counter = 7 else '0';
	end generate;
	zi7_gen_feistels8 : if ( feistels = 8 ) generate
		zi7 <= '1' when counter = 0 else '0';
	end generate;
	
	cstate_gen : process( clk )
	begin				
		if rising_edge(clk) then
			if (rst = '1' ) then
				cstate <= idle;
			else 
				cstate <= nstate;
			end if;
		end if;
	end process;
	
	nstate_proc : process(block_ready, zi7, ntt_ready, cstate )
	begin
		case cstate is
			when idle =>  
				if (block_ready = '1') then
					nstate <= process_ntt;
				else
					nstate <= idle;
				end if;
			when process_ntt =>
				if 	(zi7 = '0') then
					nstate <= process_ntt;
				elsif ( ntt_ready = '1' ) then
					nstate <= hold_output;
				else
					nstate <= idle;
				end if;
			when hold_output =>
				if ( ntt_ready = '1' ) then
					nstate <= hold_output;
				else
					nstate <= idle;
				end if;
		end case;
	end process;
	
	li <= '1' when ((cstate = idle) or (cstate = process_ntt and zi7 = '1')) else '0';
	ei <= '1' when ((cstate = process_ntt) and (zi7 = '0')) else '0';
	ntt_en <= ei or ntt_start;
	
	endsig <= '1' when ((cstate = process_ntt and zi7 = '1' and ntt_ready = '0' and msg_end = '1') or (cstate = hold_output and ntt_ready = '0' and msg_end = '1')) else '0';
	msg_end_clr <= endsig;
	ntt_end_set <= endsig;
	
	ntt_done <= '1' when ((cstate = process_ntt and ntt_ready = '0' and zi7 = '1') or (cstate = hold_output and ntt_ready = '0')) else '0';
	ntt_ready_set <= ntt_done;	  
	
	ntt_start <= '1' when (cstate = idle and block_ready = '1') else '0';
	block_ready_clr <= ntt_start;
	
	sfinal <= '1' when ((cstate = process_ntt and zi7 = '1' and ntt_ready = '0' and msg_end = '1') or (cstate = hold_output and ntt_ready = '0' and msg_end = '1')) else '0';
			
	ctrl_ntt <= ntt_done & ntt_en & ntt_start & counter & sfinal;

end beh;
