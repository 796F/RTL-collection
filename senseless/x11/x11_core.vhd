--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity x11_core is
generic (
  CORE_NUM                        : natural := 0;
  NUM_CORES                       : natural := 1
);
port (
  clk                             : in std_logic;
  reset                           : in std_logic;
  start                           : in std_logic;
  data_in                         : in std_logic;
  addr_in                         : in std_logic;
  rnw                             : in std_logic;
  data_out                        : out std_logic;
  data_out_valid                  : out std_logic;
  gn_rdy                          : out std_logic;
  nre                             : out std_logic
);
end entity x11_core;

architecture x11_core_rtl of x11_core is
  
  alias slv is std_logic_vector;

  component si_sg_addr_decode is
  generic (
    SG_NUM                        : natural := 0
  );
  port (
    clk                           : in std_logic;
    reset                         : in std_logic;
    start                         : in std_logic;
    data_in                       : in std_logic;
    addr_in                       : in std_logic;
    rnw                           : in std_logic;
    golden_nonce                  : in std_logic_vector(31 downto 0);
    data_out                      : out std_logic;
    data_out_valid                : out std_logic;
    enable                        : out std_logic;
    work                          : out std_logic_vector(607 downto 0);
    nonce_offset                  : out std_logic_vector(31 downto 0);
    difficulty                    : out std_logic_vector(31 downto 0);
    gn_rd                         : out std_logic
  );
  end component si_sg_addr_decode;

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

  component x11_ctrl is
  generic (
    CORE_NUM                      : natural;
    NUM_CORES                     : natural;
    HF_NUM_PREV                   : natural;
    FIFO_DEPTH                    : natural
  );
  port (
    clk                           : in std_logic;
    clk_en                        : in std_logic;
    reset                         : in std_logic;
    nonce_offset                  : in std_logic_vector(31 downto 0);
    difficulty                    : in std_logic_vector(31 downto 0);
    inc_nonce                     : in std_logic;
    hashes                        : in std_logic_vector(HF_NUM_PREV*544-1  downto 0);
    hashes_new                    : in std_logic_vector(HF_NUM_PREV-1 downto 0);
    gn_rd                         : in std_logic;
    x11c_start                    : out std_logic;
    nonce                         : out std_logic_vector(31 downto 0);
    nrie                          : out std_logic;
    fifo_ready                    : out std_logic;
    golden_nonce                  : out std_logic_vector(31 downto 0);
    gn_rdy                        : out std_logic
  );
  end component x11_ctrl;
  
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
    ready_next                    : in std_logic;
    data_in_first                 : in std_logic_vector(639 downto 0);
    data_in                       : in std_logic_vector(HF_NUM_PREV*544-1  downto 0);
    ready                         : out std_logic;
    hashes                        : out std_logic_vector(HF_NUM*544-1 downto 0);
    hashes_new                    : out std_logic_vector(HF_NUM-1 downto 0);
    empty                         : out std_logic
  );
  end component hash_fn_set;
  
  subtype word32 is slv(31 downto 0);

  constant NUM_STAGES             : natural := 11;

  type nat_array is array(0 to NUM_STAGES-1) of natural;
  type nat_array_2 is array(0 to NUM_STAGES) of natural;

  --constant HF_NUM_PREV            : nat_array := (1,1,2,3,2,1,1,1,1,1,1);
  --constant HF_NUM                 : nat_array := (1,2,3,2,1,1,1,1,1,1,1);
  constant HF_NUM_PREV            : nat_array := (1,1,1,1,1,1,1,1,1,1,1);
  constant HF_NUM                 : nat_array := (1,1,1,1,1,1,1,1,1,1,1);
  constant FIFO_DEPTH             : nat_array_2 := (2,2,2,2,2,2,2,2,2,2,2,2);
  constant ZEROS_640              : slv(639 downto 0) := (others => '0');
  constant ZEROS_544              : slv(543 downto 0) := (others => '0');
  constant ONES_NUM_STAGES        : slv(NUM_STAGES-1 downto 0) := (others => '1');

  signal clk_en                   : slv(NUM_STAGES-1 downto 0);
  signal x11c_start               : std_logic;
  signal x11c_start_slv           : slv(HF_NUM_PREV(0)-1 downto 0);
  signal nonce                    : word32;
  signal nonce_offset             : word32;
  signal golden_nonce             : word32;
  signal difficulty               : word32;
  signal nrie                     : std_logic;
  signal enable                   : std_logic;
  signal work                     : slv(607 downto 0);
  signal gn_rd                    : std_logic;
  signal gn_rdy_int               : std_logic;
  signal nonce_work               : slv(639 downto 0);
  signal ready_int                : slv(NUM_STAGES downto 0);
  signal empty                    : slv(NUM_STAGES-1 downto 0);
  signal hashes_0                 : slv(HF_NUM(0)*544-1 downto 0);
  signal hashes_0_new             : slv(HF_NUM(0)-1 downto 0);
  signal hashes_1                 : slv(HF_NUM(1)*544-1 downto 0);
  signal hashes_1_new             : slv(HF_NUM(1)-1 downto 0);
  signal hashes_2                 : slv(HF_NUM(2)*544-1 downto 0);
  signal hashes_2_new             : slv(HF_NUM(2)-1 downto 0);
  signal hashes_3                 : slv(HF_NUM(3)*544-1 downto 0);
  signal hashes_3_new             : slv(HF_NUM(3)-1 downto 0);
  signal hashes_4                 : slv(HF_NUM(4)*544-1 downto 0);
  signal hashes_4_new             : slv(HF_NUM(4)-1 downto 0);
  signal hashes_5                 : slv(HF_NUM(5)*544-1 downto 0);
  signal hashes_5_new             : slv(HF_NUM(5)-1 downto 0);
  signal hashes_6                 : slv(HF_NUM(6)*544-1 downto 0);
  signal hashes_6_new             : slv(HF_NUM(6)-1 downto 0);
  signal hashes_7                 : slv(HF_NUM(7)*544-1 downto 0);
  signal hashes_7_new             : slv(HF_NUM(7)-1 downto 0);
  signal hashes_8                 : slv(HF_NUM(8)*544-1 downto 0);
  signal hashes_8_new             : slv(HF_NUM(8)-1 downto 0);
  signal hashes_9                 : slv(HF_NUM(9)*544-1 downto 0);
  signal hashes_9_new             : slv(HF_NUM(9)-1 downto 0);
  signal hashes_10                : slv(HF_NUM(10)*544-1 downto 0);
  signal hashes_10_new            : slv(HF_NUM(10)-1 downto 0);

  signal q_reset_int              : std_logic;

