-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

-- Possible generics values: 
--		h = {HASH_SIZE_256, HASH_SIZE_512} 
--		adder_type = {SCCA_BASED, CLA_BASED, FCCA_BASED}
--
-- adder_type describes the type of adders being used in the critical paths. They are :
--      SCCA_BASED      => Standard Carry Chain Addition in FPGA. This is a simple '+' sign.
--      FCCA_BASED      => Fast Carry Chain Adder which utilizes special property of 6-input LUT FPGA (Applicable only to certain families of FPGA)
--      CLA_BASED       => Carry Look-Ahead Adder
--
-- All combinations are allowed.
--
-- Extra generic :
-- 		w = {2^x} where x can be any reasonable number. By default, x is 6
-- Note : Input and output test vectors must correspond to the size of w

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_skein_package.all;
use work.sha3_pkg.all;

entity skein_top is		
	generic (	
		adder_type : integer := SCCA_BASED; 
		w : integer := 64;				  
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
end skein_top;


architecture structure of skein_top is   
	-- fsm1
	signal ein, lc, ec: std_logic;
	signal zclblock, final_segment : std_logic;
	signal dth, eth : std_logic;
	-- fsm2
	signal er, etweak, lo, sf : std_logic;
	signal slast, snb, sfinal : std_logic;	 
	-- fsm3
	signal eout : std_logic;
									 	
begin		 
	control_gen : entity work.skein_control(struct)  
		generic map ( w => w,  h => h )
		port map (
		rst => rst, clk => clk,
		src_ready => src_ready, src_read => src_read, dst_ready => dst_ready, dst_write => dst_write,	  
		zclblock => zclblock, final_segment => final_segment, ein => ein, ec => ec, lc => lc, dth => dth, eth => eth, etweak => etweak,
		er => er, lo => lo, sf => sf, sfinal => sfinal, snb => snb,  slast => slast, 
		eout => eout
	);			
	
	datapath_gen : entity work.skein_datapath(struct) 
		generic map ( adder_type => adder_type, w => w, h => h)
		port map (
		clk => clk, din => din, dout => dout,
		zclblock => zclblock, final_segment => final_segment, ein => ein, ec => ec, lc => lc, dth => dth, eth => eth, etweak => etweak,
		er => er, lo => lo, sf => sf, sfinal => sfinal,  snb => snb,  slast => slast, 
		eout => eout
	);

end structure;
	
	