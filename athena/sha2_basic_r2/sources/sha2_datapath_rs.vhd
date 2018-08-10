-- =====================================================================
-- Copyright © 2010-11 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;
use work.sha2_pkg.all;

entity sha2_datapath_rs is
generic( n : integer :=HASH_SIZE_256/SHA2_WORDS_NUM; s :integer:=LOG_2_8; flag: integer:=HASH_BLOCKS_256; a :integer:=LOG_2_64; r:integer:=ROUNDS_64; cs: integer := LOG_2_1024 );
port(	
	clk							: in std_logic;
	rst							: in std_logic;
	wr_state					: in std_logic;
	wr_result					: in std_logic;
	wr_data						: in std_logic;
	kw_wr						: in std_logic;
	wr_len						: in std_logic;
	sel							: in std_logic;	  
	sel2						: in std_logic;
	sel_gh						: in std_logic;		
	sel_gh2						: in std_logic;
	ctr_ena						: in std_logic;
	z16							: out std_logic;
	zlast						: out std_logic;
	skip_word					: out std_logic;
	o8							: out std_logic;
	dst_write					: in std_logic;
	data						: in std_logic_vector(n-1 downto 0);
	dataout						: out std_logic_vector(n-1 downto 0); 
--	wr_lb						: in std_logic;
--	wr_md						: in std_logic;	
	wr_chctr					: in std_logic;		
	last_block					: out std_logic;
	msg_done					: out std_logic;
	rst_flags					: in std_logic);

end sha2_datapath_rs;

architecture sha2_datapath_rs of sha2_datapath_rs is	 
type matrix 	is array (0 to STATE_REG_NUM-1) of std_logic_vector(n-1 downto 0);
type matrix32 	is array (0 to STATE_REG_NUM-1) of std_logic_vector(31 downto 0);
type matrix64 	is array (0 to STATE_REG_NUM-1) of std_logic_vector(63 downto 0);

signal from_round			:matrix;
signal to_round				:matrix;
signal from_final_add		:matrix;
signal from_mux				:matrix;
signal result				:matrix;
signal to_result			:matrix;
constant iv256					:matrix32 := ( SHA256_AINIT, SHA256_BINIT, SHA256_CINIT, SHA256_DINIT, SHA256_EINIT, SHA256_FINIT, SHA256_GINIT, SHA256_HINIT );  
constant iv512					:matrix64 := ( SHA512_AINIT, SHA512_BINIT, SHA512_CINIT, SHA512_DINIT, SHA512_EINIT, SHA512_FINIT, SHA512_GINIT, SHA512_HINIT );  

signal wwire				:std_logic_vector(n-1 downto 0);
signal kwire				:std_logic_vector(n-1 downto 0);
signal h_exception			:std_logic_vector(n-1 downto 0);
signal rd_num				:std_logic_vector(a-1 downto 0);
signal z16_reg				:std_logic;	 
signal ena_reg				:std_logic;
constant zero				:std_logic_vector(n-1 downto 0) := (others => '0');
signal kwhwire				:std_logic_vector(n-1 downto 0);
signal kwhreg				:std_logic_vector(n-1 downto 0);
signal chunk_ctr1			:std_logic_vector(n-1-cs downto 0);	 
signal chunk_ctr2			:std_logic_vector(cs-1 downto 0);	 
signal chunk_ctr			:std_logic_vector(n-1 downto 0);
signal chunk_len			:std_logic_vector(n-1 downto 0);
signal chunk_len_reg		:std_logic_vector(n-1-9 downto 0);
signal out_ctr				:std_logic_vector(s downto 0);
signal gh					:std_logic_vector(1 downto 0);
signal last_block_out		:std_logic;	
signal rst_flags_reg		:std_logic;

begin		 	

st256_gen: if n=HASH_SIZE_256/STATE_REG_NUM generate
	sr_gen: for i in 0 to STATE_REG_NUM-1 generate	
	sr0	: regn 	generic map (n=>n, init =>iv256(i)) 
				port map (clk=>clk, en=>wr_state, rst=>rst, input=>from_mux(i), output=>to_round(i));	
	end generate;										 
end generate;

st512_gen: if n=HASH_SIZE_512/STATE_REG_NUM generate
	sr_gen: for i in 0 to STATE_REG_NUM-1 generate	
	sr0	: regn 	generic map (n=>n, init =>iv512(i)) 
				port map (clk=>clk, en=>wr_state, rst=>rst, input=>from_mux(i), output=>to_round(i));	
	end generate;										 
end generate;


				
kwh_reg		: regn 	generic map (n=>n, init =>zero) 
					port map (clk=>clk, en=>kw_wr, rst=>rst, input=>kwhwire, output=>kwhreg);

gh <= (sel_gh, sel_gh2);

h_exception <= 	to_round(6) when gh="00" else
		to_round(6) when gh="01" else
		to_round(7) when gh="10" else
		result(6);	

