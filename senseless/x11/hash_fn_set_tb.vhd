--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hash_fn_set_tb is
end entity hash_fn_set_tb;

architecture hash_fn_set_tb_behav of hash_fn_set_tb is
  
  alias slv is std_logic_vector;

  component clk_en_gen is
  generic (
    BLAKE512_DIV                  : natural;
    BMW512_DIV                    : natural;
    CUBEHASH512_DIV               : natural;
    GROESTL512_DIV                : natural;
    JH512_DIV                     : natural;
    KECCAK512_DIV                 : natural;
    LUFFA512_DIV                  : natural;
    SHAVITE512_DIV                : natural;
    SKEIN512_DIV                  : natural;
    SIMD512_DIV                   : natural;
    ECHO512_DIV                   : natural;
    WORDLENGTH                    : natural
  );
  port (
    clk                           : in std_logic;
    reset                         : in std_logic;
    clk_en                        : out std_logic_vector(10 downto 0)
  );
  end component clk_en_gen;
  
  component hash_fn_set is
  generic (
    FIRST_STAGE                   : boolean;
    HF_TYPE                       : string;
    HF_NUM_PREV                   : natural;
    HF_NUM                        : natural;
    FIFO_DEPTH                    : natural;
    DUMMY_DELAY                   : natural
  );
  port (
    clk                           : in std_logic;
    clk_en_prev                   : in std_logic;
    clk_en                        : in std_logic;
    reset                         : in std_logic;
    start                         : in std_logic_vector(HF_NUM_PREV-1 downto 0);
    first_input                   : in std_logic_vector(639 downto 0);
    input                         : in std_logic_vector(HF_NUM_PREV*544-1  downto 0);
    inc_nonce                     : out std_logic;
    hashes                        : out std_logic_vector(HF_NUM*544-1 downto 0);
    hashes_new                    : out std_logic_vector(HF_NUM-1 downto 0)
  );
  end component hash_fn_set;
  
  constant NUM_STAGES             : natural := 11;

  type nat_array is array(0 to NUM_STAGES-1) of natural;

  constant TCLK_125               : time := 8 ns;
  constant HF_NUM_PREV            : nat_array := (1,1,1,1,1,1,1,1,1,1,1);
  constant HF_NUM                 : nat_array := (1,1,1,1,1,1,1,1,1,1,1);
  constant FIFO_DEPTH             : nat_array := (32,32,32,32,32,32,32,32,32,32,32);
  constant ZEROS_640              : slv(639 downto 0) := (others => '0');
  constant ZEROS_544              : slv(543 downto 0) := (others => '0');

  signal clk                      : std_logic := '0';
  signal clk_en                   : slv(NUM_STAGES-1 downto 0);
  signal reset                    : std_logic;
  signal start                    : slv(HF_NUM_PREV(0)-1 downto 0) := "0";
  signal data_in                  : slv(639 downto 0) := (others => '0');
  signal hashes_0                 : std_logic_vector(HF_NUM(0)*544-1 downto 0);
  signal hashes_0_new             : std_logic_vector(HF_NUM(0)-1 downto 0);
  signal hashes_1                 : std_logic_vector(HF_NUM(1)*544-1 downto 0);
  signal hashes_1_new             : std_logic_vector(HF_NUM(1)-1 downto 0);
  signal hashes_2                 : std_logic_vector(HF_NUM(2)*544-1 downto 0);
  signal hashes_2_new             : std_logic_vector(HF_NUM(2)-1 downto 0);
  signal hashes_3                 : std_logic_vector(HF_NUM(3)*544-1 downto 0);
  signal hashes_3_new             : std_logic_vector(HF_NUM(3)-1 downto 0);
  signal hashes_4                 : std_logic_vector(HF_NUM(4)*544-1 downto 0);
  signal hashes_4_new             : std_logic_vector(HF_NUM(4)-1 downto 0);
  signal hashes_5                 : std_logic_vector(HF_NUM(5)*544-1 downto 0);
  signal hashes_5_new             : std_logic_vector(HF_NUM(5)-1 downto 0);
  signal hashes_6                 : std_logic_vector(HF_NUM(6)*544-1 downto 0);
  signal hashes_6_new             : std_logic_vector(HF_NUM(6)-1 downto 0);
  signal hashes_7                 : std_logic_vector(HF_NUM(7)*544-1 downto 0);
  signal hashes_7_new             : std_logic_vector(HF_NUM(7)-1 downto 0);
  signal hashes_8                 : std_logic_vector(HF_NUM(8)*544-1 downto 0);
  signal hashes_8_new             : std_logic_vector(HF_NUM(8)-1 downto 0);
  signal hashes_9                 : std_logic_vector(HF_NUM(9)*544-1 downto 0);
  signal hashes_9_new             : std_logic_vector(HF_NUM(9)-1 downto 0);
  signal hashes_10                : std_logic_vector(HF_NUM(10)*544-1 downto 0);
  signal hashes_10_new            : std_logic_vector(HF_NUM(10)-1 downto 0);

