-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sha3_hamsi_package.ALL;
use work.sha3_pkg.all;

entity hamsi_datapath is	
	generic (			   
		me_type : integer := generator;
		mw : integer := 32;
		w : integer := 32;	 
		iw : integer := 32;
		log2roundnr_final : integer := 3;
		h : integer := 256
	);
	port (
		-- external
		clk : in std_logic;		
		din  : in std_logic_vector(w-1 downto 0);	
		dout : out std_logic_vector(w-1 downto 0);	
		--fsm 1			   	   
		ein : in std_logic;
		ec, lc : in std_logic;		   
		zc0 : out std_logic;
		--zc0, final_segment : out std_logic;
		--fsm 2			  		
		er : in std_logic;
		sf : in std_logic; 		
		
		eh	: in std_logic;
		sfinal : in std_logic;
		sr_init : in std_logic;		
		roundc : in std_logic_vector(log2roundnr_final-1 downto 0);
		lo	: in std_logic;
		
		--fsm 3
		eout : in std_logic
	);				  
end hamsi_datapath;

architecture struct of hamsi_datapath is 	 
	-- //////////////////////
	-- // Constant Declaration	   
		
	type std_logic_matrix is array (natural range <>) of std_logic_vector(iw-1 downto 0) ;
	type std_logic_half_matrix is array (natural range <>) of std_logic_vector(iw-1 downto 0) ;
	
	constant b 				: integer := get_b( h );	
	constant bseg			: integer := b/32; 
	constant bhalfseg		: integer := (b/2)/32;	   	
	constant hzeros			: std_logic_vector(h-1 downto 0) := (others => '0');  
	constant wzeros			: std_logic_vector(w-1 downto 0) := (others => '0');
	
	function wordmatrix2blk  (signal x : in std_logic_matrix) return std_logic_vector is
		variable retval : std_logic_vector(b-1 downto 0);
	begin	
		for i in 0 to bseg-1 loop
			retval(iw*(i+1) - 1 downto iw*i) := x(bseg-1-i);
		end loop;
		return retval;
	end wordmatrix2blk;


	function blk2wordmatrix  (signal x : in std_logic_vector ) return std_logic_matrix is
		variable retval : std_logic_matrix(bseg-1 downto 0);
	begin
		for i in 0 to bseg-1 loop
			retval(bseg-1-i) := x(iw*(i+1) - 1 downto iw*i);
		end loop;
		return retval;
	end blk2wordmatrix;	 
	
	function wordmatrix2halfblk  (signal x : in std_logic_half_matrix) return std_logic_vector is
		variable retval : std_logic_vector(b/2-1 downto 0);
	begin	
		for i in 0 to bhalfseg-1 loop
			retval(iw*(i+1) - 1 downto iw*i) := x(bhalfseg-1-i);
		end loop;
		return retval;
	end wordmatrix2halfblk;
	function halfblk2wordmatrix  (signal x : in std_logic_vector ) return std_logic_half_matrix is
		variable retval : std_logic_half_matrix(bhalfseg-1 downto 0);
	begin
		for i in 0 to bhalfseg-1 loop
			retval(bhalfseg-1-i) := x(iw*(i+1) - 1 downto iw*i);
		end loop;
		return retval;
	end halfblk2wordmatrix;			   
	
	-- //////////////////////
	-- /// Signal Declaration
	
	constant iv : std_logic_vector(b/2 - 1 downto 0) := get_iv( h );   
	
	signal hin, hout, tout, toutxorhout : std_logic_vector(b/2 - 1 downto 0);
	signal min 			: std_logic_vector(w-1 downto 0);
	signal msg, chain  				: std_logic_half_matrix(bhalfseg-1 downto 0);						   
	signal msgtemp 					: std_logic_vector(b/2-1 downto 0);
	
	-- concat
	signal concat_out				: std_logic_vector(b - 1 downto 0);
	signal concat_out_matrix		: std_logic_matrix(bseg-1 downto 0);
	signal pin, pout				: std_logic_matrix(bseg-1 downto 0);
	signal alpha 					: std_logic_matrix(bseg-1 downto 0);
	signal alphaf					: std_logic_matrix(bseg-1 downto 0);
	signal alpha_in 				: std_logic_matrix(bseg-1 downto 0);
	signal rc 						: std_logic_vector(iw-1 downto 0);	
	
	-- acc 
	signal acc : std_logic_matrix(0 to bseg-1 );	 
	-- sbox		   
	signal sbox_in, sbox_out_slv : std_logic_vector(b-1 downto 0);
	type sbox_box is array (0 to b/4 - 1)  of std_logic_vector(3 downto 0);
	signal sbox_boxin, sbox_boxout : sbox_box;
	signal sbox_out : std_logic_matrix(bseg-1 downto 0);	 
	-- diffusion layers
	signal lout, lout_temp : std_logic_matrix(bseg-1 downto 0);  		   
	
	-- rc
	constant extendzero_cons : std_logic_vector(iw-log2roundnr_final-1 downto 0) := (others => '0');	
	
	-- c 
	signal c : std_logic_vector(w-log2(w)-1 downto 0);	
