-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

-- Possible generics values: 
--		h = {HASH_SIZE_256, HASH_SIZE_512} 
--		w = {32, 64}
--		me_type = {rom, generator}		-- Message expansion implementation style (rom = rom base, generator = matrix multiplication based)

-- Possible combinations :
-- 		(h, w ) = (HASH_SIZE_256, 32) and (HASH_SIZE_512, 64) 
--
-- 		For h = HASH_SIZE_256
--			me_type = {rom, generator}
--		For h = HASH_SIZE_512
--			me_type = rom
--
-- Extra generic :
-- 		w = {2^x} where x can be any reasonable number. By default, x is 5 for HASH_SIZE_256 and 6 for HASH_SIZE_512
-- Note : Input and output test vectors must correspond to the size of w
--
library ieee;
use ieee.std_logic_1164.all;
use work.sha3_hamsi_package.all;  
use work.sha3_pkg.all;

entity hamsi_top is		
	generic (		 
		me_type : integer := rom;
		w : integer := 32; 				 -- use 64 for h = 512
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
end hamsi_top; 


architecture struct of hamsi_top is 
	constant mw					: integer := w;	  
	constant roundnr 			: integer := get_round( h );
	constant roundnr_final 		: integer := get_round_final( h );
	constant log2roundnr_final	: integer := log2( roundnr_final );	
	
	-- fsm1
	signal ein, lc, ec: std_logic;	
	signal final_segment : std_logic;
	signal zc0 : std_logic;
	-- fsm2
	signal er, sf : std_logic;
	signal eh, sfinal, sr_init : std_logic;
	signal roundc : std_logic_vector(log2roundnr_final-1 downto 0);
	signal lo : std_logic;
	-- fsm3
	signal eout : std_logic;	 
	
	
begin	   	
	final_segment <= din(0);
	control_gen : entity work.hamsi_control(struct) 
		generic map ( roundnr => roundnr, roundnr_final =>	roundnr_final, log2roundnr_final =>	log2roundnr_final, mw => mw, h => h, w => w )
		port map (
		rst => rst, clk => clk,
		src_ready => src_ready, src_read => src_read, dst_ready => dst_ready, dst_write => dst_write,	  
		final_segment => final_segment, zc0 => zc0, ein => ein, ec => ec, lc => lc,
		er => er, sf => sf, eh => eh, sfinal => sfinal, sr_init => sr_init, roundc => roundc, lo => lo,
		eout => eout
	);			
	
	datapath_gen : entity work.hamsi_datapath(struct) 
		generic map ( me_type => me_type, mw => mw, w => w, h => h, log2roundnr_final => log2roundnr_final )
		port map (
		clk => clk, din => din, dout => dout,
		zc0 => zc0, ein => ein, ec => ec, lc => lc,
		er => er, sf => sf, eh => eh, sfinal => sfinal, sr_init => sr_init, roundc => roundc, lo => lo,
		eout => eout
	);

end struct;
	
	