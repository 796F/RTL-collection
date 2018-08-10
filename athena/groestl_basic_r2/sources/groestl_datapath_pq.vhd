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
use work.groestl_pkg.all;

-- Groestl datapath for quasi-pipelined architecture
-- possible generics values: hs = {GROESTL_DATA_SIZE_SMALL, GROESTL_DATA_SIZE_BIG}
-- rom_style = {DISTRIBUTED, COMBINATIONAL}
-- all combinations are allowed 	 

entity groestl_datapath_pq is
generic (n	:integer := GROESTL_DATA_SIZE_SMALL; hs : integer := HASH_SIZE_256; ur :integer :=2);
port( 	 
	clk					: in std_logic; 
	rst					: in std_logic; 
	ein					: in std_logic;	
	init1				: in std_logic;	
	init2				: in std_logic;	
	init3				: in std_logic;	
	last_cycle			: in std_logic;					
	finalization		: in std_logic;	
	wr_state			: in std_logic;
	wr_result			: in std_logic;
	load_ctr			: in std_logic;										   
	wr_ctr				: in std_logic;
	p_mode				: in std_logic;
	sel_out				: in std_logic;
	eout				: in std_logic;	 
	wr_c				: in std_logic;	
	wr_seg				: in std_logic;	
	en_len				: in std_logic;	
	en_ctr				: in std_logic;	
	ls_rs_flag			: in std_logic;
	final_segment		: out std_logic;		
	last_block			: out std_logic;		
	c 					: out std_logic_vector(w-1 downto 0);
	din 				: in std_logic_vector(w-1 downto 0);
    dout 				: out std_logic_vector(w-1 downto 0));
end groestl_datapath_pq;
  
architecture folded_x2 of groestl_datapath_pq is	   
constant zero : std_logic_vector(n-1 downto 0):= (others=>'0');  
signal  rin, from_final, to_round, from_register, to_final : std_logic_vector(n-1 downto 0); 
signal  init_value,  to_register, to_reg, inter_value : std_logic_vector(n-1 downto 0); 
signal  din_reg : std_logic_vector(w-1 downto 0);  			 
signal msg_len_tmp : std_logic_vector(w-4-1 downto 0);
signal  ctr : std_logic_vector(3 downto 0);  
signal  round : std_logic_vector(7 downto 0);  
signal  cnt_tmp : std_logic_vector(54 downto 0);  
signal  cnt, length : std_logic_vector(w-1 downto 0);  
signal last_wire : std_logic;

begin	
	
	-- flag for final segment detection
	din_reg <= din;
	final_segment <= din_reg(0);
	
	-- serial input parallel output
	shfin_gen : sipo 
	generic map ( N => n, M =>w) 
	port map (clk => clk, en => ein, input => din_reg, output => rin );
	
	init_value <= rin when init1='1' else rin xor from_final;
	inter_value <= init_value when init2='1' else from_register;
	to_round <= 	(from_register xor from_final) when finalization='1' else inter_value;
	to_reg <= to_final when last_cycle='1' else to_register;	
	
	-- storage register for intermediate values 	
	state_reg : regn 
	generic map(N=>n, init=>zero(n-1 downto 0)) 
	port map (clk => clk, rst => rst, en => wr_state, input => to_reg, output => from_register );	

	-- round counter 
	rd_num : countern 
	generic map (N =>4, step=>1, style =>COUNTER_STYLE_1) 
	port map (clk=>clk, rst=>rst, load=>load_ctr, en=>wr_ctr, input=> zero(3 downto 0) ,  output=>ctr); 
	round <= zero(3 downto 0) & ctr;

	-- quasi-pipelining round 	
	rounds : entity work.groestl_pq(pipelined) 
		generic map (n=>n)
		port map (clk=>clk, rst=>rst, p_mode=>p_mode, round=>round, input=>to_round, output=>to_register);
	
	-- initialization vectors for different versions of Groestl
	iv224: if hs=HASH_SIZE_224 generate
		to_final <= GROESTL_INIT_VALUE_224 when init3='1' else to_register xor from_final;  
	end generate;
	
	iv256: if hs=HASH_SIZE_256 generate
		to_final <= GROESTL_INIT_VALUE_256 when init3='1' else to_register xor from_final;  
	end generate;  
	
	iv384: if hs=HASH_SIZE_384 generate
		to_final <= GROESTL_INIT_VALUE_384 when init3='1' else to_register xor from_final;  
	end generate;  
	
	iv512: if hs=HASH_SIZE_512 generate
		to_final <= GROESTL_INIT_VALUE_512 when init3='1' else to_register xor from_final;  
	end generate;  
			
	-- final message digest storage register  		
	final_reg : regn 
	generic map(N=>n, init=>zero(n-1 downto 0)) 
	port map (clk => clk, rst => rst, en => wr_result, input => to_final, output => from_final );	
	
	-- parallel input serial output	
	shfout_gen : piso 
	generic map ( N => hs , M => w ) 
	port map (clk => clk, sel => sel_out, en => eout, input => from_final(hs-1 downto 0), output => dout );
 
	-- pipelining counter - to remove critical path from this counter 
	ctr256: if n=GROESTL_DATA_SIZE_SMALL generate
--		countern_gen1 : countern 
--		generic map (N =>55, step=>1, style =>COUNTER_STYLE_1) 
--		port map (clk=>clk, rst=>rst, load=>en_len, en=>en_ctr, input=> zero(54 downto 0) ,  output=>cnt_tmp);
		
		countern_gen1 : entity work.groestl_ctr(groestl_ctr) 
		port map (clk=>clk, rst=>rst, en_len=>en_len, en_ctr=>en_ctr,  output=>cnt_tmp);
		
		
	end generate;
	
	ctr512: if n=GROESTL_DATA_SIZE_BIG generate
--		countern_gen1 : countern 
--		generic map (N =>55, step=>2, style =>COUNTER_STYLE_1) 
--		port map (clk=>clk, rst=>rst, load=>en_len, en=>en_ctr, input=> zero(54 downto 0) ,  output=>cnt_tmp);

		countern_gen1 : entity work.groestl_ctr(groestl_ctr) 
		port map (clk=>clk, rst=>rst, en_len=>en_len, en_ctr=>en_ctr,  output=>cnt_tmp);


	end generate;
	cnt <= (cnt_tmp) & "000000000";

	length <= msg_len_tmp & "0000";

	-- last block flag 	
	last_wire <= '1' when (length <= cnt and cnt > 0)else '0';
	last_reg : d_ff port map ( clk => clk, ena => '1', rst => '0', d => last_wire, q =>last_block);	  

	-- for controller to skip zeros in fifo	
	c <=msg_len_tmp & "0000";

	-- message len storage register 
	sob : regn 
	generic map (N=>(w-4), init=>zero(w-4-1 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_c, input=>din_reg(63 downto 4), output=>msg_len_tmp );

end folded_x2; 

