--------------------------------------------------------------------------
--2010 CESCA @ Virginia Tech
--------------------------------------------------------------------------
--This program is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
library work;
use work.std_logic_arithext.all;


--datapath entity
entity aes_round_key_first is
   port(
        key      :in  std_logic_vector(127 downto 0);
        data_in  :in  std_logic_vector(127 downto 0);
        data_out :out std_logic_vector(127 downto 0);
        rst_n    :in  std_logic;
        clk      :in  std_logic
        );
end aes_round_key_first;

--signal declaration
architecture RTL of aes_round_key_first is
signal w0:std_logic_vector(31 downto 0);
signal w1:std_logic_vector(31 downto 0);
signal w2:std_logic_vector(31 downto 0);
signal w3:std_logic_vector(31 downto 0);
signal sa00:std_logic_vector(7 downto 0);
signal sa01:std_logic_vector(7 downto 0);
signal sa02:std_logic_vector(7 downto 0);
signal sa03:std_logic_vector(7 downto 0);
signal sa10:std_logic_vector(7 downto 0);
signal sa11:std_logic_vector(7 downto 0);
signal sa12:std_logic_vector(7 downto 0);
signal sa13:std_logic_vector(7 downto 0);
signal sa20:std_logic_vector(7 downto 0);
signal sa21:std_logic_vector(7 downto 0);
signal sa22:std_logic_vector(7 downto 0);
signal sa23:std_logic_vector(7 downto 0);
signal sa30:std_logic_vector(7 downto 0);
signal sa31:std_logic_vector(7 downto 0);
signal sa32:std_logic_vector(7 downto 0);
signal sa33:std_logic_vector(7 downto 0);
signal sa00_next:std_logic_vector(7 downto 0);
signal sa01_next:std_logic_vector(7 downto 0);
signal sa02_next:std_logic_vector(7 downto 0);
signal sa03_next:std_logic_vector(7 downto 0);
signal sa10_next:std_logic_vector(7 downto 0);
signal sa11_next:std_logic_vector(7 downto 0);
signal sa12_next:std_logic_vector(7 downto 0);
signal sa13_next:std_logic_vector(7 downto 0);
signal sa20_next:std_logic_vector(7 downto 0);
signal sa21_next:std_logic_vector(7 downto 0);
signal sa22_next:std_logic_vector(7 downto 0);
signal sa23_next:std_logic_vector(7 downto 0);
signal sa30_next:std_logic_vector(7 downto 0);
signal sa31_next:std_logic_vector(7 downto 0);
signal sa32_next:std_logic_vector(7 downto 0);
signal sa33_next:std_logic_vector(7 downto 0);
signal sa00_sub:std_logic_vector(7 downto 0);
signal sa01_sub:std_logic_vector(7 downto 0);
signal sa02_sub:std_logic_vector(7 downto 0);
signal sa03_sub:std_logic_vector(7 downto 0);
signal sa10_sub:std_logic_vector(7 downto 0);
signal sa11_sub:std_logic_vector(7 downto 0);
signal sa12_sub:std_logic_vector(7 downto 0);
signal sa13_sub:std_logic_vector(7 downto 0);
signal sa20_sub:std_logic_vector(7 downto 0);
signal sa21_sub:std_logic_vector(7 downto 0);
signal sa22_sub:std_logic_vector(7 downto 0);
signal sa23_sub:std_logic_vector(7 downto 0);
signal sa30_sub:std_logic_vector(7 downto 0);
signal sa31_sub:std_logic_vector(7 downto 0);
signal sa32_sub:std_logic_vector(7 downto 0);
signal sa33_sub:std_logic_vector(7 downto 0);
signal sa00_sr:std_logic_vector(7 downto 0);
signal sa01_sr:std_logic_vector(7 downto 0);
signal sa02_sr:std_logic_vector(7 downto 0);
signal sa03_sr:std_logic_vector(7 downto 0);
signal sa10_sr:std_logic_vector(7 downto 0);
signal sa11_sr:std_logic_vector(7 downto 0);
signal sa12_sr:std_logic_vector(7 downto 0);
signal sa13_sr:std_logic_vector(7 downto 0);
signal sa20_sr:std_logic_vector(7 downto 0);
signal sa21_sr:std_logic_vector(7 downto 0);
signal sa22_sr:std_logic_vector(7 downto 0);
signal sa23_sr:std_logic_vector(7 downto 0);
signal sa30_sr:std_logic_vector(7 downto 0);
signal sa31_sr:std_logic_vector(7 downto 0);
signal sa32_sr:std_logic_vector(7 downto 0);
signal sa33_sr:std_logic_vector(7 downto 0);
signal sa00_mc:std_logic_vector(7 downto 0);
signal sa01_mc:std_logic_vector(7 downto 0);
signal sa02_mc:std_logic_vector(7 downto 0);
signal sa03_mc:std_logic_vector(7 downto 0);
signal sa10_mc:std_logic_vector(7 downto 0);
signal sa11_mc:std_logic_vector(7 downto 0);
signal sa12_mc:std_logic_vector(7 downto 0);
signal sa13_mc:std_logic_vector(7 downto 0);
signal sa20_mc:std_logic_vector(7 downto 0);
signal sa21_mc:std_logic_vector(7 downto 0);
signal sa22_mc:std_logic_vector(7 downto 0);
signal sa23_mc:std_logic_vector(7 downto 0);
signal sa30_mc:std_logic_vector(7 downto 0);
signal sa31_mc:std_logic_vector(7 downto 0);
signal sa32_mc:std_logic_vector(7 downto 0);
signal sa33_mc:std_logic_vector(7 downto 0);
signal data_out00:std_logic_vector(7 downto 0);
signal data_out01:std_logic_vector(7 downto 0);
signal data_out02:std_logic_vector(7 downto 0);
signal data_out03:std_logic_vector(7 downto 0);
signal data_out04:std_logic_vector(7 downto 0);
signal data_out05:std_logic_vector(7 downto 0);
signal data_out06:std_logic_vector(7 downto 0);
signal data_out07:std_logic_vector(7 downto 0);
signal data_out08:std_logic_vector(7 downto 0);
signal data_out09:std_logic_vector(7 downto 0);
signal data_out10:std_logic_vector(7 downto 0);
signal data_out11:std_logic_vector(7 downto 0);
signal data_out12:std_logic_vector(7 downto 0);
signal data_out13:std_logic_vector(7 downto 0);
signal data_out14:std_logic_vector(7 downto 0);
signal data_out15:std_logic_vector(7 downto 0);
signal sig_0:std_logic_vector(7 downto 0);
signal sig_1:std_logic_vector(7 downto 0);
signal sig_2:std_logic_vector(7 downto 0);
signal sig_3:std_logic_vector(7 downto 0);
signal sig_4:std_logic_vector(7 downto 0);
signal sig_5:std_logic_vector(7 downto 0);
signal sig_6:std_logic_vector(7 downto 0);
signal sig_7:std_logic_vector(7 downto 0);
signal sig_8:std_logic_vector(7 downto 0);
signal sig_9:std_logic_vector(7 downto 0);
signal sig_10:std_logic_vector(7 downto 0);
signal sig_11:std_logic_vector(7 downto 0);
signal sig_12:std_logic_vector(7 downto 0);
signal sig_13:std_logic_vector(7 downto 0);
signal sig_14:std_logic_vector(7 downto 0);
signal sig_15:std_logic_vector(7 downto 0);
signal sig_16:std_logic_vector(15 downto 0);
signal sig_17:std_logic_vector(23 downto 0);
signal sig_18:std_logic_vector(31 downto 0);
signal sig_19:std_logic_vector(39 downto 0);
signal sig_20:std_logic_vector(47 downto 0);
signal sig_21:std_logic_vector(55 downto 0);
signal sig_22:std_logic_vector(63 downto 0);
signal sig_23:std_logic_vector(71 downto 0);
signal sig_24:std_logic_vector(79 downto 0);
signal sig_25:std_logic_vector(87 downto 0);
signal sig_26:std_logic_vector(95 downto 0);
signal sig_27:std_logic_vector(103 downto 0);
signal sig_28:std_logic_vector(111 downto 0);
signal sig_29:std_logic_vector(119 downto 0);
signal sig_30:std_logic_vector(127 downto 0);
signal data_out_int:std_logic_vector(127 downto 0);