begin

  reset                           <= '1', '0' after 12.5 * TCLK_125;

  clk_en_gen_inst : clk_en_gen
  generic map (
    BLAKE512_DIV                  => 1,
    BMW512_DIV                    => 1,
    CUBEHASH512_DIV               => 1,
    GROESTL512_DIV                => 1,
    JH512_DIV                     => 1,
    KECCAK512_DIV                 => 1,
    LUFFA512_DIV                  => 1,
    SHAVITE512_DIV                => 1,
    SKEIN512_DIV                  => 1,
    SIMD512_DIV                   => 1,
    ECHO512_DIV                   => 1,
    WORDLENGTH                    => 5
  )
  port map (
    clk                           => clk,
    reset                         => reset,
    clk_en                        => clk_en
  );

  hash_fn_set_0 : hash_fn_set
  generic map (
    FIRST_STAGE                   => true,
    HF_TYPE                       => "BLAKE512",
    HF_NUM_PREV                   => HF_NUM_PREV(0),
    HF_NUM                        => HF_NUM(0),
    FIFO_DEPTH                    => FIFO_DEPTH(0),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(0),
    clk_en                        => clk_en(0),
    reset                         => reset,
    start                         => start,
    first_input                   => data_in,
    input                         => ZEROS_544,
    inc_nonce                     => open,
    hashes                        => hashes_0,
    hashes_new                    => hashes_0_new
  );

  hash_fn_set_1 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "BMW512",
    HF_NUM_PREV                   => HF_NUM_PREV(1),
    HF_NUM                        => HF_NUM(1),
    FIFO_DEPTH                    => FIFO_DEPTH(1),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(0),
    clk_en                        => clk_en(1),
    reset                         => reset,
    start                         => hashes_0_new,
    first_input                   => ZEROS_640,
    input                         => hashes_0,
    inc_nonce                     => open,
    hashes                        => hashes_1,
    hashes_new                    => hashes_1_new
  );

  hash_fn_set_2 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "CUBEHASH512",
    HF_NUM_PREV                   => HF_NUM_PREV(2),
    HF_NUM                        => HF_NUM(2),
    FIFO_DEPTH                    => FIFO_DEPTH(2),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(1),
    clk_en                        => clk_en(2),
    reset                         => reset,
    start                         => hashes_1_new,
    first_input                   => ZEROS_640,
    input                         => hashes_1,
    inc_nonce                     => open,
    hashes                        => hashes_2,
    hashes_new                    => hashes_2_new
  );  

  hash_fn_set_3 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "GROESTL512",
    HF_NUM_PREV                   => HF_NUM_PREV(3),
    HF_NUM                        => HF_NUM(3),
    FIFO_DEPTH                    => FIFO_DEPTH(3),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(2),
    clk_en                        => clk_en(3),
    reset                         => reset,
    start                         => hashes_2_new,
    first_input                   => ZEROS_640,
    input                         => hashes_2,
    inc_nonce                     => open,
    hashes                        => hashes_3,
    hashes_new                    => hashes_3_new
  );

  hash_fn_set_4 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "JH512",
    HF_NUM_PREV                   => HF_NUM_PREV(4),
    HF_NUM                        => HF_NUM(4),
    FIFO_DEPTH                    => FIFO_DEPTH(4),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(3),
    clk_en                        => clk_en(4),
    reset                         => reset,
    start                         => hashes_3_new,
    first_input                   => ZEROS_640,
    input                         => hashes_3,
    inc_nonce                     => open,
    hashes                        => hashes_4,
    hashes_new                    => hashes_4_new
  );

  hash_fn_set_5 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "KECCAK512",
    HF_NUM_PREV                   => HF_NUM_PREV(5),
    HF_NUM                        => HF_NUM(5),
    FIFO_DEPTH                    => FIFO_DEPTH(5),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(4),
    clk_en                        => clk_en(5),
    reset                         => reset,
    start                         => hashes_4_new,
    first_input                   => ZEROS_640,
    input                         => hashes_4,
    inc_nonce                     => open,
    hashes                        => hashes_5,
    hashes_new                    => hashes_5_new
  );

  hash_fn_set_6 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "LUFFA512",
    HF_NUM_PREV                   => HF_NUM_PREV(6),
    HF_NUM                        => HF_NUM(6),
    FIFO_DEPTH                    => FIFO_DEPTH(6),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(5),
    clk_en                        => clk_en(6),
    reset                         => reset,
    start                         => hashes_5_new,
    first_input                   => ZEROS_640,
    input                         => hashes_5,
    inc_nonce                     => open,
    hashes                        => hashes_6,
    hashes_new                    => hashes_6_new
  );

  hash_fn_set_7 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "SHAVITE512",
    HF_NUM_PREV                   => HF_NUM_PREV(7),
    HF_NUM                        => HF_NUM(7),
    FIFO_DEPTH                    => FIFO_DEPTH(7),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(6),
    clk_en                        => clk_en(7),
    reset                         => reset,
    start                         => hashes_6_new,
    first_input                   => ZEROS_640,
    input                         => hashes_6,
    inc_nonce                     => open,
    hashes                        => hashes_7,
    hashes_new                    => hashes_7_new
  );

  hash_fn_set_8 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "SKEIN512",
    HF_NUM_PREV                   => HF_NUM_PREV(8),
    HF_NUM                        => HF_NUM(8),
    FIFO_DEPTH                    => FIFO_DEPTH(8),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(7),
    clk_en                        => clk_en(8),
    reset                         => reset,
    start                         => hashes_7_new,
    first_input                   => ZEROS_640,
    input                         => hashes_7,
    inc_nonce                     => open,
    hashes                        => hashes_8,
    hashes_new                    => hashes_8_new
  );

  hash_fn_set_9 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "SIMD512",
    HF_NUM_PREV                   => HF_NUM_PREV(9),
    HF_NUM                        => HF_NUM(9),
    FIFO_DEPTH                    => FIFO_DEPTH(9),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(8),
    clk_en                        => clk_en(9),
    reset                         => reset,
    start                         => hashes_8_new,
    first_input                   => ZEROS_640,
    input                         => hashes_8,
    inc_nonce                     => open,
    hashes                        => hashes_9,
    hashes_new                    => hashes_9_new
  );

  hash_fn_set_10 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "ECHO512",
    HF_NUM_PREV                   => HF_NUM_PREV(10),
    HF_NUM                        => HF_NUM(10),
    FIFO_DEPTH                    => FIFO_DEPTH(10),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(9),
    clk_en                        => clk_en(10),
    reset                         => reset,
    start                         => hashes_9_new,
    first_input                   => ZEROS_640,
    input                         => hashes_9,
    inc_nonce                     => open,
    hashes                        => hashes_10,
    hashes_new                    => hashes_10_new
  );

  msg_gen: process is
  begin
    wait until reset = '0';
    wait for 11 * TCLK_125;
    -- use clk_en corresponding to that used by hash_fn_set_0
    wait until clk_en(0) = '1';
    data_in                       <= X"efbeadde" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" &
                                     X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef"; 
    start                         <= "1";
    wait for 2 * TCLK_125;
    start                         <= "0";
    --wait until clk_en(2) = '1';
    --wait until clk_en(2) = '0';
    --wait until clk_en(2) = '1';
    --data_in                       <= X"5a5a5a5a" & X"01010101" & X"02020202" & X"03030303" & X"04040404" & X"05050505" & X"06060606" & X"07070707" & X"08080808" & X"09090909" &
    --                                 X"0a0a0a0a" & X"0b0b0b0b" & X"0c0c0c0c" & X"0d0d0d0d" & X"0e0e0e0e" & X"0f0f0f0f" & X"10101010" & X"20202020" & X"30303030" & X"40404040"; 
    --start                         <= "1";
    --wait for 2 * TCLK_125;
    --start                         <= "0";
  end process msg_gen;
  
  clk_gen: process is
  begin
      clk                         <= not clk;
      wait for TCLK_125/2;
  end process clk_gen;
  
end architecture hash_fn_set_tb_behav;