--  
-- Copyright (c) 2018 Allmine Inc
--

  library IEEE;
    use IEEE.std_logic_1164.all;

library work;

package sk_globals is

-- constants
constant init_vect : std_logic_vector(255 downto 0) := X"388512680e660046" & 
                                                       X"4b72d5dec5a8ff01" &
                                                       X"281a9298ca5eb3a5" &
                                                       X"54ca5249f46070c4";

end package;