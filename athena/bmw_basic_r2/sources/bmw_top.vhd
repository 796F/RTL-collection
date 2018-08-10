-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

-- Possible generics values: 
--		h = {HASH_SIZE_256, HASH_SIZE_512} 
--		adder_type = {SCCA_BASED, SCCA_TREE_BASED, FCCA_TREE_BASED, CSA_BASED, PC_BASED}
--		fr = {8, 16} 
--
-- adder_type describes the type of adders being used in the critical paths. They are :
--      SCCA_BASED      => Standard Carry Chain Addition in FPGA. This is a simple '+' sign.
--      SCCA_TREE_BASED => Same as SCCA_BASED except grouping is done. i.e. (A + B) + (C + D) instead of (A + B + C + D)
--      FCCA_TREE_BASED => Similar to SCCA_TREE_BASED except adder used is the special Fast Carry Chain Adder which utilizes special property of 6-input LUT FPGA
--      CSA_BASED       => Carry Save Adder
--      PC_BASED        => Parallel Counter
--
-- fr describes the ratio of io_clk to clk i.e. by how much factor io_clk is operating compared to clk
--
-- Valid combinations :
-- 		For HASH_SIZE_256, use fr = 8
-- 		For HASH_SIZE_512, use fr = 16
-- 		any type of adder with the above combination is fine.

-- Extra generic :
-- 		w = {2^x} where x can be any reasonable number. By default, x is 6
-- Note : Input and output test vectors must correspond to the size of w

library ieee;
use ieee.std_logic_1164.all; 
use work.sha3_pkg.all;
use work.sha3_bmw_package.all;

entity bmw_top is		
	generic (  				 
		w : integer := 64;
		adder_type:integer:=SCCA_TREE_BASED;
		h : integer := HASH_SIZE_256;
		fr : integer := 8		
	); 
	port (		
		-- global
		rst 	: in std_logic;
		clk 	: in std_logic;
		io_clk 	: in std_logic;
		
		--fifo
		src_ready : in std_logic;
		src_read  : out std_logic;
		dst_ready : in std_logic;
		dst_write : out std_logic;		
		din		: in std_logic_vector(w-1 downto 0);
		dout	: out std_logic_vector(w-1 downto 0)
	);	   
end bmw_top;


architecture struct of bmw_top is 
	-- fsm1
	signal ein, lc, ec, em : std_logic;
	signal zc0, final_segment : std_logic;
	-- fsm2
	signal sf, sl, lo, ehprime, erprime : std_logic;
	-- fsm3
	signal eout : std_logic;		
begin
	control_gen : entity work.bmw_control(struct)
		generic map ( w => w, h => h, fr => fr )
		port map (
		rst => rst, clk => clk, io_clk => io_clk,
		src_ready => src_ready, src_read => src_read, dst_ready => dst_ready, dst_write => dst_write,	  
		ec => ec, lc => lc, ein => ein, zc0 => zc0, final_segment => final_segment, em => em,
		lo => lo, sf => sf, sl => sl, erprime => erprime, ehprime => ehprime,
		eout => eout
	);				
	datapath_gen : entity work.bmw_datapath(struct) 
		generic map (w => w, h => h, adders_type => adder_type )
		port map (
		clk => clk, io_clk => io_clk, din => din, dout => dout,
		ein => ein, lc => lc, ec => ec, zc0 => zc0, final_segment => final_segment, em => em,
		lo => lo, sf => sf, sl => sl, erprime => erprime, ehprime => ehprime,
		eout => eout
	);
end struct;
	
	