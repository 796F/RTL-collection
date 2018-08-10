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
entity shavite_top is
   port(
       init  :in  std_logic;
       EoM   :in  std_logic;
       load  :in  std_logic;
       fetch :in  std_logic;
       ack   :out std_logic;
       idata :in  std_logic_vector(15 downto 0);
       odata :out std_logic_vector(15 downto 0);
       rst_n :in  std_logic;
       clk   :in  std_logic
       );
end shavite_top;

--signal declaration
architecture RTL of shavite_top is
signal chain:std_logic_vector(255 downto 0);
signal chain_wire:std_logic_vector(255 downto 0);
signal nlw_msg:std_logic_vector(5 downto 0);
signal nlw_msg_wire:std_logic_vector(5 downto 0);
signal nfw:std_logic_vector(4 downto 0);
signal nfw_wire:std_logic_vector(4 downto 0);
signal done_reg:std_logic;
signal done_reg_wire:std_logic;
signal init_reg:std_logic;
signal init_reg_wire:std_logic;
signal EoM_reg:std_logic;
signal EoM_reg_wire:std_logic;
signal load_reg:std_logic;
signal load_reg_wire:std_logic;
signal fetch_reg:std_logic;
signal fetch_reg_wire:std_logic;
signal start_0:std_logic;
signal start_0_wire:std_logic;
signal ack_reg:std_logic;
signal ack_reg_wire:std_logic;
signal round_key:std_logic_vector(127 downto 0);
signal start_cipher:std_logic;
signal start_cipher_out:std_logic;
signal done:std_logic;
signal hash:std_logic_vector(255 downto 0);
signal chain_sig:std_logic_vector(255 downto 0);
signal T0:std_logic_vector(127 downto 0);
signal T1:std_logic_vector(127 downto 0);
signal sig_2:std_logic_vector(255 downto 0);
signal sig_3:std_logic_vector(5 downto 0);
signal sig_4:std_logic_vector(255 downto 0);
signal sig_5:std_logic_vector(255 downto 0);
signal sig_6:std_logic_vector(255 downto 0);
signal sig_7:std_logic_vector(255 downto 0);
signal sig_8:std_logic_vector(4 downto 0);
signal sig_9:std_logic_vector(255 downto 0);
signal ack_int:std_logic;
signal odata_int:std_logic_vector(15 downto 0);
signal sig_10:std_logic;
signal sig_11:std_logic;
signal sig_12:std_logic;
signal sig_13:std_logic;
signal sig_14:std_logic;
signal sig_15:std_logic;
signal sig_0:std_logic_vector(127 downto 0);
signal sig_1:std_logic_vector(127 downto 0);


--component map declaration
component message_expansion
   port(
        init         :in  std_logic;
        load         :in  std_logic;
        message      :in  std_logic_vector(15 downto 0);
        round_key    :out std_logic_vector(127 downto 0);
        start_cipher :out std_logic;
        rst_n        :in  std_logic;
        clk          :in  std_logic
        );
end component;
	
component shavite_cipher
   port(
        start     :in  std_logic;
        data_in   :in  std_logic_vector(255 downto 0);
        round_key :in  std_logic_vector(127 downto 0);
        hash      :out std_logic_vector(255 downto 0);
        done      :out std_logic;
        rst_n     :in  std_logic;
        clk       :in  std_logic
       );
end component;
type STATE_TYPE is (s0,s1,s2,s3,s4);
signal STATE:STATE_TYPE;
type CONTROL is (initialize, 
	               load_msg, 
	               run, 
	               write, 
	               idle
                 );
signal cmd : CONTROL;

