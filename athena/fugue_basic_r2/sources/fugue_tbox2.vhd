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

-- asynchronous Fugue tbox2 
-- it combines AES sbox with multiplication by 01, 04, 06, 07 in GF(2^8)
-- irreduible polynomial x^8 + x^4 + x^3 + x + 1

entity fugue_tbox2 is
port (
		address 		: in std_logic_vector(AES_SBOX_SIZE-1 downto 0);
		dout 			: out std_logic_vector(4*AES_SBOX_SIZE-1 downto 0));
end fugue_tbox2;  

architecture fugue_tbox2 of fugue_tbox2 is										 

type tbox_sub is array (0 to 255) of std_logic_vector (4*AES_SBOX_SIZE-1 downto 0);
constant tbox_value : tbox_sub := 
                      	
(	
x"63975132", x"7ceb136f", x"77c7295e", x"7bf7017a", x"f2e51ae8", x"6bb7610a", x"6fa77916", x"c539a86d", 
x"30c0a090", x"01040607", x"6787492e", x"2bacfad1", x"fed532cc", x"d771c413", x"ab9ad77c", x"76c32f59", 
x"ca058a40", x"823e21a3", x"c9098049", x"7def1568", x"fac52ad0", x"597fcd94", x"470789ce", x"f0ed16e6", 
x"ad82c36e", x"d47dce1a", x"a2bee143", x"af8acf60", x"9c4665f9", x"a4a6f551", x"72d33745", x"c02db676", 
x"b7ea9f28", x"fdd938c5", x"937a47d4", x"2698d4f2", x"36d8b482", x"3ffc82bd", x"f7f104f3", x"cc1d9e52", 
x"34d0b88c", x"a5a2f356", x"e5b9688d", x"f1e910e1", x"71df3d4c", x"d84de63e", x"31c4a697", x"15547e6b", 
x"0410181c", x"c731a463", x"238ccae9", x"c321bc7f", x"18605048", x"966e59cf", x"05141e1b", x"9a5e71eb", 
x"071c1215", x"12486c7e", x"80362dad", x"e2a57a98", x"eb814ca7", x"279cd2f5", x"b2fe8133", x"75cf2550", 
x"0924363f", x"833a27a4", x"2cb0e8c4", x"1a685c46", x"1b6c5a41", x"6ea37f11", x"5a73c79d", x"a0b6ed4d", 
x"5253f7a5", x"3bec9aa1", x"d675c214", x"b3fa8734", x"29a4f6df", x"e3a17c9f", x"2fbce2cd", x"842635b1", 
x"5357f1a2", x"d169d001", x"00000000", x"ed9958b5", x"2080c0e0", x"fcdd3ec2", x"b1f28b3a", x"5b77c19a", 
x"6ab3670d", x"cb018c47", x"becea917", x"39e496af", x"4a33a7ed", x"4c2bb3ff", x"587bcb93", x"cf11945b", 
x"d06dd606", x"ef9154bb", x"aa9ed17b", x"fbc12cd7", x"431791d2", x"4d2fb5f8", x"33ccaa99", x"852233b6", 
x"450f85c0", x"f9c920d9", x"02080c0e", x"7fe71966", x"505bfbab", x"3cf088b4", x"9f4a6ff0", x"a896dd75", 
x"515ffdac", x"a3bae744", x"401b9bdb", x"8f0a0f80", x"927e41d3", x"9d4263fe", x"38e090a8", x"f5f908fd", 
x"bcc6a519", x"b6ee992f", x"da45ea30", x"2184c6e7", x"10406070", x"ffd134cb", x"f3e11cef", x"d265da08", 
x"cd199855", x"0c302824", x"134c6a79", x"ec9d5eb2", x"5f67d986", x"976a5fc8", x"440b83c7", x"175c7265", 
x"c43dae6a", x"a7aaff58", x"7ee31f61", x"3df48eb3", x"648b4327", x"5d6fd588", x"1964564f", x"73d73142", 
x"609b5b3b", x"81322baa", x"4f27b9f6", x"dc5dfe22", x"2288ccee", x"2aa8fcd6", x"90764ddd", x"88161d95", 
x"46038fc9", x"ee9552bc", x"b8d6bd05", x"1450786c", x"de55f22c", x"5e63df81", x"0b2c3a31", x"db41ec37", 
x"e0ad7696", x"32c8ac9e", x"3ae89ca6", x"0a283c36", x"493fade4", x"06181412", x"2490d8fc", x"5c6bd38f", 
x"c225ba78", x"d361dc0f", x"ac86c569", x"62935735", x"91724bda", x"956253c6", x"e4bd6e8a", x"79ff0d74", 
x"e7b16483", x"c80d864e", x"37dcb285", x"6daf7518", x"8d02038e", x"d579c81d", x"4e23bff1", x"a992db72", 
x"6cab731f", x"5643efb9", x"f4fd0efa", x"ea854aa0", x"658f4520", x"7af3077d", x"ae8ec967", x"08203038", 
x"badeb10b", x"78fb0b73", x"2594defb", x"2eb8e4ca", x"1c704854", x"a6aef95f", x"b4e69521", x"c635a264", 
x"e88d46ae", x"dd59f825", x"74cb2357", x"1f7c425d", x"4b37a1ea", x"bdc2a31e", x"8b1a179c", x"8a1e119b", 
x"70db3b4b", x"3ef884ba", x"b5e29326", x"66834f29", x"483babe3", x"030c0a09", x"f6f502f4", x"0e38242a", 
x"619f5d3c", x"35d4be8b", x"5747e9be", x"b9d2bb02", x"862e39bf", x"c129b071", x"1d744e53", x"9e4e69f7", 
x"e1a97091", x"f8cd26de", x"98567de5", x"11446677", x"69bf6d04", x"d949e039", x"8e0e0987", x"946655c1", 
x"9b5a77ec", x"1e78445a", x"872a3fb8", x"e98940a9", x"ce15925c", x"554fe5b0", x"28a0f0d8", x"df51f42b", 
x"8c060589", x"a1b2eb4a", x"89121b92", x"0d342e23", x"bfcaaf10", x"e6b56284", x"421397d5", x"68bb6b03", 
x"411f9ddc", x"99527be2", x"2db4eec3", x"0f3c222d", x"b0f68d3d", x"544be3b7", x"bbdab70c", x"16587462");


begin
					dout <= tbox_value(conv_integer(unsigned(address)));

end fugue_tbox2;

