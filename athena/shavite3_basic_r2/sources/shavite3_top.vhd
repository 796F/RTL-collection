-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.sha3_pkg.all;
use work.shavite3_pkg.all;

-- Possible generic values: 
--      hs = {HASH_SIZE_256, HASH_SIZE_512}
--      aes_round_style = {AES_ROUND_BASIC, AES_ROUND_TBOX}  
--      rom_style = {DISTRIBUTED, COMBINATIONAL}	
--
-- Note: rom_style refers to the type of rom being used in SBOX implementation
--
-- All combinations are allowed, but rom_style generic is not used when aes_round_style = AES_ROUND_TBOX

entity shavite3_top is		
	generic (
        rom_style:integer:=DISTRIBUTED; 
        hs :integer := HASH_SIZE_256;  
        aes_round_style:integer:=AES_ROUND_BASIC
    ); 
	port (		
		clk 		: in std_logic;
		rst 		: in std_logic;
		src_ready 	: in std_logic;
		src_read  	: out std_logic;
		dst_ready 	: in std_logic;
		dst_write 	: out std_logic;		
		din		    : in std_logic_vector(w-1 downto 0);
		dout		: out std_logic_vector(w-1 downto 0));	   
end shavite3_top;


architecture struct of shavite3_top is 

begin

shavite3_256_gen: if hs = HASH_SIZE_256 generate

	s256: 
	entity work.shavite3_256(struct)
	generic map ( rom_style=>rom_style, aes_round_style=>aes_round_style)
	port map (rst=>rst, clk=>clk, src_ready=>src_ready, src_read=>src_read, dst_ready=>dst_ready, dst_write=>dst_write, din=>din, dout=>dout);

end generate;

shavite3_512_gen: if hs = HASH_SIZE_512 generate

	s512: 
	entity work.shavite3_512(struct)
	generic map ( rom_style=>rom_style, aes_round_style=>aes_round_style)	
	port map (rst=>rst, clk=>clk, src_ready=>src_ready, src_read=>src_read, dst_ready=>dst_ready, dst_write=>dst_write, din=>din, dout=>dout);

end generate;
	

end struct;
	
	