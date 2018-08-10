--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity luffa512_mi is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  d_in                                  : in std_logic_vector(255 downto 0);
  x_in                                  : in std_logic_vector(1279 downto 0);
  x_out                                 : out std_logic_vector(1279 downto 0);
  x_new                                 : out std_logic
);
end entity luffa512_mi;

architecture luffa512_mi_rtl of luffa512_mi is
  
  alias slv is std_logic_vector;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  subtype uword32 is unsigned(31 downto 0);
  type mi_state is (IDLE, MI_1, MI_2, MI_3, MI_4, MI_5, MI_6, MI_7, MI_8, MI_9, MI_10, MI_11, MI_12, MI_13, MI_14, MI_15, MI_16, MI_17,
                    MI_18, MI_19, MI_20, MI_21, MI_22, MI_23, MI_24, MI_25, MI_26, MI_27, MI_28, MI_29, MI_30, MI_31, MI_32, MI_33, FINISH);
                        
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
  
  type word32_array40 is array(0 to 39) of word32;
  type word32_array8 is array(0 to 7) of word32;
    
  constant OFFSET_8                     : unsigned(3 downto 0) := X"1";
  constant OFFSET_16                    : unsigned(3 downto 0) := X"2";
  constant OFFSET_24                    : unsigned(3 downto 0) := X"3";
  constant OFFSET_32                    : unsigned(3 downto 0) := X"4";
  
  signal mi_state_next                  : mi_state;
  signal count_start_1                  : std_logic;
  signal count_en_1                     : std_logic;
  signal count_start_2                  : std_logic;
  signal count_en_2                     : std_logic;
  signal d_in_array                     : word32_array8;
  signal x_in_array                     : word32_array40;
  signal m                              : word32_array8;
  signal a                              : word32_array8;
  signal b                              : word32_array8;
  signal x                              : word32_array40;
  signal t                              : word32;
  signal done                           : std_logic;
  
  signal q_mi_state                     : mi_state;
  signal q_count_1                      : unsigned(2 downto 0);
  signal q_count_2                      : unsigned(2 downto 0);
  signal q_m                            : word32_array8;
  signal q_a                            : word32_array8;
  signal q_b                            : word32_array8;
  signal q_x                            : word32_array40;
  signal q_t                            : word32;
  
