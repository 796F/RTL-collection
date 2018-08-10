--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keccak512_reorder_sr is
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
end entity keccak512_reorder_sr;

architecture keccak512_reorder_sr_rtl of keccak512_reorder_sr is
  
  alias slv is std_logic_vector;
    
  component keccak512_ram_sr is
  port (
    clk                                 : in std_logic;
    data                                : in std_logic_vector(63 downto 0);
    all_data                            : in std_logic_vector(1599 downto 0);
    addr                                : in std_logic_vector(4 downto 0);
    we                                  : in std_logic;
    ad_we                               : in std_logic;
    q                                   : out std_logic_vector(63 downto 0);
    all_q                               : out std_logic_vector(1599 downto 0)
  );
  end component keccak512_ram_sr;
  
  subtype word64 is slv(63 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  type nat_array_25 is array(0 to 24) of natural;
  type array_9_nat_array_25 is array(0 to 8) of nat_array_25;
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
  
  constant IND                          : array_9_nat_array_25 := ((0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24),
                                                                   (0,15,5,20,10,6,21,11,1,16,12,2,17,7,22,18,8,23,13,3,24,14,4,19,9),
                                                                   (0,18,6,24,12,21,14,2,15,8,17,5,23,11,4,13,1,19,7,20,9,22,10,3,16),
                                                                   (0,13,21,9,17,14,22,5,18,1,23,6,19,2,10,7,15,3,11,24,16,4,12,20,8),
                                                                   (0,7,14,16,23,22,4,6,13,15,19,21,3,5,12,11,18,20,2,9,8,10,17,24,1),
                                                                   (0,11,22,8,19,4,10,21,7,18,3,14,20,6,17,2,13,24,5,16,1,12,23,9,15),
                                                                   (0,2,4,1,3,10,12,14,11,13,20,22,24,21,23,5,7,9,6,8,15,17,19,16,18),
                                                                   (0,5,10,15,20,12,17,22,2,7,24,4,9,14,19,6,11,16,21,1,18,23,3,8,13),
                                                                   (0,6,12,18,24,17,23,4,5,11,9,10,16,22,3,21,2,8,14,15,13,19,20,1,7));

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
  signal ram_ad_we                      : std_logic;
  signal ram_q                          : word64;
  signal ram_all_q                      : slv(1599 downto 0);
  signal ram_all_q_array                : word64_array25;
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
  
  array_mapping : for l in 0 to 24 generate
    ram_all_q_array(l)                  <= ram_all_q((l+1)*64-1 downto l*64);
  end generate array_mapping;
  
  keccak512_ram_sr_inst : keccak512_ram_sr
  port map (
    clk                                 => clk,
    data                                => ram_data,
    all_data                            => x_in_1,
    addr                                => ram_addr,
    we                                  => ram_we,
    ad_we                               => ram_ad_we,
    q                                   => ram_q,
    all_q                               => ram_all_q
  );
  
  reorder_proc : process(q_reorder_state, q_reorder_num, q_count, q_count_2, q_x, start_1, start_2, start_3, x_1, x_2, x_3, i, j, ram_q, ram_all_q_array)
  begin
    reorder_state_next                  <= q_reorder_state;
    reorder_num                         <= q_reorder_num;
    count_start                         <= '1';
    count_en                            <= '0';
    ram_data                            <= (others => '0');
    ram_addr                            <= slv(q_count);
    ram_we                              <= '0';
    ram_ad_we                           <= '0';
    x                                   <= q_x;
    done                                <= (others => '0');
    case q_reorder_state is
    when IDLE =>
      if start_1 = '1' then
        reorder_num                     <= to_unsigned(0,reorder_num'length);
        ram_ad_we                       <= '1';
        reorder_state_next              <= READ_OUT;
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
        if q_reorder_num = "10" then
          reorder_state_next            <= FINISH;
        else
          reorder_state_next            <= READ_OUT;
        end if;
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
      case q_reorder_num is
      when "00" =>
        x(to_integer(unsigned(q_count_2))) <= ram_q;
        done                            <= "001";
      when "01" =>
        x(to_integer(unsigned(q_count_2))) <= ram_q;
        done                            <= "010";
      when "10" =>
        x                               <= ram_all_q_array;
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
  
end architecture keccak512_reorder_sr_rtl;