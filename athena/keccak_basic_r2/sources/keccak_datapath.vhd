-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 
use ieee.numeric_std.all;
use work.sha3_pkg.all;
use work.keccak_pkg.all;

-- Possible generics values: 
-- hs = {HASH_SIZE_256, HASH_SIZE_512} 
-- b = {KECCAK256_CAPACITY, KECCAK512_CAPACITY}
-- possible combinaations of (hs, b) = {(HASH_SIZE_256, KECCAK256_CAPACITY), (HASH_SIZE_512, KECCAK512_CAPACITY)}

entity keccak_datapath is
generic (b : integer := KECCAK256_CAPACITY; hs: integer := HASH_SIZE_256);	
port (
		clk 				:in std_logic;
		io_clk				:in std_logic;
		rst 				:in std_logic;
		din 				:in std_logic_vector(w-1 downto 0);
		dout 				:out std_logic_vector(w-1 downto 0);
		wr_c				:in std_logic;
		en_len				:in std_logic;
		en_ctr				:in std_logic;
		ein 				:in std_logic; 
		c					:out std_logic_vector(w-1 downto 0); 
		sel_xor 			:in std_logic;
		sel_final			:in std_logic;
		wr_state			:in std_logic;
		ld_rdctr				:in std_logic;
		en_rdctr 				:in std_logic; 
		sel_piso			:in std_logic;
		wr_piso				:in std_logic;	
		final_segment		:out std_logic;
		last_block			:out std_logic 
	);
end keccak_datapath;			   

architecture struct of keccak_datapath is
signal from_sipo	:std_logic_vector(b-1 downto 0);																	
signal from_concat, to_xor, from_round, from_xor, to_register,
to_round : std_logic_vector(KECCAK_STATE-1 downto 0);
signal to_piso  	: std_logic_vector(hs-1 downto 0);
signal rd_ctr	: std_logic_vector(4 downto 0);
signal rc,  swap_din	:	std_logic_vector(w-1   downto 0);
signal zeros: std_logic_vector (KECCAK_STATE-1-b downto 0);
constant state_zero : std_logic_vector (KECCAK_STATE-1 downto 0):=(others => '0'); 
constant zero	: std_logic_vector(w-1 downto 0):=(others => '0');

type res_type is array (0 to hs/w-1) of std_logic_vector(w-1 downto 0); 			   
signal se_result : res_type;   
signal msg_len_tmp			: std_logic_vector(w-LOG2_W-1 downto 0); 
signal 	cnt_tmp , init_value 			: std_logic_vector(57 downto 0); 
signal cnt, length	  		: std_logic_vector(w-1 downto 0); 
begin	
	-- last segment flag 					  
	final_segment <= din(0);
	
	-- serial input parallel output
	swap_din <= din(31 downto 0) & din(63 downto 32);
	in_buf 		: sipo 
	generic map (N => b, M => w) 
	port map (clk => io_clk, en => ein, input => swap_din, output => from_sipo );
	
	zeros   <= (others => '0');
	from_concat <=  from_sipo & zeros;
	to_xor <= from_round when sel_xor='1' else state_zero; 
	from_xor <= from_concat xor to_xor;
	to_register <= from_xor when sel_final='1' else from_round;
		
	-- regsiter for intermediate values	
	state		: regn 
	generic map (N => KECCAK_STATE, init=>state_zero) 
	port map ( clk =>clk, rst=>rst, en =>wr_state, input=>to_register, output=>to_round);	
   
	-- asynchronous memory for Keccak constants 
	rd_cons 	: entity work.keccak_cons(keccak_cons) 	port map (addr=>rd_ctr, rc=>rc);
	-- Keccak round function with architecture based on Marcin Rogawski implementation
	rd 			: entity work.keccak_round(mrogawski_round)port map (rc=>rc, rin=>to_round, rout=>from_round);

	-- round counter
   	ctr 		: countern 
	generic map ( N => 5, step=>1, style=>COUNTER_STYLE_1 ) 
	port map ( clk => clk, rst=>rst, load => ld_rdctr, en => en_rdctr, input => zeros(4 downto 0), output => rd_ctr);
	
   	-- piso endianess fixing function
	out_gen: for i in 0 to hs/w-1 generate	
		se_result(i) <= from_round(KECCAK_STATE-i*w-1 downto KECCAK_STATE-(i+1)*w); 
		to_piso(hs-i*w-1 downto hs-(i+1)*w) <= switch_endian_word(x=>se_result(i), width=>w, w=>8);	
	end generate;	
		
	-- parallel input serial output	
	out_buf 	: piso 
	generic map (N => hs, M => w) 
	port map (clk => io_clk, sel => sel_piso, en => wr_piso, input => to_piso,  output => dout );  
	
	-- length of current segment 		
	seg_gen : regn 
	generic map (N=>(w-LOG2_W), init=>zero(w-LOG2_W-1 downto 0)) 
	port map (clk=>clk, rst=>rst, en=>wr_c, input=>din(w-1 downto LOG2_W), output=>msg_len_tmp );	
	c<=msg_len_tmp & zero(LOG2_W-1 downto 0);
	length <= msg_len_tmp & zero(LOG2_W-1 downto 0);
	
	-- amount of data alerady processed
dp256_gen : if hs=HASH_SIZE_256 generate	
	init_value <= std_logic_vector(to_unsigned(KECCAK256_WORDS, w-LOG2_W));
	countern_gen1 : countern 
	generic map (N =>(w-LOG2_W), step=>KECCAK256_WORDS, style =>COUNTER_STYLE_1) 
	port map (clk=>clk, rst=>rst, load=>en_len, en=>en_ctr, input=> init_value ,  output=>cnt_tmp); 
	cnt <= cnt_tmp & zero(LOG2_W-1 downto 0);			
end generate;
	-- amount of data alerady processed
dp512_gen : if hs=HASH_SIZE_512 generate	
	init_value <= std_logic_vector(to_unsigned(KECCAK512_WORDS, w-LOG2_W));
	countern_gen1 : countern 
	generic map (N =>(w-LOG2_W), step=>KECCAK512_WORDS, style =>COUNTER_STYLE_1) 
	port map (clk=>clk, rst=>rst, load=>en_len, en=>en_ctr, input=> init_value ,  output=>cnt_tmp); 
	cnt <= cnt_tmp & zero(LOG2_W-1 downto 0);			
end generate;
	
	-- last block flag
	last_block <= '1' when (length <= cnt) and (length>zero) else '0';
	 
	
end struct;