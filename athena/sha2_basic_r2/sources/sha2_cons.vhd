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

entity sha2_cons is 
generic(l :integer:=1; n :integer:=HASH_SIZE_256/SHA2_WORDS_NUM; a :integer:=LOG_2_64);	
port(
	clk				: in std_logic;	
	address			: in std_logic_vector(a-1 downto 0);
  	output			: out std_logic_vector(l*n-1 downto 0));
end sha2_cons;

architecture sha2_cons of sha2_cons is

constant init		:std_logic_vector(n*l-1 downto 0):=(others=>'0');	
signal buf			:std_logic_vector(n*l-1 downto 0);	

begin	   
	
a32_gen	:if n=ARCH_32 generate
	a32 : entity work.sha2_cons32(sha2_cons32) generic map (l=>l, n=>n, a=>a, r=>ROUNDS_64) port map (clk=>clk, address=>address, output=>buf);
	b32	: entity work.regn(struct) generic map (n=>n*l, init=>init) port map (clk=>clk, en=>VCC, rst=>GND,  input=>buf, output=>output );
end generate;

a64_gen	:if n=ARCH_64 generate
	a64 : entity work.sha2_cons64(sha2_cons64) generic map (l=>l, n=>n, a=>a, r=>ROUNDS_80) port map (clk=>clk, address=>address, output=>buf);	
	b64	: entity work.regn(struct) generic map (n=>n*l, init=>init) port map (clk=>clk, en=>VCC, rst=>GND, input=>buf, output=>output );
end generate;


end sha2_cons;
