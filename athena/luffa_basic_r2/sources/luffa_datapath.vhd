-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sha3_luffa_package.ALL;
use work.sha3_pkg.all;

entity luffa_datapath is	
	generic ( h : integer := 256;
			  w : integer := 64;		   
			  round_length : integer := 3);
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
		sstep_init : in std_logic;
		round : in std_logic_vector(round_length-1 downto 0);
		
		--fsm 3
		eout : in std_logic
	);				  
end luffa_datapath;

architecture struct of luffa_datapath is 			   
	constant wzeros : std_logic_vector(w-1 downto 0) := ( others => '0' );
	constant array_size : integer := get_arraysize ( h );	
	
	signal min, msg : std_logic_vector(b-1 downto 0);	
	signal mi_in, mi_out : vector_array(0 to array_size - 1);					   
	signal c : std_logic_vector( 55 downto 0);		  		
	signal yp : std_logic_vector(255 downto 0);
	signal shf : std_logic_vector(w-1 downto 0); 		 		 
	
	-- P
	signal pi, tweak_out : vector_array (0 to array_size - 1);
	signal regin : vector_array (0 to array_size - 1);	
	signal step_in : vector_array (0 to array_size - 1);
	signal step_out : vector_array (0 to array_size - 1);

	signal c0, c4 : vector_constant_array( 0 to array_size - 1 );
	
begin														
	final_segment <= din(0);

	zc0 <= '1' when c = 0 else '0';
	
	-- block decounter										
	decounter_gen : decountern generic map ( N => 56, sub => 1 ) port map ( clk => clk, rst => '0', load => lc, en => ec, input => din(w-1 downto 8), output => c );

	-- input											
	shfin_gen : sipo generic map ( N => mw,M => w) port map (clk => clk, en => ein, input => din, output => min );
	
	miin_gen : for i in 0 to array_size-1 generate
		mi_in(i) <= IV(i) when sf = '1' else step_in(i);	
	end generate;
	
	msg <= bzeros when sfinal = '1' else min;
	--/////////////////////////////////////////////////////////////
	--Luffa round (MI and P)		 
		-- MI
		mi_gen : entity work.luffa_mi(struct) generic map ( array_size => array_size ) port map ( mi => mi_in , mo => mi_out, msg => msg, yp => yp ); 
		
		--/////////////////////////////////////////////////////////////	  
		-- P
		pi <= mi_out;
		p_in_gen: for j in 0 to array_size - 1 generate
			--/////////////////////////////////////////////////////////////
			-- tweak function		
			tweak_out(j)(b-1 downto b/2) <= pi(j)(b-1 downto b/2);		 
	
			skip_first : if j = 0 generate
				tweak_out(j) <= pi(j);
			end generate;
			tweak_gen : if j /= 0 generate
				tweak_gen : for i in 3 downto 0 generate
					tweak_out(j)(32*(i+1) - 1 downto 32*i) <= pi(j)(32*(i+1) - j - 1 downto 32*i) & pi(j)(32*(i+1) - 1 downto 32*(i+1) - j) ;
				end generate;
			end generate;
			
			-- register
			reg_gen : regn generic map ( N => b, init => bzeros ) port map (clk => clk, rst => '0', en => er, input => regin(j), output => step_in(j) );
		end generate p_in_gen;
		
		unrolled_gen : for i in 0 to array_size - 1 generate
			c0(i) <= c0_constants(i,conv_integer(round));
			c4(i) <= c4_constants(i,conv_integer(round));
		end generate;		
		
		step_gen : entity work.luffa_step(struct) generic map ( array_size => array_size ) port map ( input => step_in, c0 => c0, c4 => c4, output => step_out );
		
		regin <= tweak_out when sstep_init = '1' else step_out;
	
	--/////////////////////////////////////////////////////////////

	shfout_gen : piso generic map ( N => 256, M => w ) port map (clk => clk, sel => lo, en => eout, input => yp,  output => shf );		
	dout <= shf;
end struct;