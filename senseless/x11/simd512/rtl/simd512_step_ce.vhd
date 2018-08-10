--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simd512_step_ce is
port (
  clk                                   : in std_logic;
  clk_en                                : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  direct                                : in std_logic;
  x_in                                  : in std_logic_vector(1023 downto 0);
  w                                     : in std_logic_vector(255 downto 0);
  fn                                    : in std_logic;
  isp                                   : in std_logic_vector(1 downto 0);
  rnd_i                                 : in std_logic_vector(1 downto 0); 
  x_out                                 : out std_logic_vector(1023 downto 0);
  x_out_new                             : out std_logic;
  done                                  : out std_logic;
  almost_done                           : out std_logic
);
end entity simd512_step_ce;

architecture simd512_step_ce_rtl of simd512_step_ce is
  
  alias slv is std_logic_vector;
  type step_state is (IDLE, EXEC, FINISH);
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype word8 is slv(7 downto 0);
  subtype word6 is slv(5 downto 0);
  subtype natural_0_3 is natural range 0 to 3;

  constant zeros64 : word64 := (others => '0');
  constant zeros32 : word32 := (others => '0');
  constant zeros6 : word6 := (others => '0');
  
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

  function shl6(x: word6; n: natural) return word6 is
  begin
    return word6(x(x'high-n downto 0) & zeros6(x'high downto x'length-n));
  end shl6;
  
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
    variable x_rot                      : word32;
  begin
    -- return word32(x(x'high-n downto 0) & x(x'high downto x'length-n));
    -- modifying due to vivado incompatibility when n is non-constant
    -- ERROR: [Synth 8-561] range expression could not be resolved to a constant
    case n is
    when 1 =>
      x_rot                             := x(30 downto 0) & x(31);
    when 2 =>
      x_rot                             := x(29 downto 0) & x(31 downto 30);
    when 3 =>
      x_rot                             := x(28 downto 0) & x(31 downto 29);
    when 4 =>
      x_rot                             := x(27 downto 0) & x(31 downto 28);
    when 5 =>
      x_rot                             := x(26 downto 0) & x(31 downto 27);
    when 6 =>
      x_rot                             := x(25 downto 0) & x(31 downto 26);
    when 7 =>
      x_rot                             := x(24 downto 0) & x(31 downto 25);
    when 8 =>
      x_rot                             := x(23 downto 0) & x(31 downto 24);
    when 9 =>
      x_rot                             := x(22 downto 0) & x(31 downto 23);
    when 10 =>
      x_rot                             := x(21 downto 0) & x(31 downto 22);
    when 11 =>
      x_rot                             := x(20 downto 0) & x(31 downto 21);
    when 12 =>
      x_rot                             := x(19 downto 0) & x(31 downto 20);
    when 13 =>
      x_rot                             := x(18 downto 0) & x(31 downto 19);
    when 14 =>
      x_rot                             := x(17 downto 0) & x(31 downto 18);
    when 15 =>
      x_rot                             := x(16 downto 0) & x(31 downto 17);
    when 16 =>
      x_rot                             := x(15 downto 0) & x(31 downto 16);
    when 17 =>
      x_rot                             := x(14 downto 0) & x(31 downto 15);
    when 18 =>
      x_rot                             := x(13 downto 0) & x(31 downto 14);
    when 19 =>
      x_rot                             := x(12 downto 0) & x(31 downto 13);
    when 20 =>
      x_rot                             := x(11 downto 0) & x(31 downto 12);
    when 21 =>
      x_rot                             := x(10 downto 0) & x(31 downto 11);
    when 22 =>
      x_rot                             := x(9 downto 0) & x(31 downto 10);
    when 23 =>
      x_rot                             := x(8 downto 0) & x(31 downto 9);
    when 24 =>
      x_rot                             := x(7 downto 0) & x(31 downto 8);
    when 25 =>
      x_rot                             := x(6 downto 0) & x(31 downto 7);
    when 26 =>
      x_rot                             := x(5 downto 0) & x(31 downto 6);
    when 27 =>
      x_rot                             := x(4 downto 0) & x(31 downto 5);
    when 28 =>
      x_rot                             := x(3 downto 0) & x(31 downto 4);
    when 29 =>
      x_rot                             := x(2 downto 0) & x(31 downto 3);
    when 30 =>
      x_rot                             := x(1 downto 0) & x(31 downto 2);
    when 31 =>
      x_rot                             := x(0) & x(31 downto 1);
    when others =>
      x_rot                             := x;
    end case;
    return x_rot;
  end rotl32;
  
  type word32_array_4_8 is array(0 to 3, 0 to 7) of word32;
  type word32_array32 is array(0 to 31) of word32;
  type word32_array8 is array(0 to 7) of word32;
  type nat_array_7_8 is array(0 to 6, 0 to 7) of natural;
  type nat_array_4_8 is array(0 to 3, 0 to 7) of natural;
  type nat_array_4_4 is array(0 to 3, 0 to 3) of natural;
  
  function if_fn(x: word32; y: word32; z: word32) return word32 is
  begin
    return word32(((y xor z) and x) xor z);
  end if_fn;
  
  function maj(x: word32; y: word32; z: word32) return word32 is
  begin
    return word32((x and y) or ((x or y) and z));
  end maj;
  
  constant PP8                          : nat_array_7_8 := ((1,0,3,2,5,4,7,6),
                                                            (6,7,4,5,2,3,0,1),
                                                            (2,3,0,1,6,7,4,5),
                                                            (3,2,1,0,7,6,5,4),
                                                            (5,4,7,6,1,0,3,2),
                                                            (7,6,5,4,3,2,1,0),
                                                            (4,5,6,7,0,1,2,3));
  
  constant M7                           : nat_array_4_8 := ((0,1,2,3,4,5,6,0),
                                                            (1,2,3,4,5,6,0,1),
                                                            (2,3,4,5,6,0,1,2),
                                                            (3,4,5,6,0,1,2,3));

  constant RS                           : nat_array_4_4 := ((3,23,17,27),
                                                            (28,19,22,7),
                                                            (29,9,15,5),
                                                            (4,13,10,25));

  function step_elt(x: word32_array32; i: unsigned(2 downto 0); w: word32; fn: std_logic; s: natural; x_rot: word32_array8; isp: slv(1 downto 0); rnd_i: slv(1 downto 0); direct: std_logic) return word32_array32 is
    variable n                          : natural;
    variable p                          : natural;
    variable tt                         : word32;
    variable x2                         : word32_array32;
  begin
    n                                   := to_integer(i);
    if direct = '1' then
      p                                 := PP8(M7(to_integer(unsigned(isp)),to_integer(unsigned('0' & rnd_i)+1)),n);
    else
      p                                 := PP8(M7(to_integer(unsigned(isp)),to_integer(unsigned(fn & rnd_i))),n);
    end if;
    if fn = '0' then
      tt                                := slv(unsigned(x(24+n)) + unsigned(w) + unsigned(if_fn(x(n),x(8+n),x(16+n))));
    else
      tt                                := slv(unsigned(x(24+n)) + unsigned(w) + unsigned(maj(x(n),x(8+n),x(16+n))));
    end if;
    x2                                  := x;
    x2(n)                               := slv(unsigned(rotl32(tt,s)) + unsigned(x_rot(p)));
    x2(24+n)                            := x2(16+n);
    x2(16+n)                            := x2(8+n);
    x2(8+n)                             := x_rot(n);
    return x2;
  end function step_elt;
  
  constant DIRECT_W                     : word32_array_4_8 := ((X"0BA16B95", X"72F999AD", X"9FECC2AE", X"BA3264FC",X"5E894929", X"8E9F30E5", X"2F1DAA37", X"F0F2C558"),
                                                               (X"AC506643", X"A90635A5", X"E25B878B", X"AAB7878F",X"88817F7A", X"0A02892B", X"559A7550", X"598F657E"),
                                                               (X"7EEF60A1", X"6B70E3E8", X"9C1714D1", X"B958E2A8",X"AB02675E", X"ED1C014F", X"CD8D65BB", X"FDB7A257"),
                                                               (X"09254899", X"D699C7BC", X"9019B6DC", X"2B9022E4",X"8FA14956", X"21BF9BD3", X"B94D0943", X"6FFDDC22"));
  
  signal step_state_next                : step_state;
  signal x_in_array                     : word32_array32;
  signal x_out_array                    : word32_array32;
  signal w_in_array                     : word32_array8;
  signal r                              : natural;
  signal s                              : natural;
  signal x_rot                          : word32_array8;
  signal count_start                    : std_logic;
  signal step_en                        : std_logic;
  signal done_int                       : std_logic;
  signal almost_done_int                : std_logic;
  
  signal q_step_state                   : step_state;
  signal q_x_rot                        : word32_array8;
  signal q_count                        : unsigned(2 downto 0);
  
begin
  
  x_out_new                             <= step_en;
  done                                  <= done_int;
  almost_done                           <= almost_done_int;
  
  x_mapping : for i in 0 to 31 generate
    x_out((i+1)*32-1 downto i*32)       <= x_out_array(i);
    x_in_array(i)                       <= x_in((i+1)*32-1 downto i*32);
  end generate x_mapping;
  
  w_mapping : for i in 0 to 7 generate
    w_in_array(i)                       <= w((i+1)*32-1 downto i*32);
  end generate w_mapping;
  
  r                                     <= RS(to_integer(unsigned(isp)),to_integer(unsigned(rnd_i)));
  s                                     <= RS(to_integer(unsigned(isp)),to_integer((unsigned(rnd_i) + 1) mod 4));
  
  step_proc : process(q_step_state, x_in_array, r, q_x_rot, q_count, w_in_array, fn, s, isp, rnd_i, direct, start) is
    variable x_rot_var                  : word32_array8;
  begin
    step_state_next                     <= q_step_state;
    count_start                         <= '1';
    step_en                             <= '1';
    for i in 0 to 7 loop
      x_rot_var(i)                      := rotl32(x_in_array(i),r);
    end loop;
    x_out_array                         <= step_elt(x_in_array,q_count,w_in_array(to_integer(q_count)),fn,s,x_rot_var,isp,rnd_i,direct);
    x_rot                               <= q_x_rot;
    almost_done_int                     <= '0';
    done_int                            <= '0';
    case q_step_state is
    when IDLE =>
      for i in 0 to 7 loop
        x_rot(i)                        <= rotl32(x_in_array(i),r);
      end loop;
      x_out_array                       <= step_elt(x_in_array,q_count,w_in_array(to_integer(q_count)),fn,s,x_rot_var,isp,rnd_i,direct);
      step_en                           <= start;
      if start = '1' then
        count_start                     <= '0';
        step_state_next                 <= EXEC;
      end if;
    when EXEC =>
      count_start                       <= '0';
      x_out_array                       <= step_elt(x_in_array,q_count,w_in_array(to_integer(q_count)),fn,s,q_x_rot,isp,rnd_i,direct);
      if q_count = 7 then
        almost_done_int                 <= '1';
        step_state_next                 <= FINISH;
      end if;
    when FINISH =>
      for i in 0 to 7 loop
        x_rot(i)                        <= rotl32(x_in_array(i),r);
      end loop;
      x_out_array                       <= step_elt(x_in_array,q_count,w_in_array(0),fn,s,x_rot_var,isp,rnd_i,direct);
      done_int                          <= '1';
      step_en                           <= start;
      if start = '1' then
        count_start                     <= '0';
        step_state_next                 <= EXEC;
      else
        step_state_next                 <= IDLE;
      end if;
    when others =>
      null;
    end case;
  end process step_proc;
    
  registers : process(reset, clk) is
  begin
    if reset = '1' then
      q_step_state                      <= IDLE;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        q_step_state                    <= step_state_next;
        q_x_rot                         <= x_rot;
        if count_start = '1' then
          q_count                       <= (others => '0');
        elsif step_en = '1' then
          q_count                       <= q_count + 1;
        end if;
      end if;
    end if;
  end process registers;
  
end architecture simd512_step_ce_rtl;