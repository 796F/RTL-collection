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

-- asynchronous AES tbox3 
-- it combines AES sbox with multiplication by 01, 01, 03, 02 in GF(2^8)
-- irreduible polynomial x^8 + x^4 + x^3 + x + 1

entity aes_tbox3 is
port (
		address 		: in std_logic_vector(AES_SBOX_SIZE-1 downto 0);
		dout 			: out std_logic_vector(AES_WORD_SIZE-1 downto 0));

end aes_tbox3;  

architecture aes_tbox_t3_arch of aes_tbox3 is										 

type tbox_sub is array (0 to 255) of std_logic_vector (AES_WORD_SIZE-1 downto 0);
constant tbox_value : tbox_sub := 
                      	
(	x"6363a5c6", x"7c7c84f8", x"777799ee", x"7b7b8df6", x"f2f20dff", x"6b6bbdd6", x"6f6fb1de", x"c5c55491", x"30305060", x"01010302", x"6767a9ce", x"2b2b7d56", x"fefe19e7", x"d7d762b5", x"ababe64d", x"76769aec",
	x"caca458f", x"82829d1f", x"c9c94089", x"7d7d87fa", x"fafa15ef", x"5959ebb2", x"4747c98e", x"f0f00bfb", x"adadec41", x"d4d467b3", x"a2a2fd5f", x"afafea45", x"9c9cbf23", x"a4a4f753", x"727296e4", x"c0c05b9b",
	x"b7b7c275", x"fdfd1ce1", x"9393ae3d", x"26266a4c", x"36365a6c", x"3f3f417e", x"f7f702f5", x"cccc4f83", x"34345c68", x"a5a5f451", x"e5e534d1", x"f1f108f9", x"717193e2", x"d8d873ab", x"31315362", x"15153f2a",
	x"04040C08", x"c7c75295", x"23236546", x"c3c35e9d", x"18182830", x"9696a137", x"05050f0a", x"9a9ab52f", x"0707090e", x"12123624", x"80809b1b", x"e2e23ddf", x"ebeb26cd", x"2727694e", x"b2b2cd7f", x"75759fea",
	x"09091b12", x"83839e1d", x"2c2c7458", x"1a1a2e34", x"1b1b2d36", x"6e6eb2dc", x"5a5aeeb4", x"a0a0fb5b", x"5252f6a4", x"3b3b4d76", x"d6d661b7", x"b3b3ce7d", x"29297b52", x"e3e33edd", x"2f2f715e", x"84849713",
	x"5353f5a6", x"d1d168b9", x"00000000", x"eded2cc1", x"20206040", x"fcfc1fe3", x"b1b1c879", x"5b5bedb6", x"6a6abed4", x"cbcb468d", x"bebed967", x"39394b72", x"4a4ade94", x"4c4cd498", x"5858e8b0", x"cfcf4a85",
	x"d0d06bbb", x"efef2ac5", x"aaaae54f", x"fbfb16ed", x"4343c586", x"4d4dd79a", x"33335566", x"85859411", x"4545cf8a", x"f9f910e9", x"02020604", x"7f7f81fe", x"5050f0a0", x"3c3c4478", x"9f9fba25", x"a8a8e34b",
	x"5151f3a2", x"a3a3fe5d", x"4040c080", x"8f8f8a05", x"9292ad3f", x"9d9dbc21", x"38384870", x"f5f504f1", x"bcbcdf63", x"b6b6c177", x"dada75af", x"21216342", x"10103020", x"ffff1ae5", x"f3f30efd", x"d2d26dbf",
	x"cdcd4c81", x"0c0c1418", x"13133526", x"ecec2fc3", x"5f5fe1be", x"9797a235", x"4444cc88", x"1717392e", x"c4c45793", x"a7a7f255", x"7e7e82fc", x"3d3d477a", x"6464acc8", x"5d5de7ba", x"19192B32", x"737395e6",
	x"6060a0c0", x"81819819", x"4f4fd19e", x"dcdc7fa3", x"22226644", x"2a2a7e54", x"9090ab3b", x"8888830b", x"4646ca8c", x"eeee29c7", x"b8b8d36b", x"14143c28", x"dede79a7", x"5e5ee2bc", x"0b0b1d16", x"dbdb76ad",
	x"e0e03bdb", x"32325664", x"3a3a4e74", x"0a0a1e14", x"4949db92", x"06060a0c", x"24246c48", x"5c5ce4b8", x"c2c25d9f", x"d3d36ebd", x"acacef43", x"6262a6c4", x"9191a839", x"9595a431", x"e4e437d3", x"79798bf2",
	x"e7e732d5", x"c8c8438b", x"3737596e", x"6d6db7da", x"8d8d8c01", x"d5d564b1", x"4e4ed29c", x"a9a9e049", x"6c6cb4d8", x"5656faac", x"f4f407f3", x"eaea25cf", x"6565afca", x"7a7a8ef4", x"aeaee947", x"08081810",
	x"babad56f", x"787888f0", x"25256f4a", x"2e2e725c", x"1c1c2438", x"a6a6f157", x"b4b4c773", x"c6c65197", x"e8e823cb", x"dddd7ca1", x"74749ce8", x"1f1f213e", x"4b4bdd96", x"bdbddc61", x"8b8b860d", x"8a8a850f",
	x"707090e0", x"3e3e427c", x"b5b5c471", x"6666aacc", x"4848d890", x"03030506", x"f6f601f7", x"0e0e121c", x"6161a3c2", x"35355f6a", x"5757f9ae", x"b9b9d069", x"86869117", x"c1c15899", x"1d1d273a", x"9e9eb927",
	x"e1e138d9", x"f8f813eb", x"9898b32b", x"11113322", x"6969bbd2", x"d9d970a9", x"8e8e8907", x"9494a733", x"9b9bb62d", x"1e1e223c", x"87879215", x"e9e920c9", x"cece4987", x"5555ffaa", x"28287850", x"dfdf7aa5",
	x"8c8c8f03", x"a1a1f859", x"89898009", x"0d0d171a", x"bfbfda65", x"e6e631d7", x"4242c684", x"6868b8d0", x"4141c382", x"9999b029", x"2d2d775a", x"0f0f111e", x"b0b0cb7b", x"5454fca8", x"bbbbd66d", x"16163a2c");


begin
					dout <= tbox_value(conv_integer(unsigned(address)));

end aes_tbox_t3_arch;
