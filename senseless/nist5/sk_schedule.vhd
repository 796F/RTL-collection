--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sk_schedule is

port (  clk      : in  std_logic;
        key_in   : in  std_logic_vector(511 downto 0);
        tweak    : in  std_logic_vector(127 downto 0);
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

end sk_schedule;

architecture rtl of sk_schedule is

    component sk_schedule_round
    port (  k5  : in  std_logic_vector(63 downto 0);
            k6  : in  std_logic_vector(63 downto 0);
            k7  : in  std_logic_vector(63 downto 0);
            t0  : in  std_logic_vector(63 downto 0);
            t1  : in  std_logic_vector(63 downto 0);
            s   : in  std_logic_vector(4 downto 0);
            ks5 : out std_logic_vector(63 downto 0);
            ks6 : out std_logic_vector(63 downto 0);
            ks7 : out std_logic_vector(63 downto 0)
         );
    end component;
    
    component sk_kreg
    port (  clk     : in  std_logic;
            k0_in   : in  std_logic_vector(63 downto 0);
            k1_in   : in  std_logic_vector(63 downto 0);
            k2_in   : in  std_logic_vector(63 downto 0);
            k3_in   : in  std_logic_vector(63 downto 0);
            k4_in   : in  std_logic_vector(63 downto 0);
            k5_in   : in  std_logic_vector(63 downto 0);
            k6_in   : in  std_logic_vector(63 downto 0);
            k7_in   : in  std_logic_vector(63 downto 0);
            k8_in   : in  std_logic_vector(63 downto 0);
            t0_in   : in  std_logic_vector(63 downto 0);
            t1_in   : in  std_logic_vector(63 downto 0);
            t2_in   : in  std_logic_vector(63 downto 0);
            x5_in   : in  std_logic_vector(63 downto 0);
            x6_in   : in  std_logic_vector(63 downto 0);
            x7_in   : in  std_logic_vector(63 downto 0);
            k0_out  : out std_logic_vector(63 downto 0);
            k1_out  : out std_logic_vector(63 downto 0);
            k2_out  : out std_logic_vector(63 downto 0);
            k3_out  : out std_logic_vector(63 downto 0);
            k4_out  : out std_logic_vector(63 downto 0);
            k5_out  : out std_logic_vector(63 downto 0);
            k6_out  : out std_logic_vector(63 downto 0);
            k7_out  : out std_logic_vector(63 downto 0);
            k8_out  : out std_logic_vector(63 downto 0);
            t0_out  : out std_logic_vector(63 downto 0);
            t1_out  : out std_logic_vector(63 downto 0);
            t2_out  : out std_logic_vector(63 downto 0);
            x5_out  : out std_logic_vector(63 downto 0);
            x6_out  : out std_logic_vector(63 downto 0);
            x7_out  : out std_logic_vector(63 downto 0)
         );
    end component;
    
    signal rii_ko0, rii_ko1, rii_ko2, rii_ko3, rii_ko4, rii_ko5, rii_ko6, rii_ko7, rii_ko8, rii_to0, rii_to1, rii_to2, rii_xo5, rii_xo6, rii_xo7 : std_logic_vector(63 downto 0);
    signal r00_ki0, r00_ki1, r00_ki2, r00_ki3, r00_ki4, r00_ki5, r00_ki6, r00_ki7, r00_ki8, r00_ti0, r00_ti1, r00_ti2, r00_xi5, r00_xi6, r00_xi7 : std_logic_vector(63 downto 0);
    signal r00_ko0, r00_ko1, r00_ko2, r00_ko3, r00_ko4, r00_ko5, r00_ko6, r00_ko7, r00_ko8, r00_to0, r00_to1, r00_to2, r00_xo5, r00_xo6, r00_xo7 : std_logic_vector(63 downto 0);
    signal r01_ki0, r01_ki1, r01_ki2, r01_ki3, r01_ki4, r01_ki5, r01_ki6, r01_ki7, r01_ki8, r01_ti0, r01_ti1, r01_ti2, r01_xi5, r01_xi6, r01_xi7 : std_logic_vector(63 downto 0);
    signal r01_ko0, r01_ko1, r01_ko2, r01_ko3, r01_ko4, r01_ko5, r01_ko6, r01_ko7, r01_ko8, r01_to0, r01_to1, r01_to2, r01_xo5, r01_xo6, r01_xo7 : std_logic_vector(63 downto 0);
    signal r02_ki0, r02_ki1, r02_ki2, r02_ki3, r02_ki4, r02_ki5, r02_ki6, r02_ki7, r02_ki8, r02_ti0, r02_ti1, r02_ti2, r02_xi5, r02_xi6, r02_xi7 : std_logic_vector(63 downto 0);
    signal r02_ko0, r02_ko1, r02_ko2, r02_ko3, r02_ko4, r02_ko5, r02_ko6, r02_ko7, r02_ko8, r02_to0, r02_to1, r02_to2, r02_xo5, r02_xo6, r02_xo7 : std_logic_vector(63 downto 0);
    signal r03_ki0, r03_ki1, r03_ki2, r03_ki3, r03_ki4, r03_ki5, r03_ki6, r03_ki7, r03_ki8, r03_ti0, r03_ti1, r03_ti2, r03_xi5, r03_xi6, r03_xi7 : std_logic_vector(63 downto 0);
    signal r03_ko0, r03_ko1, r03_ko2, r03_ko3, r03_ko4, r03_ko5, r03_ko6, r03_ko7, r03_ko8, r03_to0, r03_to1, r03_to2, r03_xo5, r03_xo6, r03_xo7 : std_logic_vector(63 downto 0);
    signal r04_ki0, r04_ki1, r04_ki2, r04_ki3, r04_ki4, r04_ki5, r04_ki6, r04_ki7, r04_ki8, r04_ti0, r04_ti1, r04_ti2, r04_xi5, r04_xi6, r04_xi7 : std_logic_vector(63 downto 0);
    signal r04_ko0, r04_ko1, r04_ko2, r04_ko3, r04_ko4, r04_ko5, r04_ko6, r04_ko7, r04_ko8, r04_to0, r04_to1, r04_to2, r04_xo5, r04_xo6, r04_xo7 : std_logic_vector(63 downto 0);
    signal r05_ki0, r05_ki1, r05_ki2, r05_ki3, r05_ki4, r05_ki5, r05_ki6, r05_ki7, r05_ki8, r05_ti0, r05_ti1, r05_ti2, r05_xi5, r05_xi6, r05_xi7 : std_logic_vector(63 downto 0);
    signal r05_ko0, r05_ko1, r05_ko2, r05_ko3, r05_ko4, r05_ko5, r05_ko6, r05_ko7, r05_ko8, r05_to0, r05_to1, r05_to2, r05_xo5, r05_xo6, r05_xo7 : std_logic_vector(63 downto 0);
    signal r06_ki0, r06_ki1, r06_ki2, r06_ki3, r06_ki4, r06_ki5, r06_ki6, r06_ki7, r06_ki8, r06_ti0, r06_ti1, r06_ti2, r06_xi5, r06_xi6, r06_xi7 : std_logic_vector(63 downto 0);
    signal r06_ko0, r06_ko1, r06_ko2, r06_ko3, r06_ko4, r06_ko5, r06_ko6, r06_ko7, r06_ko8, r06_to0, r06_to1, r06_to2, r06_xo5, r06_xo6, r06_xo7 : std_logic_vector(63 downto 0);
    signal r07_ki0, r07_ki1, r07_ki2, r07_ki3, r07_ki4, r07_ki5, r07_ki6, r07_ki7, r07_ki8, r07_ti0, r07_ti1, r07_ti2, r07_xi5, r07_xi6, r07_xi7 : std_logic_vector(63 downto 0);
    signal r07_ko0, r07_ko1, r07_ko2, r07_ko3, r07_ko4, r07_ko5, r07_ko6, r07_ko7, r07_ko8, r07_to0, r07_to1, r07_to2, r07_xo5, r07_xo6, r07_xo7 : std_logic_vector(63 downto 0);
    signal r08_ki0, r08_ki1, r08_ki2, r08_ki3, r08_ki4, r08_ki5, r08_ki6, r08_ki7, r08_ki8, r08_ti0, r08_ti1, r08_ti2, r08_xi5, r08_xi6, r08_xi7 : std_logic_vector(63 downto 0);
    signal r08_ko0, r08_ko1, r08_ko2, r08_ko3, r08_ko4, r08_ko5, r08_ko6, r08_ko7, r08_ko8, r08_to0, r08_to1, r08_to2, r08_xo5, r08_xo6, r08_xo7 : std_logic_vector(63 downto 0);
    signal r09_ki0, r09_ki1, r09_ki2, r09_ki3, r09_ki4, r09_ki5, r09_ki6, r09_ki7, r09_ki8, r09_ti0, r09_ti1, r09_ti2, r09_xi5, r09_xi6, r09_xi7 : std_logic_vector(63 downto 0);
    signal r09_ko0, r09_ko1, r09_ko2, r09_ko3, r09_ko4, r09_ko5, r09_ko6, r09_ko7, r09_ko8, r09_to0, r09_to1, r09_to2, r09_xo5, r09_xo6, r09_xo7 : std_logic_vector(63 downto 0);
    signal r10_ki0, r10_ki1, r10_ki2, r10_ki3, r10_ki4, r10_ki5, r10_ki6, r10_ki7, r10_ki8, r10_ti0, r10_ti1, r10_ti2, r10_xi5, r10_xi6, r10_xi7 : std_logic_vector(63 downto 0);
    signal r10_ko0, r10_ko1, r10_ko2, r10_ko3, r10_ko4, r10_ko5, r10_ko6, r10_ko7, r10_ko8, r10_to0, r10_to1, r10_to2, r10_xo5, r10_xo6, r10_xo7 : std_logic_vector(63 downto 0);
    signal r11_ki0, r11_ki1, r11_ki2, r11_ki3, r11_ki4, r11_ki5, r11_ki6, r11_ki7, r11_ki8, r11_ti0, r11_ti1, r11_ti2, r11_xi5, r11_xi6, r11_xi7 : std_logic_vector(63 downto 0);
    signal r11_ko0, r11_ko1, r11_ko2, r11_ko3, r11_ko4, r11_ko5, r11_ko6, r11_ko7, r11_ko8, r11_to0, r11_to1, r11_to2, r11_xo5, r11_xo6, r11_xo7 : std_logic_vector(63 downto 0);
    signal r12_ki0, r12_ki1, r12_ki2, r12_ki3, r12_ki4, r12_ki5, r12_ki6, r12_ki7, r12_ki8, r12_ti0, r12_ti1, r12_ti2, r12_xi5, r12_xi6, r12_xi7 : std_logic_vector(63 downto 0);
    signal r12_ko0, r12_ko1, r12_ko2, r12_ko3, r12_ko4, r12_ko5, r12_ko6, r12_ko7, r12_ko8, r12_to0, r12_to1, r12_to2, r12_xo5, r12_xo6, r12_xo7 : std_logic_vector(63 downto 0);
    signal r13_ki0, r13_ki1, r13_ki2, r13_ki3, r13_ki4, r13_ki5, r13_ki6, r13_ki7, r13_ki8, r13_ti0, r13_ti1, r13_ti2, r13_xi5, r13_xi6, r13_xi7 : std_logic_vector(63 downto 0);
    signal r13_ko0, r13_ko1, r13_ko2, r13_ko3, r13_ko4, r13_ko5, r13_ko6, r13_ko7, r13_ko8, r13_to0, r13_to1, r13_to2, r13_xo5, r13_xo6, r13_xo7 : std_logic_vector(63 downto 0);
    signal r14_ki0, r14_ki1, r14_ki2, r14_ki3, r14_ki4, r14_ki5, r14_ki6, r14_ki7, r14_ki8, r14_ti0, r14_ti1, r14_ti2, r14_xi5, r14_xi6, r14_xi7 : std_logic_vector(63 downto 0);
    signal r14_ko0, r14_ko1, r14_ko2, r14_ko3, r14_ko4, r14_ko5, r14_ko6, r14_ko7, r14_ko8, r14_to0, r14_to1, r14_to2, r14_xo5, r14_xo6, r14_xo7 : std_logic_vector(63 downto 0);
    signal r15_ki0, r15_ki1, r15_ki2, r15_ki3, r15_ki4, r15_ki5, r15_ki6, r15_ki7, r15_ki8, r15_ti0, r15_ti1, r15_ti2, r15_xi5, r15_xi6, r15_xi7 : std_logic_vector(63 downto 0);
    signal r15_ko0, r15_ko1, r15_ko2, r15_ko3, r15_ko4, r15_ko5, r15_ko6, r15_ko7, r15_ko8, r15_to0, r15_to1, r15_to2, r15_xo5, r15_xo6, r15_xo7 : std_logic_vector(63 downto 0);
    signal r16_ki0, r16_ki1, r16_ki2, r16_ki3, r16_ki4, r16_ki5, r16_ki6, r16_ki7, r16_ki8, r16_ti0, r16_ti1, r16_ti2, r16_xi5, r16_xi6, r16_xi7 : std_logic_vector(63 downto 0);
    signal r16_ko0, r16_ko1, r16_ko2, r16_ko3, r16_ko4, r16_ko5, r16_ko6, r16_ko7, r16_ko8, r16_to0, r16_to1, r16_to2, r16_xo5, r16_xo6, r16_xo7 : std_logic_vector(63 downto 0);
    signal r17_ki0, r17_ki1, r17_ki2, r17_ki3, r17_ki4, r17_ki5, r17_ki6, r17_ki7, r17_ki8, r17_ti0, r17_ti1, r17_ti2, r17_xi5, r17_xi6, r17_xi7 : std_logic_vector(63 downto 0);
    signal r17_ko0, r17_ko1, r17_ko2, r17_ko3, r17_ko4, r17_ko5, r17_ko6, r17_ko7, r17_ko8, r17_to0, r17_to1, r17_to2, r17_xo5, r17_xo6, r17_xo7 : std_logic_vector(63 downto 0);
    signal r18_ki0, r18_ki1, r18_ki2, r18_ki3, r18_ki4, r18_ki5, r18_ki6, r18_ki7, r18_ki8, r18_ti0, r18_ti1, r18_ti2, r18_xi5, r18_xi6, r18_xi7 : std_logic_vector(63 downto 0);
    signal r18_ko0, r18_ko1, r18_ko2, r18_ko3, r18_ko4, r18_ko5, r18_ko6, r18_ko7, r18_ko8, r18_to0, r18_to1, r18_to2, r18_xo5, r18_xo6, r18_xo7 : std_logic_vector(63 downto 0);

begin  -- Rtl
    
    rii_ko0 <= key_in(511 downto 448);
    rii_ko1 <= key_in(447 downto 384);
    rii_ko2 <= key_in(383 downto 320);
    rii_ko3 <= key_in(319 downto 256);
    rii_ko4 <= key_in(255 downto 192);
    rii_ko5 <= key_in(191 downto 128);
    rii_ko6 <= key_in(127 downto  64);
    rii_ko7 <= key_in( 63 downto   0);
    rii_ko8 <= rii_ko0 xor rii_ko1 xor rii_ko2 xor rii_ko3 xor rii_ko4 xor rii_ko5 xor rii_ko6 xor rii_ko7 xor x"1BD11BDAA9FC1A22";

    rii_to0 <= tweak(127 downto  64);
    rii_to1 <= tweak( 63 downto   0);
    rii_to2 <= rii_to0 xor rii_to1;

    mc00_map : sk_schedule_round port map(rii_ko5,rii_ko6,rii_ko7,rii_to0,rii_to1, "00000", r00_xi5,r00_xi6,r00_xi7);
    mc01_map : sk_schedule_round port map(r00_ko6,r00_ko7,r00_ko8,r00_to1,r00_to2, "00001", r01_xi5,r01_xi6,r01_xi7);
    mc02_map : sk_schedule_round port map(r01_ko7,r01_ko8,r01_ko0,r01_to2,r01_to0, "00010", r02_xi5,r02_xi6,r02_xi7);
    mc03_map : sk_schedule_round port map(r02_ko8,r02_ko0,r02_ko1,r02_to0,r02_to1, "00011", r03_xi5,r03_xi6,r03_xi7);
    mc04_map : sk_schedule_round port map(r03_ko0,r03_ko1,r03_ko2,r03_to1,r03_to2, "00100", r04_xi5,r04_xi6,r04_xi7);
    mc05_map : sk_schedule_round port map(r04_ko1,r04_ko2,r04_ko3,r04_to2,r04_to0, "00101", r05_xi5,r05_xi6,r05_xi7);
    mc06_map : sk_schedule_round port map(r05_ko2,r05_ko3,r05_ko4,r05_to0,r05_to1, "00110", r06_xi5,r06_xi6,r06_xi7);
    mc07_map : sk_schedule_round port map(r06_ko3,r06_ko4,r06_ko5,r06_to1,r06_to2, "00111", r07_xi5,r07_xi6,r07_xi7);
    mc08_map : sk_schedule_round port map(r07_ko4,r07_ko5,r07_ko6,r07_to2,r07_to0, "01000", r08_xi5,r08_xi6,r08_xi7);
    mc09_map : sk_schedule_round port map(r08_ko5,r08_ko6,r08_ko7,r08_to0,r08_to1, "01001", r09_xi5,r09_xi6,r09_xi7);
    mc10_map : sk_schedule_round port map(r09_ko6,r09_ko7,r09_ko8,r09_to1,r09_to2, "01010", r10_xi5,r10_xi6,r10_xi7);
    mc11_map : sk_schedule_round port map(r10_ko7,r10_ko8,r10_ko0,r10_to2,r10_to0, "01011", r11_xi5,r11_xi6,r11_xi7);
    mc12_map : sk_schedule_round port map(r11_ko8,r11_ko0,r11_ko1,r11_to0,r11_to1, "01100", r12_xi5,r12_xi6,r12_xi7);
    mc13_map : sk_schedule_round port map(r12_ko0,r12_ko1,r12_ko2,r12_to1,r12_to2, "01101", r13_xi5,r13_xi6,r13_xi7);
    mc14_map : sk_schedule_round port map(r13_ko1,r13_ko2,r13_ko3,r13_to2,r13_to0, "01110", r14_xi5,r14_xi6,r14_xi7);
    mc15_map : sk_schedule_round port map(r14_ko2,r14_ko3,r14_ko4,r14_to0,r14_to1, "01111", r15_xi5,r15_xi6,r15_xi7);
    mc16_map : sk_schedule_round port map(r15_ko3,r15_ko4,r15_ko5,r15_to1,r15_to2, "10000", r16_xi5,r16_xi6,r16_xi7);
    mc17_map : sk_schedule_round port map(r16_ko4,r16_ko5,r16_ko6,r16_to2,r16_to0, "10001", r17_xi5,r17_xi6,r17_xi7);
    mc18_map : sk_schedule_round port map(r17_ko5,r17_ko6,r17_ko7,r17_to0,r17_to1, "10010", r18_xi5,r18_xi6,r18_xi7);
        
    mr00_map : sk_kreg port map(clk,rii_ko0,rii_ko1,rii_ko2,rii_ko3,rii_ko4,rii_ko5,rii_ko6,rii_ko7,rii_ko8,rii_to0,rii_to1,rii_to2,r00_xi5,r00_xi6,r00_xi7, r00_ko0,r00_ko1,r00_ko2,r00_ko3,r00_ko4,r00_ko5,r00_ko6,r00_ko7,r00_ko8,r00_to0,r00_to1,r00_to2,r00_xo5,r00_xo6,r00_xo7);
    mr01_map : sk_kreg port map(clk,r00_ko0,r00_ko1,r00_ko2,r00_ko3,r00_ko4,r00_ko5,r00_ko6,r00_ko7,r00_ko8,r00_to0,r00_to1,r00_to2,r01_xi5,r01_xi6,r01_xi7, r01_ko0,r01_ko1,r01_ko2,r01_ko3,r01_ko4,r01_ko5,r01_ko6,r01_ko7,r01_ko8,r01_to0,r01_to1,r01_to2,r01_xo5,r01_xo6,r01_xo7);
    mr02_map : sk_kreg port map(clk,r01_ko0,r01_ko1,r01_ko2,r01_ko3,r01_ko4,r01_ko5,r01_ko6,r01_ko7,r01_ko8,r01_to0,r01_to1,r01_to2,r02_xi5,r02_xi6,r02_xi7, r02_ko0,r02_ko1,r02_ko2,r02_ko3,r02_ko4,r02_ko5,r02_ko6,r02_ko7,r02_ko8,r02_to0,r02_to1,r02_to2,r02_xo5,r02_xo6,r02_xo7);
    mr03_map : sk_kreg port map(clk,r02_ko0,r02_ko1,r02_ko2,r02_ko3,r02_ko4,r02_ko5,r02_ko6,r02_ko7,r02_ko8,r02_to0,r02_to1,r02_to2,r03_xi5,r03_xi6,r03_xi7, r03_ko0,r03_ko1,r03_ko2,r03_ko3,r03_ko4,r03_ko5,r03_ko6,r03_ko7,r03_ko8,r03_to0,r03_to1,r03_to2,r03_xo5,r03_xo6,r03_xo7);
    mr04_map : sk_kreg port map(clk,r03_ko0,r03_ko1,r03_ko2,r03_ko3,r03_ko4,r03_ko5,r03_ko6,r03_ko7,r03_ko8,r03_to0,r03_to1,r03_to2,r04_xi5,r04_xi6,r04_xi7, r04_ko0,r04_ko1,r04_ko2,r04_ko3,r04_ko4,r04_ko5,r04_ko6,r04_ko7,r04_ko8,r04_to0,r04_to1,r04_to2,r04_xo5,r04_xo6,r04_xo7);
    mr05_map : sk_kreg port map(clk,r04_ko0,r04_ko1,r04_ko2,r04_ko3,r04_ko4,r04_ko5,r04_ko6,r04_ko7,r04_ko8,r04_to0,r04_to1,r04_to2,r05_xi5,r05_xi6,r05_xi7, r05_ko0,r05_ko1,r05_ko2,r05_ko3,r05_ko4,r05_ko5,r05_ko6,r05_ko7,r05_ko8,r05_to0,r05_to1,r05_to2,r05_xo5,r05_xo6,r05_xo7);
    mr06_map : sk_kreg port map(clk,r05_ko0,r05_ko1,r05_ko2,r05_ko3,r05_ko4,r05_ko5,r05_ko6,r05_ko7,r05_ko8,r05_to0,r05_to1,r05_to2,r06_xi5,r06_xi6,r06_xi7, r06_ko0,r06_ko1,r06_ko2,r06_ko3,r06_ko4,r06_ko5,r06_ko6,r06_ko7,r06_ko8,r06_to0,r06_to1,r06_to2,r06_xo5,r06_xo6,r06_xo7);
    mr07_map : sk_kreg port map(clk,r06_ko0,r06_ko1,r06_ko2,r06_ko3,r06_ko4,r06_ko5,r06_ko6,r06_ko7,r06_ko8,r06_to0,r06_to1,r06_to2,r07_xi5,r07_xi6,r07_xi7, r07_ko0,r07_ko1,r07_ko2,r07_ko3,r07_ko4,r07_ko5,r07_ko6,r07_ko7,r07_ko8,r07_to0,r07_to1,r07_to2,r07_xo5,r07_xo6,r07_xo7);
    mr08_map : sk_kreg port map(clk,r07_ko0,r07_ko1,r07_ko2,r07_ko3,r07_ko4,r07_ko5,r07_ko6,r07_ko7,r07_ko8,r07_to0,r07_to1,r07_to2,r08_xi5,r08_xi6,r08_xi7, r08_ko0,r08_ko1,r08_ko2,r08_ko3,r08_ko4,r08_ko5,r08_ko6,r08_ko7,r08_ko8,r08_to0,r08_to1,r08_to2,r08_xo5,r08_xo6,r08_xo7);
    mr09_map : sk_kreg port map(clk,r08_ko0,r08_ko1,r08_ko2,r08_ko3,r08_ko4,r08_ko5,r08_ko6,r08_ko7,r08_ko8,r08_to0,r08_to1,r08_to2,r09_xi5,r09_xi6,r09_xi7, r09_ko0,r09_ko1,r09_ko2,r09_ko3,r09_ko4,r09_ko5,r09_ko6,r09_ko7,r09_ko8,r09_to0,r09_to1,r09_to2,r09_xo5,r09_xo6,r09_xo7);
    mr10_map : sk_kreg port map(clk,r09_ko0,r09_ko1,r09_ko2,r09_ko3,r09_ko4,r09_ko5,r09_ko6,r09_ko7,r09_ko8,r09_to0,r09_to1,r09_to2,r10_xi5,r10_xi6,r10_xi7, r10_ko0,r10_ko1,r10_ko2,r10_ko3,r10_ko4,r10_ko5,r10_ko6,r10_ko7,r10_ko8,r10_to0,r10_to1,r10_to2,r10_xo5,r10_xo6,r10_xo7);
    mr11_map : sk_kreg port map(clk,r10_ko0,r10_ko1,r10_ko2,r10_ko3,r10_ko4,r10_ko5,r10_ko6,r10_ko7,r10_ko8,r10_to0,r10_to1,r10_to2,r11_xi5,r11_xi6,r11_xi7, r11_ko0,r11_ko1,r11_ko2,r11_ko3,r11_ko4,r11_ko5,r11_ko6,r11_ko7,r11_ko8,r11_to0,r11_to1,r11_to2,r11_xo5,r11_xo6,r11_xo7);
    mr12_map : sk_kreg port map(clk,r11_ko0,r11_ko1,r11_ko2,r11_ko3,r11_ko4,r11_ko5,r11_ko6,r11_ko7,r11_ko8,r11_to0,r11_to1,r11_to2,r12_xi5,r12_xi6,r12_xi7, r12_ko0,r12_ko1,r12_ko2,r12_ko3,r12_ko4,r12_ko5,r12_ko6,r12_ko7,r12_ko8,r12_to0,r12_to1,r12_to2,r12_xo5,r12_xo6,r12_xo7);
    mr13_map : sk_kreg port map(clk,r12_ko0,r12_ko1,r12_ko2,r12_ko3,r12_ko4,r12_ko5,r12_ko6,r12_ko7,r12_ko8,r12_to0,r12_to1,r12_to2,r13_xi5,r13_xi6,r13_xi7, r13_ko0,r13_ko1,r13_ko2,r13_ko3,r13_ko4,r13_ko5,r13_ko6,r13_ko7,r13_ko8,r13_to0,r13_to1,r13_to2,r13_xo5,r13_xo6,r13_xo7);
    mr14_map : sk_kreg port map(clk,r13_ko0,r13_ko1,r13_ko2,r13_ko3,r13_ko4,r13_ko5,r13_ko6,r13_ko7,r13_ko8,r13_to0,r13_to1,r13_to2,r14_xi5,r14_xi6,r14_xi7, r14_ko0,r14_ko1,r14_ko2,r14_ko3,r14_ko4,r14_ko5,r14_ko6,r14_ko7,r14_ko8,r14_to0,r14_to1,r14_to2,r14_xo5,r14_xo6,r14_xo7);
    mr15_map : sk_kreg port map(clk,r14_ko0,r14_ko1,r14_ko2,r14_ko3,r14_ko4,r14_ko5,r14_ko6,r14_ko7,r14_ko8,r14_to0,r14_to1,r14_to2,r15_xi5,r15_xi6,r15_xi7, r15_ko0,r15_ko1,r15_ko2,r15_ko3,r15_ko4,r15_ko5,r15_ko6,r15_ko7,r15_ko8,r15_to0,r15_to1,r15_to2,r15_xo5,r15_xo6,r15_xo7);
    mr16_map : sk_kreg port map(clk,r15_ko0,r15_ko1,r15_ko2,r15_ko3,r15_ko4,r15_ko5,r15_ko6,r15_ko7,r15_ko8,r15_to0,r15_to1,r15_to2,r16_xi5,r16_xi6,r16_xi7, r16_ko0,r16_ko1,r16_ko2,r16_ko3,r16_ko4,r16_ko5,r16_ko6,r16_ko7,r16_ko8,r16_to0,r16_to1,r16_to2,r16_xo5,r16_xo6,r16_xo7);
    mr17_map : sk_kreg port map(clk,r16_ko0,r16_ko1,r16_ko2,r16_ko3,r16_ko4,r16_ko5,r16_ko6,r16_ko7,r16_ko8,r16_to0,r16_to1,r16_to2,r17_xi5,r17_xi6,r17_xi7, r17_ko0,r17_ko1,r17_ko2,r17_ko3,r17_ko4,r17_ko5,r17_ko6,r17_ko7,r17_ko8,r17_to0,r17_to1,r17_to2,r17_xo5,r17_xo6,r17_xo7);
    mr18_map : sk_kreg port map(clk,r17_ko0,r17_ko1,r17_ko2,r17_ko3,r17_ko4,r17_ko5,r17_ko6,r17_ko7,r17_ko8,r17_to0,r17_to1,r17_to2,r18_xi5,r18_xi6,r18_xi7, r18_ko0,r18_ko1,r18_ko2,r18_ko3,r18_ko4,r18_ko5,r18_ko6,r18_ko7,r18_ko8,r18_to0,r18_to1,r18_to2,r18_xo5,r18_xo6,r18_xo7);
        
    sk_out00 <= r00_ko0 & r00_ko1 & r00_ko2 & r00_ko3 & r00_ko4 & r00_xo5 & r00_xo6 & r00_xo7;
    sk_out01 <= r01_ko1 & r01_ko2 & r01_ko3 & r01_ko4 & r01_ko5 & r01_xo5 & r01_xo6 & r01_xo7;
    sk_out02 <= r02_ko2 & r02_ko3 & r02_ko4 & r02_ko5 & r02_ko6 & r02_xo5 & r02_xo6 & r02_xo7;
    sk_out03 <= r03_ko3 & r03_ko4 & r03_ko5 & r03_ko6 & r03_ko7 & r03_xo5 & r03_xo6 & r03_xo7;
    sk_out04 <= r04_ko4 & r04_ko5 & r04_ko6 & r04_ko7 & r04_ko8 & r04_xo5 & r04_xo6 & r04_xo7;
    sk_out05 <= r05_ko5 & r05_ko6 & r05_ko7 & r05_ko8 & r05_ko0 & r05_xo5 & r05_xo6 & r05_xo7;
    sk_out06 <= r06_ko6 & r06_ko7 & r06_ko8 & r06_ko0 & r06_ko1 & r06_xo5 & r06_xo6 & r06_xo7;
    sk_out07 <= r07_ko7 & r07_ko8 & r07_ko0 & r07_ko1 & r07_ko2 & r07_xo5 & r07_xo6 & r07_xo7;
    sk_out08 <= r08_ko8 & r08_ko0 & r08_ko1 & r08_ko2 & r08_ko3 & r08_xo5 & r08_xo6 & r08_xo7;
    sk_out09 <= r09_ko0 & r09_ko1 & r09_ko2 & r09_ko3 & r09_ko4 & r09_xo5 & r09_xo6 & r09_xo7;
    sk_out10 <= r10_ko1 & r10_ko2 & r10_ko3 & r10_ko4 & r10_ko5 & r10_xo5 & r10_xo6 & r10_xo7;
    sk_out11 <= r11_ko2 & r11_ko3 & r11_ko4 & r11_ko5 & r11_ko6 & r11_xo5 & r11_xo6 & r11_xo7;
    sk_out12 <= r12_ko3 & r12_ko4 & r12_ko5 & r12_ko6 & r12_ko7 & r12_xo5 & r12_xo6 & r12_xo7;
    sk_out13 <= r13_ko4 & r13_ko5 & r13_ko6 & r13_ko7 & r13_ko8 & r13_xo5 & r13_xo6 & r13_xo7;
    sk_out14 <= r14_ko5 & r14_ko6 & r14_ko7 & r14_ko8 & r14_ko0 & r14_xo5 & r14_xo6 & r14_xo7;
    sk_out15 <= r15_ko6 & r15_ko7 & r15_ko8 & r15_ko0 & r15_ko1 & r15_xo5 & r15_xo6 & r15_xo7;
    sk_out16 <= r16_ko7 & r16_ko8 & r16_ko0 & r16_ko1 & r16_ko2 & r16_xo5 & r16_xo6 & r16_xo7;
    sk_out17 <= r17_ko8 & r17_ko0 & r17_ko1 & r17_ko2 & r17_ko3 & r17_xo5 & r17_xo6 & r17_xo7;
    sk_out18 <= r18_ko0 & r18_ko1 & r18_ko2 & r18_ko3 & r18_ko4 & r18_xo5 & r18_xo6 & r18_xo7;

end rtl;
