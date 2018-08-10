-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.echo_pkg.all;

-- possible generics values: 
-- hs = {HASH_SIZE_256, HASH_SIZE_512},  

entity echo_flags is 
generic (hs : integer :=HASH_SIZE_256);	
port 
(
	clk			:in std_logic;
	rst			:in std_logic;
	len			:in std_logic_vector(w-1 downto 0);
	ctr			:in std_logic_vector(w-1 downto 0);
	din			:in std_logic_vector(w-1 downto 0);
	end_flag	:in std_logic_vector(15 downto 0);
	last_block	:out std_logic;
	underflow	:out std_logic;
	key			:out std_logic_vector(w-1 downto 0));
end echo_flags;

architecture echo_flags of echo_flags is 
constant zero	: std_logic_vector(w-1 downto 0):=(others=>'0');
signal uf_wire, uf_wire_in	:std_logic;
signal lb_wire, lb_wire_in	:std_logic;	

begin 	   
	-- detection of underflow and last block
flags_256_gen : if hs=HASH_SIZE_256 generate	
	uf_wire_in <= '1' when ((din + x"600") <= len) and ((din + x"680")>=len)   else '0';
	lb_wire_in <= '1' when (ctr >= len)   else '0';
	
end generate;		
		
flags_512_gen : if hs=HASH_SIZE_512 generate	
	uf_wire_in <= '1' when ((din + x"400") <= len) and ((din + x"480")>=len)   else '0';
	lb_wire_in <= '1' when (ctr >= len)   else '0';
end generate;		


	d0	: d_ff port map (clk=>clk, ena=>'1', rst=>rst, d=>uf_wire_in, q=> uf_wire);
	d1	: d_ff port map (clk=>clk, ena=>'1', rst=>rst, d=>lb_wire_in, q=> lb_wire);

	key <= 	ctr  when (uf_wire= '0') and (lb_wire='0') else
			din when (uf_wire= '1') and (lb_wire='0') else	
			din when (uf_wire= '0') and (lb_wire='1') else	
			zero;

	underflow <= uf_wire;
	last_block	<= lb_wire; 

end echo_flags;

