-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
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
use work.sha3_luffa_package.all;
use work.sha3_pkg.all;

entity luffa_top is		
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
end luffa_top;


architecture struct of luffa_top is
	constant round_length : integer := log2(8);
	
	-- fsm1
	signal ein, lc, ec: std_logic;
	signal zc0, final_segment : std_logic;
	-- fsm2
	signal er, lo, sf : std_logic;
	signal sstep_init, sfinal : std_logic;	 
	signal round : std_logic_vector(round_length-1 downto 0);
	-- fsm3
	signal eout : std_logic;
begin	  

    control_gen : entity work.luffa_control(struct) 
        generic map ( h => h, w => w, round_length => round_length )
        port map (
        rst => rst, clk => clk, 
        src_ready => src_ready, src_read => src_read, dst_ready => dst_ready, dst_write => dst_write,	  
        zc0 => zc0, final_segment => final_segment, ein => ein, ec => ec, lc => lc, 
        er => er, lo => lo, sf => sf, sfinal => sfinal, sstep_init => sstep_init,  round => round,
        eout => eout
    );			
    
    datapath_gen : entity work.luffa_datapath(struct) 
        generic map ( h => h, w => w, round_length => round_length )
        port map (
        clk => clk, din => din, dout => dout,
        zc0 => zc0, final_segment => final_segment, ein => ein, ec => ec, lc => lc, 
        er => er, lo => lo, sf => sf, sfinal => sfinal, sstep_init => sstep_init,  round => round,
        eout => eout
    );			
	
	
end struct;

	

