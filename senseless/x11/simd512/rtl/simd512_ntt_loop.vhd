--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simd512_ntt_loop is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  clr                                   : in std_logic;
  start                                 : in std_logic;
  ccode_start                           : in std_logic;
  ccode_last                            : in std_logic;
  wb_start                              : in std_logic;
  rb                                    : in std_logic_vector(3 downto 0);
  hk                                    : in std_logic_vector(3 downto 0);
  as                                    : in std_logic_vector(3 downto 0);
  d_in                                  : in std_logic_vector(8191 downto 0);
  d_in_we                               : in std_logic;
  wb_r                                  : in std_logic_vector(1 downto 0);
  wb_rnd_i                              : in std_logic_vector(2 downto 0);
  d_out                                 : out std_logic_vector(8191 downto 0);
  w                                     : out std_logic_vector(255 downto 0);
  done                                  : out std_logic;
  ccode_done                            : out std_logic;
  wb_done                               : out std_logic
);
end entity simd512_ntt_loop;

architecture simd512_ntt_loop_rtl of simd512_ntt_loop is
  
  alias slv is std_logic_vector;
  
  component simd512_ram is
  port (
    clk                                 : in std_logic;
    clr                                 : in std_logic;
    d_in_all                            : in std_logic_vector(8191 downto 0);
    d_in                                : in std_logic_vector(511 downto 0);
    addr                                : in std_logic_vector(3 downto 0);
    we_all                              : in std_logic;
    we                                  : in std_logic;
    d_out_all                           : out std_logic_vector(8191 downto 0);
    d_out                               : out std_logic_vector(511 downto 0)
  );
  end component simd512_ram;
  
  type ntt_loop_state is (IDLE, EXEC_1, EXEC_2, EXEC_3, EXEC_4, INIT);
  type ccode_state is (IDLE, READ_DELAY, EXEC, WRITE_DELAY, FINISH);
  type wb_state is (IDLE, READ_DELAY, EXEC_TYPE_1, EXEC_TYPE_2_1, EXEC_TYPE_2_2, FINISH);
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype word6 is slv(5 downto 0);
  subtype uword9 is unsigned(8 downto 0);
  subtype uword8 is unsigned(7 downto 0);
  subtype sword32 is signed(31 downto 0);
  subtype sword9 is signed(8 downto 0);
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
  begin
    return word32(x(x'high-n downto 0) & x(x'high downto x'length-n));
  end rotl32;
  
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
  
  type word64_array16 is array(0 to 15) of word64;
  type word32_array16 is array(0 to 15) of word32;
  type word32_array8 is array(0 to 7) of word32;
  type uword9_array_16_16 is array(0 to 15, 0 to 15) of uword9;
  type uword8_array_16_16 is array(0 to 15, 0 to 15) of uword8;
  type uword8_array16 is array(0 to 15) of uword8;
  type sword32_array16 is array(0 to 15) of sword32;
  type sword9_array256 is array(0 to 255) of sword9;
  type nat_array_4_16 is array(0 to 3, 0 to 15) of natural;
  type nat_array_4 is array(0 to 3) of natural;
  
  constant MM                           : nat_array_4 := (185, 185, 233, 233);
  
  function inner(a: word32; b: word32; wb_r: slv(1 downto 0)) return word32 is
    variable d                          : word64;
    variable e                          : word64;
    variable f                          : word32;
  begin
    d                                   := slv(unsigned(a) * MM(to_integer(unsigned(wb_r))));
    e                                   := slv(unsigned(b) * MM(to_integer(unsigned(wb_r))));
    f                                   := e(15 downto 0) & d(15 downto 0);
    return f;
  end inner;
  
  constant ALPHA                        : sword9_array256 := ("000000001","000101001","010001011","000101101",
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
  
    constant YOFF_B_N                     : uword9_array_16_16 := (("000000001","010100011","001100010","000101000",
                                                                  "001011111","001000001","000111010","011001010",
                                                                  "000011110","000000111","001110001","010101100",
                                                                  "000010111","010010111","011000110","010010101"),
                                                                 ("010000001","011010010","000110001","000010100",
                                                                  "010110000","010100001","000011101","001100101",
                                                                  "000001111","010000100","010111001","001010110",
                                                                  "010001100","011001100","001100011","011001011"),
                                                                 ("011000001","001101001","010011001","000001010",
                                                                  "001011000","011010001","010001111","010110011",
                                                                  "010001000","001000010","011011101","000101011",
                                                                  "001000110","001100110","010110010","011100110"),
                                                                 ("011100001","010110101","011001101","000000101",
                                                                  "000101100","011101001","011001000","011011010",
                                                                  "001000100","000100001","011101111","010010110",
                                                                  "000100011","000110011","001011001","001110011"),
                                                                 ("011110001","011011011","011100111","010000011",
                                                                  "000010110","011110101","001100100","001101101",
                                                                  "000100010","010010001","011111000","001001011",
                                                                  "010010010","010011010","010101101","010111010"),
                                                                 ("011111001","011101110","011110100","011000010",
                                                                  "000001011","011111011","000110010","010110111",
                                                                  "000010001","011001001","001111100","010100110",
                                                                  "001001001","001001101","011010111","001011101"),
                                                                 ("011111101","001110111","001111010","001100001",
                                                                  "010000110","011111110","000011001","011011100",
                                                                  "010001001","011100101","000111110","001010011",
                                                                  "010100101","010100111","011101100","010101111"),
                                                                 ("011111111","010111100","000111101","010110001",
                                                                  "001000011","001111111","010001101","001101110",
                                                                  "011000101","011110011","000011111","010101010",
                                                                  "011010011","011010100","001110110","011011000"),
                                                                 ("100000000","001011110","010011111","011011001",
                                                                  "010100010","011000000","011000111","000110111",
                                                                  "011100011","011111010","010010000","001010101",
                                                                  "011101010","001101010","000111011","001101100"),
                                                                 ("010000000","000101111","011010000","011101101",
                                                                  "001010001","001100000","011100100","010011100",
                                                                  "011110010","001111101","001001000","010101011",
                                                                  "001110101","000110101","010011110","000110110"),
                                                                 ("001000000","010011000","001101000","011110111",
                                                                  "010101001","000110000","001110010","001001110",
                                                                  "001111001","010111111","000100100","011010110",
                                                                  "010111011","010011011","001001111","000011011"),
                                                                 ("000100000","001001100","000110100","011111100",
                                                                  "011010101","000011000","000111001","000100111",
                                                                  "010111101","011100000","000010010","001101011",
                                                                  "011011110","011001110","010101000","010001110"),
                                                                 ("000010000","000100110","000011010","001111110",
                                                                  "011101011","000001100","010011101","010010100",
                                                                  "011011111","001110000","000001001","010110110",
                                                                  "001101111","001100111","001010100","001000111"),
                                                                 ("000001000","000010011","000001101","000111111",
                                                                  "011110110","000000110","011001111","001001010",
                                                                  "011110000","000111000","010000101","001011011",
                                                                  "010111000","010110100","000101010","010100100"),
                                                                 ("000000100","010001010","010000111","010100000",
                                                                  "001111011","000000011","011101000","000100101",
                                                                  "001111000","000011100","011000011","010101110",
                                                                  "001011100","001011010","000010101","001010010"),
                                                                 ("000000010","001000101","011000100","001010000",
                                                                  "010111110","010000010","001110100","010010011",
                                                                  "000111100","000001110","011100010","001010111",
                                                                  "000101110","000101101","010001011","000101001"));

  constant YOFF_B_F                     : uword8_array_16_16 := (("00000010","11001011","10011100","00101111",
                                                                  "01110110","11010110","01101011","01101010",
                                                                  "00101101","01011101","11010100","00010100",
                                                                  "01101111","01001001","10100010","11111011"),
                                                                 ("01100001","11010111","11111001","00110101",
                                                                  "11010011","00010011","00000011","01011001",
                                                                  "00110001","11001111","01100101","01000011",
                                                                  "10010111","10000010","11011111","00010111"),
                                                                 ("10111101","11001010","10110010","11101111",
                                                                  "11111101","01111111","11001100","00110001",
                                                                  "01001100","11101100","01010010","10001001",
                                                                  "11101000","10011101","01000001","01001111"),
                                                                 ("01100000","10100001","10110000","10000010",
                                                                  "10100001","00011110","00101111","00001001",
                                                                  "10111101","11110111","00111101","11100010",
                                                                  "11111000","01011010","01101011","01000000"),
                                                                 ("00000000","01011000","10000011","11110011",
                                                                  "10000101","00111011","01110001","01110011",
                                                                  "00010001","11101100","00100001","11010101",
                                                                  "00001100","10111111","01101111","00010011"),
                                                                 ("11111011","00111101","01100111","11010000",
                                                                  "00111001","00100011","10010100","11111000",
                                                                  "00101111","01110100","01000001","01110111",
                                                                  "11111001","10110010","10001111","00101000"),
                                                                 ("10111101","10000001","00001000","10100011",
                                                                  "11001100","11100011","11100110","11000100",
                                                                  "11001101","01111010","10010111","00101101",
                                                                  "10111011","00010011","11100011","01001000"),
                                                                 ("11110111","01111101","01101111","01111001",
                                                                  "10001100","11011100","00000110","01101011",
                                                                  "01001101","01000101","00001010","01100101",
                                                                  "00010101","01000001","10010101","10101011"),
                                                                 ("11111111","00110110","01100101","11010010",
                                                                  "10001011","00101011","10010110","10010111",
                                                                  "11010100","10100100","00101101","11101101",
                                                                  "10010010","10111000","01011111","00000110"),
                                                                 ("10100000","00101010","00001000","11001100",
                                                                  "00101110","11101110","11111110","10101000",
                                                                  "11010000","00110010","10011100","10111110",
                                                                  "01101010","01111111","00100010","11101010"),
                                                                 ("01000100","00110111","01001111","00010010",
                                                                  "00000100","10000010","00110101","11010000",
                                                                  "10110101","00010101","10101111","01111000",
                                                                  "00011001","01100100","11000000","10110010"),
                                                                 ("10100001","01100000","01010001","01111111",
                                                                  "01100000","11100011","11010010","11111000",
                                                                  "01000100","00001010","11000100","00011111",
                                                                  "00001001","10100111","10010110","11000001"),
                                                                 ("00000000","10101001","01111110","00001110",
                                                                  "01111100","11000110","10010000","10001110",
                                                                  "11110000","00010101","11100000","00101100",
                                                                  "11110101","01000010","10010010","11101110"),
                                                                 ("00000110","11000100","10011010","00110001",
                                                                  "11001000","11011110","01101101","00001001",
                                                                  "11010010","10001101","11000000","10001010",
                                                                  "00001000","01001111","01110010","11011001"),
                                                                 ("01000100","10000000","11111001","01011110",
                                                                  "00110101","00011110","00011011","00111101",
                                                                  "00110100","10000111","01101010","11010100",
                                                                  "01000110","11101110","00011110","10111001"),
                                                                 ("00001010","10000100","10010010","10001000",
                                                                  "01110101","00100101","11111011","10010110",
                                                                  "10110100","10111100","11110111","10011100",
                                                                  "11101100","11000000","01101100","01010110"));
  
  constant WB_ADDRESSES                 : nat_array_4_16 := (( 4, 6, 0, 2, 7, 5, 3, 1, 4, 6, 0, 2, 7, 5, 3, 1),
                                                             (15,11,12, 8, 9,13,10,14,15,11,12, 8, 9,13,10,14),
                                                             ( 1, 2, 7, 4, 6, 5, 0, 3, 9,10,15,12,14,13, 8,11),
                                                             ( 6, 0, 1, 7, 3, 5, 4, 2,14, 8, 9,15,11,13,12,10));
  
  signal nl_d_in_16_words               : slv(511 downto 0);
  signal nl_d_in_16_words_array         : word32_array16;
  signal nl_addr                        : slv(3 downto 0);
  signal nl_we_16_words                 : std_logic;
  signal nl_d_out_16_words              : slv(511 downto 0);
  signal nl_d_out_16_words_array        : word32_array16;
  signal ntt_loop_state_next            : ntt_loop_state;
  signal u                              : unsigned(3 downto 0);
  signal m                              : sword32_array16;
  signal t                              : sword32_array16;
  signal rb_plus_u                      : unsigned(3 downto 0);
  signal rb_plus_u_plus_hk              : unsigned(3 downto 0);
  signal v_plus_as                      : uword8_array16;
  signal done_int                       : std_logic;
  signal ccode_state_next               : ccode_state;
  signal ccode_en                       : std_logic;
  signal ccode_we                       : std_logic;
  signal ccode_data                     : word32_array16;
  signal ccode_done_int                 : std_logic;
  signal cc_d_in                        : slv(511 downto 0);
  signal cc_addr                        : slv(3 downto 0);
  signal wb_state_next                  : wb_state;
  signal wb_addr                        : slv(3 downto 0);
  signal wb_en                          : std_logic;
  signal w_int                          : word32_array8;
  signal wb_8_words                     : word32_array8;
  signal wb_done_int                    : std_logic;
  signal d_in_16_words                  : slv(511 downto 0);
  signal addr                           : slv(3 downto 0);
  signal we_16_words                    : std_logic;
  signal d_out_int                      : slv(8191 downto 0);
  
  signal q_ntt_loop_state               : ntt_loop_state;
  signal q_u                            : unsigned(3 downto 0);
  signal q_m                            : sword32_array16;
  signal q_t                            : sword32_array16;
  signal q_rb_plus_u                    : unsigned(3 downto 0);
  signal q_rb_plus_u_plus_hk            : unsigned(3 downto 0);
  signal q_v_plus_as                    : uword8_array16;
  signal q_done                         : std_logic;
  signal q_ccode_state                  : ccode_state;
  signal q_wb_state                     : wb_state;
  signal q_w                            : word32_array8;
  signal q_wb_8_words                   : word32_array8;
  signal q_count                        : unsigned(3 downto 0);
  
begin

  d_out                                 <= d_out_int;
  done                                  <= q_done;
  ccode_done                            <= ccode_done_int;
  wb_done                               <= wb_done_int;
  
  w_mapping : for i in 0 to 7 generate
    w((i+1)*32-1 downto i*32)           <= q_w(i);
  end generate w_mapping;
  
  nl_data_mapping : for i in 0 to 15 generate
    nl_d_in_16_words((i+1)*32-1 downto i*32) <= nl_d_in_16_words_array(i);
    nl_d_out_16_words_array(i)          <= nl_d_out_16_words((i+1)*32-1 downto i*32);
  end generate nl_data_mapping;
  
  cc_data_mapping : for i in 0 to 15 generate
    cc_d_in((i+1)*32-1 downto i*32)     <= ccode_data(i);
  end generate cc_data_mapping;
  
  d_in_16_words                         <= cc_d_in when ccode_en = '1' else nl_d_in_16_words;
  addr                                  <= wb_addr when wb_en = '1' else cc_addr when ccode_en = '1' else nl_addr;
  we_16_words                           <= ccode_we or nl_we_16_words;
  
  simd512_ram_inst : simd512_ram
  port map (
    clk                                 => clk,
    clr                                 => clr,
    d_in_all                            => d_in,
    d_in                                => d_in_16_words,
    addr                                => addr,
    we_all                              => d_in_we,
    we                                  => we_16_words,
    d_out_all                           => d_out_int,
    d_out                               => nl_d_out_16_words
  );
  
  ntt_loop_proc : process(q_ntt_loop_state, rb, hk, q_u, q_m, q_t, q_rb_plus_u,
                          q_rb_plus_u_plus_hk, q_v_plus_as, as, start, nl_d_out_16_words_array) is
    variable rb_plus_hk                 : slv(3 downto 0);
    variable n                          : sword32_array16;
    variable n_times_alpha              : word64_array16;
  begin
    ntt_loop_state_next                 <= q_ntt_loop_state;
    rb_plus_hk                          := slv(unsigned(rb)+unsigned(hk));
    u                                   <= q_u;
    m                                   <= q_m;
    t                                   <= q_t;
    rb_plus_u                           <= q_rb_plus_u;
    rb_plus_u_plus_hk                   <= q_rb_plus_u_plus_hk;
    v_plus_as                           <= q_v_plus_as;
    nl_addr                             <= slv(q_rb_plus_u);
    for i in 0 to 15 loop
      nl_d_in_16_words_array(i)         <= slv(q_m(i) + q_t(i));
    end loop;
    nl_we_16_words                      <= '0';
    done_int                            <= '0';
    case q_ntt_loop_state is
    when IDLE =>
      u                                 <= (others => '0');
      rb_plus_u                         <= unsigned(rb);
      rb_plus_u_plus_hk                 <= unsigned(rb_plus_hk);
      for i in 0 to 15 loop
        v_plus_as(i)                    <= i*unsigned(as);
      end loop;
      if start = '1' then
        nl_addr                         <= rb;
        ntt_loop_state_next             <= EXEC_1;
      end if;
    when EXEC_1 =>
      for i in 0 to 15 loop
        m(i)                            <= signed(nl_d_out_16_words_array(i));
      end loop;
      nl_addr                           <= slv(q_rb_plus_u_plus_hk);
      ntt_loop_state_next               <= EXEC_2;
    when EXEC_2 =>
      for i in 0 to 15 loop
        n(i)                            := signed(nl_d_out_16_words_array(i));
        n_times_alpha(i)                := slv(resize(n(i) * ALPHA(to_integer(q_v_plus_as(i))),64));
        if q_u = 0 and i = 0 then
          t(i)                          <= n(i);
        else
          t(i)                          <= signed(reds2(n_times_alpha(i)));
        end if;
      end loop;
      ntt_loop_state_next               <= EXEC_3;
    when EXEC_3 =>
      for i in 0 to 15 loop
        nl_d_in_16_words_array(i)       <= slv(q_m(i) + q_t(i));
      end loop;
      nl_addr                           <= slv(q_rb_plus_u);
      nl_we_16_words                    <= '1';
      ntt_loop_state_next               <= EXEC_4;
    when EXEC_4 =>
      for i in 0 to 15 loop
        nl_d_in_16_words_array(i)       <= slv(q_m(i) - q_t(i));
      end loop;
      nl_addr                           <= slv(q_rb_plus_u_plus_hk);
      nl_we_16_words                    <= '1';
      u                                 <= q_u + 1;
      rb_plus_u                         <= q_rb_plus_u + 1;
      rb_plus_u_plus_hk                 <= q_rb_plus_u_plus_hk + 1;
      for i in 0 to 15 loop
        v_plus_as(i)                    <= q_v_plus_as(i) + (unsigned(as) & X"0");
      end loop;
      if (q_u + 1) < unsigned(hk) then
        ntt_loop_state_next             <= INIT;
      else
        done_int                        <= '1';
        ntt_loop_state_next             <= IDLE;
      end if;
    when INIT =>
      nl_addr                           <= slv(q_rb_plus_u);
      ntt_loop_state_next               <= EXEC_1;
    when others =>
      null;
    end case;
  end process ntt_loop_proc;
  
  ccode_proc : process(q_ccode_state, ccode_start, nl_d_out_16_words_array, q_count, ccode_last)
    variable ccode_data_var             : word32_array16;
  begin
    ccode_state_next                    <= q_ccode_state;
    ccode_data_var                      := (others => zeros32);
    ccode_en                            <= '1';
    ccode_we                            <= '0';
    ccode_data                          <= (others => zeros32);
    cc_addr                             <= slv(q_count);
    ccode_done_int                      <= '0';
    case q_ccode_state is
    when IDLE =>
      ccode_en                          <= ccode_start;
      if ccode_start = '1' then
        ccode_state_next                <= READ_DELAY;
      end if;
    when READ_DELAY =>
      ccode_state_next                  <= EXEC;
    when EXEC =>
      ccode_we                          <= '1';
      for i in 0 to 15 loop
        if ccode_last = '0' then
          ccode_data_var(i)             := slv(unsigned(nl_d_out_16_words_array(i)) + YOFF_B_N(to_integer(q_count),i));
        else
          ccode_data_var(i)             := slv(unsigned(nl_d_out_16_words_array(i)) + YOFF_B_F(to_integer(q_count),i));
        end if;
        ccode_data_var(i)               := reds2(word64(resize(signed(ccode_data_var(i)),64)));
        ccode_data_var(i)               := reds1(ccode_data_var(i));
        ccode_data_var(i)               := reds1(ccode_data_var(i));
        if signed(ccode_data_var(i)) > 128 then
          ccode_data_var(i)             := word32(signed(ccode_data_var(i)) - 257);
        end if;
      end loop;
      ccode_data                        <= ccode_data_var;
      ccode_state_next                  <= WRITE_DELAY;
    when WRITE_DELAY =>
      if q_count = 0 then
        ccode_state_next                <= FINISH;
      else
        ccode_state_next                <= READ_DELAY;
      end if;
    when FINISH =>
      ccode_done_int                    <= '1';
      ccode_state_next                  <= IDLE;
    end case;
  end process ccode_proc;
  
  wb_proc : process(q_wb_state, wb_r, q_w, q_wb_8_words, wb_start, wb_rnd_i, nl_d_out_16_words_array) is
  begin
    wb_state_next                       <= q_wb_state;
    wb_addr                             <= slv(to_unsigned(WB_ADDRESSES(to_integer(unsigned(wb_r)),to_integer(unsigned(wb_rnd_i))),4));
    wb_en                               <= '1';
    w_int                               <= q_w;
    wb_8_words                          <= q_wb_8_words;
    wb_done_int                         <= '0';
    case q_wb_state is
    when IDLE =>
      wb_en                             <= wb_start;
      if wb_start = '1' then
        wb_state_next                   <= READ_DELAY;
      end if;
    when READ_DELAY =>
      if wb_r(1) = '0' then
        wb_state_next                   <= EXEC_TYPE_1;
      else
        wb_state_next                   <= EXEC_TYPE_2_1;
      end if;
    when EXEC_TYPE_1 =>
      for i in 0 to 7 loop
        w_int(i)                        <= inner(nl_d_out_16_words_array(2*i),nl_d_out_16_words_array(2*i+1),wb_r);
      end loop;
      wb_state_next                     <= FINISH;
    when EXEC_TYPE_2_1 =>
      wb_addr                           <= slv(to_unsigned(WB_ADDRESSES(to_integer(unsigned(wb_r)),to_integer(unsigned('1' & wb_rnd_i))),4));
      for i in 0 to 7 loop
        if wb_r = "10" then 
          wb_8_words(i)                 <= nl_d_out_16_words_array(2*i);
        else
          wb_8_words(i)                 <= nl_d_out_16_words_array(2*i+1);
        end if;
      end loop;
      wb_state_next                     <= EXEC_TYPE_2_2;
    when EXEC_TYPE_2_2 =>
      wb_addr                           <= slv(to_unsigned(WB_ADDRESSES(to_integer(unsigned(wb_r)),to_integer(unsigned('1' & wb_rnd_i))),4));
      for i in 0 to 7 loop
        if wb_r = "10" then
          w_int(i)                      <= inner(q_wb_8_words(i),nl_d_out_16_words_array(2*i),wb_r);
        else
          w_int(i)                      <= inner(q_wb_8_words(i),nl_d_out_16_words_array(2*i+1),wb_r);
        end if;
      end loop;
      wb_state_next                     <= FINISH;
    when FINISH =>
      wb_addr                           <= slv(to_unsigned(WB_ADDRESSES(to_integer(unsigned(wb_r)),to_integer(unsigned('1' & wb_rnd_i))),4));
      wb_done_int                       <= '1';
      wb_state_next                     <= IDLE;
    when others =>
      null;
    end case;
  end process wb_proc;
  
  registers : process(reset, clk) is
  begin
    if reset = '1' then
      q_ntt_loop_state                  <= IDLE;
      q_ccode_state                     <= IDLE;
      q_wb_state                        <= IDLE;
    elsif rising_edge(clk) then
      q_ntt_loop_state                  <= ntt_loop_state_next;
      q_ccode_state                     <= ccode_state_next;
      q_wb_state                        <= wb_state_next;
      q_u                               <= u;
      q_m                               <= m;
      q_t                               <= t;
      q_rb_plus_u                       <= rb_plus_u;
      q_rb_plus_u_plus_hk               <= rb_plus_u_plus_hk;
      q_v_plus_as                       <= v_plus_as;
      q_done                            <= done_int;
      q_w                               <= w_int;
      q_wb_8_words                      <= wb_8_words;
      if ccode_start = '1' then
        q_count                         <= (others => '0');
      elsif ccode_we = '1' then
        q_count                         <= q_count + 1;
      end if;
    end if;
  end process registers;
  
end architecture simd512_ntt_loop_rtl;