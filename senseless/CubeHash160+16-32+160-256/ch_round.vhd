--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ch_round is

port (  state_in    : in  std_logic_vector(1023 downto 0);
        state_out   : out std_logic_vector(1023 downto 0)
     );

end ch_round;

architecture rtl of ch_round is

    ----------------------------------------------------------------------------
    -- Internal signal declarations
    ----------------------------------------------------------------------------

    signal Rin0,     Rin1,     Rin2,     Rin3,     Rin4,     Rin5,     Rin6,     Rin7     : std_logic_vector(31 downto 0);
    signal Rin8,     Rin9,     Rin10,    Rin11,    Rin12,    Rin13,    Rin14,    Rin15    : std_logic_vector(31 downto 0);
    signal Rin16,    Rin17,    Rin18,    Rin19,    Rin20,    Rin21,    Rin22,    Rin23    : std_logic_vector(31 downto 0);
    signal Rin24,    Rin25,    Rin26,    Rin27,    Rin28,    Rin29,    Rin30,    Rin31    : std_logic_vector(31 downto 0);
    signal rot7_0,   rot7_1,   rot7_2,   rot7_3,   rot7_4,   rot7_5,   rot7_6,   rot7_7   : std_logic_vector(31 downto 0);
    signal rot7_8,   rot7_9,   rot7_10,  rot7_11,  rot7_12,  rot7_13,  rot7_14,  rot7_15  : std_logic_vector(31 downto 0);
    signal add0_16,  add0_17,  add0_18,  add0_19,  add0_20,  add0_21,  add0_22,  add0_23  : std_logic_vector(31 downto 0);
    signal add0_24,  add0_25,  add0_26,  add0_27,  add0_28,  add0_29,  add0_30,  add0_31  : std_logic_vector(31 downto 0);
    signal add1_16,  add1_17,  add1_18,  add1_19,  add1_20,  add1_21,  add1_22,  add1_23  : std_logic_vector(31 downto 0);
    signal add1_24,  add1_25,  add1_26,  add1_27,  add1_28,  add1_29,  add1_30,  add1_31  : std_logic_vector(31 downto 0);
    signal rot11_0,  rot11_1,  rot11_2,  rot11_3,  rot11_4,  rot11_5,  rot11_6,  rot11_7  : std_logic_vector(31 downto 0);
    signal rot11_8,  rot11_9,  rot11_10, rot11_11, rot11_12, rot11_13, rot11_14, rot11_15 : std_logic_vector(31 downto 0);
    signal swap0_0,  swap0_1,  swap0_2,  swap0_3,  swap0_4,  swap0_5,  swap0_6,  swap0_7  : std_logic_vector(31 downto 0);
    signal swap0_8,  swap0_9,  swap0_10, swap0_11, swap0_12, swap0_13, swap0_14, swap0_15 : std_logic_vector(31 downto 0);
    signal swap1_16, swap1_17, swap1_18, swap1_19, swap1_20, swap1_21, swap1_22, swap1_23 : std_logic_vector(31 downto 0);
    signal swap1_24, swap1_25, swap1_26, swap1_27, swap1_28, swap1_29, swap1_30, swap1_31 : std_logic_vector(31 downto 0);
    signal swap2_0,  swap2_1,  swap2_2,  swap2_3,  swap2_4,  swap2_5,  swap2_6,  swap2_7  : std_logic_vector(31 downto 0);
    signal swap2_8,  swap2_9,  swap2_10, swap2_11, swap2_12, swap2_13, swap2_14, swap2_15 : std_logic_vector(31 downto 0);
    signal swap3_16, swap3_17, swap3_18, swap3_19, swap3_20, swap3_21, swap3_22, swap3_23 : std_logic_vector(31 downto 0);
    signal swap3_24, swap3_25, swap3_26, swap3_27, swap3_28, swap3_29, swap3_30, swap3_31 : std_logic_vector(31 downto 0);
    signal Xor0_0,   Xor0_1,   Xor0_2,   Xor0_3,   Xor0_4,   Xor0_5,   Xor0_6,   Xor0_7   : std_logic_vector(31 downto 0);
    signal Xor0_8,   Xor0_9,   Xor0_10,  Xor0_11,  Xor0_12,  Xor0_13,  Xor0_14,  Xor0_15  : std_logic_vector(31 downto 0);
    signal Xor1_0,   Xor1_1,   Xor1_2,   Xor1_3,   Xor1_4,   Xor1_5,   Xor1_6,   Xor1_7   : std_logic_vector(31 downto 0);
    signal Xor1_8,   Xor1_9,   Xor1_10,  Xor1_11,  Xor1_12,  Xor1_13,  Xor1_14,  Xor1_15  : std_logic_vector(31 downto 0);

