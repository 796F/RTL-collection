--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cubehash512_16_rounds_ce is
port (
  clk                                   : in std_logic;
  clk_en                                : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  xor_1_flag                            : in std_logic;
  x_in                                  : in std_logic_vector(1023 downto 0);
  x_out                                 : out std_logic_vector(1023 downto 0);
  x_new                                 : out std_logic
);
end entity cubehash512_16_rounds_ce;

architecture cubehash512_16_rounds_ce_rtl of cubehash512_16_rounds_ce is
  
  alias slv is std_logic_vector;
  
  component cubehash512_round_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    start                               : in std_logic;
    even_flag                           : in std_logic;
    xor_1_flag                          : in std_logic;
    x_in                                : in std_logic_vector(1023 downto 0);
    x_out                               : out std_logic_vector(1023 downto 0);
    x_new                               : out std_logic
  );
  end component cubehash512_round_ce;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  subtype uword32 is unsigned(31 downto 0);
  type sixteen_rounds_state is (IDLE, EVEN_ROUND, ODD_ROUND, FINISH);

  constant zeros64 : word64 := (others => '0');
  constant zeros32 : word32 := (others => '0');
    
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
  
  type word32_array32 is array(0 to 31) of word32;
  
  signal sixteen_rounds_state_next      : sixteen_rounds_state;
  signal r_start                        : std_logic;
  signal even_flag                      : std_logic;
  signal xor_1_flag_int                 : std_logic;
  signal r_x_in                         : slv(1023 downto 0);
  signal r_x_out                        : slv(1023 downto 0);
  signal r_x_new                        : std_logic;
  signal count_start                    : std_logic;
  signal count_en                       : std_logic;
  signal done                           : std_logic;
  
  signal q_sixteen_rounds_state         : sixteen_rounds_state;
  signal q_count                        : unsigned(3 downto 0);
  
begin

  x_new                                 <= done;
  x_out                                 <= r_x_out;
  
  cubehash512_round_inst : cubehash512_round_ce
  port map (
    clk                                 => clk,
    clk_en                              => clk_en,
    start                               => r_start,
    even_flag                           => even_flag,
    xor_1_flag                          => xor_1_flag_int,
    x_in                                => r_x_in,
    x_out                               => r_x_out,
    x_new                               => r_x_new
  );
  
  sixteen_rounds_proc : process(q_sixteen_rounds_state, r_x_out, start, x_in, r_x_new, q_count, xor_1_flag)
  begin
    sixteen_rounds_state_next           <= q_sixteen_rounds_state;
    r_start                             <= '0';
    even_flag                           <= '1';
    xor_1_flag_int                      <= '0';
    r_x_in                              <= r_x_out;
    count_start                         <= '0';
    count_en                            <= '0';
    done                                <= '0';
    case q_sixteen_rounds_state is
    when IDLE =>
      r_x_in                            <= x_in;
      if start = '1' then
        r_start                         <= '1';
        count_start                     <= '1';
        sixteen_rounds_state_next       <= EVEN_ROUND;
      end if;
    when EVEN_ROUND =>
      if r_x_new = '1' then
        r_start                         <= '1';
        even_flag                       <= '0';
        sixteen_rounds_state_next       <= ODD_ROUND;
      end if;
    when ODD_ROUND =>
      even_flag                         <= '0';
      if q_count = 7 then
        xor_1_flag_int                  <= xor_1_flag;
      end if;
      if r_x_new = '1' then
        if q_count = 7 then
          sixteen_rounds_state_next     <= FINISH;
        else
          r_start                       <= '1';
          even_flag                     <= '1';
          count_en                      <= '1';
          sixteen_rounds_state_next     <= EVEN_ROUND;
        end if;
      end if;
    when FINISH =>
      done                              <= '1';
      r_x_in                            <= x_in;
      if start = '1' then
        r_start                         <= '1';
        count_start                     <= '1';
        sixteen_rounds_state_next       <= EVEN_ROUND;
      else
        sixteen_rounds_state_next       <= IDLE;
      end if;
    end case;
  end process sixteen_rounds_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_sixteen_rounds_state            <= IDLE;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        q_sixteen_rounds_state          <= sixteen_rounds_state_next;
        if count_start = '1' then
          q_count                       <= (others => '0');
        elsif count_en = '1' then
          q_count                       <= q_count + 1;
        end if;
      end if;
    end if;
  end process registers;
  
end architecture cubehash512_16_rounds_ce_rtl;