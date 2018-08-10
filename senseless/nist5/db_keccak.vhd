--  
-- Copyright (c) 2018 Allmine Inc
--
 
library work;
    use work.keccak_globals.all;
    
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity db_keccak is
port(   clk    : in  std_logic;
        msg_in : in  std_logic_vector(511 downto 0);
        dout   : out std_logic_vector(511 downto 0)
    );
end db_keccak;

architecture rtl of db_keccak is

--components

component keccak
port(
    clk          : in  std_logic;
    msg_in       : in  std_logic_vector(511 downto 0);
--    nonce_in     : in  std_logic_vector(size_nonce-1 downto 0);
    padding_byte : in  std_logic_vector(7 downto 0);
    dout         : out std_logic_vector(511 downto 0)
    );
end component;
    
  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------

signal pad0 : std_logic_vector(7 downto 0);
signal msg0 : std_logic_vector(511 downto 0);
signal dout0 : std_logic_vector(511 downto 0);
signal dout_tmp : std_logic_vector(511 downto 0);
signal din_tmp : std_logic_vector(511 downto 0);

begin  -- Rtl

    --swap endinaess
--    i0: for w in 0 to 7 generate
--        i1: for b in 0 to 7 generate
--            din_tmp(64*w+8*b+7 downto 64*w+8*b) <= msg_in(64*w+8*(7-b)+7 downto 64*w+8*(7-b));
--        end generate;
--    end generate;
    din_tmp <= msg_in;

    pad0   <= x"01";
    msg0   <= din_tmp;
    
    mkeccak00_map : keccak
        port map(   clk,
                    msg0,
                    pad0,
                    dout0
                );
                
        
    dout_tmp <= dout0;
    dout <= dout_tmp;
    --swap endinaess
--    o0: for w in 0 to 7 generate
--        o1: for b in 0 to 7 generate
--            dout(64*w+8*b+7 downto 64*w+8*b) <= dout_tmp(64*w+8*(7-b)+7 downto 64*w+8*(7-b));
--        end generate;    
--    end generate;

end rtl;