--component map declaration
component aes_mix_col_0
   port(
      s0:in std_logic_vector(7 downto 0);
      s1:in std_logic_vector(7 downto 0);
      s2:in std_logic_vector(7 downto 0);
      s3:in std_logic_vector(7 downto 0);
      s0_o:out std_logic_vector(7 downto 0);
      s1_o:out std_logic_vector(7 downto 0);
      s2_o:out std_logic_vector(7 downto 0);
      s3_o:out std_logic_vector(7 downto 0);
      rst_n : in std_logic;
      clk : in std_logic
   );
end component;
component sbox_us00
   port(
      din:in std_logic_vector(7 downto 0);
      dout:out std_logic_vector(7 downto 0);
      rst_n : in std_logic;
      clk : in std_logic
   );
end component;


begin


   --portmap
   label_aes_mix_col_0 : aes_mix_col_0 port map (
         s0 => sa00_sr,
         s1 => sa10_sr,
         s2 => sa20_sr,
         s3 => sa30_sr,
         s0_o => sa00_mc,
         s1_o => sa10_mc,
         s2_o => sa20_mc,
         s3_o => sa30_mc,
         rst_n => rst_n,
         clk => clk
      );
   label_aes_mix_col_1 : aes_mix_col_0 port map (
         s0 => sa01_sr,
         s1 => sa11_sr,
         s2 => sa21_sr,
         s3 => sa31_sr,
         s0_o => sa01_mc,
         s1_o => sa11_mc,
         s2_o => sa21_mc,
         s3_o => sa31_mc,
         rst_n => rst_n,
         clk => clk
      );
   label_aes_mix_col_2 : aes_mix_col_0 port map (
         s0 => sa02_sr,
         s1 => sa12_sr,
         s2 => sa22_sr,
         s3 => sa32_sr,
         s0_o => sa02_mc,
         s1_o => sa12_mc,
         s2_o => sa22_mc,
         s3_o => sa32_mc,
         rst_n => rst_n,
         clk => clk
      );
   label_aes_mix_col_3 : aes_mix_col_0 port map (
         s0 => sa03_sr,
         s1 => sa13_sr,
         s2 => sa23_sr,
         s3 => sa33_sr,
         s0_o => sa03_mc,
         s1_o => sa13_mc,
         s2_o => sa23_mc,
         s3_o => sa33_mc,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us00 : sbox_us00 port map (
         din => sa00,
         dout => sa00_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us01 : sbox_us00 port map (
         din => sa01,
         dout => sa01_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us02 : sbox_us00 port map (
         din => sa02,
         dout => sa02_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us03 : sbox_us00 port map (
         din => sa03,
         dout => sa03_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us10 : sbox_us00 port map (
         din => sa10,
         dout => sa10_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us11 : sbox_us00 port map (
         din => sa11,
         dout => sa11_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us12 : sbox_us00 port map (
         din => sa12,
         dout => sa12_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us13 : sbox_us00 port map (
         din => sa13,
         dout => sa13_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us20 : sbox_us00 port map (
         din => sa20,
         dout => sa20_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us21 : sbox_us00 port map (
         din => sa21,
         dout => sa21_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us22 : sbox_us00 port map (
         din => sa22,
         dout => sa22_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us23 : sbox_us00 port map (
         din => sa23,
         dout => sa23_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us30 : sbox_us00 port map (
         din => sa30,
         dout => sa30_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us31 : sbox_us00 port map (
         din => sa31,
         dout => sa31_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us32 : sbox_us00 port map (
         din => sa32,
         dout => sa32_sub,
         rst_n => rst_n,
         clk => clk
      );
   label_sbox_us33 : sbox_us00 port map (
         din => sa33,
         dout => sa33_sub,
         rst_n => rst_n,
         clk => clk
      );


   --combinational logics
   dpCMB: process (w0,w1,w2,w3,sa00,sa01,sa02,sa03,sa10,sa11
,sa12,sa13,sa20,sa21,sa22,sa23,sa30,sa31,sa32,sa33
,sa00_next,sa01_next,sa02_next,sa03_next,sa10_next,sa11_next,sa12_next,sa13_next,sa20_next,sa21_next
,sa22_next,sa23_next,sa30_next,sa31_next,sa32_next,sa33_next,sa00_sub,sa01_sub,sa02_sub,sa03_sub
,sa10_sub,sa11_sub,sa12_sub,sa13_sub,sa20_sub,sa21_sub,sa22_sub,sa23_sub,sa30_sub,sa31_sub
,sa32_sub,sa33_sub,sa00_sr,sa01_sr,sa02_sr,sa03_sr,sa10_sr,sa11_sr,sa12_sr,sa13_sr
,sa20_sr,sa21_sr,sa22_sr,sa23_sr,sa30_sr,sa31_sr,sa32_sr,sa33_sr,sa00_mc,sa01_mc
,sa02_mc,sa03_mc,sa10_mc,sa11_mc,sa12_mc,sa13_mc,sa20_mc,sa21_mc,sa22_mc,sa23_mc
,sa30_mc,sa31_mc,sa32_mc,sa33_mc,data_out00,data_out01,data_out02,data_out03,data_out04,data_out05
,data_out06,data_out07,data_out08,data_out09,data_out10,data_out11,data_out12,data_out13,data_out14,data_out15
,sig_0,sig_1,sig_2,sig_3,sig_4,sig_5,sig_6,sig_7,sig_8,sig_9
,sig_10,sig_11,sig_12,sig_13,sig_14,sig_15,sig_16,sig_17,sig_18,sig_19
,sig_20,sig_21,sig_22,sig_23,sig_24,sig_25,sig_26,sig_27,sig_28,sig_29
,sig_30,data_out_int,key,data_in)
      begin
         w0 <= (others=>'0');
         w1 <= (others=>'0');
         w2 <= (others=>'0');
         w3 <= (others=>'0');
         sa00 <= (others=>'0');
         sa01 <= (others=>'0');
         sa02 <= (others=>'0');
         sa03 <= (others=>'0');
         sa10 <= (others=>'0');
         sa11 <= (others=>'0');
         sa12 <= (others=>'0');
         sa13 <= (others=>'0');
         sa20 <= (others=>'0');
         sa21 <= (others=>'0');
         sa22 <= (others=>'0');
         sa23 <= (others=>'0');
         sa30 <= (others=>'0');
         sa31 <= (others=>'0');
         sa32 <= (others=>'0');
         sa33 <= (others=>'0');
         sa00_next <= (others=>'0');
         sa01_next <= (others=>'0');
         sa02_next <= (others=>'0');
         sa03_next <= (others=>'0');
         sa10_next <= (others=>'0');
         sa11_next <= (others=>'0');
         sa12_next <= (others=>'0');
         sa13_next <= (others=>'0');
         sa20_next <= (others=>'0');
         sa21_next <= (others=>'0');
         sa22_next <= (others=>'0');
         sa23_next <= (others=>'0');
         sa30_next <= (others=>'0');
         sa31_next <= (others=>'0');
         sa32_next <= (others=>'0');
         sa33_next <= (others=>'0');
         sa00_sr <= (others=>'0');
         sa01_sr <= (others=>'0');
         sa02_sr <= (others=>'0');
         sa03_sr <= (others=>'0');
         sa10_sr <= (others=>'0');
         sa11_sr <= (others=>'0');
         sa12_sr <= (others=>'0');
         sa13_sr <= (others=>'0');
         sa20_sr <= (others=>'0');
         sa21_sr <= (others=>'0');
         sa22_sr <= (others=>'0');
         sa23_sr <= (others=>'0');
         sa30_sr <= (others=>'0');
         sa31_sr <= (others=>'0');
         sa32_sr <= (others=>'0');
         sa33_sr <= (others=>'0');
         data_out00 <= (others=>'0');
         data_out01 <= (others=>'0');
         data_out02 <= (others=>'0');
         data_out03 <= (others=>'0');
         data_out04 <= (others=>'0');
         data_out05 <= (others=>'0');
         data_out06 <= (others=>'0');
         data_out07 <= (others=>'0');
         data_out08 <= (others=>'0');
         data_out09 <= (others=>'0');
         data_out10 <= (others=>'0');
         data_out11 <= (others=>'0');
         data_out12 <= (others=>'0');
         data_out13 <= (others=>'0');
         data_out14 <= (others=>'0');
         data_out15 <= (others=>'0');
         sig_0 <= (others=>'0');
         sig_1 <= (others=>'0');
         sig_2 <= (others=>'0');
         sig_3 <= (others=>'0');
         sig_4 <= (others=>'0');
         sig_5 <= (others=>'0');
         sig_6 <= (others=>'0');
         sig_7 <= (others=>'0');
         sig_8 <= (others=>'0');
         sig_9 <= (others=>'0');
         sig_10 <= (others=>'0');
         sig_11 <= (others=>'0');
         sig_12 <= (others=>'0');
         sig_13 <= (others=>'0');
         sig_14 <= (others=>'0');
         sig_15 <= (others=>'0');
         sig_16 <= (others=>'0');
         sig_17 <= (others=>'0');
         sig_18 <= (others=>'0');
         sig_19 <= (others=>'0');
         sig_20 <= (others=>'0');
         sig_21 <= (others=>'0');
         sig_22 <= (others=>'0');
         sig_23 <= (others=>'0');
         sig_24 <= (others=>'0');
         sig_25 <= (others=>'0');
         sig_26 <= (others=>'0');
         sig_27 <= (others=>'0');
         sig_28 <= (others=>'0');
         sig_29 <= (others=>'0');
         sig_30 <= (others=>'0');
         data_out_int <= (others=>'0');
         data_out <= (others=>'0');

         w0 <= key(127 downto 96);
         w1 <= key(95 downto 64);
         w2 <= key(63 downto 32);
         w3 <= key(31 downto 0);
         sig_0 <= data_in(7 downto 0) xor w3(7 downto 0);
         sa33 <= sig_0;
         sig_1 <= data_in(15 downto 8) xor w3(15 downto 8);
         sa23 <= sig_1;
         sig_2 <= data_in(23 downto 16) xor w3(23 downto 16);
         sa13 <= sig_2;
         sig_3 <= data_in(31 downto 24) xor w3(31 downto 24);
         sa03 <= sig_3;
         sig_4 <= data_in(39 downto 32) xor w2(7 downto 0);
         sa32 <= sig_4;
         sig_5 <= data_in(47 downto 40) xor w2(15 downto 8);
         sa22 <= sig_5;
         sig_6 <= data_in(55 downto 48) xor w2(23 downto 16);
         sa12 <= sig_6;
         sig_7 <= data_in(63 downto 56) xor w2(31 downto 24);
         sa02 <= sig_7;
         sig_8 <= data_in(71 downto 64) xor w1(7 downto 0);
         sa31 <= sig_8;
         sig_9 <= data_in(79 downto 72) xor w1(15 downto 8);
         sa21 <= sig_9;
         sig_10 <= data_in(87 downto 80) xor w1(23 downto 16);
         sa11 <= sig_10;
         sig_11 <= data_in(95 downto 88) xor w1(31 downto 24);
         sa01 <= sig_11;
         sig_12 <= data_in(103 downto 96) xor w0(7 downto 0);
         sa30 <= sig_12;
         sig_13 <= data_in(111 downto 104) xor w0(15 downto 8);
         sa20 <= sig_13;
         sig_14 <= data_in(119 downto 112) xor w0(23 downto 16);
         sa10 <= sig_14;
         sig_15 <= data_in(127 downto 120) xor w0(31 downto 24);
         sa00 <= sig_15;
         sa00_sr <= sa00_sub;
         sa01_sr <= sa01_sub;
         sa02_sr <= sa02_sub;
         sa03_sr <= sa03_sub;
         sa10_sr <= sa11_sub;
         sa11_sr <= sa12_sub;
         sa12_sr <= sa13_sub;
         sa13_sr <= sa10_sub;
         sa20_sr <= sa22_sub;
         sa21_sr <= sa23_sub;
         sa22_sr <= sa20_sub;
         sa23_sr <= sa21_sub;
         sa30_sr <= sa33_sub;
         sa31_sr <= sa30_sub;
         sa32_sr <= sa31_sub;
         sa33_sr <= sa32_sub;
         sa00_next <= sa00_mc;
         sa01_next <= sa01_mc;
         sa02_next <= sa02_mc;
         sa03_next <= sa03_mc;
         sa10_next <= sa10_mc;
         sa11_next <= sa11_mc;
         sa12_next <= sa12_mc;
         sa13_next <= sa13_mc;
         sa20_next <= sa20_mc;
         sa21_next <= sa21_mc;
         sa22_next <= sa22_mc;
         sa23_next <= sa23_mc;
         sa30_next <= sa30_mc;
         sa31_next <= sa31_mc;
         sa32_next <= sa32_mc;
         sa33_next <= sa33_mc;
         sig_16 <= sa00_next & sa10_next;
         sig_17 <= sig_16 & sa20_next;
         sig_18 <= sig_17 & sa30_next;
         sig_19 <= sig_18 & sa01_next;
         sig_20 <= sig_19 & sa11_next;
         sig_21 <= sig_20 & sa21_next;
         sig_22 <= sig_21 & sa31_next;
         sig_23 <= sig_22 & sa02_next;
         sig_24 <= sig_23 & sa12_next;
         sig_25 <= sig_24 & sa22_next;
         sig_26 <= sig_25 & sa32_next;
         sig_27 <= sig_26 & sa03_next;
         sig_28 <= sig_27 & sa13_next;
         sig_29 <= sig_28 & sa23_next;
         sig_30 <= sig_29 & sa33_next;
         data_out <= data_out_int;
         data_out_int <= sig_30;
      end process dpCMB;
end RTL;
