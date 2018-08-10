--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
library work;


entity jh_sbox is
   port(
      selection:in std_logic_vector(255 downto 0);
      idata:in std_logic_vector(1023 downto 0);
      odata:out std_logic_vector(1023 downto 0)

   );
end jh_sbox;


--signal declaration
architecture RTL of jh_sbox is


component jh_sbox0
port (

      idata:in std_logic_vector(3 downto 0);
      odata:out std_logic_vector(3 downto 0));
end component;

component jh_sbox1
port (

      idata:in std_logic_vector(3 downto 0);
      odata:out std_logic_vector(3 downto 0));
end component;

signal sbox0out,sbox1out,sbox_out: std_logic_vector(1023 downto 0);

begin

is00: for i in 0 to 255 generate
	-- port map two sboxes
	isb0_map : jh_sbox0 port map(idata(i*4+3 downto i*4),sbox0out(i*4+3 downto i*4));
	isb1_map : jh_sbox1 port map(idata(i*4+3 downto i*4),sbox1out(i*4+3 downto i*4));
	sbox_out(i*4+3 downto i*4) <= sbox0out(i*4+3 downto i*4) when selection(255-i) ='0' else
									sbox1out(i*4+3 downto i*4);
end generate;

odata <= sbox_out;

end RTL;
