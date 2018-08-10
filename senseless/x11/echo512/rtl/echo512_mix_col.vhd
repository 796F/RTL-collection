--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity echo512_mix_col is
port (
  num                                   : in std_logic_vector(1 downto 0);
  x_in                                  : in std_logic_vector(511 downto 0);
  t_in                                  : in std_logic_vector(511 downto 0);
  x_out                                 : out std_logic_vector(511 downto 0)
);
end entity echo512_mix_col;

architecture echo512_mix_col_rtl of echo512_mix_col is
  
  alias slv is std_logic_vector;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype word8 is slv(7 downto 0);
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
  
  function lh_128(x: slv(127 downto 0)) return word64 is
  begin
    return x(63 downto 0);
  end lh_128;
  
  type word64_array8 is array(0 to 7) of word64;

  function mix_col(x: word64_array8; t: word64_array8; num: slv(1 downto 0)) return word64_array8 is
    variable x2                         : word64_array8;
    variable a                          : word64;
    variable b                          : word64;
    variable c                          : word64;
    variable d                          : word64;
    variable ab                         : word64;
    variable bc                         : word64;
    variable cd                         : word64;
    variable abx                        : word64;
    variable bcx                        : word64;
    variable cdx                        : word64;
  begin
    case num is
    when "00" =>
      a                                 := x(0);
      b                                 := x(2);
      c                                 := x(4);
      d                                 := x(6);
    when "01" =>
      a                                 := x(0);
      b                                 := x(2);
      c                                 := x(4);
      d                                 := t(4);
    when "10" =>
      a                                 := x(0);
      b                                 := x(2);
      c                                 := t(2);
      d                                 := t(6);
    when "11" =>
      a                                 := x(0);
      b                                 := t(0);
      c                                 := t(4);
      d                                 := t(2);
    when others =>
      a                                 := x(0);
      b                                 := x(2);
      c                                 := x(4);
      d                                 := x(6);
    end case;    
    ab                                  := a xor b;
    bc                                  := b xor c;
    cd                                  := c xor d;
    abx                                 := lh_128(slv(unsigned(rotr64(ab and X"8080808080808080",7)) * 27)) xor rotl64(ab and X"7F7F7F7F7F7F7F7F",1);
    bcx                                 := lh_128(slv(unsigned(rotr64(bc and X"8080808080808080",7)) * 27)) xor rotl64(bc and X"7F7F7F7F7F7F7F7F",1);
    cdx                                 := lh_128(slv(unsigned(rotr64(cd and X"8080808080808080",7)) * 27)) xor rotl64(cd and X"7F7F7F7F7F7F7F7F",1);
    x2(0)                               := abx xor bc xor d;
    x2(2)                               := bcx xor a xor cd;
    x2(4)                               := cdx xor ab xor d;
    x2(6)                               := abx xor bcx xor cdx xor ab xor c;
    case num is
    when "00" =>
      a                                 := x(1);
      b                                 := x(3);
      c                                 := x(5);
      d                                 := x(7);
    when "01" =>
      a                                 := x(1);
      b                                 := x(3);
      c                                 := x(5);
      d                                 := t(5);
    when "10" =>
      a                                 := x(1);
      b                                 := x(3);
      c                                 := t(3);
      d                                 := t(7);
    when "11" =>
      a                                 := x(1);
      b                                 := t(1);
      c                                 := t(5);
      d                                 := t(3);
    when others =>
      a                                 := x(1);
      b                                 := x(3);
      c                                 := x(5);
      d                                 := x(7);
    end case;
    ab                                  := a xor b;
    bc                                  := b xor c;
    cd                                  := c xor d;
    abx                                 := lh_128(slv(unsigned(rotr64(ab and X"8080808080808080",7)) * 27)) xor rotl64(ab and X"7F7F7F7F7F7F7F7F",1);
    bcx                                 := lh_128(slv(unsigned(rotr64(bc and X"8080808080808080",7)) * 27)) xor rotl64(bc and X"7F7F7F7F7F7F7F7F",1);
    cdx                                 := lh_128(slv(unsigned(rotr64(cd and X"8080808080808080",7)) * 27)) xor rotl64(cd and X"7F7F7F7F7F7F7F7F",1);
    x2(1)                               := abx xor bc xor d;
    x2(3)                               := bcx xor a xor cd;
    x2(5)                               := cdx xor ab xor d;
    x2(7)                               := abx xor bcx xor cdx xor ab xor c;
    return x2;
  end mix_col;
  
  signal x_in_array                     : word64_array8;
  signal t_in_array                     : word64_array8;
  signal x_out_array                    : word64_array8;
  
begin
  
  output_mapping : for i in 0 to 7 generate
    x_out((i+1)*64-1 downto i*64)       <= x_out_array(i);
  end generate output_mapping;
   
  input_mapping : for i in 0 to 7 generate
    x_in_array(i)                       <= x_in((i+1)*64-1 downto i*64);
    t_in_array(i)                       <= t_in((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  x_out_array                           <= mix_col(x_in_array, t_in_array, num);
  
end architecture echo512_mix_col_rtl;