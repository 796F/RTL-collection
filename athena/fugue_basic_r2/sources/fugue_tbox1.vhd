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

-- asynchronous Fugue tbox1 
-- it combines AES sbox with multiplication by 01, 04, 05, 07 in GF(2^8)
-- irreduible polynomial x^8 + x^4 + x^3 + x + 1

entity fugue_tbox1 is
port (
		address 		: in std_logic_vector(AES_SBOX_SIZE-1 downto 0);
		dout 			: out std_logic_vector(4*AES_SBOX_SIZE-1 downto 0));

end fugue_tbox1;  

architecture fugue_tbox1 of fugue_tbox1 is										 

type tbox_sub is array (0 to 255) of std_logic_vector (4*AES_SBOX_SIZE-1 downto 0);
constant tbox_value : tbox_sub := 
                      	
(	
x"6397f432", x"7ceb976f", x"77c7b05e", x"7bf78c7a", x"f2e517e8", x"6bb7dc0a", x"6fa7c816", x"c539fc6d", 
x"30c0f090", x"01040507", x"6787e02e", x"2bac87d1", x"fed52bcc", x"d771a613", x"ab9a317c", x"76c3b559", 
x"ca05cf40", x"823ebca3", x"c909c049", x"7def9268", x"fac53fd0", x"597f2694", x"470740ce", x"f0ed1de6", 
x"ad822f6e", x"d47da91a", x"a2be1c43", x"af8a2560", x"9c46daf9", x"a4a60251", x"72d3a145", x"c02ded76", 
x"b7ea5d28", x"fdd924c5", x"937ae9d4", x"2698bef2", x"36d8ee82", x"3ffcc3bd", x"f7f106f3", x"cc1dd152", 
x"34d0e48c", x"a5a20756", x"e5b95c8d", x"f1e918e1", x"71dfae4c", x"d84d953e", x"31c4f597", x"1554416b", 
x"0410141c", x"c731f663", x"238cafe9", x"c321e27f", x"18607848", x"966ef8cf", x"0514111b", x"9a5ec4eb", 
x"071c1b15", x"12485a7e", x"8036b6ad", x"e2a54798", x"eb816aa7", x"279cbbf5", x"b2fe4c33", x"75cfba50", 
x"09242d3f", x"833ab9a4", x"2cb09cc4", x"1a687246", x"1b6c7741", x"6ea3cd11", x"5a73299d", x"a0b6164d", 
x"525301a5", x"3becd7a1", x"d675a314", x"b3fa4934", x"29a48ddf", x"e3a1429f", x"2fbc93cd", x"8426a2b1", 
x"535704a2", x"d169b801", x"00000000", x"ed9974b5", x"2080a0e0", x"fcdd21c2", x"b1f2433a", x"5b772c9a", 
x"6ab3d90d", x"cb01ca47", x"bece7017", x"39e4ddaf", x"4a3379ed", x"4c2b67ff", x"587b2393", x"cf11de5b", 
x"d06dbd06", x"ef917ebb", x"aa9e347b", x"fbc13ad7", x"431754d2", x"4d2f62f8", x"33ccff99", x"8522a7b6", 
x"450f4ac0", x"f9c930d9", x"02080a0e", x"7fe79866", x"505b0bab", x"3cf0ccb4", x"9f4ad5f0", x"a8963e75", 
x"515f0eac", x"a3ba1944", x"401b5bdb", x"8f0a8580", x"927eecd3", x"9d42dffe", x"38e0d8a8", x"f5f90cfd", 
x"bcc67a19", x"b6ee582f", x"da459f30", x"2184a5e7", x"10405070", x"ffd12ecb", x"f3e112ef", x"d265b708", 
x"cd19d455", x"0c303c24", x"134c5f79", x"ec9d71b2", x"5f673886", x"976afdc8", x"440b4fc7", x"175c4b65", 
x"c43df96a", x"a7aa0d58", x"7ee39d61", x"3df4c9b3", x"648bef27", x"5d6f3288", x"19647d4f", x"73d7a442", 
x"609bfb3b", x"8132b3aa", x"4f2768f6", x"dc5d8122", x"2288aaee", x"2aa882d6", x"9076e6dd", x"88169e95", 
x"460345c9", x"ee957bbc", x"b8d66e05", x"1450446c", x"de558b2c", x"5e633d81", x"0b2c2731", x"db419a37", 
x"e0ad4d96", x"32c8fa9e", x"3ae8d2a6", x"0a282236", x"493f76e4", x"06181e12", x"2490b4fc", x"5c6b378f", 
x"c225e778", x"d361b20f", x"ac862a69", x"6293f135", x"9172e3da", x"9562f7c6", x"e4bd598a", x"79ff8674", 
x"e7b15683", x"c80dc54e", x"37dceb85", x"6dafc218", x"8d028f8e", x"d579ac1d", x"4e236df1", x"a9923b72", 
x"6cabc71f", x"564315b9", x"f4fd09fa", x"ea856fa0", x"658fea20", x"7af3897d", x"ae8e2067", x"08202838", 
x"bade640b", x"78fb8373", x"2594b1fb", x"2eb896ca", x"1c706c54", x"a6ae085f", x"b4e65221", x"c635f364", 
x"e88d65ae", x"dd598425", x"74cbbf57", x"1f7c635d", x"4b377cea", x"bdc27f1e", x"8b1a919c", x"8a1e949b", 
x"70dbab4b", x"3ef8c6ba", x"b5e25726", x"6683e529", x"483b73e3", x"030c0f09", x"f6f503f4", x"0e38362a", 
x"619ffe3c", x"35d4e18b", x"574710be", x"b9d26b02", x"862ea8bf", x"c129e871", x"1d746953", x"9e4ed0f7", 
x"e1a94891", x"f8cd35de", x"9856cee5", x"11445577", x"69bfd604", x"d9499039", x"8e0e8087", x"9466f2c1", 
x"9b5ac1ec", x"1e78665a", x"872aadb8", x"e98960a9", x"ce15db5c", x"554f1ab0", x"28a088d8", x"df518e2b", 
x"8c068a89", x"a1b2134a", x"89129b92", x"0d343923", x"bfca7510", x"e6b55384", x"421351d5", x"68bbd303", 
x"411f5edc", x"9952cbe2", x"2db499c3", x"0f3c332d", x"b0f6463d", x"544b1fb7", x"bbda610c", x"16584e62");


begin
					dout <= tbox_value(conv_integer(unsigned(address)));

end fugue_tbox1;

 
