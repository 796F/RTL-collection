--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
library work;


entity jh_mds is
   port(
	a: in std_logic_vector(3 downto 0);
	b: in std_logic_vector(3 downto 0);
	c: out std_logic_vector(3 downto 0);
	d: out std_logic_vector(3 downto 0)

   );
end jh_mds;


--signal declaration
architecture rtl of jh_mds is
-- /*The linear transformation L, the MDS code*/
--#define L(a, b) {                                                       \
--      (b) ^= ( ( (a) << 1) ^ ( (a) >> 3) ^ (( (a) >> 2) & 2) ) & 0xf;   \
--      (a) ^= ( ( (b) << 1) ^ ( (b) >> 3) ^ (( (b) >> 2) & 2) ) & 0xf;   \


begin  
	d <= (a(2) xor b(3)) & 
		 (a(1) xor b(2)) & 
		 (a(0) xor a(3) xor b(1)) & 
		 (a(3) xor b(0));
	   
	c <= ((a(1) xor a(3)) xor b(2)) &
		 ((a(0) xor a(2)) xor (a(3) xor b(1))) & 
		 (((a(1) xor a(2)) xor (a(3) xor b(0))) xor b(3)) &
		 ((a(0) xor a(2)) xor b(3));
end rtl;