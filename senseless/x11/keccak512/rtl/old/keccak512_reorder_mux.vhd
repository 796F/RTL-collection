--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak512_reorder_mux is
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
end entity keccak512_reorder_mux;

architecture keccak512_reorder_mux_rtl of keccak512_reorder_mux is
  
  alias slv is std_logic_vector;
  
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  type nat_array_25 is array(0 to 24) of natural;
  type array_9_nat_array_25 is array(0 to 8) of nat_array_25;
  type array_8_nat_array_25 is array(0 to 7) of nat_array_25;
  
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
  
  subtype word1600 is slv(1599 downto 0);
  type word64_array25 is array(0 to 24) of word64;
  
  constant IND                          : array_9_nat_array_25 := ((0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24),
                                                                   (0,15, 5,20,10, 6,21,11, 1,16,12, 2,17, 7,22,18, 8,23,13, 3,24,14, 4,19, 9),
                                                                   (0,18, 6,24,12,21,14, 2,15, 8,17, 5,23,11, 4,13, 1,19, 7,20, 9,22,10, 3,16),
                                                                   (0,13,21, 9,17,14,22, 5,18, 1,23, 6,19, 2,10, 7,15, 3,11,24,16, 4,12,20, 8),
                                                                   (0, 7,14,16,23,22, 4, 6,13,15,19,21, 3, 5,12,11,18,20, 2, 9, 8,10,17,24, 1),
                                                                   (0,11,22, 8,19, 4,10,21, 7,18, 3,14,20, 6,17, 2,13,24, 5,16, 1,12,23, 9,15),
                                                                   (0, 2, 4, 1, 3,10,12,14,11,13,20,22,24,21,23, 5, 7, 9, 6, 8,15,17,19,16,18),
                                                                   (0, 5,10,15,20,12,17,22, 2, 7,24, 4, 9,14,19, 6,11,16,21, 1,18,23, 3, 8,13),
                                                                   (0, 6,12,18,24,17,23, 4, 5,11, 9,10,16,22, 3,21, 2, 8,14,15,13,19,20, 1, 7));

  -- constant IND2                         : array_8_nat_array_25 := ((0,15, 5,20,10, 6,21,11, 1,16,12, 2,17, 7,22,18, 8,23,13, 3,24,14, 4,19, 9),
                                                                   -- (0,13,21, 9,17,14,22, 5,18, 1,23, 6,19, 2,10, 7,15, 3,11,24,16, 4,12,20, 8),
                                                                   -- (0,11,22, 8,19, 4,10,21, 7,18, 3,14,20, 6,17, 2,13,24, 5,16, 1,12,23, 9,15),
                                                                   -- (0, 5,10,15,20,12,17,22, 2, 7,24, 4, 9,14,19, 6,11,16,21, 1,18,23, 3, 8,13),
                                                                   -- (0,21,17,13, 9,23,19,10, 6, 2,16,12, 8, 4,20,14, 5, 1,22,18, 7, 3,24,15,11),
                                                                   -- (0,22,19,11, 8, 3,20,17,14, 6, 1,23,15,12, 9, 4,21,18,10, 7, 2,24,16,13, 5),
                                                                   -- (0,10,20, 5,15,24, 9,19, 4,14,18, 3,13,23, 8,12,22, 7,17, 2, 6,16, 1,11,21),
                                                                   -- (0,17, 9,21,13,16, 8,20,12, 4, 7,24,11, 3,15,23,10, 2,19, 6,14, 1,18, 5,22));
                                            
  -- function reorder(x: word1600; a: natural) return word64_array25 is
    -- variable x2                         : word64_array25;
    -- variable x3                         : word64_array25;
  -- begin
    -- for i in 0 to 24 loop
      -- x2(i)                             := x((i+1)*64-1 downto i*64);
    -- end loop;
    -- for i in 0 to 24 loop
      -- x3(i)                             := x2(IND(a)(i));
    -- end loop;
    -- return x3;
  -- end reorder;
  
  -- function reorder2(x: word1600; a: natural; b: natural) return word64_array25 is
    -- variable x2                         : word64_array25;
    -- variable x3                         : word64_array25;
  -- begin
    -- for i in 0 to 24 loop
      -- x2(IND(a)(i))                     := x((i+1)*64-1 downto i*64);
    -- end loop;
    -- for i in 0 to 24 loop
      -- x3(i)                             := x2(IND(b)(i));  
    -- end loop;
    -- return x3;
  -- end reorder2;
  
  -- function reorder3(x: word1600; a: natural) return word64_array25 is
    -- variable x2                         : word64_array25;
  -- begin
    -- for i in 0 to 24 loop
      -- x2(IND(a)(i))                     := x((i+1)*64-1 downto i*64);
    -- end loop;
    -- return x2;
  -- end reorder3;
  
  function reorder(x: word1600; sel: slv(1 downto 0); a: natural; b: natural) return word64_array25 is
    variable x2                         : word64_array25;
    variable x3                         : word64_array25;
  begin
    case sel is
    when "00" =>
      for i in 0 to 24 loop
        x2(i)                           := x((i+1)*64-1 downto i*64);
      end loop;
      for i in 0 to 24 loop
        x3(i)                           := x2(IND(a)(i));
      end loop;
    when "01" =>
      -- for i in 0 to 24 loop
        -- x2(IND(a)(i))                   := x((i+1)*64-1 downto i*64);
      -- end loop;
      -- for i in 0 to 24 loop
        -- x3(i)                           := x2(IND(b)(i));  
      -- end loop;
      for i in 0 to 24 loop
        x2(i)                           := x((i+1)*64-1 downto i*64);
      end loop;
      for i in 0 to 24 loop
        x3(i)                           := x2(IND(1)(i));
      end loop;
    when "10" =>
      for i in 0 to 24 loop
        x2(IND(b)(i))                   := x((i+1)*64-1 downto i*64);
      end loop;
      x3                                := x2;
    when others =>
      null;
    end case;
    return x3;
  end reorder;
  
  
  signal x                              : word64_array25;
  
  signal q_x                            : word64_array25;
  signal q_done                         : slv(2 downto 0);
  
begin
  
  (x_new_3, x_new_2, x_new_1)           <= q_done;
  
  output_mapping : for l in 0 to 24 generate
    x_out((l+1)*64-1 downto l*64)       <= q_x(l);
  end generate output_mapping;
  
  reorder_proc : process(q_x, start_1, start_2, start_3, x_in_1, x_in_2, x_in_3, i, j)
  begin
    x                                   <= q_x;
    if start_1 = '1' then
      x                                 <= reorder(x_in_1,"00",to_integer(unsigned(i)),to_integer(unsigned(j)));
      --x                                 <= reorder(x_in_1,to_integer(unsigned(i)));
    elsif start_2 = '1' then
      x                                 <= reorder(x_in_2,"01",to_integer(unsigned(i)),to_integer(unsigned(j)));
      --x                                 <= reorder2(x_in_2,to_integer(unsigned(i)),to_integer(unsigned(j)));
    elsif start_3 = '1' then
      x                                 <= reorder(x_in_3,"10",to_integer(unsigned(i)),to_integer(unsigned(j)));
      --x                                 <= reorder3(x_in_3,to_integer(unsigned(j)));
    end if;
  end process;
  
  registers : process(clk) is
  begin
    if rising_edge(clk) then
      q_x                               <= x;
      q_done                            <= (start_3, start_2, start_1);
    end if;
  end process registers;
  
end architecture keccak512_reorder_mux_rtl;