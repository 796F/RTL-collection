--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity x11_top is
generic (
  XT_NUM                        : natural := 0;
  NUM_GROUPS                    : natural := 1;
  NUM_CORES_PER_GROUP           : natural := 1
);
port (
  clk                           : in std_logic;
  reset                         : in std_logic;
  start                         : in std_logic;
  data_in                       : in std_logic;
  addr_in                       : in std_logic;
  rnw                           : in std_logic;
  data_out                      : out std_logic;
  data_out_valid                : out std_logic;
  gn_rdy                        : out std_logic
);
end entity x11_top;

architecture x11_top_rtl of x11_top is
  
  alias slv is std_logic_vector;
  
  component si_sg_addr_decode is
  generic (
    SG_NUM                      : natural := 0
  );
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    data_in                     : in std_logic;
    addr_in                     : in std_logic;
    rnw                         : in std_logic;
    golden_nonce                : in std_logic_vector(31 downto 0);
    data_out                    : out std_logic;
    data_out_valid              : out std_logic;
    enable                      : out std_logic;
    work                        : out std_logic_vector(607 downto 0);
    nonce_offset                : out std_logic_vector(31 downto 0);
    difficulty                  : out std_logic_vector(31 downto 0);
    gn_rd                       : out std_logic
  );
  end component si_sg_addr_decode;
  
  component fifo is
  generic (
    DEPTH                       : natural := 32;
    DATA_W                      : natural := 32;
    LOG2_DEPTH                  : natural := natural(CEIL(LOG2(real(32))))
  );
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    wr_en                       : in std_logic;
    rd_en                       : in std_logic;
    data_in                     : in std_logic_vector(DATA_W-1 downto 0);
    data_out                    : out std_logic_vector(DATA_W-1 downto 0);
    used                        : out std_logic_vector(LOG2_DEPTH-1 downto 0);
    empty                       : out std_logic;
    full                        : out std_logic
  );
  end component fifo;
  
  component priority_decoder is
  generic (
    REQ_W                       : natural := 32;
    OUT_W                       : natural := natural(CEIL(LOG2(real(32))))
  );
  port (
    req                         : in std_logic_vector(REQ_W-1 downto 0);
    pdout                       : out std_logic_vector(OUT_W-1 downto 0);
    valid                       : out std_logic
  );
  end component priority_decoder;
  
  component x11_core is
  port (
    clk                         : in std_logic;
    reset                       : in std_logic;
    start                       : in std_logic;
    input                       : in std_logic_vector(639 downto 0);
    inc_nonce                   : out std_logic;
    output                      : out std_logic_vector(31 downto 0);
    done                        : out std_logic
  );
  end component x11_core;
  
  constant NONCE_BASE           : natural := XT_NUM*NUM_CORES_PER_GROUP;
  constant LOG2_NCPG            : natural := natural(CEIL(LOG2(real(NUM_CORES_PER_GROUP))));
  constant FIFO_DEPTH           : natural := NUM_CORES_PER_GROUP;
  constant LOG2_FIFO_DEPTH      : natural := natural(realmax(CEIL(LOG2(real(FIFO_DEPTH))),1.0));
  
  type xt_ctrl_state is (IDLE, INIT, ENABLED);
  type fifo_ctrl_state is (IDLE, WRITE_FIFO);
  type word_array_type is array(NUM_CORES_PER_GROUP-1 downto 0) of slv(31 downto 0);
  type uword_array_type is array(NUM_CORES_PER_GROUP-1 downto 0) of unsigned(31 downto 0);
  type x11_input_type is array(NUM_CORES_PER_GROUP-1 downto 0) of slv(639 downto 0);
  
  signal xt_ctrl_state_next     : xt_ctrl_state;
  signal fifo_ctrl_state_next   : fifo_ctrl_state;
  signal reset_int              : std_logic;
  signal x11_start              : slv(NUM_CORES_PER_GROUP-1 downto 0);
  signal x11_input              : x11_input_type;
  --signal toggle_start           : slv(NUM_CORES_PER_GROUP-1 downto 0);
  signal write_nonce            : slv(NUM_CORES_PER_GROUP-1 downto 0);
  signal nonce_written          : slv(NUM_CORES_PER_GROUP-1 downto 0);
  signal nonce_array            : uword_array_type;
  signal enable                 : std_logic;
  signal work                   : slv(607 downto 0);
  signal nonce_offset           : slv(31 downto 0);
  signal difficulty             : slv(31 downto 0);
  signal fifo_wr_en             : std_logic;
  signal fifo_rd_en             : std_logic;
  signal fifo_data_in           : slv(31 downto 0);
  signal fifo_data_out          : slv(31 downto 0);
  signal fifo_used              : slv(LOG2_FIFO_DEPTH-1 downto 0);
  signal fifo_empty             : std_logic;
  signal fifo_full              : std_logic;
  signal nonce_sel              : slv(LOG2_NCPG-1 downto 0);
  signal nonce_sel_valid        : std_logic;
  signal x11_hash               : word_array_type;
  signal done                   : slv(NUM_CORES_PER_GROUP-1 downto 0);
  signal inc_nonce              : slv(NUM_CORES_PER_GROUP-1 downto 0);
  
  signal q_xt_ctrl_state        : xt_ctrl_state;
  signal q_fifo_ctrl_state      : fifo_ctrl_state;
  signal q_x11_start            : slv(NUM_CORES_PER_GROUP-1 downto 0);
  --signal q_toggle_start         : slv(NUM_CORES_PER_GROUP-1 downto 0);
  signal q_write_nonce          : slv(NUM_CORES_PER_GROUP-1 downto 0);
  signal q_nonce_written        : slv(NUM_CORES_PER_GROUP-1 downto 0);
  signal q_nonce_array          : uword_array_type;
  
