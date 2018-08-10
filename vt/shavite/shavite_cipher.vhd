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
entity shavite_cipher is
   port(
      start     :in  std_logic;
      data_in   :in  std_logic_vector(255 downto 0);
      round_key :in  std_logic_vector(127 downto 0);
      hash      :out std_logic_vector(255 downto 0);
      done      :out std_logic;
      rst_n     :in  std_logic;
      clk       :in  std_logic

   );
end shavite_cipher;


--signal declaration
architecture RTL of shavite_cipher is
signal key_reg:std_logic_vector(127 downto 0);
signal key_reg_wire:std_logic_vector(127 downto 0);
signal aes_reg:std_logic_vector(127 downto 0);
signal aes_reg_wire:std_logic_vector(127 downto 0);
signal L:std_logic_vector(127 downto 0);
signal L_wire:std_logic_vector(127 downto 0);
signal R:std_logic_vector(127 downto 0);
signal R_wire:std_logic_vector(127 downto 0);
signal round_cntr:std_logic_vector(3 downto 0);
signal round_cntr_wire:std_logic_vector(3 downto 0);
signal step_cntr:std_logic_vector(1 downto 0);
signal step_cntr_wire:std_logic_vector(1 downto 0);
signal key_i:std_logic_vector(127 downto 0);
signal aes_data_in:std_logic_vector(127 downto 0);
signal aes_data_out:std_logic_vector(127 downto 0);
signal sig_0:std_logic;
signal sig_1:std_logic;
signal sig_2:std_logic_vector(127 downto 0);
signal sig_3:std_logic_vector(127 downto 0);
signal sig_4:std_logic;
signal sig_5:std_logic;
signal sig_6:std_logic_vector(127 downto 0);
signal sig_7:std_logic_vector(127 downto 0);
signal sig_8:std_logic_vector(127 downto 0);
signal sig_9:std_logic;
signal sig_10:std_logic;
signal sig_11:std_logic_vector(1 downto 0);
signal sig_12:std_logic_vector(1 downto 0);
signal sig_13:std_logic_vector(1 downto 0);
signal sig_14:std_logic;
signal sig_15:std_logic;
signal sig_16:std_logic;
signal sig_17:std_logic_vector(127 downto 0);
signal sig_18:std_logic;
signal sig_19:std_logic;
signal sig_20:std_logic_vector(3 downto 0);
signal sig_21:std_logic_vector(3 downto 0);
signal sig_22:std_logic_vector(3 downto 0);
signal sig_23:std_logic_vector(255 downto 0);
signal sig_24:std_logic_vector(255 downto 0);
signal sig_25:std_logic;
signal sig_26:std_logic;
signal sig_27:std_logic;
signal sig_28:std_logic;
signal hash_int:std_logic_vector(255 downto 0);
signal done_int:std_logic;


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


