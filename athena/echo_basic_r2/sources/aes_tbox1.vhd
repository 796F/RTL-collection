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

-- asynchronous AES tbox1 
-- it combines AES sbox with multiplication by 03, 02, 01, 01, in GF(2^8)
-- irreduible polynomial x^8 + x^4 + x^3 + x + 1

entity aes_tbox1 is
port (
		address 	: in std_logic_vector(AES_SBOX_SIZE-1 downto 0);
		dout 		: out std_logic_vector(AES_WORD_SIZE-1 downto 0));

end aes_tbox1;  

architecture aes_tbox_t1_arch of aes_tbox1 is										 

type tbox_sub is array (0 to 255) of std_logic_vector (AES_WORD_SIZE-1 downto 0);
constant tbox_value : tbox_sub := 
                      	
(	x"a5c66363", x"84f87c7c", x"99ee7777", x"8df67b7b", x"0dfff2f2", x"bdd66b6b", x"b1de6f6f", x"5491c5c5", x"50603030", x"03020101", x"a9ce6767", x"7d562b2b", x"19e7fefe", x"62b5d7d7", x"e64dabab", x"9aec7676",
	x"458fcaca", x"9d1f8282", x"4089c9c9", x"87fa7d7d", x"15effafa", x"ebb25959", x"c98e4747", x"0bfbf0f0", x"ec41adad", x"67b3d4d4", x"fd5fa2a2", x"ea45afaf", x"bf239c9c", x"f753a4a4", x"96e47272", x"5b9bc0c0",
	x"c275b7b7", x"1ce1fdfd", x"ae3d9393", x"6a4c2626", x"5a6c3636", x"417e3f3f", x"02f5f7f7", x"4f83cccc", x"5c683434", x"f451a5a5", x"34d1e5e5", x"08f9f1f1", x"93e27171", x"73abd8d8", x"53623131", x"3f2a1515",
	x"0C080404", x"5295c7c7", x"65462323", x"5e9dc3c3", x"28301818", x"a1379696", x"0f0a0505", x"b52f9a9a", x"090e0707", x"36241212", x"9b1b8080", x"3ddfe2e2", x"26cdebeb", x"694e2727", x"cd7fb2b2", x"9fea7575",
	x"1b120909", x"9e1d8383", x"74582c2c", x"2e341a1a", x"2d361b1b", x"b2dc6e6e", x"eeb45a5a", x"fb5ba0a0", x"f6a45252", x"4d763b3b", x"61b7d6d6", x"ce7db3b3", x"7b522929", x"3edde3e3", x"715e2f2f", x"97138484",
	x"f5a65353", x"68b9d1d1", x"00000000", x"2cc1eded", x"60402020", x"1fe3fcfc", x"c879b1b1", x"edb65b5b", x"bed46a6a", x"468dcbcb", x"d967bebe", x"4b723939", x"de944a4a", x"d4984c4c", x"e8b05858", x"4a85cfcf",
	x"6bbbd0d0", x"2ac5efef", x"e54faaaa", x"16edfbfb", x"c5864343", x"d79a4d4d", x"55663333", x"94118585", x"cf8a4545", x"10e9f9f9", x"06040202", x"81fe7f7f", x"f0a05050", x"44783c3c", x"ba259f9f", x"e34ba8a8",
	x"f3a25151", x"fe5da3a3", x"c0804040", x"8a058f8f", x"ad3f9292", x"bc219d9d", x"48703838", x"04f1f5f5", x"df63bcbc", x"c177b6b6", x"75afdada", x"63422121", x"30201010", x"1ae5ffff", x"0efdf3f3", x"6dbfd2d2",
	x"4c81cdcd", x"14180c0c", x"35261313", x"2fc3ecec", x"e1be5f5f", x"a2359797", x"cc884444", x"392e1717", x"5793c4c4", x"f255a7a7", x"82fc7e7e", x"477a3d3d", x"acc86464", x"e7ba5d5d", x"2B321919", x"95e67373",
	x"a0c06060", x"98198181", x"d19e4f4f", x"7fa3dcdc", x"66442222", x"7e542a2a", x"ab3b9090", x"830b8888", x"ca8c4646", x"29c7eeee", x"d36bb8b8", x"3c281414", x"79a7dede", x"e2bc5e5e", x"1d160b0b", x"76addbdb",
	x"3bdbe0e0", x"56643232", x"4e743a3a", x"1e140a0a", x"db924949", x"0a0c0606", x"6c482424", x"e4b85c5c", x"5d9fc2c2", x"6ebdd3d3", x"ef43acac", x"a6c46262", x"a8399191", x"a4319595", x"37d3e4e4", x"8bf27979",
	x"32d5e7e7", x"438bc8c8", x"596e3737", x"b7da6d6d", x"8c018d8d", x"64b1d5d5", x"d29c4e4e", x"e049a9a9", x"b4d86c6c", x"faac5656", x"07f3f4f4", x"25cfeaea", x"afca6565", x"8ef47a7a", x"e947aeae", x"18100808",
	x"d56fbaba", x"88f07878", x"6f4a2525", x"725c2e2e", x"24381c1c", x"f157a6a6", x"c773b4b4", x"5197c6c6", x"23cbe8e8", x"7ca1dddd", x"9ce87474", x"213e1f1f", x"dd964b4b", x"dc61bdbd", x"860d8b8b", x"850f8a8a",
	x"90e07070", x"427c3e3e", x"c471b5b5", x"aacc6666", x"d8904848", x"05060303", x"01f7f6f6", x"121c0e0e", x"a3c26161", x"5f6a3535", x"f9ae5757", x"d069b9b9", x"91178686", x"5899c1c1", x"273a1d1d", x"b9279e9e",
	x"38d9e1e1", x"13ebf8f8", x"b32b9898", x"33221111", x"bbd26969", x"70a9d9d9", x"89078e8e", x"a7339494", x"b62d9b9b", x"223c1e1e", x"92158787", x"20c9e9e9", x"4987cece", x"ffaa5555", x"78502828", x"7aa5dfdf",
	x"8f038c8c", x"f859a1a1", x"80098989", x"171a0d0d", x"da65bfbf", x"31d7e6e6", x"c6844242", x"b8d06868", x"c3824141", x"b0299999", x"775a2d2d", x"111e0f0f", x"cb7bb0b0", x"fca85454", x"d66dbbbb", x"3a2c1616");
	
		begin

					dout <= tbox_value(conv_integer(unsigned(address)));


end aes_tbox_t1_arch;
