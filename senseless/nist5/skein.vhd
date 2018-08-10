--  
-- Copyright (c) 2018 Allmine Inc
--

library work;
    use work.sk_globals.all;
    
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity skein is
port(   clk    : in  std_logic;
        msg_in : in  std_logic_vector(511 downto 0);
        key_in : in  std_logic_vector(511 downto 0);
        twk_in : in  std_logic_vector(127 downto 0);
        dout   : out std_logic_vector(511 downto 0)
    );
end skein;

architecture rtl of skein is

--components
    
component  sk_schedule is
port (  clk    : in  std_logic;
        key_in : in  std_logic_vector(511 downto 0);
        tweak  : in  std_logic_vector(127 downto 0);
        sk_out00 : out std_logic_vector(511 downto 0);
        sk_out01 : out std_logic_vector(511 downto 0);
        sk_out02 : out std_logic_vector(511 downto 0);
        sk_out03 : out std_logic_vector(511 downto 0);
        sk_out04 : out std_logic_vector(511 downto 0);
        sk_out05 : out std_logic_vector(511 downto 0);
        sk_out06 : out std_logic_vector(511 downto 0);
        sk_out07 : out std_logic_vector(511 downto 0);
        sk_out08 : out std_logic_vector(511 downto 0);
        sk_out09 : out std_logic_vector(511 downto 0);
        sk_out10 : out std_logic_vector(511 downto 0);
        sk_out11 : out std_logic_vector(511 downto 0);
        sk_out12 : out std_logic_vector(511 downto 0);
        sk_out13 : out std_logic_vector(511 downto 0);
        sk_out14 : out std_logic_vector(511 downto 0);
        sk_out15 : out std_logic_vector(511 downto 0);
        sk_out16 : out std_logic_vector(511 downto 0);
        sk_out17 : out std_logic_vector(511 downto 0);
        sk_out18 : out std_logic_vector(511 downto 0)
     );
end component;

component sk_add
port (  key_in : in  std_logic_vector(511 downto 0);
        st_in  : in  std_logic_vector(511 downto 0);
        st_out : out std_logic_vector(511 downto 0)
     );
end component;
    
component sk_4er 
port (  st_in  : in  std_logic_vector(511 downto 0);
        st_out : out std_logic_vector(511 downto 0)
     );
end component;

component sk_4or 
port (  st_in  : in  std_logic_vector(511 downto 0);
        st_out : out std_logic_vector(511 downto 0)
     );
end component;
    
component sk_sreg 
port (  clk     : in  std_logic;
        st_in   : in  std_logic_vector(511 downto 0);
        st_out  : out std_logic_vector(511 downto 0)
     );
end component;
    
  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------

signal sk_out00 : std_logic_vector(511 downto 0);
signal sk_out01 : std_logic_vector(511 downto 0);
signal sk_out02 : std_logic_vector(511 downto 0);
signal sk_out03 : std_logic_vector(511 downto 0);
signal sk_out04 : std_logic_vector(511 downto 0);
signal sk_out05 : std_logic_vector(511 downto 0);
signal sk_out06 : std_logic_vector(511 downto 0);
signal sk_out07 : std_logic_vector(511 downto 0);
signal sk_out08 : std_logic_vector(511 downto 0);
signal sk_out09 : std_logic_vector(511 downto 0);
signal sk_out10 : std_logic_vector(511 downto 0);
signal sk_out11 : std_logic_vector(511 downto 0);
signal sk_out12 : std_logic_vector(511 downto 0);
signal sk_out13 : std_logic_vector(511 downto 0);
signal sk_out14 : std_logic_vector(511 downto 0);
signal sk_out15 : std_logic_vector(511 downto 0);
signal sk_out16 : std_logic_vector(511 downto 0);
signal sk_out17 : std_logic_vector(511 downto 0);
signal sk_out18 : std_logic_vector(511 downto 0);

signal r00_in, r00_mid, r00_out : std_logic_vector(511 downto 0);
signal r01_in, r01_mid, r01_out : std_logic_vector(511 downto 0);
signal r02_in, r02_mid, r02_out : std_logic_vector(511 downto 0);
signal r03_in, r03_mid, r03_out : std_logic_vector(511 downto 0);
signal r04_in, r04_mid, r04_out : std_logic_vector(511 downto 0);
signal r05_in, r05_mid, r05_out : std_logic_vector(511 downto 0);
signal r06_in, r06_mid, r06_out : std_logic_vector(511 downto 0);
signal r07_in, r07_mid, r07_out : std_logic_vector(511 downto 0);
signal r08_in, r08_mid, r08_out : std_logic_vector(511 downto 0);
signal r09_in, r09_mid, r09_out : std_logic_vector(511 downto 0);
signal r10_in, r10_mid, r10_out : std_logic_vector(511 downto 0);
signal r11_in, r11_mid, r11_out : std_logic_vector(511 downto 0);
signal r12_in, r12_mid, r12_out : std_logic_vector(511 downto 0);
signal r13_in, r13_mid, r13_out : std_logic_vector(511 downto 0);
signal r14_in, r14_mid, r14_out : std_logic_vector(511 downto 0);
signal r15_in, r15_mid, r15_out : std_logic_vector(511 downto 0);
signal r16_in, r16_mid, r16_out : std_logic_vector(511 downto 0);
signal r17_in, r17_mid, r17_out : std_logic_vector(511 downto 0);
signal r18_in, r18_mid, r18_out : std_logic_vector(511 downto 0);

