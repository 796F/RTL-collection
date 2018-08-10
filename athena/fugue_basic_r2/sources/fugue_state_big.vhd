-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_pkg.all; 
use work.fugue_pkg.all;

entity fugue_state_big is
generic ( hs : integer := HASH_SIZE_512);
port (	
	clk 			: in 	std_logic; 
	rst 			: in 	std_logic;
	en 				: in 	std_logic;
	input 			: in	state_big;
	output 			: out 	state_big);
end fugue_state_big;

architecture fugue_state_big of fugue_state_big is	

signal low_din, low_dout : std_logic_vector((36*8*4)-hs-1 downto 0);
signal high_din, high_dout : std_logic_vector(hs-1 downto 0);
constant zero	: std_logic_vector((36*8*4)-hs-1 downto 0):=(others=>'0');

begin							  
	
	-- lower register with the intermediate values
	state_low: regn
	generic map (n=>((36*4*8)-hs), init=>zero)
	port map ( clk=>clk, rst=>rst, en=>en, input=>low_din, output=>low_dout);	

	-- higher register with the intermediate values with state initialization 	
	gen_iv_512: if hs=HASH_SIZE_512 generate
		state_high: regn generic map(n=>hs, init=>FUGUE_INIT_512) port map( clk=>clk, rst=>rst, en=>en, input=>high_din, output=>high_dout);			
	end generate;		
	
	-- conversion from state to std_logic_vector for HASH_SIZE_512	
	state512: if hs = HASH_SIZE_512 generate  
		
  		ldo: for i in 0 to 19 generate	
			output(i) <= low_dout((19-i+1)*FUGUE_WORD_SIZE-1 downto (19-i)*FUGUE_WORD_SIZE);
			low_din((19-i+1)*FUGUE_WORD_SIZE-1 downto (19-i)*FUGUE_WORD_SIZE) <= input(i);		
		end generate;	  
		
		hdo: for i in 20 to 35 generate	   
			output(i) <= high_dout((35-i+1)*FUGUE_WORD_SIZE-1 downto (35-i)*FUGUE_WORD_SIZE); 
			high_din((35-i+1)*FUGUE_WORD_SIZE-1 downto (35-i)*FUGUE_WORD_SIZE) <= input(i);
		end generate;
				
	end generate;

end fugue_state_big;
