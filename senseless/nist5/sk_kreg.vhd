--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity sk_kreg is

port (  clk     : in  std_logic;
        k0_in   : in  std_logic_vector(63 downto 0);
        k1_in   : in  std_logic_vector(63 downto 0);
        k2_in   : in  std_logic_vector(63 downto 0);
        k3_in   : in  std_logic_vector(63 downto 0);
        k4_in   : in  std_logic_vector(63 downto 0);
        k5_in   : in  std_logic_vector(63 downto 0);
        k6_in   : in  std_logic_vector(63 downto 0);
        k7_in   : in  std_logic_vector(63 downto 0);
        k8_in   : in  std_logic_vector(63 downto 0);
        t0_in   : in  std_logic_vector(63 downto 0);
        t1_in   : in  std_logic_vector(63 downto 0);
        t2_in   : in  std_logic_vector(63 downto 0);
        x5_in   : in  std_logic_vector(63 downto 0);
        x6_in   : in  std_logic_vector(63 downto 0);
        x7_in   : in  std_logic_vector(63 downto 0);
        k0_out  : out std_logic_vector(63 downto 0);
        k1_out  : out std_logic_vector(63 downto 0);
        k2_out  : out std_logic_vector(63 downto 0);
        k3_out  : out std_logic_vector(63 downto 0);
        k4_out  : out std_logic_vector(63 downto 0);
        k5_out  : out std_logic_vector(63 downto 0);
        k6_out  : out std_logic_vector(63 downto 0);
        k7_out  : out std_logic_vector(63 downto 0);
        k8_out  : out std_logic_vector(63 downto 0);
        t0_out  : out std_logic_vector(63 downto 0);
        t1_out  : out std_logic_vector(63 downto 0);
        t2_out  : out std_logic_vector(63 downto 0);
        x5_out  : out std_logic_vector(63 downto 0);
        x6_out  : out std_logic_vector(63 downto 0);
        x7_out  : out std_logic_vector(63 downto 0)
     );

end sk_kreg;

architecture rtl of sk_kreg is

begin  -- Rtl

    begReg: process( clk )
    begin
        if rising_edge( clk ) then
            k0_out <= k0_in;
            k1_out <= k1_in;
            k2_out <= k2_in;
            k3_out <= k3_in;
            k4_out <= k4_in;
            k5_out <= k5_in;
            k6_out <= k6_in;
            k7_out <= k7_in;
            k8_out <= k8_in;
            t0_out <= t0_in;
            t1_out <= t1_in;
            t2_out <= t2_in;
            x5_out <= x5_in;
            x6_out <= x6_in;
            x7_out <= x7_in;
        end if;
    end process;

end rtl;
