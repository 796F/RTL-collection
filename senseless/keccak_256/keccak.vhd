--  
-- Copyright (c) 2018 Allmine Inc
--


library work;
	use work.keccak_globals.all;
	
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;



entity keccak is
  
  port (
    clk     : in  std_logic;
    state_in     : in  std_logic_vector(1599 downto 0);
    nonce_in     : in  std_logic_vector(size_nonce-1 downto 0);
    padding_byte     : in  std_logic_vector(7 downto 0);
    dout    : out std_logic_vector(255 downto 0)
	);

end keccak;

architecture rtl of keccak is

--components

component keccak_linear
port (

    state_in     : in  k_state_type;
    state_out    : out k_state_type);

end component;


component keccak_nonlinear
port (

    state_in     : in  k_state_type;
    state_out    : out k_state_type);

end component;

component keccak_iota
port (

    state_in     : in  k_state_type;
	n_round: in std_logic_vector(4 downto 0);
    state_out    : out k_state_type);

end component;

component keccak_round_constants_gen
port (
    round_number: in unsigned(4 downto 0);
    round_constant_signal_out: out std_logic_vector(63 downto 0));
 end component;

component keccak_register
port (

	clk : in std_logic;
    state_in     : in  k_state_type;
    state_out    : out k_state_type);

end component;

  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------

 
signal in00,nl00, rg00,ll00,rc00: k_state_type;
signal nl01, rg01,ll01,rc01: k_state_type;
signal nl02, rg02,ll02,rc02: k_state_type;
signal nl03, rg03,ll03,rc03: k_state_type;
signal nl04, rg04,ll04,rc04: k_state_type;
signal nl05, rg05,ll05,rc05: k_state_type;
signal nl06, rg06,ll06,rc06: k_state_type;
signal nl07, rg07,ll07,rc07: k_state_type;
signal nl08, rg08,ll08,rc08: k_state_type;
signal nl09, rg09,ll09,rc09: k_state_type;
signal nl10, rg10,ll10,rc10: k_state_type;
signal nl11, rg11,ll11,rc11: k_state_type;
signal nl12, rg12,ll12,rc12: k_state_type;
signal nl13, rg13,ll13,rc13: k_state_type;
signal nl14, rg14,ll14,rc14: k_state_type;
signal nl15, rg15,ll15,rc15: k_state_type;
signal nl16, rg16,ll16,rc16: k_state_type;
signal nl17, rg17,ll17,rc17: k_state_type;
signal nl18, rg18,ll18,rc18: k_state_type;
signal nl19, rg19,ll19,rc19: k_state_type;
signal nl20, rg20,ll20,rc20: k_state_type;
signal nl21, rg21,ll21,rc21: k_state_type;
signal nl22, rg22,ll22,rc22: k_state_type;
signal nl23, rg23,ll23,rc23: k_state_type;


signal dout_tmp: std_logic_vector (255 downto 0);
signal state_in_sw, permutation_input, state_out_sw: std_logic_vector (1599 downto 0);  
begin  -- Rtl

