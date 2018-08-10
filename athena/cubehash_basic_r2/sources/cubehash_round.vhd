-- =====================================================================
-- copyright © 2010-2011 by cryptographic engineering research group (cerg),
-- ece department, george mason university
-- fairfax, va, u.s.a.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity cubehash_round is
    port ( datain : in  std_logic_vector (1023 downto 0);
           dataout : out  std_logic_vector (1023 downto 0));
end cubehash_round;

architecture struct of cubehash_round is

	--define intermidate signals
	--signals for upper 512 bits of 1024 bit data
	signal upper1, upper2, upper3, upper4, upper5 : std_logic_vector(511 downto 0);
	--signals for lower 512 bits of 1024 bit data
	signal lower1, lower2, lower3, lower4, lower5, lower6, lower7 : std_logic_vector(511 downto 0);
	
begin

	--divide 1024 bit data into two 512 bit halfs, upper and lower
	upper1 <= datain(1023 downto 512);
	lower1 <= datain(511 downto 0);

	--step 1 add lowerstatexxxx into upperstatexxxx modulo 2^32 for each 32 bit state
	g1: for i in 0 to 15 generate
		upper2(31 + (i*32) downto 0 + (i*32)) <= upper1(31 + (i*32) downto 0 + (i*32)) + lower1(31 + (i*32) downto 0 + (i*32));
	end generate g1;

	--step2 rotate lowerstatexxxx upwards by 7 bits for each 32 bit state
	g2: for i in 0 to 15 generate
		lower2(31 + (i*32) downto 0 + (i*32)) <= lower1(24 + (i*32) downto 0 + (i*32)) & lower1(31 + (i*32) downto 25 + (i*32));
	end generate g2;

	--step3 swap lowerstate0xxx with lowerstate1xxx for each 32 bit state
	g3: for i in 0 to 7 generate
		--put lowerstates 0 to 7 into lowerstates 8 to 15
		lower3(287 + (i*32) downto 256 + (i*32)) <= lower2(31 + (i*32) downto 0 + (i*32));
		--put lowerstates 8 to 15 into lowerstates 0 to 7
		lower3(31 + (i*32) downto 0 + (i*32)) <= lower2(287 + (i*32) downto 256 + (i*32));
	end generate g3;

	--step4 xor upperstatexxxx into lowerstatexxxx for each 32 bit state
	lower4(511 downto 0) <= upper2(511 downto 0) xor lower3(511 downto 0);

	--step5 swap upperstatexx0x with upperstatexx1x for each 32 bit state
	g5: for i in 0 to 3 generate
		--put states 0,4,8,12 into states 2,6,10,14
		upper3(95 + (i*4*32) downto 64 + (i*4*32)) <= upper2(31 + (i*4*32) downto 0 + (i*4*32));
		--put states 1,5,9,13 into states 3,7,11,15
		upper3(127 + (i*4*32) downto 96 + (i*4*32)) <= upper2(63 + (i*4*32) downto 32 +(i*4*32));
		--put states 2,6,10,14 into states 0,4,8,12
		upper3(31 + (i*4*32) downto 0 + (i*4*32)) <= upper2(95 + (i*4*32) downto 64 + (i*4*32));
		--put states 3,7,11,15 into states 1,5,9,13
		upper3(63 + (i*4*32) downto 32 +(i*4*32)) <= upper2(127 + (i*4*32) downto 96 + (i*4*32));
	end generate g5;

	--step6 add lowerstatexxxx into upperstatexxxx modulo 2^32 for each 32 bit state
	g6: for i in 0 to 15 generate
		upper4(31 + (i*32) downto 0 + (i*32)) <= upper3(31 + (i*32) downto 0 + (i*32)) + lower4(31 + (i*32) downto 0 + (i*32));
	end generate g6;	
	
	--step7 rotate lowerstatexxxx upwards by 11 bits for each 32 bit state
	g7: for i in 0 to 15 generate
		lower5(31 + (i*32) downto 0 + (i*32)) <= lower4(20 + (i*32) downto 0 + (i*32)) & lower4(31 + (i*32) downto 21 + (i*32));
	end generate g7;

	--step8 swap lowerstatex0xx with lowerstatex1xx for each 32 bit state
	g8: for i in 0 to 3 generate
		--put states 0,1,2,3 into states 4,5,6,7
		lower6(159 + (i*32) downto 128 + (i*32)) <= lower5(31 + (i*32) downto 0 + (i*32));
		--put states 8,9,10,11 into states 12,13,14,15
		lower6(415 + (i*32) downto 384 + (i*32)) <= lower5(287 + (i*32) downto 256 + (i*32));
		--put states 4,5,6,7 into states 0,1,2,3
		lower6(31 + (i*32) downto 0 + (i*32)) <= lower5(159 + (i*32) downto 128 + (i*32));
		--put states 12,13,14,15 into states 8,9,10,11
		lower6(287 + (i*32) downto 256 + (i*32)) <= lower5(415 + (i*32) downto 384 + (i*32));
	end generate g8;

	--step9 xor upperstatexxxx into lowerstatexxxx for each 32 bit state
	lower7(511 downto 0) <= upper4(511 downto 0) xor lower6(511 downto 0);

	--step10 swap upperstatexxx0 with upperstatexxx1 for each 32 bit state
	g10: for i in 0 to 7 generate
		--put states 0,2,4,6,8,10,12,14 into states 1,3,5,7,9,11,13,15
		upper5(63 + (i*2*32) downto 32 + (i*2*32)) <= upper4(31 + (i*2*32) downto 0 + (i*2*32));
		--put states 1,3,5,7,9,11,13,15 into states 0,2,4,6,8,10,12,14
		upper5(31 + (i*2*32) downto 0 + (i*2*32)) <= upper4(63 + (i*2*32) downto 32 + (i*2*32));
	end generate g10;

	--recombine the upper and lower 512 data bits
	dataout <= upper5(511 downto 0) & lower7(511 downto 0);
		
end struct;

