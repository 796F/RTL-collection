-- =====================================================================
-- Copyright © 2010-2011  by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

-- Possible generics values: 
--		h = {HASH_SIZE_256, HASH_SIZE_512}

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_shabal_package.all;

entity shabal_compact_top is		
	generic (	
		h : integer := HASH_SIZE_256	   	
	); 
	port (		
		-- global
		rst 	: in std_logic;
		clk 	: in std_logic;
		
		--fifo
		src_ready : in std_logic;
		src_read  : out std_logic;
		dst_ready : in std_logic;
		dst_write : out std_logic;
		din		: in std_logic_vector(31 downto 0);
		dout	: out std_logic_vector(31 downto 0)
	);	   
end shabal_compact_top;


architecture struct of shabal_compact_top is 
	signal zc0 : std_logic;
	signal ctrl : std_logic_vector(24 downto 0);	  
begin					
	control_gen : entity work.shabal_compact_controller(beh)
		generic map ( h => h)
		port map (
		rst => rst, clk => clk,
		src_ready => src_ready, src_read => src_read, dst_ready => dst_ready, dst_write => dst_write,
		final_segment => din(0), zc0 => zc0,
		ctrl => ctrl
	);
	
	datapath_gen : entity work.shabal_compact_datapath(struct)
		generic map ( h => h)
		port map (
		rst => rst, clk => clk, din => din, dout => dout,
		zc0 => zc0,
		ctrl => ctrl
	);
end struct;
	
	