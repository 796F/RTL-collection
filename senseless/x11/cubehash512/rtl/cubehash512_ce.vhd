--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cubehash512_ce is
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
end entity cubehash512_ce;

architecture cubehash512_ce_rtl of cubehash512_ce is
  
  alias slv is std_logic_vector;
  
  component cubehash512_16_rounds_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    xor_1_flag                          : in std_logic;
    x_in                                : in std_logic_vector(1023 downto 0);
    x_out                               : out std_logic_vector(1023 downto 0);
    x_new                               : out std_logic
  );
  end component cubehash512_16_rounds_ce;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  subtype uword32 is unsigned(31 downto 0);
  type cubehash512_state is (IDLE, EXEC_16_ROUNDS_1_INIT, EXEC_16_ROUNDS_1, EXEC_XOR_1, EXEC_16_ROUNDS_2_INIT, EXEC_16_ROUNDS_2, EXEC_XOR_2, EXEC_16_ROUNDS_3_INIT, EXEC_16_ROUNDS_3, FINISH);

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
  type word32_array16 is array(0 to 15) of word32;
  type word32_array8 is array(0 to 7) of word32;
  
  constant IV                           : word32_array32 := (X"2AEA2A61", X"50F494D4",
                                                             X"2D538B8B", X"4167D83E",
                                                             X"3FEE2313", X"C701CF8C",
                                                             X"CC39968E", X"50AC5695",
                                                             X"4D42C787",	X"A647A8B3",
                                                             X"97CF0BEF", X"825B4537",
                                                             X"EEF864D2", X"F22090C4",
                                                             X"D0E5CD33", X"A23911AE",
                                                             X"FCD398D9", X"148FE485",
                                                             X"1B017BEF", X"B6444532",
                                                             X"6A536159", X"2FF5781C",
                                                             X"91FA7934", X"0DBADEA9",
                                                             X"D65C8A2B", X"A5A70E75",
                                                             X"B1C62456", X"BC796576",
                                                             X"1921C8F7", X"E7989AF1",
                                                             X"7795D246", X"D43E3B44");
  constant PADDING                      : word32_array8 := (X"00000080",X"00000000",
                                                            X"00000000",X"00000000",
                                                            X"00000000",X"00000000",
                                                            X"00000000",X"00000000");
  
  signal cubehash512_state_next         : cubehash512_state;
  signal count_start                    : std_logic;
  signal count_en                       : std_logic;
  signal data_in_array                  : word32_array16;
  signal sr_start                       : std_logic;
  signal xor_1_flag                     : std_logic;
  signal sr_x_in                        : slv(1023 downto 0);
  signal sr_x_in_array                  : word32_array32;
  signal sr_x_out                       : slv(1023 downto 0);
  signal sr_x_out_array                 : word32_array32;
  signal sr_x_new                       : std_logic;
  signal x                              : word32_array32;
  signal done                           : std_logic;
  signal almost_done                    : std_logic;
  
  signal q_cubehash512_state            : cubehash512_state;
  signal q_count                        : unsigned(3 downto 0);
  signal q_x                            : word32_array32;
  
begin

  hash_new                              <= done;
  hash_almost_new                       <= almost_done;
  
  output_mapping : for i in 0 to 15 generate
    hash((i+1)*32-1 downto i*32)        <= q_x(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 15 generate
    data_in_array(i)                    <= data_in((i+1)*32-1 downto i*32);
  end generate input_mapping;
  
  array_mapping : for i in 0 to 31 generate
    sr_x_in((i+1)*32-1 downto i*32)     <= sr_x_in_array(i);
    sr_x_out_array(i)                   <= sr_x_out((i+1)*32-1 downto i*32);
  end generate array_mapping;
  
  cubehash512_16_rounds_inst : cubehash512_16_rounds_ce
  port map (
    clk                                 => clk,
    clk_en                              => clk_en,
    reset                               => reset,
    start                               => sr_start,
    xor_1_flag                          => xor_1_flag,
    x_in                                => sr_x_in,
    x_out                               => sr_x_out,
    x_new                               => sr_x_new
  );
  
  cubehash512_proc : process(q_cubehash512_state, q_x, start, data_in_array, sr_x_new, sr_x_out_array, q_count, pause)
  begin
    cubehash512_state_next              <= q_cubehash512_state;
    busy_n                              <= '0';
    sr_start                            <= '0';
    xor_1_flag                          <= '0';
    sr_x_in_array                       <= q_x;
    count_start                         <= '1';
    count_en                            <= '0';
    x                                   <= q_x;
    almost_done                         <= '0';
    done                                <= '0';
    case q_cubehash512_state is
    when IDLE =>
      busy_n                            <= '1';
      if start = '1' then
        busy_n                          <= '0';
        for i in 0 to 7 loop
          x(i)                          <= IV(i) xor data_in_array(i);
        end loop;
        for i in 8 to 31 loop
          x(i)                          <= IV(i);
        end loop;
        cubehash512_state_next          <= EXEC_16_ROUNDS_1_INIT;
      end if;
    when EXEC_16_ROUNDS_1_INIT =>
      sr_start                          <= '1';
      cubehash512_state_next            <= EXEC_16_ROUNDS_1;
    when EXEC_16_ROUNDS_1 =>
      if sr_x_new = '1' then
        x                               <= sr_x_out_array;
        cubehash512_state_next          <= EXEC_XOR_1;
      end if;
    when EXEC_XOR_1 =>
      for i in 0 to 7 loop
        x(i)                            <= q_x(i) xor data_in_array(8+i);
      end loop;
      cubehash512_state_next            <= EXEC_16_ROUNDS_2_INIT;
    when EXEC_16_ROUNDS_2_INIT =>
      sr_start                          <= '1';
      cubehash512_state_next            <= EXEC_16_ROUNDS_2;
    when EXEC_16_ROUNDS_2 =>
      if sr_x_new = '1' then
        x                               <= sr_x_out_array;
        cubehash512_state_next          <= EXEC_XOR_2;
      end if;
    when EXEC_XOR_2 =>
      for i in 0 to 7 loop
        x(i)                            <= q_x(i) xor PADDING(i);
      end loop;
      cubehash512_state_next            <= EXEC_16_ROUNDS_3_INIT;
    when EXEC_16_ROUNDS_3_INIT =>
      sr_start                          <= '1';
      xor_1_flag                        <= '1';
      cubehash512_state_next            <= EXEC_16_ROUNDS_3;
    when EXEC_16_ROUNDS_3 =>
      count_start                       <= '0';
      count_en                          <= sr_x_new;
      if q_count = 0 then
        xor_1_flag                      <= '1';        
      end if;
      if sr_x_new = '1' then
        x                               <= sr_x_out_array;
        sr_start                        <= '1';
        sr_x_in_array                   <= sr_x_out_array;
        if q_count = 10 then
          sr_start                      <= '0';
          almost_done                   <= '1';
          cubehash512_state_next        <= FINISH;
        end if;
      end if;
    when FINISH =>
      done                              <= '1';
      if pause = '0' then
        cubehash512_state_next          <= IDLE;
      end if;
    end case;
  end process cubehash512_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_cubehash512_state               <= IDLE;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        q_cubehash512_state             <= cubehash512_state_next;
        q_x                             <= x;
        if count_start = '1' then
          q_count                       <= (others => '0');
        elsif count_en = '1' then
          q_count                       <= q_count + 1;
        end if;
      end if;
    end if;
  end process registers;
  
end architecture cubehash512_ce_rtl;