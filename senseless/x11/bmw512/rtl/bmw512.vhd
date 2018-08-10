--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bmw512 is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  data_in                               : in std_logic_vector(511 downto 0);
  hash                                  : out std_logic_vector(511 downto 0);
  hash_new                              : out std_logic
);
end entity bmw512;

architecture bmw512_rtl of bmw512 is
  
  alias slv is std_logic_vector;
  subtype word64 is slv(63 downto 0);
  type nat_array_16_16 is array(0 to 15, 0 to 15) of natural;
  type nat_array_16_7 is array(0 to 15, 0 to 6) of natural;
  type word64_array16 is array(0 to 15) of word64;
  type word64_array8 is array(0 to 7) of word64;
  type bmw512_state is (IDLE, HASH_COMP_F0, HASH_COMP_F1, HASH_COMP_F2,FINALIZATION_F0, FINALIZATION_F1, FINALIZATION_F2);
  
  component bmw512_f0 is
  port (
    clk                                 : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    m                                   : in std_logic_vector(1023 downto 0);
    h                                   : in std_logic_vector(1023 downto 0);
    qpa                                 : out std_logic_vector(1023 downto 0);
    qpa_new                             : out std_logic
  );
  end component bmw512_f0;

  component bmw512_f1 is
  port (
    clk                                 : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    m                                   : in std_logic_vector(1023 downto 0);
    h                                   : in std_logic_vector(1023 downto 0);
    qpa                                 : in std_logic_vector(1023 downto 0);
    qpb                                 : out std_logic_vector(1023 downto 0);
    qpb_new                             : out std_logic
  );
  end component bmw512_f1;

  component bmw512_f2 is
  port (
    clk                                 : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    m                                   : in std_logic_vector(1023 downto 0);
    qpa                                 : in std_logic_vector(1023 downto 0);
    qpb                                 : in std_logic_vector(1023 downto 0);
    h                                   : out std_logic_vector(1023 downto 0);
    h_new                               : out std_logic
  );
  end component bmw512_f2;
  
  constant I16                          : nat_array_16_16 := (( 0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15),
                                                              ( 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16),
                                                              ( 2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17),
                                                              ( 3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18),
                                                              ( 4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19),
                                                              ( 5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20),
                                                              ( 6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21),
                                                              ( 7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22),
                                                              ( 8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23),
                                                              ( 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24),
                                                              (10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25),
                                                              (11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26),
                                                              (12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27),
                                                              (13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28),
                                                              (14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29),
                                                              (15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30));
  constant M16                          : nat_array_16_7 := (( 0,  1,  3,  4,  7, 10, 11),
                                                             ( 1,  2,  4,  5,  8, 11, 12),
                                                             ( 2,  3,  5,  6,  9, 12, 13),
                                                             ( 3,  4,  6,  7, 10, 13, 14),
                                                             ( 4,  5,  7,  8, 11, 14, 15),
                                                             ( 5,  6,  8,  9, 12, 15, 16),
                                                             ( 6,  7,  9, 10, 13,  0,  1),
                                                             ( 7,  8, 10, 11, 14,  1,  2),
                                                             ( 8,  9, 11, 12, 15,  2,  3),
                                                             ( 9, 10, 12, 13,  0,  3,  4),
                                                             (10, 11, 13, 14,  1,  4,  5),
                                                             (11, 12, 14, 15,  2,  5,  6),
                                                             (12, 13, 15, 16,  3,  6,  7),
                                                             (13, 14,  0,  1,  4,  7,  8),
                                                             (14, 15,  1,  2,  5,  8,  9),
                                                             (15, 16,  2,  3,  6,  9, 10));
  constant IV                           : word64_array16 := (X"8081828384858687", X"88898A8B8C8D8E8F",
                                                             X"9091929394959697", X"98999A9B9C9D9E9F",
                                                             X"A0A1A2A3A4A5A6A7", X"A8A9AAABACADAEAF",
                                                             X"B0B1B2B3B4B5B6B7", X"B8B9BABBBCBDBEBF",
                                                             X"C0C1C2C3C4C5C6C7", X"C8C9CACBCCCDCECF",
                                                             X"D0D1D2D3D4D5D6D7", X"D8D9DADBDCDDDEDF",
                                                             X"E0E1E2E3E4E5E6E7", X"E8E9EAEBECEDEEEF",
                                                             X"F0F1F2F3F4F5F6F7", X"F8F9FAFBFCFDFEFF");
  constant FINAL                        : word64_array16 := (X"AAAAAAAAAAAAAAA0", X"AAAAAAAAAAAAAAA1",
                                                             X"AAAAAAAAAAAAAAA2", X"AAAAAAAAAAAAAAA3",
                                                             X"AAAAAAAAAAAAAAA4", X"AAAAAAAAAAAAAAA5",
                                                             X"AAAAAAAAAAAAAAA6", X"AAAAAAAAAAAAAAA7",
                                                             X"AAAAAAAAAAAAAAA8", X"AAAAAAAAAAAAAAA9",
                                                             X"AAAAAAAAAAAAAAAA", X"AAAAAAAAAAAAAAAB",
                                                             X"AAAAAAAAAAAAAAAC", X"AAAAAAAAAAAAAAAD",
                                                             X"AAAAAAAAAAAAAAAE", X"AAAAAAAAAAAAAAAF");
  constant PADDING                      : word64_array8 := (X"0000000000000080", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000200");

  signal bmw512_state_next              : bmw512_state;
  signal start_int                      : std_logic;
  signal f0_start                       : std_logic;
  signal data_in_array                  : word64_array8;
  signal f_m                            : word64_array16;
  signal f_h                            : word64_array16;
  signal f_m_vec                        : slv(1023 downto 0);
  signal f_h_vec                        : slv(1023 downto 0);
  signal m                              : word64_array16;
  signal h                              : word64_array16;
  signal h_vec                          : slv(1023 downto 0);
  signal h_new                          : std_logic;
  signal qpa                            : slv(1023 downto 0);
  signal qpa_new                        : std_logic;
  signal qpb                            : slv(1023 downto 0);
  signal qpb_new                        : std_logic;
  signal done                           : std_logic;
  
  signal q_bmw512_state                 : bmw512_state;
  signal q_m                            : word64_array16;
  
begin

  hash_new                              <= done;
  
  output_mapping : for i in 0 to 7 generate
    hash((i+1)*64-1 downto i*64)        <= h(i+8);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 7 generate
    data_in_array(i)                    <= data_in((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  sig_vec_mapping : for i in 0 to 15 generate
    f_m_vec((i+1)*64-1 downto i*64)     <= f_m(i);
    f_h_vec((i+1)*64-1 downto i*64)     <= f_h(i);
    h(i)                                <= h_vec((i+1)*64-1 downto i*64);
  end generate sig_vec_mapping;

  f0_start                              <= start or start_int;
  
  bmw512_f0_inst : bmw512_f0
  port map (
    clk                                 => clk,
    reset                               => reset,
    start                               => f0_start,
    m                                   => f_m_vec,
    h                                   => f_h_vec,
    qpa                                 => qpa,
    qpa_new                             => qpa_new
  );

  bmw512_f1_inst : bmw512_f1
  port map (
    clk                                 => clk,
    reset                               => reset,
    start                               => qpa_new,
    m                                   => f_m_vec,
    h                                   => f_h_vec, 
    qpa                                 => qpa,
    qpb                                 => qpb,
    qpb_new                             => qpb_new
  );

  bmw512_f2_inst : bmw512_f2
  port map (
    clk                                 => clk,
    reset                               => reset,
    start                               => qpb_new,
    m                                   => f_m_vec,
    qpa                                 => qpa,
    qpb                                 => qpb,
    h                                   => h_vec,
    h_new                               => h_new
  );
  
  bmw512_proc : process(q_bmw512_state, q_m, data_in_array, start, qpa_new, qpb_new, h_new, h)
  begin
    bmw512_state_next                   <= q_bmw512_state;
    m                                   <= q_m;
    f_m                                 <= q_m;
    f_h                                 <= IV;
    start_int                           <= '0';
    done                                <= '0';
    case q_bmw512_state is
    when IDLE =>
      for i in 0 to 7 loop
        m(i)                            <= data_in_array(i);
      end loop;
      for i in 8 to 15 loop
        m(i)                            <= PADDING(i-8);
      end loop;
      if start = '1' then
        bmw512_state_next               <= HASH_COMP_F0;
      end if;
    when HASH_COMP_F0 =>
      f_m                               <= q_m;
      f_h                               <= IV;
      if qpa_new = '1' then
        bmw512_state_next               <= HASH_COMP_F1;
      end if;
    when HASH_COMP_F1 =>
      f_m                               <= q_m;
      f_h                               <= IV;
      if qpb_new = '1' then
        bmw512_state_next               <= HASH_COMP_F2;
      end if;
    when HASH_COMP_F2 =>
      f_m                               <= q_m;
      if h_new = '1' then
        start_int                       <= '1';
        bmw512_state_next               <= FINALIZATION_F0;
      end if;
    when FINALIZATION_F0 =>
      f_m                               <= h;
      f_h                               <= FINAL;
      if qpa_new = '1' then
        bmw512_state_next               <= FINALIZATION_F1;
      end if;
    when FINALIZATION_F1   =>
      f_m                               <= h;
      f_h                               <= FINAL;
      if qpb_new = '1' then
        bmw512_state_next               <= FINALIZATION_F2;
      end if;
    when FINALIZATION_F2 =>
      f_m                               <= h;
      if h_new = '1' then
        done                            <= '1';
        bmw512_state_next               <= IDLE;
      end if;
    -- when FINISH =>
      -- done                              <= '1';
      -- bmw512_state_next                 <= IDLE;
    end case;
  end process bmw512_proc;

  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_bmw512_state                    <= IDLE;
    elsif rising_edge(clk) then
      q_bmw512_state                    <= bmw512_state_next;
      q_m                               <= m;
    end if;
  end process registers;
  
end architecture bmw512_rtl;