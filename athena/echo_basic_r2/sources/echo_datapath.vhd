-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;																   
use work.sha3_pkg.all;
use work.echo_pkg.ALL;

-- possible generics values: 
-- hs = {HASH_SIZE_256, HASH_SIZE_512},  
-- aes_round_style = {AES_ROUND_BASIC, AES_ROUND_TBOX} and 
-- rom_style = {DISTRIBUTED, COMBINATIONAL}	
-- all combinations allowed, but with TBOX implementation rom_style generic is not used

entity echo_datapath is 		   
generic( hs:integer :=HASH_SIZE_256; rom_style:integer:=DISTRIBUTED; aes_round_style:integer:=AES_ROUND_BASIC);	
port (	 
		clk 				: in std_logic;
		io_clk 				: in std_logic;
		rst					: in std_logic; 
		din  				: in std_logic_vector(w-1 downto 0);	
		dout 				: out std_logic_vector(w-1 downto 0);	
		ein 				: in std_logic;
		c 					: out std_logic_vector(w-1 downto 0);	
		wr_c				:in std_logic;		
		wr_seg				:in std_logic;		
		sel_rd 				: in std_logic_vector(1 downto 0); 
		wr_ctr				:in std_logic;
		er 					: in std_logic;
		sf 					: in std_logic;
		bf 					: in std_logic;	
		bf_early			: in std_logic;	
		lo 					: in std_logic;		
		wr_key				:in std_logic;					  		
		wr_len				:in std_logic;	
		big_final_mode		:in std_logic_vector(1 downto 0);
		wr_new_block		:in std_logic;		
		last_block			:out std_logic;	
		underflow			:out std_logic;	   
		first_block 		:in std_logic;		
		eo 					: in std_logic;
		final_segment		:out std_logic;
		ls_rs_flag			:in std_logic);
end echo_datapath;

architecture struct256 of echo_datapath is
	signal init_state, to_round, to_register, from_round, to_big_final  : std_logic_vector(b-1 downto 0);
	signal rin : std_logic_vector(ECHO_DATA_SIZE_BIG-1 downto 0);
	signal eout, bf_reg, sel, rst_ctr, wr_result : std_logic;
	signal  key2 : std_logic_vector(w-1 downto 0);	
	constant zero : std_logic_vector(b-ECHO_DATA_SIZE_BIG-1 downto 0):=(others=>'0');  
	signal final_input : std_logic_vector(b-1 downto 0);
	signal left_init, from_final, from_final_reg : std_logic_vector(2*HASH_SIZE_256-1 downto 0);
	signal msg_len :std_logic_vector(63 downto 0);  
	signal key, ctr_wire, din_reg : std_logic_vector(63 downto 0);  
	signal  msg_len_tmp, key_out, key_wire, cnt_exeption : std_logic_vector(63 downto 0); 
	signal ctr, msg_len_tmp_wire	:std_logic_vector(54 downto 0);
	constant mw : integer:=ECHO_DATA_SIZE_BIG;
