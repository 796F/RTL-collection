--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak512_ce is
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
end entity keccak512_ce;

architecture keccak512_ce_rtl of keccak512_ce is
  
  alias slv is std_logic_vector;
  
  component keccak512_kf_elt_ce is
  port (
    clk                                 : in std_logic;
    clk_en                              : in std_logic;
    reset                               : in std_logic;
    start                               : in std_logic;
    i                                   : in std_logic_vector(2 downto 0);
    j                                   : in std_logic_vector(3 downto 0);
    k                                   : in std_logic_vector(4 downto 0);
    x_in                                : in std_logic_vector(1599 downto 0);
    x_out                               : out std_logic_vector(1599 downto 0);
    x_new                               : out std_logic;
    x_almost_ready                      : out std_logic
  );
  end component keccak512_kf_elt_ce;
  
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  type keccak512_state is (IDLE, INIT, EXEC, H_GEN, FINISH);
                        
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
  
  type word64_array25 is array(0 to 24) of word64;
  type word64_array8 is array(0 to 7) of word64;
  
  function gen_h(x: word64_array25) return word64_array25 is
    variable x2                         : word64_array25;
  begin
    for i in 0 to 24 loop
      x2(i)                             := x((i mod 5)*5 + i/5);
    end loop;
    x2(1)                               := not x2(1);
    x2(2)                               := not x2(2);
    x2(8)                               := not x2(8);
    x2(12)                              := not x2(12);
    x2(17)                              := not x2(17);
    x2(20)                              := not x2(20);
    return x2;
  end function gen_h;
  
  constant IV                           : word64_array25 := (X"0000000000000000",X"0000000000000000",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"FFFFFFFFFFFFFFFF",X"FFFFFFFFFFFFFFFF",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"FFFFFFFFFFFFFFFF",X"0000000000000000",
                                                             X"FFFFFFFFFFFFFFFF",X"FFFFFFFFFFFFFFFF",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"FFFFFFFFFFFFFFFF",X"0000000000000000",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"0000000000000000",X"0000000000000000",
                                                             X"0000000000000000");
  
  signal keccak512_state_next           : keccak512_state;
  signal count_start                    : std_logic;
  signal count_en                       : std_logic;
  signal data_in_array                  : word64_array8;
  signal h                              : word64_array25;
  signal ke_start                       : std_logic;
  signal i                              : slv(2 downto 0);
  signal j                              : slv(3 downto 0);
  signal k                              : slv(4 downto 0);
  signal ke_x_in                        : slv(1599 downto 0);
  signal ke_x_in_array                  : word64_array25;
  signal ke_x_out                       : slv(1599 downto 0);
  signal ke_x_out_array                 : word64_array25;
  signal ke_x_new                       : std_logic;
  signal ke_x_almost_ready              : std_logic;
  signal done                           : std_logic;
  signal almost_done                    : std_logic;
  
  signal q_keccak512_state              : keccak512_state;
  signal q_h                            : word64_array25;
  signal q_ke_x_new                     : std_logic;
  signal q_count                        : unsigned(4 downto 0);
  
begin

  hash_new                              <= done;
  hash_almost_new                       <= almost_done;
  
  output_mapping : for l in 0 to 7 generate
    hash((l+1)*64-1 downto l*64)        <= q_h(l);
  end generate output_mapping;
  
  input_mapping : for l in 0 to 7 generate
    data_in_array(l)                    <= data_in((l+1)*64-1 downto l*64);
  end generate input_mapping;
  
  array_mapping : for l in 0 to 24 generate
    ke_x_in((l+1)*64-1 downto l*64)     <= ke_x_in_array(l);
    ke_x_out_array(l)                   <= ke_x_out((l+1)*64-1 downto l*64);
  end generate array_mapping;

  i                                     <= slv(to_unsigned(to_integer(q_count) mod 8,i'length));
  j                                     <= slv(to_unsigned((to_integer(q_count) mod 8) + 1,j'length));
  k                                     <= slv(q_count);
  
  keccak512_kf_elt_inst : keccak512_kf_elt_ce
  port map (
    clk                                 => clk,
    clk_en                              => clk_en,
    reset                               => reset,
    start                               => ke_start,
    i                                   => i,
    j                                   => j,
    k                                   => k,
    x_in                                => ke_x_in,
    x_out                               => ke_x_out,
    x_new                               => ke_x_new,
    x_almost_ready                      => ke_x_almost_ready
  );
  
  keccak512_proc : process(q_keccak512_state, q_h, start, data_in_array, ke_x_new, q_ke_x_new, ke_x_almost_ready, ke_x_out_array, q_count, pause)
  begin
    keccak512_state_next                <= q_keccak512_state;
    busy_n                              <= '0';
    count_start                         <= '1';
    count_en                            <= '0';
    ke_start                            <= '0';
    h                                   <= q_h;
    ke_x_in_array                       <= q_h;
    almost_done                         <= '0';
    done                                <= '0';
    case q_keccak512_state is
    when IDLE =>
      busy_n                            <= '1';
      if start = '1' then
        busy_n                          <= '0';
        h                               <= IV;
        h(0)                            <= IV(0) xor data_in_array(0);
        h(5)                            <= IV(5) xor data_in_array(1);
        h(10)                           <= IV(10) xor data_in_array(2);
        h(15)                           <= IV(15) xor data_in_array(3);
        h(20)                           <= IV(20) xor data_in_array(4);
        h(1)                            <= IV(1) xor data_in_array(5);
        h(6)                            <= IV(6) xor data_in_array(6);
        h(11)                           <= IV(11) xor data_in_array(7);
        h(16)                           <= IV(16) xor X"8000000000000001";
        keccak512_state_next            <= INIT;
      end if;
    when INIT =>
      ke_start                          <= '1';
      keccak512_state_next              <= EXEC;
    when EXEC =>
      count_start                       <= '0';
      count_en                          <= ke_x_almost_ready;
      ke_start                          <= ke_x_new;
      if ke_x_new = '1' then
        h                               <= ke_x_out_array;
        ke_x_in_array                   <= ke_x_out_array;
      end if;
      -- add 1 to termination count to account for incrementing on ke_x_almost_ready
      if q_count = 24 and ke_x_new = '1' then
        ke_start                        <= '0';
        keccak512_state_next            <= H_GEN;
      end if;
    when H_GEN =>
      almost_done                       <= '1';
      h                                 <= gen_h(q_h);
      keccak512_state_next              <= FINISH;
    when FINISH =>
      done                              <= '1';
      if pause = '0' then
        keccak512_state_next            <= IDLE;
      end if;
    end case;
  end process keccak512_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_keccak512_state                 <= IDLE;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        q_keccak512_state               <= keccak512_state_next;
        q_h                             <= h;
        q_ke_x_new                      <= ke_x_new;
        if count_start = '1' then
          q_count                       <= (others => '0');
        elsif count_en = '1' then
          q_count                       <= q_count + 1;
        end if;
      end if;
    end if;
  end process registers;
  
end architecture keccak512_ce_rtl;