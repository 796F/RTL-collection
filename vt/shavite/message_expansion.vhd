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
entity message_expansion is
   port(
       init         :in  std_logic;
       load         :in  std_logic;
       message      :in  std_logic_vector(15 downto 0);
       round_key    :out std_logic_vector(127 downto 0);
       start_cipher :out std_logic;
       rst_n        :in  std_logic;
       clk          :in  std_logic
       );
end message_expansion;


--signal declaration
architecture RTL of message_expansion is
signal init_reg:std_logic;
signal init_reg_wire:std_logic;
signal load_reg:std_logic;
signal load_reg_wire:std_logic;
signal message_reg:std_logic_vector(511 downto 0);
signal message_reg_wire:std_logic_vector(511 downto 0);
signal counter_reg:std_logic_vector(63 downto 0);
signal counter_reg_wire:std_logic_vector(63 downto 0);
signal counter_init:std_logic_vector(63 downto 0);
signal counter_init_wire:std_logic_vector(63 downto 0);
signal salt_reg:std_logic_vector(255 downto 0);
signal salt_reg_wire:std_logic_vector(255 downto 0);
signal cntr0:std_logic_vector(4 downto 0);
signal cntr0_wire:std_logic_vector(4 downto 0);
signal cntr1:std_logic_vector(2 downto 0);
signal cntr1_wire:std_logic_vector(2 downto 0);
signal cntr2:std_logic_vector(1 downto 0);
signal cntr2_wire:std_logic_vector(1 downto 0);
signal nlw_msg:std_logic_vector(5 downto 0);
signal nlw_msg_wire:std_logic_vector(5 downto 0);
signal salt:std_logic_vector(255 downto 0);
signal counter:std_logic_vector(63 downto 0);
signal round_key_sig:std_logic_vector(127 downto 0);
signal key:std_logic_vector(127 downto 0);
signal aes_data_in:std_logic_vector(127 downto 0);
signal aes_data_out:std_logic_vector(127 downto 0);
signal sig_0:std_logic;
signal sig_1:std_logic;
signal sig_2:std_logic;
signal sig_3:std_logic_vector(127 downto 0);
signal sig_4:std_logic_vector(63 downto 0);
signal sig_5:std_logic_vector(95 downto 0);
signal sig_6:std_logic_vector(127 downto 0);
signal sig_7:std_logic;
signal sig_8:std_logic;
signal sig_9:std_logic;
signal sig_10:std_logic_vector(127 downto 0);
signal sig_11:std_logic_vector(63 downto 0);
signal sig_12:std_logic_vector(95 downto 0);
signal sig_13:std_logic_vector(127 downto 0);
signal sig_14:std_logic;
signal sig_15:std_logic_vector(63 downto 0);
signal sig_17:std_logic_vector(511 downto 0);
signal sig_18:std_logic_vector(5 downto 0);
signal sig_19:std_logic;
signal sig_20:std_logic;
signal sig_21:std_logic;
signal sig_22:std_logic_vector(127 downto 0);
signal sig_23:std_logic_vector(63 downto 0);
signal sig_24:std_logic_vector(95 downto 0);
signal sig_25:std_logic_vector(127 downto 0);
signal sig_26:std_logic;
signal sig_27:std_logic;
signal sig_28:std_logic_vector(63 downto 0);
signal sig_29:std_logic_vector(63 downto 0);
signal sig_30:std_logic_vector(63 downto 0);
signal sig_31:std_logic_vector(511 downto 0);
signal sig_32:std_logic;
signal sig_33:std_logic;
signal sig_34:std_logic;
signal sig_35:std_logic_vector(127 downto 0);
signal sig_36:std_logic_vector(63 downto 0);
signal sig_37:std_logic_vector(95 downto 0);
signal sig_38:std_logic_vector(127 downto 0);
signal sig_39:std_logic_vector(4 downto 0);
signal sig_40:std_logic;
signal sig_41:std_logic_vector(63 downto 0);
signal sig_42:std_logic;
signal sig_43:std_logic;
signal sig_44:std_logic;
signal sig_45:std_logic_vector(127 downto 0);
signal sig_46:std_logic_vector(63 downto 0);
signal sig_47:std_logic_vector(95 downto 0);
signal sig_48:std_logic_vector(127 downto 0);
signal sig_49:std_logic_vector(511 downto 0);
signal sig_50:std_logic;
signal sig_51:std_logic_vector(31 downto 0);
signal sig_52:std_logic_vector(31 downto 0);
signal sig_53:std_logic_vector(31 downto 0);
signal sig_54:std_logic_vector(31 downto 0);
signal sig_55:std_logic_vector(31 downto 0);
signal sig_56:std_logic_vector(63 downto 0);
signal sig_57:std_logic_vector(31 downto 0);
signal sig_58:std_logic_vector(95 downto 0);
signal sig_59:std_logic_vector(31 downto 0);
signal sig_60:std_logic_vector(127 downto 0);
signal sig_61:std_logic;
signal sig_62:std_logic_vector(31 downto 0);
signal sig_63:std_logic_vector(31 downto 0);
signal sig_64:std_logic_vector(31 downto 0);
signal sig_65:std_logic_vector(63 downto 0);
signal sig_66:std_logic_vector(31 downto 0);
signal sig_67:std_logic_vector(31 downto 0);
signal sig_68:std_logic_vector(31 downto 0);
signal sig_69:std_logic_vector(95 downto 0);
signal sig_70:std_logic_vector(31 downto 0);
signal sig_71:std_logic_vector(127 downto 0);
signal sig_72:std_logic;
signal sig_73:std_logic_vector(31 downto 0);
signal sig_74:std_logic_vector(31 downto 0);
signal sig_75:std_logic_vector(63 downto 0);
signal sig_76:std_logic_vector(31 downto 0);
signal sig_77:std_logic_vector(31 downto 0);
signal sig_78:std_logic_vector(95 downto 0);
signal sig_79:std_logic_vector(31 downto 0);
signal sig_80:std_logic_vector(31 downto 0);
signal sig_81:std_logic_vector(31 downto 0);
signal sig_82:std_logic_vector(127 downto 0);
signal sig_83:std_logic;
signal sig_84:std_logic_vector(31 downto 0);
signal sig_85:std_logic_vector(31 downto 0);
signal sig_86:std_logic_vector(31 downto 0);
signal sig_87:std_logic_vector(63 downto 0);
signal sig_88:std_logic_vector(31 downto 0);
signal sig_89:std_logic_vector(95 downto 0);
signal sig_90:std_logic_vector(31 downto 0);
signal sig_91:std_logic_vector(31 downto 0);
signal sig_92:std_logic_vector(31 downto 0);
signal sig_93:std_logic_vector(127 downto 0);
signal sig_94:std_logic_vector(31 downto 0);
signal sig_95:std_logic_vector(31 downto 0);
signal sig_96:std_logic_vector(63 downto 0);
signal sig_97:std_logic_vector(31 downto 0);
signal sig_98:std_logic_vector(95 downto 0);
signal sig_99:std_logic_vector(31 downto 0);
signal sig_100:std_logic_vector(127 downto 0);
signal sig_101:std_logic_vector(127 downto 0);
signal sig_102:std_logic_vector(127 downto 0);
signal sig_103:std_logic_vector(4 downto 0);
signal sig_104:std_logic_vector(2 downto 0);
signal sig_105:std_logic;
signal sig_106:std_logic;
signal sig_107:std_logic;
signal sig_108:std_logic_vector(1 downto 0);
signal sig_109:std_logic_vector(1 downto 0);
signal sig_110:std_logic;
signal sig_111:std_logic_vector(63 downto 0);
signal sig_112:std_logic_vector(31 downto 0);
signal sig_113:std_logic_vector(31 downto 0);
signal sig_114:std_logic_vector(63 downto 0);
signal sig_115:std_logic_vector(31 downto 0);
signal sig_116:std_logic_vector(95 downto 0);
signal sig_117:std_logic_vector(31 downto 0);
signal sig_118:std_logic_vector(31 downto 0);
signal sig_119:std_logic_vector(127 downto 0);
signal sig_120:std_logic_vector(511 downto 0);
signal sig_121:std_logic;
signal sig_122:std_logic;
signal sig_123:std_logic;
signal sig_124:std_logic_vector(127 downto 0);
signal sig_125:std_logic_vector(63 downto 0);
signal sig_126:std_logic_vector(95 downto 0);
signal sig_127:std_logic_vector(127 downto 0);
signal sig_128:std_logic_vector(4 downto 0);
signal sig_129:std_logic_vector(2 downto 0);
signal sig_130:std_logic;
signal sig_131:std_logic;
signal sig_132:std_logic;
signal sig_133:std_logic_vector(1 downto 0);
signal sig_134:std_logic_vector(1 downto 0);
signal sig_135:std_logic;
signal sig_136:std_logic_vector(63 downto 0);
signal round_key_int:std_logic_vector(127 downto 0);
signal start_cipher_int:std_logic;
signal sig_137:std_logic;
signal sig_138:std_logic;
signal sig_139:std_logic;
signal sig_140:std_logic;
signal sig_141:std_logic;
signal sig_142:std_logic;
signal sig_143:std_logic;
signal sig_144:std_logic;
signal sig_145:std_logic;
signal sig_146:std_logic;
signal sig_16:std_logic_vector(3 downto 0);


