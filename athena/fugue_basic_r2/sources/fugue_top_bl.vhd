-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;	  
use work.sha3_pkg.all;
use work.fugue_pkg.all;

-- Possible generic values: 
--      hs = {HASH_SIZE_256, HASH_SIZE_512} 
--      round_style = {FUGUE_ROUND_BASIC, FUGUE_ROUND_TBOX}
--
-- All combinations are allowed

entity fugue_top_bl is
    generic( 
        hs : integer := HASH_SIZE_256; 
        round_style:integer:=FUGUE_ROUND_BASIC
    );
    port ( 
            clk 			: in  std_logic;
            rst 			: in  std_logic;
            din 			: in  std_logic_VECTOR (31 downto 0);
            src_ready 		: in  std_logic;
            src_read 		: out  std_logic;
            dout 			: out  std_logic_VECTOR (31 downto 0);
            dst_ready 		: in  std_logic;
            dst_write 		: out  std_logic);
end fugue_top_bl;

architecture struct of fugue_top_bl is

signal load_seg_len, cnt_rst, cnt_en, loop_cnt_en : std_logic;
signal mode1_n, pad_n, mode2_n, mode3_n, mode4_n, final_n : std_logic; 
signal wr_piso, sel_piso : std_logic; 
signal cnt_lt, loop_busy : std_logic;
signal dp_rst, wr_state, last_block, stop_loop_busy : std_logic; 
	
begin
	
	
dp256_gen : if hs=HASH_SIZE_256 generate	
	fugue_dp256: entity work.fugue_datapath_bl(dp256)
	generic map (hs => hs, round_style=>round_style)
	port map( din => din, clk => clk, rst => dp_rst, load_seg_len => load_seg_len, cnt_rst => cnt_rst, cnt_en => cnt_en, loop_cnt_en => loop_cnt_en,
	mode1_n => mode1_n, pad_n => pad_n, mode2_n => mode2_n, mode3_n => mode3_n, mode4_n => mode4_n, final_n => final_n, wr_piso => wr_piso, sel_piso=>sel_piso, 
	cnt_lt => cnt_lt, loop_busy => loop_busy, wr_state=>wr_state, last_block=>last_block, stop_loop_busy=>stop_loop_busy, dout => dout);		
	
	fc : entity work.fugue_control_bl(fsm256)
	generic map(hs=>hs)
	port map(clk => clk, rst => rst, mode1_n => mode1_n, pad_n => pad_n, mode2_n => mode2_n, mode3_n => mode3_n, mode4_n	=> mode4_n,
	final_n => final_n, src_ready =>src_ready, cnt_lt =>cnt_lt, dst_ready => dst_ready, load_seg_len => load_seg_len, loop_busy => loop_busy,
	loop_cnt_en => loop_cnt_en, last_block=>last_block, cnt_rst => cnt_rst, cnt_en =>cnt_en, src_read =>src_read,  dst_write => dst_write,
	stop_loop_busy=>stop_loop_busy, wr_piso => wr_piso, sel_piso=>sel_piso, wr_state=>wr_state, dp_rst => dp_rst);
end generate;

dp512_gen : if hs=HASH_SIZE_512 generate	
	fugue_dp512: entity work.fugue_datapath_bl(dp512)
	generic map (hs => hs, round_style=>round_style)
	port map(
	din => din, clk => clk,	rst => dp_rst, load_seg_len => load_seg_len, cnt_rst => cnt_rst, cnt_en => cnt_en, loop_cnt_en => loop_cnt_en, 
	mode1_n => mode1_n, pad_n => pad_n,	mode2_n => mode2_n,	mode3_n => mode3_n, mode4_n => mode4_n, final_n => final_n,	wr_piso => wr_piso,	
	sel_piso=>sel_piso,	cnt_lt => cnt_lt, loop_busy => loop_busy,	wr_state=>wr_state,	last_block=>last_block,	stop_loop_busy=>stop_loop_busy, dout => dout);	  
	
	fc : entity work.fugue_control_bl(fsm512)
	generic map(hs=>hs)
	port map(clk => clk, rst => rst, mode1_n => mode1_n, pad_n => pad_n, mode2_n => mode2_n, mode3_n => mode3_n, mode4_n	=> mode4_n,
	final_n => final_n, src_ready =>src_ready, cnt_lt =>cnt_lt, dst_ready => dst_ready, load_seg_len => load_seg_len, loop_busy => loop_busy, 
	loop_cnt_en => loop_cnt_en, last_block=>last_block,	cnt_rst => cnt_rst, cnt_en =>cnt_en, src_read =>src_read,  dst_write => dst_write,
	stop_loop_busy=>stop_loop_busy,	wr_piso => wr_piso, sel_piso=>sel_piso, wr_state=>wr_state, dp_rst => dp_rst);
end generate;


end struct;

