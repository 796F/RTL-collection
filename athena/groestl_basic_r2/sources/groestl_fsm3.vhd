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
use work.groestl_pkg.all;

-- Groestl fsm3 is responsible for controlling output interface

entity groestl_fsm3 is	
generic (hs : integer := HASH_SIZE_256);	
	port (	   
		--global
		io_clk  : in std_logic;
		rst		: in std_logic;
	
		-- datapath
		eo 		: out std_logic;
		sel_out	: out std_logic; 
		
		-- fsm 2 handshake signal
		output_write : in std_logic;	
		output_write_clr : out std_logic;	
		output_busy_clr  : out std_logic;	
		
		-- fifo
		dst_ready : in std_logic;
		dst_write : out std_logic
	);
end groestl_fsm3;

architecture beh of groestl_fsm3 is 			 

constant hseg			: integer := hs/w;
constant log2hseg		: integer := log2( hseg );


begin
	fsm3 : sha3_fsm3 	
	generic map ( h => hs, w => w )
	port map (	   
		--global
		clk  => io_clk,
		rst		=> rst,
	
		-- datapath
		eo => eo,
		
		-- fsm 2 handshake signal
		output_write => output_write,
		output_write_clr => output_write_clr,
		output_busy_clr  => output_busy_clr,
		
		-- fifo
		dst_ready => dst_ready,
		dst_write => dst_write
	);
	
	d01 : d_ff port map (clk=>io_clk, rst=>rst, ena=>'1', d=>output_write, q=>sel_out) ;
	
end beh;

		
		
		
		