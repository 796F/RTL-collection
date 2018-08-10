--  
-- Copyright (c) 2018 Allmine Inc
--

library work;
    use work.bk_globals.all;
    
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity blake is
port(   clk    : in  std_logic;
        chn_in : in  std_logic_vector(511 downto 0);
        msg_in : in  std_logic_vector(1023 downto 0);
        slt_in : in  std_logic_vector(255 downto 0);
        cnt_in : in  std_logic_vector(127 downto 0);
        dout   : out std_logic_vector(511 downto 0)
    );
end blake;

architecture rtl of blake is

--components

component bk_round 
port (  clk   : in  std_logic;
        state : in  std_logic_vector(1023 downto 0);
        msg   : in  std_logic_vector(1023 downto 0);
        chain : out std_logic_vector(1023 downto 0)
     );
end component;
    
component bk_reg 
port (  clk     : in  std_logic;
        st_in   : in  std_logic_vector(1023 downto 0);
        st_out  : out std_logic_vector(1023 downto 0)
     );
end component;
    
component bk_hreg 
port (  clk     : in  std_logic;
        st_in   : in  std_logic_vector(511 downto 0);
        st_out  : out std_logic_vector(511 downto 0)
     );
end component;
    
component bk_sigma
port (  clk     : in  std_logic;
        round_w : in  std_logic_vector(3 downto 0);
        msg:      in  std_logic_vector(1023 downto 0);
        sigma:    out std_logic_vector(1023 downto 0)
     );
end component;


  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------

signal rii_st, rii_msg : std_logic_vector(1023 downto 0);

signal r00_st, r00_msg : std_logic_vector(1023 downto 0);
signal r00_sin, r00_sout, r00_min, r00_mout : std_logic_vector(1023 downto 0);
signal r01_sin, r01_sout, r01_min, r01_mout : std_logic_vector(1023 downto 0);
signal r02_sin, r02_sout, r02_min, r02_mout : std_logic_vector(1023 downto 0);
signal r03_sin, r03_sout, r03_min, r03_mout : std_logic_vector(1023 downto 0);
signal r04_sin, r04_sout, r04_min, r04_mout : std_logic_vector(1023 downto 0);
signal r05_sin, r05_sout, r05_min, r05_mout : std_logic_vector(1023 downto 0);
signal r06_sin, r06_sout, r06_min, r06_mout : std_logic_vector(1023 downto 0);
signal r07_sin, r07_sout, r07_min, r07_mout : std_logic_vector(1023 downto 0);
signal r08_sin, r08_sout, r08_min, r08_mout : std_logic_vector(1023 downto 0);
signal r09_sin, r09_sout, r09_min, r09_mout : std_logic_vector(1023 downto 0);
signal r10_sin, r10_sout, r10_min, r10_mout : std_logic_vector(1023 downto 0);
signal r11_sin, r11_sout, r11_min, r11_mout : std_logic_vector(1023 downto 0);
signal r12_sin, r12_sout, r12_min, r12_mout : std_logic_vector(1023 downto 0);
signal r13_sin, r13_sout, r13_min, r13_mout : std_logic_vector(1023 downto 0);
signal r14_sin, r14_sout, r14_min, r14_mout : std_logic_vector(1023 downto 0);
signal r15_sin, r15_sout, r15_min, r15_mout : std_logic_vector(1023 downto 0);

signal rii_chain, roo_chain, roo_hout : std_logic_vector(511 downto 0);

signal r00a_hout, r00b_hout : std_logic_vector(511 downto 0);
signal r01a_hout, r01b_hout : std_logic_vector(511 downto 0);
signal r02a_hout, r02b_hout : std_logic_vector(511 downto 0);
signal r03a_hout, r03b_hout : std_logic_vector(511 downto 0);
signal r04a_hout, r04b_hout : std_logic_vector(511 downto 0);
signal r05a_hout, r05b_hout : std_logic_vector(511 downto 0);
signal r06a_hout, r06b_hout : std_logic_vector(511 downto 0);
signal r07a_hout, r07b_hout : std_logic_vector(511 downto 0);
signal r08a_hout, r08b_hout : std_logic_vector(511 downto 0);
signal r09a_hout, r09b_hout : std_logic_vector(511 downto 0);
signal r10a_hout, r10b_hout : std_logic_vector(511 downto 0);
signal r11a_hout, r11b_hout : std_logic_vector(511 downto 0);
signal r12a_hout, r12b_hout : std_logic_vector(511 downto 0);
signal r13a_hout, r13b_hout : std_logic_vector(511 downto 0);
signal r14a_hout, r14b_hout : std_logic_vector(511 downto 0);
signal r15a_hout, r15b_hout : std_logic_vector(511 downto 0);

