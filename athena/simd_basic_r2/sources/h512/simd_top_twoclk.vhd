-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_simd_package.all;	
use work.sha3_pkg.all;

entity simd_top_twoclk is		
	port (		
		-- global
		rst 	: in std_logic;
		clk 	: in std_logic;
		io_clk  : in std_logic;
		--fifo
		src_ready : in std_logic;
		src_read  : out std_logic;
		dst_ready : in std_logic;
		dst_write : out std_logic;		
		din		: in std_logic_vector(63 downto 0);
		dout	: out std_logic_vector(63 downto 0)
	);	   
end simd_top_twoclk;


architecture struct of simd_top_twoclk is 	
    constant fr : integer := 2;
    constant w : integer := 64;
    constant h : integer := 512;
    
	constant b : integer := get_b( h );
	constant feistels : integer := get_feistels( h );
	
	-- fsm1
	signal ein, lc, ec, em: std_logic; 
	signal zclblock, final_segment : std_logic;
	-- ntt ctrl
	signal ctrl_ntt : std_logic_vector(6 downto 0);
	-- fsm2
	signal er, lo, sf : std_logic;	
	signal eh, slr, sphi : std_logic;
	signal ctrl_cp : std_logic_vector(2 downto 0);
	signal sa  : std_logic_vector(log2(feistels)-1 downto 0);
	signal spi : std_logic_vector(1 downto 0);
	-- fsm3
	signal eout : std_logic;						 
begin		
	control_gen : entity work.simd_control_twoclk(struct) 
		generic map ( fr => fr, b => b, w => w , h => h, feistels => feistels )
		port map (
		rst => rst, clk => clk, io_clk => io_clk,
		src_ready => src_ready, src_read => src_read, dst_ready => dst_ready, dst_write => dst_write,	  
		zclblock => zclblock, final_segment => final_segment, ein => ein, ec => ec, lc => lc, em => em,
		ctrl_ntt => ctrl_ntt,
		er => er, lo => lo, sf => sf, eh => eh, slr => slr, sphi => sphi, ctrl_cp => ctrl_cp, sa => sa, spi => spi,
		eout => eout
	);			
	
	datapath_gen : entity work.simd_datapath_twoclk(struct) 
		generic map ( b => b, w => w , h => h, feistels => feistels )
		port map (
		clk => clk, io_clk => io_clk, din => din, dout => dout, rst => rst,
		zclblock => zclblock, final_segment => final_segment, ein => ein, ec => ec, lc => lc, em => em,
		ctrl_ntt => ctrl_ntt,
		er => er, lo => lo, sf => sf, eh => eh, slr => slr, sphi => sphi, ctrl_cp => ctrl_cp, sa => sa, spi => spi,
		eout => eout
	);

end struct;
	
	