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

-- asynchronous AES tbox2 
-- it combines AES sbox with multiplication by 01, 03, 02, 01 in GF(2^8)
-- irreduible polynomial x^8 + x^4 + x^3 + x + 1

entity aes_tbox2 is
port (
		address 	: in std_logic_vector(AES_SBOX_SIZE-1 downto 0);
		dout 		: out std_logic_vector(AES_WORD_SIZE-1 downto 0));

end aes_tbox2;  

architecture aes_tbox_t2_arch of aes_tbox2 is										 

type tbox_sub is array (0 to 255) of std_logic_vector (AES_WORD_SIZE-1 downto 0);
constant tbox_value : tbox_sub := 
                      	
(	x"63a5c663", x"7c84f87c", x"7799ee77", x"7b8df67b", x"f20dfff2", x"6bbdd66b", x"6fb1de6f", x"c55491c5", x"30506030", x"01030201", x"67a9ce67", x"2b7d562b", x"fe19e7fe", x"d762b5d7", x"abe64dab", x"769aec76",
	x"ca458fca", x"829d1f82", x"c94089c9", x"7d87fa7d", x"fa15effa", x"59ebb259", x"47c98e47", x"f00bfbf0", x"adec41ad", x"d467b3d4", x"a2fd5fa2", x"afea45af", x"9cbf239c", x"a4f753a4", x"7296e472", x"c05b9bc0",
	x"b7c275b7", x"fd1ce1fd", x"93ae3d93", x"266a4c26", x"365a6c36", x"3f417e3f", x"f702f5f7", x"cc4f83cc", x"345c6834", x"a5f451a5", x"e534d1e5", x"f108f9f1", x"7193e271", x"d873abd8", x"31536231", x"153f2a15",
	x"040C0804", x"c75295c7", x"23654623", x"c35e9dc3", x"18283018", x"96a13796", x"050f0a05", x"9ab52f9a", x"07090e07", x"12362412", x"809b1b80", x"e23ddfe2", x"eb26cdeb", x"27694e27", x"b2cd7fb2", x"759fea75",
	x"091b1209", x"839e1d83", x"2c74582c", x"1a2e341a", x"1b2d361b", x"6eb2dc6e", x"5aeeb45a", x"a0fb5ba0", x"52f6a452", x"3b4d763b", x"d661b7d6", x"b3ce7db3", x"297b5229", x"e33edde3", x"2f715e2f", x"84971384",
	x"53f5a653", x"d168b9d1", x"00000000", x"ed2cc1ed", x"20604020", x"fc1fe3fc", x"b1c879b1", x"5bedb65b", x"6abed46a", x"cb468dcb", x"bed967be", x"394b7239", x"4ade944a", x"4cd4984c", x"58e8b058", x"cf4a85cf",
	x"d06bbbd0", x"ef2ac5ef", x"aae54faa", x"fb16edfb", x"43c58643", x"4dd79a4d", x"33556633", x"85941185", x"45cf8a45", x"f910e9f9", x"02060402", x"7f81fe7f", x"50f0a050", x"3c44783c", x"9fba259f", x"a8e34ba8",
	x"51f3a251", x"a3fe5da3", x"40c08040", x"8f8a058f", x"92ad3f92", x"9dbc219d", x"38487038", x"f504f1f5", x"bcdf63bc", x"b6c177b6", x"da75afda", x"21634221", x"10302010", x"ff1ae5ff", x"f30efdf3", x"d26dbfd2",
	x"cd4c81cd", x"0c14180c", x"13352613", x"ec2fc3ec", x"5fe1be5f", x"97a23597", x"44cc8844", x"17392e17", x"c45793c4", x"a7f255a7", x"7e82fc7e", x"3d477a3d", x"64acc864", x"5de7ba5d", x"192B3219", x"7395e673",
	x"60a0c060", x"81981981", x"4fd19e4f", x"dc7fa3dc", x"22664422", x"2a7e542a", x"90ab3b90", x"88830b88", x"46ca8c46", x"ee29c7ee", x"b8d36bb8", x"143c2814", x"de79a7de", x"5ee2bc5e", x"0b1d160b", x"db76addb",
	x"e03bdbe0", x"32566432", x"3a4e743a", x"0a1e140a", x"49db9249", x"060a0c06", x"246c4824", x"5ce4b85c", x"c25d9fc2", x"d36ebdd3", x"acef43ac", x"62a6c462", x"91a83991", x"95a43195", x"e437d3e4", x"798bf279",
	x"e732d5e7", x"c8438bc8", x"37596e37", x"6db7da6d", x"8d8c018d", x"d564b1d5", x"4ed29c4e", x"a9e049a9", x"6cb4d86c", x"56faac56", x"f407f3f4", x"ea25cfea", x"65afca65", x"7a8ef47a", x"aee947ae", x"08181008",
	x"bad56fba", x"7888f078", x"256f4a25", x"2e725c2e", x"1c24381c", x"a6f157a6", x"b4c773b4", x"c65197c6", x"e823cbe8", x"dd7ca1dd", x"749ce874", x"1f213e1f", x"4bdd964b", x"bddc61bd", x"8b860d8b", x"8a850f8a",
	x"7090e070", x"3e427c3e", x"b5c471b5", x"66aacc66", x"48d89048", x"03050603", x"f601f7f6", x"0e121c0e", x"61a3c261", x"355f6a35", x"57f9ae57", x"b9d069b9", x"86911786", x"c15899c1", x"1d273a1d", x"9eb9279e",
	x"e138d9e1", x"f813ebf8", x"98b32b98", x"11332211", x"69bbd269", x"d970a9d9", x"8e89078e", x"94a73394", x"9bb62d9b", x"1e223c1e", x"87921587", x"e920c9e9", x"ce4987ce", x"55ffaa55", x"28785028", x"df7aa5df",
	x"8c8f038c", x"a1f859a1", x"89800989", x"0d171a0d", x"bfda65bf", x"e631d7e6", x"42c68442", x"68b8d068", x"41c38241", x"99b02999", x"2d775a2d", x"0f111e0f", x"b0cb7bb0", x"54fca854", x"bbd66dbb", x"163a2c16");


begin

					dout <= tbox_value(conv_integer(unsigned(address)));


end aes_tbox_t2_arch;
