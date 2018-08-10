-- =====================================================================
-- Copyright © 2010-11 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;
use work.sha_tb_pkg.all;

entity fifo_ram is
generic ( 	
	fifo_style		: integer := BRAM;	
	depth 			: integer := 512;
	log2depth  		: integer := 9;
	n 				: integer := 64 );	
port ( 	
	clk 			: in  std_logic;
	write 			: in  std_logic;
	rd_addr 		: in  std_logic_vector (log2depth-1 downto 0);
	wr_addr 		: in  std_logic_vector (log2depth-1 downto 0);
	din 			: in  std_logic_vector (n-1 downto 0);
	dout 			: out std_logic_vector (n-1 downto 0));
end fifo_ram;

architecture fifo_ram of fifo_ram is
	type 	mem is array (depth-1 downto 0) of std_logic_vector(n-1 downto 0);
	signal 	memory 		: mem;
	signal 	tmp_addr 	: std_logic_vector(log2depth-1 downto 0);
	signal 	zero		: std_logic_vector(log2depth-1 downto 0);
begin									
	
	w0: if (fifo_style = DISTRIBUTED) generate
		process(clk)
		begin
			if ( rising_edge(clk) ) then
				if (write = '1') then
					memory(conv_integer(unsigned(wr_addr))) <= din;
				end if;	 
			end if;
		end process; 
		
		tmp_addr <= rd_addr;
		dout <= memory(conv_integer(unsigned(tmp_addr)));
	end generate;
	
	

	w1: if (fifo_style = BRAM) generate
		process(clk)
		begin
			if ( rising_edge(clk) ) then
				if (write = '1') then
					memory(conv_integer(unsigned(wr_addr))) <= din;
				end if;	 
				tmp_addr <= rd_addr;
			end if;
		end process; 
		
		dout <= memory(conv_integer(unsigned(tmp_addr)));
	end generate;

end fifo_ram;

