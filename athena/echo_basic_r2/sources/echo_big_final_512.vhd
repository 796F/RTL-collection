-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 
use work.echo_pkg.all;

-- combinational implementation of BigFinal function for 512-bit variant
entity echo_big_final_512 is
port(
	cv_old			: in std_logic_vector (ECHO_STATE_SIZE-ECHO_DATA_SIZE_SMALL-1 downto 0);
	input 				: in std_logic_vector (ECHO_STATE_SIZE-1 downto 0);
	cv_new			: out std_logic_vector (ECHO_STATE_SIZE-ECHO_DATA_SIZE_SMALL-1 downto 0));
end echo_big_final_512;

architecture echo_big_final_512 of echo_big_final_512 is

type b1 is array (7 downto 0) of std_logic_vector (ECHO_QWORD_SIZE-1 downto 0);
type b3 is array (ECHO_STATE_SIZE/ECHO_QWORD_SIZE-1 downto 0) of std_logic_vector (ECHO_QWORD_SIZE-1 downto 0); 
signal cv, temp	:b1;
signal win	:b3;

begin	 	
	
	l0: for i in 0 to 7 generate
		cv(i) <= cv_old((i+1)*128-1 downto i*128);		
	end generate;
		
	l1: for k in 0 to ECHO_STATE_SIZE/ECHO_QWORD_SIZE-1 generate
		win(k) <= input((k+1)*ECHO_QWORD_SIZE-1 downto k*ECHO_QWORD_SIZE);
	end generate;
	
	l2: for i in 0 to 7 generate
		temp(i) <= cv(i) xor win(i) xor win(i+8);
	end generate;

	cv_new <= temp(7) & temp(6) & temp(5) & temp(4) & temp(3) & temp(2) & temp(1) & temp(0);
	
end echo_big_final_512;