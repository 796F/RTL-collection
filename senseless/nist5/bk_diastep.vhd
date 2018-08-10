--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library work;
    use work.bk_globals.all;

entity bk_diastep is

port (  state : in  std_logic_vector(1023 downto 0);
        msg   : in  std_logic_vector(511 downto 0);
        chain : out std_logic_vector(1023 downto 0)
     );

end bk_diastep;

architecture rtl of bk_diastep is

    ----------------------------------------------------------------------------
    -- Internal signal declarations
    ----------------------------------------------------------------------------
    component bk_func
    port (  a_in :   in  std_logic_vector(63 downto 0);
            b_in :   in  std_logic_vector(63 downto 0);
            c_in :   in  std_logic_vector(63 downto 0);
            d_in :   in  std_logic_vector(63 downto 0);
            msg_i :  in  std_logic_vector(63 downto 0);
            msg_ip : in  std_logic_vector(63 downto 0);
            a_out :  out std_logic_vector(63 downto 0);
            b_out :  out std_logic_vector(63 downto 0);
            c_out :  out std_logic_vector(63 downto 0);
            d_out :  out std_logic_vector(63 downto 0)
         );
    end component;
    
    signal state0  : std_logic_vector(63 downto 0);
    signal state1  : std_logic_vector(63 downto 0);
    signal state2  : std_logic_vector(63 downto 0);
    signal state3  : std_logic_vector(63 downto 0);
    signal state4  : std_logic_vector(63 downto 0);
    signal state5  : std_logic_vector(63 downto 0);
    signal state6  : std_logic_vector(63 downto 0);
    signal state7  : std_logic_vector(63 downto 0);
    signal state8  : std_logic_vector(63 downto 0);
    signal state9  : std_logic_vector(63 downto 0);
    signal state10 : std_logic_vector(63 downto 0);
    signal state11 : std_logic_vector(63 downto 0);
    signal state12 : std_logic_vector(63 downto 0);
    signal state13 : std_logic_vector(63 downto 0);
    signal state14 : std_logic_vector(63 downto 0);
    signal state15 : std_logic_vector(63 downto 0);

    signal msg8  : std_logic_vector(63 downto 0);
    signal msg9  : std_logic_vector(63 downto 0);
    signal msg10 : std_logic_vector(63 downto 0);
    signal msg11 : std_logic_vector(63 downto 0);
    signal msg12 : std_logic_vector(63 downto 0);
    signal msg13 : std_logic_vector(63 downto 0);
    signal msg14 : std_logic_vector(63 downto 0);
    signal msg15 : std_logic_vector(63 downto 0);

    signal gf0_i    : std_logic_vector(63 downto 0);
    signal gf1_i    : std_logic_vector(63 downto 0);
    signal gf2_i    : std_logic_vector(63 downto 0);
    signal gf3_i    : std_logic_vector(63 downto 0);
    signal gf4_i    : std_logic_vector(63 downto 0);
    signal gf5_i    : std_logic_vector(63 downto 0);
    signal gf6_i    : std_logic_vector(63 downto 0);
    signal gf7_i    : std_logic_vector(63 downto 0);
    signal gf8_i    : std_logic_vector(63 downto 0);
    signal gf9_i    : std_logic_vector(63 downto 0);
    signal gf10_i   : std_logic_vector(63 downto 0);
    signal gf11_i   : std_logic_vector(63 downto 0);
    signal gf12_i   : std_logic_vector(63 downto 0);
    signal gf13_i   : std_logic_vector(63 downto 0);
    signal gf14_i   : std_logic_vector(63 downto 0);
    signal gf15_i   : std_logic_vector(63 downto 0);
    signal gf0_o    : std_logic_vector(63 downto 0);
    signal gf1_o    : std_logic_vector(63 downto 0);
    signal gf2_o    : std_logic_vector(63 downto 0);
    signal gf3_o    : std_logic_vector(63 downto 0);
    signal gf4_o    : std_logic_vector(63 downto 0);
    signal gf5_o    : std_logic_vector(63 downto 0);
    signal gf6_o    : std_logic_vector(63 downto 0);
    signal gf7_o    : std_logic_vector(63 downto 0);
    signal gf8_o    : std_logic_vector(63 downto 0);
    signal gf9_o    : std_logic_vector(63 downto 0);
    signal gf10_o   : std_logic_vector(63 downto 0);
    signal gf11_o   : std_logic_vector(63 downto 0);
    signal gf12_o   : std_logic_vector(63 downto 0);
    signal gf13_o   : std_logic_vector(63 downto 0);
    signal gf14_o   : std_logic_vector(63 downto 0);
    signal gf15_o   : std_logic_vector(63 downto 0);
    signal msg04_i  : std_logic_vector(63 downto 0);
    signal msg04_ip : std_logic_vector(63 downto 0);
    signal msg15_i  : std_logic_vector(63 downto 0);
    signal msg15_ip : std_logic_vector(63 downto 0);
    signal msg26_i  : std_logic_vector(63 downto 0);
    signal msg26_ip : std_logic_vector(63 downto 0);
    signal msg37_i  : std_logic_vector(63 downto 0);
    signal msg37_ip : std_logic_vector(63 downto 0);
    signal chain0   : std_logic_vector(63 downto 0);
    signal chain1   : std_logic_vector(63 downto 0);
    signal chain2   : std_logic_vector(63 downto 0);
    signal chain3   : std_logic_vector(63 downto 0);
    signal chain4   : std_logic_vector(63 downto 0);
    signal chain5   : std_logic_vector(63 downto 0);
    signal chain6   : std_logic_vector(63 downto 0);
    signal chain7   : std_logic_vector(63 downto 0);
    signal chain8   : std_logic_vector(63 downto 0);
    signal chain9   : std_logic_vector(63 downto 0);
    signal chain10  : std_logic_vector(63 downto 0);
    signal chain11  : std_logic_vector(63 downto 0);
    signal chain12  : std_logic_vector(63 downto 0);
    signal chain13  : std_logic_vector(63 downto 0);
    signal chain14  : std_logic_vector(63 downto 0);
    signal chain15  : std_logic_vector(63 downto 0);
    
