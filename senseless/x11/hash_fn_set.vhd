--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity hash_fn_set is
generic (
  FIRST_STAGE                           : boolean;
  HF_TYPE                               : string;
  HF_NUM_PREV                           : natural;
  HF_NUM                                : natural;
  FIFO_DEPTH                            : natural;
  DUMMY_DELAY                           : natural
);
port (
  clk                                   : in std_logic;
  clk_en_prev                           : in std_logic;
  clk_en                                : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic_vector(HF_NUM_PREV-1 downto 0);
  ready_next                            : in std_logic;
  data_in_first                         : in std_logic_vector(639 downto 0);
  data_in                               : in std_logic_vector(HF_NUM_PREV*544-1  downto 0);
  ready                                 : out std_logic;
  hashes                                : out std_logic_vector(HF_NUM*544-1 downto 0);
  hashes_new                            : out std_logic_vector(HF_NUM-1 downto 0);
  empty                                 : out std_logic
);
end entity hash_fn_set;

architecture hash_fn_set_rtl of hash_fn_set is
  
  alias slv is std_logic_vector;
  
  component priority_decoder is
  generic (
    REQ_W                               : natural := 32;
    OUT_W                               : natural := natural(CEIL(LOG2(real(32))))
  );
  port (
    req                                 : in std_logic_vector(REQ_W-1 downto 0);
    pdout                               : out std_logic_vector(OUT_W-1 downto 0);
    valid                               : out std_logic
  );
  end component priority_decoder;

  component fifo is
  generic (
    DEPTH                               : natural := 32;
    DATA_W                              : natural := 32;
    LOG2_DEPTH                          : natural := natural(CEIL(LOG2(real(32))))
  );
  port (
    clk                                 : in std_logic;
    reset                               : in std_logic;
    wr_en                               : in std_logic;
    rd_en                               : in std_logic;
    data_in                             : in std_logic_vector(DATA_W-1 downto 0);
    data_out                            : out std_logic_vector(DATA_W-1 downto 0);
    used                                : out std_logic_vector(LOG2_DEPTH-1 downto 0);
    empty                               : out std_logic;
    full                                : out std_logic
  );
  end component fifo;

  component dummy_hash_fn_first is
  generic (
    DELAY                               : natural := DUMMY_DELAY
  );
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pause                               : in std_logic;
    data_in                             : in std_logic_vector(639 downto 0);
    hash                                : out std_logic_vector(511 downto 0);
    hash_new                            : out std_logic;
    hash_almost_new                     : out std_logic;
    busy_n                              : out std_logic
  );
  end component dummy_hash_fn_first;
  
  component dummy_hash_fn is
  generic (
    DELAY                               : natural := DUMMY_DELAY
  );
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pause                               : in std_logic;
    data_in                             : in std_logic_vector(511 downto 0);
    hash                                : out std_logic_vector(511 downto 0);
    hash_new                            : out std_logic;
    hash_almost_new                     : out std_logic;
    busy_n                              : out std_logic
  );
  end component dummy_hash_fn;

  component blake512_4g_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pause                               : in std_logic;
    data_in                             : in std_logic_vector(639 downto 0);
    hash                                : out std_logic_vector(511 downto 0);
    hash_new                            : out std_logic;
    hash_almost_new                     : out std_logic;
    busy_n                              : out std_logic
  );
  end component blake512_4g_ce;

  component bmw512_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pause                               : in std_logic;
    data_in                             : in std_logic_vector(511 downto 0);
    hash                                : out std_logic_vector(511 downto 0);
    hash_new                            : out std_logic;
    hash_almost_new                     : out std_logic;
    busy_n                              : out std_logic
  );
  end component bmw512_ce;

  component groestl512_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pause                               : in std_logic;
    data_in                             : in std_logic_vector(511 downto 0);
    hash                                : out std_logic_vector(511 downto 0);
    hash_new                            : out std_logic;
    hash_almost_new                     : out std_logic;
    busy_n                              : out std_logic
  );
  end component groestl512_ce;

  component skein512_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pause                               : in std_logic;
    data_in                             : in std_logic_vector(511 downto 0);
    hash                                : out std_logic_vector(511 downto 0);
    hash_new                            : out std_logic;
    hash_almost_new                     : out std_logic;
    busy_n                              : out std_logic
  );
  end component skein512_ce;

  component jh512_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pause                               : in std_logic;
    data_in                             : in std_logic_vector(511 downto 0);
    hash                                : out std_logic_vector(511 downto 0);
    hash_new                            : out std_logic;
    hash_almost_new                     : out std_logic;
    busy_n                              : out std_logic
  );
  end component jh512_ce;

  component keccak512_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pause                               : in std_logic;
    data_in                             : in std_logic_vector(511 downto 0);
    hash                                : out std_logic_vector(511 downto 0);
    hash_new                            : out std_logic;
    hash_almost_new                     : out std_logic;
    busy_n                              : out std_logic
  );
  end component keccak512_ce;

  component luffa512_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pause                               : in std_logic;
    data_in                             : in std_logic_vector(511 downto 0);
    hash                                : out std_logic_vector(511 downto 0);
    hash_new                            : out std_logic;
    hash_almost_new                     : out std_logic;
    busy_n                              : out std_logic
  );
  end component luffa512_ce;

  component cubehash512_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pause                               : in std_logic;
    data_in                             : in std_logic_vector(511 downto 0);
    hash                                : out std_logic_vector(511 downto 0);
    hash_new                            : out std_logic;
    hash_almost_new                     : out std_logic;
    busy_n                              : out std_logic
  );
  end component cubehash512_ce;

  component shavite512_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pause                               : in std_logic;
    data_in                             : in std_logic_vector(511 downto 0);
    hash                                : out std_logic_vector(511 downto 0);
    hash_new                            : out std_logic;
    hash_almost_new                     : out std_logic;
    busy_n                              : out std_logic
  );
  end component shavite512_ce;

  component simd512_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pause                               : in std_logic;
    data_in                             : in std_logic_vector(511 downto 0);
    hash                                : out std_logic_vector(511 downto 0);
    hash_new                            : out std_logic;
    hash_almost_new                     : out std_logic;
    busy_n                              : out std_logic
  );
  end component simd512_ce;

  component echo512_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pause                               : in std_logic;
    data_in                             : in std_logic_vector(511 downto 0);
    hash                                : out std_logic_vector(511 downto 0);
    hash_new                            : out std_logic;
    hash_almost_new                     : out std_logic;
    busy_n                              : out std_logic
  );
  end component echo512_ce;  

  subtype word640 is slv(639 downto 0);
  subtype word608 is slv(607 downto 0);
  subtype word544 is slv(543 downto 0);
  subtype word512 is slv(511 downto 0);
  subtype word96 is slv(95 downto 0);
  subtype word32  is slv(31 downto 0);
  type data_in_array_type is array(HF_NUM_PREV-1 downto 0) of word544;
  type hash_array_type is array(HF_NUM-1 downto 0) of word512;
  type data_array_type is array(HF_NUM-1 downto 0) of word608;
  type nonce_array_type is array(HF_NUM-1 downto 0) of word32;
  type data_640_array_type is array(HF_NUM-1 downto 0) of word640;
  type data_512_array_type is array(HF_NUM-1 downto 0) of word512;

  constant ZEROS_96                     : word96 := (others => '0');
  constant FIFO_LOG2_DEPTH              : natural := natural(realmax(ceil(log2(real(FIFO_DEPTH))),1.0));
  constant IPD_OUT_W                    : natural := natural(realmax(CEIL(LOG2(real(HF_NUM_PREV))),1.0));
  constant HFPD_OUT_W                   : natural := natural(realmax(CEIL(LOG2(real(HF_NUM))),1.0));

  signal data_in_array                  : data_in_array_type;
  signal input_sel                      : slv(IPD_OUT_W-1 downto 0);
  signal input_sel_valid                : std_logic;
  signal hf_sel                         : slv(HFPD_OUT_W-1 downto 0);
  signal hf_sel_valid                   : std_logic;
  signal selected_data_in               : word544;
  signal start_clear_n                  : slv(HF_NUM_PREV-1 downto 0);
  signal fifo_wr_en                     : std_logic;
  signal fifo_rd_en                     : std_logic;
  signal fifo_data_out_640              : word640;
  alias fdo_640_data is fifo_data_out_640(607 downto 0);
  alias fdo_640_nonce is fifo_data_out_640(639 downto 608);
  signal fifo_data_out_544              : word544;
  alias fdo_544_hash is fifo_data_out_544(511 downto 0);
  alias fdo_544_nonce is fifo_data_out_544(543 downto 512);
  signal fdo_data                       : word608;
  signal fdo_nonce                      : word32;
  signal data_640_array                 : data_640_array_type;
  signal data_512_array                 : data_512_array_type;
  signal fifo_used                      : slv(FIFO_LOG2_DEPTH-1 downto 0);
  signal fifo_empty                     : std_logic;
  signal fifo_full                      : std_logic;
  signal fifo_almost_full               : std_logic;
  signal hf_start                       : slv(HF_NUM-1 downto 0);
  signal hash_array                     : hash_array_type;
  signal hashes_new_int                 : slv(HF_NUM-1 downto 0);
  signal hashes_almost_new_int          : slv(HF_NUM-1 downto 0);
  signal busy_n                         : slv(HF_NUM-1 downto 0);
  signal hashes_new_sel                 : slv(HFPD_OUT_W-1 downto 0);
  signal hashes_new_sel_valid           : std_logic;
  signal hashes_new_pd                  : slv(HF_NUM-1 downto 0);
  signal hf_wait                        : slv(HF_NUM-1 downto 0);

  signal q_start                        : slv(HF_NUM_PREV-1 downto 0);
  signal q_hf_start                     : slv(HF_NUM-1 downto 0);
  signal q_data_array                   : data_array_type;
  signal q_nonce_array                  : nonce_array_type;
  signal q_nonce_array_prev             : nonce_array_type;

