-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sha3_simd_package.all;
use work.twiddle_factor_pkg.all;
use work.sha3_pkg.all;

entity simd_datapath_twoclk is
	generic ( 				  
		b : integer := 512;
		w : integer := 64;
		h : integer := 256;
		feistels : integer := 4
	);
	port (
		-- external
		clk : in std_logic;
		io_clk : in std_logic;
		rst : in std_logic;
		din  : in std_logic_vector(w-1 downto 0);	
		dout : out std_logic_vector(w-1 downto 0);	
		--fsm 1		
		ein : in std_logic;
		ec, lc : in std_logic;	
		zclblock, final_segment : out std_logic;	
		em : in std_logic;
		-- ntt ctrl
		ctrl_ntt : in std_logic_vector(6 downto 0);
		--fsm 2			  		
		er : in std_logic;
		sf : in std_logic;
		lo : in std_logic;
		
		eh : in std_logic;		
		ctrl_cp : in std_logic_vector(2 downto 0);
		slr : in std_logic;
		sphi : in std_logic;
		sa	: in std_logic_vector(log2(feistels)-1 downto 0);
		spi : in std_logic_vector(1 downto 0);
		
		--fsm 3
		eout : in std_logic
	);				  
end simd_datapath_twoclk;

architecture struct of simd_datapath_twoclk is 	
	constant hinit : std_logic_vector(b-1 downto 0) := get_init( h );
	constant mw		: integer := b;			  
	constant bzeros 		: std_logic_vector(b-1 downto 0) := (others => '0');	
	
	-- output signals									
	signal ww, hout_arr, wmux : array_w(0 to 3,0 to feistels-1);
	signal min_in : std_logic_vector(b-1-w downto 0);
	signal min_in2, min, msg : std_logic_vector(b-1 downto 0);
	signal r, rp, hmux, msgmux, hin, hout  : std_logic_vector(b-1 downto 0);  
	
	signal ntt_start : std_logic;  
	signal rpout, rpout2 : std_logic_vector(h-1 downto 0);	   
	constant wzeros : std_logic_vector(w-1 downto 0) := (others => '0');
	constant log2mw : integer := log2( b );
	signal c : std_logic_vector(w-log2mw-1 downto 0);
	
	-- debug
	signal r1, r2, m1, m2 : std_logic_vector(b/2-1 downto 0);
begin					   
	-- debug #####
	r1 <= r(b-1 downto b/2);
	r2 <= r(b/2-1 downto 0);
	m1 <= min_in2(b-1 downto b/2);
	m2 <= min_in2(b/2-1 downto 0);
	-- EOD
	
	final_segment <= din(0);
	zclblock <= '1' when c = 1 else '0';
	-- ################
	-- block decounter																									   	
	decounter_gen : decountern generic map ( N => w-log2mw, sub => 1 ) port map ( clk => io_clk, rst => '0', load => lc, en => ec, input => din(w-1 downto log2mw), output => c(w-log2mw-1 downto 0) );	
	-- datapath
	shfin_gen : sipo generic map ( N => mw-w,M => w) port map (clk => io_clk, en => ein, input => din, output => min_in ); 		  
	min_in2 <= (min_in & din);
	min_reg : regn generic map ( N => b, init => bzeros) port map (clk => io_clk, rst => rst, en => em, input => min_in2,output => min); 
	
	ntt_start <= ctrl_ntt(4);
	msg_reg : regn generic map ( N => b, init => bzeros) port map (clk => clk, rst => rst, en => ntt_start, input => min,output => msg); -- ctrl_ntt(4) = start ntt
	
	
	
	msgmux <= switch_endian_byte(msg,b,32) when eh = '1' else bzeros;
	hmux <= hinit when sf = '1' else rp;
	hin <= hmux xor msgmux;	
	hreg : regn generic map ( N => b, init => bzeros) port map (clk => clk, rst => rst, en => eh, input => hmux,output => hout);
	rreg : regn generic map ( N => b, init => bzeros) port map (clk => clk, rst => rst, en => er, input => hin,output => r);
	
	-- message expansion					
	hout_arr_gen1 : for i in 0 to 3 generate
		hout_arr_gen2 : for j in 0 to feistels-1 generate   
			hout_arr(i,j) <= hout(b-1-i*(feistels*32)-j*32 downto b-i*(feistels*32)-j*32-32);
		end generate;
	end generate;	
	me_gen : entity work.simd_me(struct)  generic map ( b => b, h => h, feistels => feistels ) port map (clk => clk, rst => rst, ctrl_ntt => ctrl_ntt, ctrl_cp => ctrl_cp, msg => min, ww => ww);	 
	wmux <= hout_arr when slr = '1' else ww;	
	-- 4 steps
	step4_gen : entity work.halfround(struct) generic map ( b => b, feistels => feistels ) port map ( ii => r, ww => wmux, sphi => sphi, slr => slr, sa => sa, spi => spi, oo => rp );

	rpout <= rp(b-1 downto h);	
	rpout2 <= switch_endian_byte(rpout,h,32);
	shfout_gen : piso generic map ( N => h, M => w ) port map (clk => io_clk, sel => lo, en => eout, input => rpout2, output => dout );		
end struct;