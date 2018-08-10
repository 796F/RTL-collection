-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_arith.all;
use work.sha3_pkg.all;
use work.sha3_jh_package.all;

entity jh_rd is
	generic ( bw : integer := 1024;							-- input size
			  cw : integer := 256);						-- constant size		
	port (
		input	: in std_logic_vector(bw-1 downto 0);		--input
		cr		: in std_logic_vector(cw-1 downto 0);		--key	
		output 	: out std_logic_vector(bw-1 downto 0);			 
		output_last	: out std_logic_vector(bw-1 downto 0)
	);
end jh_rd;

architecture struct of jh_rd is
	type array_type is array (0 to cw-1) of std_logic_vector(3 downto 0);
	signal aa, vv, ww : array_type;		   
	signal vv_blk : std_logic_vector(bw-1 downto 0);
	
	signal pi, pp, phi : array_type;
	signal phi_blk : std_logic_vector(bw-1 downto 0);
--	--debug		
--	signal input_m, vv_blk_m, ww_blk_m : std_logic_matrix;
begin
	
	-- separate inputs into array of 4 bits word for easy processing
	array4_gen : for i in bw/4-1 downto 0 generate
		aa(bw/4-1 - i) <= input(i*4+3 downto i*4);  	
		phi_blk(i*4+3 downto i*4) <= phi(bw/4-1 - i);
	end generate;
	
	-- apply sbox
	sbox_gen : for i in 0 to cw-1 generate
		vv(i) <= sbox_rom(conv_integer(cr(cw-1-i)),conv_integer(unsigned(aa(i))));
	end generate;
	
	-- apply linear transformation
	lt_gen : for i in 0 to cw/2-1 generate
		lt_box : entity work.jh_lt(struct) port map ( a => vv(2*i), b => vv(2*i+1), c => ww(2*i), d => ww(2*i+1) );
	end generate;	

	-- apply permutation
		pi_gen : for  i in cw/4-1 downto 0 generate
			pi(i*4 + 0) <= ww(i*4 + 0);
			pi(i*4 + 1) <= ww(i*4 + 1);
			pi(i*4 + 2) <= ww(i*4 + 3);
			pi(i*4 + 3) <= ww(i*4 + 2);
		end generate;
		
		--pp
		pp_gen : for i in cw/2-1 downto 0 generate
			pp(i)  			<= pi(i*2);
			pp(i + cw/2)	<= pi(i*2 + 1);
		end generate;
		
		-- phi	
		phi_gen1 : for i in cw/2-1 downto 0 generate
			phi(i) <= pp(i);
		end generate;
		phi_gen : for i in cw/4-1 downto 0 generate
			phi(i*2 + cw/2)  	<= pp(i*2 + 1 + cw/2);
			phi(i*2 + 1 + cw/2) <= pp(i*2 + cw/2);	
		end generate;
	
	
		array4_gen2 : for i in bw/4-1 downto 0 generate			
			vv_blk(i*4+3 downto i*4) <= vv(bw/4-1 - i);
		end generate;
		output <= phi_blk;
		output_last <= vv_blk;					   

--	Debug (Unsynthesizable)
--	input_m <= blk2wordmatrix_inv( input );
--	vv_blk_m <= blk2wordmatrix_inv( vv_blk );
--	ww_blk_m <= blk2wordmatrix_inv( ww_blk );
end struct;											   


