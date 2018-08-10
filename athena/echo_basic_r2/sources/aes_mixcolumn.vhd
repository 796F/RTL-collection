-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;   
use ieee.numeric_std.all;
use work.sha3_pkg.all;

-- Streightforward implementation of AES MixColumn operation

entity aes_mixcolumn is
port( 
	input 		: in std_logic_vector(AES_WORD_SIZE-1 downto 0);
    output 		: out std_logic_vector(AES_WORD_SIZE-1 downto 0));
end aes_mixcolumn;
  
architecture aes_mixcolumn of aes_mixcolumn is
signal mulx2	:std_logic_vector(AES_WORD_SIZE-1 downto 0);
signal mulx3	:std_logic_vector(AES_WORD_SIZE-1 downto 0);

begin

m2_gen : for i in 0 to AES_WORD_SIZE/AES_SBOX_SIZE -1 generate 
m2	:entity work.aes_mul(aes_mulx02)   
		 port map (input=>input((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)), 
			  output=>mulx2((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)));
end generate;

m3_gen : for i in 0 to AES_WORD_SIZE/AES_SBOX_SIZE -1 generate 
m3	:entity work.aes_mul(aes_mulx03) 
   		 port map (input=>input((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)), 
			  output=>mulx3((i+1)*AES_SBOX_SIZE-1 downto (i*AES_SBOX_SIZE)));
end generate;


output(31 downto 24) 	<= mulx2(31 downto 24) 	xor mulx3(23 downto 16) xor input(15 downto 8) xor input(7 downto 0);
output(23 downto 16) 	<= mulx2(23 downto 16) xor mulx3(15 downto 8) xor input(7 downto 0) xor input(31 downto 24);
output(15 downto 8) 	<= mulx2(15 downto 8) xor mulx3(7 downto 0) xor input(31 downto 24) xor input(23 downto 16);
output(7 downto 0) 	<= mulx2(7 downto 0) xor mulx3(31 downto 24) xor input(23 downto 16) xor input(15 downto 8);


end aes_mixcolumn; 
