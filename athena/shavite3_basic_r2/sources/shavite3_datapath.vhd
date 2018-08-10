-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
use work.sha3_pkg.all;
use work.shavite3_pkg.ALL;

-- SHAvite-3 datapath for 512-bit digest variant
-- possible generics values: 
-- rom_style = {DISTRIBUTED, COMBINATIONAL}  
-- aes_round_style = {AES_ROUND_BASIC, AES_ROUND_TBOX} and 
-- all combinations allowed, but with TBOX implementation rom_style generic is not used 

entity shavite3_datapath is 		   
generic( rom_style:integer:=DISTRIBUTED; aes_round_style:integer:=AES_ROUND_BASIC);	
port (	            	
	clk 				:in std_logic;
	rst 				:in std_logic;	
	wr_c 				:in std_logic;	
	wr_seg				:in std_logic;
	ein 				:in std_logic;
	din 				:in std_logic_vector(w-1 downto 0);
 	dout 				:out std_logic_vector(w-1 downto 0);
	data_sel			:in std_logic_vector(1 downto 0);
	en_keygen			:in std_logic;
	sel_init_kg			:in std_logic;	  
	sel_init_state		:in std_logic;	  
	sel_aes				:in std_logic;
	sel_con_cnt1		:in std_logic_vector(1 downto 0);
	sel_con_cnt2		:in std_logic_vector(1 downto 0);
	sel_con_cnt3		:in std_logic;
	sel_con_cnt4		:in std_logic;
	en_ctr				:in std_logic; 
	en_in_round			:in std_logic; 
	sel_rd				:in std_logic_vector (1 downto 0); 	
	eout				:in std_logic;
	en_len				:in std_logic;
	wr_result			:in std_logic;
	sel_out				:in std_logic;	 
	c					:out std_logic_vector(63 downto 0); 
	en_state			:in std_logic;
	final_segment		:out std_logic;
	ls_rs_flag			:in std_logic;
	last_block			:out std_logic );
end shavite3_datapath;

architecture struct of shavite3_datapath is	 
signal rin: std_logic_vector(SHAVITE3_STATE_SIZE_256-1 downto 0);	 
signal  from_round, to_round, to_register,from_round_with_xor, result : std_logic_vector(255 downto 0);
signal to_key_gen	 	 	: std_logic_vector(127 downto 0); 
signal key, keyx	 	 	: std_logic_vector(127 downto 0); 
signal cnt, length	  		: std_logic_vector(63 downto 0); 
constant zero				: std_logic_vector(63 downto 0):= (others=>'0');
signal cnt_init				: std_logic_vector(63 downto 0);	  
signal msg_len_tmp			: std_logic_vector(54 downto 0);	  
signal din_reg, cnt_exeption		: std_logic_vector(63 downto 0);	  
signal last_wire			: std_logic;
signal wr_f_gen	  			: std_logic;
constant bzeros				: std_logic_vector(SHAVITE3_STATE_SIZE_256-1 downto 0):= (others=>'0');
signal 	cnt_tmp , init_value 			: std_logic_vector(54 downto 0);
begin

	-- flag for final segment detection
	din_reg <= din;
	final_segment <= din_reg(0);
	
	-- serial input parallel output
	shfin_gen : sipo 
	generic map ( N => 512, M =>w) 
	port map (clk => clk, en => ein, input => din_reg, output => rin );

	-- four clock cycles for moving data from sipo to key gen module
	with data_sel select
	to_key_gen <= 	rin(511 downto 384) when "00",
					rin(383 downto 256) when "01",
					rin(255 downto 128) when "10",
					rin(127 downto 0) when others;

	-- sub keys generator					
	skg : 
		entity work. shavite3_key_gen(shavite3_key_gen) 	
		generic map (rom_style=>rom_style, aes_round_style=>aes_round_style)
		port map( clk=> clk, rst=>rst, en=>en_keygen, sel_aes=>sel_aes, sel_init=>sel_init_kg, 
		sel_con_cnt1=>sel_con_cnt1, sel_con_cnt2=>sel_con_cnt2, sel_con_cnt3=>sel_con_cnt3, sel_con_cnt4=>sel_con_cnt4,
		input=>to_key_gen, salt=>SHAVITE3_TEMPORARY_SALT_256, cnt=>cnt_init, keyx=>keyx, key=>key);	 
					
	-- this counter is used for main round next value computations	
	init_value <= std_logic_vector(to_unsigned(1, 55));
	countern_gen1 : countern 
	generic map (N =>55, step=>1, style =>COUNTER_STYLE_1) 
	port map (clk=>clk, rst=>rst, load=>en_len, en=>en_ctr, input=> init_value ,  output=>cnt_tmp); 
	cnt <= cnt_tmp & "000000000";

	length <= msg_len_tmp & "000000000";
	
	-- last block flag 		
	last_wire <= '1' when (length <= cnt) and (length>zero) else '0';
	last_block <= last_wire;	
		
	cnt_init <= (cnt_exeption(31 downto 0) & cnt_exeption(63 downto 32)) when ((last_wire = '1') and (ls_rs_flag='1')) else (cnt(31 downto 0) & cnt(63 downto 32));	
		
	from_round_with_xor <= (from_round xor result) when wr_result='1' else from_round;

	to_register <= SHAVITE3_INIT_VALUE_256 when sel_init_state='1' else from_round_with_xor;		  
	-- intermediate values storage register
	r_gen 	: regn 
	generic map ( N => 256, init => bzeros(255 downto 0)) 
	port map (clk => clk, rst => rst, en => en_state, input => to_register, output => to_round );

	-- SHAvite-3 basic round for 256-bits variant
	sr : entity work.shavite3_round(shavite3_round)  
	generic map (rom_style=>rom_style, aes_round_style=>aes_round_style)
	port map (clk => clk, rst=>rst, en=>en_in_round, sel_rd=>sel_rd, input=>to_round, key=>key, keyx=>keyx, output=>from_round);

	wr_f_gen <= wr_result or sel_init_state;

	-- final digest storage register 	
	f_gen 	: regn 
	generic map ( N => 256, init => bzeros(255 downto 0)) 
	port map (clk => clk, rst => rst, en => wr_f_gen, input => to_register, output => result );

	-- parallel input serial output	
	shfout_gen : piso 
	generic map ( N => 256 , M => w ) 
	port map (clk => clk, sel => sel_out, en => eout, input => result, output => dout );

		-- counter exception register
	c<=msg_len_tmp & "000000000";
	cnt_gen : regn 
	generic map (N=>64, init=>zero(63 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_seg, input=>din_reg, output=>cnt_exeption );

		-- len of the message segment 
	seg_gen : regn 
	generic map (N=>55, init=>zero(54 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_c, input=>din_reg(63 downto 9), output=>msg_len_tmp );
	
end struct;