--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--
-- DIV = 1 => clk_en high every clock
-- DIV = 2 => clk_en high every second clock
-- DIV = N => clk_en high every Nth clock

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_en_gen is
generic (
  BLAKE512_DIV                    : natural;
  BMW512_DIV                      : natural;
  CUBEHASH512_DIV                 : natural;
  GROESTL512_DIV                  : natural;
  JH512_DIV                       : natural;
  KECCAK512_DIV                   : natural;
  LUFFA512_DIV                    : natural;
  SHAVITE512_DIV                  : natural;
  SKEIN512_DIV                    : natural;
  SIMD512_DIV                     : natural;
  ECHO512_DIV                     : natural;
  WORDLENGTH                      : natural
);
port (
  clk                             : in std_logic;
  reset                           : in std_logic;
  clk_en                          : out std_logic_vector(10 downto 0)
);
end entity clk_en_gen;

architecture clk_en_gen_rtl of clk_en_gen is
  
  alias slv is std_logic_vector;
  
  signal q_blake512_count         : unsigned(WORDLENGTH-1 downto 0);
  signal q_bmw512_count           : unsigned(WORDLENGTH-1 downto 0);
  signal q_cubehash512_count      : unsigned(WORDLENGTH-1 downto 0);
  signal q_groestl512_count       : unsigned(WORDLENGTH-1 downto 0);
  signal q_jh512_count            : unsigned(WORDLENGTH-1 downto 0);  
  signal q_keccak512_count        : unsigned(WORDLENGTH-1 downto 0);
  signal q_luffa512_count         : unsigned(WORDLENGTH-1 downto 0);
  signal q_shavite512_count       : unsigned(WORDLENGTH-1 downto 0);
  signal q_skein512_count         : unsigned(WORDLENGTH-1 downto 0);
  signal q_simd512_count          : unsigned(WORDLENGTH-1 downto 0);
  signal q_echo512_count          : unsigned(WORDLENGTH-1 downto 0);