begin  -- Rtl

    Rin0  <= state_in(1023 downto 992);
    Rin1  <= state_in( 991 downto 960);
    Rin2  <= state_in( 959 downto 928);
    Rin3  <= state_in( 927 downto 896);
    Rin4  <= state_in( 895 downto 864);
    Rin5  <= state_in( 863 downto 832);
    Rin6  <= state_in( 831 downto 800);
    Rin7  <= state_in( 799 downto 768);
    Rin8  <= state_in( 767 downto 736);
    Rin9  <= state_in( 735 downto 704);
    Rin10 <= state_in( 703 downto 672);
    Rin11 <= state_in( 671 downto 640);
    Rin12 <= state_in( 639 downto 608);
    Rin13 <= state_in( 607 downto 576);
    Rin14 <= state_in( 575 downto 544);
    Rin15 <= state_in( 543 downto 512);
    Rin16 <= state_in( 511 downto 480);
    Rin17 <= state_in( 479 downto 448);
    Rin18 <= state_in( 447 downto 416);
    Rin19 <= state_in( 415 downto 384);
    Rin20 <= state_in( 383 downto 352);
    Rin21 <= state_in( 351 downto 320);
    Rin22 <= state_in( 319 downto 288);
    Rin23 <= state_in( 287 downto 256);
    Rin24 <= state_in( 255 downto 224);
    Rin25 <= state_in( 223 downto 192);
    Rin26 <= state_in( 191 downto 160);
    Rin27 <= state_in( 159 downto 128);
    Rin28 <= state_in( 127 downto  96);
    Rin29 <= state_in(  95 downto  64);
    Rin30 <= state_in(  63 downto  32);
    Rin31 <= state_in(  31 downto   0);

    state_out <= Xor1_0   & Xor1_1   & Xor1_2   & Xor1_3   & Xor1_4   & Xor1_5   & Xor1_6   & Xor1_7   &
                 Xor1_8   & Xor1_9   & Xor1_10  & Xor1_11  & Xor1_12  & Xor1_13  & Xor1_14  & Xor1_15  &
                 swap3_16 & swap3_17 & swap3_18 & swap3_19 & swap3_20 & swap3_21 & swap3_22 & swap3_23 &
                 swap3_24 & swap3_25 & swap3_26 & swap3_27 & swap3_28 & swap3_29 & swap3_30 & swap3_31;

    add0_16 <= std_logic_vector(unsigned( Rin0) + unsigned(Rin16));
    add0_17 <= std_logic_vector(unsigned( Rin1) + unsigned(Rin17));
    add0_18 <= std_logic_vector(unsigned( Rin2) + unsigned(Rin18));
    add0_19 <= std_logic_vector(unsigned( Rin3) + unsigned(Rin19));
    add0_20 <= std_logic_vector(unsigned( Rin4) + unsigned(Rin20));
    add0_21 <= std_logic_vector(unsigned( Rin5) + unsigned(Rin21));
    add0_22 <= std_logic_vector(unsigned( Rin6) + unsigned(Rin22));
    add0_23 <= std_logic_vector(unsigned( Rin7) + unsigned(Rin23));
    add0_24 <= std_logic_vector(unsigned( Rin8) + unsigned(Rin24));
    add0_25 <= std_logic_vector(unsigned( Rin9) + unsigned(Rin25));
    add0_26 <= std_logic_vector(unsigned(Rin10) + unsigned(Rin26));
    add0_27 <= std_logic_vector(unsigned(Rin11) + unsigned(Rin27));
    add0_28 <= std_logic_vector(unsigned(Rin12) + unsigned(Rin28));
    add0_29 <= std_logic_vector(unsigned(Rin13) + unsigned(Rin29));
    add0_30 <= std_logic_vector(unsigned(Rin14) + unsigned(Rin30));
    add0_31 <= std_logic_vector(unsigned(Rin15) + unsigned(Rin31));

    rot7_0  <=  Rin0(24 downto 0) &  Rin0(31 downto 25);
    rot7_1  <=  Rin1(24 downto 0) &  Rin1(31 downto 25);
    rot7_2  <=  Rin2(24 downto 0) &  Rin2(31 downto 25);
    rot7_3  <=  Rin3(24 downto 0) &  Rin3(31 downto 25);
    rot7_4  <=  Rin4(24 downto 0) &  Rin4(31 downto 25);
    rot7_5  <=  Rin5(24 downto 0) &  Rin5(31 downto 25);
    rot7_6  <=  Rin6(24 downto 0) &  Rin6(31 downto 25);
    rot7_7  <=  Rin7(24 downto 0) &  Rin7(31 downto 25);
    rot7_8  <=  Rin8(24 downto 0) &  Rin8(31 downto 25);
    rot7_9  <=  Rin9(24 downto 0) &  Rin9(31 downto 25);
    rot7_10 <= Rin10(24 downto 0) & Rin10(31 downto 25);
    rot7_11 <= Rin11(24 downto 0) & Rin11(31 downto 25);
    rot7_12 <= Rin12(24 downto 0) & Rin12(31 downto 25);
    rot7_13 <= Rin13(24 downto 0) & Rin13(31 downto 25);
    rot7_14 <= Rin14(24 downto 0) & Rin14(31 downto 25);
    rot7_15 <= Rin15(24 downto 0) & Rin15(31 downto 25);

    swap0_0  <= rot7_8;
    swap0_1  <= rot7_9;
    swap0_2  <= rot7_10;
    swap0_3  <= rot7_11;
    swap0_4  <= rot7_12;
    swap0_5  <= rot7_13;
    swap0_6  <= rot7_14;
    swap0_7  <= rot7_15;
    swap0_8  <= rot7_0;
    swap0_9  <= rot7_1;
    swap0_10 <= rot7_2;
    swap0_11 <= rot7_3;
    swap0_12 <= rot7_4;
    swap0_13 <= rot7_5;
    swap0_14 <= rot7_6;
    swap0_15 <= rot7_7;

    Xor0_0  <= swap0_0  xor add0_16; 
    Xor0_1  <= swap0_1  xor add0_17; 
    Xor0_2  <= swap0_2  xor add0_18; 
    Xor0_3  <= swap0_3  xor add0_19; 
    Xor0_4  <= swap0_4  xor add0_20; 
    Xor0_5  <= swap0_5  xor add0_21; 
    Xor0_6  <= swap0_6  xor add0_22; 
    Xor0_7  <= swap0_7  xor add0_23; 
    Xor0_8  <= swap0_8  xor add0_24; 
    Xor0_9  <= swap0_9  xor add0_25; 
    Xor0_10 <= swap0_10 xor add0_26; 
    Xor0_11 <= swap0_11 xor add0_27; 
    Xor0_12 <= swap0_12 xor add0_28; 
    Xor0_13 <= swap0_13 xor add0_29; 
    Xor0_14 <= swap0_14 xor add0_30; 
    Xor0_15 <= swap0_15 xor add0_31; 

    swap1_16 <= add0_18;
    swap1_17 <= add0_19;
    swap1_18 <= add0_16;
    swap1_19 <= add0_17;
    swap1_20 <= add0_22;
    swap1_21 <= add0_23;
    swap1_22 <= add0_20;
    swap1_23 <= add0_21;
    swap1_24 <= add0_26;
    swap1_25 <= add0_27;
    swap1_26 <= add0_24;
    swap1_27 <= add0_25;
    swap1_28 <= add0_30;
    swap1_29 <= add0_31;
    swap1_30 <= add0_28;
    swap1_31 <= add0_29;

    add1_16 <= std_logic_vector(unsigned( Xor0_0) + unsigned(swap1_16));
    add1_17 <= std_logic_vector(unsigned( Xor0_1) + unsigned(swap1_17));
    add1_18 <= std_logic_vector(unsigned( Xor0_2) + unsigned(swap1_18));
    add1_19 <= std_logic_vector(unsigned( Xor0_3) + unsigned(swap1_19));
    add1_20 <= std_logic_vector(unsigned( Xor0_4) + unsigned(swap1_20));
    add1_21 <= std_logic_vector(unsigned( Xor0_5) + unsigned(swap1_21));
    add1_22 <= std_logic_vector(unsigned( Xor0_6) + unsigned(swap1_22));
    add1_23 <= std_logic_vector(unsigned( Xor0_7) + unsigned(swap1_23));
    add1_24 <= std_logic_vector(unsigned( Xor0_8) + unsigned(swap1_24));
    add1_25 <= std_logic_vector(unsigned( Xor0_9) + unsigned(swap1_25));
    add1_26 <= std_logic_vector(unsigned(Xor0_10) + unsigned(swap1_26));
    add1_27 <= std_logic_vector(unsigned(Xor0_11) + unsigned(swap1_27));
    add1_28 <= std_logic_vector(unsigned(Xor0_12) + unsigned(swap1_28));
    add1_29 <= std_logic_vector(unsigned(Xor0_13) + unsigned(swap1_29));
    add1_30 <= std_logic_vector(unsigned(Xor0_14) + unsigned(swap1_30));
    add1_31 <= std_logic_vector(unsigned(Xor0_15) + unsigned(swap1_31));

    rot11_0  <=  Xor0_0(20 downto 0) &  Xor0_0(31 downto 21);
    rot11_1  <=  Xor0_1(20 downto 0) &  Xor0_1(31 downto 21);
    rot11_2  <=  Xor0_2(20 downto 0) &  Xor0_2(31 downto 21);
    rot11_3  <=  Xor0_3(20 downto 0) &  Xor0_3(31 downto 21);
    rot11_4  <=  Xor0_4(20 downto 0) &  Xor0_4(31 downto 21);
    rot11_5  <=  Xor0_5(20 downto 0) &  Xor0_5(31 downto 21);
    rot11_6  <=  Xor0_6(20 downto 0) &  Xor0_6(31 downto 21);
    rot11_7  <=  Xor0_7(20 downto 0) &  Xor0_7(31 downto 21);
    rot11_8  <=  Xor0_8(20 downto 0) &  Xor0_8(31 downto 21);
    rot11_9  <=  Xor0_9(20 downto 0) &  Xor0_9(31 downto 21);
    rot11_10 <= Xor0_10(20 downto 0) & Xor0_10(31 downto 21);
    rot11_11 <= Xor0_11(20 downto 0) & Xor0_11(31 downto 21);
    rot11_12 <= Xor0_12(20 downto 0) & Xor0_12(31 downto 21);
    rot11_13 <= Xor0_13(20 downto 0) & Xor0_13(31 downto 21);
    rot11_14 <= Xor0_14(20 downto 0) & Xor0_14(31 downto 21);
    rot11_15 <= Xor0_15(20 downto 0) & Xor0_15(31 downto 21);

    swap2_0  <= rot11_4;
    swap2_1  <= rot11_5;
    swap2_2  <= rot11_6;
    swap2_3  <= rot11_7;
    swap2_4  <= rot11_0;
    swap2_5  <= rot11_1;
    swap2_6  <= rot11_2;
    swap2_7  <= rot11_3;
    swap2_8  <= rot11_12;
    swap2_9  <= rot11_13;
    swap2_10 <= rot11_14;
    swap2_11 <= rot11_15;
    swap2_12 <= rot11_8;
    swap2_13 <= rot11_9;
    swap2_14 <= rot11_10;
    swap2_15 <= rot11_11;

    Xor1_0  <= swap2_0  xor add1_16; 
    Xor1_1  <= swap2_1  xor add1_17; 
    Xor1_2  <= swap2_2  xor add1_18; 
    Xor1_3  <= swap2_3  xor add1_19; 
    Xor1_4  <= swap2_4  xor add1_20; 
    Xor1_5  <= swap2_5  xor add1_21; 
    Xor1_6  <= swap2_6  xor add1_22; 
    Xor1_7  <= swap2_7  xor add1_23; 
    Xor1_8  <= swap2_8  xor add1_24; 
    Xor1_9  <= swap2_9  xor add1_25; 
    Xor1_10 <= swap2_10 xor add1_26; 
    Xor1_11 <= swap2_11 xor add1_27; 
    Xor1_12 <= swap2_12 xor add1_28; 
    Xor1_13 <= swap2_13 xor add1_29; 
    Xor1_14 <= swap2_14 xor add1_30; 
    Xor1_15 <= swap2_15 xor add1_31; 

    swap3_16 <= add1_17;
    swap3_17 <= add1_16;
    swap3_18 <= add1_19;
    swap3_19 <= add1_18;
    swap3_20 <= add1_21;
    swap3_21 <= add1_20;
    swap3_22 <= add1_23;
    swap3_23 <= add1_22;
    swap3_24 <= add1_25;
    swap3_25 <= add1_24;
    swap3_26 <= add1_27;
    swap3_27 <= add1_26;
    swap3_28 <= add1_29;
    swap3_29 <= add1_28;
    swap3_30 <= add1_31;
    swap3_31 <= add1_30;

end rtl;
