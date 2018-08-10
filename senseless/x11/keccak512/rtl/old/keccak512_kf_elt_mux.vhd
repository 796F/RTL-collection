--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak512_kf_elt_mux is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  i                                     : in std_logic_vector(2 downto 0);
  j                                     : in std_logic_vector(3 downto 0);
  k                                     : in std_logic_vector(4 downto 0);
  x_in                                  : in std_logic_vector(1599 downto 0);
  x_out                                 : out std_logic_vector(1599 downto 0);
  x_new                                 : out std_logic;
  x_almost_ready                        : out std_logic
);
end entity keccak512_kf_elt_mux;

architecture keccak512_kf_elt_mux_rtl of keccak512_kf_elt_mux is
  
  alias slv is std_logic_vector;
  
  component keccak512_reorder_mux is
  port (
    clk                                   : in std_logic;
    start_1                               : in std_logic;
    start_2                               : in std_logic;
    start_3                               : in std_logic;
    i                                     : in std_logic_vector(2 downto 0);
    j                                     : in std_logic_vector(3 downto 0);
    x_in_1                                : in std_logic_vector(1599 downto 0);
    x_in_2                                : in std_logic_vector(1599 downto 0);
    x_in_3                                : in std_logic_vector(1599 downto 0);
    x_out                                 : out std_logic_vector(1599 downto 0);
    x_new_1                               : out std_logic;
    x_new_2                               : out std_logic;
    x_new_3                               : out std_logic
  );
  end component keccak512_reorder_mux;
  
  component keccak512_theta_rho is
  port (
    clk                                   : in std_logic;
    reset                                 : in std_logic;
    start                                 : in std_logic;
    x_in                                  : in std_logic_vector(1599 downto 0);
    x_out                                 : out std_logic_vector(1599 downto 0);
    x_new                                 : out std_logic
  );
  end component keccak512_theta_rho;
  
  component keccak512_khi is
  port (
    clk                                   : in std_logic;
    start                                 : in std_logic;
    x_in                                  : in std_logic_vector(1599 downto 0);
    x_out                                 : out std_logic_vector(1599 downto 0);
    x_new                                 : out std_logic
  );
  end component keccak512_khi;
  
  subtype word1600 is slv(1599 downto 0);
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  type nat_array_25 is array(0 to 24) of natural;
  type array_9_nat_array_25 is array(0 to 8) of nat_array_25;

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
  type word64_array24 is array(0 to 23) of word64;
  
  constant IND                          : array_9_nat_array_25 := ((0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24),
                                                                   (0,15,5,20,10,6,21,11,1,16,12,2,17,7,22,18,8,23,13,3,24,14,4,19,9),
                                                                   (0,18,6,24,12,21,14,2,15,8,17,5,23,11,4,13,1,19,7,20,9,22,10,3,16),
                                                                   (0,13,21,9,17,14,22,5,18,1,23,6,19,2,10,7,15,3,11,24,16,4,12,20,8),
                                                                   (0,7,14,16,23,22,4,6,13,15,19,21,3,5,12,11,18,20,2,9,8,10,17,24,1),
                                                                   (0,11,22,8,19,4,10,21,7,18,3,14,20,6,17,2,13,24,5,16,1,12,23,9,15),
                                                                   (0,2,4,1,3,10,12,14,11,13,20,22,24,21,23,5,7,9,6,8,15,17,19,16,18),
                                                                   (0,5,10,15,20,12,17,22,2,7,24,4,9,14,19,6,11,16,21,1,18,23,3,8,13),
                                                                   (0,6,12,18,24,17,23,4,5,11,9,10,16,22,3,21,2,8,14,15,13,19,20,1,7));
  
  constant RC                           : word64_array24 := (X"0000000000000001", X"0000000000008082",
                                                             X"800000000000808A", X"8000000080008000",
                                                             X"000000000000808B", X"0000000080000001",
                                                             X"8000000080008081", X"8000000000008009",
                                                             X"000000000000008A", X"0000000000000088",
                                                             X"0000000080008009", X"000000008000000A",
                                                             X"000000008000808B", X"800000000000008B",
                                                             X"8000000000008089", X"8000000000008003",
                                                             X"8000000000008002", X"8000000000000080",
                                                             X"000000000000800A", X"800000008000000A",
                                                             X"8000000080008081", X"8000000000008080",
                                                             X"0000000080000001", X"8000000080008008");
  
  signal x                              : slv(1599 downto 0);
  signal x_array                        : word64_array25;
  signal x2                             : word64_array25;
  signal tr_start                       : std_logic;
  signal tr_x_out                       : slv(1599 downto 0);
  signal tr_x_new                       : std_logic;
  signal k_start                        : std_logic;
  signal k_x_out                        : slv(1599 downto 0);
  signal k_x_new                        : std_logic;
  signal x_array_new                    : std_logic;
  
  signal q_x2                           : word64_array25;
  signal q_done                         : std_logic;
  
