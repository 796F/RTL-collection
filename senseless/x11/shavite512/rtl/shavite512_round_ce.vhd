--  
-- Copyright (c) 2018 Allmine Inc
-- OrphanedGland (wilhelm.klink@gmail.com)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shavite512_round_ce is
port (
  clk                                   : in std_logic;
  clk_en                                : in std_logic;
  reset                                 : in std_logic;
  start                                 : in std_logic;
  ke                                    : in std_logic;
  ke_xor_type                           : in std_logic;
  o                                     : in std_logic_vector(2 downto 0);
  x_in                                  : in std_logic_vector(127 downto 0);
  rk_in                                 : in std_logic_vector(1023 downto 0);
  x_out                                 : out std_logic_vector(127 downto 0);
  rk_out                                : out std_logic_vector(1023 downto 0);
  rnd_almost_ready                      : out std_logic;
  rnd_new                               : out std_logic
);
end entity shavite512_round_ce;

architecture shavite512_round_ce_rtl of shavite512_round_ce is
  
  alias slv is std_logic_vector;
  
  component shavite512_aes_round_le is
  port (
    rotate_x_out                        : in std_logic;
    x_in                                : in std_logic_vector(127 downto 0);
    x_out                               : out std_logic_vector(127 downto 0)
  );
  end component shavite512_aes_round_le;
  
  subtype word64 is slv(63 downto 0);
  subtype word32 is slv(31 downto 0);
  subtype uword64 is unsigned(63 downto 0);
  subtype uword32 is unsigned(31 downto 0);
  subtype natural_0_3 is natural range 0 to 3;
  type rnd_state is (IDLE, X_ROUND, KEY_EXPAND_0, KEY_EXPAND_1, FINISH);

  constant zeros64 : word64 := (others => '0');
  constant zeros32 : word32 := (others => '0');
  
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
  type word32_array16 is array(0 to 15) of word32;
  type word32_array8 is array(0 to 7) of word32;
  type word32_array4 is array(0 to 3) of word32;
  
  constant COUNT                        : word32_array4 := (X"00000200",X"00000000",X"00000000",X"00000000");  
  
  signal rnd_state_next                 : rnd_state;
  signal x_in_array                     : word32_array4;
  signal rk_in_array                    : word32_array32;
  signal rk_out_array                   : word32_array32;
  signal arl_x_in                       : slv(127 downto 0);
  signal arl_x_out                      : slv(127 downto 0);
  signal arl_x_in_array                 : word32_array4;
  signal arl_x_out_array                : word32_array4;
  signal x                              : word32_array4;
  signal o2                             : unsigned(2 downto 0);
  signal almost_done                    : std_logic;
  signal done                           : std_logic;
  
  signal q_rnd_state                    : rnd_state;
  signal q_x                            : word32_array4;
  signal q_o2                           : unsigned(2 downto 0);
  
begin

  rnd_almost_ready                      <= almost_done;
  rnd_new                               <= done;
  
  output_mapping_1 : for i in 0 to 3 generate
    x_out((i+1)*32-1 downto i*32)       <= q_x(i);
  end generate output_mapping_1;
  
  output_mapping_2 : for i in 0 to 31 generate
    rk_out((i+1)*32-1 downto i*32)      <= rk_out_array(i);
  end generate output_mapping_2;
  
  input_mapping_1 : for i in 0 to 3 generate
    x_in_array(i)                       <= x_in((i+1)*32-1 downto i*32);
  end generate input_mapping_1;
  
  input_mapping_2 : for i in 0 to 31 generate
    rk_in_array(i)                      <= rk_in((i+1)*32-1 downto i*32);
  end generate input_mapping_2;
  
  array_mapping : for i in 0 to 3 generate
    arl_x_in((i+1)*32-1 downto i*32)    <= arl_x_in_array(i);
    arl_x_out_array(i)                  <= arl_x_out((i+1)*32-1 downto i*32);
  end generate array_mapping;

  shavite512_aes_round_le_inst : shavite512_aes_round_le
  port map (
    rotate_x_out                        => ke,
    x_in                                => arl_x_in,
    x_out                               => arl_x_out
  );
  
  rnd_proc : process(q_rnd_state, q_x, q_o2, start, ke, ke_xor_type, o, rk_in_array, x_in_array, arl_x_out_array)
  begin
    rnd_state_next                      <= q_rnd_state;
    x                                   <= q_x;
    o2                                  <= q_o2;
    arl_x_in_array                      <= q_x;
    almost_done                         <= '0';
    done                                <= '0';
    rk_out_array                        <= rk_in_array;
    for i in 0 to 3 loop
      rk_out_array(to_integer(unsigned(o) & to_unsigned(i,2))) <= q_x(i);
    end loop;
    case q_rnd_state is
    when IDLE =>
      if start = '1' then
        if ke = '0' then
          for i in 0 to 3 loop
            x(i)                        <= x_in_array(i) xor rk_in_array(to_integer(unsigned(o) & to_unsigned(i,2)));
          end loop;
          rnd_state_next                <= X_ROUND;
        else
          for i in 0 to 3 loop
            arl_x_in_array(i)           <= rk_in_array(to_integer(unsigned(o) & to_unsigned(i,2)));
          end loop;
          x                             <= arl_x_out_array;
          o2                            <= (8 - 1 + unsigned(o)) mod 8;
          if ke_xor_type = '0' then
            rnd_state_next              <= KEY_EXPAND_0;
          else
            rnd_state_next              <= KEY_EXPAND_1;
          end if;
        end if;
      end if;
    when X_ROUND =>
      almost_done                       <= '1';
      x                                 <= arl_x_out_array;
      rnd_state_next                    <= FINISH;
    when KEY_EXPAND_0 =>
      almost_done                       <= '1';
      for i in 0 to 3 loop
        x(i)                            <= q_x(i) xor rk_in_array(to_integer(q_o2 & to_unsigned(i,2))); 
      end loop;
      rnd_state_next                    <= FINISH;
    when KEY_EXPAND_1 =>
      almost_done                       <= '1';
      for i in 0 to 2 loop
        x(i)                            <= (q_x(i) xor rk_in_array(20+i)) xor COUNT((5-i) mod 4);
      end loop;
      x(3)                              <= (q_x(3) xor rk_in_array(23)) xnor COUNT(2);
      rnd_state_next                    <= FINISH;    
    when FINISH =>
      done                              <= '1';
      if start = '1' then
        if ke = '0' then
          for i in 0 to 3 loop
            x(i)                        <= x_in_array(i) xor rk_in_array(to_integer(unsigned(o) & to_unsigned(i,2)));
          end loop;
          rnd_state_next                <= X_ROUND;
        else
          for i in 0 to 3 loop
            arl_x_in_array(i)           <= rk_in_array(to_integer(unsigned(o) & to_unsigned(i,2)));
          end loop;
          x                             <= arl_x_out_array;
          o2                            <= (8 - 1 + unsigned(o)) mod 8;
          if ke_xor_type = '0' then
            rnd_state_next              <= KEY_EXPAND_0;
          else
            rnd_state_next              <= KEY_EXPAND_1;
          end if;
        end if;
      else
        rnd_state_next                  <= IDLE;
      end if;
    end case;
  end process rnd_proc;
  
  registers : process(clk, reset) is
  begin
    if reset = '1' then
      q_rnd_state                       <= IDLE;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        q_rnd_state                       <= rnd_state_next;
        q_x                               <= x;
        q_o2                              <= o2;
      end if;
    end if;
  end process registers;
  
end architecture shavite512_round_ce_rtl;