begin  -- Rtl
    
    state0  <= state(1023 downto 960);
    state1  <= state( 959 downto 896);
    state2  <= state( 895 downto 832);
    state3  <= state( 831 downto 768);
    state4  <= state( 767 downto 704);
    state5  <= state( 703 downto 640);
    state6  <= state( 639 downto 576);
    state7  <= state( 575 downto 512);
    state8  <= state( 511 downto 448);
    state9  <= state( 447 downto 384);
    state10 <= state( 383 downto 320);
    state11 <= state( 319 downto 256);
    state12 <= state( 255 downto 192);
    state13 <= state( 191 downto 128);
    state14 <= state( 127 downto  64);
    state15 <= state(  63 downto   0);
    
    msg8  <= msg(511 downto 448);
    msg9  <= msg(447 downto 384);
    msg10 <= msg(383 downto 320);
    msg11 <= msg(319 downto 256);
    msg12 <= msg(255 downto 192);
    msg13 <= msg(191 downto 128);
    msg14 <= msg(127 downto  64);
    msg15 <= msg( 63 downto   0);
    
    chain <= chain0 & chain1 & chain2 & chain3 & chain4 & chain5 & chain6 & chain7 & chain8 & chain9 & chain10 & chain11 & chain12 & chain13 & chain14 & chain15;
    
    gf0_i  <= state0;
    gf1_i  <= state5;
    gf2_i  <= state10;
    gf3_i  <= state15;

    gf4_i  <= state1;
    gf5_i  <= state6;
    gf6_i  <= state11;
    gf7_i  <= state12;

    gf8_i  <= state2;
    gf9_i  <= state7;
    gf10_i <= state8;
    gf11_i <= state13;

    gf12_i <= state3;
    gf13_i <= state4;
    gf14_i <= state9;
    gf15_i <= state14;

    msg04_i  <= msg8;
    msg04_ip <= msg9;

    msg15_i  <= msg10;
    msg15_ip <= msg11;

    msg26_i  <= msg12;
    msg26_ip <= msg13;

    msg37_i  <= msg14;
    msg37_ip <= msg15;

    chain0  <= gf0_o;
    chain1  <= gf4_o;
    chain2  <= gf8_o;
    chain3  <= gf12_o;

    chain4  <= gf13_o;
    chain5  <= gf1_o;
    chain6  <= gf5_o;
    chain7  <= gf9_o;

    chain8  <= gf10_o;
    chain9  <= gf14_o;
    chain10 <= gf2_o;
    chain11 <= gf6_o;

    chain12 <= gf7_o;
    chain13 <= gf11_o;
    chain14 <= gf15_o;
    chain15 <= gf3_o;
    
    g04_function : bk_func
        port map(   gf0_i,
                    gf1_i,
                    gf2_i,
                    gf3_i,
                    msg04_i,
                    msg04_ip,
                    gf0_o,
                    gf1_o,
                    gf2_o,
                    gf3_o
                );
    g15_function : bk_func
        port map(   gf4_i,
                    gf5_i,
                    gf6_i,
                    gf7_i,
                    msg15_i,
                    msg15_ip,
                    gf4_o,
                    gf5_o,
                    gf6_o,
                    gf7_o
                );
    g26_function : bk_func
        port map(   gf8_i,
                    gf9_i,
                    gf10_i,
                    gf11_i,
                    msg26_i,
                    msg26_ip,
                    gf8_o,
                    gf9_o,
                    gf10_o,
                    gf11_o
                );
    g37_function : bk_func
        port map(   gf12_i,
                    gf13_i,
                    gf14_i,
                    gf15_i,
                    msg37_i,
                    msg37_ip,
                    gf12_o,
                    gf13_o,
                    gf14_o,
                    gf15_o
                );
        

end rtl;
