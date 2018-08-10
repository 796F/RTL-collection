-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.sha3_bmw_package.ALL;
use work.sha3_pkg.all;

entity bmw_datapath is 
	generic(
	w 	: integer := 64;
	h	: integer := 256;
	adders_type:integer:=SCCA_BASED);	
	port (
		-- external
		clk : in std_logic;
		io_clk : in std_logic;
		din  : in std_logic_vector(w-1 downto 0);	
		dout : out std_logic_vector(w-1 downto 0);	
		--fsm 1			  										
		ein : in std_logic;
		ec, lc : in std_logic;
		em : in std_logic;
		zc0, final_segment : out std_logic;
		
		--fsm 2			  
		sf : in std_logic;
		sl : in std_logic;
		lo : in std_logic; 
		erprime, ehprime : in std_logic;
		
		--fsm 3
		eout : in std_logic
		);
end bmw_datapath;

architecture struct of bmw_datapath is		
	constant b : integer := get_b(h);
	constant iw : integer := get_iw(h);
	constant h_init : std_logic_vector(b-1 downto 0) := get_hinit( h );
	constant const  : std_logic_vector(b-1 downto 0) := get_const( h );
	constant bzeros : std_logic_vector(b-1 downto 0) := (others => '0');
	
	signal rin, r, rin_temp, rprime, rmux : std_logic_vector(b-1 downto 0); 
	signal rdprime : std_logic_vector(h-1 downto 0); 
	signal pre_hmux, hmux, cv : std_logic_vector(b-1 downto 0);
	signal c : std_logic_vector(w-1-log2(b) downto 0);	 
	signal rin_shf : std_logic_vector(b-1-w downto 0);
	
	-- //////////////////
	-- DEBUGGING PART
	-- type std_logic_block is array (0 to 15) of std_logic_vector(iw - 1 downto 0) ;	
	-- function vec2blk  ( x : std_logic_vector(b-1 downto 0) ) return std_logic_block is
		-- variable retval : std_logic_block;
	-- begin
		-- for i in 0 to 15 loop
		-- retval(15-i) := x(iw*(i+1) - 1 downto iw*i);
		-- end loop;
		-- return retval;
	-- end vec2blk;	   
	-- signal rblk_in, rblk, cvblk, rp_blk : std_logic_block;
	-- //////////////////
	
begin				  
	-- //// DEBUGGING
	-- rblk_in <= vec2blk( rin_temp );
	-- rblk <= vec2blk( r );	
	-- rp_blk <= vec2blk( rprime );
	-- cvblk <= vec2blk( cv );
	-- -- END OF DEBUGGING	  
	-- //////////////////
	
	shfin_gen : sipo generic map ( N => b-w,M =>w) port map (clk => io_clk, en => ein, input => din, output => rin_shf );
	rin_temp <= rin_shf & din;
	rin_reg : regn generic map ( N=> b, init => bzeros ) port map ( clk => io_clk , rst => '0', en => em, input => rin_temp, output => rin );
		
	-- block decounter
	decounter_gen : decountern generic map ( N => w-log2(b), sub => 1 ) port map ( clk => io_clk, rst => '0', load => lc, en => ec, input => din(w-1 downto log2(b)), output => c );		
	zc0 <= '1' when c = 0 else '0';
	final_segment <= din(0);
	
	--============ msg reg
	rmux <= rprime when sl = '1' else rin;	   
	msg_reg_gen : regn generic map ( N => b, init => bzeros ) port map (clk => clk, rst => '0', en => erprime, input => rmux, output => r );
	
	--============ hash reg						 
	-- initialization vector 	  
	pre_hmux <= h_init when sf = '1' else rprime;		
	-- hmux
	hmux <= const when sl = '1' else pre_hmux;
	-- hreg
	hreg_gen : regn generic map ( N => b, init => bzeros ) port map ( clk => clk, rst => '0', en => ehprime, input => hmux, output => cv);	
	-- core							
	core_gen : entity work.bmw_round(struct) generic map ( adders_type=>adders_type, b => b, iw => iw, h => h ) port map ( message => r, h_prev => cv, h_next => rprime); 
	
	-- convert from big to little endian 
	rdprime <= switch_endian_byte(rprime, h, iw)(h-1 downto 0);

	--output	 								
	shfout_gen : piso generic map ( N => h, M => w ) port map (clk => io_clk, sel => lo, en => eout, input => rdprime, output => dout );
end struct;