--component map declaration
component aes_round_key_first
   port(
      key:in std_logic_vector(127 downto 0);
      data_in:in std_logic_vector(127 downto 0);
      data_out:out std_logic_vector(127 downto 0);
      rst_n : in std_logic;
      clk : in std_logic
   );
end component;
type STATE_TYPE is (s0,s1,s2,s3,s4);
signal STATE:STATE_TYPE;
type CONTROL is (initialize
, load_msg
, first
, idle
, nonlinear
, linear
);
signal cmd : CONTROL;


begin


   --portmap
   label_aes_round_msgexp : aes_round_key_first port map (
         key => key,
         data_in => aes_data_in,
         data_out => aes_data_out,
         rst_n => rst_n,
         clk => clk
      );
   --register updates
   dpREG: process (clk,rst_n)
      begin
         if (rst_n = '0') then
            init_reg <= '0';
            load_reg <= '0';
            message_reg <= (others=>'0');
            counter_reg <= (others=>'0');
            counter_init <= (others=>'0');
            salt_reg <= (others=>'0');
            cntr0 <= (others=>'0');
            cntr1 <= (others=>'0');
            cntr2 <= (others=>'0');
            nlw_msg <= (others=>'0');
         elsif clk' event and clk = '1' then
            init_reg <= init_reg_wire;
            load_reg <= load_reg_wire;
            message_reg <= message_reg_wire;
            counter_reg <= counter_reg_wire;
            counter_init <= counter_init_wire;
            salt_reg <= salt_reg_wire;
            cntr0 <= cntr0_wire;
            cntr1 <= cntr1_wire;
            cntr2 <= cntr2_wire;
            nlw_msg <= nlw_msg_wire;

         end if;
      end process dpREG;


   --combinational logics
   dpCMB: process (init_reg,load_reg,message_reg,counter_reg,counter_init,salt_reg,cntr0,cntr1,cntr2,nlw_msg
,salt,counter,round_key_sig,key,aes_data_in,aes_data_out,sig_0,sig_1,sig_2,sig_3
,sig_4,sig_5,sig_6,sig_7,sig_8,sig_9,sig_10,sig_11,sig_12,sig_13
,sig_14,sig_15,sig_17,sig_18,sig_19,sig_20,sig_21,sig_22,sig_23,sig_24
,sig_25,sig_26,sig_27,sig_28,sig_29,sig_30,sig_31,sig_32,sig_33,sig_34
,sig_35,sig_36,sig_37,sig_38,sig_39,sig_40,sig_41,sig_42,sig_43,sig_44
,sig_45,sig_46,sig_47,sig_48,sig_49,sig_50,sig_51,sig_52,sig_53,sig_54
,sig_55,sig_56,sig_57,sig_58,sig_59,sig_60,sig_61,sig_62,sig_63,sig_64
,sig_65,sig_66,sig_67,sig_68,sig_69,sig_70,sig_71,sig_72,sig_73,sig_74
,sig_75,sig_76,sig_77,sig_78,sig_79,sig_80,sig_81,sig_82,sig_83,sig_84
,sig_85,sig_86,sig_87,sig_88,sig_89,sig_90,sig_91,sig_92,sig_93,sig_94
,sig_95,sig_96,sig_97,sig_98,sig_99,sig_100,sig_101,sig_102,sig_103,sig_104
,sig_105,sig_106,sig_107,sig_108,sig_109,sig_110,sig_111,sig_112,sig_113,sig_114
,sig_115,sig_116,sig_117,sig_118,sig_119,sig_120,sig_121,sig_122,sig_123,sig_124
,sig_125,sig_126,sig_127,sig_128,sig_129,sig_130,sig_131,sig_132,sig_133,sig_134
,sig_135,sig_136,round_key_int,start_cipher_int,init,load,message,cmd,STATE)
      begin
         init_reg_wire <= init_reg;
         load_reg_wire <= load_reg;
         message_reg_wire <= message_reg;
         counter_reg_wire <= counter_reg;
         counter_init_wire <= counter_init;
         salt_reg_wire <= salt_reg;
         cntr0_wire <= cntr0;
         cntr1_wire <= cntr1;
         cntr2_wire <= cntr2;
         nlw_msg_wire <= nlw_msg;
         salt <= (others=>'0');
         counter <= (others=>'0');
         round_key_sig <= (others=>'0');
         key <= (others=>'0');
         aes_data_in <= (others=>'0');
         sig_0 <= '0';
         sig_1 <= '0';
         sig_2 <= '0';
         sig_3 <= (others=>'0');
         sig_4 <= (others=>'0');
         sig_5 <= (others=>'0');
         sig_6 <= (others=>'0');
         sig_7 <= '0';
         sig_8 <= '0';
         sig_9 <= '0';
         sig_10 <= (others=>'0');
         sig_11 <= (others=>'0');
         sig_12 <= (others=>'0');
         sig_13 <= (others=>'0');
         sig_14 <= '0';
         sig_15 <= (others=>'0');
         sig_17 <= (others=>'0');
         sig_18 <= (others=>'0');
         sig_19 <= '0';
         sig_20 <= '0';
         sig_21 <= '0';
         sig_22 <= (others=>'0');
         sig_23 <= (others=>'0');
         sig_24 <= (others=>'0');
         sig_25 <= (others=>'0');
         sig_26 <= '0';
         sig_27 <= '0';
         sig_28 <= (others=>'0');
         sig_29 <= (others=>'0');
         sig_30 <= (others=>'0');
         sig_31 <= (others=>'0');
         sig_32 <= '0';
         sig_33 <= '0';
         sig_34 <= '0';
         sig_35 <= (others=>'0');
         sig_36 <= (others=>'0');
         sig_37 <= (others=>'0');
         sig_38 <= (others=>'0');
         sig_39 <= (others=>'0');
         sig_40 <= '0';
         sig_41 <= (others=>'0');
         sig_42 <= '0';
         sig_43 <= '0';
         sig_44 <= '0';
         sig_45 <= (others=>'0');
         sig_46 <= (others=>'0');
         sig_47 <= (others=>'0');
         sig_48 <= (others=>'0');
         sig_49 <= (others=>'0');
         sig_50 <= '0';
         sig_51 <= (others=>'0');
         sig_52 <= (others=>'0');
         sig_53 <= (others=>'0');
         sig_54 <= (others=>'0');
         sig_55 <= (others=>'0');
         sig_56 <= (others=>'0');
         sig_57 <= (others=>'0');
         sig_58 <= (others=>'0');
         sig_59 <= (others=>'0');
         sig_60 <= (others=>'0');
         sig_61 <= '0';
         sig_62 <= (others=>'0');
         sig_63 <= (others=>'0');
         sig_64 <= (others=>'0');
         sig_65 <= (others=>'0');
         sig_66 <= (others=>'0');
         sig_67 <= (others=>'0');
         sig_68 <= (others=>'0');
         sig_69 <= (others=>'0');
         sig_70 <= (others=>'0');
         sig_71 <= (others=>'0');
         sig_72 <= '0';
         sig_73 <= (others=>'0');
         sig_74 <= (others=>'0');
         sig_75 <= (others=>'0');
         sig_76 <= (others=>'0');
         sig_77 <= (others=>'0');
         sig_78 <= (others=>'0');
         sig_79 <= (others=>'0');
         sig_80 <= (others=>'0');
         sig_81 <= (others=>'0');
         sig_82 <= (others=>'0');
         sig_83 <= '0';
         sig_84 <= (others=>'0');
         sig_85 <= (others=>'0');
         sig_86 <= (others=>'0');
         sig_87 <= (others=>'0');
         sig_88 <= (others=>'0');
         sig_89 <= (others=>'0');
         sig_90 <= (others=>'0');
         sig_91 <= (others=>'0');
         sig_92 <= (others=>'0');
         sig_93 <= (others=>'0');
         sig_94 <= (others=>'0');
         sig_95 <= (others=>'0');
         sig_96 <= (others=>'0');
         sig_97 <= (others=>'0');
         sig_98 <= (others=>'0');
         sig_99 <= (others=>'0');
         sig_100 <= (others=>'0');
         sig_101 <= (others=>'0');
         sig_102 <= (others=>'0');
         sig_103 <= (others=>'0');
         sig_104 <= (others=>'0');
         sig_105 <= '0';
         sig_106 <= '0';
         sig_107 <= '0';
         sig_108 <= (others=>'0');
         sig_109 <= (others=>'0');
         sig_110 <= '0';
         sig_111 <= (others=>'0');
         sig_112 <= (others=>'0');
         sig_113 <= (others=>'0');
         sig_114 <= (others=>'0');
         sig_115 <= (others=>'0');
         sig_116 <= (others=>'0');
         sig_117 <= (others=>'0');
         sig_118 <= (others=>'0');
         sig_119 <= (others=>'0');
         sig_120 <= (others=>'0');
         sig_121 <= '0';
         sig_122 <= '0';
         sig_123 <= '0';
         sig_124 <= (others=>'0');
         sig_125 <= (others=>'0');
         sig_126 <= (others=>'0');
         sig_127 <= (others=>'0');
         sig_128 <= (others=>'0');
         sig_129 <= (others=>'0');
         sig_130 <= '0';
         sig_131 <= '0';
         sig_132 <= '0';
         sig_133 <= (others=>'0');
         sig_134 <= (others=>'0');
         sig_135 <= '0';
         sig_136 <= (others=>'0');
         round_key_int <= (others=>'0');
         start_cipher_int <= '0';
         sig_16 <= "0000";
         round_key <= (others=>'0');
         start_cipher <= '0';



         case cmd is
            when initialize =>
               round_key_sig <= message_reg(511 downto 384);
               if (unsigned(cntr0(2 downto 0)) = 4) then
                  sig_0 <= '1';
               else
                  sig_0 <= '0';
               end if;
               if (unsigned(cntr0(2 downto 0)) = 6) then
                  sig_1 <= '1';
               else
                  sig_1 <= '0';
               end if;
               sig_2 <= sig_0 or sig_1;
               if (sig_2 = '1') then
                  sig_3 <= salt_reg(127 downto 0);
               else
                  sig_3 <= salt_reg(255 downto 128);
               end if;
               key <= sig_3;
               sig_4 <= message_reg(479 downto 448) & message_reg(447 downto 416);
               sig_5 <= sig_4 & message_reg(415 downto 384);
               sig_6 <= sig_5 & message_reg(511 downto 480);
               aes_data_in <= sig_6;
               round_key <= round_key_int;
               start_cipher <= start_cipher_int;
               round_key_int <= round_key_sig;
               start_cipher_int <= '0';
               init_reg_wire <= init;
               load_reg_wire <= load;
               cntr0_wire <= conv_std_logic_vector(0,5);
               cntr1_wire <= conv_std_logic_vector(0,3);
               cntr2_wire <= conv_std_logic_vector(0,2);
               nlw_msg_wire <= conv_std_logic_vector(0,6);
               message_reg_wire <= conv_std_logic_vector(0,512);
               counter_reg_wire <= conv_std_logic_vector(0,64);
               salt_reg_wire <= conv_std_logic_vector(0,256);
               counter_init_wire <= conv_std_logic_vector(unsigned(message),64);
            when load_msg =>
               salt <= conv_std_logic_vector(unsigned(sig_16),256);
               sig_17 <= message_reg(495 downto 0) & message;
               sig_18 <= unsigned(nlw_msg) + unsigned(conv_std_logic_vector(1,6));
               round_key_sig <= message_reg(511 downto 384);
               if (unsigned(cntr0(2 downto 0)) = 4) then
                  sig_19 <= '1';
               else
                  sig_19 <= '0';
               end if;
               if (unsigned(cntr0(2 downto 0)) = 6) then
                  sig_20 <= '1';
               else
                  sig_20 <= '0';
               end if;
               sig_21 <= sig_19 or sig_20;
               if (sig_21 = '1') then
                  sig_22 <= salt_reg(127 downto 0);
               else
                  sig_22 <= salt_reg(255 downto 128);
               end if;
               key <= sig_22;
               sig_23 <= message_reg(479 downto 448) & message_reg(447 downto 416);
               sig_24 <= sig_23 & message_reg(415 downto 384);
               sig_25 <= sig_24 & message_reg(511 downto 480);
               aes_data_in <= sig_25;
               if (unsigned(counter_reg) > unsigned(counter_init)) then
                  sig_26 <= '1';
               else
                  sig_26 <= '0';
               end if;
               if (unsigned(nlw_msg) = 31) then
                  sig_27 <= '1';
               else
                  sig_27 <= '0';
               end if;
               sig_28 <= unsigned(counter_reg) + unsigned(conv_std_logic_vector(512,64));
               if (sig_27 = '1') then
                  sig_29 <= sig_28;
               else
                  sig_29 <= counter_reg;
               end if;
               if (sig_26 = '1') then
                  sig_30 <= counter_init;
               else
                  sig_30 <= sig_29;
               end if;
               round_key <= round_key_int;
               start_cipher <= start_cipher_int;
               round_key_int <= round_key_sig;
               start_cipher_int <= '0';
               init_reg_wire <= init;
               load_reg_wire <= load;
               message_reg_wire <= sig_17;
               nlw_msg_wire <= sig_18;
               salt_reg_wire <= salt;
               cntr0_wire <= conv_std_logic_vector(0,5);
               cntr1_wire <= conv_std_logic_vector(0,3);
               cntr2_wire <= conv_std_logic_vector(0,2);
               counter_reg_wire <= sig_30;
            when first =>
               round_key_sig <= message_reg(511 downto 384);
               sig_31 <= message_reg(383 downto 0) & message_reg(511 downto 384);
               if (unsigned(cntr0(2 downto 0)) = 4) then
                  sig_32 <= '1';
               else
                  sig_32 <= '0';
               end if;
               if (unsigned(cntr0(2 downto 0)) = 6) then
                  sig_33 <= '1';
               else
                  sig_33 <= '0';
               end if;
               sig_34 <= sig_32 or sig_33;
               if (sig_34 = '1') then
                  sig_35 <= salt_reg(127 downto 0);
               else
                  sig_35 <= salt_reg(255 downto 128);
               end if;
               key <= sig_35;
               sig_36 <= message_reg(479 downto 448) & message_reg(447 downto 416);
               sig_37 <= sig_36 & message_reg(415 downto 384);
               sig_38 <= sig_37 & message_reg(511 downto 480);
               aes_data_in <= sig_38;
               sig_39 <= unsigned(cntr0) + unsigned(conv_std_logic_vector(1,5));
               if (unsigned(counter_reg) > unsigned(counter_init)) then
                  sig_40 <= '1';
               else
                  sig_40 <= '0';
               end if;
               if (sig_40 = '1') then
                  sig_41 <= counter_init;
               else
                  sig_41 <= counter_reg;
               end if;
               round_key <= round_key_int;
               start_cipher <= start_cipher_int;
               round_key_int <= round_key_sig;
               start_cipher_int <= '1';
               init_reg_wire <= init;
               load_reg_wire <= load;
               message_reg_wire <= sig_31;
               cntr0_wire <= sig_39;
               nlw_msg_wire <= conv_std_logic_vector(0,6);
               counter_reg_wire <= sig_41;
            when idle =>
               round_key_sig <= message_reg(511 downto 384);
               if (unsigned(cntr0(2 downto 0)) = 4) then
                  sig_7 <= '1';
               else
                  sig_7 <= '0';
               end if;
               if (unsigned(cntr0(2 downto 0)) = 6) then
                  sig_8 <= '1';
               else
                  sig_8 <= '0';
               end if;
               sig_9 <= sig_7 or sig_8;
               if (sig_9 = '1') then
                  sig_10 <= salt_reg(127 downto 0);
               else
                  sig_10 <= salt_reg(255 downto 128);
               end if;
               key <= sig_10;
               sig_11 <= message_reg(479 downto 448) & message_reg(447 downto 416);
               sig_12 <= sig_11 & message_reg(415 downto 384);
               sig_13 <= sig_12 & message_reg(511 downto 480);
               aes_data_in <= sig_13;
               if (unsigned(counter_reg) > unsigned(counter_init)) then
                  sig_14 <= '1';
               else
                  sig_14 <= '0';
               end if;
               if (sig_14 = '1') then
                  sig_15 <= counter_init;
               else
                  sig_15 <= counter_reg;
               end if;
               round_key <= round_key_int;
               start_cipher <= start_cipher_int;
               round_key_int <= round_key_sig;
               start_cipher_int <= '0';
               init_reg_wire <= init;
               load_reg_wire <= load;
               cntr0_wire <= conv_std_logic_vector(0,5);
               cntr1_wire <= conv_std_logic_vector(0,3);
               cntr2_wire <= conv_std_logic_vector(0,2);
               nlw_msg_wire <= conv_std_logic_vector(0,6);
               message_reg_wire <= conv_std_logic_vector(0,512);
               salt_reg_wire <= conv_std_logic_vector(0,256);
               counter_reg_wire <= sig_15;
            when nonlinear =>
               if (unsigned(cntr0(2 downto 0)) = 4) then
                  sig_42 <= '1';
               else
                  sig_42 <= '0';
               end if;
               if (unsigned(cntr0(2 downto 0)) = 6) then
                  sig_43 <= '1';
               else
                  sig_43 <= '0';
               end if;
               sig_44 <= sig_42 or sig_43;
               if (sig_44 = '1') then
                  sig_45 <= salt_reg(127 downto 0);
               else
                  sig_45 <= salt_reg(255 downto 128);
               end if;
               key <= sig_45;
               sig_46 <= message_reg(479 downto 448) & message_reg(447 downto 416);
               sig_47 <= sig_46 & message_reg(415 downto 384);
               sig_48 <= sig_47 & message_reg(511 downto 480);
               aes_data_in <= sig_48;
               sig_49 <= message_reg(383 downto 0) & round_key_sig;
               if (unsigned(cntr0) = 4) then
                  sig_50 <= '1';
               else
                  sig_50 <= '0';
               end if;
               sig_51 <= aes_data_out(127 downto 96) xor counter_reg(31 downto 0);
               sig_52 <= sig_51 xor message_reg(127 downto 96);
               sig_53 <=  not counter_reg(63 downto 32);
               sig_54 <= aes_data_out(95 downto 64) xor sig_53;
               sig_55 <= sig_54 xor message_reg(95 downto 64);
               sig_56 <= sig_52 & sig_55;
               sig_57 <= aes_data_out(63 downto 32) xor message_reg(63 downto 32);
               sig_58 <= sig_56 & sig_57;
               sig_59 <= aes_data_out(31 downto 0) xor message_reg(31 downto 0);
               sig_60 <= sig_58 & sig_59;
               if (unsigned(cntr0) = 14) then
                  sig_61 <= '1';
               else
                  sig_61 <= '0';
               end if;
               sig_62 <= aes_data_out(127 downto 96) xor message_reg(127 downto 96);
               sig_63 <= aes_data_out(95 downto 64) xor counter_reg(63 downto 32);
               sig_64 <= sig_63 xor message_reg(95 downto 64);
               sig_65 <= sig_62 & sig_64;
               sig_66 <=  not counter_reg(31 downto 0);
               sig_67 <= aes_data_out(63 downto 32) xor sig_66;
               sig_68 <= sig_67 xor message_reg(63 downto 32);
               sig_69 <= sig_65 & sig_68;
               sig_70 <= aes_data_out(31 downto 0) xor message_reg(31 downto 0);
               sig_71 <= sig_69 & sig_70;
               if (unsigned(cntr0) = 21) then
                  sig_72 <= '1';
               else
                  sig_72 <= '0';
               end if;
               sig_73 <= aes_data_out(127 downto 96) xor message_reg(127 downto 96);
               sig_74 <= aes_data_out(95 downto 64) xor message_reg(95 downto 64);
               sig_75 <= sig_73 & sig_74;
               sig_76 <= aes_data_out(63 downto 32) xor counter_reg(63 downto 32);
               sig_77 <= sig_76 xor message_reg(63 downto 32);
               sig_78 <= sig_75 & sig_77;
               sig_79 <=  not counter_reg(31 downto 0);
               sig_80 <= aes_data_out(31 downto 0) xor sig_79;
               sig_81 <= sig_80 xor message_reg(31 downto 0);
               sig_82 <= sig_78 & sig_81;
               if (unsigned(cntr0) = 31) then
                  sig_83 <= '1';
               else
                  sig_83 <= '0';
               end if;
               sig_84 <= aes_data_out(127 downto 96) xor counter_reg(31 downto 0);
               sig_85 <= sig_84 xor message_reg(127 downto 96);
               sig_86 <= aes_data_out(95 downto 64) xor message_reg(95 downto 64);
               sig_87 <= sig_85 & sig_86;
               sig_88 <= aes_data_out(63 downto 32) xor message_reg(63 downto 32);
               sig_89 <= sig_87 & sig_88;
               sig_90 <=  not counter_reg(63 downto 32);
               sig_91 <= aes_data_out(31 downto 0) xor sig_90;
               sig_92 <= sig_91 xor message_reg(31 downto 0);
               sig_93 <= sig_89 & sig_92;
               sig_94 <= aes_data_out(127 downto 96) xor message_reg(127 downto 96);
               sig_95 <= aes_data_out(95 downto 64) xor message_reg(95 downto 64);
               sig_96 <= sig_94 & sig_95;
               sig_97 <= aes_data_out(63 downto 32) xor message_reg(63 downto 32);
               sig_98 <= sig_96 & sig_97;
               sig_99 <= aes_data_out(31 downto 0) xor message_reg(31 downto 0);
               sig_100 <= sig_98 & sig_99;
               if (sig_83 = '1') then
                  sig_101 <= sig_93;
               else
                  sig_101 <= sig_100;
               end if;
               if (sig_50 = '1') then
                  sig_102 <= sig_60;
               elsif (sig_61 = '1') then
                  sig_102 <= sig_71;
               elsif (sig_72 = '1') then
                  sig_102 <= sig_82;
               else
                  sig_102 <= sig_101;
               end if;
               round_key_sig <= sig_102;
               sig_103 <= unsigned(cntr0) + unsigned(conv_std_logic_vector(1,5));
               sig_104 <= unsigned(cntr1) + unsigned(conv_std_logic_vector(1,3));
               if (unsigned(cntr0) = 5) then
                  sig_105 <= '1';
               else
                  sig_105 <= '0';
               end if;
               if (unsigned(cntr1) = 1) then
                  sig_106 <= '1';
               else
                  sig_106 <= '0';
               end if;
               sig_107 <= sig_105 and sig_106;
               sig_108 <= unsigned(cntr2) + unsigned(conv_std_logic_vector(1,2));
               if (sig_107 = '1') then
                  sig_109 <= sig_108;
               else
                  sig_109 <= cntr2;
               end if;
               if (unsigned(counter_reg) > unsigned(counter_init)) then
                  sig_110 <= '1';
               else
                  sig_110 <= '0';
               end if;
               if (sig_110 = '1') then
                  sig_111 <= counter_init;
               else
                  sig_111 <= counter_reg;
               end if;
               round_key <= round_key_int;
               start_cipher <= start_cipher_int;
               round_key_int <= round_key_sig;
               start_cipher_int <= '1';
               init_reg_wire <= init;
               load_reg_wire <= load;
               message_reg_wire <= sig_49;
               cntr0_wire <= sig_103;
               cntr1_wire <= sig_104;
               cntr2_wire <= sig_109;
               nlw_msg_wire <= conv_std_logic_vector(0,6);
               counter_reg_wire <= sig_111;
            when linear =>
               sig_112 <= message_reg(511 downto 480) xor message_reg(95 downto 64);
               sig_113 <= message_reg(479 downto 448) xor message_reg(63 downto 32);
               sig_114 <= sig_112 & sig_113;
               sig_115 <= message_reg(447 downto 416) xor message_reg(31 downto 0);
               sig_116 <= sig_114 & sig_115;
               sig_117 <= message_reg(511 downto 480) xor message_reg(95 downto 64);
               sig_118 <= sig_117 xor message_reg(415 downto 384);
               sig_119 <= sig_116 & sig_118;
               round_key_sig <= sig_119;
               sig_120 <= message_reg(383 downto 0) & round_key_sig;
               if (unsigned(cntr0(2 downto 0)) = 4) then
                  sig_121 <= '1';
               else
                  sig_121 <= '0';
               end if;
               if (unsigned(cntr0(2 downto 0)) = 6) then
                  sig_122 <= '1';
               else
                  sig_122 <= '0';
               end if;
               sig_123 <= sig_121 or sig_122;
               if (sig_123 = '1') then
                  sig_124 <= salt_reg(127 downto 0);
               else
                  sig_124 <= salt_reg(255 downto 128);
               end if;
               key <= sig_124;
               sig_125 <= message_reg(479 downto 448) & message_reg(447 downto 416);
               sig_126 <= sig_125 & message_reg(415 downto 384);
               sig_127 <= sig_126 & message_reg(511 downto 480);
               aes_data_in <= sig_127;
               sig_128 <= unsigned(cntr0) + unsigned(conv_std_logic_vector(1,5));
               sig_129 <= unsigned(cntr1) + unsigned(conv_std_logic_vector(1,3));
               if (unsigned(cntr0) = 5) then
                  sig_130 <= '1';
               else
                  sig_130 <= '0';
               end if;
               if (unsigned(cntr1) = 1) then
                  sig_131 <= '1';
               else
                  sig_131 <= '0';
               end if;
               sig_132 <= sig_130 and sig_131;
               sig_133 <= unsigned(cntr2) + unsigned(conv_std_logic_vector(1,2));
               if (sig_132 = '1') then
                  sig_134 <= sig_133;
               else
                  sig_134 <= cntr2;
               end if;
               if (unsigned(counter_reg) > unsigned(counter_init)) then
                  sig_135 <= '1';
               else
                  sig_135 <= '0';
               end if;
               if (sig_135 = '1') then
                  sig_136 <= counter_init;
               else
                  sig_136 <= counter_reg;
               end if;
               round_key <= round_key_int;
               start_cipher <= start_cipher_int;
               round_key_int <= round_key_sig;
               start_cipher_int <= '1';
               init_reg_wire <= init;
               load_reg_wire <= load;
               message_reg_wire <= sig_120;
               cntr0_wire <= sig_128;
               cntr1_wire <= sig_129;
               cntr2_wire <= sig_134;
               nlw_msg_wire <= conv_std_logic_vector(0,6);
               counter_reg_wire <= sig_136;
            when others=>
         end case;
      end process dpCMB;


   --controller reg
   fsmREG: process (clk,rst_n)
      begin
         if (rst_n = '0') then
            STATE <= s0;
         elsif clk' event and clk = '1' then
            STATE <= STATE;
            case STATE is
               when s0 => 
                  if (init_reg = '1') then
                          STATE <= s0;
                  else
                     if (load_reg = '1') then
                             STATE <= s1;
                     else
                             STATE <= s0;
                     end if;
                  end if;
               when s1 => 
                  if (init_reg = '1') then
                          STATE <= s0;
                  else
                     if (sig_138 = '1') then
                             STATE <= s1;
                     else
                        if (sig_139 = '1') then
                                STATE <= s2;
                        else
                                STATE <= s1;
                        end if;
                     end if;
                  end if;
               when s2 => 
                  if (init_reg = '1') then
                          STATE <= s0;
                  else
                     if (sig_140 = '1') then
                             STATE <= s2;
                     else
                             STATE <= s3;
                     end if;
                  end if;
               when s3 => 
                  if (init_reg = '1') then
                          STATE <= s0;
                  else
                     if (sig_142 = '1') then
                             STATE <= s1;
                     else
                        if (sig_143 = '1') then
                                STATE <= s3;
                        else
                                STATE <= s4;
                        end if;
                     end if;
                  end if;
               when s4 => 
                  if (init_reg = '1') then
                          STATE <= s0;
                  else
                     if (sig_145 = '1') then
                             STATE <= s1;
                     else
                        if (sig_146 = '1') then
                                STATE <= s3;
                        else
                                STATE <= s4;
                        end if;
                     end if;
                  end if;
               when others=>
            end case;
         end if;
      end process fsmREG;


   --controller cmb
   fsmCMB: process (init_reg,load_reg,message_reg,counter_reg,counter_init,salt_reg,cntr0,cntr1,cntr2,nlw_msg
,salt,counter,round_key_sig,key,aes_data_in,aes_data_out,sig_0,sig_1,sig_2,sig_3
,sig_4,sig_5,sig_6,sig_7,sig_8,sig_9,sig_10,sig_11,sig_12,sig_13
,sig_14,sig_15,sig_17,sig_18,sig_19,sig_20,sig_21,sig_22,sig_23,sig_24
,sig_25,sig_26,sig_27,sig_28,sig_29,sig_30,sig_31,sig_32,sig_33,sig_34
,sig_35,sig_36,sig_37,sig_38,sig_39,sig_40,sig_41,sig_42,sig_43,sig_44
,sig_45,sig_46,sig_47,sig_48,sig_49,sig_50,sig_51,sig_52,sig_53,sig_54
,sig_55,sig_56,sig_57,sig_58,sig_59,sig_60,sig_61,sig_62,sig_63,sig_64
,sig_65,sig_66,sig_67,sig_68,sig_69,sig_70,sig_71,sig_72,sig_73,sig_74
,sig_75,sig_76,sig_77,sig_78,sig_79,sig_80,sig_81,sig_82,sig_83,sig_84
,sig_85,sig_86,sig_87,sig_88,sig_89,sig_90,sig_91,sig_92,sig_93,sig_94
,sig_95,sig_96,sig_97,sig_98,sig_99,sig_100,sig_101,sig_102,sig_103,sig_104
,sig_105,sig_106,sig_107,sig_108,sig_109,sig_110,sig_111,sig_112,sig_113,sig_114
,sig_115,sig_116,sig_117,sig_118,sig_119,sig_120,sig_121,sig_122,sig_123,sig_124
,sig_125,sig_126,sig_127,sig_128,sig_129,sig_130,sig_131,sig_132,sig_133,sig_134
,sig_135,sig_136,round_key_int,start_cipher_int,sig_137,sig_138,sig_139,sig_140,sig_141,sig_142
,sig_143,sig_144,sig_145,sig_146,init,load,message,cmd,STATE)
      begin
      sig_137 <= '0';
      sig_138 <= '0';
      sig_139 <= '0';
      sig_140 <= '0';
      sig_141 <= '0';
      sig_142 <= '0';
      sig_143 <= '0';
      sig_144 <= '0';
      sig_145 <= '0';
      sig_146 <= '0';
      if (unsigned(nlw_msg) < 32) then
         sig_137 <= '1';
      else
         sig_137 <= '0';
      end if;
      sig_138 <= load_reg and sig_137;
      if (unsigned(nlw_msg) = 32) then
         sig_139 <= '1';
      else
         sig_139 <= '0';
      end if;
      if (unsigned(cntr0) <= 3) then
         sig_140 <= '1';
      else
         sig_140 <= '0';
      end if;
      if (unsigned(cntr2) = 2) then
         sig_141 <= '1';
      else
         sig_141 <= '0';
      end if;
      sig_142 <= load_reg and sig_141;
      if (unsigned(cntr1) <= 3) then
         sig_143 <= '1';
      else
         sig_143 <= '0';
      end if;
      if (unsigned(cntr2) = 2) then
         sig_144 <= '1';
      else
         sig_144 <= '0';
      end if;
      sig_145 <= load_reg and sig_144;
      if (unsigned(cntr1) = 0) then
         sig_146 <= '1';
      else
         sig_146 <= '0';
      end if;
      cmd <= initialize;
      case STATE is
         when s0 => 
            if (init_reg = '1') then
                    cmd <= initialize;
            else
               if (load_reg = '1') then
                       cmd <= load_msg;
               else
                       cmd <= initialize;
               end if;
            end if;
         when s1 => 
            if (init_reg = '1') then
                    cmd <= initialize;
            else
               if (sig_138 = '1') then
                       cmd <= load_msg;
               else
                  if (sig_139 = '1') then
                          cmd <= first;
                  else
                          cmd <= idle;
                  end if;
               end if;
            end if;
         when s2 => 
            if (init_reg = '1') then
                    cmd <= initialize;
            else
               if (sig_140 = '1') then
                       cmd <= first;
               else
                       cmd <= nonlinear;
               end if;
            end if;
         when s3 => 
            if (init_reg = '1') then
                    cmd <= initialize;
            else
               if (sig_142 = '1') then
                       cmd <= load_msg;
               else
                  if (sig_143 = '1') then
                          cmd <= nonlinear;
                  else
                          cmd <= linear;
                  end if;
               end if;
            end if;
         when s4 => 
            if (init_reg = '1') then
                    cmd <= initialize;
            else
               if (sig_145 = '1') then
                       cmd <= load_msg;
               else
                  if (sig_146 = '1') then
                          cmd <= nonlinear;
                  else
                          cmd <= linear;
                  end if;
               end if;
            end if;
         when others=>
         end case;
   end process fsmCMB;
end RTL;
