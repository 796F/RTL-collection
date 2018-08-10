--  
-- Copyright (c) 2018 Allmine Inc
--

library work;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;	


entity db_jh is

port (

	clk : in std_logic;
	msg     : in  std_logic_vector(511 downto 0);
    jh_digest    : out std_logic_vector(511 downto 0));

end db_jh;

architecture rtl of db_jh is

component jh_f8
port (
	clk : in std_logic;
	msg     : in  std_logic_vector(511 downto 0);
    cvi     : in  std_logic_vector(1023 downto 0);
    cvo    : out std_logic_vector(1023 downto 0));
end component;


component jh_f8f

port (
	clk : in std_logic;	
    cvi     : in  std_logic_vector(1023 downto 0);
    cvo    : out std_logic_vector(1023 downto 0));
end component;



  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------
  
  signal cvi1, cvi1_sw, cvo1, cvo2: std_logic_vector(1023 downto 0);
  signal msg_sw: std_logic_vector(511 downto 0);
  
  begin
  -- intial value of cvi1
	cvi1 <= X"6fd14b963e00aa17636a2e057a15d5438a225e8d0c97ef0be9341259f2b3c361891da0c1536f801e2aa9056bea2b6d80588eccdb2075baa6a90f3a76baf83bf70169e60541e34a6946b58a8e2e6fe65a1047a7d0c1843c243b6e71b12d5ac199cf57f6ec9db1f856a706887c5716b156e3c2fcdfe68517fb545a4678cc8cdd4b";
  -- swap endianess
  isw11: for byte in 0 to 127 generate
      isw12: for i in 0 to 7 generate
          cvi1_sw((127-byte)*8+i) <= cvi1(byte*8+i);
      end generate;    
  end generate;
    isw21: for byte in 0 to 63 generate
        isw22: for i in 0 to 7 generate
            msg_sw((63-byte)*8+i) <= msg(byte*8+i);
        end generate;    
    end generate;
      
  f8_map: jh_f8 port map(clk, msg_sw, cvi1_sw,cvo1);
  f8f_map: jh_f8f port map(clk, cvo1,cvo2);
  
      osw01: for byt in 0 to 63 generate
        osw02: for i in 0 to 7 generate
          jh_digest((63-byt)*8+i) <= cvo2(512+byt*8+i);
      end generate;    
  end generate;
  	

end rtl;
