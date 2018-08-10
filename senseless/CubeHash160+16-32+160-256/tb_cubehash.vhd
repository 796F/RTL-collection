--  
-- Copyright (c) 2018 Allmine Inc
--

-- Testvectors from CubeHash NIST submission 
-- and from https://en.bitcoinwiki.org/wiki/CubeHash#Example_Hashes:
--    ShortMsgKAT_256.txt ::
--        Len = 0
--        Msg = 00
--        CubeHash160+16/32+160-256 = 44c6de3ac6c73c391bf0906cb7482600ec06b216c7c54a2a8688a6a42676577d
--        
--        Len = 2 bytes
--        Msg = 41fb
--        CubeHash160+16/32+160-256 = ad4a4242bd1d2385d72a46eaeae3239bfa243829f0cf3640ed852d4f6609f7df
--        
--        Len = 5 bytes
--        Msg = 48656c6c6f
--        CubeHash160+16/32+160-256 = e712139e3b892f2f5fe52d0f30d78a0cb16b51b217da0e4acb103dd0856f2db0


library work;
    use work.ch_globals.all;
    
library std;
    use std.textio.all;
    
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_misc.all;
    use ieee.std_logic_arith.all;
    use ieee.std_logic_textio.all;
    use ieee.std_logic_unsigned."+";


entity tb_cubehash is
end tb_cubehash;
    
architecture tb of tb_cubehash is

-- components

component cubehash
  port( clk         : in  std_logic;
        start       : in  std_logic;
        state_in    : in  std_logic_vector(255 downto 0);
        dout        : out std_logic_vector(255 downto 0)
      );
end component;

  -- signal declarations

signal clk : std_logic;
signal state_in : std_logic_vector (255 downto 0);
signal dout : std_logic_vector (255 downto 0);
signal rst_n : std_logic;
signal start : std_logic;

type st_type is (in0,in1,in2,in3,in4,run,out0,out1,out2,out3,out4,STOP);
signal st : st_type;
signal counter : unsigned(7 downto 0);
 
begin  -- Rtl

-- port map
coremap : cubehash port map(clk, start, state_in, dout);

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
            start <= '0';
            state_in <= x"00000000" & x"00000000" & x"00000000" & x"00000000" &
                        x"00000000" & x"00000000" & x"00000000" & x"00000000";
            case st is
                 when in0 =>
                    start <= '1';
                    counter <= counter+1;
                    st <= in1;
                 when in1 =>
                    state_in <= x"80000000" & x"00000000" & x"00000000" & x"00000000" &
                                x"00000000" & x"00000000" & x"00000000" & x"00000000";
                    st <= in2;
                when in2 =>
                    state_in <= x"41fb8000" & x"00000000" & x"00000000" & x"00000000" &
                                x"00000000" & x"00000000" & x"00000000" & x"00000000";
                    counter <= counter+1;
                    st <= in3;
                when in3 =>
                    state_in <= x"48656c6c" & x"6f800000" & x"00000000" & x"00000000" &
                                x"00000000" & x"00000000" & x"00000000" & x"00000000";
                    counter <= counter+1;
                    st <= in4;
                when in4 =>
                    state_in <= x"e712139e" & x"3b892f2f" & x"5fe52d0f" & x"30d78a0c" &
                                x"b16b51b2" & x"17da0e4a" & x"cb103dd0" & x"856f2db0";
                    counter <= counter+1;
                    st <= run;
                 when run =>
                    if (counter = 176) then
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
