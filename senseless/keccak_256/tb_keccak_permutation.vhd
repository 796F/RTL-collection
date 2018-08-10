--  
-- Copyright (c) 2018 Allmine Inc
--

 library work;
	use work.keccak_globals.all;
library std;
	use std.textio.all;
	
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_misc.all;
	use ieee.std_logic_arith.all;
	use ieee.std_logic_textio.all;
	use ieee.std_logic_unsigned."+"; 


entity keccak_tb is
end keccak_tb;
	
architecture tb of keccak_tb is


-- components

component keccak  
  port (
    clk     : in  std_logic;
    state_in     : in  std_logic_vector(1599 downto 0);
    nonce_in     : in  std_logic_vector(size_nonce-1 downto 0);
    padding_byte     : in  std_logic_vector(7 downto 0);
    dout    : out std_logic_vector(255 downto 0)
	);

end component;


  -- signal declarations

signal clk : std_logic;
signal state_in : std_logic_vector (1599 downto 0);  
signal nonce_in: std_logic_vector ( size_nonce-1 downto 0);

signal padding_byte : std_logic_vector(7 downto 0);
signal dout : std_logic_vector (255 downto 0);
signal rst_n : std_logic;

 type st_type is (st0,st1,STOP);
 signal st : st_type;
 signal counter : unsigned(4 downto 0);
 
begin  -- Rtl

-- port map

coremap : keccak port map(clk,state_in, nonce_in, padding_byte, dout);


state_in <= x"6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" after 0 ns;
nonce_in <= x"61616161" after 0 ns;
padding_byte <= x"01" after 0 ns;
--main process

rst_n <= '0', '1' after 19 ns;

tbgen : process(clk)
				
	variable line_in : line;
	variable line_out : line;
	
	variable datain0 : std_logic_vector(15 downto 0);
	variable temp: std_logic_vector(63 downto 0);			
	variable temp2: std_logic_vector(63 downto 0);			
	
	
	--file filein : text open read_mode is "C:\Users\guido\Documents\keccak_fpga\KeccakVHDL-3.1\3.1\high_speed_core\perm_in.txt";
	file fileout : text open write_mode is "C:/Users/gbert/Documents/bitcoin/keccak_1600\test_vhdlout.txt";
				
		begin
			if(rst_n='0') then
				st <= st0;
				--round_in <= (others=>'0');
				counter <= (others => '0');
					
			elsif(clk'event and clk='1') then
					
					----------------------
					case st is
						when st0 =>
							if (counter<24) then
                                counter<=counter+1;
                              else
                              st <= st1;
                              end if;            
						when st1 =>
								
									for col in 3 downto 0 loop
										for i IN 0 to 63 LOOP
											temp(i) := dout(col*64 + i);
										end loop;
										hwrite(line_out,temp);
										writeline(fileout,line_out);
									end loop;
								write(fileout,string'("-"));
								writeline(fileout,line_out);

						when STOP =>
							null;
					end case;
				end if;
			end process;


-- clock generation


clkgen : process
	begin
		clk <= '1';
		loop
				wait for 10 ns;
				clk<=not clk;
		end loop;
	end process;

end tb;
