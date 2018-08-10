-- =========================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =========================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sha3_blake_package.ALL;
use work.sha3_pkg.all;

entity blake_datapath is	 	
	generic (	  	   		
		b : integer := 512;
		w : integer := 64;
		iw : integer := 32;
		h : integer := 256;
		ADDER_TYPE : integer := SCCA_BASED);
	port (
		-- external
		rst : in std_logic;
		clk : in std_logic;

		din  : in std_logic_vector(w-1 downto 0);	
		dout : out std_logic_vector(w-1 downto 0);	
		--fsm 1		
		ein : in std_logic;
		ec, lc, lc2, lm : in std_logic;	
		final_segment, zclblock, zcblock : out std_logic;		  
		extra_block : out std_logic;
		dt, eth, etl : in std_logic;		
		--fsm 2			  		
		slr : in std_logic;						
		round : in std_logic_vector(4 downto 0);				
		er, em : in std_logic;
		
		sf : in std_logic;
		lo : in std_logic;	  
		
		
		--fsm 3
		eo : in std_logic
	);				  
end blake_datapath;

architecture struct of blake_datapath is   
	
	--constant salt_init : std_logic_vector(4*iw-1 downto 0) := (others => '0');
	constant mw 			: integer := b;		 
	constant bseg			: integer := b/w;		  
	constant log2b			: integer := log2( b );
	constant log2bzeros		: std_logic_vector(log2b-1 downto 0) := (others => '0');	
	constant bzeros			: std_logic_vector(b-1 downto 0) := (others => '0');
	constant bhalfzeros		: std_logic_vector(b/2-1 downto 0) := (others => '0');
	constant bmin	: integer := b - 2 - iw*2;
	-------------
	
	
	signal t : std_logic_vector(2*iw-1 downto 0);
	signal th : std_logic_vector(2*iw-1 - log2b downto 0);
	signal tl : std_logic_vector(log2b-1 downto 0);	
	
	constant iv : std_logic_vector(b/2-1 downto 0) := get_iv( h, iw );
	signal hinit, rdprime, rmux : std_logic_vector(b/2 - 1 downto 0);
	signal rinit, rin, r, rprime : std_logic_vector(b-1 downto 0);
	
	signal min : std_logic_vector(b-w-1 downto 0);
	signal mreg_in, m : std_logic_vector(b-1 downto 0);
		
	signal cons : std_logic_vector(b-1 downto 0);	
	signal consout : std_logic_vector(iw*8-1 downto 0); 
	
	signal eout, eh : std_logic;	  	 
	
	signal c_s : std_logic_vector(w-1 downto 0);

	
	
	--type std_logic_matrix is array (0 to 15) of std_logic_vector(iw - 1 downto 0) ;
	type std_logic_matrix is array (natural range <>) of std_logic_vector(iw - 1 downto 0) ;
	function wordmatrix2blk  	(x : std_logic_matrix) return std_logic_vector is
		variable retval : std_logic_vector(b-1 downto 0);
	begin
		for i in 0 to 15 loop
			retval(iw*(i+1) - 1 downto iw*i) := x(15-i);
		end loop;
		return retval;
	end wordmatrix2blk;


	function blk2wordmatrix  	(x : std_logic_vector ) return std_logic_matrix is
		variable retval : std_logic_matrix(0 to 15);
	begin
		for i in 0 to 15 loop
		retval(15-i) := x(iw*(i+1) - 1 downto iw*i);
		end loop;
		return retval;
	end blk2wordmatrix;
	

	function halfblk2wordmatrix  	(x : std_logic_vector ) return std_logic_matrix is
		variable retval : std_logic_matrix(0 to 7);
	begin
		for i in 0 to 7 loop
		retval(7-i) := x(iw*(i+1) - 1 downto iw*i);
		end loop;
		return retval;
	end halfblk2wordmatrix;
	
	
	signal v1, v2, v2_perm, v2_revert, v3 : std_logic_matrix( 0 to 15 ); 
	signal cp : std_logic_matrix(0 to 7);	 
	
	type bot_permute_type is array ( 0 to 15 ) of integer;
	constant bot_permute : bot_permute_type := ( 0,1,2,3,5,6,7,4,10,11,8,9,15,12,13,14 );
	
	signal c2_s : std_logic_vector(w-log2b-1 downto 0);
	signal load_c : std_logic;
	-- debug			  
	--signal rinit_m, r_m, cp_m, mp_m : std_logic_matrix(0 to 15);	
