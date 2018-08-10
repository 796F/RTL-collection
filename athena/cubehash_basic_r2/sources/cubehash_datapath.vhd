-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sha3_cubehash_package.ALL;
use work.sha3_pkg.all;

entity cubehash_datapath is	 
	generic ( 
		w : integer := 64;
		h : integer := HASH_SIZE_256;
		mw : integer := 256 );
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
		er : in std_logic;
		sf : in std_logic;
		lo : in std_logic;
		
		sfinal : in std_logic;
		sm : in std_logic;
		
		--fsm 3
		eout : in std_logic
	);				  
end cubehash_datapath;

architecture struct of cubehash_datapath is 
	constant mwzeros : std_logic_vector(mw-1 downto 0) := (others =>'0');
	constant iv : std_logic_vector(b - 1 downto 0) := get_iv( h );
	signal rmux : std_logic_vector(b - 1 downto 0);
	signal rin, rprime, rr : std_logic_vector(b-1 downto 0);
	
	signal min, m, m1 : std_logic_vector(mw-1 downto 0);	
	signal c : std_logic_vector(55 downto 0); 
	-- output signals
	signal out1, out2 : std_logic_vector(h-1 downto 0);
	
	-- ################
	-- debugging signals
--	type matrix is array (15 downto 0) of std_logic_vector(63 downto 0) ;	
--	function blk2matrix  ( x : std_logic_vector(1023 downto 0) ) return matrix is
--		variable retval : matrix;
--	begin
--		for i in 0 to 15 loop
--		retval(15-i) := x(64*(i+1) - 1 downto 64*i);
--		end loop;
--		return retval;
--	end blk2matrix;
--	signal rblk, rpblk, rmuxblk : matrix;	   
--
begin				   
--	-- ################
--	-- DEBUGGING SIGNALS
--	rblk <= blk2matrix( rr );
--	rpblk <= blk2matrix( rprime );		
--	rmuxblk <= blk2matrix( rmux );	
	
	-- ################
	-- block decounter																									   	
	decounter_gen : decountern generic map ( N => 56, sub => 1 ) port map ( clk => clk, rst => '0', load => lc, en => ec, input => din(w-1 downto 8), output => c );
	zc0 <= '1' when c = 0 else '0';
	final_segment <= din(0);
	
	-- datapath
	shfin_gen : sipo generic map ( N => mw,M => w) port map (clk => clk, en => ein, input => din, output => min );
	
	--- message in little endian format
	m1 <= switch_endian_byte( min, mw, iw )  when sm = '1' else mwzeros;
	m <= switch_endian_word( m1, mw, iw );
	
	-- message xor
	rmux <= switch_endian_word( iv , b , iw) when sf = '1' else (rprime(b-1 downto b-iw+1) & (rprime(b-iw) xor sfinal) & rprime(b-iw-1 downto 0));
	rin <= rmux(b-1 downto mw) & (rmux(mw-1 downto 0) xor m);
	r_gen : regn generic map ( N => b, init => bzeros ) port map (clk => clk, rst => '0', en => er, input => rin, output => rr );						
	
	round_gen : entity work.cubehash_round(struct) port map (datain => rr, dataout => rprime);

	--output	
		-- convert to big endian for outputting data
		out1 <= switch_endian_byte( rprime(h-1 downto 0), h, iw);	
		out2 <= switch_endian_word( out1, h, iw); 
	
	shfout_gen : piso generic map ( N => h, M => w ) port map (clk => clk, sel => lo, en => eout, input => out2,  output => dout );		
end struct;