begin

  x_new                                 <= q_done;
  x_almost_ready                        <= x_array_new;
  
  output_mapping : for l in 0 to 24 generate
    x_out((l+1)*64-1 downto l*64)       <= q_x2(l);
  end generate output_mapping;

  x_mapping : for l in 0 to 24 generate
    x_array(l)                          <= x((l+1)*64-1 downto l*64);
  end generate x_mapping;
  
  keccak512_reorder_mux_inst : keccak512_reorder_mux
  port map (
    clk                                 => clk,
    start_1                             => start,
    start_2                             => tr_x_new,
    start_3                             => k_x_new,
    i                                   => i,
    j                                   => j,
    x_in_1                              => x_in,
    x_in_2                              => tr_x_out,
    x_in_3                              => k_x_out,
    x_out                               => x,
    x_new_1                             => tr_start,
    x_new_2                             => k_start,
    x_new_3                             => x_array_new
  );
  
  keccak512_theta_rho_inst : keccak512_theta_rho
  port map (
    clk                                 => clk,
    reset                               => reset,
    start                               => tr_start,
    x_in                                => x,
    x_out                               => tr_x_out,
    x_new                               => tr_x_new
  );
  
  keccak512_khi_inst : keccak512_khi
  port map (
    clk                                 => clk,
    start                               => k_start,
    x_in                                => x,
    x_out                               => k_x_out,
    x_new                               => k_x_new
  );
  
  kf_elt_proc : process(q_x2, x_array, x_array_new, i, k)
  begin
    x2                                  <= q_x2;
    if x_array_new = '1' then
      x2(0)                             <= x_array(0) xor RC(to_integer(unsigned(k)));
      for l in 1 to 24 loop
        x2(l)                           <= x_array(l);
      end loop;
      if unsigned(i) = 7 then
        x2(1)                           <= x_array(6);
        x2(6)                           <= x_array(23);
        x2(23)                          <= x_array(1);
        x2(2)                           <= x_array(12);
        x2(12)                          <= x_array(16);
        x2(16)                          <= x_array(2);
        x2(3)                           <= x_array(18);
        x2(18)                          <= x_array(14);
        x2(14)                          <= x_array(3);
        x2(4)                           <= x_array(24);
        x2(24)                          <= x_array(7);
        x2(7)                           <= x_array(4);
        x2(5)                           <= x_array(17);
        x2(17)                          <= x_array(8);
        x2(8)                           <= x_array(5);
        x2(9)                           <= x_array(11);
        x2(11)                          <= x_array(10);
        x2(10)                          <= x_array(9);
        x2(13)                          <= x_array(22);
        x2(22)                          <= x_array(20);
        x2(20)                          <= x_array(13);
        x2(15)                          <= x_array(21);
        x2(21)                          <= x_array(19);
        x2(19)                          <= x_array(15);
      end if;
    end if;
  end process kf_elt_proc;
  
  registers : process(clk) is
  begin
    if rising_edge(clk) then
      q_x2                              <= x2;
      q_done                            <= x_array_new;
    end if;
  end process registers;
  
end architecture keccak512_kf_elt_mux_rtl;