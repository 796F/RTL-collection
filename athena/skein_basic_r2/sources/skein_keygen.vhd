-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use ieee.std_logic_arith.all;
use work.sha3_pkg.all;
use work.sha3_skein_package.all;

entity skein_keygen is	
	generic ( 	adder_type : integer := SCCA_BASED;
				b : integer := 512; 
				nw : integer := 8);
	port (					
		clk		: in std_logic;
		load	: in std_logic;
		en		: in std_logic;
		keyin	: in std_logic_vector(b-1 downto 0);
		tweak 	: in std_logic_vector(127 downto 0);
		keyout	: out key_array(nw-1 downto 0)
	);
end skein_keygen;
		
architecture struct of skein_keygen is
	-- tweak															   
	type tweak_type is array (2 downto 0) of std_logic_vector(63 downto 0);
	type tweak_array is array (1 downto 0, 2 downto 0) of std_logic_vector(63 downto 0);
	signal tw_iv, tw_reg : tweak_type;
	signal tw : tweak_array;
				
	type key_type1 is array(nw downto 1) of std_logic_vector(63 downto 0);
	signal key_reg : key_type1;	 
	
	signal key_out_in : key_array(nw-1 downto nw-3); -- only the first 3 arrays need dedicated resource
	signal key 	: key_array(nw downto 0) ;
	signal parkey   : key_array(nw-1 downto 0) ;

	-- sub key counter	
	signal s_out : std_logic_vector(63 downto 0);
	type subkey_array is array(1 downto 0) of std_logic_vector(63 downto 0);
	signal s : subkey_array;
	
begin					  
	----------------------
	-- s gen 
	s(0) <= iwzeros when load = '1' else s_out;
	s_reg_gen : regn generic map ( N => iw, init => iwzeros ) port map (clk => clk, rst => '0', en => en, input => s(1), output => s_out );
	add_call : adder generic map ( adder_type => adder_type, n => 64 ) port map ( a => s(0), b => conv_std_logic_vector(1,64), s => s(1));	
	
	----------------------
	-- tweak
		--tweak init	   
	tw_iv(2) <= tweak(127 downto 64) xor tweak(63 downto 0);
	tw_iv(1) <= tweak(127 downto 64);
	tw_iv(0) <= tweak(63 downto 0);
	
		--
	tw(0,0) <= tw_iv(0) when load = '1' else tw_reg(0);
	tw(0,1) <= tw_iv(1) when load = '1' else tw_reg(1);
	tw(0,2) <= tw_iv(2) when load = '1' else tw_reg(2);
	

	tw(1,0) <= tw(0,1);
	tw(1,1) <= tw(0,2);
	tw(1,2) <= tw(0,0);
	
	
	tw_regs_gen : for i in 2 downto 0 generate
		tw_reg_gen : regn generic map ( N => iw, init => iwzeros ) port map ( clk => clk, rst => '0', en => en, input => tw(1,i), output => tw_reg(i) );
	end generate;	
	
	----------------------
	-- key
	key_gen : for i in nw-1 downto 0 generate
		key(i) <= keyin(iw*i+iw-1 downto i*iw) when load = '1' else key_reg(i+1);
	end generate;
	key(nw) <= parkey(nw-1) xor key_const;	

	parkey(0) <= key(0);
	parkey_gen2 : for j in 1 to nw-1 generate
		parkey(j) <= key(j) xor parkey(j-1);
	end generate;
	
	-- gen key out
	add_call1 : adder generic map ( adder_type => adder_type, n => 64 ) port map ( a => key(nw-1), b => s(0), s => key_out_in(nw-1));
	add_call2 : adder generic map ( adder_type => adder_type, n => 64 ) port map ( a => key(nw-2), b => tw(0,1), s => key_out_in(nw-2));
	add_call3 : adder generic map ( adder_type => adder_type, n => 64 ) port map ( a => key(nw-3), b => tw(0,0), s => key_out_in(nw-3));
	
	reggen_keyreg : for j in nw downto 1 generate
		key_reg_gen : regn generic map ( N => iw, init => iwzeros ) port map ( clk => clk, rst => '0', en => en, input => key(j), output => key_reg(j) );
	end generate;
			
	-- Register the output of the keyout
	keyout_reg2 : for j in nw-1 downto nw-3 generate
		key_out_gen : regn generic map ( N => iw, init => iwzeros ) port map ( clk => clk, rst => '0', en => en, input => key_out_in(j), output => keyout(j) );
	end generate;
	keyout(4) <= key_reg(4);
	keyout(3) <= key_reg(3);
	keyout(2) <= key_reg(2);
	keyout(1) <= key_reg(1);
	key_out_gen0 : regn generic map ( N => iw, init => iwzeros ) port map ( clk => clk, rst => '0', en => en, input => key(0), output => keyout(0) );
	
end struct;