begin

  reset_int                     <= reset or not enable;
  gn_rdy                        <= not fifo_empty;
  
  si_sg_addr_decode_inst : si_sg_addr_decode
  generic map (
    SG_NUM                      => XT_NUM
  )
  port map (
    clk                         => clk,
    reset                       => reset,
    start                       => start,
    data_in                     => data_in,
    addr_in                     => addr_in,
    rnw                         => rnw,
    golden_nonce                => fifo_data_out,
    data_out                    => data_out,
    data_out_valid              => data_out_valid,
    enable                      => enable,
    work                        => work,
    nonce_offset                => nonce_offset,
    difficulty                  => difficulty,
    gn_rd                       => fifo_rd_en
  );
  
  fifo_inst : fifo
  generic map (
    DEPTH                       => FIFO_DEPTH,
    DATA_W                      => 32,
    LOG2_DEPTH                  => LOG2_FIFO_DEPTH
  )
  port map (
    clk                         => clk,
    reset                       => reset_int,
    wr_en                       => fifo_wr_en,
    rd_en                       => fifo_rd_en,
    data_in                     => fifo_data_in,
    data_out                    => fifo_data_out,
    used                        => fifo_used,
    empty                       => fifo_empty,
    full                        => fifo_full
  );
  
  priority_decoder_inst : priority_decoder
  generic map (
    REQ_W                       => NUM_CORES_PER_GROUP,
    OUT_W                       => LOG2_NCPG
  )
  port map (
    req                         => q_write_nonce,
    pdout                       => nonce_sel,
    valid                       => nonce_sel_valid
  );
  
  fifo_ctrl : process(q_fifo_ctrl_state, nonce_sel_valid, q_nonce_array, nonce_sel)
  begin
    fifo_ctrl_state_next        <= q_fifo_ctrl_state;
    fifo_data_in                <= (others => '0');
    fifo_wr_en                  <= '0';
    nonce_written               <= (others => '0');
    case q_fifo_ctrl_state is
    when IDLE =>
      if nonce_sel_valid = '1' then
        fifo_data_in            <= slv(q_nonce_array(to_integer(unsigned(nonce_sel))));
        fifo_wr_en              <= '1';
        nonce_written(to_integer(unsigned(nonce_sel))) <= '1';
        fifo_ctrl_state_next    <= WRITE_FIFO;
      end if;
    when WRITE_FIFO =>
      fifo_ctrl_state_next      <= IDLE;
    when others =>
      null;
    end case;
  end process fifo_ctrl;
  
  x11_input(0)                  <= slv(q_nonce_array(0)) & work;
  x11_core_inst : x11_core
  port map (
    clk                         => clk,
    reset                       => reset_int,
    start                       => q_x11_start(0),
    input                       => x11_input(0),
    inc_nonce                   => inc_nonce(0),
    output                      => x11_hash(0),
    done                        => done(0)
  );
  
  x11_top_ctrl : process(q_xt_ctrl_state, q_nonce_array, q_write_nonce, nonce_offset, done, x11_hash,
                         difficulty, q_nonce_written, inc_nonce, enable)
  begin
    xt_ctrl_state_next          <= q_xt_ctrl_state;
    nonce_array                 <= q_nonce_array;
    x11_start                   <= (others => '0');
    --toggle_start                <= (others => '0');
    write_nonce                 <= q_write_nonce;
    case q_xt_ctrl_state is
    when IDLE =>
      for i in NUM_CORES_PER_GROUP-1 downto 0 loop
        nonce_array(i)          <= to_unsigned(NONCE_BASE,32) + i + unsigned(nonce_offset);
      end loop;
      xt_ctrl_state_next        <= INIT;
    when INIT =>
      x11_start                 <= (others => '1');
      xt_ctrl_state_next        <= ENABLED;
    when ENABLED =>
      for i in NUM_CORES_PER_GROUP-1 downto 0 loop
        if done(i) = '1' and (x11_hash(i) < difficulty) then
            write_nonce(i)      <= '1';
        elsif q_nonce_written(i) = '1' then
            write_nonce(i)      <= '0';
        end if;
        if inc_nonce(i) = '1' and q_write_nonce(i) = '0' then
          nonce_array(i)        <= q_nonce_array(i) + NUM_GROUPS*NUM_CORES_PER_GROUP;
          --toggle_start(i)       <= '1';
        end if;
        -- if q_toggle_start(i) = '1' then
          -- x11_start(i)       <= '1';
        -- end if;
      end loop;
      if enable = '0' then
        xt_ctrl_state_next      <= IDLE;
      end if;
    end case;
  end process x11_top_ctrl;
  
  registers : process (clk, reset)
  begin
    if reset_int = '1' then
      q_xt_ctrl_state           <= IDLE;
      q_fifo_ctrl_state         <= IDLE;
      q_x11_start               <= (others => '0');
      --q_toggle_start            <= (others => '0');
      q_write_nonce             <= (others => '0');
      q_nonce_written           <= (others => '0');
    elsif rising_edge(clk) then
      q_xt_ctrl_state           <= xt_ctrl_state_next;
      q_fifo_ctrl_state         <= fifo_ctrl_state_next;
      q_x11_start               <= x11_start;
      --q_toggle_start            <= toggle_start;
      q_write_nonce             <= write_nonce;
      q_nonce_written           <= nonce_written;
      q_nonce_array             <= nonce_array;
    end if;
  end process registers;
  
end architecture x11_top_rtl;