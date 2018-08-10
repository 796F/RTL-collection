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

-- possible generics values: hs = {HASH_SIZE_256, HASH_SIZE_512} 
-- round_style = {FUGUE_ROUND_BASIC, FUGUE_ROUND_TBOX}
-- all combinations are allowed

entity fugue_round_bl is
generic ( hs : integer := HASH_SIZE_256; round_style:integer:=FUGUE_ROUND_BASIC);
port (	
		mode1_n			:in std_logic;
		mode3_n			:in std_logic; 
		pad_n			:in std_logic; 
		loop_bsy 		:in std_logic;
		input 			:in state;
		output 			:out state;										  
		din				:in std_logic_vector(w-1 downto 0));
end fugue_round_bl;

architecture a1 of fugue_round_bl	is

signal from_tix, from_rot_three, from_cmix, to_smix, from_smix, from_rot_fifteen, from_rot_fourteen  : state;
signal p_in	:std_logic_vector(w-1 downto 0);

begin	

	p_in <= switch_endian_word(x=>din, width=>FUGUE_WORD_SIZE, w=>8);
	
	from_tix(0) <= p_in;
	from_tix(10)<= input(0) xor input(10);
	from_tix(8) <= p_in xor input(8);
	from_tix(1) <= input(24) xor input(1);
		
	tix_gen: for j in 0 to 29 generate
		cond1: if (j/=0) and (j/=1) and (j/=8) and (j/=10) generate
			from_tix(j)<=input(j);
		end generate;
	end generate; 
	
		
	rot3_gen: for j in 0 to 29 generate
			from_rot_three(j)<=from_tix((30+j-3)mod 30) when ((mode1_n = '0') OR (pad_n = '0')) and (loop_bsy = '0') else input((30+j-3)mod 30);
	end generate;

	from_cmix(0) <=from_rot_three(4) xor from_rot_three(0);
	from_cmix(15)<=from_rot_three(4) xor from_rot_three(15);
	from_cmix(1) <=from_rot_three(5) xor from_rot_three(1);
	from_cmix(16)<=from_rot_three(5) xor from_rot_three(16);
	from_cmix(2) <=from_rot_three(6) xor from_rot_three(2);
	from_cmix(17)<=from_rot_three(6) xor from_rot_three(17);

	cmix_gen: for j in 0 to 29 generate
		cond_1: if ((j>=3) and (j<=14)) or (j>=18) generate
			from_cmix(j)<=from_rot_three(j);
		end generate cond_1;
	end generate;
	
	from_rot_fifteen(19)<=input(0) xor input(4);
	from_rot_fifteen(0)<=input(0) xor input(15);

	rot15_gen: for j in 0 to 29 generate
		cond4: if (j/=0) and (j/=19) generate
			from_rot_fifteen(j)<=input((30+j-15)mod 30);
		end generate;
	end generate;
	
	from_rot_fourteen(18)<=input(0) xor input(4);
	from_rot_fourteen(0)<=input(0) xor input(16);

	rot14_gen: for j in 0 to 29 generate
		cond5: if (j/=0) and (j/=18) generate
			from_rot_fourteen(j)<=input((30+j-14)mod 30);
		end generate;
	end generate;
	
	mux_gen: for j in 0 to 29 generate
		to_smix(j)<=from_cmix(j) when mode3_n /= '0' else
					from_rot_fifteen(j) when loop_bsy = '0' else
					from_rot_fourteen(j);
	end generate;
 
basic_smix_gen: if round_style = FUGUE_ROUND_BASIC generate	
	smix: entity work.fugue_smix(basic) port map( i0 => to_smix(0), i1 => to_smix(1), i2 => to_smix(2), i3 => to_smix(3), o0 => from_smix(0), o1 => from_smix(1), o2 => from_smix(2), o3 => from_smix(3));
end generate;

tbox_smix_gen: if round_style = FUGUE_ROUND_TBOX generate	
	smix: entity work.fugue_smix(tbox) port map( i0 => to_smix(0), i1 => to_smix(1), i2 => to_smix(2), i3 => to_smix(3), o0 => from_smix(0), o1 => from_smix(1), o2 => from_smix(2), o3 => from_smix(3));
end generate;
		
	smix_gen: for j in 0 to 29 generate
		cond2: if (j>=4) generate
			from_smix(j)<=to_smix(j);
		end generate;
	end generate;			
	
	out_gen: for j in 0 to 29 generate
			output(j) <= from_smix(j);
	end generate;
	
	
end a1;	
