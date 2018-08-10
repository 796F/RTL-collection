-- =====================================================================
-- Copyright © 2010-11 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.sha2_pkg.all;

entity sha2_cons64 is 
generic(l :integer:=1; n :integer:=HASH_SIZE_512/SHA2_WORDS_NUM; a:integer:=LOG_2_80; r:integer:=ROUNDS_80);	
port(
	clk		: in std_logic;	
	address		: in std_logic_vector(a-1 downto 0);
  	output		: out std_logic_vector(l*n-1 downto 0));
end sha2_cons64;

architecture sha2_cons64 of sha2_cons64 is

type matrix is array (0 to r+47) of std_logic_vector(n-1 downto 0);
constant my_rom: matrix :=(
x"428a2f98d728ae22",
x"7137449123ef65cd", 
x"b5c0fbcfec4d3b2f", 
x"e9b5dba58189dbbc",
x"3956c25bf348b538",
x"59f111f1b605d019", 
x"923f82a4af194f9b", 
x"ab1c5ed5da6d8118",
x"d807aa98a3030242", 
x"12835b0145706fbe", 
x"243185be4ee4b28c", 
x"550c7dc3d5ffb4e2",
x"72be5d74f27b896f", 
x"80deb1fe3b1696b1", 
x"9bdc06a725c71235", 
x"c19bf174cf692694",
x"e49b69c19ef14ad2", 
x"efbe4786384f25e3", 
x"0fc19dc68b8cd5b5", 
x"240ca1cc77ac9c65",
x"2de92c6f592b0275", 
x"4a7484aa6ea6e483", 
x"5cb0a9dcbd41fbd4", 
x"76f988da831153b5",
x"983e5152ee66dfab", 
x"a831c66d2db43210", 
x"b00327c898fb213f", 
x"bf597fc7beef0ee4",
x"c6e00bf33da88fc2", 
x"d5a79147930aa725", 
x"06ca6351e003826f", 
x"142929670a0e6e70",
x"27b70a8546d22ffc", 
x"2e1b21385c26c926", 
x"4d2c6dfc5ac42aed", 
x"53380d139d95b3df",
x"650a73548baf63de", 
x"766a0abb3c77b2a8", 
x"81c2c92e47edaee6", 
x"92722c851482353b",
x"a2bfe8a14cf10364", 
x"a81a664bbc423001", 
x"c24b8b70d0f89791", 
x"c76c51a30654be30",
x"d192e819d6ef5218", 
x"d69906245565a910", 
x"f40e35855771202a", 
x"106aa07032bbd1b8",
x"19a4c116b8d2d0c8", 
x"1e376c085141ab53", 
x"2748774cdf8eeb99", 
x"34b0bcb5e19b48a8",
x"391c0cb3c5c95a63", 
x"4ed8aa4ae3418acb", 
x"5b9cca4f7763e373", 
x"682e6ff3d6b2b8a3",
x"748f82ee5defb2fc", 
x"78a5636f43172f60", 
x"84c87814a1f0ab72", 
x"8cc702081a6439ec",
x"90befffa23631e28", 
x"a4506cebde82bde9",
x"bef9a3f7b2c67915", 
x"c67178f2e372532b",
x"ca273eceea26619c", 
x"d186b8c721c0c207", 
x"eada7dd6cde0eb1e", 
x"f57d4f7fee6ed178",
x"06f067aa72176fba", 
x"0a637dc5a2c898a6",
x"113f9804bef90dae", 
x"1b710b35131c471b",
x"28db77f523047d84", 
x"32caab7b40c72493", 
x"3c9ebe0a15c9bebc", 
x"431d67c49c100d4c",
x"4cc5d4becb3e42b6", 
x"597f299cfc657e2a", 
x"5fcb6fab3ad6faec", 
x"6c44198c4a475817",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000",
x"0000000000000000");

signal addr_tmp		:std_logic_vector(a-1 downto 0);
    
begin

	process ( clk )
	begin
		if rising_edge( clk ) then
				addr_tmp <= address;
		end if;
   end process;

one_level: if l=1 generate
	output <= my_rom(conv_integer(unsigned(addr_tmp)));
end generate;

two_level:if l=2 generate
	output(n-1 downto 0) <= my_rom(conv_integer(unsigned(addr_tmp-1)));
	output(2*n-1 downto n) <= my_rom(conv_integer(unsigned(addr_tmp)));
end generate;

four_level:if l=4 generate
	output(n-1 downto 0) <= my_rom(conv_integer(unsigned(addr_tmp-3)));
	output(2*n-1 downto n) <= my_rom(conv_integer(unsigned(addr_tmp-2)));
	output(3*n-1 downto 2*n) <= my_rom(conv_integer(unsigned(addr_tmp-1)));
	output(4*n-1 downto 3*n) <= my_rom(conv_integer(unsigned(addr_tmp)));
end generate;

five_level:if l=5 generate
	output(n-1 downto 0) <= my_rom(conv_integer(unsigned(addr_tmp-4)));
	output(2*n-1 downto n) <= my_rom(conv_integer(unsigned(addr_tmp-3)));
	output(3*n-1 downto 2*n) <= my_rom(conv_integer(unsigned(addr_tmp-2)));
	output(4*n-1 downto 3*n) <= my_rom(conv_integer(unsigned(addr_tmp-1))); 
	output(5*n-1 downto 4*n) <= my_rom(conv_integer(unsigned(addr_tmp))); 
	
end generate;

eight_level:if l=8 generate
	output(n-1 downto 0) <= my_rom(conv_integer(unsigned(addr_tmp-7)));
	output(2*n-1 downto n) <= my_rom(conv_integer(unsigned(addr_tmp-6)));
	output(3*n-1 downto 2*n) <= my_rom(conv_integer(unsigned(addr_tmp-5)));
	output(4*n-1 downto 3*n) <= my_rom(conv_integer(unsigned(addr_tmp-4)));
	output(5*n-1 downto 4*n) <= my_rom(conv_integer(unsigned(addr_tmp-3)));
	output(6*n-1 downto 5*n) <= my_rom(conv_integer(unsigned(addr_tmp-2)));
	output(7*n-1 downto 6*n) <= my_rom(conv_integer(unsigned(addr_tmp-1)));
	output(8*n-1 downto 7*n) <= my_rom(conv_integer(unsigned(addr_tmp)));
end generate;

end sha2_cons64;
