-- =====================================================================
-- Copyright © 2010 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.sha3_luffa_package.all;

entity luffa_mi is	 
	generic ( array_size : integer := 3 );
	port (	mi : in vector_array (0 to array_size - 1);
			msg : in std_logic_vector (255 downto 0);	
			yp : out std_logic_vector(255 downto 0);
			mo : out vector_array (0 to array_size - 1));
end luffa_mi;

architecture struct of luffa_mi is
	signal xor1_out_pre : vector_array (0 to array_size - 1);
	signal xor1_out : std_logic_vector (255 downto 0);
	signal mult21_out : std_logic_vector (255 downto 0);
	signal mult22_out : vector_array (0 to array_size - 1);
	signal mult23_out : vector_array (0 to array_size - 1);
	signal msg_in : vector_array (0 to array_size - 1);
	signal xor2_out : vector_array (0 to array_size - 1);
	signal xor3_out : vector_array (0 to array_size - 1);
	signal xor4_out : vector_array (0 to array_size - 1);
	
begin		
	yp <= xor1_out;
	-- first xor
	xor1_out_pre(0) <= mi(0);
	mi_xor1: for i in 1 to array_size - 1 generate
		xor1_out_pre(i) <= xor1_out_pre(i-1) xor mi(i);
	end generate mi_xor1;
	xor1_out <= xor1_out_pre(array_size - 1);
	
	-- first multiplication by 0x02	
	mult1_gen : entity work.luffa_mult2 port map (input => xor1_out, output => mult21_out);
		
	-- process input message
	msg_in(0) <= msg;
	msg_proc: for h in 1 to array_size - 1 generate
		mult2_gen : entity work.luffa_mult2 port map (input => msg_in(h-1), output => msg_in(h));
	end generate msg_proc;
	
	
	
	--/////////////////////////////////////////////////////////////
	-- message injection 256 bits hash
	mi_hash_256: if (array_size = 3) generate
		--/////////////////////////////////////////////////////////////
		mi_function: for i in 0 to array_size - 1 generate						
			-- generating message injection output
			mo(i) <= msg_in(i) xor mi(i) xor mult21_out;	
		end generate mi_function;
	end generate mi_hash_256;
	
	
	
	
	--/////////////////////////////////////////////////////////////
	-- message injection 384 bits hash
	mi_hash_384: if (array_size = 4) generate
		--/////////////////////////////////////////////////////////////
		mi_function: for i in 0 to array_size - 1 generate
			-- second xor output
			xor2_out(i) <= mi(i) xor mult21_out;
			
			-- second multiplication by 0x02  
			mult22_gen : entity work.luffa_mult2 port map (input => xor2_out(i), output => mult22_out(i));
			
			-- third xor output
			xor3_out(i) <= xor2_out((i-1) mod 4) xor mult22_out(i);
			
			-- fourth xor output
			mo(i) <= xor3_out(i) xor msg_in(i);
			
		end generate mi_function;
	end generate mi_hash_384;
	
	

	--/////////////////////////////////////////////////////////////
	-- message injection 512 bits hash
	mi_hash_512: if (array_size = 5) generate
		--/////////////////////////////////////////////////////////////
		mi_function: for i in 0 to array_size - 1 generate
			-- second xor output
			xor2_out(i) <= mi(i) xor mult21_out;
			
			-- second multiplication by 0x02   
			mult22_gen : entity work.luffa_mult2 port map (input => xor2_out(i), output => mult22_out(i));
			
			-- third xor output
			xor3_out(i) <= xor2_out((i+1) mod 5) xor mult22_out(i);
			
			-- third multiplication by 0x02															 
			mult23_gen : entity work.luffa_mult2 port map (input => xor3_out(i), output => mult23_out(i));
			
			-- fourth xor output
			xor4_out(i) <= xor3_out((i-1) mod 5) xor mult23_out(i);
			
			-- fifth xor output
			mo(i) <= xor4_out(i) xor msg_in(i);
			
		end generate mi_function;
	end generate mi_hash_512;
		
end struct;

