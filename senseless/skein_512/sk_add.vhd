--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sk_add is

port (  key_in : in  std_logic_vector(511 downto 0);
        st_in  : in  std_logic_vector(511 downto 0);
        st_out : out std_logic_vector(511 downto 0)
     );

end sk_add;

architecture rtl of sk_add is

begin  -- Rtl
    
    st_out(511 downto 448) <= std_logic_vector(unsigned(st_in(511 downto 448)) + unsigned(key_in(511 downto 448)));
    st_out(447 downto 384) <= std_logic_vector(unsigned(st_in(447 downto 384)) + unsigned(key_in(447 downto 384)));
    st_out(383 downto 320) <= std_logic_vector(unsigned(st_in(383 downto 320)) + unsigned(key_in(383 downto 320)));
    st_out(319 downto 256) <= std_logic_vector(unsigned(st_in(319 downto 256)) + unsigned(key_in(319 downto 256)));
    st_out(255 downto 192) <= std_logic_vector(unsigned(st_in(255 downto 192)) + unsigned(key_in(255 downto 192)));
    st_out(191 downto 128) <= std_logic_vector(unsigned(st_in(191 downto 128)) + unsigned(key_in(191 downto 128)));
    st_out(127 downto  64) <= std_logic_vector(unsigned(st_in(127 downto  64)) + unsigned(key_in(127 downto  64)));
    st_out( 63 downto   0) <= std_logic_vector(unsigned(st_in( 63 downto   0)) + unsigned(key_in( 63 downto   0)));

end rtl;