begin		
	-- debug
	-- rinit_m <= blk2wordmatrix( rin );		 
	-- r_m <= blk2wordmatrix( r );	
	--			
	zclblock <= '1' when c_s < b else '0';
	zcblock <= '1' when c_s = b else '0';	
	final_segment <= din(0);	
	
	
	shfin_gen : sipo generic map ( N => (mw-w),M =>w) port map (clk => clk, en => ein, input => din, output => min );   
	mreg_in <= min & din;
	mreg : regn generic map (N => mw, init => bzeros) port map (clk => clk, rst => '0', en => lm, input => mreg_in, output => m );
		
	-- block decounter																									   	
	load_c <= lc or lc2;
	decounter_gen : decountern generic map ( N => w, sub => b ) port map ( clk => clk, rst => '0', load => load_c, en => ec, input => din, output => c_s );
	
	dcntr2_gen : decountern generic map ( N => w-log2b, sub => 1 ) port map ( clk => clk, rst => rst, load => lc2, en => ec, input => c_s(w-1 downto log2b), output => c2_s );
	extra_block <= '1' when c2_s = 2 else '0';
	-- Note : Xilinx keeps optimizing the register + decountern away so the above
	--		  operation is performed to prevent automatic truncation.
	-- 		  Previous method used --> extra_block <= c2_s(1);
	
	-- t gens																		
	th_gen : countern generic map ( N => 2*iw-log2b, step => 1 ) port map ( clk => clk, rst => dt, load => '0', en => eth, input => conv_std_logic_vector(0,2*iw-log2b), output => th );
	tl_gen : regn generic map ( N => log2b, init => log2bzeros ) port map ( clk => clk, rst => dt, en => etl, input => c_s(log2b-1 downto 0), output => tl );
	t <= th & tl;																									
	
	rmux <= iv when sf = '1' else rdprime;

	rinit <= rmux &  cons(b-1 downto b-iw*4)  & 
			(t(iw-1 downto 0) xor cons(b-1-iw*4 downto b-iw*5)) &  (t(iw-1 downto 0) xor cons(b-iw*5-1 downto b-iw*6)) &
			( t(2*iw-1 downto iw) xor cons(b-1-iw*6 downto b-iw*7))  & (t(2*iw-1 downto iw) xor cons(b-iw*7-1 downto b-iw*8));
	
	eh <= sf or slr;
	hreg_gen : regn generic map ( N => b/2, init => bhalfzeros ) port map (clk => clk, rst => '0', en => eh, input => rmux, output => hinit );	
	
	rin <= rinit when (sf = '1' or slr = '1' ) else rprime;
	r_gen : regn generic map ( N => b, init => bzeros ) port map (clk => clk, rst => '0', en => er, input => rin, output => r );		
		
	v1 <= blk2wordmatrix(r);
	perm4_gen : entity work.permute4xor(muxbased) generic map (h =>h, b => b, iw => iw) port map ( clk => clk,  em => em, m => m, cons => cons, round => round, consout => consout );

	cp <= halfblk2wordmatrix(consout);
	glvl1 : for i in 0 to 3 generate
		g0123 : entity work.gfunc_modified(struct) 	generic map ( iw => iw, h => h, ADDER_TYPE => ADDER_TYPE )
						port map ( ain => v1(i),bin => v1(i+4),cin => v1(i+8),din => v1(i+12),
							  const_0 => cp(2*i),const_1 => cp(2*i + 1),
							  aout =>  v2(i), bout => v2(i+4), cout=> v2(i+8),dout => v2(i+12));
	end generate;
	
	v2_gen : for i in 0 to 15 generate
		v2_perm( bot_permute(i) ) <= v2( i ); 
		v2_revert( i ) <= v2( bot_permute(i) );
	end generate;
	
	v3 <= v2_perm when round(0) = '1' else v2_revert;
		
	rprime <= wordmatrix2blk(v3);
	
	--finalization					
	rdprime <= hinit xor r(b-1 downto b/2) xor r(b/2-1 downto 0);
	
	
	--output	 								
	eout <= eo or lo;
	shfout_gen : piso generic map ( N => h, M => w ) port map (clk => clk, sel => lo, en => eout, input => rdprime, output => dout );		
end struct;