begin

  clk_en(0)                       <= q_blake512_count(q_blake512_count'high);
  clk_en(1)                       <= q_bmw512_count(q_bmw512_count'high);
  clk_en(2)                       <= q_cubehash512_count(q_cubehash512_count'high);
  clk_en(3)                       <= q_groestl512_count(q_groestl512_count'high);
  clk_en(4)                       <= q_jh512_count(q_jh512_count'high);
  clk_en(5)                       <= q_keccak512_count(q_keccak512_count'high);
  clk_en(6)                       <= q_luffa512_count(q_luffa512_count'high);
  clk_en(7)                       <= q_shavite512_count(q_shavite512_count'high);
  clk_en(8)                       <= q_skein512_count(q_skein512_count'high);
  clk_en(9)                       <= q_simd512_count(q_simd512_count'high);
  clk_en(10)                      <= q_echo512_count(q_echo512_count'high);
  
  registers : process (clk, reset)
  begin
    if reset = '1' then
      q_blake512_count            <= to_unsigned(BLAKE512_DIV + 30 mod 2**WORDLENGTH,q_blake512_count'length);
      q_bmw512_count              <= to_unsigned(BMW512_DIV + 30 mod 2**WORDLENGTH,q_bmw512_count'length);
      q_cubehash512_count         <= to_unsigned(CUBEHASH512_DIV + 30 mod 2**WORDLENGTH,q_cubehash512_count'length);
      q_groestl512_count          <= to_unsigned(GROESTL512_DIV + 30 mod 2**WORDLENGTH,q_groestl512_count'length);
      q_jh512_count               <= to_unsigned(JH512_DIV + 30 mod 2**WORDLENGTH,q_jh512_count'length);
      q_keccak512_count           <= to_unsigned(KECCAK512_DIV + 30 mod 2**WORDLENGTH,q_keccak512_count'length);
      q_luffa512_count            <= to_unsigned(LUFFA512_DIV + 30 mod 2**WORDLENGTH,q_luffa512_count'length);
      q_shavite512_count          <= to_unsigned(SHAVITE512_DIV + 30 mod 2**WORDLENGTH,q_shavite512_count'length);
      q_skein512_count            <= to_unsigned(SKEIN512_DIV + 30 mod 2**WORDLENGTH,q_skein512_count'length);
      q_simd512_count             <= to_unsigned(SIMD512_DIV + 30 mod 2**WORDLENGTH,q_simd512_count'length);
      q_echo512_count             <= to_unsigned(ECHO512_DIV + 30 mod 2**WORDLENGTH,q_echo512_count'length);
    elsif rising_edge(clk) then
      if q_blake512_count(q_blake512_count'high) = '1' then
        q_blake512_count          <= to_unsigned(BLAKE512_DIV + 30 mod 2**WORDLENGTH,q_blake512_count'length);
      else
        q_blake512_count          <= q_blake512_count - 1;
      end if;
      if q_bmw512_count(q_bmw512_count'high) = '1' then
        q_bmw512_count            <= to_unsigned(BMW512_DIV + 30 mod 2**WORDLENGTH,q_bmw512_count'length);
      else
        q_bmw512_count            <= q_bmw512_count - 1;
      end if;
      if q_cubehash512_count(q_cubehash512_count'high) = '1' then
        q_cubehash512_count       <= to_unsigned(CUBEHASH512_DIV + 30 mod 2**WORDLENGTH,q_cubehash512_count'length);
      else
        q_cubehash512_count       <= q_cubehash512_count - 1;
      end if;
      if q_groestl512_count(q_groestl512_count'high) = '1' then
        q_groestl512_count        <= to_unsigned(GROESTL512_DIV + 30 mod 2**WORDLENGTH,q_groestl512_count'length);
      else
        q_groestl512_count        <= q_groestl512_count - 1;
      end if;
      if q_jh512_count(q_jh512_count'high) = '1' then
        q_jh512_count             <= to_unsigned(JH512_DIV + 30 mod 2**WORDLENGTH,q_jh512_count'length);
      else
        q_jh512_count             <= q_jh512_count - 1;
      end if;
      if q_keccak512_count(q_keccak512_count'high) = '1' then
        q_keccak512_count         <= to_unsigned(KECCAK512_DIV + 30 mod 2**WORDLENGTH,q_keccak512_count'length);
      else
        q_keccak512_count         <= q_keccak512_count - 1;
      end if;
      if q_luffa512_count(q_luffa512_count'high) = '1' then
        q_luffa512_count          <= to_unsigned(LUFFA512_DIV + 30 mod 2**WORDLENGTH,q_luffa512_count'length);
      else
        q_luffa512_count          <= q_luffa512_count - 1;
      end if;
      if q_shavite512_count(q_shavite512_count'high) = '1' then
        q_shavite512_count        <= to_unsigned(SHAVITE512_DIV + 30 mod 2**WORDLENGTH,q_shavite512_count'length);
      else
        q_shavite512_count        <= q_shavite512_count - 1;
      end if;
      if q_skein512_count(q_skein512_count'high) = '1' then
        q_skein512_count          <= to_unsigned(SKEIN512_DIV + 30 mod 2**WORDLENGTH,q_skein512_count'length);
      else
        q_skein512_count          <= q_skein512_count - 1;
      end if;
      if q_simd512_count(q_simd512_count'high) = '1' then
        q_simd512_count           <= to_unsigned(SIMD512_DIV + 30 mod 2**WORDLENGTH,q_simd512_count'length);
      else
        q_simd512_count           <= q_simd512_count - 1;
      end if;
      if q_echo512_count(q_echo512_count'high) = '1' then
        q_echo512_count           <= to_unsigned(ECHO512_DIV + 30 mod 2**WORDLENGTH,q_echo512_count'length);
      else
        q_echo512_count           <= q_echo512_count - 1;
      end if;
    end if;
  end process registers;
  
end architecture clk_en_gen_rtl;
  