-- port map
-- fully unrolled 24 rounds
-- rgxx register out round xx
-- llxx output linear layer round xx
-- nlxx output non linear layer round xx
-- rcxx output of iota layer round xx
rg00_map : keccak_register port map(clk,in00,rg00);
ll00_map : keccak_linear port map(rg00,ll00);
nl00_map : keccak_nonlinear port map(ll00,nl00);
rc00_map : keccak_iota port map(nl00,"00000",rc00);
-- round1
rg01_map : keccak_register port map(clk,rc00,rg01);
ll01_map : keccak_linear port map(rg01,ll01);
nl01_map : keccak_nonlinear port map(ll01,nl01);
rc01_map : keccak_iota port map(nl01,"00001",rc01);
-- round2
rg02_map : keccak_register port map(clk,rc01,rg02);
ll02_map : keccak_linear port map(rg02,ll02);
nl02_map : keccak_nonlinear port map(ll02,nl02);
rc02_map : keccak_iota port map(nl02,"00010",rc02);
-- round3
rg03_map : keccak_register port map(clk,rc02,rg03);
ll03_map : keccak_linear port map(rg03,ll03);
nl03_map : keccak_nonlinear port map(ll03,nl03);
rc03_map : keccak_iota port map(nl03,"00011",rc03);
-- round4
rg04_map : keccak_register port map(clk,rc03,rg04);
ll04_map : keccak_linear port map(rg04,ll04);
nl04_map : keccak_nonlinear port map(ll04,nl04);
rc04_map : keccak_iota port map(nl04,"00100",rc04);
-- round5
rg05_map : keccak_register port map(clk,rc04,rg05);
ll05_map : keccak_linear port map(rg05,ll05);
nl05_map : keccak_nonlinear port map(ll05,nl05);
rc05_map : keccak_iota port map(nl05,"00101",rc05);
-- round6
rg06_map : keccak_register port map(clk,rc05,rg06);
ll06_map : keccak_linear port map(rg06,ll06);
nl06_map : keccak_nonlinear port map(ll06,nl06);
rc06_map : keccak_iota port map(nl06,"00110",rc06);
-- round7
rg07_map : keccak_register port map(clk,rc06,rg07);
ll07_map : keccak_linear port map(rg07,ll07);
nl07_map : keccak_nonlinear port map(ll07,nl07);
rc07_map : keccak_iota port map(nl07,"00111",rc07);
-- round8
rg08_map : keccak_register port map(clk,rc07,rg08);
ll08_map : keccak_linear port map(rg08,ll08);
nl08_map : keccak_nonlinear port map(ll08,nl08);
rc08_map : keccak_iota port map(nl08,"01000",rc08);
-- round9
rg09_map : keccak_register port map(clk,rc08,rg09);
ll09_map : keccak_linear port map(rg09,ll09);
nl09_map : keccak_nonlinear port map(ll09,nl09);
rc09_map : keccak_iota port map(nl09,"01001",rc09);
-- round10
rg10_map : keccak_register port map(clk,rc09,rg10);
ll10_map : keccak_linear port map(rg10,ll10);
nl10_map : keccak_nonlinear port map(ll10,nl10);
rc10_map : keccak_iota port map(nl10,"01010",rc10);
-- round11
rg11_map : keccak_register port map(clk,rc10,rg11);
ll11_map : keccak_linear port map(rg11,ll11);
nl11_map : keccak_nonlinear port map(ll11,nl11);
rc11_map : keccak_iota port map(nl11,"01011",rc11);
-- round12
rg12_map : keccak_register port map(clk,rc11,rg12);
ll12_map : keccak_linear port map(rg12,ll12);
nl12_map : keccak_nonlinear port map(ll12,nl12);
rc12_map : keccak_iota port map(nl12,"01100",rc12);
-- round13
rg13_map : keccak_register port map(clk,rc12,rg13);
ll13_map : keccak_linear port map(rg13,ll13);
nl13_map : keccak_nonlinear port map(ll13,nl13);
rc13_map : keccak_iota port map(nl13,"01101",rc13);
-- round14
rg14_map : keccak_register port map(clk,rc13,rg14);
ll14_map : keccak_linear port map(rg14,ll14);
nl14_map : keccak_nonlinear port map(ll14,nl14);
rc14_map : keccak_iota port map(nl14,"01110",rc14);
-- round15
rg15_map : keccak_register port map(clk,rc14,rg15);
ll15_map : keccak_linear port map(rg15,ll15);
nl15_map : keccak_nonlinear port map(ll15,nl15);
rc15_map : keccak_iota port map(nl15,"01111",rc15);
-- round16
rg16_map : keccak_register port map(clk,rc15,rg16);
ll16_map : keccak_linear port map(rg16,ll16);
nl16_map : keccak_nonlinear port map(ll16,nl16);
rc16_map : keccak_iota port map(nl16,"10000",rc16);
-- round17
rg17_map : keccak_register port map(clk,rc16,rg17);
ll17_map : keccak_linear port map(rg17,ll17);
nl17_map : keccak_nonlinear port map(ll17,nl17);
rc17_map : keccak_iota port map(nl17,"10001",rc17);
-- round18
rg18_map : keccak_register port map(clk,rc17,rg18);
ll18_map : keccak_linear port map(rg18,ll18);
nl18_map : keccak_nonlinear port map(ll18,nl18);
rc18_map : keccak_iota port map(nl18,"10010",rc18);
-- round19
rg19_map : keccak_register port map(clk,rc18,rg19);
ll19_map : keccak_linear port map(rg19,ll19);
nl19_map : keccak_nonlinear port map(ll19,nl19);
rc19_map : keccak_iota port map(nl19,"10011",rc19);
-- round20
rg20_map : keccak_register port map(clk,rc19,rg20);
ll20_map : keccak_linear port map(rg20,ll20);
nl20_map : keccak_nonlinear port map(ll20,nl20);
rc20_map : keccak_iota port map(nl20,"10100",rc20);
-- round21
rg21_map : keccak_register port map(clk,rc20,rg21);
ll21_map : keccak_linear port map(rg21,ll21);
nl21_map : keccak_nonlinear port map(ll21,nl21);
rc21_map : keccak_iota port map(nl21,"10101",rc21);
-- round22
rg22_map : keccak_register port map(clk,rc21,rg22);
ll22_map : keccak_linear port map(rg22,ll22);
nl22_map : keccak_nonlinear port map(ll22,nl22);
rc22_map : keccak_iota port map(nl22,"10110",rc22);
-- round23
rg23_map : keccak_register port map(clk,rc22,rg23);
ll23_map : keccak_linear port map(rg23,ll23);
nl23_map : keccak_nonlinear port map(ll23,nl23);
rc23_map : keccak_iota port map(nl23,"10111",rc23);



