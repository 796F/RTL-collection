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
entity aes_mix_col_0 is
   port(
        s0    :in  std_logic_vector(7 downto 0);
        s1    :in  std_logic_vector(7 downto 0);
        s2    :in  std_logic_vector(7 downto 0);
        s3    :in  std_logic_vector(7 downto 0);
        s0_o  :out std_logic_vector(7 downto 0);
        s1_o  :out std_logic_vector(7 downto 0);
        s2_o  :out std_logic_vector(7 downto 0);
        s3_o  :out std_logic_vector(7 downto 0);
        rst_n :in  std_logic;
        clk   :in  std_logic
        );
end aes_mix_col_0;

--signal declaration
architecture RTL of aes_mix_col_0 is
signal fpr:std_logic_vector(7 downto 0);
signal sig_1:std_logic_vector(8 downto 0);
signal sig_2:std_logic_vector(7 downto 0);
signal sig_3:std_logic_vector(8 downto 0);
signal sig_4:std_logic_vector(8 downto 0);
signal sig_5:std_logic_vector(8 downto 0);
signal sig_6:std_logic_vector(7 downto 0);
signal sig_7:std_logic_vector(8 downto 0);
signal sig_8:std_logic_vector(8 downto 0);
signal sig_9:std_logic_vector(8 downto 0);
signal sig_10:std_logic_vector(8 downto 0);
signal sig_11:std_logic_vector(8 downto 0);
signal sig_12:std_logic_vector(7 downto 0);
signal sig_13:std_logic_vector(8 downto 0);
signal sig_14:std_logic_vector(8 downto 0);
signal sig_15:std_logic_vector(8 downto 0);
signal sig_16:std_logic_vector(7 downto 0);
signal sig_17:std_logic_vector(8 downto 0);
signal sig_18:std_logic_vector(8 downto 0);
signal sig_19:std_logic_vector(8 downto 0);
signal sig_20:std_logic_vector(8 downto 0);
signal sig_21:std_logic_vector(8 downto 0);
signal sig_22:std_logic_vector(7 downto 0);
signal sig_23:std_logic_vector(8 downto 0);
signal sig_24:std_logic_vector(8 downto 0);
signal sig_25:std_logic_vector(8 downto 0);
signal sig_26:std_logic_vector(7 downto 0);
signal sig_27:std_logic_vector(8 downto 0);
signal sig_28:std_logic_vector(8 downto 0);
signal sig_29:std_logic_vector(8 downto 0);
signal sig_30:std_logic_vector(8 downto 0);
signal sig_31:std_logic_vector(8 downto 0);
signal sig_32:std_logic_vector(7 downto 0);
signal sig_33:std_logic_vector(8 downto 0);
signal sig_34:std_logic_vector(8 downto 0);
signal sig_35:std_logic_vector(8 downto 0);
signal sig_36:std_logic_vector(7 downto 0);
signal sig_37:std_logic_vector(8 downto 0);
signal sig_38:std_logic_vector(8 downto 0);
signal sig_39:std_logic_vector(8 downto 0);
signal sig_40:std_logic_vector(8 downto 0);
signal s0_o_int:std_logic_vector(7 downto 0);
signal s1_o_int:std_logic_vector(7 downto 0);
signal s2_o_int:std_logic_vector(7 downto 0);
signal s3_o_int:std_logic_vector(7 downto 0);
signal sig_0:std_logic_vector(7 downto 0);


