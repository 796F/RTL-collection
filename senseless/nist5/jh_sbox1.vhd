--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
library work;



--datapath entity
entity jh_sbox1 is
   port(
      idata:in std_logic_vector(3 downto 0);
      odata:out std_logic_vector(3 downto 0)

   );
end jh_sbox1;


--signal declaration
architecture RTL of jh_sbox1 is
--/*The two Sboxes S0 and S1*/
--unsigned char S[2][16] = { { 9,0,4,11,13,12,3,15,1,10,2,6,7,5,8,14 },{ 3,12,6,13,5,7,1,9,15,2,0,4,11,10,14,8 } };


signal odata_signal : std_logic_vector(3 downto 0);

begin
   --combinational logics
sbox1 : process (idata)
begin
	  
		case idata is
			when "0000" => odata_signal <= "0011";
			when "0001" => odata_signal <= "1100";
			when "0010" => odata_signal <= "0110";
			when "0011" => odata_signal <= "1101";
			when "0100" => odata_signal <= "0101";
			when "0101" => odata_signal <= "0111";
			when "0110" => odata_signal <= "0001";
			when "0111" => odata_signal <= "1001";
			when "1000" => odata_signal <= "1111";
			when "1001" => odata_signal <= "0010";
			when "1010" => odata_signal <= "0000";
			when "1011" => odata_signal <= "0100";
			when "1100" => odata_signal <= "1011";
			when "1101" => odata_signal <= "1010";
			when "1110" => odata_signal <= "1110";
			when "1111" => odata_signal <= "1000";
	        when others => odata_signal <=(others => '0');
          end case;  
	    
	  
      end process sbox1;
	  
odata <= odata_signal;
end RTL;
