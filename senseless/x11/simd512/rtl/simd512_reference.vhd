--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simd512_reference is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  data_in                               : in std_logic_vector(511 downto 0);
  hash                                  : out std_logic_vector(511 downto 0);
  hash_new                              : out std_logic
);
end entity simd512_reference;

architecture simd512_reference_rtl of simd512_reference is
  
  alias slv is std_logic_vector;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype word8 is slv(7 downto 0);
  subtype word6 is slv(5 downto 0);
  subtype natural_0_3 is natural range 0 to 3;
  
  type simd512_state is (IDLE, EXEC_1, EXEC_2, EXEC_3, EXEC_4, EXEC_5, EXEC_6, EXEC_7, EXEC_8, EXEC_9, EXEC_10, EXEC_11, EXEC_12, EXEC_13, EXEC_14, EXEC_15, EXEC_16, EXEC_17, EXEC_18, EXEC_19, FINISH);

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
  begin
    return word32(x(x'high-n downto 0) & x(x'high downto x'length-n));
  end rotl32;
  
  type word32_array256 is array(0 to 255) of word32;
  type word32_array32 is array(0 to 31) of word32;
  type word32_array8 is array(0 to 7) of word32;
  type word32_array4 is array(0 to 3) of word32;
  type word9_array256 is array(0 to 255) of slv(8 downto 0);
  type word8_array256 is array(0 to 255) of word8;
  type word8_array128 is array(0 to 127) of word8;
  type word8_array4 is array(0 to 3) of word8;
  type nat_array_8 is array(0 to 7) of natural;
  type nat_array_4 is array(0 to 3) of natural;
  type nat_array_7_8 is array(0 to 6) of nat_array_8;
  type nat_array_4_8 is array(0 to 3, 0 to 7) of natural;
  type int_array_4 is array(0 to 3) of integer;
  
  function resize_8_32(x: word8) return word32 is
  begin
    return word32(resize(unsigned(x),32));
  end function resize_8_32;
  
  function reds1(x: word32) return word32 is
    variable x2                         : word32;
    variable x3                         : word32;
  begin
    x2                                  := shr32(x,8);
    x3                                  := word32(resize(signed(unsigned(x(7 downto 0)) - unsigned(x2(23 downto 0))),32));
    return x3;
  end function reds1;
  
  function reds2(x: word64) return word32 is
    variable x2                         : word64;
    variable x3                         : slv(47 downto 0);
  begin
    x2                                  := shr64(x,16);
    x3                                  := slv(unsigned(x(15 downto 0)) + unsigned(x2(47 downto 0)));
    return x3(31 downto 0);
  end function reds2;
  
  function ntt8(d_in: word8_array128; xb: word6; xs: word6; y_ind: slv(1 downto 0)) return word32_array8 is
    variable x                          : word32_array4;
    variable a                          : word32_array4;
    variable b                          : word32_array4;
    variable y                          : word32_array8;
  begin
    x(0)                                := resize_8_32(d_in(to_integer(unsigned(xb))));
    x(1)                                := resize_8_32(d_in(to_integer(unsigned(xb) + unsigned(xs))));
    x(2)                                := resize_8_32(d_in(to_integer(unsigned(xb) + (unsigned(xs) & "0"))));
    x(3)                                := resize_8_32(d_in(to_integer(unsigned(xb) + 3*unsigned(xs))));
    a(0)                                := word32(signed(x(0)) + signed(x(2)));
    a(1)                                := word32(signed(x(0)) + signed(shl32(x(2),4)));
    a(2)                                := word32(signed(x(0)) - signed(x(2)));
    a(3)                                := word32(signed(x(0)) - signed(shl32(x(2),4)));
    b(0)                                := word32(signed(x(1)) + signed(x(3)));
    b(1)                                := reds1(word32(signed(shl32(x(1),2)) + signed(shl32(x(3),6))));
    b(2)                                := word32(signed(shl32(x(1),4)) - signed(shl32(x(3),4)));
    b(3)                                := reds1(word32(signed(shl32(x(1),6)) + signed(shl32(x(3),2))));
    for i in 0 to 3 loop
      y(i)                              := word32(signed(a(i)) + signed(b(i)));
      y(4+i)                            := word32(signed(a(i)) - signed(b(i)));
    end loop;
    -- debug
    -- if y_ind = "01" then
      -- for i in 0 to 3 loop
        -- y(i)                            := x(i);
      -- end loop;
      -- -- -- y(0)                              := word32(resize(unsigned(xb),32));
      -- -- -- y(1)                              := word32(resize(unsigned(xb) + unsigned(xs),32));
      -- -- -- y(2)                              := word32(resize(unsigned(xb) + (unsigned(xs) & "0"),32));
      -- -- -- y(3)                              := word32(resize(unsigned(xb) + 3*unsigned(xs),32));
    -- end if;
    return y;
  end ntt8;
  
  function ntt16(d_in: word8_array128; d_in_off: slv(1 downto 0); xb: word6; xs: word6; rb: word8; y: word32_array256; y_ind: slv(1 downto 0)) return word32_array256 is
    variable xb_plus_d_in_off           : word6;
    variable xb_plus_xs_plus_d_in_off   : word6;
    variable y0                         : word32_array8;
    variable y1                         : word32_array8;
    variable y2                         : word32_array256;
    variable y_ind_shift                : word8;
  begin
    xb_plus_d_in_off                    := slv(unsigned(xb) + unsigned(d_in_off));
    xb_plus_xs_plus_d_in_off            := slv(unsigned(xb) + unsigned(xs) + unsigned(d_in_off));
    y0                                  := ntt8(d_in, xb_plus_d_in_off, shl6(xs,1), y_ind);
    y1                                  := ntt8(d_in, xb_plus_xs_plus_d_in_off, shl6(xs,1), y_ind);
    y2                                  := y;
    y_ind_shift                         := y_ind & "000000";
    for i in 0 to 7 loop
      y2(to_integer(unsigned(rb)+unsigned(y_ind_shift)+i))    := word32(signed(y0(i)) + signed(shl32(y1(i),i)));
      y2(to_integer(unsigned(rb)+unsigned(y_ind_shift)+8+i))  := word32(signed(y0(i)) - signed(shl32(y1(i),i)));
    end loop;
    return y2;
  end ntt16;
  
  constant ALPHA                        : word9_array256 := ("000000001","000101001","010001011","000101101",
                                                             "000101110","001010111","011100010","000001110",
                                                             "000111100","010010011","001110100","010000010",
                                                             "010111110","001010000","011000100","001000101",
                                                             "000000010","001010010","000010101","001011010",
                                                             "001011100","010101110","011000011","000011100",
                                                             "001111000","000100101","011101000","000000011",
                                                             "001111011","010100000","010000111","010001010",
                                                             "000000100","010100100","000101010","010110100",
                                                             "010111000","001011011","010000101","000111000",
                                                             "011110000","001001010","011001111","000000110",
                                                             "011110110","000111111","000001101","000010011",
                                                             "000001000","001000111","001010100","001100111",
                                                             "001101111","010110110","000001001","001110000",
                                                             "011011111","010010100","010011101","000001100",
                                                             "011101011","001111110","000011010","000100110",
                                                             "000010000","010001110","010101000","011001110",
                                                             "011011110","001101011","000010010","011100000",
                                                             "010111101","000100111","000111001","000011000",
                                                             "011010101","011111100","000110100","001001100",
                                                             "000100000","000011011","001001111","010011011",
                                                             "010111011","011010110","000100100","010111111",
                                                             "001111001","001001110","001110010","000110000",
                                                             "010101001","011110111","001101000","010011000",
                                                             "001000000","000110110","010011110","000110101",
                                                             "001110101","010101011","001001000","001111101",
                                                             "011110010","010011100","011100100","001100000",
                                                             "001010001","011101101","011010000","000101111",
                                                             "010000000","001101100","000111011","001101010",
                                                             "011101010","001010101","010010000","011111010",
                                                             "011100011","000110111","011000111","011000000",
                                                             "010100010","011011001","010011111","001011110",
                                                             "100000000","011011000","001110110","011010100",
                                                             "011010011","010101010","000011111","011110011",
                                                             "011000101","001101110","010001101","001111111",
                                                             "001000011","010110001","000111101","010111100",
                                                             "011111111","010101111","011101100","010100111",
                                                             "010100101","001010011","000111110","011100101",
                                                             "010001001","011011100","000011001","011111110",
                                                             "010000110","001100001","001111010","001110111",
                                                             "011111101","001011101","011010111","001001101",
                                                             "001001001","010100110","001111100","011001001",
                                                             "000010001","010110111","000110010","011111011",
                                                             "000001011","011000010","011110100","011101110",
                                                             "011111001","010111010","010101101","010011010",
                                                             "010010010","001001011","011111000","010010001",
                                                             "000100010","001101101","001100100","011110101",
                                                             "000010110","010000011","011100111","011011011",
                                                             "011110001","001110011","001011001","000110011",
                                                             "000100011","010010110","011101111","000100001",
                                                             "001000100","011011010","011001000","011101001",
                                                             "000101100","000000101","011001101","010110101",
                                                             "011100001","011100110","010110010","001100110",
                                                             "001000110","000101011","011011101","001000010",
                                                             "010001000","010110011","010001111","011010001",
                                                             "001011000","000001010","010011001","001101001",
                                                             "011000001","011001011","001100011","011001100",
                                                             "010001100","001010110","010111001","010000100",
                                                             "000001111","001100101","000011101","010100001",
                                                             "010110000","000010100","000110001","011010010",
                                                             "010000001","010010101","011000110","010010111",
                                                             "000010111","010101100","001110001","000000111",
                                                             "000011110","011001010","000111010","001000001",
                                                             "001011111","000101000","001100010","010100011");

  function ntt_loop(rb: word8; hk: word8; as: slv(3 downto 0); y: word32_array256) return word32_array256 is
    variable rb_plus_hk                 : word8;
    variable m                          : word32;
    variable n                          : word32;
    variable y2                         : word32_array256;
    variable rb_plus_u                  : word8_array4;    
    variable rb_plus_u_plus_hk          : word8_array4;    
    variable v_plus_as                  : word8_array4;
    variable n_times_alpha              : word64;
    variable u                          : word8;
    variable v                          : word8;
    variable t                          : word32;
  begin
    rb_plus_hk                          := slv(unsigned(rb) + unsigned(hk));
    m                                   := y(to_integer(unsigned(rb)));
    n                                   := y(to_integer(unsigned(rb_plus_hk)));
    u                                   := (others => '0');
    v                                   := (others => '0');
    for i in 0 to 3 loop
      rb_plus_u(i)                      := slv(unsigned(rb) + to_unsigned(i,2));
      rb_plus_u_plus_hk(i)              := slv(unsigned(rb_plus_hk) + to_unsigned(i,2));
      v_plus_as(i)                      := slv(unsigned(v) + i*unsigned(as));
    end loop;
    y2                                  := y;
    y2(to_integer(unsigned(rb)))        := slv(signed(m) + signed(n));
    y2(to_integer(unsigned(rb_plus_hk))) := slv(signed(m) - signed(n));
    -- debug
    -- m                                   := y2(to_integer(unsigned(rb_plus_u(3))));
    -- n                                   := y2(to_integer(unsigned(rb_plus_u_plus_hk(3))));
    -- n_times_alpha                       := slv(resize(unsigned(n) * unsigned(ALPHA(to_integer(unsigned(v_plus_as(3))))),64));
    -- y2(0)                               := n_times_alpha(31 downto 0);
    -- y2(1)                               := reds2(n_times_alpha);
    while unsigned(u) < unsigned(hk) loop
      if u /= X"00" then
        for i in 0 to 3 loop
          m                                               := y2(to_integer(unsigned(rb_plus_u(i))));
          n                                               := y2(to_integer(unsigned(rb_plus_u_plus_hk(i))));
          n_times_alpha                                   := slv(resize(signed(n) * signed(ALPHA(to_integer(unsigned(v_plus_as(i))))),64));
          t                                               := reds2(n_times_alpha);
          y2(to_integer(unsigned(rb_plus_u(i))))          := slv(signed(m) + signed(t));
          y2(to_integer(unsigned(rb_plus_u_plus_hk(i))))  := slv(signed(m) - signed(t));
        end loop;
      else
        for i in 1 to 3 loop
          m                                               := y2(to_integer(unsigned(rb_plus_u(i))));
          n                                               := y2(to_integer(unsigned(rb_plus_u_plus_hk(i))));
          n_times_alpha                                   := slv(resize(signed(n) * signed(ALPHA(to_integer(unsigned(v_plus_as(i))))),64));
          t                                               := reds2(n_times_alpha);
          y2(to_integer(unsigned(rb_plus_u(i))))          := slv(signed(m) + signed(t));
          y2(to_integer(unsigned(rb_plus_u_plus_hk(i))))  := slv(signed(m) - signed(t));
        end loop;
      end if;
      u                                 := slv(unsigned(u) + 4);
      v                                 := slv(unsigned(v) + 4*unsigned(as));
      for i in 0 to 3 loop
        rb_plus_u(i)                    := slv(unsigned(rb_plus_u(i)) + 4);
        rb_plus_u_plus_hk(i)            := slv(unsigned(rb_plus_u_plus_hk(i)) + 4);
        v_plus_as(i)                    := slv(unsigned(v_plus_as(i)) + 4*unsigned(as));
      end loop;
    end loop;
    return y2;    
  end ntt_loop;
  
  function ntt32(d_in: word8_array128; d_in_off: slv(1 downto 0); xb: word6; xs: word6; rb: word8; y: word32_array256; y_ind: slv(1 downto 0)) return word32_array256 is
    variable xb_plus_xs                 : word6;
    variable rb_plus_16                 : word8;
    variable y_ind_shift                : word8;
    variable rb_plus_y_ind_shift        : word8;
    variable y2                         : word32_array256;
  begin
    xb_plus_xs                          := slv(unsigned(xb) + unsigned(xs));
    rb_plus_16                          := slv(unsigned(rb) + 16);
    y2                                  := ntt16(d_in, d_in_off, xb, shl6(xs,1), rb, y, y_ind);
    y2                                  := ntt16(d_in, d_in_off, xb_plus_xs, shl6(xs,1), rb_plus_16, y2, y_ind);
    y_ind_shift                         := y_ind & "000000";
    rb_plus_y_ind_shift                 := word8(unsigned(rb) + unsigned(y_ind_shift));
    y2                                  := ntt_loop(rb_plus_y_ind_shift, X"10", X"8", y2);
    return y2;
  end ntt32;
  
  function ntt64(d_in: word8_array128; d_in_off: slv(1 downto 0); xs: word6; y: word32_array256; y_ind: slv(1 downto 0)) return word32_array256 is
    variable xd                         : word6;
    variable y2                         : word32_array256;
    variable y_ind_shift                : word8;
  begin
    xd                                  := shl6(xs,1);
    y2                                  := ntt32(d_in, d_in_off, "000000", xd, X"00", y, y_ind);
    y2                                  := ntt32(d_in, d_in_off, xs, xd, X"20", y2, y_ind);
    y_ind_shift                         := y_ind & "000000";
    y2                                  := ntt_loop(y_ind_shift, X"20", X"4", y2);
    return y2;
  end ntt64;
  
  function ntt256(d_in: word8_array128; y: word32_array256) return word32_array256 is
    variable y2                         : word32_array256;
  begin
    y2                                  := ntt64(d_in, "00", "000100", y, "00");
    y2                                  := ntt64(d_in, "10", "000100", y2, "01");
    y2                                  := ntt_loop(X"00", X"40", X"2", y2);
    y2                                  := ntt64(d_in, "01", "000100", y2, "10");
    y2                                  := ntt64(d_in, "11", "000100", y2, "11");
    y2                                  := ntt_loop(X"80", X"40", X"2", y2);
    y2                                  := ntt_loop(X"00", X"80", X"1", y2);
    return y2;
  end ntt256;
  
  constant YOFF_B_N                     : word9_array256 := ("000000001","010100011","001100010","000101000",
                                                             "001011111","001000001","000111010","011001010",
                                                             "000011110","000000111","001110001","010101100",
                                                             "000010111","010010111","011000110","010010101",
                                                             "010000001","011010010","000110001","000010100",
                                                             "010110000","010100001","000011101","001100101",
                                                             "000001111","010000100","010111001","001010110",
                                                             "010001100","011001100","001100011","011001011",
                                                             "011000001","001101001","010011001","000001010",
                                                             "001011000","011010001","010001111","010110011",
                                                             "010001000","001000010","011011101","000101011",
                                                             "001000110","001100110","010110010","011100110",
                                                             "011100001","010110101","011001101","000000101",
                                                             "000101100","011101001","011001000","011011010",
                                                             "001000100","000100001","011101111","010010110",
                                                             "000100011","000110011","001011001","001110011",
                                                             "011110001","011011011","011100111","010000011",
                                                             "000010110","011110101","001100100","001101101",
                                                             "000100010","010010001","011111000","001001011",
                                                             "010010010","010011010","010101101","010111010",
                                                             "011111001","011101110","011110100","011000010",
                                                             "000001011","011111011","000110010","010110111",
                                                             "000010001","011001001","001111100","010100110",
                                                             "001001001","001001101","011010111","001011101",
                                                             "011111101","001110111","001111010","001100001",
                                                             "010000110","011111110","000011001","011011100",
                                                             "010001001","011100101","000111110","001010011",
                                                             "010100101","010100111","011101100","010101111",
                                                             "011111111","010111100","000111101","010110001",
                                                             "001000011","001111111","010001101","001101110",
                                                             "011000101","011110011","000011111","010101010",
                                                             "011010011","011010100","001110110","011011000",
                                                             "100000000","001011110","010011111","011011001",
                                                             "010100010","011000000","011000111","000110111",
                                                             "011100011","011111010","010010000","001010101",
                                                             "011101010","001101010","000111011","001101100",
                                                             "010000000","000101111","011010000","011101101",
                                                             "001010001","001100000","011100100","010011100",
                                                             "011110010","001111101","001001000","010101011",
                                                             "001110101","000110101","010011110","000110110",
                                                             "001000000","010011000","001101000","011110111",
                                                             "010101001","000110000","001110010","001001110",
                                                             "001111001","010111111","000100100","011010110",
                                                             "010111011","010011011","001001111","000011011",
                                                             "000100000","001001100","000110100","011111100",
                                                             "011010101","000011000","000111001","000100111",
                                                             "010111101","011100000","000010010","001101011",
                                                             "011011110","011001110","010101000","010001110",
                                                             "000010000","000100110","000011010","001111110",
                                                             "011101011","000001100","010011101","010010100",
                                                             "011011111","001110000","000001001","010110110",
                                                             "001101111","001100111","001010100","001000111",
                                                             "000001000","000010011","000001101","000111111",
                                                             "011110110","000000110","011001111","001001010",
                                                             "011110000","000111000","010000101","001011011",
                                                             "010111000","010110100","000101010","010100100",
                                                             "000000100","010001010","010000111","010100000",
                                                             "001111011","000000011","011101000","000100101",
                                                             "001111000","000011100","011000011","010101110",
                                                             "001011100","001011010","000010101","001010010",
                                                             "000000010","001000101","011000100","001010000",
                                                             "010111110","010000010","001110100","010010011",
                                                             "000111100","000001110","011100010","001010111",
                                                             "000101110","000101101","010001011","000101001");

constant YOFF_B_F                       : word8_array256 := ("00000010","11001011","10011100","00101111",
                                                             "01110110","11010110","01101011","01101010",
                                                             "00101101","01011101","11010100","00010100",
                                                             "01101111","01001001","10100010","11111011",
                                                             "01100001","11010111","11111001","00110101",
                                                             "11010011","00010011","00000011","01011001",
                                                             "00110001","11001111","01100101","01000011",
                                                             "10010111","10000010","11011111","00010111",
                                                             "10111101","11001010","10110010","11101111",
                                                             "11111101","01111111","11001100","00110001",
                                                             "01001100","11101100","01010010","10001001",
                                                             "11101000","10011101","01000001","01001111",
                                                             "01100000","10100001","10110000","10000010",
                                                             "10100001","00011110","00101111","00001001",
                                                             "10111101","11110111","00111101","11100010",
                                                             "11111000","01011010","01101011","01000000",
                                                             "00000000","01011000","10000011","11110011",
                                                             "10000101","00111011","01110001","01110011",
                                                             "00010001","11101100","00100001","11010101",
                                                             "00001100","10111111","01101111","00010011",
                                                             "11111011","00111101","01100111","11010000",
                                                             "00111001","00100011","10010100","11111000",
                                                             "00101111","01110100","01000001","01110111",
                                                             "11111001","10110010","10001111","00101000",
                                                             "10111101","10000001","00001000","10100011",
                                                             "11001100","11100011","11100110","11000100",
                                                             "11001101","01111010","10010111","00101101",
                                                             "10111011","00010011","11100011","01001000",
                                                             "11110111","01111101","01101111","01111001",
                                                             "10001100","11011100","00000110","01101011",
                                                             "01001101","01000101","00001010","01100101",
                                                             "00010101","01000001","10010101","10101011",
                                                             "11111111","00110110","01100101","11010010",
                                                             "10001011","00101011","10010110","10010111",
                                                             "11010100","10100100","00101101","11101101",
                                                             "10010010","10111000","01011111","00000110",
                                                             "10100000","00101010","00001000","11001100",
                                                             "00101110","11101110","11111110","10101000",
                                                             "11010000","00110010","10011100","10111110",
                                                             "01101010","01111111","00100010","11101010",
                                                             "01000100","00110111","01001111","00010010",
                                                             "00000100","10000010","00110101","11010000",
                                                             "10110101","00010101","10101111","01111000",
                                                             "00011001","01100100","11000000","10110010",
                                                             "10100001","01100000","01010001","01111111",
                                                             "01100000","11100011","11010010","11111000",
                                                             "01000100","00001010","11000100","00011111",
                                                             "00001001","10100111","10010110","11000001",
                                                             "00000000","10101001","01111110","00001110",
                                                             "01111100","11000110","10010000","10001110",
                                                             "11110000","00010101","11100000","00101100",
                                                             "11110101","01000010","10010010","11101110",
                                                             "00000110","11000100","10011010","00110001",
                                                             "11001000","11011110","01101101","00001001",
                                                             "11010010","10001101","11000000","10001010",
                                                             "00001000","01001111","01110010","11011001",
                                                             "01000100","10000000","11111001","01011110",
                                                             "00110101","00011110","00011011","00111101",
                                                             "00110100","10000111","01101010","11010100",
                                                             "01000110","11101110","00011110","10111001",
                                                             "00001010","10000100","10010010","10001000",
                                                             "01110101","00100101","11111011","10010110",
                                                             "10110100","10111100","11110111","10011100",
                                                             "11101100","11000000","01101100","01010110");

  function ccode(y: word32_array256; last: std_logic) return word32_array256 is
    variable z                          : word32;
    variable y2                         : word32_array256;
  begin
    for i in 0 to 255 loop
      if last = '0' then
        y2(i)                           := word32(unsigned(y(i)) + unsigned(YOFF_B_N(i)));
      else
        y2(i)                           := word32(unsigned(y(i)) + unsigned(YOFF_B_F(i)));
      end if;
      y2(i)                             := reds2(word64(resize(signed(y2(i)),64)));
      y2(i)                             := reds1(y2(i));
      y2(i)                             := reds1(y2(i));
      if signed(y2(i)) > 128 then
       y2(i)                           := word32(signed(y2(i)) - 257);
      end if;
    end loop;
    return y2;
  end ccode;
  
  function if_fn(x: word32; y: word32; z: word32) return word32 is
  begin
    return word32(((y xor z) and x) xor z);
  end if_fn;
  
  function maj(x: word32; y: word32; z: word32) return word32 is
  begin
    return word32((x and y) or ((x or y) and z));
  end maj;
  
  function step_elt(x: word32_array32; n: natural; w: word32; fn: std_logic; s: natural; a: word32_array8; p: natural) return word32_array32 is
    variable tt                         : word32;
    variable tfun                       : word32;
    variable x2                         : word32_array32;
  begin
    if fn = '0' then
      tt                                := slv(unsigned(x(24+n)) + unsigned(w) + unsigned(if_fn(x(n),x(8+n),x(16+n))));
      tfun                              := if_fn(x(n),x(8+n),x(16+n));
    else
      tt                                := slv(unsigned(x(24+n)) + unsigned(w) + unsigned(maj(x(n),x(8+n),x(16+n))));
      tfun                              := maj(x(n),x(8+n),x(16+n));
    end if;
    x2                                  := x;
    x2(n)                               := slv(unsigned(rotl32(tt,s)) + unsigned(a(p)));
    x2(24+n)                            := x2(16+n);
    x2(16+n)                            := x2(8+n);
    x2(8+n)                             := a(n);
    return x2;
  end function step_elt;
  
  function step_big(x: word32_array32; w: word32_array8; fn: std_logic; r: natural; s: natural; p: nat_array_8) return word32_array32 is
    variable a                          : word32_array8;
    variable x2                         : word32_array32;
  begin
    x2                                  := x;
    for i in 0 to 7 loop
      a(i)                              := rotl32(x2(i),r);
    end loop;
    for i in 0 to 7 loop
      x2                                := step_elt(x2,i,w(i),fn,s,a,p(i));
    end loop;
    return x2;
  end step_big;
  
  function inner(a: word32; b: word32; c: integer) return word32 is
    variable d                          : word64;
    variable e                          : word64;
    variable f                          : word32;
  begin
    d                                   := slv(unsigned(a) * c);
    e                                   := slv(unsigned(b) * c);
    f                                   := e(15 downto 0) & d(15 downto 0);
    return f;
  end inner;
  
  constant SB                           : nat_array_4_8 := (( 4, 6, 0, 2, 7, 5, 3, 1),
                                                            (15,11,12, 8, 9,13,10,14),
                                                            (17,18,23,20,22,21,16,19),
                                                            (30,24,25,31,27,29,28,26));
  constant O1                           : int_array_4 := (0, 0, -256, -383);
  constant O2                           : int_array_4 := (1, 1, -128, -255); 
  constant MM                           : nat_array_4 := (185, 185, 233, 233); 
  
  function wb(a: natural; b: natural; y: word32_array256) return word32_array8 is
    variable index_1                    : integer;
    variable index_2                    : integer;
    variable w                          : word32_array8;
  begin
    for i in 0 to 7 loop
      index_1                           := 16 * SB(a,b) + 2*i + O1(a);
      index_2                           := 16 * SB(a,b) + 2*i + O2(a);
      w(i)                              := inner(y(index_1),y(index_2),MM(a));
    end loop;
    return w;
  end wb;
  
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
    
  function one_round_big(x: word32_array32; y: word32_array256; ri: natural; isp: natural; rs: nat_array_4) return word32_array32 is
    variable w                          : word32_array8;
    variable x2                         : word32_array32;
  begin
    x2                                  := x;
    for i in 0 to 3 loop
      w                                 := wb(ri,i,y);
      x2                                := step_big(x2,w,'0',rs(i),rs((i+1) mod 4),PP8(M7(isp,i)));
    end loop;
    for i in 0 to 3 loop
      w                                 := wb(ri,4+i,y);
      x2                                := step_big(x2,w,'1',rs(i),rs((i+1) mod 4),PP8(M7(isp,4+i)));
    end loop;
    return x2;
  end one_round_big;
  
  constant IV                           : word32_array32 := (X"0BA16B95", X"72F999AD", X"9FECC2AE", X"BA3264FC",
                                                             X"5E894929", X"8E9F30E5", X"2F1DAA37", X"F0F2C558",
                                                             X"AC506643", X"A90635A5", X"E25B878B", X"AAB7878F",
                                                             X"88817F7A", X"0A02892B", X"559A7550", X"598F657E",
                                                             X"7EEF60A1", X"6B70E3E8", X"9C1714D1", X"B958E2A8",
                                                             X"AB02675E", X"ED1C014F", X"CD8D65BB", X"FDB7A257",
                                                             X"09254899", X"D699C7BC", X"9019B6DC", X"2B9022E4",
                                                             X"8FA14956", X"21BF9BD3", X"B94D0943", X"6FFDDC22");
  
  constant PADDING                      : word8_array128 := (X"00",X"02",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00",
                                                             X"00",X"00",X"00",X"00",X"00",X"00",X"00",X"00");
                                                             
  constant ZEROS32_ARRAY256             : word32_array256 := (others => ZEROS32);
  
  signal simd512_state_next             : simd512_state;
  signal data_in_array                  : word8_array128;
  signal y                              : word32_array256;
  signal x                              : word32_array32;
  signal h                              : word32_array32;
  signal done                           : std_logic;
  
  signal q_simd512_state                : simd512_state;
  signal q_y                            : word32_array256;
  signal q_x                            : word32_array32;
  signal q_h                            : word32_array32;
  
begin

  hash_new                              <= done;
  
  output_mapping : for i in 0 to 15 generate
    hash((i+1)*32-1 downto i*32)        <= q_h(i);
  end generate output_mapping;
  
  input_mapping : for i in 0 to 63 generate
    data_in_array(i)                    <= data_in((i+1)*8-1 downto i*8);
    data_in_array(64+i)                 <= X"00";
  end generate input_mapping;
  
  simd512_proc : process(q_simd512_state, q_y, q_x, q_h, start, data_in_array)
  begin
    simd512_state_next                  <= q_simd512_state;
    y                                   <= q_y;
    x                                   <= q_x;
    h                                   <= q_h;
    done                                <= '0';
    case q_simd512_state is
    when IDLE =>
      if start = '1' then
        y                               <= ntt256(data_in_array, ZEROS32_ARRAY256);
        for i in 0 to 31 loop
          x(i)                          <= IV(i) xor (data_in_array(4*i+3) & data_in_array(4*i+2) & data_in_array(4*i+1) & data_in_array(4*i));
        end loop;
        simd512_state_next              <= EXEC_1;
      end if;
    when EXEC_1 =>
      y                                 <= ccode(q_y, '0');
      simd512_state_next                <= EXEC_2;
    when EXEC_2 =>
      x                                 <= one_round_big(q_x,q_y,0,0,(3,23,17,27));
      simd512_state_next                <= EXEC_3;
    when EXEC_3 =>
      x                                 <= one_round_big(q_x,q_y,1,1,(28,19,22,7));
      simd512_state_next                <= EXEC_4;
    when EXEC_4 =>
      x                                 <= one_round_big(q_x,q_y,2,2,(29,9,15,5));
      simd512_state_next                <= EXEC_5;
    when EXEC_5 =>
      x                                 <= one_round_big(q_x,q_y,3,3,(4,13,10,25));
      simd512_state_next                <= EXEC_6;
    when EXEC_6 =>
      x                                 <= step_big(q_x,(IV(0),IV(1),IV(2),IV(3),IV(4),IV(5),IV(6),IV(7)),'0',4,13,PP8(4));
      simd512_state_next                <= EXEC_7;
    when EXEC_7 =>
      x                                 <= step_big(q_x,(IV(8),IV(9),IV(10),IV(11),IV(12),IV(13),IV(14),IV(15)),'0',13,10,PP8(5));
      simd512_state_next                <= EXEC_8;
    when EXEC_8 =>
      x                                 <= step_big(q_x,(IV(16),IV(17),IV(18),IV(19),IV(20),IV(21),IV(22),IV(23)),'0',10,25,PP8(6));
      simd512_state_next                <= EXEC_9;
    when EXEC_9 =>
      x                                 <= step_big(q_x,(IV(24),IV(25),IV(26),IV(27),IV(28),IV(29),IV(30),IV(31)),'0',25,4,PP8(0));
      simd512_state_next                <= EXEC_10;
    when EXEC_10 =>
      y                                 <= ntt256(PADDING, q_y);
      for i in 0 to 31 loop
        h(i)                            <= q_x(i) xor (PADDING(4*i+3) & PADDING(4*i+2) & PADDING(4*i+1) & PADDING(4*i));
      end loop;
      simd512_state_next                <= EXEC_11;
    when EXEC_11 =>
      y                                 <= ccode(q_y, '1');
      simd512_state_next                <= EXEC_12;
    when EXEC_12 =>
      h                                 <= one_round_big(q_h,q_y,0,0,(3,23,17,27));
      simd512_state_next                <= EXEC_13;
    when EXEC_13 =>
      h                                 <= one_round_big(q_h,q_y,1,1,(28,19,22,7));
      simd512_state_next                <= EXEC_14;
    when EXEC_14 =>
      h                                 <= one_round_big(q_h,q_y,2,2,(29,9,15,5));
      simd512_state_next                <= EXEC_15;
    when EXEC_15 =>
      h                                 <= one_round_big(q_h,q_y,3,3,(4,13,10,25));
      simd512_state_next                <= EXEC_16;
    when EXEC_16 =>
      h                                 <= step_big(q_h,(q_x(0),q_x(1),q_x(2),q_x(3),q_x(4),q_x(5),q_x(6),q_x(7)),'0',4,13,PP8(4));
      simd512_state_next                <= EXEC_17;
    when EXEC_17 =>
      h                                 <= step_big(q_h,(q_x(8),q_x(9),q_x(10),q_x(11),q_x(12),q_x(13),q_x(14),q_x(15)),'0',13,10,PP8(5));
      simd512_state_next                <= EXEC_18;
    when EXEC_18 =>
      h                                 <= step_big(q_h,(q_x(16),q_x(17),q_x(18),q_x(19),q_x(20),q_x(21),q_x(22),q_x(23)),'0',10,25,PP8(6));
      simd512_state_next                <= EXEC_19;
    when EXEC_19 =>
      h                                 <= step_big(q_h,(q_x(24),q_x(25),q_x(26),q_x(27),q_x(28),q_x(29),q_x(30),q_x(31)),'0',25,4,PP8(0));
      simd512_state_next                <= FINISH;
    when FINISH =>
      done                              <= '1';
      simd512_state_next                <= IDLE;
    end case;
  end process simd512_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_simd512_state                   <= IDLE;
    elsif rising_edge(clk) then
      q_simd512_state                   <= simd512_state_next;
      q_y                               <= y;
      q_x                               <= x;
      q_h                               <= h;
    end if;
  end process registers;
  
end architecture simd512_reference_rtl;