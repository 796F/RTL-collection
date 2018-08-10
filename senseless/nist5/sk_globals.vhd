--  
-- Copyright (c) 2018 Allmine Inc
--

  library IEEE;
    use IEEE.std_logic_1164.all;

library work;

package sk_globals is

-- constants

constant init_vect : std_logic_vector(511 downto 0) := x"4903adff749c51ce" & 
                                                       x"0d95de399746df03" &
                                                       x"8fd1934127c79bce" &
                                                       x"9a255629ff352cb1" &
                                                       x"5db62599df6ca7b0" &
                                                       x"eabe394ca9d5c3f4" &
                                                       x"991112c71a75b523" &
                                                       x"ae18a40b660fcc33";

end package;