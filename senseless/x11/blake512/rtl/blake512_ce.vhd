--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blake512_ce is
port (
  clk                                   : in std_logic;
  clk_en                                : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  data_in                               : in std_logic_vector(639 downto 0);
  hash                                  : out std_logic_vector(511 downto 0);
  hash_new                              : out std_logic
);
end entity blake512_ce;

architecture blake512_ce_rtl of blake512_ce is
  
  alias slv is std_logic_vector;
  
  component g_comp_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    m0                                  : in std_logic_vector(63 downto 0);
    m1                                  : in std_logic_vector(63 downto 0);
    c0                                  : in std_logic_vector(63 downto 0);
    c1                                  : in std_logic_vector(63 downto 0);
    a                                   : in std_logic_vector(63 downto 0);
    b                                   : in std_logic_vector(63 downto 0);
    c                                   : in std_logic_vector(63 downto 0);
    d                                   : in std_logic_vector(63 downto 0);
    a_out                               : out std_logic_vector(63 downto 0);
    b_out                               : out std_logic_vector(63 downto 0);
    c_out                               : out std_logic_vector(63 downto 0);
    d_out                               : out std_logic_vector(63 downto 0)
  );
  end component g_comp_ce;
  
  subtype word64 is slv(63 downto 0);
  type nat_array_16_16 is array(0 to 15, 0 to 15) of natural;
  type nat_array_8 is array(0 to 7) of natural;
  type word64_array16 is array(0 to 15) of word64;
  type word64_array10 is array(0 to 9) of word64;
  type word64_array8 is array(0 to 7) of word64;
  type word64_array6 is array(0 to 5) of word64;
  type word64_array4 is array(0 to 3) of word64;
  type word64_array2 is array(0 to 1) of word64;
  type blake512_state is (IDLE, EXEC_ROUNDS, FINISH);
  
  constant SIGMA                        : nat_array_16_16 := ( (  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15 ),
                                                               ( 14, 10,  4,  8,  9, 15, 13,  6,  1, 12,  0,  2, 11,  7,  5,  3 ),
                                                               ( 11,  8, 12,  0,  5,  2, 15, 13, 10, 14,  3,  6,  7,  1,  9,  4 ),
                                                               (  7,  9,  3,  1, 13, 12, 11, 14,  2,  6,  5, 10,  4,  0, 15,  8 ),
                                                               (  9,  0,  5,  7,  2,  4, 10, 15, 14,  1, 11, 12,  6,  8,  3, 13 ),
                                                               (  2, 12,  6, 10,  0, 11,  8,  3,  4, 13,  7,  5, 15, 14,  1,  9 ),
                                                               ( 12,  5,  1, 15, 14, 13,  4, 10,  0,  7,  6,  3,  9,  2,  8, 11 ),
                                                               ( 13, 11,  7, 14, 12,  1,  3,  9,  5,  0, 15,  4,  8,  6,  2, 10 ),
                                                               (  6, 15, 14,  9, 11,  3,  0,  8, 12,  2, 13,  7,  1,  4, 10,  5 ),
                                                               ( 10,  2,  8,  4,  7,  6,  1,  5, 15, 11,  9, 14,  3, 12, 13,  0 ),
                                                               (  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15 ),
                                                               ( 14, 10,  4,  8,  9, 15, 13,  6,  1, 12,  0,  2, 11,  7,  5,  3 ),
                                                               ( 11,  8, 12,  0,  5,  2, 15, 13, 10, 14,  3,  6,  7,  1,  9,  4 ),
                                                               (  7,  9,  3,  1, 13, 12, 11, 14,  2,  6,  5, 10,  4,  0, 15,  8 ),
                                                               (  9,  0,  5,  7,  2,  4, 10, 15, 14,  1, 11, 12,  6,  8,  3, 13 ),
                                                               (  2, 12,  6, 10,  0, 11,  8,  3,  4, 13,  7,  5, 15, 14,  1,  9 ) );
  constant IV512                        : word64_array8 := (X"6A09E667F3BCC908", X"BB67AE8584CAA73B",
                                                            X"3C6EF372FE94F82B", X"A54FF53A5F1D36F1",
                                                            X"510E527FADE682D1", X"9B05688C2B3E6C1F",
                                                            X"1F83D9ABFB41BD6B", X"5BE0CD19137E2179");
  constant C                            : word64_array16 := (X"243F6A8885A308D3", X"13198A2E03707344",
                                                             X"A4093822299F31D0", X"082EFA98EC4E6C89",
                                                             X"452821E638D01377", X"BE5466CF34E90C6C",
                                                             X"C0AC29B7C97C50DD", X"3F84D5B5B5470917",
                                                             X"9216D5D98979FB1B", X"D1310BA698DFB5AC",
                                                             X"2FFD72DBD01ADFB7", X"B8E1AFED6A267E96",
                                                             X"BA7C9045F12C7F99", X"24A19947B3916CF7",
                                                             X"0801F2E2858EFC16", X"636920D871574E69");
  constant PADDING                      : word64_array6 := (X"8000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000001",
                                                            X"0000000000000000", X"0000000000000280");
  constant T                            : word64_array2 := (X"0000000000000280", X"0000000000000000");
  constant A_IND                        : nat_array_8 := ( 0,  1,  2,  3,  0,  1,  2,  3);
  constant B_IND                        : nat_array_8 := ( 4,  5,  6,  7,  5,  6,  7,  4);
  constant C_IND                        : nat_array_8 := ( 8,  9, 10, 11, 10, 11,  8,  9);
  constant D_IND                        : nat_array_8 := (12, 13, 14, 15, 15, 12, 13, 14);

  signal blake512_state_next            : blake512_state;
  signal data_in_ec                     : slv(639 downto 0);
  signal data_in_array                  : word64_array10;
  signal init_v                         : std_logic;
  signal v0                             : word64_array16;
  signal v1                             : word64_array16;
  signal v2                             : word64_array16;
  signal m                              : word64_array16;
  signal hash_int                       : slv(511 downto 0);
  signal hash_ec                        : slv(511 downto 0);
  signal done                           : std_logic;
  signal h                              : word64_array8;
  signal round_start                    : std_logic;
  signal round_en                       : std_logic;
  signal gc_0_3_m0                      : word64_array4;
  signal gc_0_3_m1                      : word64_array4;
  signal gc_0_3_c0                      : word64_array4;
  signal gc_0_3_c1                      : word64_array4;
  signal gc_4_7_m0                      : word64_array4;
  signal gc_4_7_m1                      : word64_array4;
  signal gc_4_7_c0                      : word64_array4;
  signal gc_4_7_c1                      : word64_array4;
  
  signal q_blake512_state               : blake512_state;
  signal q_v                            : word64_array16;
  signal q_m                            : word64_array16;
  signal q_done                         : std_logic;
  signal q_h                            : word64_array8;
  signal q_round                        : unsigned(4 downto 0);
  
