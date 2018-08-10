-- =========================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =========================================================================

-- Possible generic values: 
--		h = {HASH_SIZE_256, HASH_SIZE_512}
-- 		adder_type = {SCCA_BASED, CSA_BASED}
--
-- adder_type describes the type of adders being used in the critical paths. They are :
--      SCCA_BASED      => Standard Carry Chain Addition in FPGA. This is a simple '+' sign.
--      CSA_BASED       => Carry Save Adder.

-- Extra generic :
-- 		w = {2^x} where x can be any reasonable number. By default, x is 6
-- Note : Input and output test vectors must correspond to the size of w


library ieee;
use ieee.std_logic_1164.all; 
use work.sha3_pkg.all;
use work.sha3_blake_package.all;

entity blake_top is		
	generic (			   			
		h : integer := HASH_SIZE_256;
		adder_type : integer := SCCA_BASED;	 	
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
end blake_top;


architecture struct of blake_top is  
	constant b : integer := get_b( h );
	constant iw : integer := get_iw( h );

	signal io_clk : std_logic;
	-- fsm1						   
	signal extra_block, lc2 : std_logic;
	signal ein, lc, ec, lm: std_logic;
	signal dt, eth, etl : std_logic;  
	signal zclblock, zcblock, final_segment : std_logic;
	-- fsm2
	signal er, em, lo, sf, slr : std_logic;
	signal round : std_logic_vector(4 downto 0); 
	-- fsm3
	signal eo : std_logic;
									 
begin			   
	control_gen : entity work.blake_control(struct) 
		generic map ( iw => iw, b => b, h => h, w => w  )
		port map (
		rst => rst, clk => clk,
		src_ready => src_ready, src_read => src_read, dst_ready => dst_ready, dst_write => dst_write,	  
		final_segment => final_segment, zclblock => zclblock, zcblock => zcblock, ein => ein, ec => ec, 
			lc => lc, dt => dt, eth => eth, etl => etl, extra_block => extra_block, lc2 => lc2, lm => lm,
		er => er, em => em, lo => lo, sf => sf, slr => slr, round => round,
		eo => eo		
	);			
	
	datapath_gen : entity work.blake_datapath(struct) 	
		generic map ( b => b, iw => iw, h => h, w => w, adder_type => adder_type  )
		port map (
		rst => rst, clk => clk, din => din, dout => dout, 
		final_segment => final_segment, zclblock => zclblock, zcblock => zcblock, ein => ein, ec => ec, 
			lc => lc, dt => dt, eth => eth, etl => etl, extra_block => extra_block, lc2 => lc2, lm => lm,
		er => er, em => em, lo => lo, sf => sf, slr => slr, round => round,
		eo => eo
	);

end struct;
	
	