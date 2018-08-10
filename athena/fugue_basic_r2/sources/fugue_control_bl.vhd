-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;
use work.fugue_pkg.all;

-- possible generics values: hs = {HASH_SIZE_256, HASH_SIZE_512} 

entity fugue_control_bl is 
generic (hs: integer:=HASH_SIZE_256);
port 
(
	clk				:in std_logic;
	rst				:in std_logic;
	mode1_n			:out std_logic;
	pad_n			:out std_logic;
	mode2_n			:out std_logic;
	mode3_n			:out std_logic;
	mode4_n			:out std_logic;
	final_n 		:out std_logic;
	src_ready		:in std_logic;
	cnt_lt			:in std_logic;
	dst_ready		:in std_logic;	 
	loop_busy		:in std_logic;	 
	loop_cnt_en		:out std_logic;
	load_seg_len	:out std_logic;
	cnt_rst 		:out std_logic;
	cnt_en 			:out std_logic;
	src_read 		:out std_logic;
	dst_write 		:out std_logic;	 
	sel_piso 		:out std_logic;	 	
	wr_piso 		:out std_logic;
	wr_state		:out std_logic;	
	last_block		:in std_logic; 
	stop_loop_busy	:out std_logic;
  	dp_rst 			:out std_logic);
end fugue_control_bl;

architecture fsm256 of fugue_control_bl is 

signal	mode1_n_wire			: std_logic;
signal	pad_n_wire				: std_logic;
signal	mode2_n_wire			: std_logic;
signal	mode3_n_wire			: std_logic;
signal	mode4_n_wire			: std_logic;
signal	final_n_wire 			: std_logic;	 
signal	wr_state_wire			: std_logic;
signal	load_seg_len_wire		: std_logic;
signal	cnt_rst_wire 			: std_logic;
signal	cnt_en_wire 			: std_logic;
signal	src_read_wire 			: std_logic;
signal	dst_write_wire 			: std_logic;
signal	sel_piso_wire 			: std_logic; 	
signal	wr_piso_wire	 		: std_logic; 
signal	dp_rst_wire 			: std_logic;
signal 	loop_cnt_en_wire		: std_logic;

type state_type is (idle, start,  len_idle, len, ctr_idle, ctr, lsync, lsync_idle,
dummy, fetch_data_idle, fetch_data, second_idle, 
lb_start, lb_len_idle, lb_len, lb_ctr_idle, lb_ctr, 
lb_fetch_data_idle, lb_fetch_data, lb_delay1, lb_delay1_idle, lb_delay2, lb_delay2_idle, 
lb_delay3, fin_mode2, fin_mode2_done, fin_mode2_done2, fin_mode3, fin_mode3_done, fin_mode3_done_idle, 
fin_mode3_done2, fin_mode3_done2_idle , fin_mode4, fin_mode4_idle, fin_final, fin_final_idle, fin_final_done, 
fin_final_done2, fin_final_done2_idle); 
signal cstate, nstate : state_type;

