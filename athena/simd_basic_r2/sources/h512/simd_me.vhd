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
use work.sha3_simd_package.all;

entity simd_me is	 
	generic ( 	b : integer := 512; h : integer := 256;
				feistels : integer := 4);
    port (  clk : in std_logic;
			rst : in std_logic;
			ctrl_ntt : in std_logic_vector(6 downto 0);
			ctrl_cp : in std_logic_vector(2 downto 0);	
			msg : in  std_logic_vector(b-1 downto 0);	
            ww : out array_w(0 to 3,0 to feistels-1));
end simd_me;

architecture struct of simd_me is	  
	constant pts : integer := get_pts( h );
	signal ntt_in : ntt_in_type(0 to pts-1);
	signal ntt_out : ntt_out_type(0 to pts-1);
	
begin				 

	ntt_gen : entity work.ntt_engine(struct) generic map ( h => h, pts => pts ) port map ( clk => clk, rst => rst, ctrl => ctrl_ntt, x => ntt_in, y => ntt_out );
	cp_gen : entity work.concat_permute(type5)  generic map ( h => h, pts => pts, feistels => feistels ) port map ( clk => clk, ctrl => ctrl_cp, ii => ntt_out, ww => ww );
		
	ntt_in_gen_1 : for i in 0 to pts/2 - 1 generate
		ntt_in(i) <= msg(b - i*8 - 1 downto b-i*8-8);
	end generate;
	ntt_in_gen_2 : for i in pts/2 to pts-1 generate
		ntt_in(i) <= x"00";
	end generate;		   

end struct;