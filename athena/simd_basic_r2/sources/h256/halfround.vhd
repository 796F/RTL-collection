-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;  
use ieee.std_logic_unsigned.all;
use work.twiddle_factor_pkg.all;
use work.sha3_pkg.all;
use work.sha3_simd_package.all;

entity halfround is	   
	generic ( b : integer := 512; feistels : integer := 4 );
	port ( 	ii 				: in  	std_logic_vector(b-1 downto 0);
			ww	 			: in 	array_w(0 to 3,0 to feistels-1);
			sphi, slr 		: in 	std_logic;
			sa				: in 	std_logic_vector(log2(feistels)-1 downto 0);
			spi 			: in 	std_logic_vector(1 downto 0);
			oo				: out 	std_logic_vector(b-1 downto 0) );	
end halfround;	   

architecture struct of halfround is						  
	type halfround_base is array(0 to feistels-1) of array_4x32;
	type halfround_type is array(0 to 4) of halfround_base;
	signal step : halfround_type;	
	signal amux : array_w(0 to 3, 0 to feistels-1);	
	signal r, s, pi : array_4x5;		  
	
	signal sel_pi : std_logic_vector(1 downto 0 );
begin							 
	gen_lvl1 : for i in 0 to 3 generate
		gen_lvl2 : for j in 0 to feistels-1 generate
			-- input
			step(0)(j)(i) <= ii(b-1-j*32-i*(feistels*32) downto b-32-j*32-i*(feistels*32));
			
			-- select which a to go into babystep 
			mux_feistels4 : if ( feistels = 4 ) generate
				with sa(1 downto 0) select
				amux(i,j) <= 	step(i+1)(step_permute256(i mod 3,j))(1) 		when "00",
								step(i+1)(step_permute256((i+1) mod 3,j))(1) 	when "01",
								step(i+1)(step_permute256((i+2) mod 3,j))(1) 	when "10",
								iwzeros 										when others;			
			end generate;
			mux_feistels8 : if ( feistels = 8 ) generate
				with sa(2 downto 0) select
				amux(i,j) <= 	step(i+1)(step_permute512(i mod 7,j))(1) 		when "000",
								step(i+1)(step_permute512((i+4) mod 7,j))(1) 	when "001",
								step(i+1)(step_permute512((i+1) mod 7,j))(1) 	when "010",
								step(i+1)(step_permute512((i+5) mod 7,j))(1) 	when "011",
								step(i+1)(step_permute512((i+2) mod 7,j))(1) 	when "100",
								step(i+1)(step_permute512((i+6) mod 7,j))(1) 	when "101",
								step(i+1)(step_permute512((i+3) mod 7,j))(1) 	when "110",
								step(i+1)(step_permute512(i mod 7,j))(1)		when others;			
			end generate;																		
							
			 babystep_gen : 	entity work.babystep(struct) 
								 generic map ( row => i )
								 port map ( 	ii => step(i)(j), spi => sel_pi, win => ww(i,j),  
								 ain => amux(i,j), sphi => sphi, oo => step(i+1)(j) );	
							
			oo(b-1-j*32-i*(feistels*32) downto b-32-j*32-i*(feistels*32)) <= step(4)(j)(i);
		end generate;
	end generate;		  									
	
	sel_pi <= "11" when slr = '1' else spi;
end struct;