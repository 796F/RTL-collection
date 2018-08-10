-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;	
use work.fugue_pkg.all;

entity fugue_smix is
	port (	
		i0		: in std_logic_vector(w-1 downto 0);
		i1	    : in std_logic_vector(w-1 downto 0);
		i2		: in std_logic_vector(w-1 downto 0);
		i3		: in std_logic_vector(w-1 downto 0);
		o0	    : out std_logic_vector(w-1 downto 0);
		o1		: out std_logic_vector(w-1 downto 0);
		o2		: out std_logic_vector(w-1 downto 0);
		o3		: out std_logic_vector(w-1 downto 0));
end fugue_smix;

-- streightforward implementation of Super Mix operation
architecture basic of fugue_smix is	

type array16 is array (0 to 15) of std_logic_vector(7 downto 0);
signal addr, d, mul_by_four, mul_by_seven : array16;
signal d8x6, d13x6, d2x6 : std_logic_vector(7 downto 0);
signal d7x6, d12x5, d1x5, d6x5, d11x5 : std_logic_vector(7 downto 0);
	
begin

	-- input to array16 conversion
	I0boxgen: for i in 0 to 3 generate
		addr(i)<=I0(((8*i)+7) downto 8*i);
		addr(4+i)<=I1(((8*i)+7) downto 8*i);
		addr(8+i)<=I2(((8*i)+7) downto 8*i);
		addr(12+i)<=I3(((8*i)+7) downto 8*i);

	end generate I0boxgen;
		
	-- 16 AES sboxes in parallel
	sboxes: for i in 0 to 15 generate
		sboxi 	:aes_sbox port map ( input => addr(i), output => d(i));
		amb4	:entity work.aes_mul(aes_mul) generic map (cons=>4) port map (input=>d(i), output=>mul_by_four(i));
		amb7	:entity work.aes_mul(aes_mul) generic map (cons=>7) port map (input=>d(i), output=>mul_by_seven(i));

	end generate sboxes;
			
	-- 	second part of Super-Mix is multiplication by invertible matrix 
	am6a: entity work.aes_mul(aes_mul) generic map (cons=>6) port map (input=>d(2), output=>d2x6);
	am6b: entity work.aes_mul(aes_mul) generic map (cons=>6) port map (input=>d(7), output=>d7x6);
	am6c: entity work.aes_mul(aes_mul) generic map (cons=>6) port map (input=>d(8), output=>d8x6);
	am6d: entity work.aes_mul(aes_mul) generic map (cons=>6) port map (input=>d(13), output=>d13x6);

	am5a: entity work.aes_mul(aes_mul) generic map (cons=>5) port map (input=>d(1), output=>d1x5);
	am5b: entity work.aes_mul(aes_mul) generic map (cons=>5) port map (input=>d(6), output=>d6x5);
	am5c: entity work.aes_mul(aes_mul) generic map (cons=>5) port map (input=>d(11), output=>d11x5);
	am5d: entity work.aes_mul(aes_mul) generic map (cons=>5) port map (input=>d(12), output=>d12x5);

	O0(7 downto 0)  <=d(0) xor mul_by_four(1) xor mul_by_seven(2) xor d(3) xor d(4) xor d(8) xor d(12);	
	O0(15 downto 8) <=d(1) xor d(4) xor d(5) xor mul_by_four(6) xor mul_by_seven(7) xor d(9) xor d(13); 
	O0(23 downto 16)<=d(2) xor d(6) xor mul_by_seven(8)xor d(9) xor d(10) xor mul_by_four(11) xor d(14);
	O0(w-1 downto 24)<=d(3) xor d(7) xor d(11) xor mul_by_four(12) xor mul_by_seven(13)xor d(14) xor d(15);

	O1(7 downto 0)  <=mul_by_four(5) xor mul_by_seven(6) xor d(7) xor d(8) xor d(12); 
	O1(15 downto 8) <=d(1) xor d(8) xor mul_by_four(10) xor mul_by_seven(11) xor d(13);
	O1(23 downto 16)<=d(2) xor d(6) xor mul_by_seven(12) xor d(13) xor mul_by_four(15); 
	O1(w-1 downto 24)<=mul_by_four(0) xor mul_by_seven(1) xor d(2) xor d(7) xor d(11);

	O2(7 downto 0)  <=mul_by_seven(4) xor d8x6 xor mul_by_four(9) xor mul_by_seven(10) xor d(11) xor mul_by_seven(12);	 
	O2(15 downto 8) <=mul_by_seven(1) xor mul_by_seven(9) xor d(12) xor d13x6 xor mul_by_four(14) xor mul_by_seven(15);
	O2(23 downto 16)<=mul_by_seven(0) xor d(1) xor d2x6 xor mul_by_four(3) xor mul_by_seven(6) xor mul_by_seven(14);
	O2(w-1 downto 24)<=mul_by_seven(3) xor mul_by_four(4) xor mul_by_seven(5) xor d(6) xor d7x6 xor mul_by_seven(11);

	O3(7 downto 0)  <=mul_by_four(4) xor mul_by_four(8) xor d12x5 xor mul_by_four(13) xor mul_by_seven(14) xor d(15);
	O3(15 downto 8) <=d(0) xor d1x5 xor mul_by_four(2)xor mul_by_seven(3) xor mul_by_four(9) xor mul_by_four(13);
	O3(23 downto 16)<=mul_by_four(2) xor mul_by_seven(4) xor d(5) xor d6x5 xor mul_by_four(7) xor mul_by_four(14);
	O3(w-1 downto 24)<=mul_by_four(3) xor mul_by_four(7) xor mul_by_four(8) xor mul_by_seven(9) xor d(10) xor d11x5;

