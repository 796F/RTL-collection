--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shavite512_ce is
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
end entity shavite512_ce;

architecture shavite512_ce_rtl of shavite512_ce is
  
  alias slv is std_logic_vector;
  
  component shavite512_round_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    ke                                  : in std_logic;
    ke_xor_type                         : in std_logic;
    o                                   : in std_logic_vector(2 downto 0);
    x_in                                : in std_logic_vector(127 downto 0);
    rk_in                               : in std_logic_vector(1023 downto 0);
    x_out                               : out std_logic_vector(127 downto 0);
    rk_out                              : out std_logic_vector(1023 downto 0);
    rnd_almost_ready                    : out std_logic;
    rnd_new                             : out std_logic
  );
  end component shavite512_round_ce;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  subtype uword32 is unsigned(31 downto 0);
  subtype natural_0_3 is natural range 0 to 3;
  type shavite512_state is (IDLE, EXEC_1, EXEC_2, EXEC_3, EXEC_4, EXEC_5, EXEC_6, EXEC_7, EXEC_8,
                            EXEC_9, EXEC_10, EXEC_11, EXEC_12, EXEC_13, EXEC_14, EXEC_15, EXEC_16,
                            EXEC_17, EXEC_18, EXEC_19, EXEC_20, EXEC_21, EXEC_22, EXEC_23, EXEC_24,
                            EXEC_25, EXEC_26, EXEC_27, EXEC_28, EXEC_29, EXEC_30, EXEC_31, EXEC_32,
                            EXEC_33, EXEC_34, FINISH);

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
  
  type word32_array256 is array(0 to 255) of word32;
  type word32_array32 is array(0 to 31) of word32;
  type word32_array16 is array(0 to 15) of word32;
  type word32_array8 is array(0 to 7) of word32;
  type word32_array4 is array(0 to 3) of word32;
  
  constant PADDING                      : word32_array16 := (X"00000080",X"00000000",
                                                             X"00000000",X"00000000",
                                                             X"00000000",X"00000000",
                                                             X"00000000",X"00000000",
                                                             X"00000000",X"00000000",
                                                             X"00000000",X"02000000",
                                                             X"00000000",X"00000000",
                                                             X"00000000",X"02000000");  
  constant IV                           : word32_array16 := (X"72FCCDD8", X"79CA4727",
                                                             X"128A077B", X"40D55AEC",
                                                             X"D1901A06", X"430AE307",
                                                             X"B29F5CD1", X"DF07FBFC",
                                                             X"8E45D73D", X"681AB538",
                                                             X"BDE86578", X"DD577E47",
                                                             X"E275EADE", X"502D9FCD",
                                                             X"B9357178", X"022A4B9A");
  constant COUNT                        : word32_array4 := (X"00000200",X"00000000",X"00000000",X"00000000");  
  
  signal shavite512_state_next          : shavite512_state;
  signal count_1_start                  : std_logic;
  signal count_1_en                     : std_logic;
  signal count_2_start                  : std_logic;
  signal count_2_en                     : std_logic;
  signal data_in_array                  : word32_array16;
  signal sr_start                       : std_logic;
  signal sr_ke                          : std_logic;
  signal sr_ke_xor_type                 : std_logic;
  signal sr_rnd_almost_ready            : std_logic;
  signal sr_rnd_new                     : std_logic;
  signal sr_o                           : slv(2 downto 0);
  signal sr_x_in                        : slv(127 downto 0);
  signal sr_x_out                       : slv(127 downto 0);
  signal sr_x_in_array                  : word32_array4;
  signal sr_x_out_array                 : word32_array4;
  signal sr_rk_in                       : slv(1023 downto 0);
  signal sr_rk_out                      : slv(1023 downto 0);
  signal sr_rk_in_array                 : word32_array32;
  signal sr_rk_out_array                : word32_array32;
  signal x                              : word32_array4;
  signal rk                             : word32_array32;
  signal h                              : word32_array16;
  signal rx_ke_toggle                   : std_logic;
  signal done                           : std_logic;
  signal almost_done                    : std_logic;
  
  signal q_shavite512_state             : shavite512_state;
  signal q_count_1                      : unsigned(2 downto 0);
  signal q_count_2                      : unsigned(1 downto 0);
  signal q_x                            : word32_array4;
  signal q_rk                           : word32_array32;
  signal q_h                            : word32_array16;
  signal q_rx_ke_toggle                 : std_logic;
  
