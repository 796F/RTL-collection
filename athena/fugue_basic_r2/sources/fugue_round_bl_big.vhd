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

entity fugue_round_bl_big is
generic ( hs : integer := HASH_SIZE_512; round_style:integer:=FUGUE_ROUND_BASIC );
port (			

		mode1_n					: in std_logic;
		mode3_n					: in std_logic; 
		pad_n					: in std_logic; 
		loop_bsy 				: in std_logic;
		loop_cnt				: in std_logic_vector(1 downto 0);	
		din					: in std_logic_vector(w-1 downto 0);
		input 					: in state_big; 
		output 					: out state_big);
end fugue_round_bl_big;

architecture a1 of fugue_round_bl_big	is

signal  from_tix, from_rot_three, from_cix, to_smix, 
		from_smix, from_rot_nine, from_rot_nine_two, 
		from_rot_nine_three, from_rot_eight  : state_big;
signal p_in	:std_logic_vector(w-1 downto 0);
begin	
	
	p_in <= switch_endian_word(x=>din, width=>FUGUE_WORD_SIZE, w=>8);

	from_tix(0) <= p_in;
	from_tix(22)<= input(0) xor input(22);
	from_tix(8) <= p_in xor input(8);
	from_tix(1) <= input(24) xor input(1);
	from_tix(4) <= input(27) xor input(4);
	from_tix(7) <= input(30) xor input(7);
	
	tix_gen: for j in 0 to 35 generate
		cond1: if (j/=0) and (j/=1) and (j/=4) and (j/=7) and (j/=8) and (j/=22) generate
			from_tix(j)<=input(j);
		end generate;
	end generate;

	rot3_gen: for j in 0 to 35 generate
			from_rot_three(j) <= from_tix((36+j-3)mod 36) when ((mode1_n = '0') or (pad_n = '0')) and (loop_bsy = '0') else input((36+j-3)mod 36);
	end generate;

	from_cix(0) <=from_rot_three(4) xor from_rot_three(0);
	from_cix(18)<=from_rot_three(4) xor from_rot_three(18);
	from_cix(1) <=from_rot_three(5) xor from_rot_three(1);
	from_cix(19)<=from_rot_three(5) xor from_rot_three(19);
	from_cix(2) <=from_rot_three(6) xor from_rot_three(2);
	from_cix(20)<=from_rot_three(6) xor from_rot_three(20);

	cmix_gen: for j in 0 to 35 generate
		cond_1: if ((j>=3) and (j<=17)) or (j>=21) generate
			from_cix(j)<=from_rot_three(j);
		end generate;
	end generate;
	
	from_rot_nine(13) <=input(0) xor input(4);
	from_rot_nine(18) <=input(0) xor input(9);
	from_rot_nine(27) <=input(0) xor input(18);
	from_rot_nine(0)  <=input(0) xor input(27);

	rot9_gen: for j in 0 to 35 generate
		cond4: if (j/=0) and (j/=13) and (j/=18) and (j/=27) generate
			from_rot_nine(j)<=input((36+j-9)mod 36);
		end generate;
	end generate;
	
	from_rot_nine_two(13) <=input(0) xor input(4);
	from_rot_nine_two(19) <=input(0) xor input(10);
	from_rot_nine_two(27) <=input(0) xor input(18);
	from_rot_nine_two(0)  <=input(0) xor input(27);

	rot9_2_gen: for j in 0 to 35 generate
		cond5: if (j/=0) and (j/=13) and (j/=19) and (j/=27) generate
			from_rot_nine_two(j)<=input((36+j-9)mod 36);
		end generate;
	end generate;
	
	from_rot_nine_three(13) <=input(0) xor input(4);
	from_rot_nine_three(19) <=input(0) xor input(10);
	from_rot_nine_three(28) <=input(0) xor input(19);
	from_rot_nine_three(0)  <=input(0) xor input(27);

	rot9_3_gen: for j in 0 to 35 generate
		cond6: if (j/=0) and (j/=13) and (j/=19) and (j/=28) generate
			from_rot_nine_three(j)<=input((36+j-9)mod 36);
		end generate;
	end generate;
	
	from_rot_eight(12) <=input(0) xor input(4);
	from_rot_eight(18) <=input(0) xor input(10);
	from_rot_eight(27) <=input(0) xor input(19);
	from_rot_eight(0)  <=input(0) xor input(28);

	rot8_gen: for j in 0 to 35 generate
		cond7: if (j/=0) and (j/=12) and (j/=18) and (j/=27) generate
			from_rot_eight(j)<=input((36+j-8)mod 36);
		end generate;
	end generate;
	
	mux_gen: for j in 0 to 35 generate
		to_smix(j)<=from_cix(j) when mode3_n /= '0' else
					from_rot_nine(j) when loop_cnt = "00" else
					from_rot_nine_two(j) when loop_cnt = "01" else
					from_rot_nine_three(j) when loop_cnt = "10" else
					from_rot_eight(j);
	end generate;

basic_smix_gen: if round_style = FUGUE_ROUND_BASIC generate	
	smix: entity work.fugue_smix(basic) port map( i0 => to_smix(0), i1 => to_smix(1), i2 => to_smix(2), i3 => to_smix(3), o0 => from_smix(0), o1 => from_smix(1), o2 => from_smix(2), o3 => from_smix(3));
end generate;

tbox_smix_gen: if round_style = FUGUE_ROUND_TBOX generate	
	smix: entity work.fugue_smix(tbox) port map( i0 => to_smix(0), i1 => to_smix(1), i2 => to_smix(2), i3 => to_smix(3), o0 => from_smix(0), o1 => from_smix(1), o2 => from_smix(2), o3 => from_smix(3));
end generate;

	smix_gen: for j in 0 to 35 generate
		cond2: if (j>=4) generate
			from_smix(j)<=to_smix(j);
		end generate;
	end generate;		
	
	out_gen: for j in 0 to 35 generate
			output(j) <= from_smix(j);
	end generate;  
	
end a1;	