begin


   --portmap
   label_aes_round_cipher : aes_round_key_first port map (
         key => key_i,
         data_in => aes_data_in,
         data_out => aes_data_out,
         rst_n => rst_n,
         clk => clk
      );
   --register updates
   dpREG: process (clk,rst_n)
      begin
         if (rst_n = '0') then
            key_reg <= (others=>'0');
            aes_reg <= (others=>'0');
            L <= (others=>'0');
            R <= (others=>'0');
            round_cntr <= (others=>'0');
            step_cntr <= (others=>'0');
         elsif clk' event and clk = '1' then
            key_reg <= key_reg_wire;
            aes_reg <= aes_reg_wire;
            L <= L_wire;
            R <= R_wire;
            round_cntr <= round_cntr_wire;
            step_cntr <= step_cntr_wire;

         end if;
      end process dpREG;


   --combinational logics
   dpCMB: process (key_reg,aes_reg,L,R,round_cntr,step_cntr,key_i,aes_data_in,aes_data_out,sig_0
,sig_1,sig_2,sig_3,sig_4,sig_5,sig_6,sig_7,sig_8,sig_9,sig_10
,sig_11,sig_12,sig_13,sig_14,sig_15,sig_16,sig_17,sig_18,sig_19,sig_20
,sig_21,sig_22,sig_23,sig_24,sig_25,sig_26,sig_27,sig_28,hash_int,done_int
,start,data_in,round_key)
      begin
         key_reg_wire <= key_reg;
         aes_reg_wire <= aes_reg;
         L_wire <= L;
         R_wire <= R;
         round_cntr_wire <= round_cntr;
         step_cntr_wire <= step_cntr;
         key_i <= (others=>'0');
         aes_data_in <= (others=>'0');
         sig_0 <= '0';
         sig_1 <= '0';
         sig_2 <= (others=>'0');
         sig_3 <= (others=>'0');
         sig_4 <= '0';
         sig_5 <= '0';
         sig_6 <= (others=>'0');
         sig_7 <= (others=>'0');
         sig_8 <= (others=>'0');
         sig_9 <= '0';
         sig_10 <= '0';
         sig_11 <= (others=>'0');
         sig_12 <= (others=>'0');
         sig_13 <= (others=>'0');
         sig_14 <= '0';
         sig_15 <= '0';
         sig_16 <= '0';
         sig_17 <= (others=>'0');
         sig_18 <= '0';
         sig_19 <= '0';
         sig_20 <= (others=>'0');
         sig_21 <= (others=>'0');
         sig_22 <= (others=>'0');
         sig_23 <= (others=>'0');
         sig_24 <= (others=>'0');
         sig_25 <= '0';
         sig_26 <= '0';
         sig_27 <= '0';
         sig_28 <= '0';
         hash_int <= (others=>'0');
         done_int <= '0';
         hash <= (others=>'0');
         done <= '0';

         sig_0 <=  not start;
         if (unsigned(step_cntr) = 2) then
            sig_1 <= '1';
         else
            sig_1 <= '0';
         end if;
         if (sig_1 = '1') then
            sig_2 <= R;
         else
            sig_2 <= L;
         end if;
         if (sig_0 = '1') then
            sig_3 <= data_in(255 downto 128);
         else
            sig_3 <= sig_2;
         end if;
         sig_4 <=  not start;
         if (unsigned(step_cntr) = 2) then
            sig_5 <= '1';
         else
            sig_5 <= '0';
         end if;
         sig_6 <= aes_data_out xor L;
         if (sig_5 = '1') then
            sig_7 <= sig_6;
         else
            sig_7 <= R;
         end if;
         if (sig_4 = '1') then
            sig_8 <= data_in(127 downto 0);
         else
            sig_8 <= sig_7;
         end if;
         sig_9 <=  not start;
         if (unsigned(step_cntr) = 3) then
            sig_10 <= '1';
         else
            sig_10 <= '0';
         end if;
         sig_11 <= unsigned(step_cntr) + unsigned(conv_std_logic_vector(1,2));
         if (sig_10 = '1') then
            sig_12 <= conv_std_logic_vector(1,2);
         else
            sig_12 <= sig_11;
         end if;
         if (sig_9 = '1') then
            sig_13 <= conv_std_logic_vector(0,2);
         else
            sig_13 <= sig_12;
         end if;
         key_i <= key_reg;
         if (unsigned(step_cntr) = 0) then
            sig_14 <= '1';
         else
            sig_14 <= '0';
         end if;
         if (unsigned(step_cntr) = 3) then
            sig_15 <= '1';
         else
            sig_15 <= '0';
         end if;
         sig_16 <= sig_14 or sig_15;
         if (sig_16 = '1') then
            sig_17 <= R;
         else
            sig_17 <= aes_reg;
         end if;
         aes_data_in <= sig_17;
         sig_18 <=  not start;
         if (unsigned(step_cntr) = 3) then
            sig_19 <= '1';
         else
            sig_19 <= '0';
         end if;
         sig_20 <= unsigned(round_cntr) + unsigned(conv_std_logic_vector(1,4));
         if (sig_19 = '1') then
            sig_21 <= sig_20;
         else
            sig_21 <= round_cntr;
         end if;
         if (sig_18 = '1') then
            sig_22 <= conv_std_logic_vector(0,4);
         else
            sig_22 <= sig_21;
         end if;
         sig_23 <= L & R;
         if (done_int = '1') then
            sig_24 <= sig_23;
         else
            sig_24 <= conv_std_logic_vector(0,256);
         end if;
         hash <= hash_int;
         if (unsigned(round_cntr) = 11) then
            sig_25 <= '1';
         else
            sig_25 <= '0';
         end if;
         if (unsigned(step_cntr) = 3) then
            sig_26 <= '1';
         else
            sig_26 <= '0';
         end if;
         sig_27 <= sig_25 and sig_26;
         if (sig_27 = '1') then
            sig_28 <= '1';
         else
            sig_28 <= '0';
         end if;
         done <= done_int;
         hash_int <= sig_24;
         done_int <= sig_28;
         L_wire <= sig_3;
         R_wire <= sig_8;
         aes_reg_wire <= aes_data_out;
         step_cntr_wire <= sig_13;
         key_reg_wire <= round_key;
         round_cntr_wire <= sig_22;
      end process dpCMB;
end RTL;
