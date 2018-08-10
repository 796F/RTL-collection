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
-- round_style = {FUGUE_ROUND_BASIC, FUGUE_ROUND_TBOX}
-- all combinations are allowed

entity fugue_datapath_bl is
generic( hs : integer := HASH_SIZE_256; round_style:integer:=FUGUE_ROUND_BASIC);
port (					
		clk				: in std_logic; 
		rst 			: in std_logic;
		load_seg_len	: in std_logic; 
		cnt_rst			: in std_logic; 
		cnt_en			: in std_logic; 
		loop_cnt_en 	: in std_logic; 
		mode1_n			: in std_logic; 
		pad_n			: in std_logic; 
		mode2_n			: in std_logic; 
		mode3_n			: in std_logic; 
		mode4_n			: in std_logic; 
		final_n 		: in std_logic; 
		cnt_lt			: out std_logic; 
		loop_busy 		: out std_logic;  
		sel_piso 		: in std_logic;	 
		wr_piso 		: in std_logic;		
		wr_state		: in std_logic;	
		last_block		: out std_logic; 
		stop_loop_busy	: in std_logic;
		din 			: in std_logic_vector(w-1 downto 0);
		dout 			: out std_logic_vector(w-1 downto 0));
end fugue_datapath_bl;

architecture dp256 of fugue_datapath_bl is

signal from_round, to_round : state;
signal outsig : std_logic_vector(hs-1 downto 0);
signal piso_out : std_logic_vector(w-1 downto 0);
signal loop_bsy : std_logic;   
constant zero	: std_logic_vector(w-1 downto 0):=(others=>'0');	
signal cnt_val_inter_temp : std_logic_vector(w-1-5 downto 0);

begin

	r : countern generic map (N=>FUGUE_WORD_SIZE-5, step=>1, style=>COUNTER_STYLE_1) port map (clk=>clk, rst=>cnt_rst, en=>cnt_en, load=>GND, input=>zero(26 downto 0), output=>cnt_val_inter_temp);
	
	--flags
	flags: entity work.fugue_flags_bl(fugue_flags_bl)
	generic map (hs=>hs)
	port map (clk=>clk, rst=>rst, load_seg_len=> load_seg_len, pad_n=>pad_n, mode2_n=>mode2_n, mode3_n=>mode3_n, mode4_n=>mode4_n, final_n=>final_n, 
	loop_cnt_en=>loop_cnt_en, stop_loop_busy=>stop_loop_busy, din=>din, cnt_val_inter_temp=>cnt_val_inter_temp, last_block=>last_block, loop_busy=>loop_busy, 
	loop_bsy=>loop_bsy, cnt_lt=>cnt_lt); 				
	
	-- storage of intermediate values of hash computation 	
	fs30: entity work.fugue_state(fugue_state) generic map (hs => hs) port map(input => from_round, rst => rst, clk => clk, en => wr_state, output => to_round);
			
	-- basic loop fugue round		
	fr256: 	entity work.fugue_round_bl(a1) 
	generic map (round_style=>round_style)	
	port map (input=>to_round, din=>din,  mode1_n=>mode1_n, mode3_n=>mode3_n, pad_n=>pad_n, loop_bsy=>loop_bsy, output=>from_round);	

	-- output digest words selection function	
	out256: if hs = HASH_SIZE_256 generate 
		outsig<= from_round(1) & from_round(2) & from_round(3) & (from_round(0) XOR from_round(4)) & (from_round(0) XOR from_round(15)) & from_round(16) & from_round(17) & from_round(18);
	end generate;

	-- output buffer
 	out_latch : piso 
	generic map( N=>hs, M=>FUGUE_WORD_SIZE)
	port map(clk=>clk, en =>wr_piso, sel=>sel_piso, input=>outsig, output=>piso_out); 	   	
	
	-- output port assignment	
	dout <= switch_endian_word(x=>piso_out, width=>FUGUE_WORD_SIZE, w=>8);	
				
end dp256;


architecture dp512 of fugue_datapath_bl is
	
signal from_round, to_round  : state_big;
signal outsig : std_logic_vector(hs-1 downto 0);
signal  piso_out : std_logic_vector(w-1 downto 0);
signal loop_cnt : std_logic_vector(1 downto 0);
signal loop_bsy : std_logic;
constant zero :std_logic_vector(w-1 downto 0):=(others=>'0');    
signal cnt_val_inter_temp : std_logic_vector(w-1-5 downto 0);

begin
	-- counter for amount of data processed 
	r : countern generic map (N=>FUGUE_WORD_SIZE-5, step=>1, style=>COUNTER_STYLE_1) port map (clk=>clk, rst=>cnt_rst, en=>cnt_en, load=>GND, input=>zero(26 downto 0), output=>cnt_val_inter_temp);
	
	-- counter for four clock cycles for round 
	lc_ctr : countern generic map (N=>2, step=>1, style=>COUNTER_STYLE_1) port map (clk=>clk, rst=>rst, en=>loop_cnt_en, load=>GND, input=>zero(1 downto 0), output=>loop_cnt);
   
	--flags 
	flags: entity work.fugue_flags_bl(fugue_flags_bl) 
	generic map (hs=>hs)	
	port map (clk=>clk, rst=>rst, load_seg_len=> load_seg_len, pad_n=>pad_n, mode2_n=>mode2_n, mode3_n=>mode3_n, mode4_n=>mode4_n, final_n=>final_n, 
	loop_cnt_en=>loop_cnt_en, stop_loop_busy=>stop_loop_busy, din=>din, cnt_val_inter_temp=>cnt_val_inter_temp, last_block=>last_block, loop_busy=>loop_busy, 
	loop_bsy=>loop_bsy, cnt_lt=>cnt_lt); 
	
	-- storage of intermediate values of hash computation 	
	fs_36: entity work.fugue_state_big(fugue_state_big) generic map (hs => hs) port map( input => from_round, rst => rst, clk => clk, en => wr_state, output => to_round);
		
	-- basic loop fugue round		
	fr512 : entity work.fugue_round_bl_big(a1) 
	generic map (hs=>hs, round_style=>round_style) 
	port map(din=>din, input=>to_round, mode1_n=>mode1_n, mode3_n=>mode3_n, pad_n=>pad_n, loop_bsy=>loop_bsy, loop_cnt=>loop_cnt,  output=>from_round);

	-- output digest words selection function	
	out512: if hs = HASH_SIZE_512 generate 
		outsig <= from_round(1) & from_round(2) & from_round(3) & (from_round(0) xor from_round(4)) & (from_round(0) xor from_round(9)) & from_round(10) & from_round(11) & from_round(12) & (from_round(0) XOR from_round(18)) & from_round(19) & from_round(20) & from_round(21) & (from_round(0) XOR from_round(27)) & from_round(28) & from_round(29) & from_round(30);
	end generate;
 
	-- output buffer
	out_latch : piso 
	generic map( N=>hs, M=>FUGUE_WORD_SIZE)
	port map(clk=>clk, en =>wr_piso, sel=>sel_piso, input=>outsig, output=>piso_out); 	   	
	
	-- output port assignment	
	dout <= switch_endian_word(x=>piso_out, width=>FUGUE_WORD_SIZE, w=>8);	
				
end dp512;
