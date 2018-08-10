--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity x11_core_simple is
port (
  clk                             : in std_logic;
  reset                           : in std_logic;
  start                           : in std_logic;
  input                           : in std_logic_vector(639 downto 0);
  inc_nonce                       : out std_logic;
  output                          : out std_logic_vector(31 downto 0);
  done                            : out std_logic
);
end entity x11_core_simple;

architecture x11_core_simple_rtl of x11_core_simple is
  
  alias slv is std_logic_vector;
  
  component blake512_4g is
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(639 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component blake512_4g;
  
  component bmw512 is
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component bmw512;
  
  component cubehash512 is
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component cubehash512;
  
  component groestl512 is
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component groestl512;
  
  component jh512 is
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component jh512;
  
  component keccak512 is
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component keccak512;
  
  component luffa512 is
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component luffa512;
  
  component shavite512 is
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component shavite512;
  
  component skein512 is
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component skein512;
  
  component simd512 is
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component simd512;
  
  component echo512 is
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic_vector(511 downto 0);
    hash                        : out std_logic_vector(511 downto 0);
    hash_new                    : out std_logic
  );
  end component echo512;

begin

  blake512_4g_inst : blake512_4g
  port map (
    clk                         => clk,
    reset                       => reset,
    start                       => start,
    data_in                     => input,
    hash                        => blake512_hash,
    hash_new                    => blake512_hash_new
  );
  
  bmw512_inst : bmw512
  port map (
    clk                         => clk,
    reset                       => reset,
    start                       => blake512_hash_new,
    data_in                     => blake512_hash,
    hash                        => bmw512_hash,
    hash_new                    => bmw512_hash_new
  );
  
  cubehash512_inst : cubehash512
  port map (
    clk                         => clk,
    reset                       => reset,
    start                       => bmw512_hash_new,
    data_in                     => bmw512_hash,
    hash                        => cubehash512_hash,
    hash_new                    => cubehash512_hash_new
  );
  
  groestl512_inst : groestl512
  port map (
    clk                         => clk,
    reset                       => reset,
    start                       => cubehash512_hash_new,
    data_in                     => cubehash512_hash,
    hash                        => groestl512_hash,
    hash_new                    => groestl512_hash_new
  );
  
  jh512_inst : jh512
  port map (
    clk                         => clk,
    reset                       => reset,
    start                       => groestl512_hash_new,
    data_in                     => groestl512_hash,
    hash                        => jh512_hash,
    hash_new                    => jh512_hash_new
  );
  
  keccak512_inst : keccak512
  port map (
    clk                         => clk,
    reset                       => reset,
    start                       => jh512_hash_new,
    data_in                     => jh512_hash,
    hash                        => keccak512_hash,
    hash_new                    => keccak512_hash_new
  );
  
  luffa512_inst : luffa512
  port map (
    clk                         => clk,
    reset                       => reset,
    start                       => keccak512_hash_new,
    data_in                     => keccak512_hash,
    hash                        => luffa512_hash,
    hash_new                    => luffa512_hash_new
  );
  
  shavite512_inst : shavite512
  port map (
    clk                         => clk,
    reset                       => reset,
    start                       => luffa512_hash_new,
    data_in                     => luffa512_hash,
    hash                        => shavite512_hash,
    hash_new                    => shavite512_hash_new
  );
  
  skein512_inst : skein512
  port map (
    clk                         => clk,
    reset                       => reset,
    start                       => shavite512_hash_new,
    data_in                     => shavite512_hash,
    hash                        => skein512_hash,
    hash_new                    => skein512_hash_new
  );
  
  simd512_inst : simd512
  port map (
    clk                         => clk,
    reset                       => reset,
    start                       => skein512_hash_new,
    data_in                     => skein512_hash,
    hash                        => simd512_hash,
    hash_new                    => simd512_hash_new
  );
  
  echo512_inst : echo512
  port map (
    clk                         => clk,
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
  
end architecture x11_core_simple_rtl;
  