begin 
	
	tran_proc : process ( clk )
	begin
		if (clk'event and clk = '1') then 
			if rst = '1' then
				cstate <= idle;
			else
				cstate <= nstate;
			end if;
		end if;
	end process;
	
	-- state transition 
	cond_proc: process ( rst, cstate , cnt_lt, src_ready, dst_ready, last_block )
	begin
		

			case cstate is
				when idle => 
					if src_ready = '0' then 
						nstate <= start; 
					else
						nstate <= idle; 
					end if;	

				when start => 
					if src_ready = '0' then 
							nstate <= len;
					else
						nstate <= len_idle; 
					end if;	 
					
					
				when len_idle => 
					if src_ready = '0' then 
						nstate <= len; 
					else
						nstate <= len_idle; 
					end if;
					
				when len => 
					if src_ready = '0' then  
						if last_block ='0' then
							nstate <= lsync; 
                        else
							nstate <= dummy;
						end if;	
					else
						nstate <= lsync_idle; 
					end if;	  
					
				when lsync_idle => 
					if src_ready = '0' then 
						nstate <= lsync; 
					else
						nstate <= lsync_idle; 
					end if;
					
				when lsync => 
					if src_ready = '0' then  
						if last_block ='0' then
							nstate <= ctr; 
                        else
							nstate <= dummy;
						end if;	
					else
						nstate <= ctr_idle; 
					end if;	  	
					
					
				when ctr_idle => 
					if src_ready = '0' then 
						nstate <= len; 
					else
						nstate <= len_idle; 
					end if;	   
					
				when dummy => 
					nstate <= lb_start;
					
			
				when ctr => 
					if src_ready = '0' then 
						nstate <= fetch_data; 
					else
						nstate <= fetch_data_idle; 
					end if;	 					
					
										
  				when fetch_data_idle => 
					if src_ready = '0' then 
						nstate <= fetch_data; 
					else
						nstate <= fetch_data_idle; 
					end if;		 
					
					
										
				when fetch_data => 
					if src_ready = '0' then  
						if cnt_lt = '1' then 
							nstate <= fetch_data;
						else 
								nstate <= second_idle;
						end if;
						
					
					else
						nstate <= fetch_data_idle; 
					end if;		

	
				when second_idle => 
					if src_ready = '0' then  
							nstate <= start;   
					else
						nstate <= second_idle; 
					end if;
			
		
				when lb_start => 
					if src_ready = '0' then 
							nstate <= lb_len;
					else
						nstate <= lb_len_idle; 
					end if;	 
					
				
				when lb_len_idle => 
					if src_ready = '0' then 
						nstate <= lb_len; 
					else
						nstate <= lb_len_idle; 
					end if;
					
				when lb_len => 
					if src_ready = '0' then  
							nstate <= lb_ctr; 
					else
						nstate <= lb_ctr_idle; 
					end if;	 
					
				when lb_ctr_idle => 
					if src_ready = '0' then 
						nstate <= lb_len; 
					else
						nstate <= lb_len_idle; 
					end if;	   
					
					
				when lb_ctr => 
					if src_ready = '0' then 
						nstate <= lb_fetch_data; 
					else
						nstate <= lb_fetch_data_idle; 
					end if;	 					
					
											
  				when lb_fetch_data_idle => 
					if src_ready = '0' then 
						nstate <= lb_fetch_data; 
					else
						nstate <= lb_fetch_data_idle; 
					end if;		 
					
														
				when lb_fetch_data => 
					if src_ready = '0' then  
						if cnt_lt = '1' then 
							nstate <= lb_fetch_data;
						else
								nstate <= lb_delay1;
						end if;					
					else
						nstate <= lb_delay1_idle; 
					end if;		

  				when lb_delay1 => 
					if src_ready = '0' then 
						nstate <= lb_delay2; 
					else
						nstate <= lb_delay2_idle; 
					end if;					
					
  				when lb_delay1_idle => 
					if src_ready = '0' then 
						nstate <= lb_delay1; 
					else
						nstate <= lb_delay2_idle; 
					end if;	

  				when lb_delay2 => 
					if src_ready = '0' then 
						nstate <= lb_delay3; 
					else
						nstate <= lb_delay2_idle; 
					end if;					
					
  				when lb_delay2_idle => 
					if src_ready = '0' then 
						nstate <= lb_delay2; 
					else
						nstate <= lb_delay2_idle; 
					end if;						
					
				when lb_delay3 => 
						 nstate <= fin_mode2;
					
				when fin_mode2 => 
					if cnt_lt = '1' then 
						nstate <= fin_mode2;
					else 
						nstate <= fin_mode2_done;
					end if;		
					
				when fin_mode2_done =>
					nstate <= fin_mode2_done2;
				
				when fin_mode2_done2 => 
					nstate <= fin_mode3;
					
					
				when fin_mode3 => 
					if cnt_lt = '1' then 
						nstate <= fin_mode3;
					else   
						   	if dst_ready = '0' then
								nstate <= fin_mode3_done;
						   	else 
							   nstate <= fin_mode3_done_idle;
							end if;   
					end if;	
				
				when fin_mode3_done_idle =>
					if dst_ready = '0' then
						nstate <= fin_mode3_done;
					else 
						nstate <= fin_mode3_done_idle;
					end if;			
					
				
				when fin_mode3_done =>	  
					if dst_ready = '0' then 
						nstate <= fin_mode3_done2;  
					else 
						nstate <= fin_mode3_done2_idle;
					end if;
					
				when fin_mode3_done2_idle => 
					if dst_ready = '0' then
						nstate <= fin_mode3_done2;
					else 
						nstate <= fin_mode3_done2_idle;
					end if;			
				
						
				when fin_mode3_done2 =>		
					if dst_ready ='0' then  	
						nstate <= fin_mode4;
					else 
						nstate <= fin_mode4_idle;
					end if;
					
				when fin_mode4_idle =>
					if dst_ready ='0' then  	
						nstate <= fin_mode4;
					else 
						nstate <= fin_mode4_idle;
					end if;
									
				when fin_mode4 => 
					if dst_ready ='0' then  	
						nstate <= fin_final;
					else 
						nstate <= fin_final_idle;
					end if;
					
				when fin_final_idle => 
					if dst_ready ='0' then  	
						nstate <= fin_final;
					else 
						nstate <= fin_final_idle;
					end if;
					
				
				when fin_final => 
					if dst_ready ='0' then 
						if cnt_lt = '1' then 
							nstate <= fin_final;
						else 
							nstate <= fin_final_done;
						end if;	
					else   
							nstate <= fin_final_idle;
					end if;	
						
				when fin_final_done => 	
					if dst_ready ='0' then
						nstate <= fin_final_done2;
					else 
						nstate <= fin_final_done2_idle;
					end if;
						
				when fin_final_done2_idle => 
					if dst_ready ='0' then
						nstate <= fin_final_done2;
					else 
						nstate <= fin_final_done2_idle;
					end if;
						
				when fin_final_done2 => 
					nstate <= idle;
				
		
				
				when others =>
					nstate <= idle;
					
			end case;
			
	end process;

	-- signals generation	
					
	mode1_n_wire <= '1' when (cstate=start  or cstate=lb_delay1 or cstate=lb_delay3 or cstate=fin_mode2 or cstate=fin_mode2_done or cstate=fin_mode2_done2 or 
	cstate=fin_mode3 or cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final) else '0';			
	
	pad_n_wire <= '1' when (cstate=start or cstate=len or cstate=dummy or cstate=lsync or cstate=ctr or cstate=fetch_data or cstate=lb_start or 
	cstate=lb_len or cstate=lb_ctr or cstate=lb_delay3 or cstate=lb_fetch_data or cstate=fin_mode2 or cstate=fin_mode2_done or 
	cstate=fin_mode2_done2 or cstate=fin_mode3 or cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final) else '0';				
	
	mode2_n_wire <= '1' when (cstate=start or cstate=len or cstate=dummy or  cstate=lsync or cstate=ctr  or cstate=fetch_data or cstate=lb_start or 
	cstate=lb_len or cstate=lb_ctr or cstate=lb_fetch_data or cstate=lb_delay1 or cstate=fin_mode2_done or cstate=fin_mode2_done2 or 
	cstate=fin_mode3 or cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final) else '0';			
	
	mode3_n_wire <= '1' when (cstate=start or cstate=len or cstate=dummy or cstate=lsync or cstate=ctr  or cstate=fetch_data or cstate=lb_start or 
	cstate=lb_len or cstate=lb_ctr  or cstate=lb_fetch_data or cstate=lb_delay1 or cstate=lb_delay3 or cstate=fin_mode2 or cstate=fin_mode3_done or 
	cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final) else '0';			
	
	mode4_n_wire <= '1' when (cstate=start or cstate=len or cstate=dummy or  cstate=lsync or cstate=ctr  or cstate=fetch_data or cstate=lb_start or 
	cstate=lb_len or cstate=lb_ctr  or cstate=lb_fetch_data or cstate=lb_delay1 or cstate=lb_delay3 or cstate=fin_mode2 or cstate=fin_mode2_done or 
	cstate=fin_mode2_done2 or cstate=fin_mode3  or cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final) else '0';			
	
	final_n_wire  <= '1' when (cstate=start or cstate=len or cstate=dummy or cstate=lsync or cstate=ctr  or cstate=fetch_data or cstate=lb_start or 
	cstate=lb_len or cstate=lb_ctr  or cstate=lb_fetch_data or cstate=lb_delay1 or cstate=lb_delay3 or cstate=fin_mode2 or cstate=fin_mode2_done or 
	cstate=fin_mode2_done2 or cstate=fin_mode3 or cstate=fin_mode3_done ) else '0';				 
		
	load_seg_len_wire <= '1' when (cstate=start) else '0';		
	
	dst_write_wire  <= '1' when  (cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final  or cstate=fin_final_done  ) else '0';--		

	sel_piso_wire  <= '1' when (cstate=fin_mode3 and cnt_lt='0' and dst_ready='0') else '0';	--		 	
	
	wr_piso_wire <= '1' when (cstate=fin_mode3 and cnt_lt='0' and dst_ready='0') or (cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4  or cstate=fin_final ) else '0';	-- 		 
			
	dp_rst_wire  <= '1' when (cstate=idle) else '0';
	
	stop_loop_busy <= '1' when (cstate=start or cstate=len or cstate=dummy or cstate=lb_start or cstate=lb_delay1 or cstate=lb_delay2 or cstate=lb_delay3) else '0';	

	src_read_wire  <= '1' when (cstate=start)  or (cstate=len ) or cstate=lb_start or (( cstate=ctr  or cstate=fetch_data   or cstate=lb_len or 
	cstate=lb_ctr  or cstate=lb_fetch_data or cstate=lb_delay1 or   cstate=lb_delay1) and (loop_busy='1')) else '0';			
	
	loop_cnt_en_wire  <= '1' when ((cstate=len and last_block='0')  or cstate=lsync or cstate=ctr  or cstate=fetch_data or cstate=lb_start or
	cstate=lb_len or cstate=lb_ctr or
	cstate=lb_fetch_data or cstate=lb_delay3 or cstate=fin_mode2 or cstate=fin_mode2_done or 
	cstate=fin_mode2_done2 or cstate=fin_mode3 or cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final) else '0';	

	cnt_en_wire  <= '1' when (cstate=len) or (cstate=lb_start and last_block='1') or cstate=lb_delay1 or cstate=lb_delay2  or cstate=lb_delay3 or cstate=fin_mode2 or 
	cstate=fin_final or ((cstate=lsync or cstate=ctr  or cstate=fetch_data or cstate=lb_len or cstate=lb_ctr or cstate=lb_fetch_data or 
	cstate=fin_mode2_done or cstate=fin_mode2_done2 or cstate=fin_mode3 or cstate=fin_mode3_done or 
	cstate=fin_mode3_done2 or cstate=fin_mode4 )and (loop_busy='1')) else '0';			

	cnt_rst_wire  <= '1' when (cstate=start or cstate=lb_start or cstate=lb_delay1) else '0';			
	
	wr_state_wire	 <=  '1' when ((cstate=len and last_block='0') or cstate=lsync or  cstate=ctr or cstate=fetch_data or cstate=lb_start or 
	cstate=lb_len or  cstate=lb_ctr or cstate=lb_fetch_data or cstate=lb_delay1  or cstate=fin_mode2 or cstate=fin_mode2_done or 
	cstate=fin_mode2_done2 or cstate=fin_mode3 or cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final) else '0';		
		
		
-- output from controller is registered 	
	
	out_reg01: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>mode1_n_wire, q=>mode1_n);
	out_reg02: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>pad_n_wire, q=>pad_n);
	out_reg03: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>mode2_n_wire, q=>mode2_n);
	out_reg04: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>mode3_n_wire, q=>mode3_n);
	out_reg05: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>mode4_n_wire, q=>mode4_n);
	out_reg06: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>final_n_wire, q=>final_n);
	out_reg07: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>wr_state_wire, q=>wr_state);
	out_reg08: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>load_seg_len_wire, q=>load_seg_len);
	out_reg09: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>cnt_rst_wire, q=>cnt_rst);
	out_reg10: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>cnt_en_wire, q=>cnt_en);
	out_reg11: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>src_read_wire, q=>src_read);
	out_reg12: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>dst_write_wire, q=>dst_write);
	out_reg13: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>sel_piso_wire, q=>sel_piso);
	out_reg14: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>wr_piso_wire, q=>wr_piso);
	out_reg15: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>dp_rst_wire, q=>dp_rst);
	out_reg16: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>loop_cnt_en_wire, q=>loop_cnt_en);

		
