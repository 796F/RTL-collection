--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity echo512_ce is
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
end entity echo512_ce;

architecture echo512_ce_rtl of echo512_ce is
  
  alias slv is std_logic_vector;
  
  component echo512_aes_two_rounds is
  port (
    x_in                                : in std_logic_vector(127 downto 0);
    k_in                                : in std_logic_vector(127 downto 0);
    x_out                               : out std_logic_vector(127 downto 0)
  );
  end component echo512_aes_two_rounds;
  
  component echo512_mix_col is
  port (
    num                                 : in std_logic_vector(1 downto 0);
    x_in                                : in std_logic_vector(511 downto 0);
    t_in                                : in std_logic_vector(511 downto 0);
    x_out                               : out std_logic_vector(511 downto 0)
  );
  end component echo512_mix_col;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype natural_0_3 is natural range 0 to 3;
  
  type echo512_state is (IDLE, EXEC_AES_TWO_ROUNDS, EXEC_MIX_COL, EXEC_XOR, FINISH);

  constant zeros64 : word64 := (others => '0');
  constant zeros32 : word32 := (others => '0');
  
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
   
  type word64_array32 is array(0 to 31) of word64;
  type word64_array16 is array(0 to 15) of word64;
  type word64_array8 is array(0 to 7) of word64;
  type word32_array4 is array(0 to 3) of word32;
  type nat_array_4_8 is array(0 to 3, 0 to 7) of natural;
  
  constant PADDING_1                    : word64_array16 := (X"0000000000000200", X"0000000000000000",
                                                             X"0000000000000200", X"0000000000000000",
                                                             X"0000000000000200", X"0000000000000000",
                                                             X"0000000000000200", X"0000000000000000",
                                                             X"0000000000000200", X"0000000000000000",
                                                             X"0000000000000200", X"0000000000000000",
                                                             X"0000000000000200", X"0000000000000000",
                                                             X"0000000000000200", X"0000000000000000");
                                                            
  constant PADDING_2                    : word64_array8 := (X"0000000000000080", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0200000000000000",
                                                            X"0000000000000200", X"0000000000000000");
  
  constant COUNT                        : word32_array4 := (X"00000200",X"00000000",X"00000000",X"00000000");  
  
  constant MC_X_IN_IND                  : nat_array_4_8 := (( 0, 1,10,11,20,21,30,31),
                                                            ( 8, 9,18,19,28,29, 6, 7),
                                                            (16,17,26,27, 4, 5,14,15),
                                                            (24,25, 2, 3,12,13,22,23));
  
  signal echo512_state_next             : echo512_state;
  signal data_in_array                  : word64_array32;
  signal atr_x_in                       : slv(127 downto 0);  
  signal atr_x_in_array                 : word32_array4;
  signal atr_k_in                       : slv(127 downto 0);
  signal atr_x_out                      : slv(127 downto 0);
  signal atr_x_out_array                : word32_array4;
  signal mc_num                         : slv(1 downto 0);
  signal mc_x_in                        : slv(511 downto 0);
  signal mc_x_in_array                  : word64_array8;
  signal mc_t_in                        : slv(511 downto 0);
  signal mc_x_out                       : slv(511 downto 0);
  signal mc_x_out_array                 : word64_array8;
  signal w                              : word64_array32;
  signal h                              : word64_array8;
  signal k                              : word32_array4;
  signal t                              : word64_array8;
  signal count_1_start                  : std_logic;
  signal count_1_en                     : std_logic;
  signal count_2_start                  : std_logic;
  signal count_2_en                     : std_logic;
  signal done                           : std_logic;
  signal almost_done                    : std_logic;
  
  signal q_echo512_state                : echo512_state;
  signal q_w                            : word64_array32;
  signal q_h                            : word64_array8;
  signal q_k                            : word32_array4;
  signal q_t                            : word64_array8;
  signal q_count_1                      : unsigned(3 downto 0);
  signal q_count_2                      : unsigned(3 downto 0);
  
