--  
-- Copyright (c) 2018 Allmine Inc
--

-- Testvectors generated from reference code 
-- https://github.com/vertcoin/vertcoin/tree/master/src/crypto/Lyra2RE
--    ShortMsgKAT_256.txt ::
--        Len = 32 bytes
--        Msg = 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 
--        Skein-256 = b6b2b39d a27c6f70 12492074 75608e1f 80e857c6 37740de6 58a8be5f aafaaec3  
--        
--        Len = 32 bytes
--        Msg = e712139e 3b892f2f 5fe52d0f 30d78a0c b16b51b2 17da0e4a cb103dd0 856f2db0
--        Skein-256 = a6986768 5b484290 ea051043 9616a719 0648e2bf ac8b2a5c 01c1a01d 5a029536

--        Len = 32 bytes
--        Msg = a6986768 5b484290 ea051043 9616a719 0648e2bf ac8b2a5c 01c1a01d 5a029536
--        Skein-256 = bad323e6 3fcba707 9695e419 d01e4e79 32d4675a bd98b8c0 4a49673f abdef921 

library work;
    use work.sk_globals.all;
    
library std;
    use std.textio.all;
    
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_misc.all;
    use ieee.std_logic_arith.all;
    use ieee.std_logic_textio.all;
    use ieee.std_logic_unsigned."+";


entity tb_skein is
end tb_skein;
    
architecture tb of tb_skein is

-- components

component db_skein
  port( clk    : in  std_logic;
        msg_in : in  std_logic_vector(255 downto 0);
        dout   : out std_logic_vector(255 downto 0)
      );
end component;

  -- signal declarations

signal clk : std_logic;
signal state_in : std_logic_vector (255 downto 0);
signal dout : std_logic_vector (255 downto 0);
signal rst_n : std_logic;

type st_type is (in0,in1,in2,in3,in4,run,out0,out1,out2,out3,out4,STOP);
signal st : st_type;
signal counter : unsigned(7 downto 0);
 
begin  -- Rtl

-- port map
coremap : db_skein port map(clk, state_in, dout);

--main process
rst_n <= '0', '1' after 19 ns;

tbgen : process(clk)
    variable line_in : line;
    variable line_out : line;
    
    variable temp: std_logic_vector(63 downto 0);
    
    file fileout : text open write_mode is "test_vhdlout.txt";
    begin
        if(rst_n='0') then
            st <= in0;
            counter <= (others => '0');
            state_in <= x"00000000" & x"00000000" & x"00000000" & x"00000000" &
                        x"00000000" & x"00000000" & x"00000000" & x"00000000";
        elsif(clk'event and clk='1') then
            state_in <= x"00000000" & x"00000000" & x"00000000" & x"00000000" &
                        x"00000000" & x"00000000" & x"00000000" & x"00000000";
            case st is
                 when in0 =>
                    counter <= counter+1;
                    st <= in1;
                 when in1 =>
                    state_in <= x"e712139e" & x"3b892f2f" & x"5fe52d0f" & x"30d78a0c" &
                                x"b16b51b2" & x"17da0e4a" & x"cb103dd0" & x"856f2db0";
                    st <= in2;
                when in2 =>
                    state_in <= x"a6986768" & x"5b484290" & x"ea051043" & x"9616a719" &
                                x"0648e2bf" & x"ac8b2a5c" & x"01c1a01d" & x"5a029536";
                    counter <= counter+1;
                    st <= in3;
                when in3 =>
                    counter <= counter+1;
                    st <= in4;
                when in4 =>
                    counter <= counter+1;
                    st <= run;
                 when run =>
                    if (counter = 37) then
                        st <= out0;
                    else
                        counter <= counter+1;
                    end if;
                 when out0 =>
                    st <= out1;
               when out1 =>
                    for col in 3 downto 0 loop
                        temp := dout(col*64+63 downto col*64);
                        hwrite(line_out,temp);
                        writeline(fileout,line_out);
                    end loop;
                    write(fileout,string'("-"));
                    writeline(fileout,line_out);
                    st <= out2;
               when out2 =>
                    for col in 3 downto 0 loop
                        temp := dout(col*64+63 downto col*64);
                        hwrite(line_out,temp);
                        writeline(fileout,line_out);
                    end loop;
                    write(fileout,string'("-"));
                    writeline(fileout,line_out);
                    st <= out3;
               when out3 =>
                    for col in 3 downto 0 loop
                        temp := dout(col*64+63 downto col*64);
                        hwrite(line_out,temp);
                        writeline(fileout,line_out);
                    end loop;
                    write(fileout,string'("-"));
                    writeline(fileout,line_out);
                    st <= out4;
               when out4 =>
                    for col in 3 downto 0 loop
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
