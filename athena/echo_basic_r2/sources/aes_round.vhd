-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;   
use ieee.numeric_std.all;
use work.sha3_pkg.all;

-- possible generics rom_style = {DISTRIBUTED, COMBINATIONAL}

entity aes_round is
generic (rom_style : integer := DISTRIBUTED);
port( 
	input 		: in std_logic_vector(AES_BLOCK_SIZE-1 downto 0);
	key			: in std_logic_vector(AES_BLOCK_SIZE-1 downto 0);
    output 		: out std_logic_vector(AES_BLOCK_SIZE-1 downto 0));
end aes_round;

-- TBOX implementation of AES round 

architecture tbox of aes_round is
type bytes is array (0 to 15) of std_logic_vector(7 downto 0); 
type words is array (0 to 15) of std_logic_vector(31 downto 0); 
signal to_tbox : bytes;
signal after_tbox : words;	 
signal to_xor : std_logic_vector(127 downto 0);

begin

	-- ShiftRow operation is performed as first layer	
	
	to_tbox(0) <= input(127 downto 120);
	to_tbox(1) <= input(87 downto 80);
	to_tbox(2) <= input(47 downto 40);
	to_tbox(3) <= input(7 downto 0);
	to_tbox(4) <= input(95 downto 88);
	to_tbox(5) <= input(55 downto 48);
	to_tbox(6) <= input(15 downto 8);
	to_tbox(7) <= input(103 downto 96);
	to_tbox(8) <= input(63 downto 56);
	to_tbox(9) <= input(23 downto 16);
	to_tbox(10) <= input(111 downto 104);
	to_tbox(11) <= input(71 downto 64);
	to_tbox(12) <= input(31 downto 24);
	to_tbox(13) <= input(119 downto 112);
	to_tbox(14) <= input(79 downto 72);
	to_tbox(15) <= input(39 downto 32);
		
	-- SubBytes layer combined with MicColumn layer creates Tboxes, 
	-- Single byte affects 32 bits (GF(2^8) multiplication by x01, x01, x02, x03)	
	
tbox_gen : for i in 0 to 3 generate
		u0_tbox : aes_tbox0 port map (address=>to_tbox(4*i), dout=>after_tbox(4*i));
		u1_tbox : aes_tbox1 port map (address=>to_tbox(4*i+1), dout=>after_tbox(4*i+1));
		u2_tbox : aes_tbox2 port map (address=>to_tbox(4*i+2), dout=>after_tbox(4*i+2));
		u3_tbox : aes_tbox3 port map (address=>to_tbox(4*i+3), dout=>after_tbox(4*i+3));	
	
end generate;	

	-- MixColumn operation is completed by network of xors	
	
		to_xor <= (after_tbox(0) xor after_tbox(1) xor after_tbox(2) xor after_tbox(3)) & 
					(after_tbox(4) xor after_tbox(5) xor after_tbox(6) xor after_tbox(7)) & 
					(after_tbox(8) xor after_tbox(9) xor after_tbox(10) xor after_tbox(11)) & 
					(after_tbox(12) xor after_tbox(13) xor after_tbox(14) xor after_tbox(15));
					
		-- AddRoundKey layer				
			
		output <= to_xor xor key;
	
end tbox;

-- Straightforward implementation of AES round 

architecture basic of aes_round is

signal	after_subbyte		: std_logic_vector(AES_BLOCK_SIZE-1 downto 0);
signal	after_shiftrow		: std_logic_vector(AES_BLOCK_SIZE-1 downto 0);
signal	after_mixcolumn		: std_logic_vector(AES_BLOCK_SIZE-1 downto 0);

begin

	-- SubBytes layer  

sbox_gen: for i in 0 to AES_BLOCK_SIZE/AES_SBOX_SIZE - 1  generate
sbox	: aes_sbox 	generic map (rom_style=>rom_style)
			port map (	 
				input=>input(AES_SBOX_SIZE*i + 7 downto AES_SBOX_SIZE*i), 
				output=>after_subbyte(AES_SBOX_SIZE*i+7 downto AES_SBOX_SIZE*i));	
end generate;
	
	-- ShiftRow layer  	

sr	: aes_shiftrow	port map (input=>after_subbyte, output=>after_shiftrow);

	--MixColumn layer

mc_gen : for i in 0 to AES_BLOCK_SIZE/AES_WORD_SIZE - 1  generate
mc	: aes_mixcolumn	port map (	input=>after_shiftrow(AES_WORD_SIZE*i+31 downto AES_WORD_SIZE*i), 
								output=>after_mixcolumn(AES_WORD_SIZE*i+31 downto AES_WORD_SIZE*i));	
end generate;

	-- AddRoundKey layer

output <= after_mixcolumn xor key;

end basic; 