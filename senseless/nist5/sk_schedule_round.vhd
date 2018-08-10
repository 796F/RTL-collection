--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sk_schedule_round is

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

end sk_schedule_round;

architecture rtl of sk_schedule_round is

begin  -- Rtl
    
    ks5 <= std_logic_vector(unsigned(k5) + unsigned(t0));
    ks6 <= std_logic_vector(unsigned(k6) + unsigned(t1));
    ks7 <= std_logic_vector(unsigned(k7) + unsigned(s));

end rtl;
