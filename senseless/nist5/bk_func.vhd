--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bk_func is

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
end bk_func;

    
architecture rtl of bk_func is
    
    ----------------------------------------------------------------------------
    -- Internal signal declarations
    ----------------------------------------------------------------------------

    signal ab     : std_logic_vector(63 downto 0);
    signal abm    : std_logic_vector(63 downto 0);
    signal rot25m : std_logic_vector(63 downto 0);
    signal c_rot  : std_logic_vector(63 downto 0);
    signal rot25i : std_logic_vector(63 downto 0);
    signal rot25  : std_logic_vector(63 downto 0);
    signal rot32i : std_logic_vector(63 downto 0);
    signal rot32  : std_logic_vector(63 downto 0);
    signal rot16i : std_logic_vector(63 downto 0);
    signal rot16  : std_logic_vector(63 downto 0);
    signal rot11i : std_logic_vector(63 downto 0);
    signal rot11  : std_logic_vector(63 downto 0);
    signal a_int  : std_logic_vector(63 downto 0);
    signal b_int  : std_logic_vector(63 downto 0);
    signal c_int  : std_logic_vector(63 downto 0);
    signal d_int  : std_logic_vector(63 downto 0);

begin  -- Rtl
    
    ab <= std_logic_vector(unsigned(a_in) + unsigned(b_in));
    abm <= std_logic_vector(unsigned(ab) + unsigned(msg_i));
    c_rot <= std_logic_vector(unsigned(c_in) + unsigned(rot32));

    rot25i <= c_rot xor b_in;
    rot25 <= rot25i(24 downto 0) & rot25i(63 downto 25);

    rot32i <= abm xor d_in;
    rot32 <= rot32i(31 downto 0) & rot32i(63 downto 32);

    rot16i <= a_int xor rot32;
    rot16 <= rot16i(15 downto 0) & rot16i(63 downto 16);

    rot11i <= c_int xor rot25;
    rot11 <= rot11i(10 downto 0) & rot11i(63 downto 11);

    rot25m <= std_logic_vector(unsigned(rot25) + unsigned(msg_ip));
    a_int <= std_logic_vector(unsigned(rot25m) + unsigned(abm));
    b_int <= rot11;
    c_int <= std_logic_vector(unsigned(d_int) + unsigned(c_rot));
    d_int <= rot16;

    a_out <= a_int;
    b_out <= b_int;
    c_out <= c_int;
    d_out <= d_int;

end rtl;
