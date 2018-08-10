--  
-- Copyright (c) 2018 Allmine Inc
--

library work;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity db_nist5 is

port (

    clk     : in std_logic;
    msg     : in  std_logic_vector(639 downto 0);
    digest  : out std_logic_vector(511 downto 0));

end db_nist5;

architecture rtl of db_nist5 is

component db_jh
port (
    clk     : in std_logic;
    msg     : in  std_logic_vector(511 downto 0);
    jh_digest    : out std_logic_vector(511 downto 0));

end component;

component db_blake
port(   clk    : in  std_logic;
        msg_in : in  std_logic_vector(639 downto 0);
        dout   : out std_logic_vector(511 downto 0)
    );

end component;

component db_keccak
port(   clk    : in  std_logic;
        msg_in : in  std_logic_vector(511 downto 0);
        dout   : out std_logic_vector(511 downto 0)
    );

end component;

component db_skein
port(   clk    : in  std_logic;
        msg_in : in  std_logic_vector(511 downto 0);
        dout   : out std_logic_vector(511 downto 0)
    );

end component;

component grostl512
  port( clk      : in  std_logic;
        msg_in : in  std_logic_vector(511 downto 0);
        hash     : out std_logic_vector(511 downto 0)
      );
end component;

signal kin,kout,sin,sout,jin,jout,gin,gout,bout : std_logic_vector(511 downto 0);

signal bin : std_logic_vector(639 downto 0);

begin  -- Rtl

    intReg: process( clk )
    begin
        if rising_edge( clk ) then
            bin <= msg;
            gin <= bout;
            jin <= gout;
            kin <= jout;
            sin <= kout;
            digest <= sout;
        end if;
    end process;

db_b_map : db_blake
        port map(   clk,
                    bin,
                    bout
                );

db_g_map : grostl512
        port map(   clk,
                    gin,
                    gout
                 );

db_j_map : db_jh
        port map(   clk,
                    jin,
                    jout
                );

db_k_map : db_keccak
        port map(   clk,
                    kin,
                    kout
                );

db_s_map : db_skein
        port map(   clk,
                    sin,
                    sout
                );

end rtl;
