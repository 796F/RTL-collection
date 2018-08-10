-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.sha3_pkg.all;

-- AES sbox as combinational function
-- ch.10 "FPGA and ASIC Implementatios of AES" by Kris Gaj and Pawel Chodowiec, p. 235-294
-- in "Cryptographic Engineering", Springer 2009 

entity aes_sbox_logic is
    port ( s_in : in  std_logic_vector (AES_SBOX_SIZE-1 downto 0);
           s_out : out  std_logic_vector (AES_SBOX_SIZE-1 downto 0));
end aes_sbox_logic;

architecture aes_sbox_logic of aes_sbox_logic is
signal res_mul_x, res_gf_inv, res_mul_mx : std_logic_vector (AES_SBOX_SIZE-1 downto 0);
constant b : std_logic_vector (AES_SBOX_SIZE-1 downto 0) := "01100011";

begin

	res_mul_x <= mul_x(x=> s_in);
	res_gf_inv <= gf_inv_8 (x=> res_mul_x);
	res_mul_mx <= mul_mx (x=> res_gf_inv);
	s_out <= b xor res_mul_mx;

end aes_sbox_logic;

