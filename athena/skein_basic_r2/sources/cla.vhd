-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

-- carry look-ahead adder for 64-bits

---------------------
---- CLA LEVEL 1
---------------------

library ieee;
use ieee.std_logic_1164.all;   

entity cla_gen_4 is 
	port(
		p_in	:in std_logic_vector(3 downto 0);
		g_in	:in std_logic_vector(3 downto 0);
		c0		:in std_logic;
		pg_out	:out std_logic;
		gg_out	:out std_logic;
		c_out	:out std_logic_vector(3 downto 0));
end cla_gen_4;

architecture struct of cla_gen_4 is 
	signal	g		:std_logic_vector(3 downto 0); -- generate
	signal	p		:std_logic_vector(3 downto 0); -- propagate
	signal	c_wire	:std_logic_vector(3 downto 0); -- propagate

begin
	p <= p_in;
	g <= g_in;
	c_wire(3) <= g(2) or (g(1) and p(2)) or (g(0) and p(1) and p(2)) or (c_wire(0) and p(0) and p(1) and p(2));
	c_wire(2) <= g(1) or (g(0) and p(1)) or (c_wire(0) and p(0) and p(1));
	c_wire(1) <= g(0) or (c_wire(0) and p(0)); 
	c_wire(0) <= c0;

	c_out <= c_wire(3 downto 0);

	pg_out <= p(0) and p(1)  and p(2) and p(3);
	gg_out <= g(3) or (g(2) and p(3)) or (g(1) and p(2) and p(3)) or (g(0) and p(1) and p(2) and p(3));

end struct;

---------------------
---- CLA LEVEL 2
---------------------

library ieee;
use ieee.std_logic_1164.all;

entity cla_gen_16 is
	port(
	p_in	:in std_logic_vector(15 downto 0);
	g_in	:in std_logic_vector(15 downto 0);
	c0		:in std_logic;
	pg_out	:out std_logic;
	gg_out	:out std_logic;
	c_out	:out std_logic_vector(15 downto 0));
end cla_gen_16;

architecture struct of cla_gen_16 is 
	signal c_wire	:std_logic_vector(3 downto 0);
	signal pg_wire	:std_logic_vector(3 downto 0);
	signal gg_wire	:std_logic_vector(3 downto 0);
	signal pg_new	:std_logic;
	signal gg_new	:std_logic;
	signal cc_out	:std_logic_vector(15 downto 0);
begin

	cla_gen: for i in 0 to 3 generate
		cla: entity work.cla_gen_4(struct) port map (p_in=>p_in(4*i+3 downto 4*i), g_in=>g_in(4*i+3 downto 4*i), c0=>c_wire(i), pg_out=>pg_wire(i), gg_out=>gg_wire(i), c_out=>cc_out(4*i+3 downto 4*i));
	end generate;

	cla_5: 	entity work.cla_gen_4(struct) port map (p_in=>pg_wire, g_in=>gg_wire, c0=>c0, pg_out=>pg_new, gg_out=>gg_new, c_out=>c_wire);
	
	gg_out <= gg_new;
	pg_out <= pg_new;

	c_out <=  cc_out;

end struct;

---------------------
---- CLA 16
---------------------

library ieee;
use ieee.std_logic_1164.all;

entity cla_16 is
	port(
		a		: in std_logic_vector(15 downto 0);
		b		: in std_logic_vector(15 downto 0);
		s		: out std_logic_vector(15 downto 0));
end cla_16;

architecture struct of cla_16 is  
	signal c0 		: std_logic;
	signal p_in		:std_logic_vector(15 downto 0);
	signal g_in		:std_logic_vector(15 downto 0);
	signal c_wire	:std_logic_vector(3 downto 0);
	signal pg_wire	:std_logic_vector(3 downto 0);
	signal gg_wire	:std_logic_vector(3 downto 0);
	signal pg_new	:std_logic;
	signal gg_new	:std_logic;
	signal cc_out	:std_logic_vector(15 downto 0);
