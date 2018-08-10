--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity luffa512_sc_mw_ce is
port (
  clk                                   : in std_logic;
  clk_en                                : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  a                                     : in std_logic_vector(63 downto 0);
  b                                     : in std_logic_vector(63 downto 0);
  x_in                                  : in std_logic_vector(511 downto 0);
  x_out                                 : out std_logic_vector(511 downto 0);
  x_new                                 : out std_logic
);
end entity luffa512_sc_mw_ce;

architecture luffa512_sc_mw_ce_rtl of luffa512_sc_mw_ce is
  
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

  type word64_array8 is array(0 to 7) of word64;
  type word64_array4 is array(0 to 3) of word64;
  type word64_array2 is array(0 to 1) of word64;

  function mix_word64(x: word64_array2) return word64_array2 is
    variable x2                         : word64_array2;
  begin
    x2(0)                               := x(0);
    x2(1)                               := x(0) xor x(1);
    x2(0)(31 downto 0)                  := rotl32(x2(0)(31 downto 0),2) xor x2(1)(31 downto 0);
    x2(1)(31 downto 0)                  := rotl32(x2(1)(31 downto 0),14) xor x2(0)(31 downto 0);
    x2(0)(31 downto 0)                  := rotl32(x2(0)(31 downto 0),10) xor x2(1)(31 downto 0);
    x2(1)(31 downto 0)                  := rotl32(x2(1)(31 downto 0),1);
    x2(0)(63 downto 32)                 := rotl32(x2(0)(63 downto 32),2) xor x2(1)(63 downto 32);
    x2(1)(63 downto 32)                 := rotl32(x2(1)(63 downto 32),14) xor x2(0)(63 downto 32);
    x2(0)(63 downto 32)                 := rotl32(x2(0)(63 downto 32),10) xor x2(1)(63 downto 32);
    x2(1)(63 downto 32)                 := rotl32(x2(1)(63 downto 32),1);
    return x2;
  end mix_word64;
  
  function sub_crumb64(x: word64_array4) return word64_array4 is
    variable x2                         : word64_array4;
    variable t                          : word64;
  begin
    t                                   := x(0);
    x2(0)                               := x(0) or x(1);
    x2(2)                               := x(2) xor x(3);
    x2(1)                               := not x(1);
    x2(0)                               := x2(0) xor x(3);
    x2(3)                               := x(3) and t;
    x2(1)                               := x2(1) xor x2(3);
    x2(3)                               := x2(3) xor x2(2);
    x2(2)                               := x2(2) and x2(0);
    x2(0)                               := not x2(0);
    x2(2)                               := x2(2) xor x2(1);
    x2(1)                               := x2(1) or x2(3);
    t                                   := t xor x2(1);
    x2(3)                               := x2(3) xor x2(2);
    x2(2)                               := x2(2) and x2(1);
    x2(1)                               := x2(1) xor x2(0);
    x2(0)                               := t;
    return x2;
  end sub_crumb64;
  
  signal x_in_array                     : word64_array8;
  signal x                              : word64_array8;
  
  signal q_x                            : word64_array8;
  signal q_count                        : unsigned(1 downto 0);
  signal q_done                         : slv(1 downto 0);
  
begin

  x_new                                 <= q_done(1);
  
  output_mapping : for i in 0 to 7 generate
    x_out((i+1)*64-1 downto i*64)       <= q_x(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 7 generate
    x_in_array(i)                       <= x_in((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  mix_word_proc : process(q_x, q_count, x_in_array) is
  begin
    x                                   <= q_x;
    case q_count is
    when "00" =>
      (x(0),x(1),x(2),x(3))             <= sub_crumb64((x_in_array(0),x_in_array(1),x_in_array(2),x_in_array(3)));
      (x(5),x(6),x(7),x(4))             <= sub_crumb64((x_in_array(5),x_in_array(6),x_in_array(7),x_in_array(4)));
    when "01" =>
      (x(0),x(4))                       <= mix_word64((q_x(0),q_x(4)));
      (x(1),x(5))                       <= mix_word64((q_x(1),q_x(5)));
      (x(2),x(6))                       <= mix_word64((q_x(2),q_x(6)));
      (x(3),x(7))                       <= mix_word64((q_x(3),q_x(7)));
    when "10" =>
      x(0)                              <= q_x(0) xor a;
      x(4)                              <= q_x(4) xor b;
    when others =>
      null;
    end case;
  end process mix_word_proc;
  
  registers : process(clk) is
  begin
    if rising_edge(clk) then
      if clk_en = '1' then
        q_x                             <= x;
        if start = '1' then
          q_count                       <= (others => '0');
        elsif q_count /= 3 then
          q_count                       <= q_count + 1;
        end if;
        if q_count = 2 then
          q_done                        <= "01";
        else
          q_done                        <= q_done(0) & '0';
        end if;
      end if;
    end if;
  end process registers;
  
end architecture luffa512_sc_mw_ce_rtl;