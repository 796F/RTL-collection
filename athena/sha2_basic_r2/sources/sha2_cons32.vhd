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

entity sha2_cons32 is 
generic(l:integer:=1; n :integer:=HASH_SIZE_256/SHA2_WORDS_NUM; a:integer:=LOG_2_64; r:integer:=ROUNDS_64);	
port(
	clk			:in std_logic;	
	address		: in std_logic_vector(a-1 downto 0);
  	output		: out std_logic_vector(l*n-1 downto 0));
end sha2_cons32;

architecture sha2_cons32 of sha2_cons32 is

type matrix is array (0 to r-1) of std_logic_vector(n-1 downto 0);
constant my_rom: matrix :=(
x"428a2f98",  
x"71374491",
x"b5c0fbcf", 
x"e9b5dba5", 
x"3956c25b", 
x"59f111f1",
x"923f82a4",
x"ab1c5ed5",
x"d807aa98", 
x"12835b01", 
x"243185be", 
x"550c7dc3", 
x"72be5d74", 
x"80deb1fe", 
x"9bdc06a7", 
x"c19bf174", 
x"e49b69c1", 
x"efbe4786", 
x"0fc19dc6", 
x"240ca1cc", 
x"2de92c6f", 
x"4a7484aa", 
x"5cb0a9dc", 
x"76f988da", 
x"983e5152", 
x"a831c66d", 
x"b00327c8", 
x"bf597fc7", 
x"c6e00bf3", 
x"d5a79147", 
x"06ca6351", 
x"14292967", 
x"27b70a85", 
x"2e1b2138", 
x"4d2c6dfc", 
x"53380d13", 
x"650a7354", 
x"766a0abb", 
x"81c2c92e", 
x"92722c85", 
x"a2bfe8a1", 
x"a81a664b", 
x"c24b8b70", 
x"c76c51a3", 
x"d192e819", 
x"d6990624", 
x"f40e3585", 
x"106aa070", 
x"19a4c116", 
x"1e376c08", 
x"2748774c", 
x"34b0bcb5", 
x"391c0cb3", 
x"4ed8aa4a", 
x"5b9cca4f", 
x"682e6ff3", 
x"748f82ee", 
x"78a5636f", 
x"84c87814", 
x"8cc70208", 
x"90befffa", 
x"a4506ceb", 
x"bef9a3f7", 
x"c67178f2"
);

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


end sha2_cons32;