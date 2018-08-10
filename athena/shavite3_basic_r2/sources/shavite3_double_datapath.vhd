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

entity shavite3_double_datapath is 		   
generic( rom_style:integer:=DISTRIBUTED; aes_round_style:integer:=AES_ROUND_BASIC);	
port (	            	
	clk 				:in std_logic;
	rst 				:in std_logic;	
	wr_c 				:in std_logic;	
	wr_seg 				:in std_logic;		
	ein 				:in std_logic;
	din 				:in std_logic_vector(w-1 downto 0);
 	dout 				:out std_logic_vector(w-1 downto 0);
	data_sel			:in std_logic_vector(1 downto 0);
	en_keygen			:in std_logic;
	sel_init_kg			:in std_logic;	  
	sel_init_state		:in std_logic;	  
	sel_aes				:in std_logic;
	sel_key			:in std_logic_vector(1 downto 0);
	sel_con			:in std_logic_vector(3 downto 0);
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
	last_block			:out std_logic 
	);
end shavite3_double_datapath;

architecture struct of shavite3_double_datapath is	 
signal rin: std_logic_vector(SHAVITE3_STATE_SIZE_512-1 downto 0);	 
signal  from_round, to_round, to_register,from_round_with_xor, result : std_logic_vector(HASH_SIZE_512-1 downto 0);
signal to_key_gen : std_logic_vector(255 downto 0); 
signal key_left, keyx_left, key_right, keyx_right 	 	: std_logic_vector(127 downto 0); 
signal cnt, length	: std_logic_vector(w-1 downto 0); 
constant zero : std_logic_vector(w-1 downto 0):= (others=>'0');
signal cnt_init	: std_logic_vector(127 downto 0);	  
signal msg_len_tmp	: std_logic_vector(53 downto 0);	  
signal din_reg, cnt_exeption	: std_logic_vector(w-1 downto 0);	  
signal last_wire	: std_logic;
signal wr_f_gen	  : std_logic;
constant bzeros		: std_logic_vector(SHAVITE3_STATE_SIZE_512-1 downto 0):= (others=>'0');
signal cnt_tmp, init_value  : std_logic_vector(53 downto 0);

begin

	-- flag for final segment detection
	din_reg <= din;
	final_segment <= din_reg(0);
	
	-- serial input parallel output
	shfin_gen : sipo generic map ( N => SHAVITE3_STATE_SIZE_512, M =>w) port map (clk => clk, en => ein, input => din_reg, output => rin );

	-- four clock cycles for moving data from sipo to key gen module	
	with data_sel select
	to_key_gen <= 	rin(1023 downto 768) when "00",
			rin(767 downto 512) when "01",
			rin(511 downto 256) when "10",
			rin(255 downto 0) when others;
	
	-- sub keys generator
	skg : 
	entity work.shavite3_double_key_gen(shavite3_double_key_gen) 	
	generic map (rom_style=>rom_style, aes_round_style=>aes_round_style)
	port map( clk=> clk, rst=>rst, en=>en_keygen,  sel_aes=>sel_aes, sel_init=>sel_init_kg, sel_key=>sel_key, 
	sel_con=>sel_con, input=>to_key_gen, salt=>SHAVITE3_TEMPORARY_SALT_512, cnt=>cnt_init, keyx_left=>keyx_left, key_left=>key_left,
	keyx_right=>keyx_right, key_right=>key_right);	 
					
	-- this counter is used for main round next value computations
	init_value <= std_logic_vector(to_unsigned(1, 54));
	countern_gen1 : countern generic map (N =>54, step=>1, style =>COUNTER_STYLE_1) 
	port map (clk=>clk, rst=>rst, load=>en_len, en=>en_ctr, input=> init_value ,  output=>cnt_tmp);
	cnt <= cnt_tmp & "0000000000";

	length <= msg_len_tmp & "0000000000";

	-- last block flag 	
	last_wire <= '1' when (length <= cnt) and (length>zero) else '0';
	last_block <= last_wire;	
		
 	cnt_init <= (cnt_exeption(31 downto 0) & cnt_exeption(63 downto 32)  & zero) when ((last_wire = '1') and (ls_rs_flag='1')) else (cnt(31 downto 0) & cnt(63 downto 32)  & zero);
		
	from_round_with_xor <= ( from_round xor result) when wr_result='1' else from_round;

	to_register <= SHAVITE3_INIT_VALUE_512 when sel_init_state='1' else from_round_with_xor;		  

	-- intermediate values storage register 	
	r_gen 	: regn 
	generic map ( N => HASH_SIZE_512, init => bzeros(HASH_SIZE_512-1 downto 0) ) 
	port map (clk => clk, rst => rst, en => en_state, input => to_register, output => to_round );

	-- SHAvite-3 basic round for 512-bits variant	
	sr : entity work.shavite3_double_round(shavite3_double_round)  
	generic map (rom_style=>rom_style, aes_round_style=>aes_round_style)
	port map (clk => clk, rst=>rst, en=>en_in_round, sel_rd=>sel_rd, input=>to_round, key_left=>key_left, keyx_left=>keyx_left, key_right=>key_right, keyx_right=>keyx_right, output=>from_round);

	-- final digest storage register 
	wr_f_gen <= wr_result or sel_init_state;  
	f_gen 	: regn 
	generic map ( N => HASH_SIZE_512, init => bzeros(511 downto 0) ) 
	port map (clk => clk, rst => rst, en => wr_f_gen, input => to_register, output => result ); --to_register

	-- parallel input serial output
	shfout_gen : piso 
	generic map ( N => HASH_SIZE_512 , M => w ) 
	port map (clk => clk, sel => sel_out, en => eout, input => result, output => dout );
	
	-- counter exception register 
	c<=msg_len_tmp & "0000000000";
	cnt_gen : regn 
	generic map (N=>w, init=>zero(w-1 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_seg, input=>din_reg, output=>cnt_exeption );

	-- len of the message segment 
	seg_gen : regn 
	generic map (N=>54, init=>zero(53 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_c, input=>din_reg(63 downto 10), output=>msg_len_tmp );
	
end struct;