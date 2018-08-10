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

-- asynchronous AES tbox0 
-- it combines AES sbox with multiplication by 02, 01, 01, 03 in GF(2^8)
-- irreduible polynomial x^8 + x^4 + x^3 + x + 1

entity aes_tbox0 is
port (
	address 	: in std_logic_vector(AES_SBOX_SIZE-1 downto 0);
	dout 		: out std_logic_vector(AES_WORD_SIZE-1 downto 0));
end aes_tbox0;  

architecture aes_tbox_t0_arch of aes_tbox0 is										 

type tbox_sub is array (0 to 255) of std_logic_vector (AES_WORD_SIZE-1 downto 0);
constant tbox_value : tbox_sub := 
                      
(	x"c66363a5", x"f87c7c84", x"ee777799", x"f67b7b8d", x"fff2f20d", x"d66b6bbd", x"de6f6fb1", x"91c5c554", x"60303050", x"02010103", x"ce6767a9", x"562b2b7d", x"e7fefe19", x"b5d7d762", x"4dababe6", x"ec76769a",
	x"8fcaca45", x"1f82829d", x"89c9c940", x"fa7d7d87", x"effafa15", x"b25959eb", x"8e4747c9", x"fbf0f00b", x"41adadec", x"b3d4d467", x"5fa2a2fd", x"45afafea", x"239c9cbf", x"53a4a4f7", x"e4727296", x"9bc0c05b",
	x"75b7b7c2", x"e1fdfd1c", x"3d9393ae", x"4c26266a", x"6c36365a", x"7e3f3f41", x"f5f7f702", x"83cccc4f", x"6834345c", x"51a5a5f4", x"d1e5e534", x"f9f1f108", x"e2717193", x"abd8d873", x"62313153", x"2a15153f",
	x"0804040C", x"95c7c752", x"46232365", x"9dc3c35e", x"30181828", x"379696a1", x"0a05050f", x"2f9a9ab5", x"0e070709", x"24121236", x"1b80809b", x"dfe2e23d", x"cdebeb26", x"4e272769", x"7fb2b2cd", x"ea75759f",
	x"1209091b", x"1d83839e", x"582c2c74", x"341a1a2e", x"361b1b2d", x"dc6e6eb2", x"b45a5aee", x"5ba0a0fb", x"a45252f6", x"763b3b4d", x"b7d6d661", x"7db3b3ce", x"5229297b", x"dde3e33e", x"5e2f2f71", x"13848497",
	x"a65353f5", x"b9d1d168", x"00000000", x"c1eded2c", x"40202060", x"e3fcfc1f", x"79b1b1c8", x"b65b5bed", x"d46a6abe", x"8dcbcb46", x"67bebed9", x"7239394b", x"944a4ade", x"984c4cd4", x"b05858e8", x"85cfcf4a",
	x"bbd0d06b", x"c5efef2a", x"4faaaae5", x"edfbfb16", x"864343c5", x"9a4d4dd7", x"66333355", x"11858594", x"8a4545cf", x"e9f9f910", x"04020206", x"fe7f7f81", x"a05050f0", x"783c3c44", x"259f9fba", x"4ba8a8e3",
	x"a25151f3", x"5da3a3fe", x"804040c0", x"058f8f8a", x"3f9292ad", x"219d9dbc", x"70383848", x"f1f5f504", x"63bcbcdf", x"77b6b6c1", x"afdada75", x"42212163", x"20101030", x"e5ffff1a", x"fdf3f30e", x"bfd2d26d",
	x"81cdcd4c", x"180c0c14", x"26131335", x"c3ecec2f", x"be5f5fe1", x"359797a2", x"884444cc", x"2e171739", x"93c4c457", x"55a7a7f2", x"fc7e7e82", x"7a3d3d47", x"c86464ac", x"ba5d5de7", x"3219192B", x"e6737395",
	x"c06060a0", x"19818198", x"9e4f4fd1", x"a3dcdc7f", x"44222266", x"542a2a7e", x"3b9090ab", x"0b888883", x"8c4646ca", x"c7eeee29", x"6bb8b8d3", x"2814143c", x"a7dede79", x"bc5e5ee2", x"160b0b1d", x"addbdb76",
	x"dbe0e03b", x"64323256", x"743a3a4e", x"140a0a1e", x"924949db", x"0c06060a", x"4824246c", x"b85c5ce4", x"9fc2c25d", x"bdd3d36e", x"43acacef", x"c46262a6", x"399191a8", x"319595a4", x"d3e4e437", x"f279798b",
	x"d5e7e732", x"8bc8c843", x"6e373759", x"da6d6db7", x"018d8d8c", x"b1d5d564", x"9c4e4ed2", x"49a9a9e0", x"d86c6cb4", x"ac5656fa", x"f3f4f407", x"cfeaea25", x"ca6565af", x"f47a7a8e", x"47aeaee9", x"10080818",
	x"6fbabad5", x"f0787888", x"4a25256f", x"5c2e2e72", x"381c1c24", x"57a6a6f1", x"73b4b4c7", x"97c6c651", x"cbe8e823", x"a1dddd7c", x"e874749c", x"3e1f1f21", x"964b4bdd", x"61bdbddc", x"0d8b8b86", x"0f8a8a85",
	x"e0707090", x"7c3e3e42", x"71b5b5c4", x"cc6666aa", x"904848d8", x"06030305", x"f7f6f601", x"1c0e0e12", x"c26161a3", x"6a35355f", x"ae5757f9", x"69b9b9d0", x"17868691", x"99c1c158", x"3a1d1d27", x"279e9eb9",
	x"d9e1e138", x"ebf8f813", x"2b9898b3", x"22111133", x"d26969bb", x"a9d9d970", x"078e8e89", x"339494a7", x"2d9b9bb6", x"3c1e1e22", x"15878792", x"c9e9e920", x"87cece49", x"aa5555ff", x"50282878", x"a5dfdf7a",
	x"038c8c8f", x"59a1a1f8", x"09898980", x"1a0d0d17", x"65bfbfda", x"d7e6e631", x"844242c6", x"d06868b8", x"824141c3", x"299999b0", x"5a2d2d77", x"1e0f0f11", x"7bb0b0cb", x"a85454fc", x"6dbbbbd6", x"2c16163a");
                        
begin
					dout <= tbox_value(conv_integer(unsigned(address)));

end aes_tbox_t0_arch;
