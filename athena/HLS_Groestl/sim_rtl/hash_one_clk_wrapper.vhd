-------------------------------------------------------------------------------
--! @file       hash_one_clk_wrapper.vhd
--! @brief      Wrapper for hash core
--! @project    ARC-2015 HLS SHA-3
--! @author     Ekawat (ice) Homsirikamol
--! @version    1.0
--! @copyright  Copyright (c) 2014 Cryptographic Engineering Research Group
--!             ECE Department, George Mason University Fairfax, VA, U.S.A.
--!             All rights Reserved.
--! @license    This project is released under the GNU Public License.
--!             The license and distribution terms for this file may be
--!             found in the file LICENSE in this distribution or at
--!             http://www.gnu.org/licenses/gpl-3.0.txt
--! @note       This is publicly available encryption source code that falls
--!             under the License Exception TSU (Technology and software-
--!             —unrestricted)
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use work.sha_tb_pkg.all;

entity hash_one_clk_wrapper is
	generic ( 
		algorithm 	: string  := "bmw";
		hashsize 	: integer := 256;
		iwidth 			: integer := 64; 
    owidth 			: integer := 64; 
		pad_mode	: integer := PAD;	
		fifo_mode	: integer := ZERO_WAIT_STATE		
	);
	port (		
		rst 		: in std_logic;
		clk 		: in std_logic;		
		din			: in std_logic_vector(iwidth-1 downto 0);		
	    src_read	: out std_logic;
	    src_ready	: in  std_logic;
	    dout		: out std_logic_vector(owidth-1 downto 0);
	    dst_write	: out std_logic;
	    dst_ready	: in std_logic
	);   
end entity;

architecture structure of hash_one_clk_wrapper is

begin				  		
	uut:  entity work.hls_groestl(structure)
			port map (		
				rst 	=> rst,
				clk 	=> clk,			
				din			=> din,
			    src_read	=> src_read,
			    src_ready	=> src_ready,
			    dout		=> dout,
			    dst_write	=> dst_write,
			    dst_ready	=> dst_ready
		);   
end structure;