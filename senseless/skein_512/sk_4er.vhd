--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sk_4er is

port (  st_in  : in  std_logic_vector(511 downto 0);
        st_out : out std_logic_vector(511 downto 0)
     );

end sk_4er;

architecture rtl of sk_4er is

    component sk_mix
    port (  x0 : in  std_logic_vector(63 downto 0);
            x1 : in  std_logic_vector(63 downto 0);
            Rj : in  std_logic_vector(1 downto 0);
            Rd : in  std_logic_vector(2 downto 0);
            y0 : out std_logic_vector(63 downto 0);
            y1 : out std_logic_vector(63 downto 0)
         );
    end component;
    ----------------------------------------------------------------------------
    -- Internal signal declarations
    ----------------------------------------------------------------------------

    signal r0_mi0, r0_mi1, r0_mi2, r0_mi3, r0_mi4, r0_mi5, r0_mi6, r0_mi7 : std_logic_vector(63 downto 0);
    signal r0_mo0, r0_mo1, r0_mo2, r0_mo3, r0_mo4, r0_mo5, r0_mo6, r0_mo7 : std_logic_vector(63 downto 0);
    signal r1_mo0, r1_mo1, r1_mo2, r1_mo3, r1_mo4, r1_mo5, r1_mo6, r1_mo7 : std_logic_vector(63 downto 0);
    signal r2_mo0, r2_mo1, r2_mo2, r2_mo3, r2_mo4, r2_mo5, r2_mo6, r2_mo7 : std_logic_vector(63 downto 0);
    signal r3_mo0, r3_mo1, r3_mo2, r3_mo3, r3_mo4, r3_mo5, r3_mo6, r3_mo7 : std_logic_vector(63 downto 0);

begin  -- Rtl
    
    r0_mi0 <= st_in(511 downto 448);
    r0_mi1 <= st_in(447 downto 384);
    r0_mi2 <= st_in(383 downto 320);
    r0_mi3 <= st_in(319 downto 256);
    r0_mi4 <= st_in(255 downto 192);
    r0_mi5 <= st_in(191 downto 128);
    r0_mi6 <= st_in(127 downto  64);
    r0_mi7 <= st_in( 63 downto   0);

    mm00_map : sk_mix port map(r0_mi0,r0_mi1,"00","000",r0_mo0,r0_mo1);
    mm01_map : sk_mix port map(r0_mi2,r0_mi3,"01","000",r0_mo2,r0_mo3);
    mm02_map : sk_mix port map(r0_mi4,r0_mi5,"10","000",r0_mo4,r0_mo5);
    mm03_map : sk_mix port map(r0_mi6,r0_mi7,"11","000",r0_mo6,r0_mo7);
    
    mm10_map : sk_mix port map(r0_mo2,r0_mo1,"00","001",r1_mo2,r1_mo1);
    mm11_map : sk_mix port map(r0_mo4,r0_mo7,"01","001",r1_mo4,r1_mo7);
    mm12_map : sk_mix port map(r0_mo6,r0_mo5,"10","001",r1_mo6,r1_mo5);
    mm13_map : sk_mix port map(r0_mo0,r0_mo3,"11","001",r1_mo0,r1_mo3);
    
    mm20_map : sk_mix port map(r1_mo4,r1_mo1,"00","010",r2_mo4,r2_mo1);
    mm21_map : sk_mix port map(r1_mo6,r1_mo3,"01","010",r2_mo6,r2_mo3);
    mm22_map : sk_mix port map(r1_mo0,r1_mo5,"10","010",r2_mo0,r2_mo5);
    mm23_map : sk_mix port map(r1_mo2,r1_mo7,"11","010",r2_mo2,r2_mo7);
    
    mm30_map : sk_mix port map(r2_mo6,r2_mo1,"00","011",r3_mo6,r3_mo1);
    mm31_map : sk_mix port map(r2_mo0,r2_mo7,"01","011",r3_mo0,r3_mo7);
    mm32_map : sk_mix port map(r2_mo2,r2_mo5,"10","011",r3_mo2,r3_mo5);
    mm33_map : sk_mix port map(r2_mo4,r2_mo3,"11","011",r3_mo4,r3_mo3);
    
    st_out <= r3_mo0 & r3_mo1 & r3_mo2 & r3_mo3 & r3_mo4 & r3_mo5 & r3_mo6 & r3_mo7;
    
end rtl;
