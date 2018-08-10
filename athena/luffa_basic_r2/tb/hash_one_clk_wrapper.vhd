-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.ALL;
use work.sha_tb_pkg.all;

entity hash_one_clk_wrapper is
	generic ( 
		algorithm 	: string  := "bmw";
		hashsize 	: integer := 256;
		w 			: integer := 64; 
		pad_mode	: integer := PAD;	
		fifo_mode	: integer := ZERO_WAIT_STATE		
	);
	port (		
		rst 		: in std_logic;
		clk 		: in std_logic;		
		din			: in std_logic_vector(w-1 downto 0);		
	    src_read	: out std_logic;
	    src_ready	: in  std_logic;
	    dout		: out std_logic_vector(w-1 downto 0);
	    dst_write	: out std_logic;
	    dst_ready	: in std_logic
	);   
end entity;

architecture wrapper of hash_one_clk_wrapper is

begin
  
		abc: entity work.luffa_top(struct)
			generic map ( w => w, h => hashsize )
			port map (		
				-- global
				rst 	=> rst,
				clk 	=> clk,			
				--fifo
				din			=> din,
			    src_read	=> src_read,
			    src_ready	=> src_ready,
			    dout		=> dout,
			    dst_write	=> dst_write,
			    dst_ready	=> dst_ready
		);   		
	
end wrapper;