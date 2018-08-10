--------------------------------------------------------------------------
--2010 CESCA @ Virginia Tech
--------------------------------------------------------------------------
--This program is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------
--Algorithm Name: Keccak
--Authors: Guido Bertoni, Joan Daemen, Michael Peeters and Gilles Van Assche
--Date: August 29, 2009

--This code, originally by Guido Bertoni, Joan Daemen, Michael Peeters and
--Gilles Van Assche as a part of the SHA-3 submission, is hereby put in the
--public domain. It is given as is, without any guarantee.

--For more information, feedback or questions, please refer to our website:
--http://keccak.noekeon.org/
--------------------------------------------------------------------------

library work;
	use work.keccak_globals.all;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity keccak_buffer is
  
  port (
        clk                   : in  std_logic;
        rst_n                 : in  std_logic;    
        din_buffer_in         : in  std_logic_vector(15 downto 0);
        din_buffer_in_valid   : in  std_logic;
        last_block            : in  std_logic;
        din_buffer_full       : out std_logic;
        din_buffer_out        : out std_logic_vector(1023 downto 0);
        dout_buffer_in        : in  std_logic_vector(255 downto 0);
        dout_buffer_out       : out std_logic_vector(15 downto 0);
        dout_buffer_out_valid : out std_logic;
        ready                 : in  std_logic);

end keccak_buffer;

architecture rtl of keccak_buffer is

--components
----------------------------------------------------------------------------
-- Internal signal declarations
----------------------------------------------------------------------------
signal mode, buffer_full: std_logic; --mode=0 input mode/ mode=1 output mode
signal count_in_words : unsigned(6 downto 0);

signal initial_buff: std_logic;
signal buffer_data: std_logic_vector(1023 downto 0);
 
begin  -- Rtl

  p_main : process (clk, rst_n)
 variable count_out_words:integer range 0 to 16;
    
  begin  -- process p_main
    if rst_n = '0' then                 -- asynchronous rst_n (active low)
      buffer_data <= (others => '0');
      count_in_words <= (others => '0');
      count_out_words :=0;
      buffer_full <='0';
      mode<='0';      
      dout_buffer_out_valid<='0';
      initial_buff <= '0';
    elsif clk'event and clk = '1' then  -- rising clk edge
	
	if(din_buffer_in_valid = '1' and buffer_full = '0')then
	  initial_buff <= '1';
	 end if;
	    
	if(last_block ='1' and ready='1') then
		mode<='1';
	end if;

	--input mode
	if (mode='0') then
		if(buffer_full='1' and ready ='1')  then
			buffer_full<='0';
			count_in_words<= (others=>'0');
			
		else
			
if (din_buffer_in_valid='1' and buffer_full='0') then
							--shift buffer
					if(count_in_words(1 downto 0) = 0) then
						buffer_data(1023 downto 1008) <= din_buffer_in;
						for i in 0 to 14 loop
							buffer_data( 63+(i*64) downto 0+(i*64) )<=buffer_data( 127+(i*64) downto 64+(i*64) );			
						end loop;
					elsif(count_in_words(1 downto 0) = 1) then
						buffer_data(1007 downto 992) <= din_buffer_in;
					elsif(count_in_words(1 downto 0) = 2) then
						buffer_data(991 downto 976) <= din_buffer_in;
					else	
						buffer_data(975 downto 960)<= din_buffer_in;
					end if;	
					--insert new input
   				--	buffer_data(1023 downto 1008) <= din_buffer_in;
					if (count_in_words=63) then
						-- buffer full ready for being absorbed by the permutation
						buffer_full <= '1';
						count_in_words<= (others=>'0');
					else
						-- increment count_in_words
						count_in_words <= count_in_words + 1;				
					
					end if;		
			end if;
		end if;
	else
		--output mode
		dout_buffer_out_valid<='1';
		if(count_out_words=0) then
			buffer_data(255 downto 0) <= dout_buffer_in;
			count_out_words:=count_out_words+1;
			dout_buffer_out_valid<='1';
			--for i in 0 to 2 loop
			--	buffer_data( 63+(i*64) downto 0+(i*64) )<=buffer_data( 127+(i*64) downto 64+(i*64) );
			--end loop;
		else
			if(count_out_words<16) then
				count_out_words:=count_out_words+1;
				dout_buffer_out_valid<='1';
			--	for i in 0 to 2 loop
			--		buffer_data( 63+(i*64) downto 0+(i*64) )<=buffer_data( 127+(i*64) downto 64+(i*64) );
			--	end loop;
					buffer_data( 239 downto 0 )<=buffer_data( 255 downto 16 );
			else
				dout_buffer_out_valid<='0';
				count_out_words:=0;
				mode<='0';					
			end if;
		end if;
	end if;
    end if;
  end process p_main;

din_buffer_out  <=buffer_data;
dout_buffer_out <=buffer_data(15 downto 0);
din_buffer_full <=buffer_full;

end rtl;
