-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sha3_luffa_package.all;

entity luffa_step is	 
	generic ( array_size : integer := 3 );
	port (	input : in vector_array (0 to array_size - 1);
			c0, c4 : in vector_constant_array(0 to array_size - 1);
			output : out vector_array (0 to array_size - 1));
end luffa_step;

architecture struct of luffa_step is

	signal subcrumb_pre_in, subcrumb_pre_out : vector_array( 0 to array_size - 1 );
	signal subcrumb_out : vector_array (0 to array_size - 1);	  
	
	type sbox_type is array (0 to array_size-1, 0 to 63) of std_logic_vector(3 downto 0);
	signal s_in, s_out : sbox_type;	  
	
	type mixword_array is array (0 to array_size-1) of std_logic_matrix;
	signal mix_in, mix_out : mixword_array; 
	signal addcons : mixword_array; 
	
	
begin

	permutation: for j in 0 to array_size - 1 generate	
		
		--/////////////////////////////////////////////////////////////		
		-- SubCrumb
		-- rearrange (0 1 2 3 4 5 6 7) to (0 1 2 3 5 6 7 4)
		subcrumb_pre_in(j) <= input(j)(wd*8-1 downto wd*4) & input(j)(wd*3-1 downto 0) & input(j)(wd*4-1 downto wd*3);
		subcrumb_l1 : for i in 0 to 31 generate
			subcrumb_l2_left : for k in 0 to 3 generate
				s_in(j,i)(k) <= subcrumb_pre_in(j)(255-k*wd-i);
				s_in(j,i+32)(k) <= subcrumb_pre_in(j)(127-k*wd-i);   	
				
				subcrumb_pre_out(j)(255-k*wd-i) <= s_out(j,i)(k);				
				subcrumb_pre_out(j)(127-k*wd-i) <= s_out(j,i+32)(k);  
			end generate;	  
			s_out(j,i) <= sbox_rom(to_integer(unsigned(s_in(j,i))));
			s_out(j,i+32) <= sbox_rom(to_integer(unsigned(s_in(j,i+32))));
		end generate;												 
		-- rearrange the order back
		subcrumb_out(j) <= subcrumb_pre_out(j)(wd*8-1 downto wd*4) & subcrumb_pre_out(j)(wd-1 downto 0) & subcrumb_pre_out(j)(wd*4-1 downto wd);

		--/////////////////////////////////////////////////////////////
		-- mixword function			  
		mix_in(j) <= blk2wordmatrix_inv( subcrumb_out(j) );																						  
		mix_gen : for i in 0 to 3 generate
			mix_call : entity work.luffa_mixword( struct ) port map ( xk => mix_in(j)(i), xk4 => mix_in(j)(i+4), yk => mix_out(j)(i), yk4 => mix_out(j)(i+4) );
		end generate;
		
		addcons_gen : for i in 0 to 7 generate
			c0_gen : if ( i = 0 ) generate 
				addcons(j)(i) <= mix_out(j)(i) xor c0(j);
			end generate;
			c4_gen : if ( i = 4 ) generate 
				addcons(j)(i) <= mix_out(j)(i) xor c4(j);
			end generate;
			cX_gen : if ( i /= 0 and i /= 4 ) generate 
				addcons(j)(i) <= mix_out(j)(i);
			end generate;
		end generate;
		--/////////////////////////////////////////////////////////////
		-- addconstant function
		output(j) <= wordmatrix2blk_inv( addcons(j) );		
		
	end generate permutation;
	
end struct;