-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;
use work.fugue_pkg.all;

-- possible generics values: hs = {HASH_SIZE_256, HASH_SIZE_512} 
entity fugue_flags_bl is 
generic (hs : integer := HASH_SIZE_256);
port (	
	clk 				: in 	std_logic; 
	rst 				: in 	std_logic;
	load_seg_len		: in 	std_logic;
	pad_n				: in 	std_logic;
	mode2_n				: in 	std_logic;
	mode3_n				: in 	std_logic;
	mode4_n				: in 	std_logic;
	final_n				: in 	std_logic;		 
	loop_cnt_en			: in 	std_logic;	  
	stop_loop_busy		: in 	std_logic;
	cnt_val_inter_temp 	: in std_logic_vector(w-1-5 downto 0);
	din 				: in	std_logic_vector(w-1 downto 0);
	last_block			: out 	std_logic;	
	loop_bsy			: out 	std_logic;	
	loop_busy			: out 	std_logic;
	cnt_lt 				: out 	std_logic);
end fugue_flags_bl;

architecture fugue_flags_bl of fugue_flags_bl is   

signal data_cnt, cnt_val : std_logic_vector(w-1 downto 0);

signal loop_cnt, not_loop_cnt : std_logic_vector(1 downto 0);
signal loop_bsy2, loop_busy_reg : std_logic;   
constant zero	: std_logic_vector(w-1 downto 0):=(others=>'0');	
signal cnt_val_inter, last_din, data_cnt_wire : std_logic_vector(w-1 downto 0);	
signal cnt_lt_in, last_block_wire, lb  :std_logic;

begin
	-- flag determining if this is last segment of message
	last_block_wire <= '1' when din(0)='1' else '0';
	lb_dff : d_ff port map (clk=>clk, rst=>rst, ena=>load_seg_len, d=>last_block_wire, q=>lb);
	
	-- last block of the message	
	last_block <= (last_block_wire and load_seg_len) or lb;	
	
	last_din <= (din - x"00000041");
	data_cnt_wire <= last_din when last_block_wire ='1' else din;
	rg: regn generic map (N=>FUGUE_WORD_SIZE, init=>zero) port map ( clk =>clk, rst =>'0', en => load_seg_len, input => data_cnt_wire, output =>data_cnt);
	
	cnt_val_inter <= cnt_val_inter_temp & "00000";
	
	
flags256: if hs=HASH_SIZE_256 generate	
	cnt_lt_in <= '1' when cnt_val_inter+x"20"<cnt_val else '0';	
	cnt_dff : d_ff port map (clk=>clk, rst=>rst, ena=>VCC, d=>cnt_lt_in, q=>cnt_lt); 
   			
		cnt_val <= X"000003c0" when (mode4_n = '0') or (final_n = '0') else 
					X"00000340" when mode3_n = '0' else 
					X"00000160" when mode2_n = '0' else 
					X"00000040" when pad_n = '0' else
					  data_cnt; 

	not_loop_cnt <= not loop_cnt;
	lc_reg : regn generic map (n=>2, init=>zero(1 downto 0)) port map (clk=>clk, rst=>rst, en=>loop_cnt_en, input=>not_loop_cnt, output=>loop_cnt);
	
  	loop_bsy2 <= '1' when (loop_cnt = "00") and (stop_loop_busy='0') else '0';
	l_b_dff : d_ff port map (clk=>clk, rst=>rst, ena=>VCC, d=>loop_bsy2, q=>loop_busy_reg);
    loop_bsy <= loop_busy_reg;
	loop_busy <= loop_busy_reg;		  
end generate;

flags512: if hs=HASH_SIZE_512 generate	
	cnt_lt_in <= '1' when cnt_val_inter<cnt_val else '0';	
	cnt_dff : d_ff port map (clk=>clk, rst=>rst, ena=>VCC, d=>cnt_lt_in, q=>cnt_lt);
		

		cnt_val <= X"00000700" when (mode4_n = '0') or (final_n = '0') else 
					  X"000005C0" when mode3_n = '0' else 
					  X"000003E0" when mode2_n = '0' else 
					  X"00000040" when pad_n = '0' else 
					  data_cnt; 

	loop_bsy2 <= '1' when (loop_cnt /= "11") and (stop_loop_busy='0') else '0';
	l_b_dff : d_ff port map (clk=>clk, rst=>rst, ena=>VCC, d=>loop_bsy2, q=>loop_busy_reg);
    loop_bsy <= loop_busy_reg;
	loop_busy <= loop_bsy2;
	lc_ctr : countern generic map (N=>2, step=>1, style=>COUNTER_STYLE_1) port map (clk=>clk, rst=>rst, en=>loop_cnt_en, load=>GND, input=>zero(1 downto 0), output=>loop_cnt);
end generate;
	
	
	
end fugue_flags_bl;	 

