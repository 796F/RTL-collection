-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;		
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.sha3_pkg.all;


entity shabal_compact_controller is
	generic ( h : integer := 256 );
	port (
		-- global
		clk, rst 				: in std_logic;
		src_read, dst_write 	: out std_logic;
		src_ready, dst_ready 	: in std_logic;
		
		-- internal
		final_segment, zc0 		: in std_logic;
		ctrl 					: out std_logic_vector(24 downto 0)
	);
end shabal_compact_controller;

architecture beh of shabal_compact_controller is   
 
	signal pc, pc_in : std_logic_vector(3 downto 0); 
	signal pc_sel : std_logic;
	
	signal lpc, epc : std_logic;	
	
	type state_type is ( reset_1, reset_2, load_len_1, load_len_2, block_load_1, block_load_2, block_load_3, block_load_4, pdata_1, pdata_2, pdata_3, pdata_4, output_msg_1, output_msg_2 );
	signal cstate, nstate : state_type;
	
	signal last_segment, last_segment_set, last_segment_clr : std_logic;
	signal sf, sf_clr, sf_set : std_logic;
	signal pccnt, pccnt_clr, pccnt_set : std_logic;
	
	signal final_cntr : std_logic_vector(1 downto 0); 
	signal efinal_cntr, dfinal_cntr : std_logic;

	-- control out signals			  
	signal ein, sout : std_logic;	-- din dout
	signal lctr, ectr : std_logic;		-- word counter
	signal sm2, sm, em : std_logic; 	-- m
	signal sfinal : std_logic; 		-- misc
	signal sb, eb : std_logic;			-- eb
	signal ec, ecd : std_logic; 			-- c	
	signal sacp, scp, ecp : std_logic; 	-- cp
	signal sw, ew, sw_add : std_logic; 	-- w
	signal sa, ea : std_logic; 			-- a		
	signal c_addr: std_logic_vector(3 downto 0); -- c
	signal caddr_sel : std_logic;	
	-- comparison signals
	signal zpc0, zpc2, zpc4, zpc6, zpc8, zpc9, zpc15 : std_logic;	  
	
	signal src_read_s, dst_write_s : std_logic;	   
