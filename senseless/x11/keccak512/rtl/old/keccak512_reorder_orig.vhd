--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak512_reorder is
port (
  clk                                   : in std_logic;
  reset                                 : in std_logic;
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
end entity keccak512_reorder;

architecture keccak512_reorder_rtl of keccak512_reorder is
  
  alias slv is std_logic_vector;
  
  component ram is
  generic (
    DATA_W              : natural := 64;
    ADDR_W              : natural := 5
  );
  port (
    clk                 : in std_logic;
    data                : in std_logic_vector(DATA_W-1 downto 0);
    addr                : in std_logic_vector(ADDR_W-1 downto 0);
    we                  : in std_logic;
    q                   : out std_logic_vector(DATA_W-1 downto 0)
  );
  end component ram;
  
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  type nat_array_25 is array(0 to 24) of natural;
  type array_24_nat_array_25 is array(0 to 23) of nat_array_25;
  type reorder_state is (IDLE, WRITE_IN, READ_OUT, FINISH);
  
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
  
  constant IND : array_24_nat_array_25  := ((0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24),
                                            (0,15,5,20,10,6,21,11,1,16,12,2,17,7,22,18,8,23,13,3,24,14,4,19,9),
                                            (0,18,6,24,12,21,14,2,15,8,17,5,23,11,4,13,1,19,7,20,9,22,10,3,16),
                                            (0,13,21,9,17,14,22,5,18,1,23,6,19,2,10,7,15,3,11,24,16,4,12,20,8),
                                            (0,7,14,16,23,22,4,6,13,15,19,21,3,5,12,11,18,20,2,9,8,10,17,24,1),
                                            (0,11,22,8,19,4,10,21,7,18,3,14,20,6,17,2,13,24,5,16,1,12,23,9,15),
                                            (0,2,4,1,3,10,12,14,11,13,20,22,24,21,23,5,7,9,6,8,15,17,19,16,18),
                                            (0,5,10,15,20,12,17,22,2,7,24,4,9,14,19,6,11,16,21,1,18,23,3,8,13),
                                            (0,6,12,18,24,17,23,4,5,11,9,10,16,22,3,21,2,8,14,15,13,19,20,1,7),
                                            (0,21,17,13,9,23,19,10,6,2,16,12,8,4,20,14,5,1,22,18,7,3,24,15,11),
                                            (0,14,23,7,16,19,3,12,21,5,8,17,1,10,24,22,6,15,4,13,11,20,9,18,2),
                                            (0,22,19,11,8,3,20,17,14,6,1,23,15,12,9,4,21,18,10,7,2,24,16,13,5),
                                            (0,4,3,2,1,20,24,23,22,21,15,19,18,17,16,10,14,13,12,11,5,9,8,7,6),
                                            (0,10,20,5,15,24,9,19,4,14,18,3,13,23,8,12,22,7,17,2,6,16,1,11,21),
                                            (0,12,24,6,18,9,16,3,10,22,13,20,7,19,1,17,4,11,23,5,21,8,15,2,14),
                                            (0,17,9,21,13,16,8,20,12,4,7,24,11,3,15,23,10,2,19,6,14,1,18,5,22),
                                            (0,23,16,14,7,8,1,24,17,10,11,9,2,20,18,19,12,5,3,21,22,15,13,6,4),
                                            (0,19,8,22,11,1,15,9,23,12,2,16,5,24,13,3,17,6,20,14,4,18,7,21,10),
                                            (0,3,1,4,2,15,18,16,19,17,5,8,6,9,7,20,23,21,24,22,10,13,11,14,12),
                                            (0,20,15,10,5,18,13,8,3,23,6,1,21,16,11,24,19,14,9,4,12,7,2,22,17),
                                            (0,24,18,12,6,13,7,1,20,19,21,15,14,8,2,9,3,22,16,10,17,11,5,4,23),
                                            (0,9,13,17,21,7,11,15,24,3,14,18,22,1,5,16,20,4,8,12,23,2,6,10,19),
                                            (0,16,7,23,14,11,2,18,9,20,22,13,4,15,6,8,24,10,1,17,19,5,21,12,3),
                                            (0,8,11,19,22,2,5,13,16,24,4,7,10,18,21,1,9,12,15,23,3,6,14,17,20));

  signal reorder_state_next             : reorder_state;
  signal reorder_num                    : unsigned(1 downto 0);
  signal count_start                    : std_logic;
  signal count_en                       : std_logic;
  signal x_1                            : word64_array25;
  signal x_2                            : word64_array25;
  signal x_3                            : word64_array25;
  signal x                              : word64_array25;
  signal ram_data                       : word64;
  signal ram_addr                       : slv(4 downto 0);
  signal ram_we                         : std_logic;
  signal ram_q                          : word64;
  signal done                           : slv(2 downto 0);
  
  signal q_reorder_state                : reorder_state;
  signal q_reorder_num                  : unsigned(1 downto 0);
  signal q_count                        : unsigned(4 downto 0);
  signal q_count_2                      : unsigned(4 downto 0);
  signal q_x                            : word64_array25;
  signal q_done                         : slv(2 downto 0);
  
begin
  
  (x_new_3, x_new_2, x_new_1)           <= q_done;
  
  output_mapping : for l in 0 to 24 generate
    x_out((l+1)*64-1 downto l*64)       <= q_x(l);
  end generate output_mapping;

  input_mapping : for l in 0 to 24 generate
    x_1(l)                              <= x_in_1((l+1)*64-1 downto l*64);
    x_2(l)                              <= x_in_2((l+1)*64-1 downto l*64);
    x_3(l)                              <= x_in_3((l+1)*64-1 downto l*64);
  end generate input_mapping;
  
  ram_inst : ram
  generic map (
    DATA_W                              => 64,
    ADDR_W                              => 5
  )
  port map (
    clk                                 => clk,
    data                                => ram_data,
    addr                                => ram_addr,
    we                                  => ram_we,
    q                                   => ram_q
  );
  
  reorder_proc : process(q_reorder_state, q_reorder_num, q_count, q_count_2, q_x, start_1, start_2, start_3, x_1, x_2, x_3, i, j, ram_q)
  begin
    reorder_state_next                  <= q_reorder_state;
    reorder_num                         <= q_reorder_num;
    count_start                         <= '1';
    count_en                            <= '0';
    ram_data                            <= (others => '0');
    ram_addr                            <= slv(q_count);
    ram_we                              <= '0';
    x                                   <= q_x;
    done                                <= (others => '0');
    case q_reorder_state is
    when IDLE =>
      if start_1 = '1' then
        reorder_num                     <= to_unsigned(0,reorder_num'length);
        ram_data                        <= x_1(to_integer(unsigned(q_count)));
        ram_we                          <= '1';
        reorder_state_next              <= WRITE_IN;
      elsif start_2 = '1' then
        reorder_num                     <= to_unsigned(1,reorder_num'length);
        ram_data                        <= x_2(to_integer(unsigned(q_count)));
        ram_addr                        <= slv(to_unsigned(IND(to_integer(unsigned(i)))(to_integer(unsigned(q_count))),ram_addr'length));
        ram_we                          <= '1';
        reorder_state_next              <= WRITE_IN;
      elsif start_3 = '1' then
        reorder_num                     <= to_unsigned(2,reorder_num'length);
        ram_data                        <= x_3(to_integer(unsigned(q_count)));
        ram_addr                        <= slv(to_unsigned(IND(to_integer(unsigned(j)))(to_integer(unsigned(q_count))),ram_addr'length));
        ram_we                          <= '1';
        reorder_state_next              <= WRITE_IN;
      end if;
    when WRITE_IN =>
      count_start                       <= '0';
      count_en                          <= '1';
      case q_reorder_num is
      when "00" =>
        ram_data                        <= x_1(to_integer(unsigned(q_count)));
      when "01" =>
        ram_data                        <= x_2(to_integer(unsigned(q_count)));
        ram_addr                        <= slv(to_unsigned(IND(to_integer(unsigned(i)))(to_integer(unsigned(q_count))),ram_addr'length));
      when "10" =>
        ram_data                        <= x_3(to_integer(unsigned(q_count)));
        ram_addr                        <= slv(to_unsigned(IND(to_integer(unsigned(j)))(to_integer(unsigned(q_count))),ram_addr'length));
      when others =>
        null;
      end case;
      ram_we                            <= '1';
      if q_count = 24 then
        count_start                     <= '1';
        count_en                        <= '0';
        reorder_state_next              <= READ_OUT;
      end if;
    when READ_OUT =>
      count_start                       <= '0';
      count_en                          <= '1';
      case q_reorder_num is
      when "00" =>
        ram_addr                        <= slv(to_unsigned(IND(to_integer(unsigned(i)))(to_integer(unsigned(q_count))),ram_addr'length));
      when "01" =>
        ram_addr                        <= slv(to_unsigned(IND(to_integer(unsigned(j)))(to_integer(unsigned(q_count))),ram_addr'length));  
      when others =>
        null;
      end case;
      if q_count /= 0 then
        x(to_integer(unsigned(q_count_2))) <= ram_q;
      end if;
      if q_count = 24 then
        count_start                     <= '1';
        count_en                        <= '0';
        reorder_state_next              <= FINISH;
      end if;
    when FINISH =>
      x(to_integer(unsigned(q_count_2))) <= ram_q;
      case q_reorder_num is
      when "00" =>
        done                            <= "001";
      when "01" =>
        done                            <= "010";
      when "10" =>
        done                            <= "100";
      when others =>
        null;
      end case;
      reorder_state_next                <= IDLE;
    end case;
  end process reorder_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_reorder_state                   <= IDLE;
    elsif rising_edge(clk) then
      q_reorder_state                   <= reorder_state_next;
      q_reorder_num                     <= reorder_num;
      q_x                               <= x;
      q_done                            <= done;
      if count_start = '1' then
        q_count                         <= (others => '0');
      elsif count_en = '1' then
        q_count                         <= q_count + 1;  
      end if;
      q_count_2                         <= q_count;
    end if;
  end process registers;
  
end architecture keccak512_reorder_rtl;