round: 	entity work.sha2_round_rs(basic) 
		generic map (n=>n)		
		port map (
		sel_gh=>sel_gh, kw=>kwhreg, kwire=>kwire, wwire=>wwire,	ain=>to_round(0), bin=>to_round(1), 
		cin=>to_round(2), din=>to_round(3), ein=>to_round(4), fin=>to_round(5), gin=>to_round(6), 
		hin=>h_exception, kwhwire=>kwhwire, aout=>from_round(0),bout=>from_round(1), cout=>from_round(2),	
		dout=>from_round(3), eout=>from_round(4), fout=>from_round(5), gout=>from_round(6), hout=>from_round(7));  	  
		
	from_final_add(0)	<= to_round(0) +  result(3);
	from_final_add(4)	<= to_round(4) +  result(7);
		
mux0_gen: for i in 0 to STATE_REG_NUM-1 generate
	from_mux(i) <= from_final_add(i) when sel='1' else from_round(i);	
end generate; 

	from_final_add(1) <= result(0);
	from_final_add(2) <= result(1);
	from_final_add(3) <= result(2);
	from_final_add(5) <= result(4);
	from_final_add(6) <= result(5);
	from_final_add(7) <= result(6);

	ena_reg <=wr_result or dst_write;

mux1_gen: for i in 0 to STATE_REG_NUM-2 generate
		 to_result(i) <= from_final_add(i) when wr_result='1' else result(i+1);
end generate;	  

	to_result(7) <= from_final_add(7);

hs256_gen: if n=HASH_SIZE_256/STATE_REG_NUM generate
	rr_gen: for i in 0 to STATE_REG_NUM-1 generate
	rr	: regn 		generic map (n=>n, init =>iv256(i)) 
						port map (clk=>clk, en=>ena_reg, rst=>rst, input=>to_result(i), output=>result(i));	
	end generate;
end generate;

hs512_gen: if n=HASH_SIZE_512/STATE_REG_NUM generate
	rr_gen: for i in 0 to STATE_REG_NUM-1 generate
	rr	: regn 		generic map (n=>n, init =>iv512(i)) 
						port map (clk=>clk, en=>ena_reg, rst=>rst, input=>to_result(i), output=>result(i));	
	end generate;
end generate;
	
dc			: entity work.sha2_msg_scheduler(mc_evoy) 
			generic map (n=>n)	
			port map (clk=>clk, sel=>sel2, wr_data=>wr_data, data=>data, w=>wwire);		
	  
rd_ctr 		:entity work.sha2_ctr(sha2_ctr) 	generic map (s=>a, r=>r-1, step=>1) 
			port map (clk=>clk, reset=>rst, ena=>ctr_ena, ctr=>rd_num);	  
	
	

bf			:entity work.sha2_flags_bl(sha2_flags_bl) 	generic map (n=>n, a=>a, r=>r, s=>s, flag=>flag)
						port map (clk=>clk, wr_len=>wr_len, rd_num=>rd_num, exam_block=>data,  
						out_ctr=>out_ctr, rst=>rst, rst_flags=>rst, z16=>z16_reg,  
						zlast=>zlast, skip_word=>skip_word, o8=>o8, last_block_in=>data(0), last_block_out=>last_block_out );		 
						last_block <= (data(0) and wr_len) or last_block_out;

o_ctr		:entity work.sha2_ctr(sha2_ctr) 	generic map (s=>s+1, r=>flag+1) 
						port map (clk=>clk, reset=>rst, ena=>dst_write, ctr=>out_ctr);
						
con256_gen: if n=HASH_SIZE_256/STATE_REG_NUM generate						
const		:entity work.sha2_cons(sha2_cons) generic map (n=>HASH_SIZE_256/STATE_REG_NUM, a=>a)
			port map (clk=> clk, address=>rd_num, output=>kwire);
end generate;	

con512_gen: if n=HASH_SIZE_512/STATE_REG_NUM generate						
const		:entity work.sha2_cons(sha2_cons) generic map (n=>HASH_SIZE_512/STATE_REG_NUM, a=>a)
						port map (clk=> clk, address=>rd_num, output=>kwire);						
end generate;						
						
						
ch_len		:regn		generic map (n=>(n-9), init => zero(n-1 downto 9)) 	  -- 9 least signisicant bits are always zero - dont need to store them
						port map (clk=>clk, en=>wr_len, rst=>rst, input=>data(n-1 downto 9), output=>chunk_len_reg);
						chunk_len <= chunk_len_reg & "000000000";
				 
	rst_flags_reg <= rst or rst_flags;						
ch_ctr 		:entity work.sha2_ctr(sha2_ctr) 	generic map (s=>(n-cs), r=>(2**(n)-1-cs), step=>1) 
						port map (clk=>clk, reset=>rst_flags_reg, ena=>wr_chctr, ctr=>chunk_ctr1);

chunk_ctr2 <= (others=>'0');

chunk_ctr <= chunk_ctr1 & chunk_ctr2;

z16 <= z16_reg;	
--last_block <= lb_reg;
msg_done <= '1' when (chunk_ctr=chunk_len) else '0';--md_reg;		

dataout <=result(0);

	
end sha2_datapath_rs;

