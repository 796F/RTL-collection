-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sha3_skein_package.ALL;
use work.sha3_pkg.all;

entity skein_datapath is
	generic ( 	adder_type : integer := SCCA_BASED;
				w : integer := 64;
				h : integer := HASH_SIZE_256;				
				round_unrolled : integer := 4 );
	port (
		-- external
		clk : in std_logic;
		
		din  : in std_logic_vector(w-1 downto 0);	
		dout : out std_logic_vector(w-1 downto 0);	
		--fsm 1		
		ein : in std_logic;
		ec, lc : in std_logic;	 
		final_segment, zclblock : out std_logic;
		dth, eth : in std_logic;		
		--fsm 2			  		
		er, etweak : in std_logic;
		sf : in std_logic;		-- 1 for first block of a message
		lo : in std_logic;
		
		sfinal : in std_logic; 	 -- 0 for msg, 1 for output
		slast 	: in std_logic;  -- 1 for last block and output , 0 else
		snb		: in std_logic;
		
		--fsm 3
		eout : in std_logic		
	);				  
end skein_datapath;

architecture struct of skein_datapath is   

	function get_key_size (ux : integer ) return integer is
	begin
		if ( ux = 8 ) then
			return ( 2 );
		else
			return ( 1 ) ;
		end if;
	end get_key_size;
	
	------ Constants	
	constant nw : integer := 8; -- fixed
	constant b : integer := 512; -- fixed	   
	constant bzeros 	: std_logic_vector(b-1 downto 0) := (others => '0');
	constant mw			: integer := b;		-- message width	
	constant mwzeros	: std_logic_vector(mw-1 downto 0) := (others => '0');  
	constant key_size	: integer := get_key_size(round_unrolled);
	constant perm : permute_type (0 to nw-1) := get_perm( b );
	constant rot : rot_type (0 to nw/2-1,0 to 7) := get_rot( b );  
	constant iv : std_logic_vector(b-1 downto 0) := get_iv( h );																			  
	constant tzeros : std_logic_vector(95 downto 0) := (others => '0');
	----------	
	
	signal min,min_endian1,min_endian2, msg : std_logic_vector(mw-1 downto 0);
	signal r, rmux, rp : std_logic_vector(b-1 downto 0);
	
	signal tweak : std_logic_vector(127 downto 0);				  
	signal tw_type : std_logic_vector(5 downto 0);
	signal tw_bit_pad : std_logic;	 
	constant tw_tree_level : std_logic_vector(6 downto 0) := (others =>'0');
	constant tw_reserved : std_logic_vector(15 downto 0) := (others =>'0');	
	signal tw_position : std_logic_vector(95 downto 0);	   
	
	-- T CALC
	signal t_in, t_out : std_logic_vector(95 downto 0);
	signal cadd : std_logic_vector(w-4 downto 0); 
	signal cpad : std_logic;
	signal zclblock_s : std_logic;
	signal c : std_logic_vector(w-1 downto 0);

	signal keyout  : key_array(nw-1 downto 0);
	
	signal threefish, cv,  keyin : std_logic_vector(b-1 downto 0);	  
	signal switch_out, switch1, switch2 : std_logic_vector(h-1 downto 0);
	
	-- ROUND SIGNALS
	signal keyinj : key_array(nw-1 downto 0);	
	signal round : round_array(0 to round_unrolled, nw-1 downto 0);	
	signal roundout : round_array(0 to round_unrolled-1, nw-1 downto 0);	  
	
	-- 4x
	signal sshalf : std_logic;
	
	
	constant log2mw : integer := log2(mw);						
	constant log2mwzeros : std_logic_vector(log2mw-1 downto 0) := (others => '0');