--	-- segment counter		   
--	constant log2mw : integer := log2(mw);
--	signal c : std_logic_vector(w-log2mw-1 downto 0);
begin	
	---//////////////---
	-- block decounter																									   	
	decounter_gen : decountern generic map ( N => w-log2(w), sub => 1 ) port map ( clk => clk, rst => '0', load => lc, en => ec, input => din(w-1 downto log2(w)), output => c );	
	zc0 <= '1' when c = 1 else '0';		 
	
	---//////////////---
	-- input
	shfin_gen : regn generic map ( N => w, init => wzeros) port map (clk => clk, rst => '0', en => ein, input => din, output => min );
	
	---//////////////---
	-- Message Expansion
	me_gen1 : if me_type = generator generate
		me_gen : entity work.hamsi_me(generator) generic map (b => b, w => w, h => h) port map ( min => min, msg => msgtemp );	   	
	end generate;
	me_gen2 : if me_type = rom generate
		me_gen : entity work.hamsi_me(rom) generic map ( b => b, w => w, h => h) port map ( min => min, msg => msgtemp );
	end generate;
	
	msg <= halfblk2wordmatrix( msgtemp );		
	
	toutxorhout <= tout xor hout;
	hin <= iv when sf = '1' else toutxorhout;														   
	h_gen : regn generic map ( N => h, init => hzeros) port map (clk => clk, rst => '0', en => eh, input => hin, output => hout );	 
	chain <= halfblk2wordmatrix( hin );
	
	---//////////////---
	-- Concatination	
	concat256 : if ( h = 256 ) generate
		concat_out <= msg(0) & msg(1) & chain(0) & chain(1) & chain(2) & chain(3) & msg(2) & msg(3) & msg(4) & msg(5) & chain(4) & chain(5) & chain(6) & chain(7) & msg(6) & msg(7) ;
	end generate;
	concat512 : if ( h = 512 ) generate
		concat_out <= msg(0) & msg(1) & chain(0) & chain(1) & msg( 2) & msg( 3) & chain( 2) & chain( 3) & chain( 4) & chain( 5) & msg( 4) & msg( 5) & chain( 6) & chain( 7) & msg( 6) & msg( 7) & 
					  msg(8) & msg(9) & chain(8) & chain(9) & msg(10) & msg(11) & chain(10) & chain(11) & chain(12) & chain(13) & msg(12) & msg(13) & chain(14) & chain(15) & msg(14) & msg(15);
	end generate;
	
	concat_out_matrix <= blk2wordmatrix( concat_out );
	pin <= concat_out_matrix when sr_init = '1' else lout;
		
	abc : process ( clk )
	begin
		if rising_edge( clk ) then
			if er = '1' then
				pout <= pin;
			end if;
		end if;
	end process;

	
	
	alpha_gen : for i in 0 to bseg-1 generate
		alpha(i) <= alpha_cons(0, i);
		alphaf(i) <= alpha_cons(1, i);
	end generate;
	alpha_in <= alphaf when sfinal = '1' else alpha;
		
	-- round counter 	 
	rc <=  extendzero_cons & roundc;
	
	---////////////////////////////---
	-- BEGIN : The Non-linear Permutation P

		---//////////////---
		-- Addition of Constants and Counter	
		acc(0) <= pout(0) xor alpha_in(0);
		acc(1) <= pout(1) xor alpha_in(1) xor rc; 		
		acc_gen : for i in 2 to bseg-1 generate
			acc(i) <= pout(i) xor alpha_in(i);			
		end generate;
		
		---//////////////---
		-- Substitution Layer		   
		-- convert to block
		sbox_in <= wordmatrix2blk( acc );
		sbox_gen_outer: for i in b/4 - 1 downto 0 generate		 
			--group into 4 bits
			sbox_boxin(i) 			<= sbox_in(i) & sbox_in(i+b/4) & sbox_in(i+b/2) & sbox_in(i+3*b/4);
			--apply sbox
			sbox_boxout(i) <= sbox_rom(conv_integer(sbox_boxin(i)));
			--ungroup and insert back to the same location
			sbox_out_slv(i) 		<= sbox_boxout(i)(3);
			sbox_out_slv(i+b/4) 	<= sbox_boxout(i)(2);
			sbox_out_slv(i+b/2) 	<= sbox_boxout(i)(1);
			sbox_out_slv(i+3*b/4) 	<= sbox_boxout(i)(0);
		end generate sbox_gen_outer ;					  
		--revert to matrix
		sbox_out <= blk2wordmatrix( sbox_out_slv );
		---//////////////---
		-- Diffusion Layer (Linear Transformation 'L')		
		
		ltrans_small_gen : if ( h = 256 or h = 224 ) generate
			l1 : entity work.hamsi_diffusion(struct) port map (	ai => sbox_out(0),  bi => sbox_out(5),  ci => sbox_out(10),  di => sbox_out(15), 
															ao => lout(0), bo => lout(5), co => lout(10), do => lout(15) );
			l2 : entity work.hamsi_diffusion(struct) port map (	ai => sbox_out(1),  bi => sbox_out(6),  ci => sbox_out(11),  di => sbox_out(12), 
															ao => lout(1), bo => lout(6), co => lout(11), do => lout(12) );
			l3 : entity work.hamsi_diffusion(struct) port map (	ai => sbox_out(2),  bi => sbox_out(7),  ci => sbox_out(8),   di => sbox_out(13), 
															ao => lout(2), bo => lout(7), co => lout(8),  do => lout(13) );
			l4 : entity work.hamsi_diffusion(struct) port map (	ai => sbox_out(3),  bi => sbox_out(4),  ci => sbox_out(9),   di => sbox_out(14), 
															ao => lout(3), bo => lout(4), co => lout(9),  do => lout(14) );
		end generate;										 
		ltrans_large_gen : if ( h = 512 ) generate
			l1 : entity work.hamsi_diffusion(struct) port map (	ai => sbox_out(0),  bi => sbox_out(9),  ci => sbox_out(18), di => sbox_out(27), 
																ao => lout_temp(0), 		bo => lout_temp(9), 		co => lout_temp(18), 	do => lout_temp(27) );
			l2 : entity work.hamsi_diffusion(struct) port map (	ai => sbox_out(1),  bi => sbox_out(10), ci => sbox_out(19), di => sbox_out(28), 
																ao => lout_temp(1), 		bo => lout_temp(10), 	co => lout_temp(19), 	do => lout_temp(28) );
			l3 : entity work.hamsi_diffusion(struct) port map (	ai => sbox_out(2),  bi => sbox_out(11), ci => sbox_out(20), di => sbox_out(29), 
																ao => lout_temp(2), 		bo => lout_temp(11), 	co => lout_temp(20), 	do => lout_temp(29) );
			l4 : entity work.hamsi_diffusion(struct) port map (	ai => sbox_out(3),  bi => sbox_out(12), ci => sbox_out(21), di => sbox_out(30), 
																ao => lout_temp(3), 		bo => lout_temp(12), 	co => lout_temp(21), 	do => lout_temp(30) );
			l5 : entity work.hamsi_diffusion(struct) port map (	ai => sbox_out(4),  bi => sbox_out(13), ci => sbox_out(22), di => sbox_out(31), 
																ao => lout_temp(4), 		bo => lout_temp(13), 	co => lout_temp(22), 	do => lout_temp(31) );
			l6 : entity work.hamsi_diffusion(struct) port map (	ai => sbox_out(5),  bi => sbox_out(14), ci => sbox_out(23), di => sbox_out(24), 
																ao => lout_temp(5), 		bo => lout_temp(14), 	co => lout_temp(23), 	do => lout_temp(24) );			
			l7 : entity work.hamsi_diffusion(struct) port map (	ai => sbox_out(6),  bi => sbox_out(15), ci => sbox_out(16), di => sbox_out(25), 
																ao => lout_temp(6), 		bo => lout_temp(15), 	co => lout_temp(16), 	do => lout_temp(25) );
			l8 : entity work.hamsi_diffusion(struct) port map (	ai => sbox_out(7),  bi => sbox_out(8), ci => sbox_out(17), di => sbox_out(26), 
																ao => lout_temp(7), 		bo => lout_temp(8), 	co => lout_temp(17), 	do => lout_temp(26) );
																
			lout(1) <= lout_temp(1);		lout(3) <= lout_temp(3);		lout(4) <= lout_temp(4);		lout(6) <= lout_temp(6);
			lout(8) <= lout_temp(8);		lout(10) <= lout_temp(10);		lout(13) <= lout_temp(13);		lout(15) <= lout_temp(15);		
			lout(17) <= lout_temp(17);		lout(18) <= lout_temp(18);		lout(20) <= lout_temp(20);		lout(23) <= lout_temp(23);		
			lout(24) <= lout_temp(24);		lout(27) <= lout_temp(27);		lout(29) <= lout_temp(29);		lout(30) <= lout_temp(30);		
			l9 : entity work.hamsi_diffusion(struct) port map (	ai => lout_temp(0),  bi => lout_temp(2),  ci => lout_temp(5),  di => lout_temp(7), 
																ao => lout(0), 		bo => lout(2), 		co => lout(5), 		do => lout(7) );
			l10: entity work.hamsi_diffusion(struct) port map (	ai => lout_temp(16), bi => lout_temp(19), ci => lout_temp(21), di => lout_temp(22), 
																ao => lout(16),		bo => lout(19), 	co => lout(21), 	do => lout(22) );
			l11: entity work.hamsi_diffusion(struct) port map (	ai => lout_temp(9),  bi => lout_temp(11), ci => lout_temp(12), di => lout_temp(14), 
																ao => lout(9), 		bo => lout(11), 	co => lout(12), 	do => lout(14) );
			l12: entity work.hamsi_diffusion(struct) port map (	ai => lout_temp(25), bi => lout_temp(26), ci => lout_temp(28), di => lout_temp(31), 
																ao => lout(25), 	bo => lout(26), 	co => lout(28), 	do => lout(31) );				
		end generate;	
	-- END : The Non-linear Permutation P
	---////////////////////////////---
	
	---//////////////---
	--Truncation	
	truncate_small_gen : if h = 256 or h = 224 generate
		tout <= lout(0) & lout(1) & lout(2) & lout(3) & lout(8) & lout(9) & lout(10) & lout(11);
	end generate;
		
	truncate_big_gen : if h = 512 or h = 384 generate
		tout <= lout(0) & lout(1) & lout(2) & lout(3) & lout(4) & lout(5) & lout(6) & lout(7) &
				lout(16) & lout(17) & lout(18) & lout(19) & lout(20) & lout(21) & lout(22) & lout(23); 
	end generate;	 

	---//////////////---
	--output			
	
	shfout_gen : piso generic map ( N => h, M => w ) port map (clk => clk, sel => lo, en => eout, input => toutxorhout,  output => dout );		
end struct;