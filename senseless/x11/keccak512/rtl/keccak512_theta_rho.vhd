--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak512_theta_rho is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  x_in                                  : in std_logic_vector(1599 downto 0);
  x_out                                 : out std_logic_vector(1599 downto 0);
  x_new                                 : out std_logic
);
end entity keccak512_theta_rho;

architecture keccak512_theta_rho_rtl of keccak512_theta_rho is
  
  alias slv is std_logic_vector;
  
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  type nat_array_25 is array(0 to 24) of natural;
  type theta_state is (IDLE, T_GEN, X_GEN, FINISH);

  constant zeros64 : word64 := (others => '0');
    
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
  type word64_array10 is array(0 to 9) of word64;
  type word64_array8 is array(0 to 7) of word64;
  type word64_array5 is array(0 to 4) of word64;
  type word64_array3 is array(0 to 2) of word64;
  
  function th_elt(x: word64_array10) return word64 is
    variable t                          : word64_array3;
  begin
    t(0)                                := x(5) xor x(6);
    t(1)                                := x(7) xor x(8);
    t(0)                                := t(0) xor x(9);
    t(0)                                := rotl(t(0) xor t(1),1);
    t(0)                                := t(0) xor x(4);
    t(1)                                := x(0) xor x(1);
    t(2)                                := x(2) xor x(3);
    t(1)                                := t(1) xor t(2);
    return word64(t(0) xor t(1));
  end th_elt;
  
  constant R                            : nat_array_25 := (0,36,3,41,18,1,44,10,45,2,62,6,43,15,61,28,55,25,21,56,27,20,39,8,14);
  
  function rho(x: word64_array25) return word64_array25 is
    variable x2                         : word64_array25;
  begin
    for i in 0 to 24 loop
      x2(i)                             := rotl(x(i),R(i));
    end loop;
    return x2;
  end rho;  
  
  signal theta_state_next               : theta_state;
  signal count_start                    : std_logic;    
  signal count_en                       : std_logic;
  signal x_in_array                     : word64_array25;
  signal x                              : word64_array25;
  signal x_out_int                      : word64_array25;
  signal t                              : word64_array5;
  signal done                           : std_logic;
  
  signal q_theta_state                  : theta_state;
  signal q_count                        : unsigned(4 downto 0);
  signal q_x                            : word64_array25;
  signal q_t                            : word64_array5;
  
begin

  x_new                                 <= done;
  
  output_mapping : for i in 0 to 24 generate
    x_out((i+1)*64-1 downto i*64)       <= x_out_int(i);
  end generate output_mapping;
  
  x_out_int                             <= rho(q_x);
  
  input_mapping : for i in 0 to 24 generate
    x_in_array(i)                       <= x_in((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  theta_proc : process(q_theta_state, q_t, q_x, start, x_in_array, q_count)
  begin
    theta_state_next                    <= q_theta_state;
    count_start                         <= '1';
    count_en                            <= '0';
    t                                   <= q_t;
    x                                   <= q_x;
    done                                <= '0';
    case q_theta_state is
    when IDLE =>
      if start = '1' then
        x                               <= x_in_array;
        theta_state_next                <= T_GEN;
      end if;
    when T_GEN =>
      count_start                       <= '0';
      count_en                          <= '1';
      case q_count is
      when "00000" =>
        t(0)                            <= th_elt((q_x(20),q_x(21),q_x(22),q_x(23),q_x(24),q_x(5),q_x(6),q_x(7),q_x(8),q_x(9)));
      when "00001" =>
        t(1)                            <= th_elt((q_x(0),q_x(1),q_x(2),q_x(3),q_x(4),q_x(10),q_x(11),q_x(12),q_x(13),q_x(14)));  
      when "00010" =>
        t(2)                            <= th_elt((q_x(5),q_x(6),q_x(7),q_x(8),q_x(9),q_x(15),q_x(16),q_x(17),q_x(18),q_x(19)));    
      when "00011" =>
        t(3)                            <= th_elt((q_x(10),q_x(11),q_x(12),q_x(13),q_x(14),q_x(20),q_x(21),q_x(22),q_x(23),q_x(24)));
      when "00100" =>
        t(4)                            <= th_elt((q_x(15),q_x(16),q_x(17),q_x(18),q_x(19),q_x(0),q_x(1),q_x(2),q_x(3),q_x(4)));
        count_start                     <= '1';
        count_en                        <= '0';
        theta_state_next                <= X_GEN;
      when others =>
        null;
      end case;
    when X_GEN =>
      count_start                       <= '0';
      count_en                          <= '1';
      x(to_integer(q_count))            <= q_x(to_integer(q_count)) xor q_t(to_integer(q_count)/5);
      if q_count = 24 then
        theta_state_next                <= FINISH;
      end if;
    when FINISH =>
      done                              <= '1';
      theta_state_next                  <= IDLE;
    end case;
  end process theta_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_theta_state                     <= IDLE;
    elsif rising_edge(clk) then
      q_theta_state                     <= theta_state_next;
      q_x                               <= x;
      q_t                               <= t;
      if count_start = '1' then
        q_count                         <= (others => '0');
      elsif count_en = '1' then
        q_count                         <= q_count + 1;
      end if;
    end if;
  end process registers;
  
end architecture keccak512_theta_rho_rtl;