begin														
	-- block decounter																									   	
	decounter_gen : decountern generic map ( N => w-log2mw, sub => 1 ) port map ( clk => clk, rst => '0', load => lc, en => ec, input => din(w-1 downto log2mw), output => c(w-1 downto log2mw) );	
	counter_bot_gen : regn generic map ( N => log2mw, init => log2mwzeros ) port map ( clk => clk, rst => '0', en => lc, input => din(log2mw-1 downto 0), output => c(log2mw-1 downto 0));			
	
	zclblock_s <= '1' when c <= b else '0';
	zclblock <= zclblock_s;
	final_segment <= din(0);
	-- t gens																			  
		t_reg : regn generic map ( N => 96, init => tzeros ) port map ( clk => clk, rst => dth, en => eth, input => t_in, output => t_out );		
		cadd <= c(w-1 downto 3);
		cpad <= (c(0) or c(1) or c(2));		
		t_in <= (t_out + cadd + cpad) when zclblock_s = '1' else (t_out + b/8 );
		tw_position <= conv_std_logic_vector(8,96) when sfinal = '1' else t_out;
		
	
	-- tweak				
	tw_type <= TW_OUT_CONS when sfinal = '1' else TW_MSG_CONS;
	tw_bit_pad <= cpad and slast and not sfinal;
	tweak <= (slast or sfinal) & (sf or sfinal )  & tw_type & tw_bit_pad & tw_tree_level & tw_reserved & tw_position;
	
	-- input																										 
	min_endian1 <= switch_endian_byte(min,b,64);
	min_endian2 <= switch_endian_word(min_endian1,b,64);
	shfin_gen : sipo generic map ( N => mw,M => w) port map (clk => clk, en => ein, input => din, output => min );
	msg_reg : regn generic map ( N => mw, init => mwzeros ) port map ( clk => clk, rst => sfinal, en => snb, input => min_endian2, output => msg );
	
	rmux <= min_endian2 when snb = '1' else rp;
	r_reg : regn generic map ( N => b, init => bzeros ) port map ( clk => clk, rst => sfinal, en => er, input => rmux, output => r );
	
	-----------------------
	--------- ROUND -------
	inout_gen : for i in nw-1 downto 0 generate
		round(0,i) <= r(iw*(i+1)-1 downto iw*i);
		rp(iw*(i+1)-1 downto iw*i) <= round(round_unrolled,i);
	end generate;		
		
	--------------------
	--------- 4x -------			
	-- cntrl signal	
	process ( clk )	   
	begin
		if rising_edge( clk ) then
			if ( snb = '1' ) then
				sshalf <= '0';
			elsif ( er = '1' ) then
				sshalf <= not sshalf;
			end if;
		end if;
	end process;	
	-- core
	row_gen : for i in 0 to round_unrolled-1 generate
		key_inj : if ( i mod 4 = 0 ) generate																								
			keyinj_gen : for j in nw-1 downto 0 generate 
				add_call : adder generic map ( adder_type => adder_type, n => 64 ) port map ( a => keyout(j), b => round(i,j) , s => keyinj(j));
			end generate;			
			mix_gen_gen : for j in 0 to nw/2-1 generate
				mix_gen : entity work.skein_mix_4r(struct) generic map ( adder_type => adder_type, rotate_0 => rot(j,i), rotate_1 => rot(j,i+4) ) port map ( sel => sshalf, a => keyinj(2*j), b => keyinj(2*j+1), c => roundout(i,2*j), d => roundout(i,2*j+1) );
			end generate;
		end generate;
		nokey_inj : if (i mod 4 /= 0 ) generate	
			mix_gen_gen : for j in 0 to nw/2-1 generate
				mix_gen_r : entity work.skein_mix_4r(struct) generic map (adder_type => adder_type,  rotate_0 => rot(j,i), rotate_1 => rot(j,i+4) ) port map ( sel => sshalf, a => round(i,2*j), b => round(i,2*j+1), c => roundout(i,2*j), d => roundout(i,2*j+1) );
			end generate;
		end generate;
	end generate;	
 
	
	perm1: for i in 1 to round_unrolled generate 
		perm2 : for j in 0 to nw-1 generate
			round(i,j) <= roundout(i-1,perm(j));
		end generate;
	end generate;
	--------- ROUND -------
	-----------------------			   
	
	threefish_out_gen : for i in nw-1 downto 0 generate
		threefish(64*(i+1)-1 downto 64*i) <= keyinj(i);
	end generate;
	cv <= threefish xor msg;
	
	keyin <= iv when sf = '1' else cv;
	keygen_gen : entity work.skein_keygen(struct) generic map (adder_type => adder_type, b => b, nw => nw) port map ( clk => clk, load => snb, en => etweak, keyin => keyin, tweak => tweak, keyout => keyout );
	
	switch_out <= cv(h-1 downto 0);
	switch1 <= switch_endian_word(switch_out, h, iw); 
	switch2 <= switch_endian_byte(switch1,h,iw);
		
	--output	
	shfout_gen : piso generic map ( N => h, M => w ) port map (clk => clk, sel => lo, en => eout, input => switch2, output => dout );		
end struct;