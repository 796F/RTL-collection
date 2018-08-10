--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity x11_ctrl is
generic (
  CORE_NUM                        : natural;
  NUM_CORES                       : natural;
  HF_NUM_PREV                     : natural;
  FIFO_DEPTH                      : natural
);
port (
  clk                             : in std_logic;
  clk_en                          : in std_logic;
  reset                           : in std_logic;
  nonce_offset                    : in std_logic_vector(31 downto 0);
  difficulty                      : in std_logic_vector(31 downto 0);
  inc_nonce                       : in std_logic;
  hashes                          : in std_logic_vector(HF_NUM_PREV*544-1  downto 0);
  hashes_new                      : in std_logic_vector(HF_NUM_PREV-1 downto 0);
  gn_rd                           : in std_logic;
  x11c_start                      : out std_logic;
  nonce                           : out std_logic_vector(31 downto 0);
  nrie                            : out std_logic;
  fifo_ready                      : out std_logic;
  golden_nonce                    : out std_logic_vector(31 downto 0);
  gn_rdy                          : out std_logic
);
end entity x11_ctrl;

architecture x11_ctrl_rtl of x11_ctrl is
  
  alias slv is std_logic_vector;

  component priority_decoder is
  generic (
    REQ_W                         : natural := 32;
    OUT_W                         : natural := natural(CEIL(LOG2(real(32))))
  );
  port (
    req                           : in std_logic_vector(REQ_W-1 downto 0);
    pdout                         : out std_logic_vector(OUT_W-1 downto 0);
    valid                         : out std_logic
  );
  end component priority_decoder;

  component fifo is
  generic (
    DEPTH                         : natural := 32;
    DATA_W                        : natural := 32;
    LOG2_DEPTH                    : natural := natural(CEIL(LOG2(real(32))))
  );
  port (
    clk                           : in std_logic;
    reset                         : in std_logic;
    wr_en                         : in std_logic;
    rd_en                         : in std_logic;
    data_in                       : in std_logic_vector(DATA_W-1 downto 0);
    data_out                      : out std_logic_vector(DATA_W-1 downto 0);
    used                          : out std_logic_vector(LOG2_DEPTH-1 downto 0);
    empty                         : out std_logic;
    full                          : out std_logic
  );
  end component fifo;

  subtype word32 is slv(31 downto 0);
  subtype uword32 is unsigned(31 downto 0);
  type word32_array_type is array(HF_NUM_PREV-1 downto 0) of word32;
  type x11_ctrl_state is (IDLE, INIT, ENABLED, FINISH);

  constant NONCE_MAX              : uword32 := (others => '1');
  constant NONCE_LAST_OFFSET      : uword32 := NONCE_MAX - (NONCE_MAX mod NUM_CORES);
  constant NONCE_LAST             : uword32 := NONCE_LAST_OFFSET + CORE_NUM;
  constant FIFO_LOG2_DEPTH        : natural := natural(realmax(ceil(log2(real(FIFO_DEPTH))),1.0));
  constant IPD_OUT_W              : natural := natural(realmax(CEIL(LOG2(real(HF_NUM_PREV))),1.0));

  signal x11_ctrl_state_next      : x11_ctrl_state;
  signal nonce_next               : uword32;
  signal h32_array                : word32_array_type;
  signal nonce_array              : word32_array_type;
  signal input_sel                : slv(IPD_OUT_W-1 downto 0);
  signal input_sel_valid          : std_logic;
  signal selected_h32             : word32;
  signal selected_nonce           : word32;
  signal nonce_golden             : std_logic;
  signal start_clear_n            : slv(HF_NUM_PREV-1 downto 0);
  signal fifo_wr_en               : std_logic;
  signal fifo_used                : slv(FIFO_LOG2_DEPTH-1 downto 0);
  signal fifo_empty               : std_logic;
  signal fifo_full                : std_logic;
  signal fifo_almost_full         : std_logic;
  signal nrie_int                 : std_logic;

  signal q_x11_ctrl_state         : x11_ctrl_state;
  signal q_nonce                  : uword32;
  signal q_start                  : slv(HF_NUM_PREV-1 downto 0);

