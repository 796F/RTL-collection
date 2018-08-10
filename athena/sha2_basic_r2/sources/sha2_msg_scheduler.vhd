-- =====================================================================
-- Copyright © 2010-11 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.sha2_pkg.all;

entity sha2_msg_scheduler is 
generic( l: integer:=1; n : integer :=HASH_SIZE_256/SHA2_WORDS_NUM);
port(
	clk			: in std_logic;
	sel			: in std_logic;
	wr_data		: in std_logic;
	data		: in std_logic_vector(n-1 downto 0);
	w			: out std_logic_vector(l*n-1 downto 0));
end sha2_msg_scheduler;

architecture sha2_msg_scheduler of sha2_msg_scheduler is				 

type matrix is array (0 to 16) of std_logic_vector(n-1 downto 0);
signal wires	: matrix;

signal wwires		: std_logic_vector(n-1 downto 0);

signal d_one_wire 	: std_logic_vector(n-1 downto 0);
signal d_zero_wire	: std_logic_vector(n-1 downto 0);  


begin

	wires(0) <= wwires when sel='1' else data;

rg	: for i in 0 to 15 generate
		regs: Process(clk)
		begin		
			
			if (clk'event and clk = '1') then
					if (wr_data = '1') then
						wires(i+1)<=wires(i);
					end if;
				end if;   
		end process;	  
end generate;	

sigma256_gen : if n=HASH_SIZE_256/STATE_REG_NUM generate
d0	: entity work.sha2_sigma_func(sha2_sigma_func)  	generic map (n=>n, func=>"ms", a=>ARCH32_MS0_1, b=>ARCH32_MS0_2, c=>ARCH32_MS0_3) port map (x=>wires(15), o=>d_zero_wire);
d1	: entity work.sha2_sigma_func(sha2_sigma_func)  	generic map (n=>n, func=>"ms", a=>ARCH32_MS1_1, b=>ARCH32_MS1_2, c=>ARCH32_MS1_3) port map (x=>wires(2), o=>d_one_wire);
end generate;
	
sigma512_gen : if n=HASH_SIZE_512/STATE_REG_NUM generate
d0	: entity work.sha2_sigma_func(sha2_sigma_func)  	generic map (n=>n, func=>"ms", a=>ARCH64_MS0_1, b=>ARCH64_MS0_2, c=>ARCH64_MS0_3) port map (x=>wires(15), o=>d_zero_wire);
d1	: entity work.sha2_sigma_func(sha2_sigma_func)  	generic map (n=>n, func=>"ms", a=>ARCH64_MS1_1, b=>ARCH64_MS1_2, c=>ARCH64_MS1_3) port map (x=>wires(2), o=>d_one_wire);
end generate;


wwires <= wires(7) + wires(16) + d_zero_wire + d_one_wire;

output: for i in 1 to l generate 
	w((i*n-1) downto (i-1)*n) <= wires(i);
end generate;	

end sha2_msg_scheduler;


architecture mc_evoy of sha2_msg_scheduler is				 

type matrix is array (0 to 16) of std_logic_vector(n-1 downto 0);
signal wires		: matrix;
signal wwires			: std_logic_vector(n-1 downto 0);
signal d_one_wire 		: std_logic_vector(n-1 downto 0);
signal d_zero_wire		: std_logic_vector(n-1 downto 0);  
signal first_stage		: std_logic_vector(n-1 downto 0);  
signal to_second_stage	: std_logic_vector(n-1 downto 0);  
signal second_stage		: std_logic_vector(n-1 downto 0);  
signal to_third_stage	: std_logic_vector(n-1 downto 0); 
signal init_data		: std_logic_vector(n-1 downto 0);					
constant zero 			: std_logic_vector(n-1 downto 0):=(others=>'0');
begin
	init_data <= (others=>'0');

--m0		:  muxn generic map (n=> n)port map (sel=>sel, a=>data, b=>wwires, o=>wires(0));
		wires(0) <= wwires when sel='1' else data;


rg	: for i in 0 to 15 generate
		regs: Process(clk)
		begin		

			
			if (clk'event and clk = '1') then
					if (wr_data = '1') then
						wires(i+1)<=wires(i);
					end if;
				end if;   
		end process;	  
end generate;	

a32: if n=ARCH_32 generate
d0	: entity work.sha2_sigma_func(sha2_sigma_func)  	generic map (n=>n, func=>"ms", a=>ARCH32_MS0_1, b=>ARCH32_MS0_2, c=>ARCH32_MS0_3) port map (x=>wires(13), o=>d_zero_wire);
d1	: entity work.sha2_sigma_func(sha2_sigma_func)  	generic map (n=>n, func=>"ms", a=>ARCH32_MS1_1, b=>ARCH32_MS1_2, c=>ARCH32_MS1_3) port map (x=>wires(2), o=>d_one_wire);
end generate;

a64: if n=ARCH_64 generate
d0	: entity work.sha2_sigma_func(sha2_sigma_func)  	generic map (n=>n, func=>"ms", a=>ARCH64_MS0_1, b=>ARCH64_MS0_2, c=>ARCH64_MS0_3) port map (x=>wires(13), o=>d_zero_wire);
d1	: entity work.sha2_sigma_func(sha2_sigma_func)  	generic map (n=>n, func=>"ms", a=>ARCH64_MS1_1, b=>ARCH64_MS1_2, c=>ARCH64_MS1_3) port map (x=>wires(2), o=>d_one_wire);
end generate;

first_stage <= d_zero_wire + wires(14);

reg01	: entity work.regn(struct) generic map (n=>n, init=>zero) port map(clk=>clk, en=>VCC, rst=>GND, input=>first_stage, output=>to_second_stage);

second_stage <= to_second_stage + wires(6);

reg02	: entity work.regn(struct) generic map (n=>n, init=>zero) port map(clk=>clk, en=>VCC, rst=>GND, input=>second_stage, output=>to_third_stage);

wwires <= to_third_stage + d_one_wire;

output: for i in 1 to l generate 
	w((i*n-1) downto (i-1)*n) <= wires(i);
end generate;	


end mc_evoy;