begin  -- Rtl

    mks00_map : sk_schedule
        port map(   clk,
                    key_in,
                    twk_in,
                    sk_out00,
                    sk_out01,
                    sk_out02,
                    sk_out03,
                    sk_out04,
                    sk_out05,
                    sk_out06,
                    sk_out07,
                    sk_out08,
                    sk_out09,
                    sk_out10,
                    sk_out11,
                    sk_out12,
                    sk_out13,
                    sk_out14,
                    sk_out15,
                    sk_out16,
                    sk_out17,
                    sk_out18
                );
                
    ma00_map : sk_add  port map(sk_out00, msg_in,  r00_in );
    mc00_map : sk_4er  port map(        r00_in,  r00_mid);
    mr00_map : sk_sreg port map(clk,    r00_mid, r00_out);
    ma01_map : sk_add  port map(sk_out01, r00_out, r01_in );
    mc01_map : sk_4or  port map(        r01_in,  r01_mid);
    mr01_map : sk_sreg port map(clk,    r01_mid, r01_out);
    ma02_map : sk_add  port map(sk_out02, r01_out, r02_in );
    mc02_map : sk_4er  port map(        r02_in,  r02_mid);
    mr02_map : sk_sreg port map(clk,    r02_mid, r02_out);
    ma03_map : sk_add  port map(sk_out03, r02_out, r03_in );
    mc03_map : sk_4or  port map(        r03_in,  r03_mid);
    mr03_map : sk_sreg port map(clk,    r03_mid, r03_out);
    ma04_map : sk_add  port map(sk_out04, r03_out, r04_in );
    mc04_map : sk_4er  port map(        r04_in,  r04_mid);
    mr04_map : sk_sreg port map(clk,    r04_mid, r04_out);
    ma05_map : sk_add  port map(sk_out05, r04_out, r05_in );
    mc05_map : sk_4or  port map(        r05_in,  r05_mid);
    mr05_map : sk_sreg port map(clk,    r05_mid, r05_out);
    ma06_map : sk_add  port map(sk_out06, r05_out, r06_in );
    mc06_map : sk_4er  port map(        r06_in,  r06_mid);
    mr06_map : sk_sreg port map(clk,    r06_mid, r06_out);
    ma07_map : sk_add  port map(sk_out07, r06_out, r07_in );
    mc07_map : sk_4or  port map(        r07_in,  r07_mid);
    mr07_map : sk_sreg port map(clk,    r07_mid, r07_out);
    ma08_map : sk_add  port map(sk_out08, r07_out, r08_in );
    mc08_map : sk_4er  port map(        r08_in,  r08_mid);
    mr08_map : sk_sreg port map(clk,    r08_mid, r08_out);
    ma09_map : sk_add  port map(sk_out09, r08_out, r09_in );
    mc09_map : sk_4or  port map(        r09_in,  r09_mid);
    mr09_map : sk_sreg port map(clk,    r09_mid, r09_out);
    ma10_map : sk_add  port map(sk_out10, r09_out, r10_in );
    mc10_map : sk_4er  port map(        r10_in,  r10_mid);
    mr10_map : sk_sreg port map(clk,    r10_mid, r10_out);
    ma11_map : sk_add  port map(sk_out11, r10_out, r11_in );
    mc11_map : sk_4or  port map(        r11_in,  r11_mid);
    mr11_map : sk_sreg port map(clk,    r11_mid, r11_out);
    ma12_map : sk_add  port map(sk_out12, r11_out, r12_in );
    mc12_map : sk_4er  port map(        r12_in,  r12_mid);
    mr12_map : sk_sreg port map(clk,    r12_mid, r12_out);
    ma13_map : sk_add  port map(sk_out13, r12_out, r13_in );
    mc13_map : sk_4or  port map(        r13_in,  r13_mid);
    mr13_map : sk_sreg port map(clk,    r13_mid, r13_out);
    ma14_map : sk_add  port map(sk_out14, r13_out, r14_in );
    mc14_map : sk_4er  port map(        r14_in,  r14_mid);
    mr14_map : sk_sreg port map(clk,    r14_mid, r14_out);
    ma15_map : sk_add  port map(sk_out15, r14_out, r15_in );
    mc15_map : sk_4or  port map(        r15_in,  r15_mid);
    mr15_map : sk_sreg port map(clk,    r15_mid, r15_out);
    ma16_map : sk_add  port map(sk_out16, r15_out, r16_in );
    mc16_map : sk_4er  port map(        r16_in,  r16_mid);
    mr16_map : sk_sreg port map(clk,    r16_mid, r16_out);
    ma17_map : sk_add  port map(sk_out17, r16_out, r17_in );
    mc17_map : sk_4or  port map(        r17_in,  r17_mid);
    mr17_map : sk_sreg port map(clk,    r17_mid, r17_out);
    ma18_map : sk_add  port map(sk_out18, r17_out, r18_in );
    r18_mid <= r18_in;
    mr18_map : sk_sreg port map(clk,    r18_mid, r18_out);
        
    dout <= r18_out;

end rtl;
