--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity luffa512_p_ce is
port (
  clk                                   : in std_logic;
  clk_en                                : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  x_in                                  : in std_logic_vector(1279 downto 0);
  x_out                                 : out std_logic_vector(1279 downto 0);
  x_new                                 : out std_logic
);
end entity luffa512_p_ce;

architecture luffa512_p_ce_rtl of luffa512_p_ce is
  
  alias slv is std_logic_vector;
  
  component luffa512_sc_mw_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    a                                   : in std_logic_vector(63 downto 0);
    b                                   : in std_logic_vector(63 downto 0);
    x_in                                : in std_logic_vector(511 downto 0);
    x_out                               : out std_logic_vector(511 downto 0);
    x_new                               : out std_logic
  );
  end component luffa512_sc_mw_ce;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  type p_state is (IDLE, P_1, P_2, P_3, FINISH);
                        
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

  type word64_array8 is array(0 to 7) of word64;
  type word32_array40 is array(0 to 39) of word32;
  type word32_array8 is array(0 to 7) of word32;
    
  function tweak(x: word32_array40) return word32_array40 is
    variable x2                         : word32_array40;
  begin
    x2                                  := x;
    x2(12)                              := rotl32(x2(12),1);
    x2(13)                              := rotl32(x2(13),1);
    x2(14)                              := rotl32(x2(14),1);
    x2(15)                              := rotl32(x2(15),1);
    x2(20)                              := rotl32(x2(20),2);
    x2(21)                              := rotl32(x2(21),2);
    x2(22)                              := rotl32(x2(22),2);
    x2(23)                              := rotl32(x2(23),2);
    x2(28)                              := rotl32(x2(28),3);
    x2(29)                              := rotl32(x2(29),3);
    x2(30)                              := rotl32(x2(30),3);
    x2(31)                              := rotl32(x2(31),3);
    x2(36)                              := rotl32(x2(36),4);
    x2(37)                              := rotl32(x2(37),4);
    x2(38)                              := rotl32(x2(38),4);
    x2(39)                              := rotl32(x2(39),4);
    return x2;
  end tweak;
  
  constant RCW010                       : word64_array8 := (X"b6de10ed303994a6", X"70f47aaec0e65299",
                                                            X"0707a3d46cc33a12", X"1c1e8f51dc56983e",
                                                            X"707a3d451e00108f", X"aeb285627800423d",
                                                            X"baca15898f5b7882", X"40a46f3e96e1db12");
  constant RCW014                       : word64_array8 := (X"01685f3de0337818", X"05a17cf4441ba90d",
                                                            X"bd09caca7f34d442", X"f4272b289389217f",
                                                            X"144ae5cce5a8bce6", X"faa7ae2b5274baf4",
                                                            X"2e48f1c126889ba7", X"b923c7049a226e9d");
  constant RCW230                       : word64_array8 := (X"b213afa5fc20d9d2", X"c84ebe9534552e25",
                                                            X"4e608a227ad8818f", X"56d858fe8438764a",
                                                            X"343b138fbb6de032", X"d0ec4e3dedb780c8",
                                                            X"2ceb4882d9847356", X"b3ad2208a2c78434");
  constant RCW234                       : word64_array8 := (X"e028c9bfe25e72c1", X"44756f91e623bb72",
                                                            X"7e8fce325c58a4a4", X"956548be1e38e2e7",
                                                            X"fe191be278e38b9d", X"3cb226e527586719",
                                                            X"5944a28e36eda57f", X"a1c4c355703aace7");
  constant RC40                         : word32_array8 := (X"f0d2e9e3",X"ac11d7fa",
                                                            X"1bcb66f2",X"6f2d9bc9",
                                                            X"78602649",X"8edae952",
                                                            X"3b6ba548",X"edae9520");
  constant RC44                         : word32_array8 := (X"5090d577",X"2d1925ab",
                                                            X"b46496ac",X"d1925ab0",
                                                            X"29131ab6",X"0fc053c3",
                                                            X"3f014f0c",X"fc053c31");

  constant ZEROS_WORD64_ARRAY8          : word64_array8 := (others => zeros64);
  
  signal p_state_next                   : p_state;
  signal count_start                    : std_logic;
  signal count_en                       : std_logic;
  signal x_in_array                     : word32_array40;
  signal x_tweak                        : word32_array40;
  signal x                              : word32_array40;
  signal sc_mw_start                    : std_logic;
  signal sc_mw_a                        : word64;
  signal sc_mw_b                        : word64;
  signal sc_mw_x_in                     : slv(511 downto 0);
  signal sc_mw_x_in_array               : word64_array8;
  signal sc_mw_x_out                    : slv(511 downto 0);
  signal sc_mw_x_out_array              : word64_array8;
  signal sc_mw_x_new                    : std_logic;
  signal done                           : std_logic;
  
  signal q_p_state                      : p_state;
  signal q_count                        : unsigned(2 downto 0);
  signal q_x                            : word32_array40;  
  
