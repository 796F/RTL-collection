--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simd512_round is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  wb_done                               : in std_logic;
  step_done                             : in std_logic;
  wb_start                              : out std_logic;
  step_start                            : out std_logic;
  step_fn                               : out std_logic;
  rnd_i                                 : out std_logic_vector(1 downto 0);
  wb_rnd_i                              : out std_logic_vector(2 downto 0);
  done                                  : out std_logic
);
end entity simd512_round;

architecture simd512_round_rtl of simd512_round is
  
  alias slv is std_logic_vector;
  type round_state is (IDLE, CALC_W_1, STEP_1, CALC_W_2, STEP_2, FINISH);
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype word8 is slv(7 downto 0);
  subtype word6 is slv(5 downto 0);
  subtype natural_0_3 is natural range 0 to 3;

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
  
  signal round_state_next               : round_state;
  signal wb_start_int                   : std_logic;
  signal step_start_int                 : std_logic;
  signal step_fn_int                    : std_logic;
  signal done_int                       : std_logic;
  
  signal q_round_state                  : round_state;
  signal q_count_1                      : unsigned(1 downto 0);
  signal q_count_2                      : unsigned(2 downto 0);
  
begin

  wb_start                              <= wb_start_int;
  step_start                            <= step_start_int;
  step_fn                               <= step_fn_int;
  rnd_i                                 <= slv(q_count_1);
  wb_rnd_i                              <= slv(q_count_2);
  done                                  <= done_int;
  
  round_proc : process(q_round_state, start, wb_done, step_done, q_count_1) is
  begin
    round_state_next                    <= q_round_state;
    wb_start_int                        <= '0';
    step_start_int                      <= '0';
    step_fn_int                         <= '0';
    done_int                            <= '0';
    case q_round_state is
    when IDLE =>
      wb_start_int                      <= start;
      if start = '1' then
        round_state_next                <= CALC_W_1;
      end if;
    when CALC_W_1 =>
      step_start_int                    <= wb_done;
      if wb_done = '1' then
        round_state_next                <= STEP_1;
      end if;
    when STEP_1 =>
      wb_start_int                      <= step_done;
      if step_done = '1' then
        if q_count_1 = 3 then
          step_fn_int                   <= '1';
          round_state_next              <= CALC_W_2;
        else
          round_state_next              <= CALC_W_1;
        end if;
      end if;
    when CALC_W_2 =>
      step_fn_int                       <= '1';
      step_start_int                    <= wb_done;
      if wb_done = '1' then
        round_state_next                <= STEP_2;  
      end if;
    when STEP_2 =>
      step_fn_int                       <= '1';
      if step_done = '1' then
        if q_count_1 = 3 then
          round_state_next              <= FINISH;
        else
          wb_start_int                  <= '1';
          round_state_next              <= CALC_W_2;
        end if;
      end if;
    when FINISH =>
      done_int                          <= '1';
      wb_start_int                      <= start;
      if start = '1' then
        round_state_next                <= CALC_W_1;
      else
        round_state_next                <= IDLE;
      end if;
    end case;
  end process round_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_round_state                     <= IDLE;
    elsif rising_edge(clk) then
      q_round_state                     <= round_state_next;
      if start = '1' then
        q_count_1                       <= (others => '0');
      elsif step_done = '1' then
        q_count_1                       <= q_count_1 + 1;
      end if;
      if start = '1' then
        q_count_2                       <= (others => '0');
      elsif wb_done = '1' then
        q_count_2                       <= q_count_2 + 1;
      end if;
    end if;
  end process registers;
  
end architecture simd512_round_rtl;