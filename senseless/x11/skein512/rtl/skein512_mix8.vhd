--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity skein512_mix8 is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  mix_count                             : in std_logic_vector(1 downto 0);
  even                                  : in std_logic;
  p_in                                  : in std_logic_vector(511 downto 0);
  p_out                                 : out std_logic_vector(511 downto 0);
  p_new                                 : out std_logic
);
end entity skein512_mix8;

architecture skein512_mix8_rtl of skein512_mix8 is
  
  alias slv is std_logic_vector;
  subtype word64 is slv(63 downto 0);
  type nat_array_4 is array(0 to 3) of natural;
                        
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
  
  type word64_array8 is array(0 to 7) of word64;
  
  signal p_in_int                       : word64_array8;
  signal p_in_int_reordered             : word64_array8;
  signal p                              : word64_array8;
  signal rc_vec                         : nat_array_4;
  signal index_1                        : unsigned(3 downto 0);
  signal index_2                        : unsigned(3 downto 0);
  
  signal q_count                        : unsigned(1 downto 0);
  signal q_p                            : word64_array8;
  signal q_p_reordered                  : word64_array8;
  signal q_done                         : slv(1 downto 0);
  
begin
  
  output_mapping : for i in 0 to 7 generate
    p_out((i+1)*64-1 downto i*64)       <= q_p_reordered(i);
  end generate output_mapping;
  
  p_new                                 <= q_done(1);
  
  input_mapping : for i in 0 to 7 generate
    p_in_int(i)                         <= p_in((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  reorder_proc : process(p_in_int, q_p, mix_count, even) is
  begin
    p_in_int_reordered                  <= p_in_int;
    q_p_reordered                       <= q_p;
    rc_vec                              <= (46,36,19,37);
    case mix_count is
    when "00" =>
      p_in_int_reordered                <= p_in_int;
      q_p_reordered                     <= q_p;
      if even = '1' then
        rc_vec                          <= (46,36,19,37);
      else
        rc_vec                          <= (39,30,34,24);
      end if;
    when "01" =>
      p_in_int_reordered                <= (p_in_int(2),p_in_int(1),p_in_int(4),p_in_int(7),p_in_int(6),p_in_int(5),p_in_int(0),p_in_int(3));
      q_p_reordered                     <= (q_p(6),q_p(1),q_p(0),q_p(7),q_p(2),q_p(5),q_p(4),q_p(3));
      if even = '1' then
        rc_vec                          <= (33,27,14,42);
      else
        rc_vec                          <= (13,50,10,17);
      end if;
    when "10" =>
      p_in_int_reordered                <= (p_in_int(4),p_in_int(1),p_in_int(6),p_in_int(3),p_in_int(0),p_in_int(5),p_in_int(2),p_in_int(7));
      q_p_reordered                     <= (q_p(4),q_p(1),q_p(6),q_p(3),q_p(0),q_p(5),q_p(2),q_p(7));
      if even = '1' then
        rc_vec                          <= (17,49,36,39);
      else
        rc_vec                          <= (25,29,39,43);
      end if;
    when "11" =>
      p_in_int_reordered                <= (p_in_int(6),p_in_int(1),p_in_int(0),p_in_int(7),p_in_int(2),p_in_int(5),p_in_int(4),p_in_int(3));
      q_p_reordered                     <= (q_p(2),q_p(1),q_p(4),q_p(7),q_p(6),q_p(5),q_p(0),q_p(3));
      if even = '1' then
        rc_vec                          <= (44, 9,54,56);
      else
        rc_vec                          <= ( 8,35,56,22);
      end if;
    when others => null;
    end case;
  end process reorder_proc;
  
  index_1                               <= 2*q_count;
  index_2                               <= 2*q_count + 1;
  
  p_calc_proc : process(q_p, index_1, index_2, p_in_int_reordered)
    variable p_ind_1                    : word64;
  begin
    p_ind_1                             := word64(unsigned(p_in_int_reordered(to_integer(index_1))) + unsigned(p_in_int_reordered(to_integer(index_2))));
    p                                   <= q_p;
    p(to_integer(index_1))              <= p_ind_1;
    p(to_integer(index_2))              <= rotl(p_in_int_reordered(to_integer(index_2)),rc_vec(to_integer(q_count))) xor p_ind_1;
  end process p_calc_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_count                           <= (others => '0');
    elsif rising_edge(clk) then
      q_p                               <= p;
      if start = '1' then
        q_count                         <= (others => '0');
      elsif q_count /= 3 then
        q_count                         <= q_count + 1;
      end if;
      if q_count = 2 then
        q_done                          <= "01";
      else
        q_done                          <= q_done(0) & '0';
      end if;
    end if;
  end process registers;
  
end architecture skein512_mix8_rtl;