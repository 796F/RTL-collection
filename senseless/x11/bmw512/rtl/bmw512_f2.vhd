--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bmw512_f2 is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  m                                     : in std_logic_vector(1023 downto 0);
  qpa                                   : in std_logic_vector(1023 downto 0);
  qpb                                   : in std_logic_vector(1023 downto 0);
  h                                     : out std_logic_vector(1023 downto 0);
  h_new                                 : out std_logic
);
end entity bmw512_f2;

architecture bmw512_f2_rtl of bmw512_f2 is
  
  alias slv is std_logic_vector;
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
                        
  constant zeros64 : word64 := (others => '0');
  
  function shr(x: word64; n: natural) return word64 is
  begin
    return word64(zeros64(n-1 downto 0) & x(x'high downto n));
  end shr;
  
  function shl(x: word64; n: natural) return word64 is
  begin
    return word64(x(x'high-n downto 0) & zeros64(x'high downto x'length-n));
  end shl;
  
  function rotr(x: uword64; n: natural) return uword64 is
  begin
    return uword64(x(n-1 downto 0) & x(x'high downto n));
  end rotr;
  
  function rotl(x: uword64; n: natural) return uword64 is
  begin
    return uword64(x(x'high-n downto 0) & x(x'high downto x'length-n));
  end rotl;
  
  type word64_array16 is array(0 to 15) of word64;
  type uword64_array16 is array(0 to 15) of uword64;
  type bmw512_f2_state is (IDLE, EXEC_F2_0, EXEC_F2_1, EXEC_F2_2, FINISH);
  
  signal bmw512_f2_state_next           : bmw512_f2_state;
  signal loop_count_start               : std_logic;
  signal loop_count_en                  : std_logic;
  signal m_int                          : word64_array16;
  signal qpa_int                        : word64_array16;
  signal qpb_int                        : word64_array16;
  signal xl                             : word64;
  signal xh                             : word64;
  signal h_int                          : uword64_array16;
  signal done                           : std_logic;
  
  signal q_bmw512_f2_state              : bmw512_f2_state;
  signal q_loop_count                   : unsigned(4 downto 0);
  signal q_xl                           : word64;
  signal q_xh                           : word64;
  signal q_h                            : uword64_array16;
  
begin

  h_new                                 <= done;
  
  output_mapping : for i in 0 to 15 generate
    h((i+1)*64-1 downto i*64)           <= slv(q_h(i));
  end generate output_mapping;
  
  input_mapping : for i in 0 to 15 generate
    m_int(i)                            <= m((i+1)*64-1 downto i*64);
    qpa_int(i)                          <= qpa((i+1)*64-1 downto i*64);
    qpb_int(i)                          <= qpb((i+1)*64-1 downto i*64);
  end generate input_mapping;
  
  bmw512_f2_proc : process(q_bmw512_f2_state, q_xl, q_xh, start, m_int, qpa_int, qpb_int, q_loop_count, q_h)
    variable h_0                        : uword64;
  begin
    bmw512_f2_state_next                <= q_bmw512_f2_state;
    loop_count_start                    <= '1';
    loop_count_en                       <= '0';
    xl                                  <= q_xl;
    xh                                  <= q_xh;
    h_int                               <= q_h;
    done                                <= '0';
    case q_bmw512_f2_state is
    when IDLE =>
      if start = '1' then
        bmw512_f2_state_next            <= EXEC_F2_0;
      end if;
    when EXEC_F2_0 =>
      xl                                <= qpb_int(0) xor qpb_int(1) xor qpb_int(2) xor qpb_int(3) xor qpb_int(4) xor qpb_int(5) xor qpb_int(6) xor qpb_int(7);
      bmw512_f2_state_next              <= EXEC_F2_1;
    when EXEC_F2_1 =>
      xh                                <= q_xl xor qpb_int(8) xor qpb_int(9) xor qpb_int(10) xor qpb_int(11) xor qpb_int(12) xor qpb_int(13) xor qpb_int(14) xor qpb_int(15);
      bmw512_f2_state_next              <= EXEC_F2_2;
    when EXEC_F2_2 =>
      loop_count_start                  <= '0';
      loop_count_en                     <= '1';
      case q_loop_count is
      when "00000" =>
        h_int(0)                        <= unsigned(shl(q_xh,5)  xor shr(qpb_int(0),5) xor m_int(0)) + unsigned(q_xl xor qpb_int(8) xor qpa_int(0));
      when "00001" =>
        h_int(1)                        <= unsigned(shr(q_xh,7)  xor shl(qpb_int(1),8) xor m_int(1)) + unsigned(q_xl xor qpb_int(9) xor qpa_int(1));
      when "00010" =>
        h_int(2)                        <= unsigned(shr(q_xh,5)  xor shl(qpb_int(2),5) xor m_int(2)) + unsigned(q_xl xor qpb_int(10) xor qpa_int(2));
      when "00011" =>
        h_int(3)                        <= unsigned(shr(q_xh,1)  xor shl(qpb_int(3),5) xor m_int(3)) + unsigned(q_xl xor qpb_int(11) xor qpa_int(3));
      when "00100" =>
        h_int(4)                        <= unsigned(shr(q_xh,3)  xor     qpb_int(4)    xor m_int(4)) + unsigned(q_xl xor qpb_int(12) xor qpa_int(4));
      when "00101" =>
        h_int(5)                        <= unsigned(shl(q_xh,6)  xor shr(qpb_int(5),6) xor m_int(5)) + unsigned(q_xl xor qpb_int(13) xor qpa_int(5));
      when "00110" =>
        h_int(6)                        <= unsigned(shr(q_xh,4)  xor shl(qpb_int(6),6) xor m_int(6)) + unsigned(q_xl xor qpb_int(14) xor qpa_int(6));
      when "00111" =>
        h_int(7)                        <= unsigned(shr(q_xh,11) xor shl(qpb_int(7),2) xor m_int(7)) + unsigned(q_xl xor qpb_int(15) xor qpa_int(7));
      when "01000" =>
        -- h_int(8)                     <= unsigned(rotl(q_h(4),9))  + unsigned(q_xh xor qpb_int(8)  xor m_int(8))  + unsigned(shl(q_xl,8) xor qpb_int(7) xor qpa_int(8));
        h_0                             := unsigned(rotl(q_h(4),9))  + unsigned(q_xh xor qpb_int(8)  xor m_int(8));
        h_int(8)                        <= h_0 + unsigned(shl(q_xl,8) xor qpb_int(7) xor qpa_int(8));   
      when "01001" =>
        -- h_int(9)                     <= unsigned(rotl(q_h(5),10)) + unsigned(q_xh xor qpb_int(9)  xor m_int(9))  + unsigned(shr(q_xl,6) xor qpb_int(0) xor qpa_int(9));
        h_0                             := unsigned(rotl(q_h(5),10)) + unsigned(q_xh xor qpb_int(9)  xor m_int(9));
        h_int(9)                        <= h_0 + unsigned(shr(q_xl,6) xor qpb_int(0) xor qpa_int(9));
      when "01010" =>
        -- h_int(10)                    <= unsigned(rotl(q_h(6),11)) + unsigned(q_xh xor qpb_int(10) xor m_int(10)) + unsigned(shl(q_xl,6) xor qpb_int(1) xor qpa_int(10));
        h_0                             := unsigned(rotl(q_h(6),11)) + unsigned(q_xh xor qpb_int(10) xor m_int(10));
        h_int(10)                       <= h_0 + unsigned(shl(q_xl,6) xor qpb_int(1) xor qpa_int(10));
      when "01011" =>
        -- h_int(11)                    <= unsigned(rotl(q_h(7),12)) + unsigned(q_xh xor qpb_int(11) xor m_int(11)) + unsigned(shl(q_xl,4) xor qpb_int(2) xor qpa_int(11));
        h_0                             := unsigned(rotl(q_h(7),12)) + unsigned(q_xh xor qpb_int(11) xor m_int(11));
        h_int(11)                       <= h_0 + unsigned(shl(q_xl,4) xor qpb_int(2) xor qpa_int(11));
      when "01100" =>
        -- h_int(12)                    <= unsigned(rotl(q_h(0),13)) + unsigned(q_xh xor qpb_int(12) xor m_int(12)) + unsigned(shr(q_xl,3) xor qpb_int(3) xor qpa_int(12));
        h_0                             := unsigned(rotl(q_h(0),13)) + unsigned(q_xh xor qpb_int(12) xor m_int(12));
        h_int(12)                       <= h_0 + unsigned(shr(q_xl,3) xor qpb_int(3) xor qpa_int(12));
      when "01101" =>
        -- h_int(13)                    <= unsigned(rotl(q_h(1),14)) + unsigned(q_xh xor qpb_int(13) xor m_int(13)) + unsigned(shr(q_xl,4) xor qpb_int(4) xor qpa_int(13));
        h_0                             := unsigned(rotl(q_h(1),14)) + unsigned(q_xh xor qpb_int(13) xor m_int(13));
        h_int(13)                       <= h_0 + unsigned(shr(q_xl,4) xor qpb_int(4) xor qpa_int(13));
      when "01110" =>
        -- h_int(14)                    <= unsigned(rotl(q_h(2),15)) + unsigned(xh xor qpb(14) xor m(14)) + unsigned(shr(xl,7) xor qpb(5) xor qpa(14));
        h_0                             := unsigned(rotl(q_h(2),15)) + unsigned(q_xh xor qpb_int(14) xor m_int(14));
        h_int(14)                       <= h_0 + unsigned(shr(q_xl,7) xor qpb_int(5) xor qpa_int(14));
      when "01111" =>
        -- h_int(15)                    <= unsigned(rotl(q_h(3),16)) + unsigned(xh xor qpb(15) xor m(15)) + unsigned(shr(xl,2) xor qpb(6) xor qpa(15));
        h_0                             := unsigned(rotl(q_h(3),16)) + unsigned(q_xh xor qpb_int(15) xor m_int(15));
        h_int(15)                       <= h_0 + unsigned(shr(q_xl,2) xor qpb_int(6) xor qpa_int(15));
        bmw512_f2_state_next            <= FINISH;
      when others =>
        null;
      end case;
    when FINISH =>
      done                              <= '1';
      bmw512_f2_state_next              <= IDLE;
    end case;
  end process bmw512_f2_proc;

  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_bmw512_f2_state                 <= IDLE;
    elsif rising_edge(clk) then
      q_bmw512_f2_state                 <= bmw512_f2_state_next;
      q_xl                              <= xl;
      q_xh                              <= xh;
      q_h                               <= h_int;
      if loop_count_start = '1' then
        q_loop_count                    <= (others => '0');
      elsif loop_count_en = '1' then
        q_loop_count                    <= q_loop_count + 1;
      end if;
    end if;
  end process registers;
  
end architecture bmw512_f2_rtl;