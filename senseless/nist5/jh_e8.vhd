--  
-- Copyright (c) 2018 Allmine Inc
--

library work;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;	


entity jh_e8 is

port (

	clk : in std_logic;
    idata     : in  std_logic_vector(1023 downto 0);
    odata    : out std_logic_vector(1023 downto 0));

end jh_e8;

architecture rtl of jh_e8 is



component jh_sbox
port (
		selection:in std_logic_vector(255 downto 0);
		idata:in std_logic_vector(1023 downto 0);
		odata:out std_logic_vector(1023 downto 0)
	  );
end component;


component jh_register 

port (

	clk : in std_logic;
    state_in     : in  std_logic_vector(1023 downto 0);
    state_out    : out std_logic_vector(1023 downto 0));
end component;



component jh_permutation
   port(
      idata:in std_logic_vector(1023 downto 0);
      odata:out std_logic_vector(1023 downto 0)
   );
end component;


component jh_linear 
   port(
      idata:in std_logic_vector(1023 downto 0);
      odata:out std_logic_vector(1023 downto 0)
   );
end component;

component jh_round_constant
port (
   	n_round		: in std_logic_vector(5 downto 0);
    constant_out    : out std_logic_vector(255 downto 0));

end component;


  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------
  
  signal sb_out_0, l_out0, p_out0, rg_out0: std_logic_vector(1023 downto 0);
  signal const0: std_logic_vector(255 downto 0);
  signal sb_out_1, l_out1, p_out1, rg_out1: std_logic_vector(1023 downto 0);
  signal const1: std_logic_vector(255 downto 0);
  signal sb_out_2, l_out2, p_out2, rg_out2: std_logic_vector(1023 downto 0);
  signal const2: std_logic_vector(255 downto 0);
  signal sb_out_3, l_out3, p_out3, rg_out3: std_logic_vector(1023 downto 0);
  signal const3: std_logic_vector(255 downto 0);
  signal sb_out_4, l_out4, p_out4, rg_out4: std_logic_vector(1023 downto 0);
  signal const4: std_logic_vector(255 downto 0);
  signal sb_out_5, l_out5, p_out5, rg_out5: std_logic_vector(1023 downto 0);
  signal const5: std_logic_vector(255 downto 0);
  signal sb_out_6, l_out6, p_out6, rg_out6: std_logic_vector(1023 downto 0);
  signal const6: std_logic_vector(255 downto 0);
  signal sb_out_7, l_out7, p_out7, rg_out7: std_logic_vector(1023 downto 0);
  signal const7: std_logic_vector(255 downto 0);
  signal sb_out_8, l_out8, p_out8, rg_out8: std_logic_vector(1023 downto 0);
  signal const8: std_logic_vector(255 downto 0);
  signal sb_out_9, l_out9, p_out9, rg_out9: std_logic_vector(1023 downto 0);
  signal const9: std_logic_vector(255 downto 0);
  signal sb_out_10, l_out10, p_out10, rg_out10: std_logic_vector(1023 downto 0);
  signal const10: std_logic_vector(255 downto 0);
  signal sb_out_11, l_out11, p_out11, rg_out11: std_logic_vector(1023 downto 0);
  signal const11: std_logic_vector(255 downto 0);
  signal sb_out_12, l_out12, p_out12, rg_out12: std_logic_vector(1023 downto 0);
  signal const12: std_logic_vector(255 downto 0);
  signal sb_out_13, l_out13, p_out13, rg_out13: std_logic_vector(1023 downto 0);
  signal const13: std_logic_vector(255 downto 0);
  signal sb_out_14, l_out14, p_out14, rg_out14: std_logic_vector(1023 downto 0);
  signal const14: std_logic_vector(255 downto 0);
  signal sb_out_15, l_out15, p_out15, rg_out15: std_logic_vector(1023 downto 0);
  signal const15: std_logic_vector(255 downto 0);
  signal sb_out_16, l_out16, p_out16, rg_out16: std_logic_vector(1023 downto 0);
  signal const16: std_logic_vector(255 downto 0);
  signal sb_out_17, l_out17, p_out17, rg_out17: std_logic_vector(1023 downto 0);
  signal const17: std_logic_vector(255 downto 0);
  signal sb_out_18, l_out18, p_out18, rg_out18: std_logic_vector(1023 downto 0);
  signal const18: std_logic_vector(255 downto 0);
  signal sb_out_19, l_out19, p_out19, rg_out19: std_logic_vector(1023 downto 0);
  signal const19: std_logic_vector(255 downto 0);
  signal sb_out_20, l_out20, p_out20, rg_out20: std_logic_vector(1023 downto 0);
  signal const20: std_logic_vector(255 downto 0);
  signal sb_out_21, l_out21, p_out21, rg_out21: std_logic_vector(1023 downto 0);
  signal const21: std_logic_vector(255 downto 0);
  signal sb_out_22, l_out22, p_out22, rg_out22: std_logic_vector(1023 downto 0);
  signal const22: std_logic_vector(255 downto 0);
  signal sb_out_23, l_out23, p_out23, rg_out23: std_logic_vector(1023 downto 0);
  signal const23: std_logic_vector(255 downto 0);
  signal sb_out_24, l_out24, p_out24, rg_out24: std_logic_vector(1023 downto 0);
  signal const24: std_logic_vector(255 downto 0);
  signal sb_out_25, l_out25, p_out25, rg_out25: std_logic_vector(1023 downto 0);
  signal const25: std_logic_vector(255 downto 0);
  signal sb_out_26, l_out26, p_out26, rg_out26: std_logic_vector(1023 downto 0);
  signal const26: std_logic_vector(255 downto 0);
  signal sb_out_27, l_out27, p_out27, rg_out27: std_logic_vector(1023 downto 0);
  signal const27: std_logic_vector(255 downto 0);
  signal sb_out_28, l_out28, p_out28, rg_out28: std_logic_vector(1023 downto 0);
  signal const28: std_logic_vector(255 downto 0);
  signal sb_out_29, l_out29, p_out29, rg_out29: std_logic_vector(1023 downto 0);
  signal const29: std_logic_vector(255 downto 0);
  signal sb_out_30, l_out30, p_out30, rg_out30: std_logic_vector(1023 downto 0);
  signal const30: std_logic_vector(255 downto 0);
  signal sb_out_31, l_out31, p_out31, rg_out31: std_logic_vector(1023 downto 0);
  signal const31: std_logic_vector(255 downto 0);
  signal sb_out_32, l_out32, p_out32, rg_out32: std_logic_vector(1023 downto 0);
  signal const32: std_logic_vector(255 downto 0);
  signal sb_out_33, l_out33, p_out33, rg_out33: std_logic_vector(1023 downto 0);
  signal const33: std_logic_vector(255 downto 0);
  signal sb_out_34, l_out34, p_out34, rg_out34: std_logic_vector(1023 downto 0);
  signal const34: std_logic_vector(255 downto 0);
  signal sb_out_35, l_out35, p_out35, rg_out35: std_logic_vector(1023 downto 0);
  signal const35: std_logic_vector(255 downto 0);
  signal sb_out_36, l_out36, p_out36, rg_out36: std_logic_vector(1023 downto 0);
  signal const36: std_logic_vector(255 downto 0);
  signal sb_out_37, l_out37, p_out37, rg_out37: std_logic_vector(1023 downto 0);
  signal const37: std_logic_vector(255 downto 0);
  signal sb_out_38, l_out38, p_out38, rg_out38: std_logic_vector(1023 downto 0);
  signal const38: std_logic_vector(255 downto 0);
  signal sb_out_39, l_out39, p_out39, rg_out39: std_logic_vector(1023 downto 0);
  signal const39: std_logic_vector(255 downto 0);
  signal sb_out_40, l_out40, p_out40, rg_out40: std_logic_vector(1023 downto 0);
  signal const40: std_logic_vector(255 downto 0);
  signal sb_out_41, l_out41, p_out41, rg_out41: std_logic_vector(1023 downto 0);
  signal const41: std_logic_vector(255 downto 0);
  signal tmp_de,de_out,tmp_g,g_out: std_logic_vector(1023 downto 0);
    
  
  begin
  --grouping

  g02: for i in 0 to 31 generate
      g03: for j in 0 to 7 generate      
      tmp_g(i*32+3+j*4) <= idata ((7-j)+i*8);
      tmp_g(i*32+2+j*4) <= idata ((7-j)+i*8 +256);
      tmp_g(i*32+1+j*4) <= idata ((7-j)+i*8 +512) ;
      tmp_g(i*32+0+j*4) <=idata ((7-j)+i*8 +768);
      end generate;
  
  end generate;

    
    g00: for i in 0 to 127 generate
      g01: for j in 0 to 3 generate
          g_out(i*8+j) <= tmp_g(i*4+j);
          g_out(i*8+j+4) <= tmp_g(i*4+j+128*4);
        end generate;
    end generate;
    
  
  d_map0: jh_register port map(clk, g_out, rg_out0);
  r_map0: jh_round_constant port map("000000", const0);
  s_map0: jh_sbox port map(const0, rg_out0, sb_out_0);
  l_map0: jh_linear port map(sb_out_0, l_out0);
  p_map0: jh_permutation port map(l_out0, p_out0);
  d_map1: jh_register port map(clk, p_out0, rg_out1);
  r_map1: jh_round_constant port map("000001", const1);
  s_map1: jh_sbox port map(const1, rg_out1, sb_out_1);
  l_map1: jh_linear port map(sb_out_1, l_out1);
  p_map1: jh_permutation port map(l_out1, p_out1);
  d_map2: jh_register port map(clk, p_out1, rg_out2);
  r_map2: jh_round_constant port map("000010", const2);
  s_map2: jh_sbox port map(const2, rg_out2, sb_out_2);
  l_map2: jh_linear port map(sb_out_2, l_out2);
  p_map2: jh_permutation port map(l_out2, p_out2);
  d_map3: jh_register port map(clk, p_out2, rg_out3);
  r_map3: jh_round_constant port map("000011", const3);
  s_map3: jh_sbox port map(const3, rg_out3, sb_out_3);
  l_map3: jh_linear port map(sb_out_3, l_out3);
  p_map3: jh_permutation port map(l_out3, p_out3);
  d_map4: jh_register port map(clk, p_out3, rg_out4);
  r_map4: jh_round_constant port map("000100", const4);
  s_map4: jh_sbox port map(const4, rg_out4, sb_out_4);
  l_map4: jh_linear port map(sb_out_4, l_out4);
  p_map4: jh_permutation port map(l_out4, p_out4);
  d_map5: jh_register port map(clk, p_out4, rg_out5);
  r_map5: jh_round_constant port map("000101", const5);
  s_map5: jh_sbox port map(const5, rg_out5, sb_out_5);
  l_map5: jh_linear port map(sb_out_5, l_out5);
  p_map5: jh_permutation port map(l_out5, p_out5);
  d_map6: jh_register port map(clk, p_out5, rg_out6);
  r_map6: jh_round_constant port map("000110", const6);
  s_map6: jh_sbox port map(const6, rg_out6, sb_out_6);
  l_map6: jh_linear port map(sb_out_6, l_out6);
  p_map6: jh_permutation port map(l_out6, p_out6);
  d_map7: jh_register port map(clk, p_out6, rg_out7);
  r_map7: jh_round_constant port map("000111", const7);
  s_map7: jh_sbox port map(const7, rg_out7, sb_out_7);
  l_map7: jh_linear port map(sb_out_7, l_out7);
  p_map7: jh_permutation port map(l_out7, p_out7);
  d_map8: jh_register port map(clk, p_out7, rg_out8);
  r_map8: jh_round_constant port map("001000", const8);
  s_map8: jh_sbox port map(const8, rg_out8, sb_out_8);
  l_map8: jh_linear port map(sb_out_8, l_out8);
  p_map8: jh_permutation port map(l_out8, p_out8);
  d_map9: jh_register port map(clk, p_out8, rg_out9);
  r_map9: jh_round_constant port map("001001", const9);
  s_map9: jh_sbox port map(const9, rg_out9, sb_out_9);
  l_map9: jh_linear port map(sb_out_9, l_out9);
  p_map9: jh_permutation port map(l_out9, p_out9);
  d_map10: jh_register port map(clk, p_out9, rg_out10);
  r_map10: jh_round_constant port map("001010", const10);
  s_map10: jh_sbox port map(const10, rg_out10, sb_out_10);
  l_map10: jh_linear port map(sb_out_10, l_out10);
  p_map10: jh_permutation port map(l_out10, p_out10);
  d_map11: jh_register port map(clk, p_out10, rg_out11);
  r_map11: jh_round_constant port map("001011", const11);
  s_map11: jh_sbox port map(const11, rg_out11, sb_out_11);
  l_map11: jh_linear port map(sb_out_11, l_out11);
  p_map11: jh_permutation port map(l_out11, p_out11);
  d_map12: jh_register port map(clk, p_out11, rg_out12);
  r_map12: jh_round_constant port map("001100", const12);
  s_map12: jh_sbox port map(const12, rg_out12, sb_out_12);
  l_map12: jh_linear port map(sb_out_12, l_out12);
  p_map12: jh_permutation port map(l_out12, p_out12);
  d_map13: jh_register port map(clk, p_out12, rg_out13);
  r_map13: jh_round_constant port map("001101", const13);
  s_map13: jh_sbox port map(const13, rg_out13, sb_out_13);
  l_map13: jh_linear port map(sb_out_13, l_out13);
  p_map13: jh_permutation port map(l_out13, p_out13);
  d_map14: jh_register port map(clk, p_out13, rg_out14);
  r_map14: jh_round_constant port map("001110", const14);
  s_map14: jh_sbox port map(const14, rg_out14, sb_out_14);
  l_map14: jh_linear port map(sb_out_14, l_out14);
  p_map14: jh_permutation port map(l_out14, p_out14);
  d_map15: jh_register port map(clk, p_out14, rg_out15);
  r_map15: jh_round_constant port map("001111", const15);
  s_map15: jh_sbox port map(const15, rg_out15, sb_out_15);
  l_map15: jh_linear port map(sb_out_15, l_out15);
  p_map15: jh_permutation port map(l_out15, p_out15);
  d_map16: jh_register port map(clk, p_out15, rg_out16);
  r_map16: jh_round_constant port map("010000", const16);
  s_map16: jh_sbox port map(const16, rg_out16, sb_out_16);
  l_map16: jh_linear port map(sb_out_16, l_out16);
  p_map16: jh_permutation port map(l_out16, p_out16);
  d_map17: jh_register port map(clk, p_out16, rg_out17);
  r_map17: jh_round_constant port map("010001", const17);
  s_map17: jh_sbox port map(const17, rg_out17, sb_out_17);
  l_map17: jh_linear port map(sb_out_17, l_out17);
  p_map17: jh_permutation port map(l_out17, p_out17);
  d_map18: jh_register port map(clk, p_out17, rg_out18);
  r_map18: jh_round_constant port map("010010", const18);
  s_map18: jh_sbox port map(const18, rg_out18, sb_out_18);
  l_map18: jh_linear port map(sb_out_18, l_out18);
  p_map18: jh_permutation port map(l_out18, p_out18);
  d_map19: jh_register port map(clk, p_out18, rg_out19);
  r_map19: jh_round_constant port map("010011", const19);
  s_map19: jh_sbox port map(const19, rg_out19, sb_out_19);
  l_map19: jh_linear port map(sb_out_19, l_out19);
  p_map19: jh_permutation port map(l_out19, p_out19);
  d_map20: jh_register port map(clk, p_out19, rg_out20);
  r_map20: jh_round_constant port map("010100", const20);
  s_map20: jh_sbox port map(const20, rg_out20, sb_out_20);
  l_map20: jh_linear port map(sb_out_20, l_out20);
  p_map20: jh_permutation port map(l_out20, p_out20);
  d_map21: jh_register port map(clk, p_out20, rg_out21);
  r_map21: jh_round_constant port map("010101", const21);
  s_map21: jh_sbox port map(const21, rg_out21, sb_out_21);
  l_map21: jh_linear port map(sb_out_21, l_out21);
  p_map21: jh_permutation port map(l_out21, p_out21);
  d_map22: jh_register port map(clk, p_out21, rg_out22);
  r_map22: jh_round_constant port map("010110", const22);
  s_map22: jh_sbox port map(const22, rg_out22, sb_out_22);
  l_map22: jh_linear port map(sb_out_22, l_out22);
  p_map22: jh_permutation port map(l_out22, p_out22);
  d_map23: jh_register port map(clk, p_out22, rg_out23);
  r_map23: jh_round_constant port map("010111", const23);
  s_map23: jh_sbox port map(const23, rg_out23, sb_out_23);
  l_map23: jh_linear port map(sb_out_23, l_out23);
  p_map23: jh_permutation port map(l_out23, p_out23);
  d_map24: jh_register port map(clk, p_out23, rg_out24);
  r_map24: jh_round_constant port map("011000", const24);
  s_map24: jh_sbox port map(const24, rg_out24, sb_out_24);
  l_map24: jh_linear port map(sb_out_24, l_out24);
  p_map24: jh_permutation port map(l_out24, p_out24);
  d_map25: jh_register port map(clk, p_out24, rg_out25);
  r_map25: jh_round_constant port map("011001", const25);
  s_map25: jh_sbox port map(const25, rg_out25, sb_out_25);
  l_map25: jh_linear port map(sb_out_25, l_out25);
  p_map25: jh_permutation port map(l_out25, p_out25);
  d_map26: jh_register port map(clk, p_out25, rg_out26);
  r_map26: jh_round_constant port map("011010", const26);
  s_map26: jh_sbox port map(const26, rg_out26, sb_out_26);
  l_map26: jh_linear port map(sb_out_26, l_out26);
  p_map26: jh_permutation port map(l_out26, p_out26);
  d_map27: jh_register port map(clk, p_out26, rg_out27);
  r_map27: jh_round_constant port map("011011", const27);
  s_map27: jh_sbox port map(const27, rg_out27, sb_out_27);
  l_map27: jh_linear port map(sb_out_27, l_out27);
  p_map27: jh_permutation port map(l_out27, p_out27);
  d_map28: jh_register port map(clk, p_out27, rg_out28);
  r_map28: jh_round_constant port map("011100", const28);
  s_map28: jh_sbox port map(const28, rg_out28, sb_out_28);
  l_map28: jh_linear port map(sb_out_28, l_out28);
  p_map28: jh_permutation port map(l_out28, p_out28);
  d_map29: jh_register port map(clk, p_out28, rg_out29);
  r_map29: jh_round_constant port map("011101", const29);
  s_map29: jh_sbox port map(const29, rg_out29, sb_out_29);
  l_map29: jh_linear port map(sb_out_29, l_out29);
  p_map29: jh_permutation port map(l_out29, p_out29);
  d_map30: jh_register port map(clk, p_out29, rg_out30);
  r_map30: jh_round_constant port map("011110", const30);
  s_map30: jh_sbox port map(const30, rg_out30, sb_out_30);
  l_map30: jh_linear port map(sb_out_30, l_out30);
  p_map30: jh_permutation port map(l_out30, p_out30);
  d_map31: jh_register port map(clk, p_out30, rg_out31);
  r_map31: jh_round_constant port map("011111", const31);
  s_map31: jh_sbox port map(const31, rg_out31, sb_out_31);
  l_map31: jh_linear port map(sb_out_31, l_out31);
  p_map31: jh_permutation port map(l_out31, p_out31);
  d_map32: jh_register port map(clk, p_out31, rg_out32);
  r_map32: jh_round_constant port map("100000", const32);
  s_map32: jh_sbox port map(const32, rg_out32, sb_out_32);
  l_map32: jh_linear port map(sb_out_32, l_out32);
  p_map32: jh_permutation port map(l_out32, p_out32);
  d_map33: jh_register port map(clk, p_out32, rg_out33);
  r_map33: jh_round_constant port map("100001", const33);
  s_map33: jh_sbox port map(const33, rg_out33, sb_out_33);
  l_map33: jh_linear port map(sb_out_33, l_out33);
  p_map33: jh_permutation port map(l_out33, p_out33);
  d_map34: jh_register port map(clk, p_out33, rg_out34);
  r_map34: jh_round_constant port map("100010", const34);
  s_map34: jh_sbox port map(const34, rg_out34, sb_out_34);
  l_map34: jh_linear port map(sb_out_34, l_out34);
  p_map34: jh_permutation port map(l_out34, p_out34);
  d_map35: jh_register port map(clk, p_out34, rg_out35);
  r_map35: jh_round_constant port map("100011", const35);
  s_map35: jh_sbox port map(const35, rg_out35, sb_out_35);
  l_map35: jh_linear port map(sb_out_35, l_out35);
  p_map35: jh_permutation port map(l_out35, p_out35);
  d_map36: jh_register port map(clk, p_out35, rg_out36);
  r_map36: jh_round_constant port map("100100", const36);
  s_map36: jh_sbox port map(const36, rg_out36, sb_out_36);
  l_map36: jh_linear port map(sb_out_36, l_out36);
  p_map36: jh_permutation port map(l_out36, p_out36);
  d_map37: jh_register port map(clk, p_out36, rg_out37);
  r_map37: jh_round_constant port map("100101", const37);
  s_map37: jh_sbox port map(const37, rg_out37, sb_out_37);
  l_map37: jh_linear port map(sb_out_37, l_out37);
  p_map37: jh_permutation port map(l_out37, p_out37);
  d_map38: jh_register port map(clk, p_out37, rg_out38);
  r_map38: jh_round_constant port map("100110", const38);
  s_map38: jh_sbox port map(const38, rg_out38, sb_out_38);
  l_map38: jh_linear port map(sb_out_38, l_out38);
  p_map38: jh_permutation port map(l_out38, p_out38);
  d_map39: jh_register port map(clk, p_out38, rg_out39);
  r_map39: jh_round_constant port map("100111", const39);
  s_map39: jh_sbox port map(const39, rg_out39, sb_out_39);
  l_map39: jh_linear port map(sb_out_39, l_out39);
  p_map39: jh_permutation port map(l_out39, p_out39);
  d_map40: jh_register port map(clk, p_out39, rg_out40);
  r_map40: jh_round_constant port map("101000", const40);
  s_map40: jh_sbox port map(const40, rg_out40, sb_out_40);
  l_map40: jh_linear port map(sb_out_40, l_out40);
  p_map40: jh_permutation port map(l_out40, p_out40);
  d_map41: jh_register port map(clk, p_out40, rg_out41);
  r_map41: jh_round_constant port map("101001", const41);
  s_map41: jh_sbox port map(const41, rg_out41, sb_out_41);
  l_map41: jh_linear port map(sb_out_41, l_out41);
  p_map41: jh_permutation port map(l_out41, p_out41);
  
  --degrouping
  
  dg00: for i in 0 to 127 generate
    dg01: for j in 0 to 3 generate
        tmp_de(i*4+j) <= p_out41(i*8+j);
        tmp_de(i*4+j+128*4) <= p_out41(i*8+j+4);
      end generate;
  end generate;
  
dg02: for i in 0 to 31 generate
    dg03: for j in 0 to 7 generate
    --first nibble
    de_out ((7-j)+i*8 ) <= tmp_de(i*32+3+j*4);
    de_out ((7-j)+i*8 +256) <= tmp_de(i*32+2+j*4);
    de_out ((7-j)+i*8 +512) <= tmp_de(i*32+1+j*4);
    de_out ((7-j)+i*8 +768) <= tmp_de(i*32+0+j*4);
    end generate;

end generate;

	odata <= de_out;
	

end rtl;
