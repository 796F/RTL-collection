--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity jh512 is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  data_in                               : in std_logic_vector(511 downto 0);
  hash                                  : out std_logic_vector(511 downto 0);
  hash_new                              : out std_logic
);
end entity jh512;

architecture jh512_rtl of jh512 is
  
  alias slv is std_logic_vector;
  
  component jh512_slu is
  port (
    clk                                 : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    r                                   : in std_logic_vector(5 downto 0);
    h_in                                : in std_logic_vector(1023 downto 0);
    h_out                               : out std_logic_vector(1023 downto 0);
    h_new                               : out std_logic
  );
  end component jh512_slu;
  
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  type nat_array_8 is array(0 to 7) of natural;
  type nat_array_4 is array(0 to 3) of natural;
  type jh512_state is (IDLE, INIT, E, H_GEN, FINISH);
                        
  constant zeros64 : word64 := (others => '0');
  
  function endian_swap(x: word64) return word64 is
  begin
    return word64(x(7 downto 0)   & x(15 downto 8)  & x(23 downto 16) & x(31 downto 24) &
                  x(39 downto 32) & x(47 downto 40) & x(55 downto 48) & x(63 downto 56));
  end endian_swap;
  
  function shr(x: word64; n: natural) return word64 is
  begin
    return word64(zeros64(n-1 downto 0) & x(x'high downto n));
  end shr;
  
  function shl(x: word64; n: natural) return word64 is
  begin
    return word64(x(x'high-n downto 0) & zeros64(x'high downto x'length-n));
  end shl;
  
  function rotr(x: word64; n: natural) return word64 is
  begin
    return word64(x(n-1 downto 0) & x(x'high downto n));
  end rotr;
  
  function rotl(x: word64; n: natural) return word64 is
  begin
    return word64(x(x'high-n downto 0) & x(x'high downto x'length-n));
  end rotl;
  
  type word64_array16 is array(0 to 15) of word64;
  type word64_array8 is array(0 to 7) of word64;
  
  constant IV                           : word64_array16 := (X"6fd14b963e00aa17", X"636a2e057a15d543",
                                                             X"8a225e8d0c97ef0b", X"e9341259f2b3c361",
                                                             X"891da0c1536f801e", X"2aa9056bea2b6d80",
                                                             X"588eccdb2075baa6", X"a90f3a76baf83bf7",
                                                             X"0169e60541e34a69", X"46b58a8e2e6fe65a",
                                                             X"1047a7d0c1843c24", X"3b6e71b12d5ac199",
                                                             X"cf57f6ec9db1f856", X"a706887c5716b156",
                                                             X"e3c2fcdfe68517fb", X"545a4678cc8cdd4b");
  constant PADDING                      : word64_array8 := (X"0000000000000080", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0002000000000000");
  
  signal jh512_state_next               : jh512_state;
  signal count_start                    : std_logic;
  signal count_en                       : std_logic;
  signal last_pass                      : std_logic;
  signal data_in_array                  : word64_array8;
  signal m                              : word64_array8;
  signal h                              : word64_array16;
  signal slu_start                      : std_logic;
  signal slu_h                          : slv(1023 downto 0);
  signal slu_h_new                      : std_logic;
  signal slu_h_int                      : word64_array16;
  signal done                           : std_logic;
  
  signal q_jh512_state                  : jh512_state;
  signal q_last_pass                    : std_logic;
  signal q_m                            : word64_array8;
  signal q_h                            : word64_array16;
  signal q_h_vec                        : slv(1023 downto 0);
  signal q_count                        : unsigned(5 downto 0);
  
begin

  hash_new                              <= done;
  
  output_mapping : for i in 0 to 7 generate
    hash((i+1)*64-1 downto i*64)        <= q_h(8+i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 7 generate
    data_in_array(i)                    <= data_in((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  array_mapping : for i in 0 to 15 generate
    q_h_vec((i+1)*64-1 downto i*64)     <= q_h(i);
    slu_h_int(i)                        <= slu_h((i+1)*64-1 downto i*64);
  end generate array_mapping;
  
  jh512_slu_inst : jh512_slu
  port map (
    clk                                 => clk,
    reset                               => reset,
    start                               => slu_start,
    r                                   => slv(q_count),
    h_in                                => q_h_vec,
    h_out                               => slu_h,
    h_new                               => slu_h_new
  );
  
  jh512_proc : process(q_jh512_state, q_last_pass, q_m, q_h, data_in_array, start, slu_h_new,
                       slu_h_int, q_count)
  begin
    jh512_state_next                    <= q_jh512_state;
    count_start                         <= '1';
    count_en                            <= '0';
    slu_start                           <= '0';
    last_pass                           <= q_last_pass;
    m                                   <= q_m;
    h                                   <= q_h;
    done                                <= '0';
    case q_jh512_state is
    when IDLE =>
      last_pass                         <= '0';
      m                                 <= data_in_array;
      if start = '1' then
        for i in 0 to 15 loop
          h(i)                          <= endian_swap(IV(i));
        end loop;
        jh512_state_next                <= INIT;
      end if;
    when INIT =>
      for i in 0 to 7 loop
        h(i)                            <= q_h(i) xor q_m(i);
      end loop;
      slu_start                         <= '1';
      jh512_state_next                  <= E;
    when E =>
      count_start                       <= '0';
      count_en                          <= slu_h_new;
      if slu_h_new = '1' then
        h                               <= slu_h_int;
        if q_count = 41 then
          jh512_state_next              <= H_GEN;
        else
          slu_start                     <= '1';
        end if;
      end if;
    when H_GEN =>
      for i in 0 to 7 loop
        h(8+i)                          <= q_h(8+i) xor q_m(i);
      end loop;
      if q_last_pass = '1' then
        jh512_state_next                <= FINISH;
      else
        last_pass                       <= '1';
        m                               <= PADDING;
        jh512_state_next                <= INIT;
      end if;
    when FINISH =>
      done                              <= '1';
      jh512_state_next                  <= IDLE;
    end case;
  end process jh512_proc;

  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_jh512_state                     <= IDLE;
    elsif rising_edge(clk) then
      q_jh512_state                     <= jh512_state_next;
      q_last_pass                       <= last_pass;
      q_m                               <= m;
      q_h                               <= h;
      if count_start = '1' then
        q_count                         <= (others => '0');
      elsif count_en = '1' then
        q_count                         <= q_count + 1;
      end if;
    end if;
  end process registers;
  
end architecture jh512_rtl;