signal cnt_i   : std_logic_vector(255 downto 0);

begin  -- Rtl

--  State initialization
    cnt_i <= cnt_in(63 downto 0) & cnt_in(63 downto 0) & cnt_in(127 downto 64) & cnt_in(127 downto 64);
    rii_st(1023 downto 512) <= chn_in;
    rii_st(511 downto 256) <= slt_in xor const_t(1023 downto 768);
    rii_st(255 downto   0) <= cnt_i xor const_t(767 downto 512);
    mrii_map : bk_reg   port map(clk, rii_st, r00_st);
    rii_msg <= msg_in xor const_r;
    mmii_map : bk_reg   port map(clk, rii_msg, r00_msg);
    
    mc00_map : bk_round port map(clk, r00_st, r00_msg, r00_sin);
    mr00_map : bk_reg   port map(clk, r00_sin, r00_sout);
    ms00_map : bk_sigma port map(clk, "0000", r00_msg, r00_min);
    mm00_map : bk_reg   port map(clk, r00_min, r00_mout);
        
    mc01_map : bk_round port map(clk, r00_sout, r00_mout, r01_sin);
    mr01_map : bk_reg   port map(clk, r01_sin, r01_sout);
    ms01_map : bk_sigma port map(clk, "0001", r00_mout, r01_min);
    mm01_map : bk_reg   port map(clk, r01_min, r01_mout);
        
    mc02_map : bk_round port map(clk, r01_sout, r01_mout, r02_sin);
    mr02_map : bk_reg   port map(clk, r02_sin, r02_sout);
    ms02_map : bk_sigma port map(clk, "0010", r01_mout, r02_min);
    mm02_map : bk_reg   port map(clk, r02_min, r02_mout);
        
    mc03_map : bk_round port map(clk, r02_sout, r02_mout, r03_sin);
    mr03_map : bk_reg   port map(clk, r03_sin, r03_sout);
    ms03_map : bk_sigma port map(clk, "0011", r02_mout, r03_min);
    mm03_map : bk_reg   port map(clk, r03_min, r03_mout);
        
    mc04_map : bk_round port map(clk, r03_sout, r03_mout, r04_sin);
    mr04_map : bk_reg   port map(clk, r04_sin, r04_sout);
    ms04_map : bk_sigma port map(clk, "0100", r03_mout, r04_min);
    mm04_map : bk_reg   port map(clk, r04_min, r04_mout);
        
    mc05_map : bk_round port map(clk, r04_sout, r04_mout, r05_sin);
    mr05_map : bk_reg   port map(clk, r05_sin, r05_sout);
    ms05_map : bk_sigma port map(clk, "0101", r04_mout, r05_min);
    mm05_map : bk_reg   port map(clk, r05_min, r05_mout);
        
    mc06_map : bk_round port map(clk, r05_sout, r05_mout, r06_sin);
    mr06_map : bk_reg   port map(clk, r06_sin, r06_sout);
    ms06_map : bk_sigma port map(clk, "0110", r05_mout, r06_min);
    mm06_map : bk_reg   port map(clk, r06_min, r06_mout);
        
    mc07_map : bk_round port map(clk, r06_sout, r06_mout, r07_sin);
    mr07_map : bk_reg   port map(clk, r07_sin, r07_sout);
    ms07_map : bk_sigma port map(clk, "0111", r06_mout, r07_min);
    mm07_map : bk_reg   port map(clk, r07_min, r07_mout);
        
    mc08_map : bk_round port map(clk, r07_sout, r07_mout, r08_sin);
    mr08_map : bk_reg   port map(clk, r08_sin, r08_sout);
    ms08_map : bk_sigma port map(clk, "1000", r07_mout, r08_min);
    mm08_map : bk_reg   port map(clk, r08_min, r08_mout);
        
    mc09_map : bk_round port map(clk, r08_sout, r08_mout, r09_sin);
    mr09_map : bk_reg   port map(clk, r09_sin, r09_sout);
    ms09_map : bk_sigma port map(clk, "1001", r08_mout, r09_min);
    mm09_map : bk_reg   port map(clk, r09_min, r09_mout);
        
    mc10_map : bk_round port map(clk, r09_sout, r09_mout, r10_sin);
    mr10_map : bk_reg   port map(clk, r10_sin, r10_sout);
    ms10_map : bk_sigma port map(clk, "0000", r09_mout, r10_min);
    mm10_map : bk_reg   port map(clk, r10_min, r10_mout);
        
    mc11_map : bk_round port map(clk, r10_sout, r10_mout, r11_sin);
    mr11_map : bk_reg   port map(clk, r11_sin, r11_sout);
    ms11_map : bk_sigma port map(clk, "0001", r10_mout, r11_min);
    mm11_map : bk_reg   port map(clk, r11_min, r11_mout);
        
    mc12_map : bk_round port map(clk, r11_sout, r11_mout, r12_sin);
    mr12_map : bk_reg   port map(clk, r12_sin, r12_sout);
    ms12_map : bk_sigma port map(clk, "0010", r11_mout, r12_min);
    mm12_map : bk_reg   port map(clk, r12_min, r12_mout);
        
    mc13_map : bk_round port map(clk, r12_sout, r12_mout, r13_sin);
    mr13_map : bk_reg   port map(clk, r13_sin, r13_sout);
    ms13_map : bk_sigma port map(clk, "0011", r12_mout, r13_min);
    mm13_map : bk_reg   port map(clk, r13_min, r13_mout);
        
    mc14_map : bk_round port map(clk, r13_sout, r13_mout, r14_sin);
    mr14_map : bk_reg   port map(clk, r14_sin, r14_sout);
    ms14_map : bk_sigma port map(clk, "0100", r13_mout, r14_min);
    mm14_map : bk_reg   port map(clk, r14_min, r14_mout);
        
    mc15_map : bk_round port map(clk, r14_sout, r14_mout, r15_sin);
    mr15_map : bk_reg   port map(clk, r15_sin, r15_sout);
    -- ms15_map : bk_sigma port map("0101", r14_mout, r15_min);
    -- mm15_map : bk_reg   port map(clk, r15_min, r15_mout);
        
    mhii_map : bk_hreg  port map(clk, chn_in, rii_chain);
    mh00a_map : bk_hreg  port map(clk, rii_chain, r00a_hout);
    mh00b_map : bk_hreg  port map(clk, r00a_hout, r00b_hout);
    mh01a_map : bk_hreg  port map(clk, r00b_hout, r01a_hout);
    mh01b_map : bk_hreg  port map(clk, r01a_hout, r01b_hout);
    mh02a_map : bk_hreg  port map(clk, r01b_hout, r02a_hout);
    mh02b_map : bk_hreg  port map(clk, r02a_hout, r02b_hout);
    mh03a_map : bk_hreg  port map(clk, r02b_hout, r03a_hout);
    mh03b_map : bk_hreg  port map(clk, r03a_hout, r03b_hout);
    mh04a_map : bk_hreg  port map(clk, r03b_hout, r04a_hout);
    mh04b_map : bk_hreg  port map(clk, r04a_hout, r04b_hout);
    mh05a_map : bk_hreg  port map(clk, r04b_hout, r05a_hout);
    mh05b_map : bk_hreg  port map(clk, r05a_hout, r05b_hout);
    mh06a_map : bk_hreg  port map(clk, r05b_hout, r06a_hout);
    mh06b_map : bk_hreg  port map(clk, r06a_hout, r06b_hout);
    mh07a_map : bk_hreg  port map(clk, r06b_hout, r07a_hout);
    mh07b_map : bk_hreg  port map(clk, r07a_hout, r07b_hout);
    mh08a_map : bk_hreg  port map(clk, r07b_hout, r08a_hout);
    mh08b_map : bk_hreg  port map(clk, r08a_hout, r08b_hout);
    mh09a_map : bk_hreg  port map(clk, r08b_hout, r09a_hout);
    mh09b_map : bk_hreg  port map(clk, r09a_hout, r09b_hout);
    mh10a_map : bk_hreg  port map(clk, r09b_hout, r10a_hout);
    mh10b_map : bk_hreg  port map(clk, r10a_hout, r10b_hout);
    mh11a_map : bk_hreg  port map(clk, r10b_hout, r11a_hout);
    mh11b_map : bk_hreg  port map(clk, r11a_hout, r11b_hout);
    mh12a_map : bk_hreg  port map(clk, r11b_hout, r12a_hout);
    mh12b_map : bk_hreg  port map(clk, r12a_hout, r12b_hout);
    mh13a_map : bk_hreg  port map(clk, r12b_hout, r13a_hout);
    mh13b_map : bk_hreg  port map(clk, r13a_hout, r13b_hout);
    mh14a_map : bk_hreg  port map(clk, r13b_hout, r14a_hout);
    mh14b_map : bk_hreg  port map(clk, r14a_hout, r14b_hout);
    mh15a_map : bk_hreg  port map(clk, r14b_hout, r15a_hout);
    mh15b_map : bk_hreg  port map(clk, r15a_hout, r15b_hout);
		
    roo_chain <= r15b_hout xor r15_sout(1023 downto 512) xor r15_sout(511 downto 0);
    mhoo_map : bk_hreg  port map(clk, roo_chain,  roo_hout);
        
    dout <= roo_hout;

end rtl;