begin

  hash_new                              <= done;
  hash_almost_new                       <= almost_done;
  
  output_mapping : for i in 0 to 15 generate
    hash((i+1)*32-1 downto i*32)        <= q_h(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 15 generate
    data_in_array(i)                    <= data_in((i+1)*32-1 downto i*32);
  end generate input_mapping;
  
  array_mapping_1 : for i in 0 to 3 generate
    sr_x_in((i+1)*32-1 downto i*32)     <= sr_x_in_array(i);
    sr_x_out_array(i)                   <= sr_x_out((i+1)*32-1 downto i*32);
  end generate array_mapping_1;
  
  array_mapping_2 : for i in 0 to 31 generate
    sr_rk_in((i+1)*32-1 downto i*32)    <= sr_rk_in_array(i);
    sr_rk_out_array(i)                  <= sr_rk_out((i+1)*32-1 downto i*32);
  end generate array_mapping_2;
  
  shavite512_round_inst : shavite512_round_ce
  port map (
    clk                                 => clk,
    clk_en                              => clk_en,
    reset                               => reset,
    start                               => sr_start,
    ke                                  => sr_ke,
    ke_xor_type                         => sr_ke_xor_type,
    o                                   => sr_o,
    x_in                                => sr_x_in,
    rk_in                               => sr_rk_in,
    x_out                               => sr_x_out,
    rk_out                              => sr_rk_out,
    rnd_almost_ready                    => sr_rnd_almost_ready,
    rnd_new                             => sr_rnd_new
  );
  
  shavite512_proc : process(q_shavite512_state, q_x, q_rk, q_h, q_rx_ke_toggle, q_count_1, q_count_2, start, data_in_array, sr_rnd_almost_ready, sr_rnd_new, sr_x_out_array, sr_rk_out_array, pause)
  begin
    shavite512_state_next               <= q_shavite512_state;
    busy_n                              <= '0';
    count_1_start                       <= '0';
    count_1_en                          <= '0';
    count_2_start                       <= '0';
    count_2_en                          <= '0';
    x                                   <= q_x;
    rk                                  <= q_rk;
    h                                   <= q_h;
    rx_ke_toggle                        <= q_rx_ke_toggle;
    sr_start                            <= '0';
    sr_ke                               <= '0';
    sr_ke_xor_type                      <= '0';
    sr_o                                <= slv(q_count_1);
    sr_x_in_array                       <= q_x;
    sr_rk_in_array                      <= q_rk;
    almost_done                         <= '0';
    done                                <= '0';
    case q_shavite512_state is
    when IDLE =>
      busy_n                            <= '1';
      count_1_start                     <= '1';
      if start = '1' then
        busy_n                          <= '0';
        for i in 0 to 15 loop
          rk(i)                         <= data_in_array(i);
          rk(16+i)                      <= PADDING(i);
          sr_rk_in_array(i)             <= data_in_array(i);
          sr_rk_in_array(16+i)          <= PADDING(i);
        end loop;
        h                               <= IV;
        sr_start                        <= '1';
        sr_x_in_array                   <= (IV(4),IV(5),IV(6),IV(7));
        shavite512_state_next           <= EXEC_1;
      end if;
    when EXEC_1 =>
      count_1_en                        <= sr_rnd_almost_ready;  
      if sr_rnd_new = '1' then
        x                               <= sr_x_out_array;
        if q_count_1 = 4 then
          shavite512_state_next         <= EXEC_2;
        else
          sr_start                      <= '1';
          sr_x_in_array                 <= sr_x_out_array;
        end if;
      end if;
    when EXEC_2 =>
      for i in 0 to 3 loop
        h(i)                            <= q_h(i) xor q_x(i);
      end loop;
      shavite512_state_next             <= EXEC_3;
      sr_start                          <= '1';
      sr_x_in_array                     <= (q_h(12),q_h(13),q_h(14),q_h(15));
      shavite512_state_next             <= EXEC_3;
    when EXEC_3 =>
      count_1_en                        <= sr_rnd_almost_ready;  
      if sr_rnd_new = '1' then
        x                               <= sr_x_out_array;
        if q_count_1 = 0 then
          shavite512_state_next         <= EXEC_4;
        else
          sr_start                      <= '1';
          sr_x_in_array                 <= sr_x_out_array;
        end if;
      end if;
    when EXEC_4 =>
      for i in 0 to 3 loop
        h(8+i)                          <= q_h(8+i) xor q_x(i);
      end loop;
      count_2_start                     <= '1';
      sr_start                          <= '1';
      sr_ke                             <= '1';
      shavite512_state_next             <= EXEC_5;
    when EXEC_5 =>
      if sr_rnd_new = '1' then
        rk                              <= sr_rk_out_array;
        if q_count_2 = 0 then  
          shavite512_state_next         <= EXEC_6;
        else
          sr_start                      <= '1';
          sr_x_in_array                 <= (q_h(0),q_h(1),q_h(2),q_h(3));
          sr_rk_in_array                <= sr_rk_out_array;
          shavite512_state_next         <= EXEC_7;
        end if;
      end if;
    when EXEC_6 =>
      for i in 0 to 2 loop
        rk(i)                           <= q_rk(i) xor COUNT(i);
        sr_rk_in_array(i)               <= q_rk(i) xor COUNT(i);
      end loop;
      rk(3)                             <= q_rk(3) xor not COUNT(3);
      sr_rk_in_array(3)                 <= q_rk(3) xor not COUNT(3);
      sr_start                          <= '1';
      sr_x_in_array                     <= (q_h(0),q_h(1),q_h(2),q_h(3));
      shavite512_state_next             <= EXEC_7;
    when EXEC_7 =>
      count_1_en                        <= sr_rnd_almost_ready;
      if sr_rnd_new = '1' then
        x                               <= sr_x_out_array;
        sr_start                        <= '1';
        sr_ke                           <= '1';
        shavite512_state_next           <= EXEC_8;
      end if;
    when EXEC_8 =>
      rx_ke_toggle                      <= '0';
      if sr_rnd_new = '1' then
        rk                              <= sr_rk_out_array;
        if q_count_2 = 1 then
          shavite512_state_next         <= EXEC_9;
        else
          sr_start                      <= '1';
          sr_rk_in_array                <= sr_rk_out_array;
          shavite512_state_next         <= EXEC_10;
        end if;
      end if;
    when EXEC_9 =>
      for i in 0 to 2 loop
        rk(4+i)                         <= q_rk(4+i) xor COUNT(3-i);
        sr_rk_in_array(i)               <= q_rk(4+i) xor COUNT(3-i);
      end loop;
      rk(4+3)                           <= q_rk(4+3) xor not COUNT(0);
      sr_rk_in_array(4+3)               <= q_rk(4+3) xor not COUNT(0);
      sr_start                          <= '1';
      shavite512_state_next             <= EXEC_10;
    when EXEC_10 =>
      count_1_en                        <= sr_rnd_almost_ready and not q_rx_ke_toggle;
      if sr_rnd_new = '1' then
        rx_ke_toggle                    <= not q_rx_ke_toggle;
        if q_rx_ke_toggle = '0' then
          x                             <= sr_x_out_array;
          if q_count_1 = 4 then
            shavite512_state_next       <= EXEC_11;
          else
            sr_start                    <= '1';
            sr_ke                       <= '1';
          end if;
        else
          rk                            <= sr_rk_out_array;
          sr_rk_in_array                <= sr_rk_out_array;
          sr_start                      <= '1';
        end if;
      end if;
    when EXEC_11 =>
      for i in 0 to 3 loop
        h(12+i)                         <= q_h(12+i) xor q_x(i);
      end loop;
      sr_start                          <= '1';
      sr_ke                             <= '1';
      shavite512_state_next             <= EXEC_12;
    when EXEC_12 =>
      rx_ke_toggle                      <= '0';
      if sr_rnd_new = '1' then
        rk                              <= sr_rk_out_array;
        sr_rk_in_array                  <= sr_rk_out_array;
        sr_start                        <= '1';
        sr_x_in_array                   <= (q_h(8),q_h(9),q_h(10),q_h(11));
        shavite512_state_next           <= EXEC_13;
      end if;
    when EXEC_13 =>
      count_1_en                        <= sr_rnd_almost_ready and not q_rx_ke_toggle;
      if sr_rnd_new = '1' then
        rx_ke_toggle                    <= not q_rx_ke_toggle;
        if q_rx_ke_toggle = '0' then
          x                             <= sr_x_out_array;
          sr_start                      <= '1';
          sr_ke                         <= '1';
        else
          rk                            <= sr_rk_out_array;
          if q_count_1 = 7 then
            if q_count_2 = 2 then
              shavite512_state_next     <= EXEC_14;
            else
              sr_rk_in_array            <= sr_rk_out_array;
              sr_start                  <= '1';
              shavite512_state_next     <= EXEC_15;
            end if;
          else
            sr_rk_in_array              <= sr_rk_out_array;
            sr_start                    <= '1';
          end if;
        end if;
      end if;
    when EXEC_14 =>
      for i in 0 to 2 loop
        rk(28+i)                        <= q_rk(28+i) xor COUNT((i+2) mod 4);
        sr_rk_in_array(28+i)            <= q_rk(28+i) xor COUNT((i+2) mod 4);
      end loop;
      rk(28+3)                          <= q_rk(28+3) xor not COUNT(1);
      sr_rk_in_array(28+3)              <= q_rk(28+3) xor not COUNT(1);
      sr_start                          <= '1';
      shavite512_state_next             <= EXEC_15;
    when EXEC_15 =>
      count_1_en                        <= sr_rnd_almost_ready;
      if sr_rnd_new = '1' then
        x                               <= sr_x_out_array;
        shavite512_state_next           <= EXEC_16;
      end if;
    when EXEC_16 =>
      for i in 0 to 3 loop
        h(4+i)                          <= q_h(4+i) xor q_x(i);
      end loop;
      for i in 0 to 3 loop
        rk(i)                           <= q_rk(i) xor q_rk((25+i) mod 32);
        sr_rk_in_array(i)               <= q_rk(i) xor q_rk((25+i) mod 32);
      end loop;
      sr_start                          <= '1';
      sr_x_in_array                     <= (q_h(12),q_h(13),q_h(14),q_h(15));
      shavite512_state_next             <= EXEC_17;
    when EXEC_17 =>
      count_1_en                        <= sr_rnd_almost_ready;
      if sr_rnd_almost_ready = '1' then
        for i in 0 to 3 loop
          rk(i + to_integer((q_count_1 + 1) & "00")) <= q_rk(i + to_integer((q_count_1 + 1) & "00")) xor q_rk((25 + (i + to_integer((q_count_1 + 1) & "00"))) mod 32);
        end loop;
      end if;
      if sr_rnd_new = '1' then
        x                               <= sr_x_out_array;
        sr_start                        <= '1';
        if q_count_1 = 4 then
          sr_x_in_array                 <= (q_h(4),q_h(5),q_h(6),q_h(7));
          shavite512_state_next         <= EXEC_18;
        else
          sr_start                      <= '1';
          sr_x_in_array                 <= sr_x_out_array;
        end if;
      end if;
    when EXEC_18 =>
      count_1_en                        <= sr_rnd_almost_ready;
      if sr_rnd_almost_ready = '1' then
        for i in 0 to 3 loop
          rk(i + to_integer((q_count_1 + 1) & "00")) <= q_rk(i + to_integer((q_count_1 + 1) & "00")) xor q_rk((25 + (i + to_integer((q_count_1 + 1) & "00"))) mod 32);
        end loop;
        for i in 0 to 3 loop
          h(8+i)                        <= q_h(8+i) xor q_x(i);
        end loop;
      end if;
      if sr_rnd_new = '1' then
        sr_start                          <= '1';
        sr_x_in_array                     <= sr_x_out_array;
        shavite512_state_next             <= EXEC_19;
      end if;
    when EXEC_19 =>
      count_1_en                        <= sr_rnd_almost_ready;
      if sr_rnd_almost_ready = '1' and q_count_1 /= 7 then
        for i in 0 to 3 loop
          rk(i + to_integer((q_count_1 + 1) & "00")) <= q_rk(i + to_integer((q_count_1 + 1) & "00")) xor q_rk((25 + (i + to_integer((q_count_1 + 1) & "00"))) mod 32);
        end loop;
      end if;
      if sr_rnd_new = '1' then
        x                               <= sr_x_out_array;
        if q_count_1 = 0 then
          sr_start                      <= '1';
          sr_ke                         <= '1';
          shavite512_state_next         <= EXEC_20;
        else
          sr_start                      <= '1';
          sr_x_in_array                 <= sr_x_out_array;
        end if;
      end if;
    when EXEC_20 =>
      if sr_rnd_almost_ready = '1' then
        for i in 0 to 3 loop
          h(i)                          <= q_h(i) xor q_x(i);
        end loop;
      end if;
      if sr_rnd_new = '1' then
        rk                              <= sr_rk_out_array;          
        sr_rk_in_array                  <= sr_rk_out_array;
        sr_start                        <= '1';
        sr_x_in_array                   <= (q_h(8),q_h(9),q_h(10),q_h(11));
        shavite512_state_next           <= EXEC_21;
      end if;
    when EXEC_21 =>
      count_1_en                        <= sr_rnd_almost_ready and not q_rx_ke_toggle;
      if sr_rnd_new = '1' then
        rx_ke_toggle                    <= not q_rx_ke_toggle;
        if q_rx_ke_toggle = '0' then
          x                             <= sr_x_out_array;
          sr_start                      <= '1';
          sr_ke                         <= '1';
          if q_count_1 = 4 then
            shavite512_state_next       <= EXEC_22;
          end if;
        else
          rk                            <= sr_rk_out_array;
          sr_rk_in_array                <= sr_rk_out_array;
          sr_start                      <= '1';
        end if;
      end if;    
    when EXEC_22 =>
      if sr_rnd_almost_ready = '1' then
        for i in 0 to 3 loop
          h(4+i)                        <= q_h(4+i) xor q_x(i);
        end loop;
      end if;
      if sr_rnd_new = '1' then
        rx_ke_toggle                    <= not q_rx_ke_toggle;
        rk                              <= sr_rk_out_array;
        sr_rk_in_array                  <= sr_rk_out_array;
        sr_start                        <= '1';
        sr_x_in_array                   <= (q_h(0),q_h(1),q_h(2),q_h(3));
        shavite512_state_next           <= EXEC_23;
      end if;
    when EXEC_23 =>
      count_1_en                        <= sr_rnd_almost_ready and not q_rx_ke_toggle;
      if sr_rnd_new = '1' then
        rx_ke_toggle                    <= not q_rx_ke_toggle;
        if q_rx_ke_toggle = '0' then
          x                             <= sr_x_out_array;
          if q_count_1 = 0 then
            shavite512_state_next       <= EXEC_24;
          else
            sr_start                    <= '1';
            sr_ke                       <= '1';
          end if;
        else
          rk                            <= sr_rk_out_array;
          sr_rk_in_array                <= sr_rk_out_array;
          sr_start                      <= '1';
        end if;
      end if;
    when EXEC_24 =>
      for i in 0 to 3 loop
        h(12+i)                         <= q_h(12+i) xor q_x(i);
      end loop;
      for i in 0 to 3 loop
        rk(i)                           <= q_rk(i) xor q_rk((25+i) mod 32);
        sr_rk_in_array(i)               <= q_rk(i) xor q_rk((25+i) mod 32);
      end loop;
      sr_start                          <= '1';
      sr_x_in_array                     <= (q_h(4),q_h(5),q_h(6),q_h(7));
      shavite512_state_next             <= EXEC_25;
    when EXEC_25 =>
      count_1_en                        <= sr_rnd_almost_ready;
      if sr_rnd_almost_ready = '1' then
        for i in 0 to 3 loop
          rk(i + to_integer((q_count_1 + 1) & "00")) <= q_rk(i + to_integer((q_count_1 + 1) & "00")) xor q_rk((25 + (i + to_integer((q_count_1 + 1) & "00"))) mod 32);
        end loop;
      end if;
      if sr_rnd_new = '1' then
        x                               <= sr_x_out_array;
        sr_start                        <= '1';
        if q_count_1 = 4 then
          sr_x_in_array                 <= (q_h(12),q_h(13),q_h(14),q_h(15));
          shavite512_state_next         <= EXEC_26;
        else
          sr_x_in_array                 <= sr_x_out_array;
        end if;
      end if;
    when EXEC_26 =>
      count_1_en                        <= sr_rnd_almost_ready;
      if sr_rnd_almost_ready = '1' then
        for i in 0 to 3 loop
          rk(i + to_integer((q_count_1 + 1) & "00")) <= q_rk(i + to_integer((q_count_1 + 1) & "00")) xor q_rk((25 + (i + to_integer((q_count_1 + 1) & "00"))) mod 32);
        end loop;
        for i in 0 to 3 loop
          h(i)                          <= q_h(i) xor q_x(i);
        end loop;
      end if;
      if sr_rnd_new = '1' then
        x                               <= sr_x_out_array;
        sr_start                        <= '1';
        sr_x_in_array                   <= sr_x_out_array;
        shavite512_state_next           <= EXEC_27;
      end if;
    when EXEC_27 =>
      count_1_en                        <= sr_rnd_almost_ready;
      if sr_rnd_almost_ready = '1' and q_count_1 /= 7 then
        for i in 0 to 3 loop
          rk(i + to_integer((q_count_1 + 1) & "00")) <= q_rk(i + to_integer((q_count_1 + 1) & "00")) xor q_rk((25 + (i + to_integer((q_count_1 + 1) & "00"))) mod 32);
        end loop;
      end if;
      if sr_rnd_new = '1' then
        x                               <= sr_x_out_array;
        if q_count_1 = 0 then
          shavite512_state_next         <= EXEC_28;
        else
          sr_start                      <= '1';
          sr_x_in_array                 <= sr_x_out_array;
        end if;
      end if;
    when EXEC_28 =>
      for i in 0 to 3 loop
        h(8+i)                          <= q_h(8+i) xor q_x(i);  
      end loop;
      sr_start                          <= '1';
      sr_ke                             <= '1';
      if q_count_2 = 2 then
        shavite512_state_next           <= EXEC_29;
      else
        count_2_en                      <= '1';
        shavite512_state_next           <= EXEC_5;
      end if;
    when EXEC_29 =>
      rx_ke_toggle                      <= '0';
      if sr_rnd_new = '1' then
        rk                              <= sr_rk_out_array;
        sr_rk_in_array                  <= sr_rk_out_array;
        sr_start                        <= '1';
        sr_x_in_array                   <= (q_h(0),q_h(1),q_h(2),q_h(3));
        shavite512_state_next           <= EXEC_30;
      end if;
    when EXEC_30 =>
      count_1_en                        <= sr_rnd_almost_ready and not q_rx_ke_toggle;
      if sr_rnd_new = '1' then
        rx_ke_toggle                    <= not q_rx_ke_toggle;
        if q_rx_ke_toggle = '0' then
          x                             <= sr_x_out_array;
          sr_start                      <= '1';
          sr_ke                         <= '1';
          if q_count_1 = 4 then
            shavite512_state_next       <= EXEC_31;
          end if;
        else
          rk                            <= sr_rk_out_array;
          sr_rk_in_array                <= sr_rk_out_array;
          sr_start                      <= '1';
        end if;
      end if;
    when EXEC_31 =>
      if sr_rnd_almost_ready = '1' then
        for i in 0 to 3 loop
          h(12+i)                       <= q_h(12+i) xor q_x(i);
        end loop;
      end if;
      if sr_rnd_new = '1' then
        rx_ke_toggle                    <= not q_rx_ke_toggle;
        rk                              <= sr_rk_out_array;
        sr_rk_in_array                  <= sr_rk_out_array;
        sr_start                        <= '1';
        sr_x_in_array                   <= (q_h(8),q_h(9),q_h(10),q_h(11));
        shavite512_state_next           <= EXEC_32;
      end if;
    when EXEC_32 =>
      count_1_en                        <= sr_rnd_almost_ready and not q_rx_ke_toggle;
      if sr_rnd_new = '1' then
        rx_ke_toggle                    <= not q_rx_ke_toggle;
        if q_rx_ke_toggle = '0' then
          x                             <= sr_x_out_array;
          if q_count_1 = 0 then
            shavite512_state_next       <= EXEC_33;
          else
            sr_start                    <= '1';
            sr_ke                       <= '1';
            if q_count_1 = 6 then
              sr_ke_xor_type            <= '1';
            end if;
          end if;
        else
          rk                            <= sr_rk_out_array;
          sr_rk_in_array                <= sr_rk_out_array;
          sr_start                      <= '1';
        end if;
      end if;
    when EXEC_33 =>
      for i in 0 to 3 loop
        h(4+i)                          <= q_h(4+i) xor q_x(i);
      end loop;
      shavite512_state_next             <= EXEC_34;
    when EXEC_34 =>
      for i in 0 to 15 loop
        h(i)                            <= IV(i) xor q_h((8+i) mod 16); 
      end loop;
      almost_done                       <= '1';
      shavite512_state_next             <= FINISH;
    when FINISH =>
      done                              <= '1';
      if pause = '0' then
        shavite512_state_next           <= IDLE;
      end if;
    end case;
  end process shavite512_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_shavite512_state                <= IDLE;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        q_shavite512_state              <= shavite512_state_next;
        q_x                             <= x;
        q_rk                            <= rk;
        q_h                             <= h;
        q_rx_ke_toggle                  <= rx_ke_toggle;
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
  
end architecture shavite512_ce_rtl;