--  
-- Copyright (c) 2018 Allmine Inc
--

library STD;
 use STD.textio.all;


  library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_misc.all;
    use IEEE.std_logic_arith.all;
    

library work;


package keccak_globals is

--types
type k_plane_type is array (0 to 4) of std_logic_vector(63 downto 0);
type k_state_type is array (0 to 4) of k_plane_type;


-- constants for input

-- keccak 512 with 1024 capacity
constant size_input : integer := 512;
constant size_nonce : integer := 0;
constant size_input_rate : integer := 576;
constant size_output : integer := 512;

end package;