begin

  gn_rdy                          <= gn_rdy_int;               
  nre                             <= '1' when (nrie = '1') and (gn_rdy_int = '0') and (empty = ONES_NUM_STAGES) else '0';

  si_sg_addr_decode_inst : si_sg_addr_decode
  generic map (
    SG_NUM                        => CORE_NUM
  )
  port map (
    clk                           => clk,
    reset                         => reset,
    start                         => start,
    data_in                       => data_in,
    addr_in                       => addr_in,
    rnw                           => rnw,
    golden_nonce                  => golden_nonce,
    data_out                      => data_out,
    data_out_valid                => data_out_valid,
    enable                        => enable,
    work                          => work,
    nonce_offset                  => nonce_offset,
    difficulty                    => difficulty,
    gn_rd                         => gn_rd
  );

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
    reset                         => q_reset_int,
    clk_en                        => clk_en
  );

  x11_ctrl_inst : x11_ctrl
  generic map (
    CORE_NUM                      => CORE_NUM,
    NUM_CORES                     => NUM_CORES,
    HF_NUM_PREV                   => HF_NUM(10),
    FIFO_DEPTH                    => FIFO_DEPTH(11)
  )
  port map (
    clk                           => clk,
    clk_en                        => clk_en(10),
    reset                         => q_reset_int,
    nonce_offset                  => nonce_offset,
    difficulty                    => difficulty,
    inc_nonce                     => ready_int(0),
    hashes_new                    => hashes_10_new,
    hashes                        => hashes_10,
    gn_rd                         => gn_rd,
    x11c_start                    => x11c_start,
    nonce                         => nonce,
    nrie                          => nrie,
    fifo_ready                    => ready_int(11),
    golden_nonce                  => golden_nonce,
    gn_rdy                        => gn_rdy_int
  );

  nonce_work                      <= nonce & work;
  x11c_start_slv                  <= (others => x11c_start);

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
    reset                         => q_reset_int,
    start                         => x11c_start_slv,
    ready_next                    => ready_int(1),
    data_in_first                 => nonce_work,
    data_in                       => ZEROS_544,
    ready                         => ready_int(0),
    hashes                        => hashes_0,
    hashes_new                    => hashes_0_new,
    empty                         => empty(0)
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
    reset                         => q_reset_int,
    start                         => hashes_0_new,
    ready_next                    => ready_int(2),
    data_in_first                 => ZEROS_640,
    data_in                       => hashes_0,
    ready                         => ready_int(1),
    hashes                        => hashes_1,
    hashes_new                    => hashes_1_new,
    empty                         => empty(1)
  );

  hash_fn_set_2 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "GROESTL512",
    HF_NUM_PREV                   => HF_NUM_PREV(2),
    HF_NUM                        => HF_NUM(2),
    FIFO_DEPTH                    => FIFO_DEPTH(2),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(1),
    clk_en                        => clk_en(2),
    reset                         => q_reset_int,
    start                         => hashes_1_new,
    ready_next                    => ready_int(3),
    data_in_first                 => ZEROS_640,
    data_in                       => hashes_1,
    ready                         => ready_int(2),
    hashes                        => hashes_2,
    hashes_new                    => hashes_2_new,
    empty                         => empty(2)
  );  

  hash_fn_set_3 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "SKEIN512",
    HF_NUM_PREV                   => HF_NUM_PREV(3),
    HF_NUM                        => HF_NUM(3),
    FIFO_DEPTH                    => FIFO_DEPTH(3),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(2),
    clk_en                        => clk_en(3),
    reset                         => q_reset_int,
    start                         => hashes_2_new,
    ready_next                    => ready_int(4),
    data_in_first                 => ZEROS_640,
    data_in                       => hashes_2,
    ready                         => ready_int(3),
    hashes                        => hashes_3,
    hashes_new                    => hashes_3_new,
    empty                         => empty(3)
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
    reset                         => q_reset_int,
    start                         => hashes_3_new,
    ready_next                    => ready_int(5),
    data_in_first                 => ZEROS_640,
    data_in                       => hashes_3,
    ready                         => ready_int(4),
    hashes                        => hashes_4,
    hashes_new                    => hashes_4_new,
    empty                         => empty(4)
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
    reset                         => q_reset_int,
    start                         => hashes_4_new,
    ready_next                    => ready_int(6),
    data_in_first                 => ZEROS_640,
    data_in                       => hashes_4,
    ready                         => ready_int(5),
    hashes                        => hashes_5,
    hashes_new                    => hashes_5_new,
    empty                         => empty(5)
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
    reset                         => q_reset_int,
    start                         => hashes_5_new,
    ready_next                    => ready_int(7),
    data_in_first                 => ZEROS_640,
    data_in                       => hashes_5,
    ready                         => ready_int(6),
    hashes                        => hashes_6,
    hashes_new                    => hashes_6_new,
    empty                         => empty(6)
  );

  hash_fn_set_7 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "CUBEHASH512",
    HF_NUM_PREV                   => HF_NUM_PREV(7),
    HF_NUM                        => HF_NUM(7),
    FIFO_DEPTH                    => FIFO_DEPTH(7),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(6),
    clk_en                        => clk_en(7),
    reset                         => q_reset_int,
    start                         => hashes_6_new,
    ready_next                    => ready_int(8),
    data_in_first                 => ZEROS_640,
    data_in                       => hashes_6,
    ready                         => ready_int(7),
    hashes                        => hashes_7,
    hashes_new                    => hashes_7_new,
    empty                         => empty(7)
  );

  hash_fn_set_8 : hash_fn_set
  generic map (
    FIRST_STAGE                   => false,
    HF_TYPE                       => "SHAVITE512",
    HF_NUM_PREV                   => HF_NUM_PREV(8),
    HF_NUM                        => HF_NUM(8),
    FIFO_DEPTH                    => FIFO_DEPTH(8),
    DUMMY_DELAY                   => 0
  )
  port map (
    clk                           => clk,
    clk_en_prev                   => clk_en(7),
    clk_en                        => clk_en(8),
    reset                         => q_reset_int,
    start                         => hashes_7_new,
    ready_next                    => ready_int(9),
    data_in_first                 => ZEROS_640,
    data_in                       => hashes_7,
    ready                         => ready_int(8),
    hashes                        => hashes_8,
    hashes_new                    => hashes_8_new,
    empty                         => empty(8)
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
    reset                         => q_reset_int,
    start                         => hashes_8_new,
    ready_next                    => ready_int(10),
    data_in_first                 => ZEROS_640,
    data_in                       => hashes_8,
    ready                         => ready_int(9),
    hashes                        => hashes_9,
    hashes_new                    => hashes_9_new,
    empty                         => empty(9)
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
    reset                         => q_reset_int,
    start                         => hashes_9_new,
    ready_next                    => ready_int(11),
    data_in_first                 => ZEROS_640,
    data_in                       => hashes_9,
    ready                         => ready_int(10),
    hashes                        => hashes_10,
    hashes_new                    => hashes_10_new,
    empty                         => empty(10)
  );

  registers : process (clk)
  begin
    if rising_edge(clk) then
      q_reset_int                 <= reset or not enable;
    end if;
  end process registers;
  
end architecture x11_core_rtl;
  