-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_pkg.all; 
use work.fugue_pkg.all;

-- possible generics values: hs = {HASH_SIZE_224, HASH_SIZE_256} 

entity fugue_state is
generic ( hs : integer := HASH_SIZE_256);
port (	
	clk				: in std_logic;
	rst				: in std_logic;
	en 				: in std_logic;
	input 			: in state;
	output 			: out state);
end fugue_state;

architecture fugue_state of fugue_state is	

signal low_din, low_dout : std_logic_vector((30*8*4)-hs-1 downto 0);
signal high_din, high_dout : std_logic_vector(hs-1 downto 0);
constant zero	: std_logic_vector((30*8*4)-hs-1 downto 0):=(others=>'0');

begin							  

	-- lower register with the intermediate values
	state_low: regn
	generic map (n=>((30*4*8)-hs), init=>zero)
	port map ( clk=>clk, rst=>rst, en=>en, input=>low_din, output=>low_dout);	
	
	-- higher register with the intermediate values with state initialization 
	gen_iv_224: if hs=HASH_SIZE_224 generate
		state_high: regn generic map(n=>hs, init=>FUGUE_INIT_224) port map( clk=>clk, rst=>rst, en=>en, input=>high_din, output=>high_dout);			
	end generate;		
	
	gen_iv_256: if hs=HASH_SIZE_256 generate
		state_high: regn generic map(n=>hs, init=>FUGUE_INIT_256) port map( clk=>clk, rst=>rst, en=>en, input=>high_din, output=>high_dout);			
	end generate;		

	-- conversion from state to std_logic_vector for HASH_SIZE_224	
	state224: if hs = HASH_SIZE_224 generate 
				  		
		ldo: for i in 0 to 22 generate	
			output(i) <= low_dout((22-i+1)*FUGUE_WORD_SIZE-1 downto (22-i)*FUGUE_WORD_SIZE);
			low_din((22-i+1)*FUGUE_WORD_SIZE-1 downto (22-i)*FUGUE_WORD_SIZE) <= input(i);			
		end generate;	  
		
		hdo: for i in 23 to 29 generate	   
			output(i) <= high_dout((29-i+1)*FUGUE_WORD_SIZE-1 downto (29-i)*FUGUE_WORD_SIZE);
			high_din((29-i+1)*FUGUE_WORD_SIZE-1 downto (29-i)*FUGUE_WORD_SIZE) <= input(i);
		end generate;
		
	end generate;

	-- conversion from state to std_logic_vector for HASH_SIZE_256	
	state256: if hs = HASH_SIZE_256 generate  
		
  		ldo: for i in 0 to 21 generate	
			output(i) <= low_dout((21-i+1)*FUGUE_WORD_SIZE-1 downto (21-i)*FUGUE_WORD_SIZE);
			low_din((21-i+1)*FUGUE_WORD_SIZE-1 downto (21-i)*FUGUE_WORD_SIZE) <= input(i);		
		end generate;	  
		
		hdo: for i in 22 to 29 generate	   
			output(i) <= high_dout((29-i+1)*FUGUE_WORD_SIZE-1 downto (29-i)*FUGUE_WORD_SIZE); 
			high_din((29-i+1)*FUGUE_WORD_SIZE-1 downto (29-i)*FUGUE_WORD_SIZE) <= input(i);
		end generate;
				
	end generate;

end fugue_state;
