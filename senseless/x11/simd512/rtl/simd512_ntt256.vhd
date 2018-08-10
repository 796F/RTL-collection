--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simd512_ntt256 is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  clr                                   : in std_logic;
  start                                 : in std_logic;
  ccode_start                           : in std_logic;
  ccode_last                            : in std_logic;
  wb_start                              : in std_logic;
  wb_r                                  : in std_logic_vector(1 downto 0);
  wb_rnd_i                              : in std_logic_vector(2 downto 0);
  d_in                                  : in std_logic_vector(1023 downto 0);
  d_out                                 : out std_logic_vector(8191 downto 0);
  w                                     : out std_logic_vector(255 downto 0);
  done                                  : out std_logic;
  ccode_done                            : out std_logic;
  wb_done                               : out std_logic
);
end entity simd512_ntt256;

architecture simd512_ntt256_rtl of simd512_ntt256 is
  
  alias slv is std_logic_vector;
  
  component simd512_ntt64 is
  port (
    clk                                 : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    d_in                                : in std_logic_vector(1023 downto 0);
    d_in_off                            : in std_logic_vector(1 downto 0);
    nl_d_in_off                         : in std_logic_vector(3 downto 0);
    nl_d_out                            : in std_logic_vector(8191 downto 0);
    nl_done                             : in std_logic;
    nl_start                            : out std_logic;
    nl_rb                               : out std_logic_vector(3 downto 0);
    nl_hk                               : out std_logic_vector(3 downto 0);
    nl_as                               : out std_logic_vector(3 downto 0); 
    nl_d_in                             : out std_logic_vector(8191 downto 0);
    nl_d_in_we                          : out std_logic;
    ntt64_done                          : out std_logic
  );
  end component simd512_ntt64;
    
  component simd512_ntt_loop is
  port (
    clk                                 : in std_logic;
    reset                               : in std_logic;
    clr                                 : in std_logic;
    start                               : in std_logic;
    ccode_start                         : in std_logic;
    ccode_last                          : in std_logic;
    wb_start                            : in std_logic;
    rb                                  : in std_logic_vector(3 downto 0);
    hk                                  : in std_logic_vector(3 downto 0);
    as                                  : in std_logic_vector(3 downto 0);
    d_in                                : in std_logic_vector(8191 downto 0);
    d_in_we                             : in std_logic;
    wb_r                                : in std_logic_vector(1 downto 0);
    wb_rnd_i                            : in std_logic_vector(2 downto 0);
    d_out                               : out std_logic_vector(8191 downto 0);
    w                                   : out std_logic_vector(255 downto 0);
    done                                : out std_logic;
    ccode_done                          : out std_logic;
    wb_done                             : out std_logic
  );
  end component simd512_ntt_loop;
    
  type ntt256_state is (IDLE, NTT64_1, NTT64_2, NTT_LOOP_INIT_1, NTT_LOOP_1, NTT64_3, NTT64_4, NTT_LOOP_INIT_2,
                        NTT_LOOP_2, NTT_LOOP_INIT_3, NTT_LOOP_3);
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
    
  signal ntt256_state_next              : ntt256_state;
  signal done_int                       : std_logic;
  signal ntt64_start                    : std_logic;
  signal d_in_off                       : slv(1 downto 0);
  signal nl_d_in_off                    : slv(3 downto 0);
  signal nl_d_out                       : slv(8191 downto 0);
  signal nl_done                        : std_logic;
  signal nl_start                       : std_logic;
  signal ntt64_nl_start                 : std_logic;
  signal nl_rb                          : slv(3 downto 0);
  signal nl_rb_off                      : slv(3 downto 0);
  signal nl_rb_int                      : slv(3 downto 0);
  signal nl_hk                          : slv(3 downto 0);
  signal ntt64_nl_hk                    : slv(3 downto 0);
  signal nl_as                          : slv(3 downto 0);
  signal ntt64_nl_as                    : slv(3 downto 0);
  signal nl_d_in                        : slv(8191 downto 0);
  signal nl_d_in_we                     : std_logic;
  signal cc_d_in                        : slv(511 downto 0);
  signal cc_d_in_we                     : std_logic;
  signal ntt64_done                     : std_logic;
  
  signal q_ntt256_state                 : ntt256_state;
  
