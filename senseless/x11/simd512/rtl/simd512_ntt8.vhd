--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simd512_ntt8 is
port (
  clk                                   : in std_logic;
  start                                 : in std_logic;
  d_in                                  : in std_logic_vector(1023 downto 0);
  xb                                    : in std_logic_vector(5 downto 0);
  xs                                    : in std_logic_vector(5 downto 0);
  d_out                                 : out std_logic_vector(255 downto 0);
  d_out_new                             : out std_logic
);
end entity simd512_ntt8;

architecture simd512_ntt8_rtl of simd512_ntt8 is
  
  alias slv is std_logic_vector;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype word8 is slv(7 downto 0);
  subtype sword32 is signed(31 downto 0);
  subtype natural_0_3 is natural range 0 to 3;

  constant zeros64 : word64 := (others => '0');
  constant zeros32 : word32 := (others => '0');
  
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
  
  function resize_8_32(x: word8) return word32 is
  begin
    return word32(resize(unsigned(x),32));
  end function resize_8_32;
  
  function reds1(x: word32) return word32 is
    variable x2                         : word32;
    variable x3                         : word32;
  begin
    x2                                  := shr32(x,8);
    x3                                  := word32(resize(signed(unsigned(x(7 downto 0)) - unsigned(x2(23 downto 0))),32));
    return x3;
  end function reds1;
  
  type word32_array8 is array(0 to 7) of word32;
  type word32_array4 is array(0 to 3) of word32;
  type word8_array128 is array(0 to 127) of word8;
  type sword32_array4 is array(0 to 3) of sword32;
  
  signal d_in_array                     : word8_array128;
  signal x                              : word32_array4;
  signal a                              : sword32_array4;
  signal b                              : sword32_array4;
  signal d_out_array                    : word32_array8;
  
  signal q_a                            : sword32_array4;
  signal q_b                            : sword32_array4;
  signal q_done                         : slv(1 downto 0);
  
begin

  d_out_new                             <= q_done(1);
  
  output_mapping : for i in 0 to 7 generate
    d_out((i+1)*32-1 downto i*32)       <= d_out_array(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 127 generate
    d_in_array(i)                       <= d_in((i+1)*8-1 downto i*8);
  end generate input_mapping;
  
  x(0)                                  <= resize_8_32(d_in_array(to_integer(unsigned(xb))));
  x(1)                                  <= resize_8_32(d_in_array(to_integer(unsigned(xb) + unsigned(xs))));
  x(2)                                  <= resize_8_32(d_in_array(to_integer(unsigned(xb) + (unsigned(xs) & "0"))));
  x(3)                                  <= resize_8_32(d_in_array(to_integer(unsigned(xb) + 3*unsigned(xs))));
  a(0)                                  <= signed(x(0)) + signed(x(2));
  a(1)                                  <= signed(x(0)) + signed(shl32(x(2),4));
  a(2)                                  <= signed(x(0)) - signed(x(2));
  a(3)                                  <= signed(x(0)) - signed(shl32(x(2),4));
  b(0)                                  <= signed(x(1)) + signed(x(3));
  b(1)                                  <= signed(reds1(word32(signed(shl32(x(1),2)) + signed(shl32(x(3),6)))));
  b(2)                                  <= signed(shl32(x(1),4)) - signed(shl32(x(3),4));
  b(3)                                  <= signed(reds1(word32(signed(shl32(x(1),6)) + signed(shl32(x(3),2)))));
  d_out_array_gen: for i in 0 to 3 generate
    d_out_array(i)                      <= word32(q_a(i) + q_b(i));
    d_out_array(4+i)                    <= word32(q_a(i) - q_b(i));
  end generate d_out_array_gen;
  
  registers : process(clk) is
  begin
    if rising_edge(clk) then
      q_a                               <= a;
      q_b                               <= b;
      q_done                            <= q_done(0) & start;
    end if;
  end process registers;
  
end architecture simd512_ntt8_rtl;