begin
   --portmap
   label_message_expansion : message_expansion port map (
         init => init,
         load => load,
         message => idata,
         round_key => round_key,
         start_cipher => start_cipher_out,
         rst_n => rst_n,
         clk => clk
      );
   label_shavite_cipher : shavite_cipher port map (
         start => start_cipher,
         data_in => chain_sig,
         round_key => round_key,
         hash => hash,
         done => done,
         rst_n => rst_n,
         clk => clk
      );
   --register updates
   dpREG: process (clk,rst_n)
      begin
         if (rst_n = '0') then
            chain <= (others=>'0');
            nlw_msg <= (others=>'0');
            nfw <= (others=>'0');
            done_reg <= '0';
            init_reg <= '0';
            EoM_reg <= '0';
            load_reg <= '0';
            fetch_reg <= '0';
            start_0 <= '0';
            ack_reg <= '0';
         elsif clk' event and clk = '1' then
            chain <= chain_wire;
            nlw_msg <= nlw_msg_wire;
            nfw <= nfw_wire;
            done_reg <= done_reg_wire;
            init_reg <= init_reg_wire;
            EoM_reg <= EoM_reg_wire;
            load_reg <= load_reg_wire;
            fetch_reg <= fetch_reg_wire;
            start_0 <= start_0_wire;
            ack_reg <= ack_reg_wire;

         end if;
      end process dpREG;


   --combinational logics
   dpCMB: process (chain,nlw_msg,nfw,done_reg,init_reg,EoM_reg,load_reg,fetch_reg,start_0,ack_reg
,round_key,start_cipher,start_cipher_out,done,hash,chain_sig,T0,T1,sig_2,sig_3
,sig_4,sig_5,sig_6,sig_7,sig_8,sig_9,ack_int,odata_int,init,EoM
,load,fetch,idata,cmd,STATE)
      begin
         chain_wire <= chain;
         nlw_msg_wire <= nlw_msg;
         nfw_wire <= nfw;
         done_reg_wire <= done_reg;
         init_reg_wire <= init_reg;
         EoM_reg_wire <= EoM_reg;
         load_reg_wire <= load_reg;
         fetch_reg_wire <= fetch_reg;
         start_0_wire <= start_0;
         ack_reg_wire <= ack_reg;
         start_cipher <= '0';
         chain_sig <= (others=>'0');
         T0 <= (others=>'0');
         T1 <= (others=>'0');
         sig_2 <= (others=>'0');
         sig_3 <= (others=>'0');
         sig_4 <= (others=>'0');
         sig_5 <= (others=>'0');
         sig_6 <= (others=>'0');
         sig_7 <= (others=>'0');
         sig_8 <= (others=>'0');
         sig_9 <= (others=>'0');
         ack_int <= '0';
         odata_int <= (others=>'0');
         sig_0 <= "00111110111011001111010101010001101111110001000010000001100110111110011011011100100001010101100111110011111000100011111111010101";
         sig_1 <= "01000011000110101110110001110011011110011110001111110111001100011001100000110010010111110000010110101001001010100011000111110001";
         ack <= '0';
         odata <= (others=>'0');

         case cmd is
            when initialize =>
               T0 <= sig_0;
               T1 <= sig_1;
               sig_2 <= T0 & T1;
               chain_sig <= chain;
               ack <= ack_int;
               odata <= odata_int;
               start_cipher <= '0';
               ack_int <= '0';
               odata_int <= conv_std_logic_vector(0,16);
               init_reg_wire <= init;
               load_reg_wire <= load;
               fetch_reg_wire <= fetch;
               nlw_msg_wire <= conv_std_logic_vector(0,6);
               nfw_wire <= conv_std_logic_vector(0,5);
               done_reg_wire <= '0';
               start_0_wire <= '0';
               chain_wire <= sig_2;
            when load_msg =>
               sig_3 <= unsigned(nlw_msg) + unsigned(conv_std_logic_vector(1,6));
               chain_sig <= chain;
               sig_4 <= hash xor chain;
               if (done = '1') then
                  sig_5 <= sig_4;
               else
                  sig_5 <= chain;
               end if;
               start_cipher <= '0';
               ack <= ack_int;
               odata <= odata_int;
               ack_int <= '1';
               odata_int <= conv_std_logic_vector(0,16);
               init_reg_wire <= init;
               load_reg_wire <= load;
               fetch_reg_wire <= fetch;
               nlw_msg_wire <= sig_3;
               nfw_wire <= conv_std_logic_vector(0,5);
               chain_wire <= sig_5;
               start_0_wire <= '0';
               ack_reg_wire <= '1';
            when run =>
               start_cipher <= start_0;
               chain_sig <= chain;
               sig_6 <= hash xor chain;
               if (done = '1') then
                  sig_7 <= sig_6;
               else
                  sig_7 <= chain;
               end if;
               ack <= ack_int;
               odata <= odata_int;
               ack_int <= ack_reg;
               odata_int <= conv_std_logic_vector(0,16);
               init_reg_wire <= init;
               load_reg_wire <= load;
               fetch_reg_wire <= fetch;
               nlw_msg_wire <= conv_std_logic_vector(0,6);
               nfw_wire <= conv_std_logic_vector(0,5);
               start_0_wire <= start_cipher_out;
               chain_wire <= sig_7;
               done_reg_wire <= done;
               ack_reg_wire <= '0';
            when write =>
               start_cipher <= '0';
               chain_sig <= chain;
               sig_8 <= unsigned(nfw) + unsigned(conv_std_logic_vector(1,5));
               sig_9 <= chain(239 downto 0) & chain(255 downto 240);
               ack <= ack_int;
               odata <= odata_int;
               ack_int <= '1';
               odata_int <= chain(255 downto 240);
               init_reg_wire <= init;
               load_reg_wire <= load;
               fetch_reg_wire <= fetch;
               done_reg_wire <= done;
               start_0_wire <= '0';
               nfw_wire <= sig_8;
               nlw_msg_wire <= conv_std_logic_vector(0,6);
               chain_wire <= sig_9;
            when idle =>
               chain_sig <= chain;
               start_cipher <= '0';
               ack <= ack_int;
               odata <= odata_int;
               ack_int <= '0';
               odata_int <= conv_std_logic_vector(0,16);
               init_reg_wire <= init;
               load_reg_wire <= load;
               fetch_reg_wire <= fetch;
               nlw_msg_wire <= conv_std_logic_vector(0,6);
               nfw_wire <= conv_std_logic_vector(0,5);
               done_reg_wire <= '0';
               start_0_wire <= '0';
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
                          STATE <= s1;
                  else
                          STATE <= s0;
                  end if;
               when s1 => 
                  if (init_reg = '1') then
                          STATE <= s1;
                  else
                     if (load_reg = '1') then
                             STATE <= s2;
                     else
                             STATE <= s1;
                     end if;
                  end if;
               when s2 => 
                  if (init_reg = '1') then
                          STATE <= s1;
                  else
                     if (sig_11 = '1') then
                             STATE <= s2;
                     else
                             STATE <= s3;
                     end if;
                  end if;
               when s3 => 
                  if (init_reg = '1') then
                          STATE <= s1;
                  else
                     if (sig_12 = '1') then
                             STATE <= s4;
                     else
                        if (sig_13 = '1') then
                                STATE <= s3;
                        else
                           if (load_reg = '1') then
                                   STATE <= s2;
                           else
                                   STATE <= s4;
                           end if;
                        end if;
                     end if;
                  end if;
               when s4 => 
                  if (init_reg = '1') then
                          STATE <= s1;
                  else
                     if (sig_15 = '1') then
                             STATE <= s4;
                     else
                        if (load_reg = '1') then
                                STATE <= s2;
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
   fsmCMB: process (chain,nlw_msg,nfw,done_reg,init_reg,EoM_reg,load_reg,fetch_reg,start_0,ack_reg
,round_key,start_cipher,start_cipher_out,done,hash,chain_sig,T0,T1,sig_2,sig_3
,sig_4,sig_5,sig_6,sig_7,sig_8,sig_9,ack_int,odata_int,sig_10,sig_11
,sig_12,sig_13,sig_14,sig_15,init,EoM,load,fetch,idata,cmd,STATE)
      begin
      sig_10 <= '0';
      sig_11 <= '0';
      sig_12 <= '0';
      sig_13 <= '0';
      sig_14 <= '0';
      sig_15 <= '0';
      if (unsigned(nlw_msg) < 32) then
         sig_10 <= '1';
      else
         sig_10 <= '0';
      end if;
      sig_11 <= load_reg and sig_10;
      sig_12 <= done_reg and fetch_reg;
      sig_13 <=  not done_reg;
      if (unsigned(nfw) < 16) then
         sig_14 <= '1';
      else
         sig_14 <= '0';
      end if;
      sig_15 <= fetch_reg and sig_14;
      cmd <= initialize;
      case STATE is
         when s0 => 
            if (init_reg = '1') then
                    cmd <= initialize;
            else
                    cmd <= initialize;
            end if;
         when s1 => 
            if (init_reg = '1') then
                    cmd <= initialize;
            else
               if (load_reg = '1') then
                       cmd <= load_msg;
               else
                       cmd <= initialize;
               end if;
            end if;
         when s2 => 
            if (init_reg = '1') then
                    cmd <= initialize;
            else
               if (sig_11 = '1') then
                       cmd <= load_msg;
               else
                       cmd <= run;
               end if;
            end if;
         when s3 => 
            if (init_reg = '1') then
                    cmd <= initialize;
            else
               if (sig_12 = '1') then
                       cmd <= write;
               else
                  if (sig_13 = '1') then
                          cmd <= run;
                  else
                     if (load_reg = '1') then
                             cmd <= load_msg;
                     else
                             cmd <= idle;
                     end if;
                  end if;
               end if;
            end if;
         when s4 => 
            if (init_reg = '1') then
                    cmd <= initialize;
            else
               if (sig_15 = '1') then
                       cmd <= write;
               else
                  if (load_reg = '1') then
                          cmd <= load_msg;
                  else
                          cmd <= idle;
                  end if;
               end if;
            end if;
         when others=>
         end case;
   end process fsmCMB;
end RTL;
