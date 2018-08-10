-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================
-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.sha3_pkg.all;
use work.keccak_pkg.all;

-- keccak fsm3 is responsible for controlling output interface 

entity keccak_fsm3 is	
generic (hs : integer := HASH_SIZE_256);	
port (	   
		io_clk  			: in std_logic;
		rst					: in std_logic;
		eo 					: out std_logic;
		sel_out				: out std_logic; 
		output_write 		: in std_logic;	
		output_write_clr 	: out std_logic;	
		output_busy_clr  	: out std_logic;	
		dst_ready 			: in std_logic;
		dst_write 			: out std_logic);
end keccak_fsm3;

architecture beh of keccak_fsm3 is 			 

constant hseg			: integer := hs/w;
constant log2hseg		: integer := log2( hseg );

begin
fsm3 : sha3_fsm3 	
	generic map ( h => hs, w => w )
	port map (	   
		clk  => io_clk,
		rst		=> rst,
		eo => eo,
		output_write => output_write,
		output_write_clr => output_write_clr,
		output_busy_clr  => output_busy_clr,
		dst_ready => dst_ready,
		dst_write => dst_write);
	
	d01 : d_ff port map (clk=>io_clk, rst=>rst, ena=>VCC, d=>output_write, q=>sel_out) ;
	
end beh;

		
		
		
		