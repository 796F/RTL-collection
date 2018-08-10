--  
-- Copyright (c) 2018 Allmine Inc
--

-- Testvectors generated from reference code 
-- https://github.com/tpruvot/cpuminer-multi/blob/linux/algo/nist5.c
--        Len = 80 bytes
--        Msg = 
--          0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 
--          Blake-512 Output digest:
--          13cee4af d536f7ed 6aa3f7fc 90e00050 4bf01dd0 41a8a3c1 f38f0bfa 14258308 384b6c5c 75d2ab52 8277de92 a0968b66 50fcb806 87a4eab0 dcd87216 bc522dc6 
--          Groestl-512 Output digest:
--          5ba55893 849a3e48 bd588b37 5803f510 10b842fb e173b7b3 2121d67b e8befdfd 704be904 708fc801 979e4762 100f7c98 137291f6 7d3ad515 766ef9b1 ef02e8ab 
--          JH-512 Output digest:
--          231afb47 84a18785 dc4c124e 1e460ec3 38e13fd3 84a1b178 12a5a0f0 d3c97df5 7cb16b3c 9ff06f87 bdc982c0 b5882a75 927aad0e 73338cd6 28cfe8c6 cfe744b8 
--          Keccak-512 Output digest:
--          946b44b6 347724a4 88a25a15 0a39d0c4 3d183438 7772662b aa9e1ae6 5967b64d 84ef71ee 85ce690c fa2f8e2c a0f21f91 659d4857 1d9cabf9 aa941e65 5351898d 
--          Skein-512 Output digest:
--          f793aee4 ec7c83ad 3fb06661 fc514201 ea8865a2 22eb7cc5 50fb0fcb 7644435d 4856ad97 ccf1fbbe d547b5a5 30b2c108 3924c5d1 024b380e eac2058d 68ef44da 
--        
--        Len = 80 bytes
--        Msg = 
--          000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f 
--          Blake-512 Output digest:
--          dbc2a885 76bdc79a 75daad04 c1426223 7cba3eed 3421381c 5ae269e8 f2ac537d dc87a7be f5267469 daea8a63 e35437a0 f30ce92c ea8e25dc 67b9848b e1276536 
--          Groestl-512 Output digest:
--          8df4f1a6 e8445c6b 9277a1d3 4bb79b6e a99afe34 6ab518c7 ad4a4516 c45fb662 5587671f 1866058c 0735e147 29843e35 8c9805a0 50c62f26 c7968709 c57f81bc 
--          JH-512 Output digest:
--          566b6da2 4ca006fe 56edb031 876135a3 001deb97 f0d45f8e 442cd2f3 c716d35d 4d0f402c c63fa1a9 57af916d 26bee124 e93e126e 7cc813d0 7e5760c7 468bfe16 
--          Keccak-512 Output digest:
--          9856cf74 e797a3ba c21c3066 ada508ae 6b9b06a7 7f87c95a 13d86744 a87f6e54 87e6f03b 53486880 4d649cec 186765d2 239c6ec9 c0db0d73 906865ef 4e5df881 
--          Skein-512 Output digest:
--          613f61e8 346b89ae 0429f1d4 9108b588 f3ad050d e7f0ad13 589bf758 40e6e3d3 89b247ca 6b44b1ca c0880bf3 6213c7f3 6cdf0a29 5fbf71ba 7ce60cbb 97494c23 
--        
--        Len = 80 bytes
--        Msg = 
--          716f6e863f744b9ac22c97ec7b76ea5f5908bc5b2f67c61510bfc4751384ea7a0ce8d4ef4dd7cd8d62dfded9d4edb0a774ae6a41929a74da23109e8f11139c870c7b159452328517463db487df5e39b7
--          Blake-512 Output digest:
--          8d80f6fd 793001d8 f84790cc 65d7f3b0 99196b88 b1d4f468 bff7c25d c40bc9c1 c20e4d0f c4ca9954 ba207d15 9bbe44f3 a1d0a106 a0d55ad1 5079f4e9 73c02243 
--          Groestl-512 Output digest:
--          f78d2b4f eb58e228 75fe0406 7a4be5a9 52321628 ad0a1e06 fe552517 2ca5ad2a 671afa4f 182f09c2 784f3d01 fc48d31b c3bfe6fe 7669e594 8472e876 88b172e1 
--          JH-512 Output digest:
--          fe884342 c74beeaa d9ad2852 3f820e37 e5702bfc 7a6aaf4f 43b9cdc1 2a1baa74 44ecc4f1 403dc749 d162873e b8bd8788 ec084c0e 2d37c8e3 d7a2d0f7 343d12fd 
--          Keccak-512 Output digest:
--          4a817a52 0f53ba10 371e65b9 ad88fbcc de465251 8f46efde c98746c7 785fca46 675cdf1c 02fcbd9a 6fe48a2e f8017e6a fb69c3d9 cbf38832 b1d7ed6f 47fdbeb8 
--          Skein-512 Output digest:
--          a46c6177 ddcffcb9 615e7cc0 037c9a4c f7ee0b85 c190a98f 43796ffc 383ac7f3 883e32e9 e3152913 d135f9e4 3657e8a0 eafcb004 4f000551 c26df057 ee90f433 