begin

	-- initialization vector
	left_init <= (ECHO_INIT_VALUE_256 & ECHO_INIT_VALUE_256 & ECHO_INIT_VALUE_256 & ECHO_INIT_VALUE_256)
				when first_block ='1' and bf='0' else from_final_reg;
	init_state <=(left_init & rin);	  
		
	-- final segment flag
	din_reg <= din;
	final_segment <= din_reg(0);
	
	-- serial input parallel output
	shfin_gen : sipo generic map ( N => ECHO_DATA_SIZE_BIG, M =>w) port map (clk => io_clk, en => ein, input => din_reg, output => rin );
			
	-- intermediate values storage register 
	to_register <= init_state when sf='1' else from_round; 
	r_gen 	: regn generic map ( N => b, init => bzeros ) port map (clk => clk, rst => rst, en => er, input => to_register, output => to_round );

	-- round of ECHO function
	eround	: 	entity work.echo_round(echo_round) 
	generic map(rom_style=>rom_style, aes_round_style=>aes_round_style) 
	port map (clk => clk, sel=>sel_rd, input=>to_round, key=>key_out, salt=>ECHO_TEMPORARY_SALT, output=>from_round, to_big_final=>to_big_final);

	-- BigFinal implementaion	
	final_input <= zero & rin  when big_final_mode="11" else to_big_final; 	
	b_f: entity work.echo_big_final_256(echo_big_final_256)
	port map(cv_old=>left_init, input=>final_input, cv_new=>from_final);
	
	-- final digest storage register
	wr_result <= bf or bf_early;
	f_gen 	: regn generic map ( N => (2 * HASH_SIZE_256), init => bzeros (2 * HASH_SIZE_256-1 downto 0) ) port map (clk => clk, rst => rst, en => wr_result, input => from_final, output => from_final_reg );	

	-- parallel input serial output
	shfout_gen : piso 
	generic map ( N => HASH_SIZE_256 , M => w ) 
	port map (clk => io_clk, sel => sel, en => eout, input => from_final_reg(2*HASH_SIZE_256-1 downto HASH_SIZE_256), output => dout );
		
	-- message len register
	sel <= lo or bf_reg;
	rlen: regn 
	generic map (N=>64, init=>zero(63 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_len, input=>msg_len_tmp, output=>msg_len);
	
	-- amount of data processed so far - counter
	countern_gen : countern 
	generic map (N =>55, step=>3, style =>COUNTER_STYLE_1) 
	port map (clk=>clk, rst=>rst, load=>wr_len, en=>wr_new_block, input=> ECHO_BIG_HEX_DATA_SIZE(63 downto 9) ,  output=>ctr); 
	
	-- flags for underflow and last block detection	
	ctr_wire <= ctr & "000000000";
	ef: entity work.echo_flags(echo_flags)
		generic map (hs=>HASH_SIZE_256)
		port map (clk=>clk, rst=>rst, len=>msg_len_tmp, ctr=>ctr_wire, din=>cnt_exeption ,end_flag=>rin(143 downto 128), last_block=>last_block, underflow=>underflow, key=>key);			
	
	rst_ctr <= rst or bf;
	countern_gen2 : countern 
	generic map (N =>60, step=>1, style =>COUNTER_STYLE_1) 
	port map (clk=>clk, rst=>rst_ctr, load=>GND, en=>wr_ctr, input=> zero(59 downto 0) ,  output=>key2(63 downto 4)); 
	key2(3 downto 0) <= "0000";
	key_wire <=  (key + key2);	 
		
	kr: regn 
	generic map (N=>64, init=>zero(63 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_key, input=>key_wire, output=>key_out);
		
	flag: d_ff port map (clk=>clk, rst=>rst, d=>bf, ena=>VCC, q=>bf_reg);
		
	eout <= eo or (lo ) or bf_reg;	
	 

	c<=msg_len_tmp;   
	msg_len_tmp <= msg_len_tmp_wire & "000000000";
	cnt_gen : regn 
	generic map (N=>64, init=>zero(63 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_seg, input=>din_reg, output=>cnt_exeption );

	seg_gen : regn 
	generic map (N=>55, init=>zero(54 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_c, input=>din_reg(63 downto 9), output=>msg_len_tmp_wire );

	
end struct256;	  


architecture struct512 of echo_datapath is
	signal init_state, to_round, to_register, from_round, final_input, to_big_final  : std_logic_vector(b-1 downto 0);
	signal rin : std_logic_vector(ECHO_DATA_SIZE_SMALL-1 downto 0);
	signal eout,  bf_reg, sel, rst_ctr, wr_result : std_logic;
	signal  key2 : std_logic_vector(ECHO_QWORD_SIZE/2-1 downto 0);	
	constant zero : std_logic_vector(ECHO_DATA_SIZE_SMALL-1 downto 0):=(others=>'0');
	signal left_init, from_final, from_final_reg : std_logic_vector(2*HASH_SIZE_512-1 downto 0);

	signal msg_len, cnt_exeption :std_logic_vector(63 downto 0);  
	signal key, ctr_wire, din_reg : std_logic_vector(63 downto 0);  
	signal msg_len_tmp, key_out, key_wire : std_logic_vector(63 downto 0);
	signal ctr, msg_len_tmp_wire	:std_logic_vector(53 downto 0);
	constant mw: integer := ECHO_DATA_SIZE_SMALL;
begin

	-- initialization vector	  
	left_init <= (ECHO_INIT_VALUE_512 & ECHO_INIT_VALUE_512 & ECHO_INIT_VALUE_512 & ECHO_INIT_VALUE_512 & ECHO_INIT_VALUE_512 & ECHO_INIT_VALUE_512 & ECHO_INIT_VALUE_512 & ECHO_INIT_VALUE_512)
					when first_block='1' and bf='0' else from_final_reg;
	init_state <=(left_init & rin);	  

	-- final segment flag	
	din_reg <= din;
	final_segment <= din_reg(0);
	
	-- serial input parallel output
	shfin_gen : sipo 
	generic map ( N => ECHO_DATA_SIZE_SMALL, M =>w) 
	port map (clk => io_clk, en => ein, input => din_reg, output => rin );

	-- intermediate values storage register
	to_register <= init_state when sf='1' else from_round; 
	r_gen 	: regn 
	generic map ( N => b, init => bzeros ) 
	port map (clk => clk, rst => rst, en => er, input => to_register, output => to_round );
	
	-- round of ECHO function	
	eround	: entity work.echo_round(echo_round) 
	generic map(rom_style=>rom_style, aes_round_style=>aes_round_style) 
	port map (clk => clk, sel=>sel_rd, input=>to_round, key=>key_out, salt=>ECHO_TEMPORARY_SALT, output=>from_round, to_big_final=>to_big_final);

	-- BigFinal implementaion
	final_input <= zero & rin  when big_final_mode="11" else to_big_final;--from_round;	--to_round;
	b_f: entity work.echo_big_final_512(echo_big_final_512)
	port map(cv_old=>left_init, input=>final_input, cv_new=>from_final);
	
	-- final digest storage register	
	wr_result <= bf or bf_early;
	f_gen 	: regn 
	generic map ( N => (2 * HASH_SIZE_512), init => bzeros (2 * HASH_SIZE_512-1 downto 0) ) 
	port map (clk => clk, rst => rst, en => wr_result, input => from_final, output => from_final_reg );	

	-- parallel input serial output
	shfout_gen : piso 
	generic map ( N => HASH_SIZE_512 , M => w ) 
	port map (clk => io_clk, sel => sel, en => eout, input => from_final_reg(2*HASH_SIZE_512-1 downto HASH_SIZE_512), output => dout );
	
	sel <= lo or bf_reg;
													 
	rlen: regn 
	generic map (N=>64, init=>zero(63 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_len, input=>msg_len_tmp, output=>msg_len);
	
	countern_gen : countern 
	generic map (N =>54, step=>1, style =>COUNTER_STYLE_1) 
	port map (clk=>clk, rst=>rst, load=>wr_len, en=>wr_new_block, input=> ECHO_SMALL_HEX_DATA_SIZE(63 downto 10),  output=>ctr); 
	
	ctr_wire <= ctr & "0000000000";																										 --rin(191 downto 128)
	ef: entity work.echo_flags(echo_flags)
	generic map (hs=>HASH_SIZE_512)	
	port map (clk=>clk, rst=>rst,  len=>msg_len_tmp, ctr=>ctr_wire, din=>cnt_exeption, end_flag=>rin(143 downto 128), last_block=>last_block, underflow=>underflow, key=>key);			
	
	rst_ctr <= rst or bf;
	countern_gen2 : countern generic map (N =>60, step=>1, style =>COUNTER_STYLE_1) port map (clk=>clk, rst=>rst_ctr, load=>GND, en=>wr_ctr, input=> zero(59 downto 0) ,  output=>key2(63 downto 4)); 
    key2(3 downto 0) <= "0000";	
	key_wire <=   key + key2;
	
	kr: regn 
	generic map (N=>64, init=>zero(63 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_key, input=>key_wire, output=>key_out);
	
	flag: d_ff port map (clk=>clk, rst=>rst, d=>bf, ena=>VCC, q=>bf_reg);

	eout <= eo or (lo ) or bf_reg;	
	 
	c<=msg_len_tmp;-- & "000000000";   
	msg_len_tmp <= msg_len_tmp_wire & "0000000000";
	cnt_gen : regn 
	generic map (N=>64, init=>zero(63 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_seg, input=>din_reg, output=>cnt_exeption );

	seg_gen : regn 
	generic map (N=>54, init=>zero(53 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_c, input=>din_reg(63 downto 10), output=>msg_len_tmp_wire );
	 
end struct512;