-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;

entity sync_clock is
	generic (
	  fr : integer := 1	
	);
	port (						 
		rst		   	: in std_logic;
		fast_clock 	: in std_logic;
		slow_clock 	: in std_logic;
		sync		: out std_logic
	);
end sync_clock;

architecture struct of sync_clock is 	

	constant log2fr : integer := log2( fr );
	signal counter, start : std_logic_vector(log2fr-1 downto 0); 
	constant zero	:std_logic_vector(log2fr-1 downto 0):=(others=>'0');
begin	


	
	count_gen : countern generic map ( N => log2fr, step=>1, style=>COUNTER_STYLE_1 ) port map ( clk => fast_clock, rst=>rst, load => rst, en => '1', input => zero, output => counter );
	
	start_gen : process( slow_clock )
	begin
		if rising_edge(slow_clock) then
			if ( rst = '1' ) then
				start <= (others => '0');
			else
				start <= counter;	
			end if;
		end if;
	end process;  								
	
	sync <= '1' when ( start = counter and rst = '0') else '0';
	

end struct;