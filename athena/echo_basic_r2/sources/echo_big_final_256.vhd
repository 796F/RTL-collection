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

-- combinational implementation of BigFinal function for 256-bit variant
entity echo_big_final_256 is
port(
	cv_old			: in std_logic_vector (ECHO_STATE_SIZE-ECHO_DATA_SIZE_BIG-1 downto 0);
	input 			: in std_logic_vector (ECHO_STATE_SIZE-1 downto 0);
	cv_new			: out std_logic_vector (ECHO_STATE_SIZE-ECHO_DATA_SIZE_BIG-1 downto 0));
end echo_big_final_256;

architecture echo_big_final_256 of echo_big_final_256 is

type b1 is array (3 downto 0) of std_logic_vector (ECHO_QWORD_SIZE-1 downto 0);
type b2 is array (ECHO_STATE_SIZE/ECHO_QWORD_SIZE-1 downto 0) of std_logic_vector (ECHO_QWORD_SIZE-1 downto 0);
signal cv, temp	:b1;
signal win	:b2;

begin	 	
	
	l0: for i in 0 to (ECHO_STATE_SIZE-ECHO_DATA_SIZE_BIG)/ECHO_QWORD_SIZE-1 generate
		cv(i) <= cv_old((i+1)*ECHO_QWORD_SIZE-1 downto i*ECHO_QWORD_SIZE);		
	end generate;
		
	l1: for i in 0 to ECHO_STATE_SIZE/ECHO_QWORD_SIZE-1 generate
		win(i) <= input((i+1)*ECHO_QWORD_SIZE-1 downto i*ECHO_QWORD_SIZE);
	end generate;
	
	temp(0) <= cv(0) xor win(0) xor win(4) xor win(8) xor win(12);
	temp(1) <= cv(1) xor win(1) xor win(5) xor win(9) xor win(13);
	temp(2) <= cv(2) xor win(2) xor win(6) xor win(10) xor win(14);
	temp(3) <= cv(3) xor win(3) xor win(7) xor win(11) xor win(15);	  	
	
	cv_new <= temp(3) & temp(2) & temp(1) & temp(0);
		
end echo_big_final_256;