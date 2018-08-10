--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sk_mix is

port (  x0 : in  std_logic_vector(63 downto 0);
        x1 : in  std_logic_vector(63 downto 0);
        Rj : in  std_logic_vector(1 downto 0);
        Rd : in  std_logic_vector(2 downto 0);
        y0 : out std_logic_vector(63 downto 0);
        y1 : out std_logic_vector(63 downto 0)
     );

end sk_mix;

architecture rtl of sk_mix is

    ----------------------------------------------------------------------------
    -- Internal signal declarations
    ----------------------------------------------------------------------------

    signal rot_0  : std_logic_vector(63 downto 0);
    signal rot_1  : std_logic_vector(63 downto 0);
    signal rot_2  : std_logic_vector(63 downto 0);
    signal rot_3  : std_logic_vector(63 downto 0);
    signal rot    : std_logic_vector(63 downto 0);
    signal y0_int : std_logic_vector(63 downto 0);
    signal y1_int : std_logic_vector(63 downto 0);

begin  -- Rtl
    
    rot_0 <= x1(63-46 downto 0) & x1(63 downto 64-46) when Rd="000" else
             x1(63-33 downto 0) & x1(63 downto 64-33) when Rd="001" else
             x1(63-17 downto 0) & x1(63 downto 64-17) when Rd="010" else
             x1(63-44 downto 0) & x1(63 downto 64-44) when Rd="011" else
             x1(63-39 downto 0) & x1(63 downto 64-39) when Rd="100" else
             x1(63-13 downto 0) & x1(63 downto 64-13) when Rd="101" else
             x1(63-25 downto 0) & x1(63 downto 64-25) when Rd="110" else
             x1(63- 8 downto 0) & x1(63 downto 64- 8);
    rot_1 <= x1(63-36 downto 0) & x1(63 downto 64-36) when Rd="000" else
             x1(63-27 downto 0) & x1(63 downto 64-27) when Rd="001" else
             x1(63-49 downto 0) & x1(63 downto 64-49) when Rd="010" else
             x1(63- 9 downto 0) & x1(63 downto 64- 9) when Rd="011" else
             x1(63-30 downto 0) & x1(63 downto 64-30) when Rd="100" else
             x1(63-50 downto 0) & x1(63 downto 64-50) when Rd="101" else
             x1(63-29 downto 0) & x1(63 downto 64-29) when Rd="110" else
             x1(63-35 downto 0) & x1(63 downto 64-35);
    rot_2 <= x1(63-19 downto 0) & x1(63 downto 64-19) when Rd="000" else
             x1(63-14 downto 0) & x1(63 downto 64-14) when Rd="001" else
             x1(63-36 downto 0) & x1(63 downto 64-36) when Rd="010" else
             x1(63-54 downto 0) & x1(63 downto 64-54) when Rd="011" else
             x1(63-34 downto 0) & x1(63 downto 64-34) when Rd="100" else
             x1(63-10 downto 0) & x1(63 downto 64-10) when Rd="101" else
             x1(63-39 downto 0) & x1(63 downto 64-39) when Rd="110" else
             x1(63-56 downto 0) & x1(63 downto 64-56);
    rot_3 <= x1(63-37 downto 0) & x1(63 downto 64-37) when Rd="000" else
             x1(63-42 downto 0) & x1(63 downto 64-42) when Rd="001" else
             x1(63-39 downto 0) & x1(63 downto 64-39) when Rd="010" else
             x1(63-56 downto 0) & x1(63 downto 64-56) when Rd="011" else
             x1(63-24 downto 0) & x1(63 downto 64-24) when Rd="100" else
             x1(63-17 downto 0) & x1(63 downto 64-17) when Rd="101" else
             x1(63-43 downto 0) & x1(63 downto 64-43) when Rd="110" else
             x1(63-22 downto 0) & x1(63 downto 64-22);
                 
    rot <= rot_0 when Rj="00" else
           rot_1 when Rj="01" else
           rot_2 when Rj="10" else
           rot_3;
               
    y0_int <= std_logic_vector(unsigned(x0) + unsigned(x1));
    y1_int <= y0_int xor rot;

    y0 <= y0_int;
    y1 <= y1_int;

end rtl;
