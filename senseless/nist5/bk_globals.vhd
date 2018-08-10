--  
-- Copyright (c) 2018 Allmine Inc
--

library IEEE;
    use IEEE.std_logic_1164.all;

library work;

package bk_globals is

-- constants
constant init_vect : std_logic_vector(511 downto 0) := X"6A09E667F3BCC908" & 
                                                       X"BB67AE8584CAA73B" &
                                                       X"3C6EF372FE94F82B" &
                                                       X"A54FF53A5F1D36F1" &
                                                       X"510E527FADE682D1" &
                                                       X"9B05688C2B3E6C1F" &
                                                       X"1F83D9ABFB41BD6B" &
                                                       X"5BE0CD19137E2179";

constant const_t : std_logic_vector(1023 downto 0) :=  X"243F6A8885A308D3" & X"13198A2E03707344" &
                                                       X"A4093822299F31D0" & X"082EFA98EC4E6C89" &
                                                       X"452821E638D01377" & X"BE5466CF34E90C6C" &
                                                       X"C0AC29B7C97C50DD" & X"3F84D5B5B5470917" &
                                                       X"9216D5D98979FB1B" & X"D1310BA698DFB5AC" &
                                                       X"2FFD72DBD01ADFB7" & X"B8E1AFED6A267E96" &
                                                       X"BA7C9045F12C7F99" & X"24A19947B3916CF7" &
                                                       X"0801F2E2858EFC16" & X"636920D871574E69"; 

constant const_r : std_logic_vector(1023 downto 0) :=  X"13198A2E03707344" & X"243F6A8885A308D3" &
                                                       X"082EFA98EC4E6C89" & X"A4093822299F31D0" &
                                                       X"BE5466CF34E90C6C" & X"452821E638D01377" &
                                                       X"3F84D5B5B5470917" & X"C0AC29B7C97C50DD" &
                                                       X"D1310BA698DFB5AC" & X"9216D5D98979FB1B" &
                                                       X"B8E1AFED6A267E96" & X"2FFD72DBD01ADFB7" &
                                                       X"24A19947B3916CF7" & X"BA7C9045F12C7F99" &
                                                       X"636920D871574E69" & X"0801F2E2858EFC16";

end package;