begin

  nonce                           <= slv(q_nonce);
  nrie                            <= nrie_int;
  fifo_ready                      <= '0' when ((fifo_almost_full = '1' and fifo_wr_en = '1') or (fifo_full = '1' and gn_rd = '0')) else '1';
  gn_rdy                          <= not fifo_empty;

  input_array_gen : for i in 0 to HF_NUM_PREV-1 generate
    h32_array(i)(31 downto 24)    <= hashes(i*544+7*32+7  downto i*544+7*32);
    h32_array(i)(23 downto 16)    <= hashes(i*544+7*32+15 downto i*544+7*32+8);
    h32_array(i)(15 downto 8)     <= hashes(i*544+7*32+23 downto i*544+7*32+16);
    h32_array(i)(7  downto 0)     <= hashes(i*544+7*32+31 downto i*544+7*32+24);
    nonce_array(i)                <= hashes(i*544+543     downto i*544+512);
  end generate input_array_gen;

  x11_ctrl_proc : process(q_x11_ctrl_state, q_nonce, nonce_offset, inc_nonce) is
  begin
    x11_ctrl_state_next           <= q_x11_ctrl_state;
    x11c_start                    <= '0';
    nonce_next                    <= q_nonce;
    nrie_int                      <= '0';
    case q_x11_ctrl_state is
    when IDLE =>
      nonce_next                  <= to_unsigned(CORE_NUM,32) + unsigned(nonce_offset);
      x11_ctrl_state_next         <= INIT;
    when INIT =>
      x11c_start                  <= '1';
      x11_ctrl_state_next         <= ENABLED;
    when ENABLED =>
      if q_nonce = NONCE_LAST then
        x11_ctrl_state_next       <= FINISH;
      elsif inc_nonce = '1' then
        nonce_next                <= q_nonce + 1;
        x11_ctrl_state_next       <= INIT;
      end if;
    when FINISH =>
      nrie_int                    <= '1';
    end case;
  end process x11_ctrl_proc;

  input_pd : priority_decoder
  generic map (
    REQ_W                         => HF_NUM_PREV,
    OUT_W                         => IPD_OUT_W
  )
  port map (
    req                           => q_start,
    pdout                         => input_sel,
    valid                         => input_sel_valid
  );

  selected_h32                    <= h32_array(to_integer(unsigned(input_sel)));
  selected_nonce                  <= nonce_array(to_integer(unsigned(input_sel)));

  fifo_almost_full                <= '1' when (unsigned(fifo_used) = FIFO_DEPTH-1) else '0';
  -- only store nonces corresponding to hash < difficulty
  nonce_golden                    <= '1' when (selected_h32 < difficulty) else '0';
  fifo_wr_en                      <= (clk_en and nonce_golden) when (input_sel_valid = '1' and fifo_full = '0') else '0';

  input_pd_proc : process (clk_en, input_sel_valid, fifo_full, input_sel) is
  begin
    start_clear_n                 <= (others => '1');
    if clk_en = '1' and input_sel_valid = '1' and fifo_full = '0' then
      start_clear_n(to_integer(unsigned(input_sel))) <= '0';
    end if;
  end process input_pd_proc;

  fifo_inst : fifo
  generic map (
    DEPTH                         => FIFO_DEPTH,
    DATA_W                        => 32,
    LOG2_DEPTH                    => FIFO_LOG2_DEPTH
  )
  port map (
    clk                           => clk,
    reset                         => reset,
    wr_en                         => fifo_wr_en,
    rd_en                         => gn_rd,
    data_in                       => selected_nonce,
    data_out                      => golden_nonce,
    used                          => fifo_used,
    empty                         => fifo_empty,
    full                          => fifo_full
  );

  registers : process (clk, reset)
  begin
    if reset = '1' then
      q_x11_ctrl_state            <= IDLE;
      q_start                     <= (others => '0');
    elsif rising_edge(clk) then
      q_x11_ctrl_state            <= x11_ctrl_state_next;
      q_nonce                     <= nonce_next;
      q_start                     <= (hashes_new or q_start) and start_clear_n;
    end if;
  end process registers;
  
end architecture x11_ctrl_rtl;
  