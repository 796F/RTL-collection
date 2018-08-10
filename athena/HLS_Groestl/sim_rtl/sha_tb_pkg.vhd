-------------------------------------------------------------------------------
--! @file       sha_tb_pkg.vhd
--! @brief      Testbench's package
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


package sha_tb_pkg is		
	-- =========================
	-- DO NOT EDIT THIS SECTION
	-- =========================
	constant ONE_CLK : integer 	:= 1;
	constant TWO_CLK : integer 	:= 2;
	
	constant NOPAD : integer 	:= 0;
	constant PAD : integer 		:= 1;
	
	constant ZERO_WAIT_STATE			: integer:=0;
	constant ONE_WAIT_STATE				: integer:=1;  
	constant ZERO_WAIT_STATE_PREFETCH	: integer:=2; 

	constant DISTRIBUTED				: integer:=0; 
	constant BRAM						: integer:=1; 
	
	constant NO_SPLIT					: integer := 0;
	constant FIXED_SPLIT				: integer := 1;
	constant RANDOM_SPLIT				: integer := 2;	
	-- =========================

	
	
	
	-- =========================
	-- =========================
	-- EDIT THIS SECTION ONLY!!!
	-- =========================
	-- =========================
	-- hash core parameters	
	constant algorithm			: string 	:= "Groestl";
		--Algorithm supported:
		   --      blake, blue_midnight_wish, cubehash, echo, fugue, groestl, hamsi
		   --      jh, keccak, luffa, sha-2, shabal, shavite-3, simd, skein		
	constant hashsize			: integer 	:= 256;	
	constant iwidth				: integer 	:= 64;
    constant owidth				: integer 	:= 64;
	constant pad_mode			: integer	:= PAD;	-- valid modes are ==> PAD (padded input), NOPAD (not padded input)
	constant fifo_mode			: integer 	:= ZERO_WAIT_STATE; -- valid modes are ==> ZERO_WAIT_STATE, ONE_WAIT_STATE		
	constant interface_type     : integer 	:= ONE_CLK; 		-- valid types are ==> ONE_CLK (one clock), TWO_CLK (two clocks: clk and io_clk)
	constant fr 				: integer 	:= 1; 				-- frequency ratio of io_clk to clk

	-- Simulation parameters
	constant clk_period 		: time 		:= 20 ns;			-- clock speed		
	constant split_type			: integer	:= RANDOM_SPLIT;	-- valid types are ==> NO_SPLIT, FIXED_SPLIT, or RANDOM_SPLIT
	constant logfile_name 		: string 	:= "athena_test_log.txt";
	constant resultfile_name 	: string 	:= "athena_test_result.txt"; 

	-- FIFO parameters		
	constant fifo_style			: integer 	:= BRAM; 			-- valid styles are ==> DISTRIBUTED,  BRAM 
	constant depth 				: integer	:= 1024;				-- depth of FIFO
	constant log2depth 			: integer 	:= 10;				-- 2^X = depth, where X = log2depth					   
	
	
	-- Test Mode
	constant test_mode 		: integer := 0;
		-- 0 = standard (no input empty or output full check)
		-- 1 = all (standard + input empty)
		-- 2 = standard + input empty error check
		-- 3 = standard + output full error check
	constant input_stall_cycles : integer := 50;
		-- The number of IO_clock_cycles to be stalled between each src_read signal
	constant output_stall_cycles : integer := 400;
		-- The number of IO_clock_cycles to be stalled between each dst_write signal
	-- =========================
	-- =========================
	-- END OF EDITABLE SECTION
	-- =========================
	-- =========================
	
	
	
	-- =========================
	-- FUNCTIONS
	-- =========================
	function get_io_clk ( cpr : time; fr : integer; interface : integer ) return time;
	function get_pad_str ( i : integer ) return string;
	function get_split_str ( i : integer ) return string;
	function get_interface_str ( i : integer ) return string;
	
	-- =========================
	-- COMPONENTS
	-- =========================
	component hash_two_clk_wrapper is
	generic ( 
		algorithm 	: string  := "bmw";
		hashsize 	: integer := 256;
		iwidth 			: integer := 64; 
    owidth 			: integer := 64; 
		pad_mode	: integer := PAD;	
		fifo_mode	: integer := ZERO_WAIT_STATE; 
		fr			: integer := 8		
	);
	port (		
		rst 		: in std_logic;
		clk 		: in std_logic;
		io_clk 		: in std_logic;
		din			: in std_logic_vector(iwidth-1 downto 0);
	    src_read	: out std_logic;
	    src_ready	: in  std_logic;
	    dout		: out std_logic_vector(owidth-1 downto 0);
	    dst_write	: out std_logic;
	    dst_ready	: in std_logic
	);   
	end component;
	
	component hash_one_clk_wrapper is
	generic ( 
		algorithm 	: string  := "bmw";
		hashsize 	: integer := 256;
		w 			: integer := 64; 
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
	end component;	
	
	component fifo_ram is
		generic ( 	
			fifo_style		: integer := BRAM;	
			depth 			: integer := 512;
			log2depth  		: integer := 9;
			n 				: integer := 64 );	
		port ( 	
			clk 			: in  std_logic;
			write 			: in  std_logic;
			rd_addr 		: in  std_logic_vector (log2depth-1 downto 0);
			wr_addr 		: in  std_logic_vector (log2depth-1 downto 0);
			din 			: in  std_logic_vector (n-1 downto 0);
			dout 			: out std_logic_vector (n-1 downto 0));
	end component;
	
	component fifo is
		generic (
			fifo_mode		: integer := ZERO_WAIT_STATE;
			fifo_style		: integer := BRAM;
			depth 			: integer := 512;	
			log2depth 		: integer := 9;
			n 				: integer := 64);
		port (
			clk				: in std_logic;
			rst				: in std_logic;
			write			: in std_logic; 
			read			: in std_logic;
			din 			: in std_logic_vector(n-1 downto 0);
			dout	 		: out std_logic_vector(n-1 downto 0);
			full			: out std_logic; 
			empty 			: out std_logic);
	end component;


end package sha_tb_pkg;		  

package body sha_tb_pkg is	
	-- =========================
	--  FUNCTION DESCRIPTIONS
	-- =========================
	function get_io_clk ( cpr : time; fr : integer; interface : integer ) return time is
		variable ret : time := cpr/fr;
	begin			
		if (interface = TWO_CLK) then			
			return ( ret );
		else 
			return ( cpr );
		end if;
	end function get_io_clk; 
	
	function get_pad_str ( i : integer ) return string is
	begin
		if ( i = PAD ) then
			return "PAD";
		elsif ( i = NOPAD ) then
			return "NOPAD";		  
		else
			return "ERROR";
		end if;
	end function get_pad_str;		
	
	function get_split_str ( i : integer ) return string is
	begin
		if ( i = NO_SPLIT ) then
			return "NO_SPLIT";
		elsif ( i = FIXED_SPLIT ) then
			return "FIXED_SPLIT";
		elsif ( i = RANDOM_SPLIT ) then
			return "RANDOM_SPLIT";
		else
			return "ERROR";
		end if;
	end function get_split_str;		
	
	function get_interface_str ( i : integer ) return string is
	begin
		if ( i = ONE_CLK ) then
			return "ONE_CLK";
		elsif ( i = TWO_CLK ) then
			return "TWO_CLK";		  
		else
			return "ERROR";
		end if;
	end function get_interface_str;	
end package body;