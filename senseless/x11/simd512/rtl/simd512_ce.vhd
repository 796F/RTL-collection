--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simd512_ce is
port (
  clk                                   : in std_logic;
  clk_en                                : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  pause                                 : in std_logic;
  data_in                               : in std_logic_vector(511 downto 0);
  hash                                  : out std_logic_vector(511 downto 0);
  hash_new                              : out std_logic;
  hash_almost_new                       : out std_logic;
  busy_n                                : out std_logic
);
end entity simd512_ce;

architecture simd512_ce_rtl of simd512_ce is
  
  alias slv is std_logic_vector;
  
  component simd512_ntt256_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    clr                                 : in std_logic;
    start                               : in std_logic;
    ccode_start                         : in std_logic;
    ccode_last                          : in std_logic;
    wb_start                            : in std_logic;
    wb_r                                : in std_logic_vector(1 downto 0);
    wb_rnd_i                            : in std_logic_vector(2 downto 0);
    d_in                                : in std_logic_vector(1023 downto 0);
    d_out                               : out std_logic_vector(8191 downto 0);
    w                                   : out std_logic_vector(255 downto 0);
    done                                : out std_logic;
    ccode_done                          : out std_logic;
    wb_done                             : out std_logic
  );
  end component simd512_ntt256_ce;
  
  component simd512_round_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    wb_done                             : in std_logic;
    step_done                           : in std_logic;
    wb_start                            : out std_logic;
    step_start                          : out std_logic;
    step_fn                             : out std_logic;
    rnd_i                               : out std_logic_vector(1 downto 0);
    wb_rnd_i                            : out std_logic_vector(2 downto 0);
    done                                : out std_logic
  );
  end component simd512_round_ce;
  
  component simd512_step_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    direct                              : in std_logic;
    x_in                                : in std_logic_vector(1023 downto 0);
    w                                   : in std_logic_vector(255 downto 0);
    fn                                  : in std_logic;
    isp                                 : in std_logic_vector(1 downto 0);
    rnd_i                               : in std_logic_vector(1 downto 0); 
    x_out                               : out std_logic_vector(1023 downto 0);
    x_out_new                           : out std_logic;
    done                                : out std_logic;
    almost_done                         : out std_logic
  );
  end component simd512_step_ce;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype word8 is slv(7 downto 0);
  subtype word6 is slv(5 downto 0);
  subtype natural_0_3 is natural range 0 to 3;
  
  type simd512_state is (IDLE, NTT256_1, CCODE_1, ROUND_1_1, ROUND_2_1, ROUND_3_1, ROUND_4_1, STEP_1_1, STEP_2_1, STEP_3_1, STEP_4_1, NTT256_2, CCODE_2, ROUND_1_2, ROUND_2_2, ROUND_3_2, ROUND_4_2, STEP_1_2, STEP_2_2, STEP_3_2, STEP_4_2, FINISH);

  constant zeros64 : word64 := (others => '0');
  constant zeros32 : word32 := (others => '0');
  constant zeros6 : word6 := (others => '0');
  
  function byte_sel(x: word32; n: natural_0_3) return unsigned is
  begin
    return unsigned(x((n+1)*8-1 downto n*8));
  end byte_sel;
  
  function endian_swap64(x: word64) return word64 is
  begin
    return word64(x(7 downto 0)   & x(15 downto 8)  & x(23 downto 16) & x(31 downto 24) &
                  x(39 downto 32) & x(47 downto 40) & x(55 downto 48) & x(63 downto 56));
  end endian_swap64;

  function endian_swap32(x: word32) return word32 is
  begin
    return word32(x(7 downto 0)   & x(15 downto 8)  & x(23 downto 16) & x(31 downto 24));
  end endian_swap32;
  
  function shr64(x: word64; n: natural) return word64 is
  begin
    return word64(zeros64(n-1 downto 0) & x(x'high downto n));
  end shr64;
  
  function shr32(x: word32; n: natural) return word32 is
  begin
    return word32(zeros32(n-1 downto 0) & x(x'high downto n));
  end shr32;
  
  function shl64(x: word64; n: natural) return word64 is
  begin
    return word64(x(x'high-n downto 0) & zeros64(x'high downto x'length-n));
  end shl64;

  function shl32(x: word32; n: natural) return word32 is
  begin
    return word32(x(x'high-n downto 0) & zeros32(x'high downto x'length-n));
  end shl32;

  function shl6(x: word6; n: natural) return word6 is
  begin
    return word6(x(x'high-n downto 0) & zeros6(x'high downto x'length-n));
  end shl6;
  
  function rotr64(x: word64; n: natural) return word64 is
  begin
    return word64(x(n-1 downto 0) & x(x'high downto n));
  end rotr64;
  
  function rotr32(x: word32; n: natural) return word32 is
  begin
    return word32(x(n-1 downto 0) & x(x'high downto n));
  end rotr32;
  
  function rotl64(x: word64; n: natural) return word64 is
  begin
    return word64(x(x'high-n downto 0) & x(x'high downto x'length-n));
  end rotl64;
  
  function rotl32(x: word32; n: natural) return word32 is
  begin
    return word32(x(x'high-n downto 0) & x(x'high downto x'length-n));
  end rotl32;
  
  type word32_array256 is array(0 to 255) of word32;
  type word32_array32 is array(0 to 31) of word32;
  type word32_array8 is array(0 to 7) of word32;
  
  constant IV                           : word32_array32 := (X"0BA16B95", X"72F999AD", X"9FECC2AE", X"BA3264FC",
                                                             X"5E894929", X"8E9F30E5", X"2F1DAA37", X"F0F2C558",
                                                             X"AC506643", X"A90635A5", X"E25B878B", X"AAB7878F",
                                                             X"88817F7A", X"0A02892B", X"559A7550", X"598F657E",
                                                             X"7EEF60A1", X"6B70E3E8", X"9C1714D1", X"B958E2A8",
                                                             X"AB02675E", X"ED1C014F", X"CD8D65BB", X"FDB7A257",
                                                             X"09254899", X"D699C7BC", X"9019B6DC", X"2B9022E4",
                                                             X"8FA14956", X"21BF9BD3", X"B94D0943", X"6FFDDC22");
  
  constant PADDING                      : word32_array32 := (X"00000200", X"00000000", X"00000000", X"00000000",
                                                             X"00000000", X"00000000", X"00000000", X"00000000",
                                                             X"00000000", X"00000000", X"00000000", X"00000000",
                                                             X"00000000", X"00000000", X"00000000", X"00000000",
                                                             X"00000000", X"00000000", X"00000000", X"00000000",
                                                             X"00000000", X"00000000", X"00000000", X"00000000",
                                                             X"00000000", X"00000000", X"00000000", X"00000000",
                                                             X"00000000", X"00000000", X"00000000", X"00000000");
                                                             
  constant ZEROS32_ARRAY256             : word32_array256 := (others => ZEROS32);
  
  signal simd512_state_next             : simd512_state;
  signal ntt256_start                   : std_logic;
  signal data_in_array                  : word32_array32;
  signal ntt256_d_in                    : slv(1023 downto 0);
  signal ntt256_d_in_array              : word32_array32;
  signal d_out                          : slv(8191 downto 0);
  signal d_out_array                    : word32_array256;
  signal ntt256_done                    : std_logic;
  signal y                              : word32_array256;
  signal x                              : word32_array32;
  signal h                              : word32_array32;
  signal count_start                    : std_logic;
  signal count_en                       : std_logic;
  signal ccode_start                    : std_logic;
  signal ccode_last                     : std_logic;
  signal ccode_done                     : std_logic;
  signal round_start                    : std_logic;
  signal wb_start                       : std_logic;
  signal wb_r                           : slv(1 downto 0);
  signal wb_rnd_i                       : slv(2 downto 0);
  signal w                              : slv(255 downto 0);
  signal wb_done                        : std_logic;
  signal step_direct_w                  : slv(255 downto 0);
  signal step_direct_w_array            : word32_array8;
  signal w_int                          : slv(255 downto 0);
  signal step_start                     : std_logic;
  signal step_direct_start              : std_logic;
  signal step_start_int                 : std_logic;
  signal step_direct                    : std_logic;
  signal step_fn                        : std_logic;
  signal rnd_i                          : slv(1 downto 0);
  signal step_direct_rnd_i              : slv(1 downto 0);
  signal rnd_i_int                      : slv(1 downto 0);
  signal round_done                     : std_logic;
  signal step_x_in                      : slv(1023 downto 0);
  signal step_x_in_array                : word32_array32;
  signal step_x_out                     : slv(1023 downto 0);
  signal step_x_out_array               : word32_array32;
  signal step_x_out_new                 : std_logic;
  signal step_done                      : std_logic;
  signal step_almost_done               : std_logic;
  signal done                           : std_logic;
  signal almost_done                    : std_logic;
  
  signal q_simd512_state                : simd512_state;
  signal q_y                            : word32_array256;
  signal q_x                            : word32_array32;
  signal q_h                            : word32_array32;
  signal q_count                        : unsigned(3 downto 0);
  
begin

  hash_new                              <= done;
  hash_almost_new                       <= almost_done;
  
  output_mapping : for i in 0 to 15 generate
    hash((i+1)*32-1 downto i*32)        <= q_h(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 15 generate
    data_in_array(i)                    <= data_in((i+1)*32-1 downto i*32);
    data_in_array(16+i)                 <= (others => '0');
  end generate input_mapping;
  
  array_mapping_1 : for i in 0 to 255 generate
    d_out_array(i)                      <= d_out((i+1)*32-1 downto i*32);
  end generate array_mapping_1;
  
  array_mapping_2 : for i in 0 to 31 generate
    ntt256_d_in((i+1)*32-1 downto i*32) <= ntt256_d_in_array(i);
  end generate array_mapping_2;
  
  simd512_ntt256_inst : simd512_ntt256_ce
  port map (
    clk                                 => clk,
    clk_en                              => clk_en,
    reset                               => reset,
    clr                                 => reset,
    start                               => ntt256_start,
    ccode_start                         => ccode_start,
    ccode_last                          => ccode_last,
    wb_start                            => wb_start,
    wb_r                                => wb_r,
    wb_rnd_i                            => wb_rnd_i,
    d_in                                => ntt256_d_in,
    d_out                               => d_out,
    w                                   => w,
    done                                => ntt256_done,
    ccode_done                          => ccode_done,
    wb_done                             => wb_done
  );
  
  simd512_round_inst : simd512_round_ce
  port map (
    clk                                 => clk,
    clk_en                              => clk_en,
    reset                               => reset,
    start                               => round_start,
    wb_done                             => wb_done,
    step_done                           => step_done,
    wb_start                            => wb_start,
    step_start                          => step_start,
    step_fn                             => step_fn,
    rnd_i                               => rnd_i,
    wb_rnd_i                            => wb_rnd_i,
    done                                => round_done
  );
  
  step_x_mapping : for i in 0 to 31 generate
    step_x_in((i+1)*32-1 downto i*32)   <= step_x_in_array(i);
    step_x_out_array(i)                 <= step_x_out((i+1)*32-1 downto i*32);
  end generate step_x_mapping;
  
  step_direct_x_mapping : for i in 0 to 7 generate
    step_direct_w((i+1)*32-1 downto i*32) <= step_direct_w_array(i);
  end generate step_direct_x_mapping;
  
  step_start_int                        <= step_start or step_direct_start;
  w_int                                 <= step_direct_w when step_direct = '1' else w;
  rnd_i_int                             <= step_direct_rnd_i when step_direct = '1' else rnd_i;
  
  simd512_step_inst : simd512_step_ce
  port map (
    clk                                 => clk,
    clk_en                              => clk_en,
    reset                               => reset,
    start                               => step_start_int,
    direct                              => step_direct,
    x_in                                => step_x_in,
    w                                   => w_int,
    fn                                  => step_fn,
    isp                                 => wb_r,
    rnd_i                               => rnd_i_int,
    x_out                               => step_x_out,
    x_out_new                           => step_x_out_new,
    done                                => step_done,
    almost_done                         => step_almost_done
  );
  
  simd512_proc : process(q_simd512_state, q_y, q_x, q_h, start, q_count, data_in_array, ntt256_done, ccode_done, step_x_out_new, step_x_out_array, round_done, step_done, step_almost_done, pause)
  begin
    simd512_state_next                  <= q_simd512_state;
    busy_n                              <= '0';
    ntt256_start                        <= '0';
    ntt256_d_in_array                   <= data_in_array;
    count_start                         <= '0';
    count_en                            <= '0';
    ccode_start                         <= '0';
    ccode_last                          <= '0';
    round_start                         <= '0';
    wb_r                                <= (others => '0');
    step_direct_start                   <= '0';
    step_direct                         <= '0';
    step_direct_rnd_i                   <= (others => '0');
    step_direct_w_array                 <= (IV(0),IV(1),IV(2),IV(3),IV(4),IV(5),IV(6),IV(7));
    y                                   <= q_y;
    step_x_in_array                     <= q_x;
    if step_x_out_new = '1' then
      x                                 <= step_x_out_array;
    else
      x                                 <= q_x;
    end if;
    h                                   <= q_h;
    almost_done                         <= '0';
    done                                <= '0';
    case q_simd512_state is
    when IDLE =>
      busy_n                            <= '1';
      ntt256_start                      <= start;
      count_start                       <= start;
      if start = '1' then
        busy_n                          <= '0';
        simd512_state_next              <= NTT256_1;
      end if;
    when NTT256_1 =>
      if q_count = 15 then
        count_en                        <= '0';
      else
        count_en                        <= '1';
      end if;
      x(to_integer(q_count))            <= IV(to_integer(q_count)) xor data_in_array(to_integer(q_count));
      for i in 0 to 15 loop
        x(16+i)                         <= IV(16+i);
      end loop;
      ccode_start                       <= ntt256_done;
      if ntt256_done = '1' then
        simd512_state_next              <= CCODE_1;
      end if;
    when CCODE_1 =>
      round_start                       <= ccode_done;
      if ccode_done = '1' then
        simd512_state_next              <= ROUND_1_1;
      end if;
    when ROUND_1_1 =>
      round_start                       <= round_done;
      if round_done = '1' then
        wb_r                            <= "01";
        simd512_state_next              <= ROUND_2_1;
      end if;
    when ROUND_2_1 =>
      wb_r                              <= "01";
      round_start                       <= round_done;
      if round_done = '1' then
        wb_r                            <= "10";
        simd512_state_next              <= ROUND_3_1;
      end if;
    when ROUND_3_1 =>
      wb_r                              <= "10";
      round_start                       <= round_done;
      if round_done = '1' then
        wb_r                            <= "11";
        simd512_state_next              <= ROUND_4_1;
      end if;    
    when ROUND_4_1 =>
      wb_r                              <= "11";
      step_direct_start                 <= round_done;
      if round_done = '1' then
        step_direct                     <= '1';
        step_direct_rnd_i               <= (others => '0');
        step_direct_w_array             <= (IV(0),IV(1),IV(2),IV(3),IV(4),IV(5),IV(6),IV(7));
        simd512_state_next              <= STEP_1_1;
      end if;
    when STEP_1_1 =>
      wb_r                              <= "11";
      step_direct                       <= '1';
      step_direct_rnd_i                 <= (others => '0');
      step_direct_w_array               <= (IV(0),IV(1),IV(2),IV(3),IV(4),IV(5),IV(6),IV(7));
      step_direct_start                 <= step_done;
      if step_done = '1' then
        step_direct                     <= '1';
        step_direct_rnd_i               <= "01";
        step_direct_w_array             <= (IV(8),IV(9),IV(10),IV(11),IV(12),IV(13),IV(14),IV(15));
        simd512_state_next              <= STEP_2_1;
      end if;
    when STEP_2_1 =>
      wb_r                              <= "11";
      step_direct                       <= '1';
      step_direct_rnd_i                 <= "01";
      step_direct_w_array               <= (IV(8),IV(9),IV(10),IV(11),IV(12),IV(13),IV(14),IV(15));
      step_direct_start                 <= step_done;
      if step_done = '1' then
        step_direct                     <= '1';
        step_direct_rnd_i               <= "10";
        step_direct_w_array             <= (IV(16),IV(17),IV(18),IV(19),IV(20),IV(21),IV(22),IV(23));
        simd512_state_next              <= STEP_3_1;
      end if;
    when STEP_3_1 =>
      wb_r                              <= "11";
      step_direct                       <= '1';
      step_direct_rnd_i                 <= "10";
      step_direct_w_array               <= (IV(16),IV(17),IV(18),IV(19),IV(20),IV(21),IV(22),IV(23));
      step_direct_start                 <= step_done;
      if step_done = '1' then
        step_direct                     <= '1';
        step_direct_rnd_i               <= "11";
        step_direct_w_array             <= (IV(24),IV(25),IV(26),IV(27),IV(28),IV(29),IV(30),IV(31));
        simd512_state_next              <= STEP_4_1;
      end if;
    when STEP_4_1 =>
      wb_r                              <= "11";
      step_direct                       <= '1';
      step_direct_rnd_i                 <= "11";
      step_direct_w_array               <= (IV(24),IV(25),IV(26),IV(27),IV(28),IV(29),IV(30),IV(31));
      ntt256_start                      <= step_done;
      if step_done = '1' then
        ntt256_d_in_array               <= PADDING;
        simd512_state_next              <= NTT256_2;
      end if;
    when NTT256_2 =>
      ntt256_d_in_array                 <= PADDING;
      h(0)                              <= q_x(0) xor PADDING(0);
      for i in 1 to 31 loop
        h(i)                            <= q_x(i);
      end loop;
      ccode_start                       <= ntt256_done;
      if ntt256_done = '1' then
        ccode_last                      <= '1';
        simd512_state_next              <= CCODE_2;
      end if;
    when CCODE_2 =>
      ccode_last                        <= '1';
      round_start                       <= ccode_done;
      if ccode_done = '1' then
        step_x_in_array                 <= q_h;
        simd512_state_next              <= ROUND_1_2;
      end if;
    when ROUND_1_2 =>
      step_x_in_array                   <= q_h;
      if step_x_out_new = '1' then
        h                               <= step_x_out_array;
      else
        h                               <= q_h;
      end if;
      x                                 <= q_x;
      round_start                       <= round_done;
      if round_done = '1' then
        wb_r                            <= "01";
        simd512_state_next              <= ROUND_2_2;
      end if;
    when ROUND_2_2 =>
      step_x_in_array                   <= q_h;
      if step_x_out_new = '1' then
        h                               <= step_x_out_array;
      else
        h                               <= q_h;
      end if;
      x                                 <= q_x;
      wb_r                              <= "01";
      round_start                       <= round_done;
      if round_done = '1' then
        wb_r                            <= "10";
        simd512_state_next              <= ROUND_3_2;
      end if;
    when ROUND_3_2 =>
      step_x_in_array                   <= q_h;
      if step_x_out_new = '1' then
        h                               <= step_x_out_array;
      else
        h                               <= q_h;
      end if;
      x                                 <= q_x;
      wb_r                              <= "10";
      round_start                       <= round_done;
      if round_done = '1' then
        wb_r                            <= "11";
        simd512_state_next              <= ROUND_4_2;
      end if;     
    when ROUND_4_2 =>
      step_x_in_array                   <= q_h;
      if step_x_out_new = '1' then
        h                               <= step_x_out_array;
      else
        h                               <= q_h;
      end if;
      x                                 <= q_x;
      wb_r                              <= "11";
      step_direct_start                 <= round_done;
      if round_done = '1' then
        step_direct                     <= '1';
        step_direct_rnd_i               <= (others => '0');
        step_direct_w_array             <= (q_x(0),q_x(1),q_x(2),q_x(3),q_x(4),q_x(5),q_x(6),q_x(7));
        simd512_state_next              <= STEP_1_2;
      end if;
    when STEP_1_2 =>
      step_x_in_array                   <= q_h;
      if step_x_out_new = '1' then
        h                               <= step_x_out_array;
      else
        h                               <= q_h;
      end if;
      x                                 <= q_x;
      wb_r                              <= "11";
      step_direct                       <= '1';
      step_direct_rnd_i                 <= (others => '0');
      step_direct_w_array               <= (q_x(0),q_x(1),q_x(2),q_x(3),q_x(4),q_x(5),q_x(6),q_x(7));
      step_direct_start                 <= step_done;
      if step_done = '1' then
        step_direct                     <= '1';
        step_direct_rnd_i               <= "01";
        step_direct_w_array             <= (q_x(8),q_x(9),q_x(10),q_x(11),q_x(12),q_x(13),q_x(14),q_x(15));
        simd512_state_next              <= STEP_2_2;
      end if;
    when STEP_2_2 =>
      step_x_in_array                   <= q_h;
      if step_x_out_new = '1' then
        h                               <= step_x_out_array;
      else
        h                               <= q_h;
      end if;
      x                                 <= q_x;
      wb_r                              <= "11";
      step_direct                       <= '1';
      step_direct_rnd_i                 <= "01";
      step_direct_w_array               <= (q_x(8),q_x(9),q_x(10),q_x(11),q_x(12),q_x(13),q_x(14),q_x(15));
      step_direct_start                 <= step_done;
      if step_done = '1' then
        step_direct                     <= '1';
        step_direct_rnd_i               <= "10";
        step_direct_w_array             <= (q_x(16),q_x(17),q_x(18),q_x(19),q_x(20),q_x(21),q_x(22),q_x(23));
        simd512_state_next              <= STEP_3_2;
      end if;
    when STEP_3_2 =>
      step_x_in_array                   <= q_h;
      if step_x_out_new = '1' then
        h                               <= step_x_out_array;
      else
        h                               <= q_h;
      end if;
      x                                 <= q_x;
      wb_r                              <= "11";
      step_direct                       <= '1';
      step_direct_rnd_i                 <= "10";
      step_direct_w_array               <= (q_x(16),q_x(17),q_x(18),q_x(19),q_x(20),q_x(21),q_x(22),q_x(23));
      step_direct_start                 <= step_done;
      if step_done = '1' then
        step_direct                     <= '1';
        step_direct_rnd_i               <= "11";
        step_direct_w_array             <= (q_x(24),q_x(25),q_x(26),q_x(27),q_x(28),q_x(29),q_x(30),q_x(31));
        simd512_state_next              <= STEP_4_2;
      end if;
    when STEP_4_2 =>
      step_x_in_array                   <= q_h;
      if step_x_out_new = '1' then
        h                               <= step_x_out_array;
      else
        h                               <= q_h;
      end if;
      x                                 <= q_x;
      wb_r                              <= "11";
      step_direct                       <= '1';
      step_direct_rnd_i                 <= "11";
      step_direct_w_array               <= (q_x(24),q_x(25),q_x(26),q_x(27),q_x(28),q_x(29),q_x(30),q_x(31));
      almost_done                       <= step_almost_done;
      if step_almost_done = '1' then
        simd512_state_next              <= FINISH;
      end if;
    when FINISH =>
      done                              <= '1';
      if pause = '0' then
        simd512_state_next              <= IDLE;
      end if;
    when others =>
      null;
    end case;
  end process simd512_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_simd512_state                   <= IDLE;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        q_simd512_state                 <= simd512_state_next;
        q_y                             <= y;
        q_x                             <= x;
        q_h                             <= h;
        if count_start = '1' then
          q_count                       <= (others => '0');
        elsif count_en = '1' then
          q_count                       <= q_count + 1;
        end if;
      end if;
    end if;
  end process registers;
  
end architecture simd512_ce_rtl;