--input mapping

-- adjust endianess, xor nonce, and xor padding byte and add last bit of the padding

-- for keccak 256 
-- the nonce is at the end of the 640 bits (from 1599-32-640 to 1599-640
-- the padding byte goes at the end of the 640 input bits
-- last bit of padding is in positio of the ending of the rate, rate is 1088 bits


-- for keccak 512 the padding byte goes at the end of the 640 input bits, 576 already absorbed in the first permutation
-- additional more 32 bit are absorbed in the state, and 32 bit of nonce are absorbed, so padding byte is in postion 
-- last bit of padding is in positio of the ending of the rate, rate is 1088 bits


--swap endianess of state

isw11: for byte in 0 to 199 generate
    isw12: for i in 0 to 7 generate
        --dout((row*64*5)+(col*64)+i) <= rc23(row)(col)(i);
        state_in_sw((199-byte)*8+i) <= state_in(byte*8+i);
    end generate;    
end generate;

    in001: for i in 0 to (size_input-1) generate
        permutation_input(i) <= state_in_sw(i);
    end generate;    
-- apply nonce
    in002: for i in (size_input) to (size_input + size_nonce -1) generate
        permutation_input(i) <= state_in_sw(i) xor nonce_in(i-(size_input));
    end generate;    

-- apply padding byte

    in003: for i in (size_input + size_nonce) to (size_input + size_nonce +7) generate
        permutation_input(i) <= state_in_sw(i) xor padding_byte(i-(size_input + size_nonce));
    end generate;    
-- padding with zero, so copy

    in004: for i in (size_input + size_nonce + 8) to (size_input_rate -2) generate
        permutation_input(i) <= state_in_sw(i);
    end generate;    
   
-- padding bit of the 0x80    
   permutation_input(size_input_rate -1) <= state_in_sw(size_input_rate -1) xor '1';

-- capacity part

    in005: for i in (size_input_rate) to (1599) generate
        permutation_input(i) <= state_in_sw(i);
    end generate;    
    

i100: for row in 0 to 4 generate
	i110: for col in 0 to 4 generate
		i120: for i in 0 to 63 generate
			in00(row)(col)(i)<= permutation_input(((row)*64*5)+(col*64)+i);
		end generate;	
	end generate;
end generate;



--output mapping
-- just 256 bits
--o10: for row in 0 to 4 generate
	o11: for col in 0 to 3 generate
		o12: for i in 0 to 63 generate
			--dout((row*64*5)+(col*64)+i) <= rc23(row)(col)(i);
			dout_tmp((0*64*5)+(col*64)+i) <= rc23(0)(col)(i);
		end generate;	
	end generate;
--end generate;

--swap endinaess
o110: for byte in 0 to 31 generate
    o120: for i in 0 to 7 generate
        --dout((row*64*5)+(col*64)+i) <= rc23(row)(col)(i);
        dout((31-byte)*8+i) <= dout_tmp(byte*8+i);
    end generate;    
end generate;



end rtl;