begin

  x_new                                 <= done;
  
  output_mapping : for i in 0 to 39 generate
    x_out((i+1)*32-1 downto i*32)       <= q_x(i);
  end generate output_mapping;
  
  input_mapping_1 : for i in 0 to 7 generate
    d_in_array(7-i)                     <= endian_swap32(d_in((i+1)*32-1 downto i*32));
  end generate input_mapping_1;
  
  input_mapping_2 : for i in 0 to 39 generate
    x_in_array(i)                       <= x_in((i+1)*32-1 downto i*32);  
  end generate input_mapping_2;
  
  mi_proc : process(q_mi_state, q_m, q_a, q_b, q_x, q_t, start, d_in_array, x_in_array, q_count_1, q_count_2)
  begin
    mi_state_next                       <= q_mi_state;
    count_start_1                       <= '1';
    count_en_1                          <= '0';
    count_start_2                       <= '1';
    count_en_2                          <= '0';
    m                                   <= q_m;
    a                                   <= q_a;
    b                                   <= q_b;
    x                                   <= q_x;
    t                                   <= q_t;
    done                                <= '0';
    case q_mi_state is
    when IDLE =>
      if start = '1' then
        m                               <= d_in_array;
        x                               <= x_in_array;
        mi_state_next                   <= MI_1;
      end if;
    when MI_1 =>
      count_start_1                     <= '0';
      count_en_1                        <= q_count_2(0);
      count_start_2                     <= q_count_2(0);
      count_en_2                        <= '1';
      if q_count_2 = 0 then
        a(to_integer(q_count_1))        <= q_x(to_integer(q_count_1)) xor q_x(to_integer(OFFSET_8 & q_count_1));
      else
        b(to_integer(q_count_1))        <= q_x(to_integer(OFFSET_16 & q_count_1)) xor q_x(to_integer(OFFSET_24 & q_count_1));
      end if;
      if q_count_1 = 7 and q_count_2 = 1 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_2;
      end if;
    when MI_2 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      a(to_integer(q_count_1))          <= q_a(to_integer(q_count_1)) xor q_b(to_integer(q_count_1));
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_3;
      end if;
    when MI_3 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      a(to_integer(q_count_1))          <= q_a(to_integer(q_count_1)) xor q_x(to_integer(OFFSET_32 & q_count_1));      
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_4;
      end if;
    when MI_4 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_a(7);
        a(7)                            <= q_a(6);
        a(6)                            <= q_a(5);
        a(5)                            <= q_a(4);
        a(4)                            <= q_a(3) xor q_a(7);
      when "001" =>
        a(3)                            <= q_a(2) xor q_t;
        a(2)                            <= q_a(1);
      when "010" =>
        a(1)                            <= q_a(0) xor q_t;
        a(0)                            <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_5;
      when others =>
        null;
      end case;
    when MI_5 =>
      count_start_1                     <= '0';
      if q_count_2 = 4 then
        count_en_1                      <= '1';
        count_start_2                   <= '1';
      else
        count_en_1                      <= '0';
        count_start_2                   <= '0';
      end if;
      count_en_2                        <= '1';
      case q_count_2 is
      when "000" =>
        x(to_integer(q_count_1))              <= q_a(to_integer(q_count_1)) xor q_x(to_integer(q_count_1));
      when "001" =>
        x(to_integer(OFFSET_8 & q_count_1))   <= q_a(to_integer(q_count_1)) xor q_x(to_integer(OFFSET_8 & q_count_1));
      when "010" =>
        x(to_integer(OFFSET_16 & q_count_1))  <= q_a(to_integer(q_count_1)) xor q_x(to_integer(OFFSET_16 & q_count_1));
      when "011" =>
        x(to_integer(OFFSET_24 & q_count_1))  <= q_a(to_integer(q_count_1)) xor q_x(to_integer(OFFSET_24 & q_count_1));
      when "100" =>
        x(to_integer(OFFSET_32 & q_count_1))  <= q_a(to_integer(q_count_1)) xor q_x(to_integer(OFFSET_32 & q_count_1));
        if q_count_1 = 7 then
          mi_state_next                 <= MI_6;
        end if;
      when others =>
        null;
      end case;
    when MI_6 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_x(7);
        b(7)                            <= q_x(6);
        b(6)                            <= q_x(5);
        b(5)                            <= q_x(4);
        b(4)                            <= q_x(3) xor q_x(7);
      when "001" =>
        b(3)                            <= q_x(2) xor q_t;
        b(2)                            <= q_x(1);
      when "010" =>
        b(1)                            <= q_x(0) xor q_t;
        b(0)                            <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_7;
      when others =>
        null;
      end case;
    when MI_7 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      b(to_integer(q_count_1))          <= q_b(to_integer(q_count_1)) xor q_x(to_integer(OFFSET_8 & q_count_1));      
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_8;
      end if;
    when MI_8 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_x(15);
        x(15)                           <= q_x(14);
        x(14)                           <= q_x(13);
        x(13)                           <= q_x(12);
        x(12)                           <= q_x(11) xor q_x(15);
      when "001" =>
        x(11)                           <= q_x(10) xor q_t;
        x(10)                           <= q_x(9);
      when "010" =>
        x(9)                            <= q_x(8) xor q_t;
        x(8)                            <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_9;
      when others =>
        null;
      end case;
    when MI_9 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      x(to_integer(OFFSET_8 & q_count_1)) <= q_x(to_integer(OFFSET_8 & q_count_1)) xor q_x(to_integer(OFFSET_16 & q_count_1));      
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_10;
      end if;
    when MI_10 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_x(23);
        x(23)                           <= q_x(22);
        x(22)                           <= q_x(21);
        x(21)                           <= q_x(20);
        x(20)                           <= q_x(19) xor q_x(23);
      when "001" =>
        x(19)                           <= q_x(18) xor q_t;
        x(18)                           <= q_x(17);
      when "010" =>
        x(17)                           <= q_x(16) xor q_t;
        x(16)                           <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_11;
      when others =>
        null;
      end case;
    when MI_11 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      x(to_integer(OFFSET_16 & q_count_1)) <= q_x(to_integer(OFFSET_16 & q_count_1)) xor q_x(to_integer(OFFSET_24 & q_count_1));      
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_12;
      end if;
    when MI_12 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_x(31);
        x(31)                           <= q_x(30);
        x(30)                           <= q_x(29);
        x(29)                           <= q_x(28);
        x(28)                           <= q_x(27) xor q_x(31);
      when "001" =>
        x(27)                           <= q_x(26) xor q_t;
        x(26)                           <= q_x(25);
      when "010" =>
        x(25)                           <= q_x(24) xor q_t;
        x(24)                           <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_13;
      when others =>
        null;
      end case;
    when MI_13 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      x(to_integer(OFFSET_24 & q_count_1)) <= q_x(to_integer(OFFSET_24 & q_count_1)) xor q_x(to_integer(OFFSET_32 & q_count_1));      
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_14;
      end if;
    when MI_14 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_x(39);
        x(39)                           <= q_x(38);
        x(38)                           <= q_x(37);
        x(37)                           <= q_x(36);
        x(36)                           <= q_x(35) xor q_x(39);
      when "001" =>
        x(35)                           <= q_x(34) xor q_t;
        x(34)                           <= q_x(33);
      when "010" =>
        x(33)                           <= q_x(32) xor q_t;
        x(32)                           <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_15;
      when others =>
        null;
      end case;
    when MI_15 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      x(to_integer(OFFSET_32 & q_count_1)) <= q_x(to_integer(OFFSET_32 & q_count_1)) xor q_x(to_integer(q_count_1));      
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_16;
      end if;
    when MI_16 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_b(7);
        x(7)                            <= q_b(6);
        x(6)                            <= q_b(5);
        x(5)                            <= q_b(4);
        x(4)                            <= q_b(3) xor q_b(7);
      when "001" =>
        x(3)                            <= q_b(2) xor q_t;
        x(2)                            <= q_b(1);
      when "010" =>
        x(1)                            <= q_b(0) xor q_t;
        x(0)                            <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_17;
      when others =>
        null;
      end case;
    when MI_17 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      x(to_integer(q_count_1))          <= q_x(to_integer(q_count_1)) xor q_x(to_integer(OFFSET_32 & q_count_1));
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_18;
      end if;
    when MI_18 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_x(39);
        x(39)                           <= q_x(38);
        x(38)                           <= q_x(37);
        x(37)                           <= q_x(36);
        x(36)                           <= q_x(35) xor q_x(39);
      when "001" =>
        x(35)                           <= q_x(34) xor q_t;
        x(34)                           <= q_x(33);
      when "010" =>
        x(33)                           <= q_x(32) xor q_t;
        x(32)                           <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_19;
      when others =>
        null;
      end case;
    when MI_19 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      x(to_integer(OFFSET_32 & q_count_1)) <= q_x(to_integer(OFFSET_32 & q_count_1)) xor q_x(to_integer(OFFSET_24 & q_count_1));
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_20;
      end if;
    when MI_20 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_x(31);
        x(31)                           <= q_x(30);
        x(30)                           <= q_x(29);
        x(29)                           <= q_x(28);
        x(28)                           <= q_x(27) xor q_x(31);
      when "001" =>
        x(27)                           <= q_x(26) xor q_t;
        x(26)                           <= q_x(25);
      when "010" =>
        x(25)                           <= q_x(24) xor q_t;
        x(24)                           <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_21;
      when others =>
        null;
      end case;
    when MI_21 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      x(to_integer(OFFSET_24 & q_count_1)) <= q_x(to_integer(OFFSET_24 & q_count_1)) xor q_x(to_integer(OFFSET_16 & q_count_1));
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_22;
      end if;
    when MI_22 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_x(23);
        x(23)                           <= q_x(22);
        x(22)                           <= q_x(21);
        x(21)                           <= q_x(20);
        x(20)                           <= q_x(19) xor q_x(23);
      when "001" =>
        x(19)                           <= q_x(18) xor q_t;
        x(18)                           <= q_x(17);
      when "010" =>
        x(17)                           <= q_x(16) xor q_t;
        x(16)                           <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_23;
      when others =>
        null;
      end case;
    when MI_23 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      x(to_integer(OFFSET_16 & q_count_1)) <= q_x(to_integer(OFFSET_16 & q_count_1)) xor q_x(to_integer(OFFSET_8 & q_count_1));
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_24;
      end if;
    when MI_24 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_x(15);
        x(15)                           <= q_x(14);
        x(14)                           <= q_x(13);
        x(13)                           <= q_x(12);
        x(12)                           <= q_x(11) xor q_x(15);
      when "001" =>
        x(11)                           <= q_x(10) xor q_t;
        x(10)                           <= q_x(9);
      when "010" =>
        x(9)                            <= q_x(8) xor q_t;
        x(8)                            <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_25;
      when others =>
        null;
      end case;
    when MI_25 =>
      count_start_1                     <= '0';
      count_en_1                        <= q_count_2(0);
      count_start_2                     <= q_count_2(0);
      count_en_2                        <= '1';
      if q_count_2 = 0 then
        x(to_integer(OFFSET_8 & q_count_1)) <= q_x(to_integer(OFFSET_8 & q_count_1)) xor q_b(to_integer(q_count_1));
      else
        x(to_integer(q_count_1))            <= q_x(to_integer(q_count_1)) xor q_m(to_integer(q_count_1));
      end if;
      if q_count_1 = 7 and q_count_2 = 1 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_26;
      end if;
    when MI_26 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_m(7);
        m(7)                            <= q_m(6);
        m(6)                            <= q_m(5);
        m(5)                            <= q_m(4);
        m(4)                            <= q_m(3) xor q_m(7);
      when "001" =>
        m(3)                            <= q_m(2) xor q_t;
        m(2)                            <= q_m(1);
      when "010" =>
        m(1)                            <= q_m(0) xor q_t;
        m(0)                            <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_27;
      when others =>
        null;
      end case;
    when MI_27 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      x(to_integer(OFFSET_8 & q_count_1)) <= q_x(to_integer(OFFSET_8 & q_count_1)) xor q_m(to_integer(q_count_1));
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_28;
      end if;
    when MI_28 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_m(7);
        m(7)                            <= q_m(6);
        m(6)                            <= q_m(5);
        m(5)                            <= q_m(4);
        m(4)                            <= q_m(3) xor q_m(7);
      when "001" =>
        m(3)                            <= q_m(2) xor q_t;
        m(2)                            <= q_m(1);
      when "010" =>
        m(1)                            <= q_m(0) xor q_t;
        m(0)                            <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_29;
      when others =>
        null;
      end case;
    when MI_29 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      x(to_integer(OFFSET_16 & q_count_1)) <= q_x(to_integer(OFFSET_16 & q_count_1)) xor q_m(to_integer(q_count_1));
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_30;
      end if;
    when MI_30 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_m(7);
        m(7)                            <= q_m(6);
        m(6)                            <= q_m(5);
        m(5)                            <= q_m(4);
        m(4)                            <= q_m(3) xor q_m(7);
      when "001" =>
        m(3)                            <= q_m(2) xor q_t;
        m(2)                            <= q_m(1);
      when "010" =>
        m(1)                            <= q_m(0) xor q_t;
        m(0)                            <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_31;
      when others =>
        null;
      end case;
    when MI_31 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      x(to_integer(OFFSET_24 & q_count_1)) <= q_x(to_integer(OFFSET_24 & q_count_1)) xor q_m(to_integer(q_count_1));
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= MI_32;
      end if;
    when MI_32 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      case q_count_1 is
      when "000" =>
        t                               <= q_m(7);
        m(7)                            <= q_m(6);
        m(6)                            <= q_m(5);
        m(5)                            <= q_m(4);
        m(4)                            <= q_m(3) xor q_m(7);
      when "001" =>
        m(3)                            <= q_m(2) xor q_t;
        m(2)                            <= q_m(1);
      when "010" =>
        m(1)                            <= q_m(0) xor q_t;
        m(0)                            <= q_t;
        count_start_1                   <= '1';
        mi_state_next                   <= MI_33;
      when others =>
        null;
      end case;
    when MI_33 =>
      count_start_1                     <= '0';
      count_en_1                        <= '1';
      x(to_integer(OFFSET_32 & q_count_1)) <= q_x(to_integer(OFFSET_32 & q_count_1)) xor q_m(to_integer(q_count_1));
      if q_count_1 = 7 then
        count_start_1                   <= '1';
        mi_state_next                   <= FINISH;
      end if;
    when FINISH =>
      done                              <= '1';
      mi_state_next                     <= IDLE;
    end case;
  end process mi_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_mi_state                        <= IDLE;
    elsif rising_edge(clk) then
      q_mi_state                        <= mi_state_next;
      q_m                               <= m;
      q_a                               <= a;
      q_b                               <= b;
      q_x                               <= x;
      q_t                               <= t;
      if count_start_1 = '1' then
        q_count_1                       <= (others => '0');
      elsif count_en_1 = '1' then
        q_count_1                       <= q_count_1 + 1;
      end if;
      if count_start_2 = '1' then
        q_count_2                       <= (others => '0');
      elsif count_en_2 = '1' then
        q_count_2                       <= q_count_2 + 1;
      end if;
    end if;
  end process registers;
  
end architecture luffa512_mi_rtl;