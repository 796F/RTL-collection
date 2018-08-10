--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity skein512_mix_ce is
port (
  clk                                   : in std_logic;
  clk_en                                : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  addkey_only                           : in std_logic;
  even                                  : in std_logic;
  p_in                                  : in std_logic_vector(511 downto 0);
  h                                     : in std_logic_vector(511 downto 0);
  k                                     : in std_logic_vector(63 downto 0);
  t                                     : in std_logic_vector(191 downto 0);
  s                                     : in std_logic_vector(4 downto 0);
  p_out                                 : out std_logic_vector(511 downto 0);
  p_new                                 : out std_logic
);
end entity skein512_mix_ce;

architecture skein512_mix_ce_rtl of skein512_mix_ce is
  
  alias slv is std_logic_vector;
  
  component skein512_add_key_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    p_in                                : in std_logic_vector(511 downto 0);
    h                                   : in std_logic_vector(511 downto 0);
    k                                   : in std_logic_vector(63 downto 0);
    t                                   : in std_logic_vector(191 downto 0);
    s                                   : in std_logic_vector(4 downto 0);
    p_out                               : out std_logic_vector(511 downto 0);
    p_new                               : out std_logic
  );
  end component skein512_add_key_ce;
  
  component skein512_mix8_xilinx_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    mix_count                           : in std_logic_vector(1 downto 0);
    even                                : in std_logic;
    p_in                                : in std_logic_vector(511 downto 0);
    p_out                               : out std_logic_vector(511 downto 0);
    p_new                               : out std_logic
  );
  end component skein512_mix8_xilinx_ce;
  
  subtype word64 is slv(63 downto 0);
  type nat_array_4 is array(0 to 3) of natural;
  type skein512_mix_state is (IDLE, ADD_KEY, MIX, FINISH);
                        
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
  
  signal skein512_mix_state_next        : skein512_mix_state;
  signal count_start                    : std_logic;
  signal count_en                       : std_logic;
  signal h_int                          : word64_array9;
  signal p_in_int                       : word64_array8;
  signal ak_p_out                       : slv(511 downto 0);
  signal ak_p_out_int                   : word64_array8;
  signal ak_p_new                       : std_logic;
  signal m8_p_out                       : slv(511 downto 0);
  signal m8_p_out_int                   : word64_array8;
  signal m8_p_new                       : std_logic;
  signal p                              : word64_array8;
  signal p_vec                          : slv(511 downto 0);
  signal t_int                          : word64_array3;
  signal ak_start                       : std_logic;
  signal rc_vec                         : nat_array_4;
  signal m8_start                       : std_logic;
  signal done                           : std_logic;

  signal q_skein512_mix_state           : skein512_mix_state;
  signal q_p                            : word64_array8;
  signal q_count                        : unsigned(1 downto 0);
  
begin


  output_mapping : for i in 0 to 7 generate
    p_out((i+1)*64-1 downto i*64)       <= q_p(i);
  end generate output_mapping;
  
  p_new                                 <= done;
  
  array_mapping_1 : for i in 0 to 7 generate
    h_int(i)                            <= h((i+1)*64-1 downto i*64);
    p_in_int(i)                         <= p_in((i+1)*64-1 downto i*64);
    ak_p_out_int(i)                     <= ak_p_out((i+1)*64-1 downto i*64);
    m8_p_out_int(i)                     <= m8_p_out((i+1)*64-1 downto i*64);
    p_vec((i+1)*64-1 downto i*64)       <= q_p(i);
  end generate array_mapping_1;
  
  array_mapping_2 : for i in 0 to 2 generate
    t_int(i)                            <= t((i+1)*64-1 downto i*64);
  end generate array_mapping_2;

  h_int(8)                              <= k;

  skein512_add_key_inst : skein512_add_key_ce
  port map (
    clk                                 => clk,
    clk_en                              => clk_en,
    reset                               => reset,
    start                               => ak_start,
    p_in                                => p_in,
    h                                   => h,
    k                                   => k,
    t                                   => t,
    s                                   => s,
    p_out                               => ak_p_out,
    p_new                               => ak_p_new
  );

  skein512_mix8_inst : skein512_mix8_xilinx_ce
  port map (
    clk                                 => clk,
    clk_en                              => clk_en,
    reset                               => reset,
    start                               => m8_start,
    mix_count                           => slv(q_count),
    even                                => even,
    p_in                                => p_vec,
    p_out                               => m8_p_out,
    p_new                               => m8_p_new
  );
  
  mix_proc : process(q_skein512_mix_state, q_p, start, ak_p_new, addkey_only, ak_p_out_int, even, m8_p_out_int, m8_p_new)
  begin
    skein512_mix_state_next             <= q_skein512_mix_state;
    count_start                         <= '1';
    count_en                            <= '0';
    p                                   <= q_p;
    ak_start                            <= '0';
    m8_start                            <= '0';
    done                                <= '0';
    case q_skein512_mix_state is
    when IDLE =>
      if start = '1' then
        ak_start                        <= '1';
        skein512_mix_state_next         <= ADD_KEY;
      end if;
    when ADD_KEY =>
      if ak_p_new = '1' then
        p                               <= ak_p_out_int;
        if addkey_only = '1' then
          skein512_mix_state_next       <= FINISH;
        else
          m8_start                      <= '1';
          skein512_mix_state_next       <= MIX;
        end if;
      end if;
    when MIX =>
      count_start                       <= '0';
      count_en                          <= m8_p_new;
      m8_start                          <= m8_p_new;
      if m8_p_new = '1' then
        p                               <= m8_p_out_int;
        if q_count = 3 then
          count_en                      <= '0';
          m8_start                      <= '0';
          skein512_mix_state_next       <= FINISH;
        end if;
      end if;
    when FINISH =>
      done                              <= '1';
      if start = '1' then
        ak_start                        <= '1';
        skein512_mix_state_next         <= ADD_KEY;
      else
        skein512_mix_state_next         <= IDLE;
      end if;
    end case;
  end process mix_proc;

  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_skein512_mix_state              <= IDLE;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        q_skein512_mix_state            <= skein512_mix_state_next;
        q_p                             <= p;
        if count_start = '1' then
          q_count                       <= (others => '0');
        elsif count_en = '1' and q_count /= 3 then
          q_count                       <= q_count + 1;
        end if;
      end if;
    end if;
  end process registers;
  
end architecture skein512_mix_ce_rtl;