begin
  
  d_out                                 <= nl_d_out;
  done                                  <= done_int;
  
  simd512_ntt64_inst : simd512_ntt64
  port map (
    clk                                 => clk,
    reset                               => reset,
    start                               => ntt64_start,
    d_in                                => d_in,
    d_in_off                            => d_in_off,
    nl_d_in_off                         => nl_d_in_off,
    nl_d_out                            => nl_d_out,
    nl_done                             => nl_done,
    nl_start                            => ntt64_nl_start,
    nl_rb                               => nl_rb,
    nl_hk                               => ntt64_nl_hk,
    nl_as                               => ntt64_nl_as,
    nl_d_in                             => nl_d_in,
    nl_d_in_we                          => nl_d_in_we,
    ntt64_done                          => ntt64_done
  ); 
  
  nl_rb_int                             <= slv(unsigned(nl_rb) + unsigned(nl_rb_off));
  
  simd512_ntt_loop_inst : simd512_ntt_loop
  port map (
    clk                                 => clk,
    reset                               => reset,
    clr                                 => clr,
    start                               => nl_start,
    ccode_start                         => ccode_start,
    ccode_last                          => ccode_last,
    wb_start                            => wb_start,
    rb                                  => nl_rb_int,
    hk                                  => nl_hk,
    as                                  => nl_as,
    d_in                                => nl_d_in,
    d_in_we                             => nl_d_in_we,
    wb_r                                => wb_r,
    wb_rnd_i                            => wb_rnd_i,
    d_out                               => nl_d_out,
    w                                   => w,
    done                                => nl_done,
    ccode_done                          => ccode_done,
    wb_done                             => wb_done
  );
  
  ntt256_proc : process(q_ntt256_state, ntt64_nl_start, ntt64_nl_hk, ntt64_nl_as, start, ntt64_done, nl_done)
  begin
    ntt256_state_next                   <= q_ntt256_state;
    ntt64_start                         <= '0';
    d_in_off                            <= "00";
    nl_d_in_off                         <= X"0";
    nl_rb_off                           <= X"0";
    nl_start                            <= ntt64_nl_start;
    nl_hk                               <= ntt64_nl_hk;
    nl_as                               <= ntt64_nl_as;
    done_int                            <= '0';
    case q_ntt256_state is
    when IDLE =>
      ntt64_start                       <= start;
      if start = '1' then
        ntt256_state_next               <= NTT64_1;
      end if;
    when NTT64_1 =>
      ntt64_start                       <= ntt64_done;
      if ntt64_done = '1' then
        d_in_off                        <= "10";
        nl_d_in_off                     <= X"2";
        nl_rb_off                       <= X"4";
        ntt256_state_next               <= NTT64_2;
      end if;
    when NTT64_2 =>
      d_in_off                          <= "10";
      nl_d_in_off                       <= X"2";
      nl_rb_off                         <= X"4";
      if ntt64_done = '1' then
        ntt256_state_next               <= NTT_LOOP_INIT_1;
      end if;
    when NTT_LOOP_INIT_1 =>
      nl_start                          <= '1';
      nl_hk                             <= X"4";
      nl_as                             <= X"2";
      ntt256_state_next                 <= NTT_LOOP_1;
    when NTT_LOOP_1 =>
      nl_hk                             <= X"4";
      nl_as                             <= X"2";
      ntt64_start                       <= nl_done;
      if nl_done = '1' then
        d_in_off                        <= "01";
        nl_d_in_off                     <= X"4";
        nl_rb_off                       <= X"8";
        ntt256_state_next               <= NTT64_3;
      end if;
    when NTT64_3 =>
      d_in_off                          <= "01";
      nl_d_in_off                       <= X"4";
      nl_rb_off                         <= X"8";
      ntt64_start                       <= ntt64_done;
      if ntt64_done = '1' then
        d_in_off                        <= "11";
        nl_d_in_off                     <= X"6";
        nl_rb_off                       <= X"C";
        ntt256_state_next               <= NTT64_4;
      end if;
    when NTT64_4 =>
      d_in_off                          <= "11";
      nl_d_in_off                       <= X"6";
      nl_rb_off                         <= X"C";
      if ntt64_done = '1' then
        ntt256_state_next               <= NTT_LOOP_INIT_2;
      end if;
    when NTT_LOOP_INIT_2 =>
      nl_start                          <= '1';
      nl_rb_off                         <= X"8";
      nl_hk                             <= X"4";
      nl_as                             <= X"2";
      ntt256_state_next                 <= NTT_LOOP_2;
    when NTT_LOOP_2 =>
      nl_rb_off                         <= X"8";
      nl_hk                             <= X"4";
      nl_as                             <= X"2";
      if nl_done = '1' then
        ntt256_state_next               <= NTT_LOOP_INIT_3;
      end if;
    when NTT_LOOP_INIT_3 =>
      nl_start                          <= '1';
      nl_hk                             <= X"8";
      nl_as                             <= X"1";
      ntt256_state_next                 <= NTT_LOOP_3;
    when NTT_LOOP_3 =>
      nl_hk                             <= X"8";
      nl_as                             <= X"1";
      done_int                          <= nl_done;
      if nl_done = '1' then
        ntt256_state_next               <= IDLE;
      end if;
    when others =>
      null;
    end case;
  end process ntt256_proc;
  
  registers : process(reset, clk) is
  begin
    if reset = '1' then
      q_ntt256_state                    <= IDLE;
    elsif rising_edge(clk) then
      q_ntt256_state                    <= ntt256_state_next;
    end if;
  end process registers;
  
end architecture simd512_ntt256_rtl;