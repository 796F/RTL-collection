--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity skein512 is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  data_in                               : in std_logic_vector(511 downto 0);
  hash                                  : out std_logic_vector(511 downto 0);
  hash_new                              : out std_logic
);
end entity skein512;

architecture skein512_rtl of skein512 is
  
  alias slv is std_logic_vector;
  
  component skein512_mix is
  port (
    clk                                 : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    addkey_only                         : in std_logic;
    even                                : in std_logic;
    p_in                                : in std_logic_vector(511 downto 0);
    h                                   : in std_logic_vector(511 downto 0);
    k                                   : in std_logic_vector(63 downto 0);
    t                                   : in std_logic_vector(191 downto 0);
    s                                   : in std_logic_vector(4 downto 0);
    p_out                               : out std_logic_vector(511 downto 0);
    p_new                               : out std_logic
  );
  end component skein512_mix;
  
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  type nat_array_8 is array(0 to 7) of natural;
  type nat_array_4 is array(0 to 3) of natural;
  type skein512_state is (IDLE, INIT, MIX, ADD_KEY, H_GEN, FINISH);
                        
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
  
  type word64_array8 is array(0 to 7) of word64;
  type word64_array3 is array(0 to 2) of word64;
  
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
  signal mix_start                      : std_logic;
  signal addkey_only                    : std_logic;
  signal even                           : std_logic;
  signal mix_p                          : slv(511 downto 0);
  signal mix_p_int                      : word64_array8;
  signal mix_p_new                      : std_logic;
  signal done                           : std_logic;
  
  signal q_skein512_state               : skein512_state;
  signal q_last_pass                    : std_logic;
  signal q_count                        : unsigned(4 downto 0);
  signal q_m                            : word64_array8;
  signal q_p                            : word64_array8;
  signal q_p_vec                        : slv(511 downto 0);
  signal q_h                            : word64_array8;
  signal q_h_vec                        : slv(511 downto 0);
  signal q_k                            : word64;
  signal q_t                            : word64_array3;
  signal q_t_vec                        : slv(191 downto 0);
  
begin

  hash_new                              <= done;
  
  output_mapping : for i in 0 to 7 generate
    hash((i+1)*64-1 downto i*64)        <= q_h(i);
  end generate output_mapping;
  
  array_mapping_1 : for i in 0 to 7 generate
    data_in_array(i)                    <= data_in((i+1)*64-1 downto i*64);
    mix_p_int(i)                        <= mix_p((i+1)*64-1 downto i*64);
    q_p_vec((i+1)*64-1 downto i*64)     <= q_p(i);
    q_h_vec((i+1)*64-1 downto i*64)     <= q_h(i);
  end generate array_mapping_1;

  array_mapping_2 : for i in 0 to 2 generate
    q_t_vec((i+1)*64-1 downto i*64)     <= q_t(i);
  end generate array_mapping_2;
  
  even                                  <= '1' when to_integer(q_count) mod 2 = 0 else '0';
  
  skein512_mix_inst : skein512_mix
  port map (
    clk                                 => clk,
    reset                               => reset,
    start                               => mix_start,
    addkey_only                         => addkey_only,
    even                                => even,
    p_in                                => q_p_vec,
    h                                   => q_h_vec,
    k                                   => q_k,
    t                                   => q_t_vec,
    s                                   => slv(q_count),
    p_out                               => mix_p,
    p_new                               => mix_p_new
  );
  
  skein512_proc : process(q_skein512_state, q_last_pass, q_m, q_p, q_h, q_k, q_t, data_in_array, start, mix_p_new, mix_p_int, q_count)
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
    mix_start                           <= '0';
    addkey_only                         <= '0';
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
      mix_start                         <= '1';
      skein512_state_next               <= MIX;
    when MIX =>
      count_start                       <= '0';
      count_en                          <= mix_p_new;
      mix_start                         <= mix_p_new;
      if mix_p_new = '1' then
        p                               <= mix_p_int;
        if q_count = 17 then
          addkey_only                   <= '1';
          skein512_state_next           <= ADD_KEY;
        end if;
      end if;
    when ADD_KEY =>
      count_start                       <= '0';
      addkey_only                       <= '1';
      if mix_p_new = '1' then
        p                               <= mix_p_int;
        skein512_state_next             <= H_GEN;
      end if;
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
  
end architecture skein512_rtl;