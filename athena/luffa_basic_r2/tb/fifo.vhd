-- =====================================================================
-- Copyright © 2010-11 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;  
use ieee.std_logic_unsigned.all;
use work.sha_tb_pkg.all;

entity fifo is
generic (
	fifo_mode		: integer := ZERO_WAIT_STATE;
	fifo_style		: integer := BRAM;
	depth 			: integer := 512;	
	log2depth 		: integer := 9;
	n 				: integer := 64);
port (
	clk				: in std_logic;
	rst				: in std_logic;
	write			: in std_logic; 
	read			: in std_logic;
	din 			: in std_logic_vector(n-1 downto 0);
	dout	 		: out std_logic_vector(n-1 downto 0);
	full			: out std_logic; 
	empty 			: out std_logic);
end fifo;

architecture fifo of fifo is 
begin 	   

no_pf:	if ((fifo_mode=ZERO_WAIT_STATE) and (fifo_style=DISTRIBUTED)) or (fifo_mode=ONE_WAIT_STATE) generate 
f0_ws	:	entity work.fifo(no_prefetch) 
			generic map (fifo_mode=>fifo_mode, depth=>depth, log2depth=>log2depth, n=>n) 
			port map	(clk=>clk, rst=>rst, write=>write, read=>read, din=>din, dout=>dout, full=>full, empty=>empty);	
end generate;

pf:	if (fifo_mode=ZERO_WAIT_STATE) and (fifo_style=BRAM) generate 
f0_ws_pf	:	entity work.fifo(prefetch) 
			generic map (fifo_mode=>fifo_mode, depth=>depth, log2depth=>log2depth, n=>n) 
			port map	(clk=>clk, rst=>rst, write=>write, read=>read, din=>din, dout=>dout, full=>full, empty=>empty);	
end generate;

end fifo;	

architecture prefetch of fifo is
	signal readpointer  : std_logic_vector(log2depth-1 downto 0);
	signal writepointer : std_logic_vector(log2depth-1 downto 0);
	signal bytecounter  : std_logic_vector(log2depth downto 0);
	
	signal wr_en_s : std_logic;
	signal fifo_full_s    : std_logic;
	signal fifo_empty_s   : std_logic;
	
	signal read_ok : std_logic;
	signal read_address : std_logic_vector(log2depth-1 downto 0);  
	
	signal dataout : std_logic_vector(n-1 downto 0); 
	
begin		 
	
	fiforam: fifo_ram
	generic map(	   
		fifo_style => fifo_style,
		depth => depth,
		log2depth => log2depth,
		n => n
	)
	port map(
			clk => clk,
			write => wr_en_s,
			wr_addr => writepointer,
			rd_addr => read_address,
			din => din,
			dout => dout
	);	

	reg: process(clk,rst)
	begin
		if (rst = '1') then
			readpointer  <= (others => '0');
			writepointer <= (others => '0'); 
			bytecounter  <= (others => '0');  --remainder (write pointer - read pointer)
		elsif rising_edge( clk ) then
			readpointer <= read_address;
			if ( read_ok = '1' and write = '0') then
				bytecounter  <= bytecounter - 1;
			elsif ( read_ok = '1' and write = '1' and fifo_full_s = '0') then
				writepointer <= writepointer + 1;
			elsif ( read_ok = '1' and write = '1' and fifo_full_s = '1') then	-- cant write
				bytecounter <= bytecounter - 1;
			elsif ( read_ok = '0' and write = '1' and fifo_full_s = '0') then -- cant read
				writepointer <= writepointer + 1;
				bytecounter <= bytecounter + 1;			
			end if;
		end if;
	end process;					
	
	read_ok <= read and (not fifo_empty_s);
	read_address <= (readpointer + 1) when (read_ok = '1') else readpointer;
	
	fifo_empty_s <= '1' when (bytecounter = 0) else  '0';
	fifo_full_s  <= bytecounter(log2depth);

	full  <= fifo_full_s;
	empty <= fifo_empty_s;

	wr_en_s <= '1' when ( write = '1' and fifo_full_s = '0') else '0';
end prefetch;


architecture no_prefetch of fifo is

	signal readpointer  	: std_logic_vector(log2depth-1 downto 0);
	signal writepointer 	: std_logic_vector(log2depth-1 downto 0);
	signal bytecounter  	: std_logic_vector(log2depth downto 0);
	signal write_s 			: std_logic;
	signal full_s    	: std_logic;
	signal empty_s   	: std_logic;
	signal dout_s 		: std_logic_vector(N-1 downto 0);  

begin		 
	
	fiforam: fifo_ram
	generic map(
		fifo_style=>fifo_style,
		depth => depth,
		log2depth => log2depth,
		n => n
	)
	port map(
		clk => clk,
		write => write_s,
		wr_addr => writepointer,
		rd_addr => readpointer,
		din => din,
		dout => dout
	);	

	process(clk,rst)
	begin
		if (rst = '1') then
			readpointer  <= (others => '0');
			writepointer <= (others => '0'); 
			bytecounter  <= (others => '0');  --differences (write pointer - read pointer)
		elsif(clk'event and clk = '1') then
			if ( write = '1' and full_s = '0' and read = '0') then
				writepointer <= writepointer + 1;
				bytecounter  <= bytecounter + 1;
			elsif ( read = '1' and empty_s = '0' and write = '0') then
				readpointer  <= readpointer + 1;
				bytecounter  <= bytecounter - 1;
			elsif ( read = '1' and empty_s = '0' and write = '1' and full_s = '0') then
				readpointer <= readpointer + 1;
				writepointer <= writepointer + 1;
			elsif ( read = '1' and empty_s = '0' and write = '1' and full_s = '1') then	-- cant write
				readpointer <= readpointer + 1;
				bytecounter <= bytecounter - 1;
			elsif ( read = '1' and empty_s = '1' and write = '1' and full_s = '0') then -- cant read
				writepointer <= writepointer + 1;
				bytecounter <= bytecounter + 1;

				
			end if;
		end if;
	end process;

	empty_s <= '1' when (bytecounter = 0) else  '0';
	full_s  <= bytecounter(log2depth);

	full  <= full_s;
	empty <= empty_s;

	write_s <= '1' when ( write = '1' and full_s = '0') else '0';

end no_prefetch;
