--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity skein512_reference is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  data_in                               : in std_logic_vector(511 downto 0);
  hash                                  : out std_logic_vector(511 downto 0);
  hash_new                              : out std_logic
);
end entity skein512_reference;

architecture skein512_reference_rtl of skein512_reference is
  
  alias slv is std_logic_vector;
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  type nat_array_8 is array(0 to 7) of natural;
  type nat_array_4 is array(0 to 3) of natural;
  type skein512_state is (IDLE, INIT, MIX, ADDKEY, H_GEN, FINISH);
                        
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
  
  type word64_array256 is array(0 to 255) of word64;
  type word64_array32 is array(0 to 31) of word64;
  type word64_array16 is array(0 to 15) of word64;
  type word64_array9 is array(0 to 8) of word64;
  type word64_array8 is array(0 to 7) of word64;
  type word64_array3 is array(0 to 2) of word64;
  
  function add_key(p: word64_array8; h: word64_array8; k: word64; t: word64_array3; s: natural) return word64_array8 is
    variable h2                         : word64_array9;
    variable p2                         : word64_array8;
  begin
    for i in 0 to 7 loop
      h2(i)                             := h(i);
    end loop;
    h2(8)                               := k;
    for i in 0 to 4 loop
      p2(i)                             := word64(unsigned(p(i)) + unsigned(h2((s+i) mod 9)));
    end loop;
    p2(5)                               := word64(unsigned(p(5)) + unsigned(h2((s+5) mod 9)) + unsigned(t(s mod 3)));
    p2(6)                               := word64(unsigned(p(6)) + unsigned(h2((s+6) mod 9)) + unsigned(t((s+1) mod 3)));
    p2(7)                               := word64(unsigned(p(7)) + unsigned(h2((s+7) mod 9)) + to_unsigned(s,64));
    return p2;
  end add_key;
  
  function mix_8(p: word64_array8; rc: nat_array_4) return word64_array8 is
    variable p2 : word64_array8;
  begin
    for i in 0 to 3 loop
      p2(i*2)                           := word64(unsigned(p(i*2)) + unsigned(p(i*2+1)));
      p2(i*2+1)                         := rotl(p(i*2+1),rc(i)) xor p2(i*2);
    end loop;
    return p2;
  end mix_8;
    
  function mix_even(p: word64_array8; h: word64_array8; k: word64; t: word64_array3; s: natural) return word64_array8 is
    variable p2                                       : word64_array8;
  begin
    p2                                                := add_key(p, h, k, t, s);
    p2                                                := mix_8( p2,                                               (46,36,19,37));
    (p2(2),p2(1),p2(4),p2(7),p2(6),p2(5),p2(0),p2(3)) := mix_8((p2(2),p2(1),p2(4),p2(7),p2(6),p2(5),p2(0),p2(3)), (33,27,14,42));
    (p2(4),p2(1),p2(6),p2(3),p2(0),p2(5),p2(2),p2(7)) := mix_8((p2(4),p2(1),p2(6),p2(3),p2(0),p2(5),p2(2),p2(7)), (17,49,36,39));
    (p2(6),p2(1),p2(0),p2(7),p2(2),p2(5),p2(4),p2(3)) := mix_8((p2(6),p2(1),p2(0),p2(7),p2(2),p2(5),p2(4),p2(3)), (44, 9,54,56));    
    return p2;
  end mix_even;
  
  function mix_odd(p: word64_array8; h: word64_array8; k: word64; t: word64_array3; s: natural) return word64_array8 is
    variable p2                                       : word64_array8;
  begin
    p2                                                := add_key(p, h, k, t, s);
    p2                                                := mix_8( p2,                                               (39,30,34,24));
    (p2(2),p2(1),p2(4),p2(7),p2(6),p2(5),p2(0),p2(3)) := mix_8((p2(2),p2(1),p2(4),p2(7),p2(6),p2(5),p2(0),p2(3)), (13,50,10,17));
    (p2(4),p2(1),p2(6),p2(3),p2(0),p2(5),p2(2),p2(7)) := mix_8((p2(4),p2(1),p2(6),p2(3),p2(0),p2(5),p2(2),p2(7)), (25,29,39,43));
    (p2(6),p2(1),p2(0),p2(7),p2(2),p2(5),p2(4),p2(3)) := mix_8((p2(6),p2(1),p2(0),p2(7),p2(2),p2(5),p2(4),p2(3)), ( 8,35,56,22));    
    return p2;
  end mix_odd;
  
  constant IV                           : word64_array8 := (X"4903ADFF749C51CE", X"0D95DE399746DF03",
                                                            X"8FD1934127C79BCE", X"9A255629FF352CB1",
                                                            X"5DB62599DF6CA7B0", X"EABE394CA9D5C3F4",
                                                            X"991112C71A75B523", X"AE18A40B660FCC33");
  
  signal skein512_state_next            : skein512_state;
  signal last_pass                      : std_logic;
  signal count_start                    : std_logic;
  signal count_en                       : std_logic;
  signal data_in_array                  : word64_array8;
  signal m                              : word64_array8;
  signal p                              : word64_array8;
  signal h                              : word64_array8;
  signal k                              : word64;
  signal t                              : word64_array3;
  signal done                           : std_logic;
  
  signal q_skein512_state               : skein512_state;
  signal q_last_pass                    : std_logic;
  signal q_count                        : unsigned(4 downto 0);
  signal q_m                            : word64_array8;
  signal q_p                            : word64_array8;
  signal q_h                            : word64_array8;
  signal q_k                            : word64;
  signal q_t                            : word64_array3;
  
