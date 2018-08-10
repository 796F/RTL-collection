--  
-- Copyright (c) 2018 Allmine Inc
--

library work;
    use work.sk_globals.all;
    
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity db_skein is
port(   clk    : in  std_logic;
        msg_in : in  std_logic_vector(511 downto 0);
        dout   : out std_logic_vector(511 downto 0)
    );
end db_skein;

architecture rtl of db_skein is

--components
    
component skein
port(   clk    : in  std_logic;
        msg_in : in  std_logic_vector(511 downto 0);
        key_in : in  std_logic_vector(511 downto 0);
        twk_in : in  std_logic_vector(127 downto 0);
        dout   : out std_logic_vector(511 downto 0)
    );
end component;
    
  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------

signal rcnt : std_logic_vector(4 downto 0);

signal tweak0, tweak1 : std_logic_vector(127 downto 0);
signal key0, key1 : std_logic_vector(511 downto 0);
signal msg0, msg1 : std_logic_vector(511 downto 0);
signal dout0, dout1 : std_logic_vector(511 downto 0);
signal dout_tmp : std_logic_vector(511 downto 0);
signal din_tmp : std_logic_vector(511 downto 0);
signal din00_reg : std_logic_vector(511 downto 0);
signal din01_reg : std_logic_vector(511 downto 0);
signal din02_reg : std_logic_vector(511 downto 0);
signal din03_reg : std_logic_vector(511 downto 0);
signal din04_reg : std_logic_vector(511 downto 0);
signal din05_reg : std_logic_vector(511 downto 0);
signal din06_reg : std_logic_vector(511 downto 0);
signal din07_reg : std_logic_vector(511 downto 0);
signal din08_reg : std_logic_vector(511 downto 0);
signal din09_reg : std_logic_vector(511 downto 0);
signal din10_reg : std_logic_vector(511 downto 0);
signal din11_reg : std_logic_vector(511 downto 0);
signal din12_reg : std_logic_vector(511 downto 0);
signal din13_reg : std_logic_vector(511 downto 0);
signal din14_reg : std_logic_vector(511 downto 0);
signal din15_reg : std_logic_vector(511 downto 0);
signal din16_reg : std_logic_vector(511 downto 0);
signal din17_reg : std_logic_vector(511 downto 0);
signal din18_reg : std_logic_vector(511 downto 0);

begin  -- Rtl

    --swap endinaess
    i0: for w in 0 to 7 generate
        i1: for b in 0 to 7 generate
            din_tmp(64*w+8*b+7 downto 64*w+8*b) <= msg_in(64*w+8*(7-b)+7 downto 64*w+8*(7-b));
        end generate;
    end generate;

    tweak0 <= x"0000000000000040" &
              x"f000000000000000";
    tweak1 <= x"0000000000000008" &
              x"ff00000000000000";
    key0   <= init_vect;
    key1 <= dout0 xor din18_reg;
    msg0 <=   din_tmp;
    msg1 <=   x"0000000000000000" &
              x"0000000000000000" &
              x"0000000000000000" &
              x"0000000000000000" &
              x"0000000000000000" &
              x"0000000000000000" &
              x"0000000000000000" &
              x"0000000000000000";
    
    msgReg: process( clk )
    begin
        if rising_edge( clk ) then
            din00_reg <= din_tmp;
            din01_reg <= din00_reg;
            din02_reg <= din01_reg;
            din03_reg <= din02_reg;
            din04_reg <= din03_reg;
            din05_reg <= din04_reg;
            din06_reg <= din05_reg;
            din07_reg <= din06_reg;
            din08_reg <= din07_reg;
            din09_reg <= din08_reg;
            din10_reg <= din09_reg;
            din11_reg <= din10_reg;
            din12_reg <= din11_reg;
            din13_reg <= din12_reg;
            din14_reg <= din13_reg;
            din15_reg <= din14_reg;
            din16_reg <= din15_reg;
            din17_reg <= din16_reg;
            din18_reg <= din17_reg;
        end if;
    end process;
    
    mskein00_map : skein
        port map(   clk,
                    msg0,
                    key0,
                    tweak0,
                    dout0
                );
                
    mskein01_map : skein
        port map(   clk,
                    msg1,
                    key1,
                    tweak1,
                    dout1
                );
                
        
    dout_tmp <= dout1;
    --swap endinaess
    o0: for w in 0 to 7 generate
        o1: for b in 0 to 7 generate
            dout(64*w+8*b+7 downto 64*w+8*b) <= dout_tmp(64*w+8*(7-b)+7 downto 64*w+8*(7-b));
        end generate;    
    end generate;

end rtl;
