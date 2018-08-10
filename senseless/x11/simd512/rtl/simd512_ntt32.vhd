--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simd512_ntt32 is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  d_in                                  : in std_logic_vector(1023 downto 0);
  d_in_off                              : in std_logic_vector(1 downto 0);
  xb                                    : in std_logic_vector(5 downto 0);
  nl_done                               : in std_logic;
  nl_start                              : out std_logic;
  nl_d_in                               : out std_logic_vector(1023 downto 0)
);
end entity simd512_ntt32;

architecture simd512_ntt32_rtl of simd512_ntt32 is
  
  alias slv is std_logic_vector;
  
  component simd512_ntt16 is
  port (
    clk                                 : in std_logic;
    start                               : in std_logic;
    d_in                                : in std_logic_vector(1023 downto 0);
    d_in_off                            : in std_logic_vector(1 downto 0);
    xb                                  : in std_logic_vector(5 downto 0);
    xs                                  : in std_logic_vector(5 downto 0);
    d_out                               : out std_logic_vector(511 downto 0);
    d_out_new                           : out std_logic
  );
  end component simd512_ntt16;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype word8 is slv(7 downto 0);
  subtype word6 is slv(5 downto 0);
  subtype natural_0_3 is natural range 0 to 3;

  constant zeros64 : word64 := (others => '0');
  constant zeros32 : word32 := (others => '0');
  constant zeros6 : word6 := (others => '0');
  
  function byte_sel(x: word32; n: natural_0_3) return unsigned is
  begin
    return unsigned(x((n+1)*8-1 downto n*8));
  end byte_sel;
  
  function endian_swap64(x: word64) return word64 is
  begin
    return word64(x(7 downto 0)   & x(15 downto 8)  & x(23 downto 16) & x(31 downto 24) &
                  x(39 downto 32) & x(47 downto 40) & x(55 downto 48) & x(63 downto 56));
  end endian_swap64;

  function endian_swap32(x: word32) return word32 is
  begin
    return word32(x(7 downto 0)   & x(15 downto 8)  & x(23 downto 16) & x(31 downto 24));
  end endian_swap32;
  
  function shr64(x: word64; n: natural) return word64 is
  begin
    return word64(zeros64(n-1 downto 0) & x(x'high downto n));
  end shr64;
  
  function shr32(x: word32; n: natural) return word32 is
  begin
    return word32(zeros32(n-1 downto 0) & x(x'high downto n));
  end shr32;
  
  function shl64(x: word64; n: natural) return word64 is
  begin
    return word64(x(x'high-n downto 0) & zeros64(x'high downto x'length-n));
  end shl64;

  function shl32(x: word32; n: natural) return word32 is
  begin
    return word32(x(x'high-n downto 0) & zeros32(x'high downto x'length-n));
  end shl32;
  
  function shl6(x: word6; n: natural) return word6 is
  begin
    return word6(x(x'high-n downto 0) & zeros6(x'high downto x'length-n));
  end shl6;
  
  function rotr64(x: word64; n: natural) return word64 is
  begin
    return word64(x(n-1 downto 0) & x(x'high downto n));
  end rotr64;
  
  function rotr32(x: word32; n: natural) return word32 is
  begin
    return word32(x(n-1 downto 0) & x(x'high downto n));
  end rotr32;
  
  function rotl64(x: word64; n: natural) return word64 is
  begin
    return word64(x(x'high-n downto 0) & x(x'high downto x'length-n));
  end rotl64;
  
  function rotl32(x: word32; n: natural) return word32 is
  begin
    return word32(x(x'high-n downto 0) & x(x'high downto x'length-n));
  end rotl32;
  
  signal xb_plus_xs                     : word6;
  signal ntt16_0_d_out                  : slv(511 downto 0);
  signal ntt16_1_d_out                  : slv(511 downto 0);
  
begin
  
  nl_d_in                               <= ntt16_1_d_out & ntt16_0_d_out;
  
  xb_plus_xs                            <= slv(unsigned(xb) + "001000");
  
  simd512_ntt16_0 : simd512_ntt16
  port map (
    clk                                 => clk,
    start                               => start,
    d_in                                => d_in,
    d_in_off                            => d_in_off,
    xb                                  => xb,
    xs                                  => "010000",
    d_out                               => ntt16_0_d_out,
    d_out_new                           => nl_start
  );
  
  simd512_ntt16_1 : simd512_ntt16
  port map (
    clk                                 => clk,
    start                               => start,
    d_in                                => d_in,
    d_in_off                            => d_in_off,
    xb                                  => xb_plus_xs,
    xs                                  => "010000",
    d_out                               => ntt16_1_d_out,
    d_out_new                           => open
  );
  
end architecture simd512_ntt32_rtl;