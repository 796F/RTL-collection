--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity groestl512 is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  data_in                               : in std_logic_vector(511 downto 0);
  hash                                  : out std_logic_vector(511 downto 0);
  hash_new                              : out std_logic
);
end entity groestl512;

architecture groestl512_rtl of groestl512 is
  
  alias slv is std_logic_vector;
  
  component groestl512_round is
  port (
    clk                                 : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    pq_sel                              : in std_logic;
    data_in                             : in std_logic_vector(1023 downto 0);
    data_out                            : out std_logic_vector(1023 downto 0);
    data_new                            : out std_logic
  );
  end component groestl512_round;
 
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  subtype natural_0_7 is natural range 0 to 7;
  type nat_array_8 is array(0 to 7) of natural;
  type groestl512_state is (IDLE, EXEC_0, EXEC_1, EXEC_2, EXEC_3, EXEC_4, FINISH);
                        
  constant zeros64 : word64 := (others => '0');
  
  function byte_sel(x: word64; n: natural_0_7) return unsigned is
  begin
    return unsigned(x((n+1)*8-1 downto n*8));
  end byte_sel;
  
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
  
  function pc64(j: word64; r: natural) return word64 is
  begin
    return slv(unsigned(j) + to_unsigned(r,64));
  end function pc64;
  
  function qc64(j: word64; r: natural) return word64 is
  begin
    return word64(shl(slv(to_unsigned(r,64)),56) xnor shl(slv(j),56));
  end function qc64;
  
  type word64_array16 is array(0 to 15) of word64;
  type word64_array8 is array(0 to 7) of word64;
  
  constant IV                           : word64_array16 := (X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0000000000000000",
                                                             X"0000000000000000", X"0002000000000000");
  constant PADDING                      : word64_array8 := (X"0000000000000080", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0000000000000000",
                                                            X"0000000000000000", X"0100000000000000");
  
  signal groestl512_state_next          : groestl512_state;
  signal data_in_array                  : word64_array8;
  signal g512r_di                       : slv(1023 downto 0);
  signal g512r_do                       : slv(1023 downto 0);
  signal g512r_di_vec                   : word64_array16;
  signal g512r_do_vec                   : word64_array16;
  signal g512r_start                    : std_logic;
  signal pq_sel                         : std_logic;
  signal g512r_data_new                 : std_logic;
  signal m                              : word64_array16;
  signal h                              : word64_array16;
  signal g                              : word64_array16;
  signal done                           : std_logic;
  
  signal q_groestl512_state             : groestl512_state;
  signal q_m                            : word64_array16;
  signal q_h                            : word64_array16;
  signal q_g                            : word64_array16;
  
begin

  hash_new                              <= done;
  
  output_mapping : for i in 0 to 7 generate
    hash((i+1)*64-1 downto i*64)        <= q_h(i+8);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 7 generate
    data_in_array(i)                    <= data_in((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  array_mapping : for i in 0 to 15 generate
    g512r_di((i+1)*64-1 downto i*64)    <= g512r_di_vec(i);
    g512r_do_vec(i)                     <= g512r_do((i+1)*64-1 downto i*64);
  end generate array_mapping;
  
  groestl512_round_inst : groestl512_round
  port map (
    clk                                 => clk,
    reset                               => reset,
    start                               => g512r_start,
    pq_sel                              => pq_sel,
    data_in                             => g512r_di,
    data_out                            => g512r_do,
    data_new                            => g512r_data_new
  );
  
  groestl512_proc : process(q_groestl512_state, q_m, q_h, q_g, data_in_array, start, g512r_data_new,
                            g512r_do_vec)
  begin
    groestl512_state_next               <= q_groestl512_state;
    m                                   <= q_m;
    h                                   <= q_h;
    g                                   <= q_g;
    g512r_start                         <= '0';
    pq_sel                              <= '1';
    g512r_di_vec                        <= (others => (others => '0'));
    done                                <= '0';
    case q_groestl512_state is
    when IDLE =>
      for i in 0 to 7 loop
        m(i)                            <= data_in_array(i);
      end loop;
      for i in 8 to 15 loop
        m(i)                            <= PADDING(i-8);
      end loop;
      g(15)                             <= PADDING(7) xor IV(15);
      g512r_di_vec(15)                  <= PADDING(7) xor IV(15);
      for i in 0 to 7 loop
        g(i)                            <= data_in_array(i);
        g512r_di_vec(i)                 <= data_in_array(i);
      end loop;
      for i in 8 to 14 loop
        g(i)                            <= PADDING(i-8);
        g512r_di_vec(i)                 <= PADDING(i-8); 
      end loop;
      if start = '1' then
        g512r_start                     <= '1';
        groestl512_state_next           <= EXEC_0;
      end if;
    when EXEC_0 =>
      for i in 0 to 15 loop
        h(i)                            <= IV(i);
      end loop;
      g512r_di_vec                      <= q_g;
      if g512r_data_new = '1' then
        g                               <= g512r_do_vec;
        g512r_start                     <= '1';
        g512r_di_vec                    <= q_m;
        pq_sel                          <= '0';
        groestl512_state_next           <= EXEC_1;
      end if;
    when EXEC_1 =>
      g512r_di_vec                      <= q_m;
      pq_sel                            <= '0';
      if g512r_data_new = '1' then
        m                               <= g512r_do_vec;
        groestl512_state_next           <= EXEC_2;
      end if;
    when EXEC_2 =>
      for i in 0 to 15 loop
        h(i)                            <= q_h(i) xor q_g(i) xor q_m(i);
      end loop;
      g512r_start                       <= '1';
      g512r_di_vec                      <= h;
      groestl512_state_next             <= EXEC_3;
    when EXEC_3 =>
      g512r_di_vec                      <= q_h;
      if g512r_data_new = '1' then
        g                               <= g512r_do_vec;
        groestl512_state_next           <= EXEC_4;
      end if;
    when EXEC_4 =>
      for i in 0 to 15 loop
        h(i)                            <= q_h(i) xor q_g(i);
      end loop;    
      groestl512_state_next             <= FINISH;
    when FINISH =>
      done                              <= '1';
      groestl512_state_next             <= IDLE;
    end case;
  end process groestl512_proc;

  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_groestl512_state                <= IDLE;
    elsif rising_edge(clk) then
      q_groestl512_state                <= groestl512_state_next;
      q_m                               <= m;
      q_h                               <= h;
      q_g                               <= g;
    end if;
  end process registers;
  
end architecture groestl512_rtl;