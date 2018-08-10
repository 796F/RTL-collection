--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cubehash512_round is
port (
  clk                                   : in std_logic;
  start                                 : in std_logic;
  even_flag                             : in std_logic;
  xor_1_flag                            : in std_logic;
  x_in                                  : in std_logic_vector(1023 downto 0);
  x_out                                 : out std_logic_vector(1023 downto 0);
  x_new                                 : out std_logic
);
end entity cubehash512_round;

architecture cubehash512_round_rtl of cubehash512_round is
  
  alias slv is std_logic_vector;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);

  constant zeros64 : word64 := (others => '0');
  constant zeros32 : word32 := (others => '0');
    
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
  
  type word32_array32 is array(0 to 31) of word32;
  
  signal x_in_array                     : word32_array32;
  signal x                              : word32_array32;
  
  signal q_x                            : word32_array32;
  signal q_count                        : unsigned(2 downto 0);
  signal q_done                         : slv(1 downto 0);
  
begin

  x_new                                 <= q_done(1);
  
  output_mapping : for i in 0 to 31 generate
    x_out((i+1)*32-1 downto i*32)       <= q_x(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 31 generate
    x_in_array(i)                       <= x_in((i+1)*32-1 downto i*32);
  end generate input_mapping;
  
  round_proc : process(q_x, q_count, even_flag, xor_1_flag) is
  begin
    x                                   <= q_x;
    case q_count is
    when "000" =>
      if even_flag = '1' then
        for i in 0 to 15 loop
          x(16+i)                       <= slv(unsigned(q_x(i)) + unsigned(q_x(16+i)));
          x(i)                          <= rotl32(q_x(i),7);
        end loop;
      else
        for i in 0 to 15 loop
          x(16 + (3-i) mod 4 + 4*(i/4)) <= slv(unsigned(q_x(16 + (3-i) mod 4 + 4*(i/4))) + unsigned(q_x(i mod 4 + 4*((15-i)/4))));
          x(i mod 4 + 4*((15-i)/4))     <= rotl32(q_x(i mod 4 + 4*((15-i)/4)),7);
        end loop;
      end if;
    when "001" =>
      if even_flag = '1' then
        for i in 0 to 15 loop
          x((8+i) mod 16)               <= q_x((8+i) mod 16) xor q_x(16+i);
        end loop;
      else
        for i in 0 to 15 loop
          x((i+4) mod 8 + 8*(i/8))      <= q_x((i+4) mod 8 + 8*(i/8)) xor q_x(16 + (3-i) mod 4 + 4*(i/4));
        end loop;
      end if;
    when "010" =>
      if even_flag = '1' then
        for i in 0 to 15 loop
          x(16+4*(i/4)+((i+2) mod 4))   <= slv(unsigned(q_x(16+4*(i/4)+((i+2) mod 4))) + unsigned(q_x((8+i) mod 16)));
          x((8+i) mod 16)               <= rotl32(q_x((8+i) mod 16),11);
        end loop;
      else
        for i in 0 to 15 loop
          x(16 + (i+1) mod 2 + 2*(i/2)) <= slv(unsigned(q_x(16 + (i+1) mod 2 + 2*(i/2))) + unsigned(q_x((i+4) mod 8 + 8*(i/8))));
          x((i+4) mod 8 + 8*(i/8))      <= rotl32(q_x((i+4) mod 8 + 8*(i/8)),11);
        end loop;
      end if;
    when "011" =>
      if even_flag = '1' then
        for i in 0 to 15 loop
          x((4*((15-i)/4)) + i mod 4)   <= q_x((4*((15-i)/4)) + i mod 4) xor q_x(16+4*(i/4)+((i+2) mod 4));
        end loop;
      else
        for i in 0 to 15 loop
          x(i)                          <= q_x(i) xor q_x(16 + (i+1) mod 2 + 2*(i/2));
        end loop;
        if xor_1_flag = '1' then
          x(31)(0)                      <= q_x(31)(0) xor '1';
        end if;
      end if;
    when others =>
      null;
    end case;
  end process round_proc;
  
  registers : process(clk) is
  begin
    if rising_edge(clk) then
      if start = '1' then
        q_x                             <= x_in_array;
      else
        q_x                             <= x;
      end if;
      if start = '1' then
        q_count                         <= (others => '0');
      elsif q_count(q_count'high) /= '1' then
        q_count                         <= q_count + 1;
      end if;
      if q_count = 3 then
        q_done                          <= "01";
      else
        q_done                          <= q_done(0) & '0';
      end if;
    end if;
  end process registers;
  
end architecture cubehash512_round_rtl;