end basic;

-- TBOX implementation of Super Mix operation
architecture tbox of fugue_smix is	

type array16 is array (0 to 15) of std_logic_vector(7 downto 0);
type array8 is array (0 to 7) of std_logic_vector(23 downto 0);
type array4 is array (0 to 3) of std_logic_vector(31 downto 0);

signal addr : array16;
signal tbox_zero : array8;
signal tbox_one, tbox_two : array4;

begin

	-- input to array16 conversion
	I0boxgen: for i in 0 to 3 generate
		addr(i)<=I0(((8*i)+7) downto 8*i);
		addr(4+i)<=I1(((8*i)+7) downto 8*i);
		addr(8+i)<=I2(((8*i)+7) downto 8*i);
		addr(12+i)<=I3(((8*i)+7) downto 8*i);
	end generate I0boxgen;

	-- SubBytes layer combined with MicColumn layer creates Fugue Tboxes 		
	ft0_gen: entity work.fugue_tbox0(fugue_tbox0)
			port map (address=>addr(0), dout=>tbox_zero(0));	
			
	ft1_gen: entity work.fugue_tbox1(fugue_tbox1)
			port map (address=>addr(1), dout=>tbox_one(0));	
		
	ft2_gen: entity work.fugue_tbox2(fugue_tbox2)
			port map (address=>addr(2), dout=>tbox_two(0));	

	ft3_gen: entity work.fugue_tbox0(fugue_tbox0)
			port map (address=>addr(3), dout=>tbox_zero(1));	

	ft4_gen: entity work.fugue_tbox0(fugue_tbox0)
			port map (address=>addr(4), dout=>tbox_zero(2));	
			
	ft5_gen: entity work.fugue_tbox0(fugue_tbox0)
			port map (address=>addr(5), dout=>tbox_zero(3));	
		
	ft6_gen: entity work.fugue_tbox1(fugue_tbox1)
			port map (address=>addr(6), dout=>tbox_one(1));	

	ft7_gen: entity work.fugue_tbox2(fugue_tbox2)
			port map (address=>addr(7), dout=>tbox_two(1));	

	ft8_gen: entity work.fugue_tbox2(fugue_tbox2)
			port map (address=>addr(8), dout=>tbox_two(2));	
			
	ft9_gen: entity work.fugue_tbox0(fugue_tbox0)
			port map (address=>addr(9), dout=>tbox_zero(4));	
		
	ft10_gen: entity work.fugue_tbox0(fugue_tbox0)
			port map (address=>addr(10), dout=>tbox_zero(5));	

	ft11_gen: entity work.fugue_tbox1(fugue_tbox1)
			port map (address=>addr(11), dout=>tbox_one(2));	

	ft12_gen: entity work.fugue_tbox1(fugue_tbox1)
			port map (address=>addr(12), dout=>tbox_one(3));	
			
	ft13_gen: entity work.fugue_tbox2(fugue_tbox2)
			port map (address=>addr(13), dout=>tbox_two(3));	
		
	ft14_gen: entity work.fugue_tbox0(fugue_tbox0)
			port map (address=>addr(14), dout=>tbox_zero(6));	

	ft15_gen: entity work.fugue_tbox0(fugue_tbox0)
			port map (address=>addr(15), dout=>tbox_zero(7));	

	-- MixColumn operation is completed by network of xors	
	o0(7 downto 0)  <= tbox_zero(0)(23 downto 16) xor tbox_one(0)(23 downto 16) xor tbox_two(0)(7 downto 0) xor tbox_zero(1)(23 downto 16) xor tbox_zero(2)(23 downto 16) xor tbox_two(2)(31 downto 24) xor tbox_one(3)(31 downto 24);
	o0(15 downto 8) <= tbox_one(0)(31 downto 24) xor tbox_zero(2)(23 downto 16) xor tbox_zero(3)(23 downto 16) xor tbox_one(1)(23 downto 16) xor tbox_two(1)(7 downto 0) xor tbox_zero(4)(23 downto 16) xor tbox_two(3)(31 downto 24);  
	o0(23 downto 16)<= tbox_two(0)(31 downto 24) xor tbox_one(1)(31 downto 24) xor tbox_two(2)(7 downto 0) xor tbox_zero(4)(23 downto 16) xor tbox_zero(5)(23 downto 16) xor tbox_one(2)(23 downto 16) xor tbox_zero(6)(23 downto 16);
	o0(31 downto 24)<= tbox_zero(1)(23 downto 16) xor tbox_two(1)(31 downto 24) xor tbox_one(2)(31 downto 24) xor tbox_one(3)(23 downto 16) xor tbox_two(3)(7 downto 0) xor tbox_zero(6)(23 downto 16) xor tbox_zero(7)(23 downto 16);
	
	o1(7 downto 0)  <= tbox_zero(3)(15 downto 8) xor tbox_one(1)(7 downto 0) xor tbox_two(1)(31 downto 24) xor tbox_two(2)(31 downto 24) xor tbox_one(3)(31 downto 24);
	o1(15 downto 8) <= tbox_one(0)(31 downto 24) xor tbox_two(2)(31 downto 24) xor tbox_zero(5)(15 downto 8) xor tbox_one(2)(7 downto 0) xor tbox_two(3)(31 downto 24);	
	o1(23 downto 16)<= tbox_two(0)(31 downto 24) xor tbox_one(1)(31 downto 24) xor tbox_one(3)(7 downto 0) xor tbox_two(3)(31 downto 24) xor tbox_zero(7)(15 downto 8);	
	o1(31 downto 24)<= tbox_zero(0)(15 downto 8) xor tbox_one(0)(7 downto 0) xor tbox_two(0)(31 downto 24) xor tbox_two(1)(31 downto 24) xor tbox_one(2)(31 downto 24);
	
	o2(7 downto 0)  <= tbox_zero(2)(7 downto 0) xor tbox_two(2)(15 downto 8) xor tbox_zero(4)(15 downto 8) xor tbox_zero(5)(7 downto 0) xor tbox_one(2)(31 downto 24) xor tbox_one(3)(7 downto 0);
	o2(15 downto 8) <= tbox_one(0)(7 downto 0) xor tbox_zero(4)(7 downto 0) xor tbox_one(3)(31 downto 24) xor tbox_two(3)(15 downto 8) xor tbox_zero(6)(15 downto 8) xor tbox_zero(7)(7 downto 0);
	o2(23 downto 16)<= tbox_zero(0)(7 downto 0) xor tbox_one(0)(31 downto 24) xor tbox_two(0)(15 downto 8) xor tbox_zero(1)(15 downto 8) xor tbox_one(1)(7 downto 0) xor tbox_zero(6)(7 downto 0);
	o2(31 downto 24)<= tbox_zero(1)(7 downto 0) xor tbox_zero(2)(15 downto 8) xor tbox_zero(3)(7 downto 0) xor tbox_one(1)(31 downto 24) xor tbox_two(1)(15 downto 8) xor tbox_one(2)(7 downto 0);

	o3(7 downto 0)  <= tbox_zero(2)(15 downto 8) xor tbox_two(2)(23 downto 16) xor tbox_one(3)(15 downto 8) xor tbox_two(3)(23 downto 16) xor tbox_zero(6)(7 downto 0) xor tbox_zero(7)(23 downto 16);
	o3(15 downto 8) <= tbox_zero(0)(23 downto 16) xor tbox_one(0)(15 downto 8) xor tbox_two(0)(23 downto 16) xor tbox_zero(1)(7 downto 0) xor tbox_zero(4)(15 downto 8) xor tbox_two(3)(23 downto 16);
	o3(23 downto 16)<=tbox_two(0)(23 downto 16) xor tbox_zero(2)(7 downto 0) xor tbox_zero(3)(23 downto 16) xor tbox_one(1)(15 downto 8) xor tbox_two(1)(23 downto 16) xor tbox_zero(6)(15 downto 8);
	o3(31 downto 24)<= tbox_zero(1)(15 downto 8) xor tbox_two(1)(23 downto 16) xor tbox_two(2)(23 downto 16) xor tbox_zero(4)(7 downto 0) xor tbox_zero(5)(23 downto 16) xor tbox_one(2)(15 downto 8);



end tbox;


