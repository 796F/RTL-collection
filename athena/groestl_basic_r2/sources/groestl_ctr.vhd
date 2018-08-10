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

-- pipelined counter - for removing critical path from the design

entity groestl_ctr is
generic ( 
	N 	: integer := 55;
	step	:integer  :=1);
port ( 	  
	clk 	: in std_logic;
	rst 	: in std_logic;
	en_len 	: in std_logic; 
	en_ctr 	: in std_logic; 
    output 	: out std_logic_vector(N-1 downto 0));
end groestl_ctr;

architecture groestl_ctr of groestl_ctr is
constant zero	:std_logic_vector(4 downto 0):=(others=>'0');  
constant ones	:std_logic_vector(4 downto 0):=(others=>'1');  

type vec11 is array (1 to 11) of std_logic;	 
type vec12 is array (0 to 11) of std_logic;	 
type matrix11 is array (1 to 11) of std_logic_vector(4 downto 0);

signal c_tmp  :matrix11;
signal c_wire, c_reg	:vec11;	   
signal en_ctr_reg, en_ctr_wire : vec12;

begin

en_ctr_wire(0) <= en_ctr;	  
en_ctr_reg(0) <= en_ctr;
ctr_pipeline: for i in 1 to 11 generate																									  
	
ctr : countern generic map (N =>5, step=>1, style =>COUNTER_STYLE_1) port map (clk=>clk, rst=>rst, load=>en_len, en=>en_ctr_wire(i-1), input=> zero(4 downto 0) ,  output=>c_tmp(i));
c_wire(i) <= '1' when c_tmp(i)=ones else '0';
c_dff : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => c_wire(i), q =>c_reg(i));
en_dff : d_ff port map ( clk => clk, ena => VCC, rst => GND, d => en_ctr_reg(i-1), q =>en_ctr_reg(i));
en_ctr_wire(i) <= en_ctr_reg(i) and c_reg(i);		
end generate;	


output <= c_tmp(11) & c_tmp(10) & c_tmp(9) & c_tmp(8) & c_tmp(7) & c_tmp(6) & c_tmp(5) & c_tmp(4) & c_tmp(3) & c_tmp(2) & c_tmp(1);


end groestl_ctr;

