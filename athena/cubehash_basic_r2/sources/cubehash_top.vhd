-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

-- Possible generics values: 
--		h = {HASH_SIZE_256, HASH_SIZE_512}

-- Extra generic :
-- 		w = {2^x} where x can be any reasonable number. By default, x is 6
-- Note : Input and output test vectors must correspond to the size of w

library ieee;
use ieee.std_logic_1164.all;	
use work.sha3_pkg.all;
use work.sha3_cubehash_package.all;

entity cubehash_top is		
	generic (
		h : integer := HASH_SIZE_256;
		w : integer := 64
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
end cubehash_top;


architecture struct of cubehash_top is 
	-- fsm1
	signal ein, lc, ec: std_logic; 
	signal zc0, final_segment : std_logic;
	-- fsm2
	signal er, lo, sf : std_logic;
	signal sm, sfinal : std_logic;
	-- fsm3
	signal eout : std_logic;	

	constant mw : integer := 32*8;
begin		
	control_gen : entity work.cubehash_control(struct) 
		generic map ( w => w, h => h, mw => mw )
		port map (
		rst => rst, clk => clk,
		src_ready => src_ready, src_read => src_read, dst_ready => dst_ready, dst_write => dst_write,	  
		zc0 => zc0, final_segment => final_segment, ein => ein, ec => ec, lc => lc, 
		er => er, lo => lo, sf => sf, sfinal => sfinal, sm => sm,
		eout => eout
	);			
	
	datapath_gen : entity work.cubehash_datapath(struct) 
		generic map ( w => w, h => h, mw => mw )
		port map (
		clk => clk, din => din, dout => dout,
		zc0 => zc0, final_segment => final_segment,  ein => ein, ec => ec, lc => lc, 
		er => er, lo => lo, sf => sf, sfinal => sfinal, sm => sm,
		eout => eout
	);

end struct;
	
					  