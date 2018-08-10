-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

-- Possible generics values: 
--		h = {HASH_SIZE_256, HASH_SIZE_512} 


library ieee;
use ieee.std_logic_1164.all; 
use work.sha3_pkg.all;
use work.sha3_jh_package.all;

entity jh_top is		
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
		din		: in std_logic_vector(w-1 downto 0);
		dout	: out std_logic_vector(w-1 downto 0)
	);	   
end jh_top;


architecture struct of jh_top is 
	-- fsm1
	signal ein, lc, ec: std_logic;
	signal zc0, final_segment : std_logic;
	-- fsm2
	signal er, lo, sf : std_logic;
	signal srdp, erf : std_logic;
	-- fsm3
	signal eout : std_logic;
	-- top fsm									 
begin							
	control_gen : entity work.jh_control(struct)
		generic map ( h => h )
		port map (
		rst => rst, clk => clk,
		src_ready => src_ready, src_read => src_read, dst_ready => dst_ready, dst_write => dst_write,	  
		zc0 => zc0, final_segment => final_segment, ein => ein, ec => ec, lc => lc,
		er => er, lo => lo, sf => sf, srdp => srdp, erf => erf,
		eout => eout
	);			
	
	datapath_gen : entity work.jh_datapath(struct) 
		generic map ( h => h )
		port map (
		clk => clk, din => din, dout => dout,
		zc0 => zc0, final_segment => final_segment, ein => ein, ec => ec, lc => lc, 
		er => er, lo => lo, sf => sf, srdp => srdp, erf => erf,
		eout => eout
	);

end struct;
	
	