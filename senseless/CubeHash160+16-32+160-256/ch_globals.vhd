--  
-- Copyright (c) 2018 Allmine Inc
--

  library IEEE;
    use IEEE.std_logic_1164.all;

library work;

package ch_globals is

-- constants
constant init_state : std_logic_vector(1023 downto 0) := X"ea2bd4b4ccd6f29f63117e7135481eae" & 
                                                         X"22512d5be5d94e637e624131f4cc12be" &
                                                         X"c2d0b69642af2070d0720c353361da8c" &
                                                         X"28cceca48ef8ad834680ac0040e5fbab" &
                                                         X"d89041c36107fbd56c859d41f0b26679" &
                                                         X"093925495fa2560365c892fd93cb6285" &
                                                         X"2af2b5ae9e4b4e60774abfdd85254725" &
                                                         X"15815aeb4ab6aad69cdaf8afd6032c0a";

end package;