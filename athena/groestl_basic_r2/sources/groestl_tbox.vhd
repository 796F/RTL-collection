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

-- asynchronous Groestl tbox1 
-- it combines AES sbox with multiplication by 02, 03, 04, 05, 07 in GF(2^8)
-- irreduible polynomial x^8 + x^4 + x^3 + x + 1

entity groestl_tbox is
port (
		address 		: in std_logic_vector(AES_SBOX_SIZE-1 downto 0);
		dout 			: out std_logic_vector(5*AES_SBOX_SIZE-1 downto 0));

end groestl_tbox;  

architecture groestl_tbox of groestl_tbox is										 

type tbox_sub is array (0 to 255) of std_logic_vector (5*AES_SBOX_SIZE-1 downto 0);
constant tbox_value : tbox_sub := 
                      	
(	x"c6a597f432", x"f884eb976f", x"ee99c7b05e", x"f68df78c7a", x"ff0de517e8", x"d6bdb7dc0a", x"deb1a7c816", x"915439fc6d", 
x"6050c0f090", x"0203040507", x"cea987e02e", x"567dac87d1", x"e719d52bcc", x"b56271a613", x"4de69a317c", x"ec9ac3b559", 
x"8f4505cf40", x"1f9d3ebca3", x"894009c049", x"fa87ef9268", x"ef15c53fd0", x"b2eb7f2694", x"8ec90740ce", x"fb0bed1de6", 
x"41ec822f6e", x"b3677da91a", x"5ffdbe1c43", x"45ea8a2560", x"23bf46daf9", x"53f7a60251", x"e496d3a145", x"9b5b2ded76", 
x"75c2ea5d28", x"e11cd924c5", x"3dae7ae9d4", x"4c6a98bef2", x"6c5ad8ee82", x"7e41fcc3bd", x"f502f106f3", x"834f1dd152", 
x"685cd0e48c", x"51f4a20756", x"d134b95c8d", x"f908e918e1", x"e293dfae4c", x"ab734d953e", x"6253c4f597", x"2a3f54416b", 
x"080c10141c", x"955231f663", x"46658cafe9", x"9d5e21e27f", x"3028607848", x"37a16ef8cf", x"0a0f14111b", x"2fb55ec4eb", 
x"0e091c1b15", x"2436485a7e", x"1b9b36b6ad", x"df3da54798", x"cd26816aa7", x"4e699cbbf5", x"7fcdfe4c33", x"ea9fcfba50", 
x"121b242d3f", x"1d9e3ab9a4", x"5874b09cc4", x"342e687246", x"362d6c7741", x"dcb2a3cd11", x"b4ee73299d", x"5bfbb6164d", 
x"a4f65301a5", x"764decd7a1", x"b76175a314", x"7dcefa4934", x"527ba48ddf", x"dd3ea1429f", x"5e71bc93cd", x"139726a2b1", 
x"a6f55704a2", x"b96869b801", x"0000000000", x"c12c9974b5", x"406080a0e0", x"e31fdd21c2", x"79c8f2433a", x"b6ed772c9a", 
x"d4beb3d90d", x"8d4601ca47", x"67d9ce7017", x"724be4ddaf", x"94de3379ed", x"98d42b67ff", x"b0e87b2393", x"854a11de5b", 
x"bb6b6dbd06", x"c52a917ebb", x"4fe59e347b", x"ed16c13ad7", x"86c51754d2", x"9ad72f62f8", x"6655ccff99", x"119422a7b6", 
x"8acf0f4ac0", x"e910c930d9", x"0406080a0e", x"fe81e79866", x"a0f05b0bab", x"7844f0ccb4", x"25ba4ad5f0", x"4be3963e75", 
x"a2f35f0eac", x"5dfeba1944", x"80c01b5bdb", x"058a0a8580", x"3fad7eecd3", x"21bc42dffe", x"7048e0d8a8", x"f104f90cfd", 
x"63dfc67a19", x"77c1ee582f", x"af75459f30", x"426384a5e7", x"2030405070", x"e51ad12ecb", x"fd0ee112ef", x"bf6d65b708", 
x"814c19d455", x"1814303c24", x"26354c5f79", x"c32f9d71b2", x"bee1673886", x"35a26afdc8", x"88cc0b4fc7", x"2e395c4b65", 
x"93573df96a", x"55f2aa0d58", x"fc82e39d61", x"7a47f4c9b3", x"c8ac8bef27", x"bae76f3288", x"322b647d4f", x"e695d7a442", 
x"c0a09bfb3b", x"199832b3aa", x"9ed12768f6", x"a37f5d8122", x"446688aaee", x"547ea882d6", x"3bab76e6dd", x"0b83169e95", 
x"8cca0345c9", x"c729957bbc", x"6bd3d66e05", x"283c50446c", x"a779558b2c", x"bce2633d81", x"161d2c2731", x"ad76419a37", 
x"db3bad4d96", x"6456c8fa9e", x"744ee8d2a6", x"141e282236", x"92db3f76e4", x"0c0a181e12", x"486c90b4fc", x"b8e46b378f", 
x"9f5d25e778", x"bd6e61b20f", x"43ef862a69", x"c4a693f135", x"39a872e3da", x"31a462f7c6", x"d337bd598a", x"f28bff8674", 
x"d532b15683", x"8b430dc54e", x"6e59dceb85", x"dab7afc218", x"018c028f8e", x"b16479ac1d", x"9cd2236df1", x"49e0923b72", 
x"d8b4abc71f", x"acfa4315b9", x"f307fd09fa", x"cf25856fa0", x"caaf8fea20", x"f48ef3897d", x"47e98e2067", x"1018202838", 
x"6fd5de640b", x"f088fb8373", x"4a6f94b1fb", x"5c72b896ca", x"3824706c54", x"57f1ae085f", x"73c7e65221", x"975135f364", 
x"cb238d65ae", x"a17c598425", x"e89ccbbf57", x"3e217c635d", x"96dd377cea", x"61dcc27f1e", x"0d861a919c", x"0f851e949b", 
x"e090dbab4b", x"7c42f8c6ba", x"71c4e25726", x"ccaa83e529", x"90d83b73e3", x"06050c0f09", x"f701f503f4", x"1c1238362a", 
x"c2a39ffe3c", x"6a5fd4e18b", x"aef94710be", x"69d0d26b02", x"17912ea8bf", x"995829e871", x"3a27746953", x"27b94ed0f7", 
x"d938a94891", x"eb13cd35de", x"2bb356cee5", x"2233445577", x"d2bbbfd604", x"a970499039", x"07890e8087", x"33a766f2c1", 
x"2db65ac1ec", x"3c2278665a", x"15922aadb8", x"c9208960a9", x"874915db5c", x"aaff4f1ab0", x"5078a088d8", x"a57a518e2b", 
x"038f068a89", x"59f8b2134a", x"0980129b92", x"1a17343923", x"65daca7510", x"d731b55384", x"84c61351d5", x"d0b8bbd303", 
x"82c31f5edc", x"29b052cbe2", x"5a77b499c3", x"1e113c332d", x"7bcbf6463d", x"a8fc4b1fb7", x"6dd6da610c", x"2c3a584e62");


begin
	dout <= tbox_value(conv_integer(unsigned(address)));

end groestl_tbox;