begin
	c0 <= '0';
	p_in <= a xor b;
	g_in <= a and b;
	
	cla_gen: for i in 0 to 3 generate
		cla: entity work.cla_gen_4(struct) port map (p_in=>p_in(4*i+3 downto 4*i), g_in=>g_in(4*i+3 downto 4*i), c0=>c_wire(i), pg_out=>pg_wire(i), gg_out=>gg_wire(i), c_out=>cc_out(4*i+3 downto 4*i));
	end generate;

	cla_5: 	entity work.cla_gen_4(struct) port map (p_in=>pg_wire, g_in=>gg_wire, c0=>c0, pg_out=>pg_new, gg_out=>gg_new, c_out=>c_wire);
	
	s <= p_in xor cc_out;
end struct;


---------------------
---- CLA 32
---------------------

library ieee;
use ieee.std_logic_1164.all;

entity cla_32 is 
	port(
		a	:in std_logic_vector(31 downto 0);
		b	:in std_logic_vector(31 downto 0);
		s	:out std_logic_vector(31 downto 0));
end cla_32;

architecture struct of cla_32 is 

	signal c_wire	:std_logic_vector(3 downto 0);
	signal p_wire	:std_logic_vector(3 downto 0);
	signal g_wire	:std_logic_vector(3 downto 0);
	signal c_sum	:std_logic_vector(31 downto 0);
	signal p_in		:std_logic_vector(31 downto 0);
	signal g_in		:std_logic_vector(31 downto 0);
	signal c0 		:std_logic;
	signal pg_out	:std_logic;
	signal gg_out	:std_logic;


begin
	c0 <='0';
	p_in <= a xor b;
	g_in <= a and b;

	cla_gen : for i in 0 to 1 generate 
		cla_16	: 		entity work.cla_gen_16(struct) 	port map (p_in=>p_in(16*i+15 downto 16*i), g_in=>g_in(16*i+15 downto 16*i), c0=>c_wire(i), pg_out=>p_wire(i), gg_out=>g_wire(i),  c_out=>c_sum(16*i+15 downto 16*i));
	end generate; 

	cla_64	:		entity work.cla_gen_4(struct)	port map (p_in=>p_wire, g_in=>g_wire, c0=>c0, pg_out=>pg_out, gg_out=>gg_out, c_out=>c_wire);

	s <= p_in xor c_sum;
end struct;


---------------------
---- CLA 64
---------------------

library ieee;
use ieee.std_logic_1164.all;

entity cla_64 is 
	port(
		a	:in std_logic_vector(63 downto 0);
		b	:in std_logic_vector(63 downto 0);
		s	:out std_logic_vector(63 downto 0));
end cla_64;

architecture struct of cla_64 is 

	signal c_wire	:std_logic_vector(3 downto 0);
	signal p_wire	:std_logic_vector(3 downto 0);
	signal g_wire	:std_logic_vector(3 downto 0);
	signal c_sum	:std_logic_vector(63 downto 0);
	signal p_in		:std_logic_vector(63 downto 0);
	signal g_in		:std_logic_vector(63 downto 0);
	signal c0 		:std_logic;
	signal	pg_out	:std_logic;
	signal	gg_out	:std_logic;
begin
	c0 <='0';
	p_in <= a xor b;
	g_in <= a and b;

	cla_gen : for i in 0 to 3 generate 
		cla_16	: 		entity work.cla_gen_16(struct) 	port map (p_in=>p_in(16*i+15 downto 16*i), g_in=>g_in(16*i+15 downto 16*i), c0=>c_wire(i), pg_out=>p_wire(i), gg_out=>g_wire(i),  c_out=>c_sum(16*i+15 downto 16*i));
	end generate; 

	cla_64	:		entity work.cla_gen_4(struct)	port map (p_in=>p_wire, g_in=>g_wire, c0=>c0, pg_out=>pg_out, gg_out=>gg_out, c_out=>c_wire);

	s <= p_in xor c_sum;
end struct;
