-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sha3_jh_package.all;
use work.sha3_pkg.all;

entity jh_datapath is	
	generic ( h : integer := 256 );
	port (
		-- external
		clk : in std_logic;
		din  : in std_logic_vector(w-1 downto 0);	
		dout : out std_logic_vector(w-1 downto 0);	
		--fsm 1		
		ein : in std_logic;
		ec, lc : in std_logic;	
		zc0, final_segment : out std_logic;
		--fsm 2			  		
		erf : in std_logic;
		er : in std_logic;
		sf : in std_logic;
		lo : in std_logic;
		
		srdp : in std_logic;		
		
		--fsm 3
		eout : in std_logic
	);				  
end jh_datapath;


architecture struct of jh_datapath is 
	--input		  
	signal min, min_out : std_logic_vector(mw-1 downto 0);
	
	-- round constant
	signal crd_out, crdp : std_logic_vector(crw-1 downto 0);
	
	-- round			  
	signal g, dg : std_logic_vector(b-1 downto 0);
	signal rin, rout, rd_out, rd_last : std_logic_vector(b-1 downto 0);
	signal hp, hm : std_logic_vector(b-1 downto 0);
	signal hp_or_iv : std_logic_vector(b-1 downto 0);
	signal c : std_logic_vector(w-log2mw-1 downto 0);	
	constant iv : std_logic_vector(b-1 downto 0) := get_iv( h );
	
	-- debug  						   
--	signal crdo : std_logic_vector(b-1 downto 0);
--	constant zeros : std_logic_vector(b-1-crw downto 0) := (others => '0');
--	signal dg_m, rin_m, rout_m, rd_out_m, crd_out_m, hm_m, hp_m : std_logic_matrix;
begin						
	---//////////////---
	-- block decounter																									   	
	decounter_gen : decountern generic map ( N => w-log2mw, sub => 1 ) port map ( clk => clk, rst => '0', load => lc, en => ec, input => din(w-1 downto log2mw), output => c(w-log2mw-1 downto 0) );	
	zc0 <= '1' when c = 0 else '0';																																										
	final_segment <= din(0);
	
	-- input
	shfin_gen : sipo generic map ( N => mw,M => w) port map (clk => clk, en => ein, input => din, output => min );
	-- input register (for xor at the last round of a block )
	min_reg : regn generic map ( N => mw, init => mwzeros ) port map ( clk => clk, rst => '0', en => srdp, input => min, output => min_out );
	-- input to r reg
	hm <= ( min xor hp_or_iv(b-1 downto b/2) ) & hp_or_iv(b/2-1 downto 0);	
	hp_or_iv <= iv when sf = '1' else hp;	
	
	-- group (rearrange them into correct order)		   
	g <= form_group( hm, b, crw );
	rin <= g when srdp = '1' else rd_out;

	--R registers
	rreg_gen : regn generic map ( N => b, init => bzeros ) port map ( clk => clk, rst => '0', en => er, input => rin, output => rout );		
	
	-- round	
	rd_gen 	: entity work.jh_rd(struct) generic map ( bw => b, cw => crw  ) port map ( input => rout, cr => crd_out, output => rd_out, output_last => rd_last );
		
	-- output to round function	 
	dg <= degroup( rd_last, b, crw );
 	hp <= dg(b-1 downto b/2) & ( min_out xor dg(b/2-1 downto 0) );
	
	-- output 
	shfout_gen : piso generic map ( N => h, M => w ) port map (clk => clk, sel => lo, en => eout, input => hp(h-1 downto 0), output => dout );		

	--- ////////////////////////////////////
	-- round constant (generate using generator)	
	crd_reg : regn generic map ( N => crw, init => cr8_iv ) port map ( clk => clk, rst => erf, en => er, input => crdp, output => crd_out );
	crd_gen : entity work.jh_rd(struct) generic map ( bw => crw, cw => crkw ) port map ( input => crd_out, cr => crkwzeros, output => crdp);
		
--	--debug
--	rin_m <= blk2wordmatrix_inv( rin );
--	rout_m <= blk2wordmatrix_inv( rout );
--	rd_out_m <= blk2wordmatrix_inv( rd_out );
--	dg_m <= blk2wordmatrix_inv( dg );
--	hp_m <= blk2wordmatrix_inv( hp );
--	hm_m <= blk2wordmatrix_inv( hm );
--	crdo <= crd_out & zeros;
--	crd_out_m <= blk2wordmatrix_inv( crdo );
end struct;