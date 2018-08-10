--  
-- Copyright (c) 2018 Allmine Inc
--

library work;
    use work.bk_globals.all;
    
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity db_blake is
port(   clk    : in  std_logic;
        msg_in : in  std_logic_vector(639 downto 0);
        dout   : out std_logic_vector(511 downto 0)
    );
end db_blake;

architecture rtl of db_blake is

--components

component blake
port(   clk    : in  std_logic;
        chn_in : in  std_logic_vector(511 downto 0);
        msg_in : in  std_logic_vector(1023 downto 0);
        slt_in : in  std_logic_vector(255 downto 0);
        cnt_in : in  std_logic_vector(127 downto 0);
        dout   : out std_logic_vector(511 downto 0)
    );
end component;
    
  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------

signal msg0 : std_logic_vector(1023 downto 0);
signal cnt0 : std_logic_vector(127 downto 0);
signal slt0 : std_logic_vector(255 downto 0);
signal chn0 : std_logic_vector(511 downto 0);
signal dout0 : std_logic_vector(511 downto 0);
signal din_tmp  : std_logic_vector(639 downto 0);
signal dout_tmp : std_logic_vector(511 downto 0);

begin  -- Rtl

    --swap endinaess
   -- i0: for w in 0 to 19 generate
       -- i1: for b in 0 to 3 generate
           -- din_tmp(32*w+8*b+7 downto 32*w+8*b) <= msg_in(32*w+8*(3-b)+7 downto 32*w+8*(3-b));
       -- end generate;
   -- end generate;
    din_tmp <= msg_in;

    cnt0 <= x"00000000000000000000000000000280";
    slt0 <= x"00000000000000000000000000000000" &
            x"00000000000000000000000000000000";
    chn0 <= init_vect;
    msg0 <= din_tmp &
            x"80000000" & x"00000000" & x"00000000" & x"00000000" &
            x"00000000" & x"00000000" & x"00000000" & x"00000001" &
            x"00000000" & x"00000000" & x"00000000" & x"00000280";
    
    mblake00_map : blake
        port map(   clk,
                    chn0,
                    msg0,
                    slt0,
                    cnt0,
                    dout0
                );
                
    dout <= dout0;

    -- swap endinaess
    -- o0: for w in 0 to 3 generate
        -- o1: for b in 0 to 7 generate
            -- dout(64*w+8*b+7 downto 64*w+8*b) <= dout_tmp(64*w+8*(7-b)+7 downto 64*w+8*(7-b));
        -- end generate;    
    -- end generate;

end rtl;