begin

  hash_new                              <= done;
  
  output_mapping : for i in 0 to 7 generate
    hash((i+1)*64-1 downto i*64)        <= q_h(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 7 generate
    data_in_array(i)                    <= data_in((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  skein512_proc : process(q_skein512_state, q_last_pass, q_m, q_p, q_h, q_k, q_t, data_in_array, start, q_count)
  begin
    skein512_state_next                 <= q_skein512_state;
    last_pass                           <= q_last_pass;
    count_start                         <= '1';
    count_en                            <= '0';
    m                                   <= q_m;
    p                                   <= q_p;
    h                                   <= q_h;
    k                                   <= q_k;
    t                                   <= q_t;
    done                                <= '0';
    case q_skein512_state is
    when IDLE =>
      last_pass                         <= '0';
      m                                 <= data_in_array;
      p                                 <= data_in_array;
      t(0)                              <= X"0000000000000040";
      t(1)                              <= X"F000000000000000";
      if start = '1' then
        for i in 0 to 7 loop
          h(i)                          <= IV(i);
        end loop;
        skein512_state_next             <= INIT;
      end if;
    when INIT =>
      k                                 <= ((q_h(0) xor q_h(1)) xor (q_h(2) xor q_h(3))) xor ((q_h(4) xor q_h(5)) xor (q_h(6) xor q_h(7))) xor X"1BD11BDAA9FC1A22";
      t(2)                              <= q_t(0) xor q_t(1);
      skein512_state_next               <= MIX;
    when MIX =>
      count_start                       <= '0';
      count_en                          <= '1';
      if to_integer(q_count) mod 2 = 0 then
        p                               <= mix_even(q_p, q_h, q_k, q_t, to_integer(q_count));
      else
        p                               <= mix_odd(q_p, q_h, q_k, q_t, to_integer(q_count));
      end if;
      if q_count = 17 then
        skein512_state_next             <= ADDKEY;
      end if;
    when ADDKEY =>
      p                                 <= add_key(q_p, q_h, q_k, q_t, 18);
      skein512_state_next               <= H_GEN;
    when H_GEN =>
      for i in 0 to 7 loop
        h(i)                            <= q_m(i) xor q_p(i);
      end loop;
      if q_last_pass = '1' then
        skein512_state_next             <= FINISH;
      else
        last_pass                       <= '1';
        t(0)                            <= X"0000000000000008";
        t(1)                            <= X"FF00000000000000";
        m                               <= (others => (others => '0'));
        p                               <= (others => (others => '0'));
        skein512_state_next             <= INIT;
      end if;
    when FINISH =>
      done                              <= '1';
      skein512_state_next               <= IDLE;
    end case;
  end process skein512_proc;

  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_skein512_state                  <= IDLE;
    elsif rising_edge(clk) then
      q_skein512_state                  <= skein512_state_next;
      q_last_pass                       <= last_pass;
      q_m                               <= m;
      q_p                               <= p;
      q_h                               <= h;
      q_k                               <= k;
      q_t                               <= t;
      if count_start = '1' then
        q_count                         <= (others => '0');
      elsif count_en = '1' then
        q_count                         <= q_count + 1;
      end if;
    end if;
  end process registers;
  
end architecture skein512_reference_rtl;