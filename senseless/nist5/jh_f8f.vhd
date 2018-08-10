--  
-- Copyright (c) 2018 Allmine Inc
--

library work;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;	


entity jh_f8f is

port (

	clk : in std_logic;	
    cvi     : in  std_logic_vector(1023 downto 0);
    cvo    : out std_logic_vector(1023 downto 0));

end jh_f8f;

architecture rtl of jh_f8f is



component jh_e8
port (
		clk : in std_logic;
		idata:in std_logic_vector(1023 downto 0);
		odata:out std_logic_vector(1023 downto 0)
	  );
end component;




  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------
signal padding:std_logic_vector(511 downto 0);  

signal e8_in,e8_out: std_logic_vector(1023 downto 0);  
  begin
  
 -- padding
 -- endianess already fixed
 padding <= X"00020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080";

 -- initial xor
 
 e8_in(511 downto 0) <= cvi(511 downto 0) xor padding(511 downto 0);
 e8_in(1023 downto 512) <= cvi(1023 downto 512);
 
 cvo(1023 downto 512) <= e8_out(1023 downto 512) xor padding(511 downto 0);
 cvo(511 downto 0) <= e8_out(511 downto 0);
 
 e8_map: jh_e8 port map(clk, e8_in, e8_out);
 	

end rtl;
