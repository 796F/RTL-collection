--  
-- Copyright (c) 2018 Allmine Inc
--

library work;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;	


entity jh_f8 is

port (

	clk : in std_logic;
	msg     : in  std_logic_vector(511 downto 0);
    cvi     : in  std_logic_vector(1023 downto 0);
    cvo    : out std_logic_vector(1023 downto 0));

end jh_f8;

architecture rtl of jh_f8 is



component jh_e8
port (
		clk : in std_logic;
		idata:in std_logic_vector(1023 downto 0);
		odata:out std_logic_vector(1023 downto 0)
	  );
end component;


component jh_register_msg 

port (

	clk : in std_logic;
    state_in     : in  std_logic_vector(511 downto 0);
    state_out    : out std_logic_vector(511 downto 0));
end component;


  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------
signal rg_out0: std_logic_vector(511 downto 0);
signal rg_out1: std_logic_vector(511 downto 0);
signal rg_out2: std_logic_vector(511 downto 0);
signal rg_out3: std_logic_vector(511 downto 0);
signal rg_out4: std_logic_vector(511 downto 0);
signal rg_out5: std_logic_vector(511 downto 0);
signal rg_out6: std_logic_vector(511 downto 0);
signal rg_out7: std_logic_vector(511 downto 0);
signal rg_out8: std_logic_vector(511 downto 0);
signal rg_out9: std_logic_vector(511 downto 0);
signal rg_out10: std_logic_vector(511 downto 0);
signal rg_out11: std_logic_vector(511 downto 0);
signal rg_out12: std_logic_vector(511 downto 0);
signal rg_out13: std_logic_vector(511 downto 0);
signal rg_out14: std_logic_vector(511 downto 0);
signal rg_out15: std_logic_vector(511 downto 0);
signal rg_out16: std_logic_vector(511 downto 0);
signal rg_out17: std_logic_vector(511 downto 0);
signal rg_out18: std_logic_vector(511 downto 0);
signal rg_out19: std_logic_vector(511 downto 0);
signal rg_out20: std_logic_vector(511 downto 0);
signal rg_out21: std_logic_vector(511 downto 0);
signal rg_out22: std_logic_vector(511 downto 0);
signal rg_out23: std_logic_vector(511 downto 0);
signal rg_out24: std_logic_vector(511 downto 0);
signal rg_out25: std_logic_vector(511 downto 0);
signal rg_out26: std_logic_vector(511 downto 0);
signal rg_out27: std_logic_vector(511 downto 0);
signal rg_out28: std_logic_vector(511 downto 0);
signal rg_out29: std_logic_vector(511 downto 0);
signal rg_out30: std_logic_vector(511 downto 0);
signal rg_out31: std_logic_vector(511 downto 0);
signal rg_out32: std_logic_vector(511 downto 0);
signal rg_out33: std_logic_vector(511 downto 0);
signal rg_out34: std_logic_vector(511 downto 0);
signal rg_out35: std_logic_vector(511 downto 0);
signal rg_out36: std_logic_vector(511 downto 0);
signal rg_out37: std_logic_vector(511 downto 0);
signal rg_out38: std_logic_vector(511 downto 0);
signal rg_out39: std_logic_vector(511 downto 0);
signal rg_out40: std_logic_vector(511 downto 0);
signal rg_out41: std_logic_vector(511 downto 0);  
 
signal e8_in,e8_out: std_logic_vector(1023 downto 0);  
  
  begin
 -- initial xor
 
 e8_in(511 downto 0) <= cvi(511 downto 0) xor msg(511 downto 0);
 e8_in(1023 downto 512) <= cvi(1023 downto 512);
 
 cvo(1023 downto 512) <= e8_out(1023 downto 512) xor rg_out41(511 downto 0);
 cvo(511 downto 0) <= e8_out(511 downto 0);
 
 e8_map: jh_e8 port map(clk, e8_in, e8_out);
 -- pipeline of message
 
dm_map0: jh_register_msg port map(clk, msg, rg_out0);
dm_map1: jh_register_msg port map(clk, rg_out0, rg_out1);
dm_map2: jh_register_msg port map(clk, rg_out1, rg_out2);
dm_map3: jh_register_msg port map(clk, rg_out2, rg_out3);
dm_map4: jh_register_msg port map(clk, rg_out3, rg_out4);
dm_map5: jh_register_msg port map(clk, rg_out4, rg_out5);
dm_map6: jh_register_msg port map(clk, rg_out5, rg_out6);
dm_map7: jh_register_msg port map(clk, rg_out6, rg_out7);
dm_map8: jh_register_msg port map(clk, rg_out7, rg_out8);
dm_map9: jh_register_msg port map(clk, rg_out8, rg_out9);
dm_map10: jh_register_msg port map(clk, rg_out9, rg_out10);
dm_map11: jh_register_msg port map(clk, rg_out10, rg_out11);
dm_map12: jh_register_msg port map(clk, rg_out11, rg_out12);
dm_map13: jh_register_msg port map(clk, rg_out12, rg_out13);
dm_map14: jh_register_msg port map(clk, rg_out13, rg_out14);
dm_map15: jh_register_msg port map(clk, rg_out14, rg_out15);
dm_map16: jh_register_msg port map(clk, rg_out15, rg_out16);
dm_map17: jh_register_msg port map(clk, rg_out16, rg_out17);
dm_map18: jh_register_msg port map(clk, rg_out17, rg_out18);
dm_map19: jh_register_msg port map(clk, rg_out18, rg_out19);
dm_map20: jh_register_msg port map(clk, rg_out19, rg_out20);
dm_map21: jh_register_msg port map(clk, rg_out20, rg_out21);
dm_map22: jh_register_msg port map(clk, rg_out21, rg_out22);
dm_map23: jh_register_msg port map(clk, rg_out22, rg_out23);
dm_map24: jh_register_msg port map(clk, rg_out23, rg_out24);
dm_map25: jh_register_msg port map(clk, rg_out24, rg_out25);
dm_map26: jh_register_msg port map(clk, rg_out25, rg_out26);
dm_map27: jh_register_msg port map(clk, rg_out26, rg_out27);
dm_map28: jh_register_msg port map(clk, rg_out27, rg_out28);
dm_map29: jh_register_msg port map(clk, rg_out28, rg_out29);
dm_map30: jh_register_msg port map(clk, rg_out29, rg_out30);
dm_map31: jh_register_msg port map(clk, rg_out30, rg_out31);
dm_map32: jh_register_msg port map(clk, rg_out31, rg_out32);
dm_map33: jh_register_msg port map(clk, rg_out32, rg_out33);
dm_map34: jh_register_msg port map(clk, rg_out33, rg_out34);
dm_map35: jh_register_msg port map(clk, rg_out34, rg_out35);
dm_map36: jh_register_msg port map(clk, rg_out35, rg_out36);
dm_map37: jh_register_msg port map(clk, rg_out36, rg_out37);
dm_map38: jh_register_msg port map(clk, rg_out37, rg_out38);
dm_map39: jh_register_msg port map(clk, rg_out38, rg_out39);
dm_map40: jh_register_msg port map(clk, rg_out39, rg_out40);
dm_map41: jh_register_msg port map(clk, rg_out40, rg_out41);



end rtl;
