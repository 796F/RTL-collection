 -- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;   
use ieee.numeric_std.all;
use work.sha3_pkg.all;	 
use work.groestl_pkg.all;	

-- Groestl MixBytes  implemented as combinational function
-- possible generics values: hs = {GROESTL_DATA_SIZE_SMALL, GROESTL_DATA_SIZE_BIG} 
-- they are corresponding to 256 and 512 versions respectively 

entity groestl_mixbytes is
generic (n	:integer := GROESTL_DATA_SIZE_SMALL);
port( 
	input 		: in std_logic_vector(n-1 downto 0);
    output 		: out std_logic_vector(n-1 downto 0));
end groestl_mixbytes;
  
architecture groestl_mixbytes of groestl_mixbytes is
signal mulx2	:std_logic_vector(n-1 downto 0);
signal mulx3	:std_logic_vector(n-1 downto 0);
signal mulx4	:std_logic_vector(n-1 downto 0);
signal mulx5	:std_logic_vector(n-1 downto 0);
signal mulx7	:std_logic_vector(n-1 downto 0);
	
begin

-- multiplication by x02 in GF(2^8)
m2a_gen : for i in 0 to n/AES_SBOX_SIZE -1 generate 
m2a	:entity work.aes_mul(aes_mulx02)   
		 port map (input=>input((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)), 
			  output=>mulx2((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)));
end generate;

-- multiplication by x03 in GF(2^8)
m3a_gen : for i in 0 to n/AES_SBOX_SIZE -1 generate 
m3a	:entity work.aes_mul(aes_mulx03) 
   		 port map (input=>input((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)), 
			  output=>mulx3((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)));
end generate;

-- multiplication by x04 in GF(2^8)
m4_gen : for i in 0 to n/AES_SBOX_SIZE -1 generate 
m4	:entity work.aes_mul(aes_mulx04) 
   		 port map (input=>input((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)), 
			  output=>mulx4((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)));
end generate;

-- multiplication by x05 in GF(2^8)
m5a_gen : for i in 0 to n/AES_SBOX_SIZE -1 generate 
m5a	:entity work.aes_mul(aes_mulx05) 
   		 port map (input=>input((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)), 
			  output=>mulx5((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)));
end generate;

-- multiplication by x07 in GF(2^8)
m7_gen : for i in 0 to n/AES_SBOX_SIZE -1 generate 
m7	:entity work.aes_mul(aes_mulx07) 
   		 port map (input=>input((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)), 
			  output=>mulx7((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)));
end generate;

-- network of xors 
out_ls_gen: for i in 0 to n/64-1 generate
	output(64*i+63 downto 64*i+56) 	<= mulx2(64*i+63 downto 64*i+56) xor mulx2(64*i+55 downto 64*i+48) xor mulx3(64*i+47 downto 64*i+40) xor mulx4(64*i+39 downto 64*i+32) xor mulx5(64*i+31 downto 64*i+24) xor mulx3(64*i+23 downto 64*i+16)  xor mulx5(64*i+15 downto 64*i+8)  xor mulx7(64*i+7 downto 64*i);
	output(64*i+55 downto 64*i+48) 	<= mulx7(64*i+63 downto 64*i+56)  xor mulx2(64*i+55 downto 64*i+48) xor mulx2(64*i+47 downto 64*i+40) xor mulx3(64*i+39 downto 64*i+32) xor mulx4(64*i+31 downto 64*i+24) xor mulx5(64*i+23 downto 64*i+16)  xor mulx3(64*i+15 downto 64*i+8)  xor mulx5(64*i+7 downto 64*i);
	output(64*i+47 downto 64*i+40) 	<= mulx5(64*i+63 downto 64*i+56)  xor mulx7(64*i+55 downto 64*i+48) xor mulx2(64*i+47 downto 64*i+40) xor mulx2(64*i+39 downto 64*i+32) xor mulx3(64*i+31 downto 64*i+24) xor mulx4(64*i+23 downto 64*i+16)  xor mulx5(64*i+15 downto 64*i+8)  xor mulx3(64*i+7 downto 64*i);
	output(64*i+39 downto 64*i+32) 	<= mulx3(64*i+63 downto 64*i+56)  xor mulx5(64*i+55 downto 64*i+48) xor mulx7(64*i+47 downto 64*i+40) xor mulx2(64*i+39 downto 64*i+32) xor mulx2(64*i+31 downto 64*i+24) xor mulx3(64*i+23 downto 64*i+16)  xor mulx4(64*i+15 downto 64*i+8)  xor mulx5(64*i+7 downto 64*i);
	output(64*i+31 downto 64*i+24) 	<= mulx5(64*i+63 downto 64*i+56)  xor mulx3(64*i+55 downto 64*i+48) xor mulx5(64*i+47 downto 64*i+40) xor mulx7(64*i+39 downto 64*i+32) xor mulx2(64*i+31 downto 64*i+24) xor mulx2(64*i+23 downto 64*i+16)  xor mulx3(64*i+15 downto 64*i+8)  xor mulx4(64*i+7 downto 64*i);
	output(64*i+23 downto 64*i+16) 	<= mulx4(64*i+63 downto 64*i+56)  xor mulx5(64*i+55 downto 64*i+48) xor mulx3(64*i+47 downto 64*i+40) xor mulx5(64*i+39 downto 64*i+32) xor mulx7(64*i+31 downto 64*i+24) xor mulx2(64*i+23 downto 64*i+16)  xor mulx2(64*i+15 downto 64*i+8)  xor mulx3(64*i+7 downto 64*i);
	output(64*i+15 downto 64*i+8) 	<= mulx3(64*i+63 downto 64*i+56)  xor mulx4(64*i+55 downto 64*i+48) xor mulx5(64*i+47 downto 64*i+40) xor mulx3(64*i+39 downto 64*i+32) xor mulx5(64*i+31 downto 64*i+24) xor mulx7(64*i+23 downto 64*i+16)  xor mulx2(64*i+15 downto 64*i+8)  xor mulx2(64*i+7 downto 64*i);
	output(64*i+7 downto 64*i+0) 	<= mulx2(64*i+63 downto 64*i+56)  xor mulx3(64*i+55 downto 64*i+48) xor mulx4(64*i+47 downto 64*i+40) xor mulx5(64*i+39 downto 64*i+32) xor mulx3(64*i+31 downto 64*i+24) xor mulx5(64*i+23 downto 64*i+16)  xor mulx7(64*i+15 downto 64*i+8)  xor mulx2(64*i+7 downto 64*i);

end generate;




end groestl_mixbytes; 