begin

  x_new                                 <= done;
  
  output_mapping : for i in 0 to 39 generate
    x_out((i+1)*32-1 downto i*32)       <= q_x(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 39 generate
    x_in_array(i)                       <= x_in((i+1)*32-1 downto i*32);
  end generate input_mapping;
  
  array_mapping : for i in 0 to 7 generate
    sc_mw_x_in((i+1)*64-1 downto i*64)  <= sc_mw_x_in_array(i);
    sc_mw_x_out_array(i)                <= sc_mw_x_out((i+1)*64-1 downto i*64);  
  end generate array_mapping;
  
  x_tweak                               <= tweak(x_in_array);
  
  luffa512_sc_mw_inst : luffa512_sc_mw_ce
  port map (
    clk                                 => clk,
    clk_en                              => clk_en,
    reset                               => reset,
    start                               => sc_mw_start,
    a                                   => sc_mw_a,
    b                                   => sc_mw_b,
    x_in                                => sc_mw_x_in,
    x_out                               => sc_mw_x_out,
    x_new                               => sc_mw_x_new
  );
  
  p_proc : process(q_p_state, q_x, start, x_tweak, sc_mw_x_new, q_count, sc_mw_x_out_array)
  begin
    p_state_next                        <= q_p_state;
    count_start                         <= '1';
    count_en                            <= '0';
    x                                   <= q_x;
    sc_mw_start                         <= '0';
    sc_mw_x_in_array                    <= ZEROS_WORD64_ARRAY8;
    sc_mw_a                             <= (others => '0');
    sc_mw_b                             <= (others => '0');
    done                                <= '0';
    case q_p_state is
    when IDLE =>
      if start = '1' then
        x                               <= x_tweak;
        for i in 0 to 7 loop
          sc_mw_x_in_array(i)           <= x_tweak(8+i) & x_tweak(i);
        end loop;
        sc_mw_a                         <= RCW010(0);
        sc_mw_b                         <= RCW014(0);
        sc_mw_start                     <= '1';
        p_state_next                    <= P_1;
      end if;
    when P_1 =>
      count_start                       <= '0';
      count_en                          <= sc_mw_x_new;
      if sc_mw_x_new = '1' then
        sc_mw_x_in_array                <= sc_mw_x_out_array;
        for i in 0 to 7 loop
          x(i)                          <= sc_mw_x_out_array(i)(31 downto 0);
          x(8+i)                        <= sc_mw_x_out_array(i)(63 downto 32);  
        end loop;
      else
        for i in 0 to 7 loop
          sc_mw_x_in_array(i)           <= q_x(8+i) & q_x(i);
        end loop;
      end if;
      sc_mw_a                           <= RCW010(to_integer(q_count));
      sc_mw_b                           <= RCW014(to_integer(q_count));
      sc_mw_start                       <= sc_mw_x_new;
      if q_count = 7 and sc_mw_x_new = '1' then
        for i in 0 to 7 loop
          x(i)                          <= sc_mw_x_out_array(i)(31 downto 0);
          x(8+i)                        <= sc_mw_x_out_array(i)(63 downto 32);  
          sc_mw_x_in_array(i)           <= q_x(24 + i) & q_x(16 + i);
        end loop;
        sc_mw_a                         <= RCW230(0);
        sc_mw_b                         <= RCW234(0);
        count_start                     <= '1';
        count_en                        <= '0';  
        p_state_next                    <= P_2;
      end if;
    when P_2 =>
      count_start                       <= '0';
      count_en                          <= sc_mw_x_new;
      if sc_mw_x_new = '1' then
        sc_mw_x_in_array                <= sc_mw_x_out_array;
        for i in 0 to 7 loop
          x(16+i)                       <= sc_mw_x_out_array(i)(31 downto 0);
          x(24+i)                       <= sc_mw_x_out_array(i)(63 downto 32);  
        end loop;
      else
        for i in 0 to 7 loop
          sc_mw_x_in_array(i)           <= q_x(24 + i) & q_x(16 + i);
        end loop;
      end if;
      sc_mw_a                           <= RCW230(to_integer(q_count));
      sc_mw_b                           <= RCW234(to_integer(q_count));
      sc_mw_start                       <= sc_mw_x_new;
      if q_count = 7 and sc_mw_x_new = '1' then
        for i in 0 to 7 loop
          x(16+i)                       <= sc_mw_x_out_array(i)(31 downto 0);
          x(24+i)                       <= sc_mw_x_out_array(i)(63 downto 32);
          sc_mw_x_in_array(i)           <= zeros32 & q_x(32+i);
        end loop;
        sc_mw_a                         <= zeros32 & RC40(0);
        sc_mw_b                         <= zeros32 & RC44(0);
        count_start                     <= '1';
        count_en                        <= '0';
        p_state_next                    <= P_3;
      end if;
    when P_3 =>
      count_start                       <= '0';
      count_en                          <= sc_mw_x_new;
      if sc_mw_x_new = '1' then
        sc_mw_x_in_array                <= sc_mw_x_out_array;
        for i in 0 to 7 loop
          x(32+i)                       <= sc_mw_x_out_array(i)(31 downto 0);
        end loop;
      else
        for i in 0 to 7 loop
          sc_mw_x_in_array(i)           <= zeros32 & q_x(32+i);
        end loop;
      end if;
      sc_mw_a                           <= zeros32 & RC40(to_integer(q_count));
      sc_mw_b                           <= zeros32 & RC44(to_integer(q_count));
      sc_mw_start                       <= sc_mw_x_new;  
      if q_count = 7 and sc_mw_x_new = '1' then
        for i in 0 to 7 loop
          x(32+i)                       <= sc_mw_x_out_array(i)(31 downto 0);
        end loop;
        sc_mw_start                     <= '0';    
        p_state_next                    <= FINISH;
      end if;
    when FINISH =>
      done                              <= '1';
      p_state_next                      <= IDLE;
    end case;
  end process p_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_p_state                         <= IDLE;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        q_p_state                       <= p_state_next;
        q_x                             <= x;
        if count_start = '1' then
          q_count                       <= (others => '0');
        elsif count_en = '1' then
          q_count                       <= q_count + 1;
        end if;
      end if;
    end if;
  end process registers;
  
end architecture luffa512_p_ce_rtl;