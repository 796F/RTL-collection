-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library	ieee;
use ieee.std_logic_1164.all;
use	ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.sha3_pkg.all;

-- asynchronous Fugue tbox0 
-- it combines AES sbox with multiplication by 01, 04, 07 in GF(2^8)
-- irreduible polynomial x^8 + x^4 + x^3 + x + 1

entity fugue_tbox0 is
port (
		address 		: in std_logic_vector(AES_SBOX_SIZE-1 downto 0);
		dout 			: out std_logic_vector(3*AES_SBOX_SIZE-1 downto 0));

end fugue_tbox0;  

architecture fugue_tbox0 of fugue_tbox0 is										 

type tbox_sub is array (0 to 255) of std_logic_vector (3*AES_SBOX_SIZE-1 downto 0);
constant tbox_value : tbox_sub := 
                      	
(	
x"639732", x"7ceb6f", x"77c75e", x"7bf77a", x"f2e5e8", x"6bb70a", x"6fa716", x"c5396d", 
x"30c090", x"010407", x"67872e", x"2bacd1", x"fed5cc", x"d77113", x"ab9a7c", x"76c359", 
x"ca0540", x"823ea3", x"c90949", x"7def68", x"fac5d0", x"597f94", x"4707ce", x"f0ede6", 
x"ad826e", x"d47d1a", x"a2be43", x"af8a60", x"9c46f9", x"a4a651", x"72d345", x"c02d76", 
x"b7ea28", x"fdd9c5", x"937ad4", x"2698f2", x"36d882", x"3ffcbd", x"f7f1f3", x"cc1d52", 
x"34d08c", x"a5a256", x"e5b98d", x"f1e9e1", x"71df4c", x"d84d3e", x"31c497", x"15546b", 
x"04101c", x"c73163", x"238ce9", x"c3217f", x"186048", x"966ecf", x"05141b", x"9a5eeb", 
x"071c15", x"12487e", x"8036ad", x"e2a598", x"eb81a7", x"279cf5", x"b2fe33", x"75cf50", 
x"09243f", x"833aa4", x"2cb0c4", x"1a6846", x"1b6c41", x"6ea311", x"5a739d", x"a0b64d", 
x"5253a5", x"3beca1", x"d67514", x"b3fa34", x"29a4df", x"e3a19f", x"2fbccd", x"8426b1", 
x"5357a2", x"d16901", x"000000", x"ed99b5", x"2080e0", x"fcddc2", x"b1f23a", x"5b779a", 
x"6ab30d", x"cb0147", x"bece17", x"39e4af", x"4a33ed", x"4c2bff", x"587b93", x"cf115b", 
x"d06d06", x"ef91bb", x"aa9e7b", x"fbc1d7", x"4317d2", x"4d2ff8", x"33cc99", x"8522b6", 
x"450fc0", x"f9c9d9", x"02080e", x"7fe766", x"505bab", x"3cf0b4", x"9f4af0", x"a89675", 
x"515fac", x"a3ba44", x"401bdb", x"8f0a80", x"927ed3", x"9d42fe", x"38e0a8", x"f5f9fd", 
x"bcc619", x"b6ee2f", x"da4530", x"2184e7", x"104070", x"ffd1cb", x"f3e1ef", x"d26508", 
x"cd1955", x"0c3024", x"134c79", x"ec9db2", x"5f6786", x"976ac8", x"440bc7", x"175c65", 
x"c43d6a", x"a7aa58", x"7ee361", x"3df4b3", x"648b27", x"5d6f88", x"19644f", x"73d742", 
x"609b3b", x"8132aa", x"4f27f6", x"dc5d22", x"2288ee", x"2aa8d6", x"9076dd", x"881695", 
x"4603c9", x"ee95bc", x"b8d605", x"14506c", x"de552c", x"5e6381", x"0b2c31", x"db4137", 
x"e0ad96", x"32c89e", x"3ae8a6", x"0a2836", x"493fe4", x"061812", x"2490fc", x"5c6b8f", 
x"c22578", x"d3610f", x"ac8669", x"629335", x"9172da", x"9562c6", x"e4bd8a", x"79ff74", 
x"e7b183", x"c80d4e", x"37dc85", x"6daf18", x"8d028e", x"d5791d", x"4e23f1", x"a99272", 
x"6cab1f", x"5643b9", x"f4fdfa", x"ea85a0", x"658f20", x"7af37d", x"ae8e67", x"082038", 
x"bade0b", x"78fb73", x"2594fb", x"2eb8ca", x"1c7054", x"a6ae5f", x"b4e621", x"c63564", 
x"e88dae", x"dd5925", x"74cb57", x"1f7c5d", x"4b37ea", x"bdc21e", x"8b1a9c", x"8a1e9b", 
x"70db4b", x"3ef8ba", x"b5e226", x"668329", x"483be3", x"030c09", x"f6f5f4", x"0e382a", 
x"619f3c", x"35d48b", x"5747be", x"b9d202", x"862ebf", x"c12971", x"1d7453", x"9e4ef7", 
x"e1a991", x"f8cdde", x"9856e5", x"114477", x"69bf04", x"d94939", x"8e0e87", x"9466c1", 
x"9b5aec", x"1e785a", x"872ab8", x"e989a9", x"ce155c", x"554fb0", x"28a0d8", x"df512b", 
x"8c0689", x"a1b24a", x"891292", x"0d3423", x"bfca10", x"e6b584", x"4213d5", x"68bb03", 
x"411fdc", x"9952e2", x"2db4c3", x"0f3c2d", x"b0f63d", x"544bb7", x"bbda0c", x"165862");


begin
					dout <= tbox_value(conv_integer(unsigned(address)));

end fugue_tbox0;