end fsm256;	

architecture fsm512 of fugue_control_bl is 

signal	mode1_n_wire			: std_logic;
signal	pad_n_wire				: std_logic;
signal	mode2_n_wire			: std_logic;
signal	mode3_n_wire			: std_logic;
signal	mode4_n_wire			: std_logic;
signal	final_n_wire 			: std_logic;	 
signal	wr_state_wire			: std_logic;
signal	load_seg_len_wire		: std_logic;
signal	cnt_rst_wire 			: std_logic;
signal	cnt_en_wire 			: std_logic;
signal	src_read_wire 			: std_logic;
signal	dst_write_wire 			: std_logic;
signal	sel_piso_wire 			: std_logic; 	
signal	wr_piso_wire	 		: std_logic; 
signal	dp_rst_wire 			: std_logic;
signal 	loop_cnt_en_wire		: std_logic;

type state_type is (idle, start, len_idle, len, ctr_idle, ctr, lsync, lsync_idle,
dummy, fetch_data_idle, fetch_data, second_idle, 
lb_start, lb_len_idle, lb_len, lb_ctr_idle, lb_ctr, 
lb_fetch_data_idle, lb_fetch_data, lb_delay1, lb_delay1_idle, lb_delay2, lb_delay2_idle, 
lb_delay3, fin_pad, fin_pad_done, fin_pad_done2, fin_mode2, fin_mode2_done, fin_mode2_done2, fin_mode3, 
fin_mode3_done, fin_mode3_done_idle, fin_mode3_done2, fin_mode3_done2_idle , fin_mode4, fin_mode4_idle, 
fin_final, fin_final_idle, fin_final_done, fin_final_done2, fin_final_done2_idle); 
signal cstate, nstate : state_type;

