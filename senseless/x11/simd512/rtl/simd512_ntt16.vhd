--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simd512_ntt16 is
port (
  clk                                   : in std_logic;
  start                                 : in std_logic;
  d_in                                  : in std_logic_vector(1023 downto 0);
  d_in_off                              : in std_logic_vector(1 downto 0);
  xb                                    : in std_logic_vector(5 downto 0);
  xs                                    : in std_logic_vector(5 downto 0);
  d_out                                 : out std_logic_vector(511 downto 0);
  d_out_new                             : out std_logic
);
end entity simd512_ntt16;

architecture simd512_ntt16_rtl of simd512_ntt16 is
  
  alias slv is std_logic_vector;
  
  component simd512_ntt8 is
  port (
    clk                                 : in std_logic;
    start                               : in std_logic;
    d_in                                : in std_logic_vector(1023 downto 0);
    xb                                  : in std_logic_vector(5 downto 0);
    xs                                  : in std_logic_vector(5 downto 0);
    d_out                               : out std_logic_vector(255 downto 0);
    d_out_new                           : out std_logic
  );
  end component simd512_ntt8;
  
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
  
  type word32_array16 is array(0 to 15) of word32;
  type word32_array8 is array(0 to 7) of word32;
  
  signal xb_plus_d_in_off               : word6;
  signal xb_plus_xs_plus_d_in_off       : word6;
  signal ntt8_xs                        : word6;
  signal ntt8_0_d_out                   : slv(255 downto 0);
  signal ntt8_1_d_out                   : slv(255 downto 0);
  signal ntt8_d_out_new                 : std_logic;
  signal y0                             : word32_array8;
  signal y1                             : word32_array8;
  
  signal q_done                         : std_logic;
  signal q_y2                           : word32_array16;
  
begin

  d_out_new                             <= q_done;
  
  output_mapping : for i in 0 to 15 generate
    d_out((i+1)*32-1 downto i*32)       <= q_y2(i);
  end generate output_mapping;
  
  array_mapping : for i in 0 to 7 generate
    y0(i)                               <= ntt8_0_d_out((i+1)*32-1 downto i*32);
    y1(i)                               <= ntt8_1_d_out((i+1)*32-1 downto i*32);
  end generate array_mapping;
  
  xb_plus_d_in_off                      <= slv(unsigned(xb) + unsigned(d_in_off));
  xb_plus_xs_plus_d_in_off              <= slv(unsigned(xb) + unsigned(xs) + unsigned(d_in_off));
  ntt8_xs                               <= shl6(xs,1);
  
  simd512_ntt8_0 : simd512_ntt8
  port map (
    clk                                 => clk,
    start                               => start,
    d_in                                => d_in,
    xb                                  => xb_plus_d_in_off,
    xs                                  => ntt8_xs,
    d_out                               => ntt8_0_d_out,
    d_out_new                           => ntt8_d_out_new
  );
  
  simd512_ntt8_1 : simd512_ntt8
  port map (
    clk                                 => clk,
    start                               => start,
    d_in                                => d_in,
    xb                                  => xb_plus_xs_plus_d_in_off,
    xs                                  => ntt8_xs,
    d_out                               => ntt8_1_d_out,
    d_out_new                           => open
  );
  
  registers : process(clk) is
  begin
    if rising_edge(clk) then
      q_done                            <= ntt8_d_out_new;
      if ntt8_d_out_new = '1' then
        for i in 0 to 7 loop
          q_y2(i)                       <= word32(signed(y0(i)) + signed(shl32(y1(i),i)));
          q_y2(8+i)                     <= word32(signed(y0(i)) - signed(shl32(y1(i),i)));
        end loop;
      end if;
    end if;
  end process registers;
  
end architecture simd512_ntt16_rtl;