begin

  ready                                 <= '0' when ((fifo_almost_full = '1' and fifo_wr_en = '1') or (fifo_full = '1' and fifo_rd_en = '0')) else '1';
  hashes_new                            <= hashes_new_pd;
  empty                                 <= fifo_empty;

  output_mapping : for i in 0 to HF_NUM - 1 generate
    hashes((i+1)*544-1 downto i*544)    <= q_nonce_array_prev(i) & hash_array(i);
  end generate output_mapping;

  input_mapping : for i in 0 to HF_NUM_PREV - 1 generate
    data_in_array(i)                    <= data_in((i+1)*544-1 downto i*544);
  end generate input_mapping;

  input_pd : priority_decoder
  generic map (
    REQ_W                               => HF_NUM_PREV,
    OUT_W                               => IPD_OUT_W
  )
  port map (
    req                                 => q_start,
    pdout                               => input_sel,
    valid                               => input_sel_valid
  );

  selected_data_in                      <= data_in_array(to_integer(unsigned(input_sel)));

  fifo_almost_full                      <= '1' when (unsigned(fifo_used) = FIFO_DEPTH-1) else '0';
  fifo_wr_en                            <= clk_en_prev when (input_sel_valid = '1' and fifo_full = '0') else '0';
  fifo_rd_en                            <= clk_en when hf_sel_valid = '1' and fifo_empty = '0' else '0';

  input_pd_proc : process (clk_en_prev, input_sel_valid, fifo_full, input_sel) is
  begin
    start_clear_n                       <= (others => '1');
    if clk_en_prev = '1' and input_sel_valid = '1' and fifo_full = '0' then
      start_clear_n(to_integer(unsigned(input_sel))) <= '0';
    end if;
  end process input_pd_proc;

  hf_pd : priority_decoder
  generic map (
    REQ_W                               => HF_NUM,
    OUT_W                               => HFPD_OUT_W
  )
  port map (
    req                                 => busy_n,
    pdout                               => hf_sel,
    valid                               => hf_sel_valid
  );

  hf_pd_proc : process (clk_en, hf_sel_valid, fifo_empty, hf_sel) is
  begin
    hf_start                            <= (others => '0');
    if clk_en = '1' and hf_sel_valid = '1' and fifo_empty = '0' then
      hf_start(to_integer(unsigned(hf_sel))) <= '1';
    end if;
  end process hf_pd_proc;

  first_stage_gen : if FIRST_STAGE = true generate

    fifo_inst : fifo
    generic map (
      DEPTH                             => FIFO_DEPTH,
      DATA_W                            => 640,
      LOG2_DEPTH                        => FIFO_LOG2_DEPTH
    )
    port map (
      clk                               => clk,
      reset                             => reset,
      wr_en                             => fifo_wr_en,
      rd_en                             => fifo_rd_en,
      data_in                           => data_in_first,
      data_out                          => fifo_data_out_640,
      used                              => fifo_used,
      empty                             => fifo_empty,
      full                              => fifo_full
    );

    fdo_data                            <= fdo_640_data;
    fdo_nonce                           <= fdo_640_nonce;

    hash_fn_gen : for i in 0 to HF_NUM - 1 generate

      data_640_array(i)                 <= q_nonce_array(i) & q_data_array(i);

      dummy_hf_gen : if HF_TYPE = "DUMMY" generate

        dummy_hash_fn_first_inst : dummy_hash_fn_first
        generic map (
          DELAY                         => DUMMY_DELAY
        )
        port map (
          clk                           => clk,
          clk_en                        => clk_en,
          reset                         => reset,
          start                         => q_hf_start(i),
          pause                         => hf_wait(i),
          data_in                       => data_640_array(i),
          hash                          => hash_array(i),
          hash_new                      => hashes_new_int(i),
          hash_almost_new               => hashes_almost_new_int(i),
          busy_n                        => busy_n(i)
        );

      end generate dummy_hf_gen;

      blake512_hf_gen : if HF_TYPE = "BLAKE512" generate

        blake512_inst : blake512_4g_ce
        port map (
          clk                           => clk,
          clk_en                        => clk_en,
          reset                         => reset,
          start                         => q_hf_start(i),
          pause                         => hf_wait(i),
          data_in                       => data_640_array(i),
          hash                          => hash_array(i),
          hash_new                      => hashes_new_int(i),
          hash_almost_new               => hashes_almost_new_int(i),
          busy_n                        => busy_n(i)
        );

      end generate blake512_hf_gen;

    end generate hash_fn_gen;

  end generate first_stage_gen;

  normal_stage_gen : if FIRST_STAGE = false generate

    fifo_inst : fifo
    generic map (
      DEPTH                             => FIFO_DEPTH,
      DATA_W                            => 544,
      LOG2_DEPTH                        => FIFO_LOG2_DEPTH
    )
    port map (
      clk                               => clk,
      reset                             => reset,
      wr_en                             => fifo_wr_en,
      rd_en                             => fifo_rd_en,
      data_in                           => selected_data_in,
      data_out                          => fifo_data_out_544,
      used                              => fifo_used,
      empty                             => fifo_empty,
      full                              => fifo_full
    );

    fdo_data                            <= ZEROS_96 & fdo_544_hash;
    fdo_nonce                           <= fdo_544_nonce;

    hash_fn_gen : for i in 0 to HF_NUM - 1 generate

      data_512_array(i)                 <= q_data_array(i)(511 downto 0);

      dummy_hf_gen : if HF_TYPE = "DUMMY" generate

        dummy_hash_fn_inst : dummy_hash_fn
        generic map (
          DELAY                         => DUMMY_DELAY
        )
        port map (
          clk                           => clk,
          clk_en                        => clk_en,
          reset                         => reset,
          start                         => q_hf_start(i),
          pause                         => hf_wait(i),
          data_in                       => data_512_array(i),
          hash                          => hash_array(i),
          hash_new                      => hashes_new_int(i),
          hash_almost_new               => hashes_almost_new_int(i),
          busy_n                        => busy_n(i)
        );

      end generate dummy_hf_gen;

      bmw512_hf_gen : if HF_TYPE = "BMW512" generate

        bmw512_inst : bmw512_ce
        port map (
          clk                           => clk,
          clk_en                        => clk_en,
          reset                         => reset,
          start                         => q_hf_start(i),
          pause                         => hf_wait(i),
          data_in                       => data_512_array(i),
          hash                          => hash_array(i),
          hash_new                      => hashes_new_int(i),
          hash_almost_new               => hashes_almost_new_int(i),
          busy_n                        => busy_n(i)
        );

      end generate bmw512_hf_gen;

      groestl512_hf_gen : if HF_TYPE = "GROESTL512" generate

        groestl512_inst : groestl512_ce
        port map (
          clk                           => clk,
          clk_en                        => clk_en,
          reset                         => reset,
          start                         => q_hf_start(i),
          pause                         => hf_wait(i),
          data_in                       => data_512_array(i),
          hash                          => hash_array(i),
          hash_new                      => hashes_new_int(i),
          hash_almost_new               => hashes_almost_new_int(i),
          busy_n                        => busy_n(i)
        );

      end generate groestl512_hf_gen;

      skein512_hf_gen : if HF_TYPE = "SKEIN512" generate

        skein512_inst : skein512_ce
        port map (
          clk                           => clk,
          clk_en                        => clk_en,
          reset                         => reset,
          start                         => q_hf_start(i),
          pause                         => hf_wait(i),
          data_in                       => data_512_array(i),
          hash                          => hash_array(i),
          hash_new                      => hashes_new_int(i),
          hash_almost_new               => hashes_almost_new_int(i),
          busy_n                        => busy_n(i)
        );

      end generate skein512_hf_gen;

      jh512_hf_gen : if HF_TYPE = "JH512" generate

        jh512_inst : jh512_ce
        port map (
          clk                           => clk,
          clk_en                        => clk_en,
          reset                         => reset,
          start                         => q_hf_start(i),
          pause                         => hf_wait(i),
          data_in                       => data_512_array(i),
          hash                          => hash_array(i),
          hash_new                      => hashes_new_int(i),
          hash_almost_new               => hashes_almost_new_int(i),
          busy_n                        => busy_n(i)
        );

      end generate jh512_hf_gen;

      keccak512_hf_gen : if HF_TYPE = "KECCAK512" generate

        keccak512_inst : keccak512_ce
        port map (
          clk                           => clk,
          clk_en                        => clk_en,
          reset                         => reset,
          start                         => q_hf_start(i),
          pause                         => hf_wait(i),
          data_in                       => data_512_array(i),
          hash                          => hash_array(i),
          hash_new                      => hashes_new_int(i),
          hash_almost_new               => hashes_almost_new_int(i),
          busy_n                        => busy_n(i)
        );

      end generate keccak512_hf_gen;

      luffa512_hf_gen : if HF_TYPE = "LUFFA512" generate

        luffa512_inst : luffa512_ce
        port map (
          clk                           => clk,
          clk_en                        => clk_en,
          reset                         => reset,
          start                         => q_hf_start(i),
          pause                         => hf_wait(i),
          data_in                       => data_512_array(i),
          hash                          => hash_array(i),
          hash_new                      => hashes_new_int(i),
          hash_almost_new               => hashes_almost_new_int(i),
          busy_n                        => busy_n(i)
        );

      end generate luffa512_hf_gen;

      cubehash512_hf_gen : if HF_TYPE = "CUBEHASH512" generate

        cubehash512_inst : cubehash512_ce
        port map (
          clk                           => clk,
          clk_en                        => clk_en,
          reset                         => reset,
          start                         => q_hf_start(i),
          pause                         => hf_wait(i),
          data_in                       => data_512_array(i),
          hash                          => hash_array(i),
          hash_new                      => hashes_new_int(i),
          hash_almost_new               => hashes_almost_new_int(i),
          busy_n                        => busy_n(i)
        );

      end generate cubehash512_hf_gen;

      shavite512_hf_gen : if HF_TYPE = "SHAVITE512" generate

        shavite512_inst : shavite512_ce
        port map (
          clk                           => clk,
          clk_en                        => clk_en,
          reset                         => reset,
          start                         => q_hf_start(i),
          pause                         => hf_wait(i),
          data_in                       => data_512_array(i),
          hash                          => hash_array(i),
          hash_new                      => hashes_new_int(i),
          hash_almost_new               => hashes_almost_new_int(i),
          busy_n                        => busy_n(i)
        );

      end generate shavite512_hf_gen;

      simd512_hf_gen : if HF_TYPE = "SIMD512" generate

        simd512_inst : simd512_ce
        port map (
          clk                           => clk,
          clk_en                        => clk_en,
          reset                         => reset,
          start                         => q_hf_start(i),
          pause                         => hf_wait(i),
          data_in                       => data_512_array(i),
          hash                          => hash_array(i),
          hash_new                      => hashes_new_int(i),
          hash_almost_new               => hashes_almost_new_int(i),
          busy_n                        => busy_n(i)
        );

      end generate simd512_hf_gen;

      echo512_hf_gen : if HF_TYPE = "ECHO512" generate

        echo512_inst : echo512_ce
        port map (
          clk                           => clk,
          clk_en                        => clk_en,
          reset                         => reset,
          start                         => q_hf_start(i),
          pause                         => hf_wait(i),
          data_in                       => data_512_array(i),
          hash                          => hash_array(i),
          hash_new                      => hashes_new_int(i),
          hash_almost_new               => hashes_almost_new_int(i),
          busy_n                        => busy_n(i)
        );

      end generate echo512_hf_gen;

    end generate hash_fn_gen;

  end generate normal_stage_gen;

  -- ensure only one hashes_new bit can be set at a time
  -- multiple hash functions can be ready to output results at the same time
  -- when the downstream fifo is full
  hf_hn_pd : priority_decoder
  generic map (
    REQ_W                               => HF_NUM,
    OUT_W                               => HFPD_OUT_W
  )
  port map (
    req                                 => hashes_new_int,
    pdout                               => hashes_new_sel,
    valid                               => hashes_new_sel_valid
  );

  hf_hn_proc : process (hashes_new_sel, hashes_new_sel_valid, ready_next) is
  begin
    hashes_new_pd                       <= (others => '0');
    hf_wait                             <= (others => '1');
    if hashes_new_sel_valid = '1' and ready_next = '1' then
      hashes_new_pd(to_integer(unsigned(hashes_new_sel))) <= '1';
      hf_wait(to_integer(unsigned(hashes_new_sel)))       <= '0';
    end if;
  end process hf_hn_proc;
  
  registers : process (clk, reset)
  begin
    if reset = '1' then
      q_start                           <= (others => '0');
    elsif rising_edge(clk) then
      q_start                           <= (start or q_start) and start_clear_n;
      if clk_en = '1' then
        q_hf_start                      <= hf_start;
        for i in 0 to HF_NUM - 1 loop
          if hashes_almost_new_int(i) = '1' then
            q_nonce_array_prev(i)       <= q_nonce_array(i);
          end if; 
          if hf_start(i) = '1' then
            q_nonce_array(i)            <= fdo_nonce;
            q_data_array(i)             <= fdo_data;
          end if;
        end loop;
      end if;
    end if;
  end process registers;
  
end architecture hash_fn_set_rtl;
  