library work;
    use work.bk_globals.all;
    
library std;
    use std.textio.all;
    
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_misc.all;
    use ieee.std_logic_arith.all;
    use ieee.std_logic_textio.all;
    use ieee.std_logic_unsigned."+";

entity tb_nist5 is
end tb_nist5;
    
architecture tb of tb_nist5 is

-- components

component db_nist5
  port( clk    : in  std_logic;
        msg    : in  std_logic_vector(639 downto 0);
        digest : out std_logic_vector(511 downto 0)
      );
end component;

  -- signal declarations

signal clk : std_logic;
signal state_in : std_logic_vector (639 downto 0);
signal msg0, msg1, msg2 : std_logic_vector (639 downto 0);
signal dout : std_logic_vector (511 downto 0);
signal rst_n : std_logic;

type st_type is (in0,in1,in2,in3,in4,run,out0,out1,out2,out3,out4,STOP);
signal st : st_type;
signal counter : unsigned(8 downto 0);
 
begin  -- Rtl

-- port map
coremap : db_nist5 port map(clk, state_in, dout);

--main process
rst_n <= '0', '1' after 19 ns;

msg0 <= x"00000000" & x"00000000" & x"00000000" & x"00000000" &
        x"00000000" & x"00000000" & x"00000000" & x"00000000" &
        x"00000000" & x"00000000" & x"00000000" & x"00000000" &
        x"00000000" & x"00000000" & x"00000000" & x"00000000" &
        x"00000000" & x"00000000" & x"00000000" & x"00000000";
msg1 <= x"00010203" & x"04050607" & x"08090a0b" & x"0c0d0e0f" &
        x"10111213" & x"14151617" & x"18191a1b" & x"1c1d1e1f" &
        x"20212223" & x"24252627" & x"28292a2b" & x"2c2d2e2f" &
        x"30313233" & x"34353637" & x"38393a3b" & x"3c3d3e3f" &
        x"40414243" & x"44454647" & x"48494a4b" & x"4c4d4e4f";
msg2 <= x"716f6e863f744b9ac22c97ec7b76ea5f" &
        x"5908bc5b2f67c61510bfc4751384ea7a" &
        x"0ce8d4ef4dd7cd8d62dfded9d4edb0a7" &
        x"74ae6a41929a74da23109e8f11139c87" &
        x"0c7b159452328517463db487df5e39b7";
state_in <= msg1 when (counter=1) else
            msg2 when (counter=2) else
            msg0;
tbgen : process(clk, rst_n)
    variable line_in : line;
    variable line_out : line;
    
    variable temp: std_logic_vector(63 downto 0);
    
    file fileout : text open write_mode is "test_vhdlout.txt";
    begin
        if(rst_n='0') then
            st <= in0;
            counter <= (others => '0');
        elsif(clk'event and clk='1') then
            case st is
                 when in0 =>
                    counter <= counter+1;
                    st <= in1;
                 when in1 =>
                     counter <= counter+1;
                    st <= in2;
                when in2 =>
                    counter <= counter+1;
                    st <= in3;
                when in3 =>
                    counter <= counter+1;
                    st <= in4;
                when in4 =>
                    counter <= counter+1;
                    st <= run;
                 when run =>
                    if (counter = 265) then
                        st <= out0;
                    else
                        counter <= counter+1;
                    end if;
                 when out0 =>
                    st <= out1;
               when out1 =>
                    for col in 7 downto 0 loop
                        temp := dout(col*64+63 downto col*64);
                        hwrite(line_out,temp);
                        writeline(fileout,line_out);
                    end loop;
                    write(fileout,string'("-"));
                    writeline(fileout,line_out);
                    st <= out2;
               when out2 =>
                    for col in 7 downto 0 loop
                        temp := dout(col*64+63 downto col*64);
                        hwrite(line_out,temp);
                        writeline(fileout,line_out);
                    end loop;
                    write(fileout,string'("-"));
                    writeline(fileout,line_out);
                    st <= out3;
               when out3 =>
                    for col in 7 downto 0 loop
                        temp := dout(col*64+63 downto col*64);
                        hwrite(line_out,temp);
                        writeline(fileout,line_out);
                    end loop;
                    write(fileout,string'("-"));
                    writeline(fileout,line_out);
                    st <= out4;
               when out4 =>
                    for col in 7 downto 0 loop
                        temp := dout(col*64+63 downto col*64);
                        hwrite(line_out,temp);
                        writeline(fileout,line_out);
                    end loop;
                    write(fileout,string'("-"));
                    writeline(fileout,line_out);
                    st <= STOP;
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
