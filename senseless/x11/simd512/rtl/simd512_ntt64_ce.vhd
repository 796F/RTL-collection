--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simd512_ntt64_ce is
port (
  clk                                   : in std_logic;
  clk_en                                : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  d_in                                  : in std_logic_vector(1023 downto 0);
  d_in_off                              : in std_logic_vector(1 downto 0);
  nl_d_in_off                           : in std_logic_vector(3 downto 0);
  nl_d_out                              : in std_logic_vector(8191 downto 0);
  nl_done                               : in std_logic;
  nl_start                              : out std_logic;
  nl_rb                                 : out std_logic_vector(3 downto 0);
  nl_hk                                 : out std_logic_vector(3 downto 0);
  nl_as                                 : out std_logic_vector(3 downto 0); 
  nl_d_in                               : out std_logic_vector(8191 downto 0);
  nl_d_in_we                            : out std_logic;
  ntt64_done                            : out std_logic
);
end entity simd512_ntt64_ce;

architecture simd512_ntt64_ce_rtl of simd512_ntt64_ce is
  
  alias slv is std_logic_vector;
  
  component simd512_ntt32_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    d_in                                : in std_logic_vector(1023 downto 0);
    d_in_off                            : in std_logic_vector(1 downto 0);
    xb                                  : in std_logic_vector(5 downto 0);
    nl_done                             : in std_logic;
    nl_start                            : out std_logic;
    nl_d_in                             : out std_logic_vector(1023 downto 0)
  );
  end component simd512_ntt32_ce;
  
  type ntt64_state is (IDLE, NTT32_1, NTT32_2, NTT_LOOP_INIT, NTT_LOOP);
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
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
  
  signal ntt64_state_next               : ntt64_state;
  signal ntt32_start                    : std_logic;
  signal ntt32_xb                       : slv(5 downto 0);
  signal ntt32_nl_done                  : std_logic;
  signal ntt32_nl_start                 : std_logic;
  signal ntt32_nl_d_in                  : slv(1023 downto 0);
  signal nl_start_int                   : std_logic;
  signal nl_d_in_sel                    : slv(3 downto 0);
  signal done_int                       : std_logic;
  
  signal q_ntt64_state                  : ntt64_state;
  
begin

  ntt64_done                            <= done_int;
  
  nl_d_in_mapping : process(nl_d_in_sel, nl_d_out, ntt32_nl_d_in) is
  begin
    nl_d_in                             <= nl_d_out;
    case nl_d_in_sel is
    when X"0" =>
      nl_d_in(1023 downto 0)            <= ntt32_nl_d_in;
    when X"1" =>
      nl_d_in(2047 downto 1024)         <= ntt32_nl_d_in;
    when X"2" =>
      nl_d_in(3071 downto 2048)         <= ntt32_nl_d_in;
    when X"3" =>
      nl_d_in(4095 downto 3072)         <= ntt32_nl_d_in;
    when X"4" =>
      nl_d_in(5119 downto 4096)         <= ntt32_nl_d_in;
    when X"5" =>
      nl_d_in(6143 downto 5120)         <= ntt32_nl_d_in;
    when X"6" =>
      nl_d_in(7167 downto 6144)         <= ntt32_nl_d_in;
    when X"7" =>
      nl_d_in(8191 downto 7168)         <= ntt32_nl_d_in;
    when others =>
      null;
    end case;
  end process nl_d_in_mapping;
  
  nl_start                              <= ntt32_nl_start or nl_start_int;
  nl_d_in_we                            <= ntt32_nl_start;
  
  smid512_ntt32_inst : simd512_ntt32_ce
  port map (
    clk                                 => clk,
    clk_en                              => clk_en,
    reset                               => reset,
    start                               => ntt32_start,
    d_in                                => d_in,
    d_in_off                            => d_in_off,
    xb                                  => ntt32_xb,
    nl_done                             => ntt32_nl_done,
    nl_start                            => ntt32_nl_start,
    nl_d_in                             => ntt32_nl_d_in
  );
  
  ntt64_proc : process(q_ntt64_state, nl_d_in_off, start, nl_done)
  begin
    ntt64_state_next                    <= q_ntt64_state;
    ntt32_start                         <= '0';
    ntt32_xb                            <= "000000";
    nl_start_int                        <= '0';
    nl_d_in_sel                         <= nl_d_in_off;
    nl_rb                               <= X"0";
    nl_hk                               <= X"1";
    nl_as                               <= X"8";
    ntt32_nl_done                       <= '0';
    done_int                            <= '0';
    case q_ntt64_state is
    when IDLE =>
      ntt32_start                       <= start;
      if start = '1' then
        ntt64_state_next                <= NTT32_1;
      end if;
    when NTT32_1 =>
      ntt32_nl_done                     <= nl_done;
      ntt32_start                       <= nl_done;
      if nl_done = '1' then
        ntt32_xb                        <= "000100";
        ntt64_state_next                <= NTT32_2;
      end if;
    when NTT32_2 =>
      ntt32_nl_done                     <= nl_done;
      ntt32_xb                          <= "000100";
      nl_d_in_sel                       <= slv(unsigned(nl_d_in_off) + 1);
      nl_rb                             <= X"2";
      if nl_done = '1' then
        ntt64_state_next                <= NTT_LOOP_INIT;
      end if;
    when NTT_LOOP_INIT =>
      nl_start_int                      <= '1';
      nl_rb                             <= X"0";
      nl_hk                             <= X"2";
      nl_as                             <= X"4";
      ntt64_state_next                  <= NTT_LOOP;      
    when NTT_LOOP =>
      nl_rb                             <= X"0";
      nl_hk                             <= X"2";
      nl_as                             <= X"4";
      done_int                          <= nl_done;
      if start = '1' then
        ntt32_start                     <= '1';
        nl_rb                           <= X"0";
        nl_hk                           <= X"1";
        nl_as                           <= X"8";
        ntt64_state_next                <= NTT32_1;
      elsif nl_done = '1' then
        ntt64_state_next                <= IDLE;
      end if;
    when others =>
      null;
    end case;
  end process ntt64_proc;
  
  registers : process(reset, clk) is
  begin
    if reset = '1' then
      q_ntt64_state                     <= IDLE;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        q_ntt64_state                   <= ntt64_state_next;
      end if;
    end if;
  end process registers;
  
end architecture simd512_ntt64_ce_rtl;