begin			
	-- control out signals	assignation
	ctrl( 0)	<= ein ;	ctrl( 1)	<= ea ; 	ctrl( 2)	<= sout ; 		--eout unused
	ctrl( 3) 	<= lctr; 	ctrl( 4)	<= ectr ;
	ctrl( 5)	<= sm2	and not sfinal	  ;	ctrl( 6)	<= sm	and not sfinal	;	ctrl( 7)	<= em	;
	ctrl( 8)	<= sf 	;	ctrl( 9)	<= sfinal;
	ctrl(10)	<= sb	;	ctrl(11)	<= eb	;	 
	ctrl(12)	<= ec;
	ctrl(13) 	<= sacp; 	ctrl(14)	<= scp	;	ctrl(15)	<= ecp 	;
	ctrl(16) 	<= sw	; 	ctrl(17)	<= ew	;	ctrl(18) 	<= sw_add and not sfinal;
	ctrl(19)	<= sa	;
	ctrl(23 downto 20) <= c_addr;
	ctrl(24) <= ecd;
	
	-- same signals	 
	sacp <= sm2;
	scp <= sm2;
	sb <= sm2;
	sa <= sm2;
	
	sf_set <= last_segment_clr;
	
	-- COMPARE
	zpc0  <= '1' when pc = 0  else '0';
	zpc2  <= '1' when pc = 2  else '0';
	zpc4  <= '1' when pc = 4  else '0';		
	zpc6  <= '1' when pc = 6  else '0';
	zpc8  <= '1' when pc = 8  else '0';
	zpc9  <= '1' when pc = 9  else '0';
	zpc15 <= '1' when pc = 15 else '0';
	
	-- counter 1
	pc_in <= conv_std_logic_vector(15,4) when pc_sel = '0' else conv_std_logic_vector(8,4);	   
		
	c_addr <= ((not pc(3)) & (not pc(2)) & (not pc(1)) & (not pc(0))) when caddr_sel = '1' else pc;
			  
	cntr_gen : process( clk ) 
	begin 
		if rising_edge( clk ) then	  
			-- pc
			if ( lpc = '1' ) then				
				pc <= pc_in;
			elsif ( epc = '1' ) then						
				pc <= pc - 1;					 			
			end if;
		end if;
	end process;															
	
	fcntr_gen : process( clk ) 
	begin 
		if rising_edge(clk) then
		-- final_cntr
			if ( rst = '1' or dfinal_cntr = '1' ) then
				final_cntr <= (others => '0');
			elsif ( efinal_cntr = '1' ) then
				final_cntr <= final_cntr + 1;
			end if;
		end if;
	end process;
	
	last_segment_gen : entity work.sr(struct) port map ( clk => clk, clr => last_segment_clr, set => last_segment_set, o => last_segment );
	sf_gen : entity work.sr(struct) port map ( clk => clk, clr => sf_clr, set => sf_set, o => sf );
	pcnt_gen : entity work.sr(struct) port map ( clk => clk, clr => pccnt_clr, set => pccnt_set, o => pccnt );		
		
	-- state process
	cstate_proc : process ( clk )
	begin
		if rising_edge( clk ) then 
			if rst = '1' then
				cstate <= reset_1;
			else
				cstate <= nstate;
			end if;
		end if;
	end process;	
	
	nstate_proc : process ( cstate, final_segment, src_ready, dst_ready, zpc0, zpc2, zpc4, zpc6, zpc8, zpc9, zpc15, sfinal, final_cntr, pccnt, zc0, last_segment)
	begin
		case cstate is	 
			when reset_1 =>
				nstate <= reset_2;
			when reset_2 =>
				nstate <= load_len_1;
			when load_len_1 =>
				if (src_ready = '1') then
					nstate <= load_len_1;
				elsif (final_segment = '1') then 
					nstate <= load_len_2;
				else 
					nstate <= block_load_1;
				end if;			  				
			when load_len_2 =>
				if (src_ready = '1') then
					nstate <= load_len_2;
				else
					nstate <= block_load_1;
				end if;
			when block_load_1 =>
				if (src_ready = '0' or sfinal = '1') then
					nstate <= block_load_2;
				else
					nstate <= block_load_1;
				end if;
			when block_load_2 =>
				if (src_ready = '0' or sfinal = '1') then
					nstate <= block_load_3;
				else
					nstate <= block_load_2;
				end if;
			when block_load_3 =>
				if ((src_ready = '0' or sfinal = '1') and zpc4 = '1') then
					nstate <= block_load_4;
				else
					nstate <= block_load_3;
				end if;
			when block_load_4 =>
				if ((src_ready = '0'  or (sfinal = '1')) and zpc0 = '1') then
					nstate <= pdata_1;
				else
					nstate <= block_load_4;
				end if;
			when pdata_1 =>
				if ( zpc6 = '1' ) then
					nstate <= pdata_2;											
				else 
					nstate <= pdata_1;
				end if;
			when pdata_2 =>
				if ( zpc9 = '1' and pccnt = '1') then
					nstate <= pdata_3;
				else 
					nstate <= pdata_2;
				end if;
			when pdata_3 =>
				if ( zpc2 = '1') then
					nstate <= pdata_4;
				else 
					nstate <= pdata_3;
				end if;
			when pdata_4 =>
				if ( zpc9 = '0' ) then
					nstate <= pdata_4;
				elsif (zpc9 = '1' and final_cntr = "11") then	  
					if ( h = 512 ) then
						nstate <= output_msg_2;
					else
						nstate <= output_msg_1;
					end if;
				elsif  (zpc9 = '1' and ((zc0 = '0') or (zc0 = '1' and last_segment = '1'))) then
					nstate <= block_load_1;
				else 
					nstate <= load_len_1;
				end if;
			when output_msg_1 =>
				if ( zpc8 = '1' ) then
					nstate <= output_msg_2;
				else
					nstate <= output_msg_1;
				end if;	
			when output_msg_2 =>
				if ( zpc0 = '1' and dst_ready = '0') then
					nstate <= reset_1;
				else
					nstate <= output_msg_2;
				end if;	
		end case;				
	end process;	  
	
	output_proc : process ( cstate, src_ready, sfinal, zc0, zpc0, zpc2, zpc4, zpc8, zpc9, zpc15, final_segment, last_segment, zc0, pccnt , dst_ready  )
	begin			  
		dst_write_s <= '0'; src_read_s <= '0';
		ein <= '0'; sout <= '0';	-- i/o 
		pccnt_set <= '0'; pccnt_clr <= '0';		-- pccnt		
		lctr <= '0'; ectr <= '0';				-- c counter		
		sm2 <= '0'; sm <= '0'; em <= '0'; 		-- m
		eb <= '0';								-- b 	 ( sb <= '0'; )
		ec <= '0'; ecd <= '0';					-- c	
		ecp <= '0'; 							-- cp	 (sacp <= '0'; scp <= '0'; )	
				
		sw <= '0'; ew <= '0'; sw_add <= '0'; 	-- w
		ea <= '0'; 								-- a	 (sa <= '0'; )		   
		last_segment_set <= '0'; last_segment_clr <= '0';				-- last_segment			
		
		-- internals	  
		caddr_sel <= '0';			-- select c address
		lpc <= '0'; epc <= '0'; pc_sel <= '0'; -- pc control		
		efinal_cntr <= '0'; dfinal_cntr <= '0'; -- final cntr
		case cstate is	 
			when reset_1 =>	  
				pccnt_clr <= '1';
				ew <= '1'; sw_add <= '1';
				last_segment_clr <= '1';	
				lpc <= '1';	 	
				dfinal_cntr <= '1';
			when reset_2 =>
				ew <= '1';	
				caddr_sel <= '0';							
			when load_len_1 =>	 								
				if ( src_ready = '0' ) then
					ein <= '1';
					lctr <= '1';   
					src_read_s <= '1';
				end if;	   
				if ( final_segment = '1' ) then
					last_segment_set <= '1';
				end if;						
			when load_len_2 =>	 		   							
				if (src_ready = '0') then
					src_read_s <= '1';   
				end if;
			when block_load_1 =>   
				sm2 <= '1';				 
				sw <= '1'; sw_add <= '1'; 				
				caddr_sel <= '1';								
				if ( src_ready = '0'  and sfinal = '0') then	  
					ein <= '1';		 					
					src_read_s <= '1';
				end if;
				if (src_ready = '0' and sfinal = '0') then
					ectr <= '1';
				end if;
				if (src_ready = '0' or sfinal = '1') then -- or sfinal = '1'					
					em <= '1';
					ec <= '1'; 	 
					ecd <= '1';
					ecp <= '1';	
					eb <= '1';	  
					ea <= '1';
					ew <= '1'; 
					epc <= '1';
				end if;			
			when block_load_2 =>	
				sm2 <= '1';
				sw <= '1';			
				caddr_sel <= '1';
				if (( src_ready = '0' ) and (sfinal = '0')) then
					src_read_s <= '1';  
					ein <= '1';
				end if;
				if (src_ready = '0' or sfinal = '1') then										
					em <= '1';									
					ec <= '1';	
					ecd <= '1';
					ecp <= '1';	  
					eb <= '1';	 
					ea <= '1';
					ew <= '1';
					epc <= '1';
				end if;				
			when block_load_3 =>   
				sm2 <= '1';
				caddr_sel <= '1';
				if (src_ready = '0' and sfinal = '0') then
					src_read_s <= '1';   
					ein <= '1';	
				end if;
				if (src_ready = '0' or sfinal = '1') then					
					em <= '1';	
					ec <= '1';	  
					ecd <= '1';
					ecp <= '1';	 
					eb <= '1';	 
					ea <= '1';		   
					epc <= '1';
				end if;				
			when block_load_4 =>	 
				pc_sel <= '1';	 
				caddr_sel <= '1';
				sm2 <= '1';			  			   					
				if ( zpc0 = '1') then
					lpc <= '1';
				end if;			   							
				if (( src_ready = '0' ) and (sfinal = '0')) then
					src_read_s <= '1';	   
					ein <= '1';	
				end if;	  											
				if (src_ready = '0' or sfinal = '1') then					
					em <= '1';
					ec <= '1';	
					ecd <= '1';
					eb <= '1';	  
					epc <= '1';
				end if;				
			when pdata_1 =>			
				ec <= '1';
				pccnt_clr <= '1';	
				em <= '1';
				eb <= '1';	  
				ea <= '1';	   
				epc <= '1'; 
			when pdata_2 =>	
				ec <= '1';
				em <= '1';
				ecp <= '1';	
				eb <= '1';
				ea <= '1';			 
				epc <= '1';
				if ( zpc8 = '1' ) then
					pccnt_set <= '1';
				end if;				
			when pdata_3 =>	  
				ec <= '1';
				em <= '1'; 
				ecp <= '1';
				eb <= '1';	
				ea <= '1';		  
				epc <= '1';
				pccnt_clr <= '1'; 
				if ( last_segment = '0' or zc0 = '0' ) then
					sm <= '1'; 
				end if;
			when pdata_4 =>	
				ec <= '1';
				em <= '1';
				eb <= '1';
				ea <= '1';	 				
				epc <= '1';
				if ( last_segment = '0' or zc0 = '0' ) then
					sm <= '1'; 
				end if;
				if ( zpc9 = '1' ) then	 
					lpc <= '1';
				end if;																	
				if ( last_segment = '1' and zc0 = '1' and zpc9 = '1') then
					efinal_cntr <= '1';
				end if;
			when output_msg_1 =>
				eb <= '1';
				epc <= '1';
			when output_msg_2 =>				
				if (dst_ready = '0' ) then					
					dst_write_s <= '1';
				end if;
				if (dst_ready = '0') then
					epc <= '1';
					sout <= '1';					   
					eb <= '1';
				end if;
		end case;				
	end process;	 
	src_read <= src_read_s;
	dst_write <= dst_write_s;

	-- sf controls
	sf_clr <= '1' when (cstate = block_load_4 and src_ready = '0' and zpc0 = '1') else '0'; 
	-- final
	sfinal <= '1' when (final_cntr /= 0) else '0';	 
	
end beh;