begin


   --combinational logics
   dpCMB: process (fpr,sig_1,sig_2,sig_3,sig_4,sig_5,sig_6,sig_7,sig_8,sig_9
,sig_10,sig_11,sig_12,sig_13,sig_14,sig_15,sig_16,sig_17,sig_18,sig_19
,sig_20,sig_21,sig_22,sig_23,sig_24,sig_25,sig_26,sig_27,sig_28,sig_29
,sig_30,sig_31,sig_32,sig_33,sig_34,sig_35,sig_36,sig_37,sig_38,sig_39
,sig_40,s0_o_int,s1_o_int,s2_o_int,s3_o_int,s0,s1,s2,s3)
      begin
         fpr <= (others=>'0');
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
         sig_31 <= (others=>'0');
         sig_32 <= (others=>'0');
         sig_33 <= (others=>'0');
         sig_34 <= (others=>'0');
         sig_35 <= (others=>'0');
         sig_36 <= (others=>'0');
         sig_37 <= (others=>'0');
         sig_38 <= (others=>'0');
         sig_39 <= (others=>'0');
         sig_40 <= (others=>'0');
         s0_o_int <= (others=>'0');
         s1_o_int <= (others=>'0');
         s2_o_int <= (others=>'0');
         s3_o_int <= (others=>'0');
         sig_0 <= "00011011";
         s0_o <= (others=>'0');
         s1_o <= (others=>'0');
         s2_o <= (others=>'0');
         s3_o <= (others=>'0');

         fpr <= sig_0;
         sig_1 <= conv_std_logic_vector(shl(conv_unsigned(unsigned(s0),9),conv_unsigned(1,9)),9);
         if (s0(7) = '1') then
            sig_2 <= fpr;
         else
            sig_2 <= conv_std_logic_vector(0,8);
         end if;
         sig_3 <= sig_1 xor conv_std_logic_vector(unsigned(sig_2),9);
         sig_4 <= conv_std_logic_vector(shl(conv_unsigned(unsigned(s1),9),conv_unsigned(1,9)),9);
         sig_5 <= sig_3 xor sig_4;
         if (s1(7) = '1') then
            sig_6 <= fpr;
         else
            sig_6 <= conv_std_logic_vector(0,8);
         end if;
         sig_7 <= sig_5 xor conv_std_logic_vector(unsigned(sig_6),9);
         sig_8 <= sig_7 xor conv_std_logic_vector(unsigned(s1),9);
         sig_9 <= sig_8 xor conv_std_logic_vector(unsigned(s2),9);
         sig_10 <= sig_9 xor conv_std_logic_vector(unsigned(s3),9);
         s0_o <= s0_o_int;
         sig_11 <= conv_std_logic_vector(shl(conv_unsigned(unsigned(s1),9),conv_unsigned(1,9)),9);
         if (s1(7) = '1') then
            sig_12 <= fpr;
         else
            sig_12 <= conv_std_logic_vector(0,8);
         end if;
         sig_13 <= sig_11 xor conv_std_logic_vector(unsigned(sig_12),9);
         sig_14 <= conv_std_logic_vector(shl(conv_unsigned(unsigned(s2),9),conv_unsigned(1,9)),9);
         sig_15 <= sig_13 xor sig_14;
         if (s2(7) = '1') then
            sig_16 <= fpr;
         else
            sig_16 <= conv_std_logic_vector(0,8);
         end if;
         sig_17 <= sig_15 xor conv_std_logic_vector(unsigned(sig_16),9);
         sig_18 <= sig_17 xor conv_std_logic_vector(unsigned(s0),9);
         sig_19 <= sig_18 xor conv_std_logic_vector(unsigned(s2),9);
         sig_20 <= sig_19 xor conv_std_logic_vector(unsigned(s3),9);
         s1_o <= s1_o_int;
         sig_21 <= conv_std_logic_vector(shl(conv_unsigned(unsigned(s2),9),conv_unsigned(1,9)),9);
         if (s2(7) = '1') then
            sig_22 <= fpr;
         else
            sig_22 <= conv_std_logic_vector(0,8);
         end if;
         sig_23 <= sig_21 xor conv_std_logic_vector(unsigned(sig_22),9);
         sig_24 <= conv_std_logic_vector(shl(conv_unsigned(unsigned(s3),9),conv_unsigned(1,9)),9);
         sig_25 <= sig_23 xor sig_24;
         if (s3(7) = '1') then
            sig_26 <= fpr;
         else
            sig_26 <= conv_std_logic_vector(0,8);
         end if;
         sig_27 <= sig_25 xor conv_std_logic_vector(unsigned(sig_26),9);
         sig_28 <= sig_27 xor conv_std_logic_vector(unsigned(s0),9);
         sig_29 <= sig_28 xor conv_std_logic_vector(unsigned(s1),9);
         sig_30 <= sig_29 xor conv_std_logic_vector(unsigned(s3),9);
         s2_o <= s2_o_int;
         sig_31 <= conv_std_logic_vector(shl(conv_unsigned(unsigned(s3),9),conv_unsigned(1,9)),9);
         if (s3(7) = '1') then
            sig_32 <= fpr;
         else
            sig_32 <= conv_std_logic_vector(0,8);
         end if;
         sig_33 <= sig_31 xor conv_std_logic_vector(unsigned(sig_32),9);
         sig_34 <= conv_std_logic_vector(shl(conv_unsigned(unsigned(s0),9),conv_unsigned(1,9)),9);
         sig_35 <= sig_33 xor sig_34;
         if (s0(7) = '1') then
            sig_36 <= fpr;
         else
            sig_36 <= conv_std_logic_vector(0,8);
         end if;
         sig_37 <= sig_35 xor conv_std_logic_vector(unsigned(sig_36),9);
         sig_38 <= sig_37 xor conv_std_logic_vector(unsigned(s0),9);
         sig_39 <= sig_38 xor conv_std_logic_vector(unsigned(s1),9);
         sig_40 <= sig_39 xor conv_std_logic_vector(unsigned(s2),9);
         s3_o <= s3_o_int;
         s0_o_int <= sig_10(7 downto 0);
         s1_o_int <= sig_20(7 downto 0);
         s2_o_int <= sig_30(7 downto 0);
         s3_o_int <= sig_40(7 downto 0);
      end process dpCMB;
end RTL;
