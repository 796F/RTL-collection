--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity skein512_add_key is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  p_in                                  : in std_logic_vector(511 downto 0);
  h                                     : in std_logic_vector(511 downto 0);
  k                                     : in std_logic_vector(63 downto 0);
  t                                     : in std_logic_vector(191 downto 0);
  s                                     : in std_logic_vector(4 downto 0);
  p_out                                 : out std_logic_vector(511 downto 0);
  p_new                                 : out std_logic
);
end entity skein512_add_key;

architecture skein512_add_key_rtl of skein512_add_key is
  
  alias slv is std_logic_vector;
  subtype word64 is slv(63 downto 0);
                        
  constant zeros64 : word64 := (others => '0');
  
  function shr(x: word64; n: natural) return word64 is
  begin
    return word64(zeros64(n-1 downto 0) & x(x'high downto n));
  end shr;
  
  function shl(x: word64; n: natural) return word64 is
  begin
    return word64(x(x'high-n downto 0) & zeros64(x'high downto x'length-n));
  end shl;
  
  function rotr(x: word64; n: natural) return word64 is
  begin
    return word64(x(n-1 downto 0) & x(x'high downto n));
  end rotr;
  
  function rotl(x: word64; n: natural) return word64 is
  begin
    return word64(x(x'high-n downto 0) & x(x'high downto x'length-n));
  end rotl;
  
  type word64_array9 is array(0 to 8) of word64;
  type word64_array8 is array(0 to 7) of word64;
  type word64_array3 is array(0 to 2) of word64;
  
  signal h_int                          : word64_array9;
  signal p_in_int                       : word64_array8;
  signal p                              : word64_array8;
  signal t_int                          : word64_array3;
  
  signal q_count                        : unsigned(2 downto 0);
  signal q_p                            : word64_array8;
  signal q_done                         : slv(1 downto 0);
  
begin
  
  output_mapping : for i in 0 to 7 generate
    p_out((i+1)*64-1 downto i*64)       <= q_p(i);
  end generate output_mapping;
  
  p_new                                 <= q_done(1);
  
  input_mapping_1 : for i in 0 to 7 generate
    h_int(i)                            <= h((i+1)*64-1 downto i*64);
    p_in_int(i)                         <= p_in((i+1)*64-1 downto i*64);
  end generate input_mapping_1;
  
  input_mapping_2 : for i in 0 to 2 generate
    t_int(i)                            <= t((i+1)*64-1 downto i*64);
  end generate input_mapping_2;

  h_int(8)                              <= k;
  
  add_key_proc : process(q_count, q_p, p_in_int, h_int, s, t_int) is
  begin
    p                                   <= q_p;
    case q_count is
    when "000" | "001" | "010" | "011" | "100" =>
      p(to_integer(q_count))            <= word64(unsigned(p_in_int(to_integer(q_count))) + unsigned(h_int(to_integer(unsigned(s) + q_count) mod 9)));
    when "101" =>
      p(to_integer(q_count))            <= word64(unsigned(p_in_int(to_integer(q_count))) + unsigned(h_int(to_integer(unsigned(s) + q_count) mod 9)) + unsigned(t_int(to_integer(unsigned(s)) mod 3)));
    when "110" =>
      p(to_integer(q_count))            <= word64(unsigned(p_in_int(to_integer(q_count))) + unsigned(h_int(to_integer(unsigned(s) + q_count) mod 9)) + unsigned(t_int(to_integer(unsigned(s) + 1) mod 3)));
    when "111" =>
      p(to_integer(q_count))            <= word64(unsigned(p_in_int(to_integer(q_count))) + unsigned(h_int(to_integer(unsigned(s) + q_count) mod 9)) + unsigned(s));
    when others =>
      null;
    end case;
  end process add_key_proc;

  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_count                           <= (others => '0');
    elsif rising_edge(clk) then
      q_p                               <= p;
      if start = '1' then
        q_count                         <= (others => '0');
      elsif q_count /= 7 then
        q_count                         <= q_count + 1;
      end if;
      if q_count = 6 then
        q_done                          <= "01";
      else
        q_done                          <= q_done(0) & '0';
      end if;
    end if;
  end process registers;
  
end architecture skein512_add_key_rtl;