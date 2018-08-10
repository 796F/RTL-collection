--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blake512_tb is
end entity blake512_tb;

architecture blake512_tb_behav of blake512_tb is
  
  alias slv is std_logic_vector;
  
  component blake512_4g is
  port (
    clk                           : in std_logic;
    reset                         : in std_logic;
    start                         : in std_logic;
    data_in                       : in std_logic_vector(639 downto 0);
    hash                          : out std_logic_vector(511 downto 0);
    hash_new                      : out std_logic
  );
  end component blake512_4g;
  
  component blake512_8g is
  port (
    clk                           : in std_logic;
    reset                         : in std_logic;
    start                         : in std_logic;
    data_in                       : in std_logic_vector(639 downto 0);
    hash                          : out std_logic_vector(511 downto 0);
    hash_new                      : out std_logic
  );
  end component blake512_8g;
  
  constant TCLK_125               : time := 8 ns;
  
  signal clk                      : std_logic := '0';
  signal reset                    : std_logic;
  signal start                    : std_logic := '0';
  signal data_in                  : slv(639 downto 0) := (others => '0');
  signal hash_4g                  : slv(511 downto 0);
  signal hash_4g_new              : std_logic;
  signal hash_8g                  : slv(511 downto 0);
  signal hash_8g_new              : std_logic;
  
begin

  reset                           <= '1', '0' after 12.5 * TCLK_125;

  blake512_4g_inst : blake512_4g
  port map (
    clk                           => clk,
    reset                         => reset,
    start                         => start,
    data_in                       => data_in,
    hash                          => hash_4g,
    hash_new                      => hash_4g_new
  );

  blake512_8g_inst : blake512_8g
  port map (
    clk                           => clk,
    reset                         => reset,
    start                         => start,
    data_in                       => data_in,
    hash                          => hash_8g,
    hash_new                      => hash_8g_new
  );

  msg_gen: process is
  begin
    wait until reset = '0';
    data_in                       <= X"efbeadde" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" &
                                     X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef" & X"deadbeef"; 
    start                         <= '1';
    wait for TCLK_125;
    start                         <= '0';  
  end process msg_gen;
  
  clk_gen: process is
  begin
      clk                         <= not clk;
      wait for TCLK_125/2;
  end process clk_gen;
  
end architecture blake512_tb_behav;