begin

  hash_new                              <= done;
  hash_almost_new                       <= almost_done;
  
  output_mapping : for i in 0 to 7 generate
    hash((i+1)*64-1 downto i*64)        <= q_h(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 7 generate
    data_in_array(i)                    <= PADDING_1(i);
    data_in_array(8+i)                  <= PADDING_1(8+i);
    data_in_array(16+i)                 <= data_in((i+1)*64-1 downto i*64);
    data_in_array(24+i)                 <= PADDING_2(i);
  end generate input_mapping;
  
  array_mapping_1 : for i in 0 to 3 generate
    atr_x_in((i+1)*32-1 downto i*32)    <= atr_x_in_array(i);
    atr_k_in((i+1)*32-1 downto i*32)    <= q_k(i);
    atr_x_out_array(i)                  <= atr_x_out((i+1)*32-1 downto i*32);
  end generate array_mapping_1;
  
  array_mapping_2 : for i in 0 to 7 generate
    mc_x_in((i+1)*64-1 downto i*64)     <= mc_x_in_array(i);
    mc_t_in((i+1)*64-1 downto i*64)     <= q_t(i);
    mc_x_out_array(i)                   <= mc_x_out((i+1)*64-1 downto i*64);
  end generate array_mapping_2;
  
  echo512_aes_two_rounds_inst : echo512_aes_two_rounds
  port map (
    x_in                                => atr_x_in,
    k_in                                => atr_k_in,
    x_out                               => atr_x_out
  );
  
  mc_num                                <= slv(q_count_1(1 downto 0));
  
  echo512_mix_col_inst : echo512_mix_col
  port map (
    num                                 => mc_num,
    x_in                                => mc_x_in,
    t_in                                => mc_t_in,
    x_out                               => mc_x_out
  );
  
  echo512_proc : process(q_echo512_state, q_w, q_t, q_count_1, q_k, q_h, start, data_in_array, atr_x_out_array, q_count_2, mc_x_out_array, pause)
  begin
    echo512_state_next                  <= q_echo512_state;
    busy_n                              <= '0';
    w                                   <= q_w;
    t                                   <= q_t;
    atr_x_in_array(0)                   <= q_w(to_integer(q_count_1 & '0'))(31 downto 0);
    atr_x_in_array(1)                   <= q_w(to_integer(q_count_1 & '0'))(63 downto 32);
    atr_x_in_array(2)                   <= q_w(to_integer(q_count_1 & '1'))(31 downto 0);
    atr_x_in_array(3)                   <= q_w(to_integer(q_count_1 & '1'))(63 downto 32);
    for i in 0 to 7 loop
      mc_x_in_array(i)                  <= q_w(MC_X_IN_IND(to_integer(q_count_1(1 downto 0)),i));
    end loop;
    k                                   <= q_k;
    h                                   <= q_h;
    count_1_start                       <= '1';
    count_1_en                          <= '0';
    count_2_start                       <= '1';
    count_2_en                          <= '0';
    almost_done                         <= '0';
    done                                <= '0';
    case q_echo512_state is
    when IDLE =>
      busy_n                            <= '1';
      if start = '1' then
        busy_n                          <= '0';
        w                               <= data_in_array;
        k                               <= COUNT;
        echo512_state_next              <= EXEC_AES_TWO_ROUNDS;
      end if;
    when EXEC_AES_TWO_ROUNDS =>
      count_1_start                     <= '0';
      count_1_en                        <= '1';
      count_2_start                     <= '0';
      w(to_integer(q_count_1 & '0'))(31 downto 0)  <= atr_x_out_array(0);
      w(to_integer(q_count_1 & '0'))(63 downto 32) <= atr_x_out_array(1);
      w(to_integer(q_count_1 & '1'))(31 downto 0)  <= atr_x_out_array(2);
      w(to_integer(q_count_1 & '1'))(63 downto 32) <= atr_x_out_array(3);
      k(0)                              <= slv(unsigned(q_k(0)) + 1);
      if q_count_1 = 15 then
        count_1_start                   <= '1';
        count_1_en                      <= '0';
        for i in 0 to 7 loop
          if i = 6 then
            mc_x_in_array(i)            <= atr_x_out_array(1) & atr_x_out_array(0);
          elsif i = 7 then
            mc_x_in_array(i)            <= atr_x_out_array(3) & atr_x_out_array(2);
          else
            mc_x_in_array(i)            <= q_w(MC_X_IN_IND(0,i));
          end if;
        end loop;
        echo512_state_next              <= EXEC_MIX_COL;
      end if;
    when EXEC_MIX_COL =>
      count_1_start                     <= '0';
      count_1_en                        <= '1';
      count_2_start                     <= '0';
      for i in 0 to 7 loop
        w(to_integer(unsigned(q_count_1(1 downto 0) & "000") + i)) <= mc_x_out_array(i);
      end loop;
      case q_count_1(1 downto 0) is
      when "00" =>
        t(0)                            <= q_w(2);
        t(1)                            <= q_w(3);
        t(2)                            <= q_w(4);
        t(3)                            <= q_w(5);
        t(4)                            <= q_w(6);
        t(5)                            <= q_w(7);
      when "01" =>
        t(4)                            <= q_w(12);
        t(5)                            <= q_w(13);
        t(6)                            <= q_w(14);
        t(7)                            <= q_w(15);
      when "10" =>
        t(2)                            <= q_w(22);
        t(3)                            <= q_w(23);
      when others =>
        null;
      end case;
      if q_count_1 = 3 then
        if q_count_2 = 9 then
          echo512_state_next            <= EXEC_XOR;
        else
          count_1_start                 <= '1';
          count_1_en                    <= '0';
          count_2_en                    <= '1';
          echo512_state_next            <= EXEC_AES_TWO_ROUNDS;
        end if;
      end if;
    when EXEC_XOR =>
      for i in 0 to 7 loop
        h(i)                            <= data_in_array(i) xor data_in_array(16+i) xor q_w(i) xor q_w(16+i);
      end loop;
      almost_done                       <= '1';
      echo512_state_next                <= FINISH;
    when FINISH =>
      done                              <= '1';
      if pause = '0' then
        echo512_state_next              <= IDLE;
      end if;
    when others =>
      null;
    end case;
  end process echo512_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_echo512_state                   <= IDLE;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        q_echo512_state                 <= echo512_state_next;
        q_w                             <= w;
        q_k                             <= k;
        q_t                             <= t;
        q_h                             <= h;
        if count_1_start = '1' then
          q_count_1                     <= (others => '0');
        elsif count_1_en = '1' then
          q_count_1                     <= q_count_1 + 1;
        end if;
        if count_2_start = '1' then
          q_count_2                     <= (others => '0');
        elsif count_2_en = '1' then
          q_count_2                     <= q_count_2 + 1;  
        end if;
      end if;
    end if;
  end process registers;
  
end architecture echo512_ce_rtl;