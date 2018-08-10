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
use work.echo_pkg.all;

-- ECHO fsm3 is responsible for controlling output interface 
entity echo_fsm3 is					
	port (	   
		io_clk  			: in std_logic;
		rst					: in std_logic;
		eo 					: out std_logic;
		output_write 		: in std_logic;	
		output_write_clr 	: out std_logic;	
		output_busy_clr  	: out std_logic;	
		dst_ready 			: in std_logic;
		dst_write 			: out std_logic);
end echo_fsm3;

architecture beh256 of echo_fsm3 is

begin
	fsm3 : sha3_fsm3 	
	generic map ( h => HASH_SIZE_256, w => w )
	port map (	   
		clk  => io_clk,
		rst		=> rst,
		eo => eo,
		output_write => output_write,
		output_write_clr => output_write_clr,
		output_busy_clr  => output_busy_clr,
		dst_ready => dst_ready,
		dst_write => dst_write);

end beh256;	

architecture beh512 of echo_fsm3 is

begin
	fsm3 : sha3_fsm3 	
	generic map (  h => HASH_SIZE_512, w => w )
	port map (	   
		clk  => io_clk,
		rst		=> rst,
		eo => eo,
		output_write => output_write,
		output_write_clr => output_write_clr,
		output_busy_clr  => output_busy_clr,
		dst_ready => dst_ready,
		dst_write => dst_write);

end beh512;

		
		
		
		