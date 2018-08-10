--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity x11_core_simple_ce is
port (
  clk                           : in std_logic;
  reset                         : in std_logic;
  start                         : in std_logic;
  input                         : in std_logic_vector(639 downto 0);
  inc_nonce                     : out std_logic;
  output                        : out std_logic_vector(31 downto 0);
  done                          : out std_logic
);
end entity x11_core_simple_ce;

architecture x11_core_simple_ce_rtl of x11_core_simple_ce is
  
  alias slv is std_logic_vector;
  
  component clk_en_gen is
  generic (
    BLAKE512_DIV                : natural;
    BMW512_DIV                  : natural;
    CUBEHASH512_DIV             : natural;
    GROESTL512_DIV              : natural;
    JH512_DIV                   : natural;
    KECCAK512_DIV               : natural;
    LUFFA512_DIV                : natural;
    SHAVITE512_DIV              : natural;
    SKEIN512_DIV                : natural;
    SIMD512_DIV                 : natural;
    ECHO512_DIV                 : natural
  );
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    clk_en                      : out std_logic_vector(10 downto 0)
  );
  end component clk_en_gen;
  
  component blake512_4g_ce is
  port (
    clk                         : in std_logic;
    clk_en                      : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(639 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component blake512_4g_ce;
  
  component bmw512_ce is
  port (
    clk                         : in std_logic;
    clk_en                      : in std_logic;  
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component bmw512_ce;
  
  component cubehash512_ce is
  port (
    clk                         : in std_logic;
    clk_en                      : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component cubehash512_ce;
  
  component groestl512_ce is
  port (
    clk                         : in std_logic;
    clk_en                      : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component groestl512_ce;
  
  component jh512_ce is
  port (
    clk                         : in std_logic;
    clk_en                      : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component jh512_ce;
  
  component keccak512_ce is
  port (
    clk                         : in std_logic;
    clk_en                      : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component keccak512_ce;
  
  component luffa512_ce is
  port (
    clk                         : in std_logic;
    clk_en                      : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component luffa512_ce;
  
  component shavite512_ce is
  port (
    clk                         : in std_logic;
    clk_en                      : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component shavite512_ce;
  
  component skein512_ce is
  port (
    clk                         : in std_logic;
    clk_en                      : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component skein512_ce;
  
  component simd512_ce is
  port (
    clk                         : in std_logic;
    clk_en                      : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component simd512_ce;
  
  component echo512_ce is
  port (
    clk                         : in std_logic;
    clk_en                      : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component echo512_ce;

  signal clk_en                 : std_logic_vector(10 downto 0);
  
begin

  clk_en_gen_inst : clk_en_gen
  generic map (
    BLAKE512_DIV                => 15,
    BMW512_DIV                  => 15,
    CUBEHASH512_DIV             => 15,
    GROESTL512_DIV              => 15,
    JH512_DIV                   => 15,
    KECCAK512_DIV               => 15,
    LUFFA512_DIV                => 15,
    SHAVITE512_DIV              => 15,
    SKEIN512_DIV                => 15,
    SIMD512_DIV                 => 15,
    ECHO512_DIV                 => 15
  )
  port map (
    clk                         => clk,
    reset                       => reset,
    clk_en                      => clk_en
  );

  blake512_4g_inst : blake512_4g_ce
  port map (
    clk                         => clk,
    clk_en                      => clk_en(0),
    reset                       => reset,
    start                       => start,
    data_in                     => input,
    hash                        => blake512_hash,
    hash_new                    => blake512_hash_new
  );
  
  bmw512_inst : bmw512_ce
  port map (
    clk                         => clk,
    clk_en                      => clk_en(1),
    reset                       => reset,
    start                       => blake512_hash_new,
    data_in                     => blake512_hash,
    hash                        => bmw512_hash,
    hash_new                    => bmw512_hash_new
  );
  
  cubehash512_inst : cubehash512_ce
  port map (
    clk                         => clk,
    clk_en                      => clk_en(2),
    reset                       => reset,
    start                       => bmw512_hash_new,
    data_in                     => bmw512_hash,
    hash                        => cubehash512_hash,
    hash_new                    => cubehash512_hash_new
  );
  
  groestl512_inst : groestl512_ce
  port map (
    clk                         => clk,
    clk_en                      => clk_en(3),
    reset                       => reset,
    start                       => cubehash512_hash_new,
    data_in                     => cubehash512_hash,
    hash                        => groestl512_hash,
    hash_new                    => groestl512_hash_new
  );
  
  jh512_inst : jh512_ce
  port map (
    clk                         => clk,
    clk_en                      => clk_en(4),
    reset                       => reset,
    start                       => groestl512_hash_new,
    data_in                     => groestl512_hash,
    hash                        => jh512_hash,
    hash_new                    => jh512_hash_new
  );
  
  keccak512_inst : keccak512_ce
  port map (
    clk                         => clk,
    clk_en                      => clk_en(5),
    reset                       => reset,
    start                       => jh512_hash_new,
    data_in                     => jh512_hash,
    hash                        => keccak512_hash,
    hash_new                    => keccak512_hash_new
  );
  
  luffa512_inst : luffa512_ce
  port map (
    clk                         => clk,
    clk_en                      => clk_en(6),
    reset                       => reset,
    start                       => keccak512_hash_new,
    data_in                     => keccak512_hash,
    hash                        => luffa512_hash,
    hash_new                    => luffa512_hash_new
  );
  
  shavite512_inst : shavite512_ce
  port map (
    clk                         => clk,
    clk_en                      => clk_en(7),
    reset                       => reset,
    start                       => luffa512_hash_new,
    data_in                     => luffa512_hash,
    hash                        => shavite512_hash,
    hash_new                    => shavite512_hash_new
  );
  
  skein512_inst : skein512_ce
  port map (
    clk                         => clk,
    clk_en                      => clk_en(8),
    reset                       => reset,
    start                       => shavite512_hash_new,
    data_in                     => shavite512_hash,
    hash                        => skein512_hash,
    hash_new                    => skein512_hash_new
  );
  
  simd512_inst : simd512_ce
  port map (
    clk                         => clk,
    clk_en                      => clk_en(9),
    reset                       => reset,
    start                       => skein512_hash_new,
    data_in                     => skein512_hash,
    hash                        => simd512_hash,
    hash_new                    => simd512_hash_new
  );
  
  echo512_inst : echo512_ce
  port map (
    clk                         => clk,
    clk_en                      => clk_en(10),
    reset                       => reset,
    start                       => simd512_hash_new,
    data_in                     => simd512_hash,
    hash                        => output,
    hash_new                    => done
  );
  
  -- registers : process (clk)
  -- begin
    -- if rising_edge(clk) then
      -- if start = '1' or inc_nonce_int = '1' then
        -- q_nonce                   <= input(639 downto 608);
      -- end if;
      -- if smix_done = '1' then
        -- q_nonce_2                 <= q_nonce;
      -- end if;
    -- end if;
  -- end process registers;
  
end architecture x11_core_simple_ce_rtl;
  