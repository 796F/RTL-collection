--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dummy_hash_fn is
generic (
  DELAY                       : natural := 0
);
port (
  clk                         : in std_logic;
  clk_en                      : in std_logic;
  reset                       : in std_logic;
  start                       : in std_logic;
  pause                       : in std_logic;
  data_in                     : in std_logic_vector(511 downto 0);
  hash                        : out std_logic_vector(511 downto 0);
  hash_new                    : out std_logic;
  hash_almost_new             : out std_logic;
  busy_n                      : out std_logic
);
end entity dummy_hash_fn;

architecture dummy_hash_fn_rtl of dummy_hash_fn is
  
  alias slv is std_logic_vector;

  type dummy_hf_state is (IDLE, COUNT, FINISH);
  
  signal dummy_hf_state_next  : dummy_hf_state;
  signal count_start          : std_logic;
  signal count_en             : std_logic;
  signal done                 : std_logic;

  signal q_dummy_hf_state     : dummy_hf_state;
  signal q_hash               : slv(511 downto 0);
  signal q_count              : unsigned(12 downto 0);

begin

  hash                        <= q_hash;
  hash_new                    <= done;
  hash_almost_new             <= q_count(12) and q_count(0);

  dummy_hf_proc: process(q_dummy_hf_state, start, q_count, pause)
  begin
    dummy_hf_state_next       <= q_dummy_hf_state;
    busy_n                    <= '0';
    count_start               <= '1';
    count_en                  <= '0';
    done                      <= '0';
    case q_dummy_hf_state is
    when IDLE =>
      busy_n                  <= '1';
      if start = '1' then
        busy_n                <= '0';
        dummy_hf_state_next   <= COUNT;
      end if;
    when COUNT =>
      count_start             <= '0';
      count_en                <= '1';
      if q_count(12) = '1' then
        dummy_hf_state_next   <= FINISH;
      end if;
    when FINISH =>
      done                    <= '1';
      if pause = '0' then
        dummy_hf_state_next   <= IDLE;
      end if;
    end case;
  end process dummy_hf_proc;
  
  registers : process (clk)
  begin
  if reset = '1' then
    q_dummy_hf_state          <= IDLE;
  elsif rising_edge(clk) then
    if clk_en = '1' then
      q_dummy_hf_state        <= dummy_hf_state_next;
      if q_count(12) = '1' and q_count(0) = '1' then
        q_hash                <= data_in;
      end if;
      if count_start = '1' then
        q_count               <= to_unsigned(DELAY,q_count'length);
      elsif count_en = '1' then
        q_count               <= q_count - 1;
      end if;
    end if;
  end if;
  end process registers;
  
end architecture dummy_hash_fn_rtl;
  