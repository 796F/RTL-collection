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

entity keccak is
  
  port (
    clk        : in  std_logic;
    rst_n      : in  std_logic;
    start      : in  std_logic;
    din        : in  std_logic_vector(15 downto 0);
    din_valid  : in  std_logic;
    buffer_full: out std_logic;
    last_block : in  std_logic;    
    ready      : out std_logic;
    dout       : out std_logic_vector(15 downto 0);
    dout_valid : out std_logic);

end keccak;

architecture rtl of keccak is
--components

component keccak_round
port (

    round_in     : in  k_state;
    round_constant_signal    : in std_logic_vector(63 downto 0);
    round_out    : out k_state);
end component;

component keccak_round_constants_gen
port (
    round_number: in unsigned(4 downto 0);
    round_constant_signal_out: out std_logic_vector(63 downto 0));
 end component;


component keccak_buffer 
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
 end component;
----------------------------------------------------------------------------
-- Internal signal declarations
----------------------------------------------------------------------------
signal reg_data,round_in,round_out: k_state;
--signal zero_state : k_state;
signal reg_data_vector: std_logic_vector (255 downto 0);
signal counter_nr_rounds : unsigned(4 downto 0);
--signal zero_lane: k_lane;
signal din_buffer_full:std_logic;
--signal zero_plane: k_plane;
signal round_constant_signal: std_logic_vector(63 downto 0);
signal din_buffer_out: std_logic_vector(1023 downto 0);
signal permutation_computed : std_logic;
signal din_buffer_full_r:std_logic;

begin  -- Rtl
-- port map

round_map : keccak_round port map(round_in,round_constant_signal,round_out);
round_constants_gen: keccak_round_constants_gen port map(counter_nr_rounds,round_constant_signal);
buffer_in: keccak_buffer port map(clk, rst_n,
din,din_valid,last_block, 
din_buffer_full,din_buffer_out,
reg_data_vector,
dout,dout_valid,permutation_computed);

-- constants signals
--zero_lane<= (others =>'0');

--i000: for x in 0 to 4 generate
--	zero_plane(x)<= zero_lane;
--end generate;

--i001: for y in 0 to 4 generate
--	zero_state(y)<= zero_plane;
--end generate;

--map part of the state to a vector
i002: for x in 0 to 3 generate
	i003: for i in 0 to 63 generate
		reg_data_vector(64*x+i)<= reg_data(0)(x)(i);
	end generate;
end generate;

 -- state register and counter of the number of rounds
  p_main : process (clk, rst_n)
    
  begin  -- process p_main
    if rst_n = '0' then                 -- asynchronous rst_n (active low)
      --reg_data <= zero_state;
      		for row in 0 to 4 loop
			for col in 0 to 4 loop
				for i in 0 to 63 loop
					reg_data(row)(col)(i)<='0';
				end loop;
			end loop;
		end loop;
      counter_nr_rounds <= (others => '0');
      permutation_computed <='1';
      din_buffer_full_r <= '0';
    elsif clk'event and clk = '1' then  -- rising clk edge
  din_buffer_full_r <= din_buffer_full;
	if (start='1') then
		--reg_data <= zero_state;
		for row in 0 to 4 loop
			for col in 0 to 4 loop
				for i in 0 to 63 loop
					reg_data(row)(col)(i)<='0';
				end loop;
			end loop;
		end loop;
		counter_nr_rounds <= (others => '0');	
		permutation_computed<='1';		
	else
		if(din_buffer_full ='1' and permutation_computed='1') then
			counter_nr_rounds(4 downto 0)<= (others => '0');
			counter_nr_rounds(0)<='1';
			permutation_computed<='0';
			reg_data<= round_out;
		else
			if( counter_nr_rounds < 24 and permutation_computed='0') then			
				counter_nr_rounds <= counter_nr_rounds + 1;
				reg_data<= round_out;
							
			end if;
			if( counter_nr_rounds = 23) then
				permutation_computed<='1';
				counter_nr_rounds<= (others => '0');
			end if;
		end if;
		
	end if;
    end if;
  end process p_main;

--input mapping
--capacity part

	i01: for col in 1 to 4 generate
		i02: for i in 0 to 63 generate
			round_in(3)(col)(i)<= reg_data(3)(col)(i);

		
		end generate;	
	end generate;

	i03: for col in 0 to 4 generate
		i04: for i in 0 to 63 generate
			round_in(4)(col)(i)<= reg_data(4)(col)(i);

		
		end generate;	
	end generate;
--rate part
i10: for row in 0 to 2 generate
	i11: for col in 0 to 4 generate
		i12: for i in 0 to 63 generate
			--round_in(row)(col)(i)<= reg_data(row)(col)(i) xor (din_buffer_out((row*64*5)+(col*64)+i) and (din_buffer_full_r and permutation_computed));
			round_in(row)(col)(i)<= reg_data(row)(col)(i) xor (din_buffer_out((row*64*5)+(col*64)+i) and (din_buffer_full and permutation_computed));
		end generate;	
	end generate;
end generate;

i13: for i in 0 to 63 generate
			--round_in(3)(0)(i)<= reg_data(3)(0)(i) xor (din_buffer_out((3*64*5)+(0*64)+i) and (din_buffer_full_r and permutation_computed));
			round_in(3)(0)(i)<= reg_data(3)(0)(i) xor (din_buffer_out((3*64*5)+(0*64)+i) and (din_buffer_full and permutation_computed));
end generate;	

ready<=permutation_computed;
buffer_full<=din_buffer_full;


end rtl;
