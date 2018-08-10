--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
library work;


entity jh_linear is
   port(
      idata:in std_logic_vector(1023 downto 0);
      odata:out std_logic_vector(1023 downto 0)

   );
end jh_linear;


--signal declaration
architecture rtl of jh_linear is


component jh_mds
port (

      a: in std_logic_vector(3 downto 0);
	b: in std_logic_vector(3 downto 0);
	c: out std_logic_vector(3 downto 0);
	d: out std_logic_vector(3 downto 0)
);
end component;

begin

is00: for i in 0 to 127 generate
	imds_map : jh_mds port map(idata(i*8+3 downto i*8),idata(i*8+7 downto i*8+4),odata(i*8+3 downto i*8),odata(i*8+7 downto i*8+4));
end generate;



end rtl;