begin 
	
	tran_proc : process ( clk )
	begin
		if (clk'event and clk = '1') then 
			if rst = '1' then
				cstate <= idle;
			else
				cstate <= nstate;
			end if;
		end if;
	end process;
	
	-- state transition
	cond_proc: process ( rst, cstate , cnt_lt, src_ready, dst_ready, last_block )
	begin
		

			case cstate is
				when idle => 
					if src_ready = '0' then 
						nstate <= start; 
					else
						nstate <= idle; 
					end if;	

				when start => 
					if src_ready = '0' then 
							nstate <= len;	
					else
						nstate <= len_idle; 
					end if;	 
					
				
				when len_idle => 
					if src_ready = '0' then 
						nstate <= len; 
					else
						nstate <= len_idle; 
					end if;
					
				when len => 
					if src_ready = '0' then  
						if last_block ='0' then
							nstate <= lsync; 
                        else
							nstate <= dummy;
						end if;	
					else
						nstate <= lsync_idle; 
					end if;	  
					
				when lsync_idle => 
					if src_ready = '0' then 
						nstate <= lsync; 
					else
						nstate <= lsync_idle; 
					end if;
					
				when lsync => 
					if src_ready = '0' then  
						if last_block ='0' then
							nstate <= ctr; 
                        else
							nstate <= dummy;
						end if;	
					else
						nstate <= ctr_idle; 
					end if;	  	
					
					
				when ctr_idle => 
					if src_ready = '0' then 
						nstate <= len; 
					else
						nstate <= len_idle; 
					end if;	   
					
				when dummy => 
					nstate <= lb_start;
					
					
				when ctr => 
					if src_ready = '0' then 
						nstate <= fetch_data; 
					else
						nstate <= fetch_data_idle; 
					end if;	 					
					
												
  				when fetch_data_idle => 
					if src_ready = '0' then 
						nstate <= fetch_data; 
					else
						nstate <= fetch_data_idle; 
					end if;		 
					
					
										
				when fetch_data => 
					if src_ready = '0' then  
						if cnt_lt = '1' then 
							nstate <= fetch_data;
						else
								nstate <= second_idle;
						end if;
						
					
					else
						nstate <= fetch_data_idle; 
					end if;		

	
				when second_idle => 
					if src_ready = '0' then  
							nstate <= start;   	
					else
						nstate <= second_idle; 
					end if;
					
		
				when lb_start => 
					if src_ready = '0' then 
							nstate <= lb_len;
					else
						nstate <= lb_len_idle; 
					end if;	 
					
				
				when lb_len_idle => 
					if src_ready = '0' then 
						nstate <= lb_len; 
					else
						nstate <= lb_len_idle; 
					end if;
					
				when lb_len => 
					if src_ready = '0' then  
							nstate <= lb_ctr; 
					else
						nstate <= lb_ctr_idle; 
					end if;	 
					
				when lb_ctr_idle => 
					if src_ready = '0' then 
						nstate <= lb_len; 
					else
						nstate <= lb_len_idle; 
					end if;	   
					
					
				when lb_ctr => 
					if src_ready = '0' then 
						nstate <= lb_fetch_data; 
					else
						nstate <= lb_fetch_data_idle; 
					end if;	 					
					
					
							
  				when lb_fetch_data_idle => 
					if src_ready = '0' then 
						nstate <= lb_fetch_data; 
					else
						nstate <= lb_fetch_data_idle; 
					end if;		 
					
					
										
				when lb_fetch_data => 
					if src_ready = '0' then  
						if cnt_lt = '1' then 
							nstate <= lb_fetch_data;
						else
								nstate <= lb_delay1;
						end if;
						
					
					else
						nstate <= lb_delay1_idle; 
					end if;		

  				when lb_delay1 => 
					if src_ready = '0' then 
						nstate <=lb_delay2; 
					else
						nstate <= lb_delay2_idle; 
					end if;					
					
  				when lb_delay1_idle => 
					if src_ready = '0' then 
						nstate <= lb_delay1; 
					else
						nstate <= lb_delay2_idle; 
					end if;	

  				when lb_delay2 => 
					if src_ready = '0' then 
						nstate <= lb_delay3; 
					else
						nstate <= lb_delay2_idle; 
					end if;					
					
  				when lb_delay2_idle => 
					if src_ready = '0' then 
						nstate <= lb_delay2; 
					else
						nstate <= lb_delay2_idle; 
					end if;						
					
				when lb_delay3 => 
					nstate <= fin_pad;
				
				
				when fin_pad => 
					if cnt_lt = '1' then 
						nstate <= fin_pad;
					else 
						nstate <= fin_pad_done;
					end if;				  
							
				when fin_pad_done => 	
					nstate <= fin_pad_done2;
				
				when fin_pad_done2 =>
					nstate <= fin_mode2;
				
				when fin_mode2 => 
					if cnt_lt = '1' then 
						nstate <= fin_mode2;
					else 
						nstate <= fin_mode2_done;
					end if;		
					
				when fin_mode2_done =>
					nstate <= fin_mode2_done2;
				
				when fin_mode2_done2 => 
					nstate <= fin_mode3;
					
					
				when fin_mode3 => 
					if cnt_lt = '1' then 
						nstate <= fin_mode3;
					else   
						   	if dst_ready = '0' then
								nstate <= fin_mode3_done;
						   	else 
							   nstate <= fin_mode3_done_idle;
							end if;   
					end if;	
				
				when fin_mode3_done_idle =>
					if dst_ready = '0' then
						nstate <= fin_mode3_done;
					else 
						nstate <= fin_mode3_done_idle;
					end if;			
					
				
				when fin_mode3_done =>	  
					if dst_ready = '0' then 
						nstate <= fin_mode3_done2;  
					else 
						nstate <= fin_mode3_done2_idle;
					end if;
					
				when fin_mode3_done2_idle => 
					if dst_ready = '0' then
						nstate <= fin_mode3_done2;
					else 
						nstate <= fin_mode3_done2_idle;
					end if;			
				
						
				when fin_mode3_done2 =>		
					if dst_ready ='0' then  	
						nstate <= fin_mode4;
					else 
						nstate <= fin_mode4_idle;
					end if;
					
				when fin_mode4_idle =>
					if dst_ready ='0' then  	
						nstate <= fin_mode4;
					else 
						nstate <= fin_mode4_idle;
					end if;
				
										
				when fin_mode4 => 
					if dst_ready ='0' then  	
						nstate <= fin_final;
					else 
						nstate <= fin_final_idle;
					end if;
					
				when fin_final_idle => 
					if dst_ready ='0' then  	
						nstate <= fin_final;
					else 
						nstate <= fin_final_idle;
					end if;
					
				
				when fin_final => 
					if dst_ready ='0' then 
						if cnt_lt = '1' then 
							nstate <= fin_final;
						else 
							nstate <= fin_final_done;
						end if;	
					else   
							nstate <= fin_final_idle;
					end if;	
						
				when fin_final_done => 	
					if dst_ready ='0' then
						nstate <= fin_final_done2;
					else 
						nstate <= fin_final_done2_idle;
					end if;
						
				when fin_final_done2_idle => 
					if dst_ready ='0' then
						nstate <= idle;--fin_final_done2;
					else 
						nstate <= fin_final_done2_idle;
					end if;
						
				when fin_final_done2 => 
				nstate <= idle;	
				
				when others =>
					nstate <= idle;
					
			end case;
			
	end process;		
		
	-- signals generation
	
	mode1_n_wire <= '1' when (cstate=start  or cstate=lb_delay1 or cstate=lb_delay2 or cstate=lb_delay3 or cstate=fin_pad_done or cstate=fin_pad_done2 or cstate=fin_pad or 
	cstate=fin_mode2 or cstate=fin_mode2_done or cstate=fin_mode2_done2 or cstate=fin_mode3 or cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4 or 
	cstate=fin_final) else '0';			
							  
	pad_n_wire <= '1' when (cstate=start or cstate=len or cstate=dummy or cstate=lsync or cstate=ctr or cstate=fetch_data or cstate=lb_start or 
	cstate=lb_len or cstate=lb_ctr or cstate=lb_fetch_data or cstate=fin_pad_done or cstate=fin_pad_done2 or cstate=fin_mode2 or cstate=fin_mode2_done or 
	cstate=fin_mode2_done2 or cstate=fin_mode3 or cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final) else '0';				
	
	mode2_n_wire <= '1' when (cstate=start or cstate=len or cstate=dummy or  cstate=lsync or cstate=ctr  or cstate=fetch_data or cstate=lb_start or 
	cstate=lb_len or cstate=lb_ctr or cstate=lb_fetch_data or cstate=lb_delay1 or cstate=lb_delay2 or cstate=lb_delay3 or cstate=fin_pad or 
	cstate=fin_mode2_done or cstate=fin_mode2_done2 or cstate=fin_mode3 or cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final) else '0';			
	
	mode3_n_wire <= '1' when (cstate=start or cstate=len or cstate=dummy or cstate=lsync or cstate=ctr  or cstate=fetch_data or cstate=lb_start or 
	cstate=lb_len or cstate=lb_ctr  or cstate=lb_fetch_data or cstate=lb_delay1 or cstate=lb_delay2  or cstate=lb_delay3  or cstate=fin_pad or 
	cstate=fin_pad_done or cstate=fin_pad_done2 or cstate=fin_mode2 or cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final) else '0';			
	
	mode4_n_wire <= '1' when (cstate=start or cstate=len or cstate=dummy or  cstate=lsync or cstate=ctr  or cstate=fetch_data or cstate=lb_start or 
	cstate=lb_len or cstate=lb_ctr  or cstate=lb_fetch_data or cstate=lb_delay1 or cstate=lb_delay2 or cstate=lb_delay3 or cstate=fin_pad or 
	cstate=fin_pad_done or cstate=fin_pad_done2 or cstate=fin_mode2 or cstate=fin_mode2_done or cstate=fin_mode2_done2 or cstate=fin_mode3  or cstate=fin_mode3_done2 or 
	cstate=fin_mode4 or cstate=fin_final) else '0';			
	
	final_n_wire  <= '1' when (cstate=start or cstate=len or cstate=dummy or cstate=lsync or cstate=ctr  or cstate=fetch_data or cstate=lb_start or 
	cstate=lb_len or cstate=lb_ctr  or cstate=lb_fetch_data or cstate=lb_delay1 or cstate=lb_delay2 or cstate=lb_delay3 or cstate=fin_pad or 
	cstate=fin_pad_done or cstate=fin_pad_done2 or cstate=fin_mode2 or cstate=fin_mode2_done or cstate=fin_mode2_done2 or cstate=fin_mode3 or cstate=fin_mode3_done ) else '0';				 
		
	load_seg_len_wire <= '1' when (cstate=start) else '0';		
			
	dst_write_wire  <= '1' when  (cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final  or cstate=fin_final_done  ) else '0';--		

	sel_piso_wire  <= '1' when (cstate=fin_mode3 and cnt_lt='0' and dst_ready='0') else '0';	--		 	
	
	wr_piso_wire <= '1' when (cstate=fin_mode3 and cnt_lt='0' and dst_ready='0') or (cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4  or cstate=fin_final ) else '0';	-- 		 	
		
	dp_rst_wire  <= '1' when (cstate=idle) else '0';
	
	stop_loop_busy <= '1' when (cstate=start or cstate=len or cstate=dummy or cstate=lb_delay1 or cstate=lb_delay2 ) else '0';	

	src_read_wire  <= '1' when (cstate=start)  or (cstate=len ) or (cstate=dummy ) or (cstate=fin_final_done2) or(( cstate=ctr  or cstate=fetch_data   or cstate=lb_len or 
	cstate=lb_ctr  or cstate=lb_fetch_data or cstate=lb_delay1 or   cstate=lb_delay1) and (loop_busy='0')) else '0';			
  
	loop_cnt_en_wire  <= '1' when ((cstate=len and last_block='0') or cstate=dummy  or cstate=lsync or cstate=ctr  or cstate=fetch_data or 
	cstate=lb_start or cstate=lb_len or cstate=lb_ctr or cstate=lb_fetch_data or cstate=lb_delay2 or cstate=lb_delay3 or cstate=fin_pad  or 
	cstate=fin_mode2_done or cstate=fin_mode2_done2 or cstate=fin_mode3 or cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final) else '0';	
											
	cnt_en_wire  <= '1' when (cstate=len)  or cstate=lb_delay2 or cstate=fin_pad_done or cstate=fin_pad_done2 or cstate=fin_mode2 or cstate=fin_final or 
	((cstate=ctr or cstate=fetch_data  or cstate=lb_len or cstate=lb_ctr or cstate=lb_fetch_data or cstate=fin_pad  or 
	cstate=fin_mode2_done or cstate=fin_mode2_done2 or cstate=fin_mode3 or cstate=fin_mode3_done or cstate=fin_mode3_done2 or cstate=fin_mode4 )and (loop_busy='0')) else '0';			

	cnt_rst_wire  <= '1' when (cstate=start or  cstate=lb_delay1) else '0';		

	wr_state_wire	 <=  '1' when ((cstate=len and last_block='0') or cstate=lsync or  cstate=ctr or cstate=fetch_data  or cstate=lb_start or 
	cstate=dummy or cstate=lb_len or  cstate=lb_ctr or cstate=lb_fetch_data or cstate=lb_delay1  or cstate=lb_delay3  or cstate=fin_pad or 
	cstate=fin_pad_done or cstate=fin_pad_done2 or cstate=fin_mode2 or cstate=fin_mode2_done or cstate=fin_mode2_done2 or cstate=fin_mode3 or cstate=fin_mode3_done or 
	cstate=fin_mode3_done2 or cstate=fin_mode4 or cstate=fin_final) else '0';		
		
-- output from controller is registered 	
	
	out_reg01: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>mode1_n_wire, q=>mode1_n);
	out_reg02: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>pad_n_wire, q=>pad_n);
	out_reg03: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>mode2_n_wire, q=>mode2_n);
	out_reg04: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>mode3_n_wire, q=>mode3_n);
	out_reg05: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>mode4_n_wire, q=>mode4_n);
	out_reg06: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>final_n_wire, q=>final_n);
	out_reg07: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>wr_state_wire, q=>wr_state);
	out_reg08: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>load_seg_len_wire, q=>load_seg_len);
	out_reg09: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>cnt_rst_wire, q=>cnt_rst);
	out_reg10: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>cnt_en_wire, q=>cnt_en);
	out_reg11: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>src_read_wire, q=>src_read);
	out_reg12: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>dst_write_wire, q=>dst_write);
	out_reg13: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>sel_piso_wire, q=>sel_piso);
	out_reg14: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>wr_piso_wire, q=>wr_piso);
	out_reg15: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>dp_rst_wire, q=>dp_rst);
	out_reg16: d_ff port map(clk=>clk, rst=>rst, ena=>VCC, d=>loop_cnt_en_wire, q=>loop_cnt_en);
	
end fsm512;	