begin

  hash                                  <= hash_ec;
  hash_new                              <= q_done;

  -- output endian conversion
  output_end_conv : for i in 7 downto 0 generate
    hash_ec(i*64+23  downto i*64+16)    <= hash_int(i*64+47  downto i*64+40);
    hash_ec(i*64+31  downto i*64+24)    <= hash_int(i*64+39  downto i*64+32);
    hash_ec(i*64+7   downto i*64)       <= hash_int(i*64+63  downto i*64+56);
    hash_ec(i*64+15  downto i*64+8)     <= hash_int(i*64+55  downto i*64+48);
    hash_ec(i*64+55  downto i*64+48)    <= hash_int(i*64+15  downto i*64+8);
    hash_ec(i*64+63  downto i*64+56)    <= hash_int(i*64+7   downto i*64);
    hash_ec(i*64+39  downto i*64+32)    <= hash_int(i*64+31  downto i*64+24);    
    hash_ec(i*64+47  downto i*64+40)    <= hash_int(i*64+23  downto i*64+16);
  end generate output_end_conv;
  
  output_mapping : for i in 0 to 7 generate
    hash_int((i+1)*64-1 downto i*64)    <= q_h(i);
  end generate output_mapping;

  -- input endian conversion
  input_end_conv : for i in 17 downto 0 generate
    data_in_ec(i*32+7  downto i*32)     <= data_in(i*32+31 downto i*32+24);
    data_in_ec(i*32+15 downto i*32+8)   <= data_in(i*32+23 downto i*32+16);
    data_in_ec(i*32+23 downto i*32+16)  <= data_in(i*32+15 downto i*32+8);
    data_in_ec(i*32+31 downto i*32+24)  <= data_in(i*32+7  downto i*32);
  end generate input_end_conv;
  
  -- big endian conversion inhibited for nonce
  data_in_ec(639 downto 576)            <= data_in(639 downto 576);
  
  input_mapping : for i in 0 to 9 generate
    data_in_array(i)                    <= data_in_ec((i+1)*64-1 downto i*64);
  end generate input_mapping;

  g_comp_gen : for i in 0 to 3 generate

    gc_0_3_m0(i)                        <= q_m(SIGMA(to_integer(q_round),i*2));
    gc_0_3_m1(i)                        <= q_m(SIGMA(to_integer(q_round),i*2+1));
    gc_0_3_c0(i)                        <= C(SIGMA(to_integer(q_round),i*2));
    gc_0_3_c1(i)                        <= C(SIGMA(to_integer(q_round),i*2+1));
  
    g_comp_0_to_3 : g_comp_ce
    port map (
      clk                               => '0', -- unused currently
      clk_en                            => '0', -- unused currently
      reset                             => '0', -- unused currently
      start                             => '0', -- unused currently
      m0                                => gc_0_3_m0(i),
      m1                                => gc_0_3_m1(i),
      c0                                => gc_0_3_c0(i),
      c1                                => gc_0_3_c1(i),
      a                                 => q_v(A_IND(i)),
      b                                 => q_v(B_IND(i)),
      c                                 => q_v(C_IND(i)),
      d                                 => q_v(D_IND(i)),
      a_out                             => v1(A_IND(i)),
      b_out                             => v1(B_IND(i)),
      c_out                             => v1(C_IND(i)),
      d_out                             => v1(D_IND(i))
    );
    
    gc_4_7_m0(i)                        <= q_m(SIGMA(to_integer(q_round),(i+4)*2));
    gc_4_7_m1(i)                        <= q_m(SIGMA(to_integer(q_round),(i+4)*2+1));
    gc_4_7_c0(i)                        <= C(SIGMA(to_integer(q_round),(i+4)*2));
    gc_4_7_c1(i)                        <= C(SIGMA(to_integer(q_round),(i+4)*2+1));

    g_comp_4_to_7 : g_comp_ce
    port map (
      clk                               => '0', -- unused currently
      clk_en                            => '0', -- unused currently
      reset                             => '0', -- unused currently
      start                             => '0', -- unused currently
      m0                                => gc_4_7_m0(i),
      m1                                => gc_4_7_m1(i),
      c0                                => gc_4_7_c0(i),
      c1                                => gc_4_7_c1(i),
      a                                 => v1(A_IND(i+4)),
      b                                 => v1(B_IND(i+4)),
      c                                 => v1(C_IND(i+4)),
      d                                 => v1(D_IND(i+4)),
      a_out                             => v2(A_IND(i+4)),
      b_out                             => v2(B_IND(i+4)),
      c_out                             => v2(C_IND(i+4)),
      d_out                             => v2(D_IND(i+4))
    );
    
  end generate g_comp_gen;
  
  v0_0_7_gen : for i in 0 to 7 generate
    v0(i)                               <= IV512(i);
  end generate v0_0_7_gen;
  
  v0_8_11_gen : for i in 8 to 11 generate
    v0(i)                               <= C(i-8);
  end generate v0_8_11_gen;
  
  v0(12)                                <= T(0) xor C(4);
  v0(13)                                <= T(0) xor C(5);
  v0(14)                                <= T(1) xor C(6);
  v0(15)                                <= T(1) xor C(7);
  
  blake512 : process(q_blake512_state, q_m, q_h, data_in_array, start, q_round, q_v)
  begin
    blake512_state_next                 <= q_blake512_state;
    init_v                              <= '0';
    m                                   <= q_m;
    round_start                         <= '1';
    round_en                            <= '0';
    done                                <= '0';
    h                                   <= q_h;
    case q_blake512_state is
    when IDLE =>
      init_v                            <= '1';
      for i in 0 to 9 loop
        m(i)                            <= data_in_array(i);
      end loop;
      for i in 10 to 15 loop
        m(i)                            <= PADDING(i-10);
      end loop;
      if start = '1' then
        blake512_state_next             <= EXEC_ROUNDS;
      end if;
    when EXEC_ROUNDS =>
      round_start                       <= '0';
      round_en                          <= '1';
      if q_round = 15 then
        round_en                        <= '0';
        blake512_state_next             <= FINISH;
      end if;
    when FINISH =>
      done                              <= '1';
      for i in 0 to 7 loop
        h(i)                            <= IV512(i) xor q_v(i) xor q_v(i+8);
      end loop;
      blake512_state_next               <= IDLE;
    end case;
  end process blake512;

  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_blake512_state                  <= IDLE;
      q_done                            <= '0';
      for i in 0 to 7 loop
        q_h(i)                          <= (others => '0');
      end loop;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        q_blake512_state                <= blake512_state_next;
        q_m                             <= m;
        q_done                          <= done;
        q_h                             <= h;
        if init_v = '1' then
          q_v                           <= v0;
        else
          q_v                           <= v2;
        end if;
        if round_start = '1' then
          q_round                       <= (others => '0');
        elsif round_en = '1' then
          q_round                       <= q_round + 1;
        end if;
      end if;
    end if;
  end process registers;
  
end architecture blake512_ce_rtl;