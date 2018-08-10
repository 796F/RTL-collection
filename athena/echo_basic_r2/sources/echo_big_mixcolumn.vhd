-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;
use work.echo_pkg.all;

-- combinational implementation of BigMixColumn function 
entity echo_big_mixcolumn is
port(
	input	:in std_logic_vector(ECHO_STATE_SIZE-1 downto 0);
	output	:out std_logic_vector(ECHO_STATE_SIZE-1 downto 0));

end echo_big_mixcolumn;

architecture echo_big_mixcolumn of echo_big_mixcolumn is

type bmc is array (4*ECHO_STATE_SIZE/ECHO_QWORD_SIZE-1 downto 0) of std_logic_vector (ECHO_QWORD_SIZE/4-1 downto 0);
signal mc_in, mc_out	:bmc;

begin	 	

o1l :for j in 0 to 3 generate
	i1l : for i in 0 to ECHO_STATE_SIZE/ECHO_QWORD_SIZE-1 generate
		mc_in(16*j+i)(31 downto 24) <= input((4*j+3)*ECHO_QWORD_SIZE+8*i+7 downto (4*j+3)*ECHO_QWORD_SIZE+8*i);
		mc_in(16*j+i)(23 downto 16) <= input((4*j+2)*ECHO_QWORD_SIZE+8*i+7 downto (4*j+2)*ECHO_QWORD_SIZE+8*i);
		mc_in(16*j+i)(15 downto 8) <= input((4*j+1)*ECHO_QWORD_SIZE+8*i + 7 downto (4*j+1)*ECHO_QWORD_SIZE+8*i);
		mc_in(16*j+i)(7 downto 0) <= input ((4*j)*ECHO_QWORD_SIZE+8*i+7 downto (4*j)*ECHO_QWORD_SIZE+8*i);	
	end generate;
end generate;

ml : for i in 0 to 4*ECHO_STATE_SIZE/ECHO_QWORD_SIZE-1 generate
mc0	: aes_mixcolumn port map (input=>mc_in(i), output=>mc_out(i));
end generate;


o2l :for j in 0 to 3 generate
	i2l : for i in 0 to ECHO_STATE_SIZE/ECHO_QWORD_SIZE-1 generate
		output((4*j)*ECHO_QWORD_SIZE+8*i+7 downto (4*j)*ECHO_QWORD_SIZE+8*i) <= mc_out(16*j+i)(7 downto 0);	
		output((4*j+1)*ECHO_QWORD_SIZE+8*i + 7 downto (4*j+1)*ECHO_QWORD_SIZE+8*i) <= mc_out(16*j+i)(15 downto 8);
		output((4*j+2)*ECHO_QWORD_SIZE+8*i+7 downto (4*j+2)*ECHO_QWORD_SIZE+8*i) <= mc_out(16*j+i)(23 downto 16);
		output((4*j+3)*ECHO_QWORD_SIZE+8*i+7 downto (4*j+3)*ECHO_QWORD_SIZE+8*i) <= mc_out(16*j+i)(31 downto 24);
	end generate;
end generate;
	
end echo_big_mixcolumn;