-------------------------------------------------------------------------------
--! @file       sha_tb_all_hls.vhd
--! @brief      Testbench for HLS-based SHA-3
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.ALL;
use ieee.std_logic_textio.all;
use work.sha_tb_pkg.all;

LIBRARY std;
use std.textio.all;

ENTITY sha_tb_all IS
END sha_tb_all;

ARCHITECTURE behavior OF sha_tb_all IS
	-- =================== --
	-- STR DECLARATION --
	-- =================== --
	constant pad_str 		: string := get_pad_str( pad_mode );
	constant split_str 		: string := get_split_str( split_type );
	constant interface_str 	: string := get_interface_str( interface_type );
	constant ifile_name 	: string := split_str & "_" & pad_str & "_" & algorithm & "_datain_h" & integer'image(hashsize) & "_w" & integer'image(iwidth) & ".txt";
	constant ofile_name 	: string := split_str & "_" & pad_str & "_" & algorithm & "_dataout_h" & integer'image(hashsize) & "_w" & integer'image(iwidth) & ".txt";

	-- =================== --
	-- SIGNALS DECLARATION --
	-- =================== --

	-- simulation signals (used by ATHENa script, ignore if not used)
	signal simulation_pass : std_logic := '0'; 	  	-- '0' signifies a pass at the end of simulation, '1' is fail
	signal stop_clock : boolean := false;		-- '1' signifies a completed simulation, '0' otherwise
	signal force_exit : boolean := false;

	-- error check signal
	signal global_stop : std_logic := '1';

	-- globals
	SIGNAL clk 		:  std_logic := '0';
	signal io_clk 	: std_logic := '0';
	SIGNAL rst 		:  std_logic := '0';

	--Inputs
	SIGNAL fifoin_write : std_logic := '0';
	signal fifoout_read : std_logic := '0';
	SIGNAL ext_idata 	:  std_logic_vector(iwidth-1 downto 0) := (others=>'0');

	--Outputs
	SIGNAL fifoout_empty:  std_logic;
	SIGNAL fifoin_full 	:  std_logic;
	SIGNAL ext_odata 	:  std_logic_vector(owidth-1 downto 0);

	-- Internals
	SIGNAL fifoin_empty  : std_logic;
	SIGNAL fifoin_read 	 : std_logic;
	SIGNAL fifoout_full  : std_logic;
	SIGNAL fifoout_write : std_logic;
	SIGNAL odata 		 : std_logic_vector(owidth-1 downto 0);
	SIGNAL idata 		 : std_logic_vector(iwidth-1 downto 0);
	SIGNAL idata_delayed : std_logic_vector(iwidth-1 downto 0);

	--Verification signals
	signal stall_fifoin_empty		: std_logic := '0';
	signal stall_fifoout_full		: std_logic := '0';
	signal fifoin_ready_selected 	: std_logic;
	signal fifoin_read_selected 	: std_logic;
	signal fifoout_ready_selected 	: std_logic;
	signal fifoout_write_selected 	: std_logic;



	------------- clock constant ------------------
	constant io_clk_period : time := get_io_clk( clk_period, fr, interface_type );
	----------- end of clock constant -------------

	------------- string constant ------------------
   	constant cons_len 	: string(1 to 6) := "Len = ";
	constant cons_msg 	: string(1 to 6) := "Msg = ";
	constant cons_md 	: string(1 to 5) := "MD = ";
	constant cons_eof 	: string(1 to 5) := "#EOF#";
	----------- end of string constant -------------

	------------- debug constant ------------------
   	constant debug_input : boolean := false;
	constant debug_output : boolean := false;
	----------- end of clock constant -------------

	-- ================= --
	-- FILES DECLARATION --
	-- ================= --

	--------------- input / output files -------------------
	FILE datain_file	: TEXT OPEN READ_MODE   is  ifile_name;
	FILE dataout_file	: TEXT OPEN READ_MODE   is  ofile_name;

	FILE log_file : TEXT OPEN WRITE_MODE is logfile_name;
	FILE result_file : TEXT OPEN WRITE_MODE is resultfile_name;
	------------- end of input files --------------------

BEGIN

	clk_gen: process
	begin
		if ((not stop_clock) and (global_stop = '1')) then
			clk <= '1';
			wait for clk_period/2;
			clk <= '0';
			wait for clk_period/2;
		else
			wait;
		end if;
	end process clk_gen;

	io_clk_gen: process
	begin
		if ((not stop_clock) and (global_stop = '1')) then
			io_clk <= '1';
			wait for io_clk_period/2;
			io_clk <= '0';
			wait for io_clk_period/2;
		else
			wait;
		end if;
	end process io_clk_gen;

	-- ============ --
	-- PORT MAPPING --
	-- ============ --
	fifoin: entity work.fifo(prefetch)
	generic map ( fifo_mode=>fifo_mode, depth => depth, log2depth => log2depth, N => iwidth)
	port map (
		clk=>io_clk,
		rst=>rst,
		write=>fifoin_write,
		read=>fifoin_read_selected,
		din=>ext_idata,
		dout=>idata,
		full=>fifoin_full,
		empty=>fifoin_empty);
	fifoin_read_selected <= '0' when stall_fifoin_empty = '1' else fifoin_read;
	fifoin_ready_selected <= '0' when stall_fifoin_empty = '1' else not fifoin_empty;	 -- '1' when emptied

	fifoout: entity work.fifo(prefetch)
		generic map ( fifo_mode=>fifo_mode, depth => depth, log2depth => log2depth, N => owidth)
		port map (
		clk=>io_clk,
		rst=>rst,
		write=>fifoout_write_selected,
		read=>fifoout_read,
		din=>odata,
		dout=>ext_odata,
		full=>fifoout_full,
		empty=>fifoout_empty);
	fifoout_write_selected <= '0' when stall_fifoout_full = '1' else fifoout_write;
	fifoout_ready_selected <= '0' when stall_fifoout_full = '1' else not fifoout_full; -- '1' when fulled


	idata_delayed <= idata after 1/4*clk_period;
	one_clk_gen : if (interface_type = one_clk) generate
		uut:  entity work.hash_one_clk_wrapper(structure)
		generic map ( algorithm => algorithm, hashsize => hashsize, iwidth => iwidth, owidth => owidth, pad_mode => pad_mode, fifo_mode => fifo_mode )
		port map (
			rst 	=> rst,
			clk 	=> clk,
			din			=> idata_delayed,
		    src_read	=> fifoin_read,
		    src_ready	=> fifoin_ready_selected,
		    dout		=> odata,
		    dst_write	=> fifoout_write,
		    dst_ready	=> fifoout_ready_selected
		);
	end generate;
	two_clk_gen : if (interface_type = two_clk) generate
		uut: hash_two_clk_wrapper
		generic map ( algorithm => algorithm, hashsize => hashsize, iwidth => iwidth, owidth => owidth, pad_mode => pad_mode, fifo_mode => fifo_mode, fr => fr )
		port map (
			rst 	=> rst,
			clk 	=> clk,
			io_clk	=> io_clk,
			din			=> idata_delayed,
		    src_read	=> fifoin_read,
		    src_ready	=> fifoin_ready_selected,
		    dout		=> odata,
		    dst_write	=> fifoout_write,
		    dst_ready	=> fifoout_ready_selected
		);
	end generate;
	 -- =================== --
	 -- END OF PORT MAPPING --
	 -- =================== --


    -- ===========================================================
	-- ==================== DATA POPULATION ======================
	tb_readdata : PROCESS
   		VARIABLE 	line_data, errorMsg	: 	LINE;
		variable 	word_block 				:  	std_logic_vector(iwidth-1 downto 0) := (others=>'0');
		variable 	read_result				: 	boolean;
		variable	loop_enable				: 	std_logic := '1';
		variable	temp_read				: 	string(1 to 6);
		variable	valid_line				: 	boolean := true;
	BEGIN

		rst <= '1';	   		wait for 5*clk_period;
		rst <= '0';	   		wait for clk_period;

		-- read header
		while ( not endfile (datain_file)) and ( loop_enable = '1' ) loop
			if endfile (datain_file) then
				loop_enable := '0';
			end if;

			readline(datain_file, line_data);
			read(line_data, temp_read, read_result);
			if (temp_read = cons_len) then
				loop_enable := '0';
			end if;
		end loop;

		-- do operations in the falling edge of the io_clk
		wait for io_clk_period/2;

		while not endfile ( datain_file ) loop
			-- if the fifo is full, wait ...
			fifoin_write <= '1';
			if ( fifoin_full = '1' ) then
				fifoin_write <= '0';
				wait until fifoin_full <= '0';
				wait for io_clk_period/2; -- write in the rising edge
				fifoin_write <= '1';
			end if;

			hread( line_data, word_block, read_result );
			while (((read_result = false) or (valid_line = false)) and (not endfile( datain_file ))) loop
				readline(datain_file, line_data);
				read(line_data, temp_read, read_result);	-- read line header
				if ( temp_read = cons_msg or temp_read = cons_len) then
					valid_line := true;
					fifoin_write <= '1';
				else
					valid_line := false;
					fifoin_write <= '0';
				end if;
				hread( line_data, word_block, read_result );-- read data
				report "---------din:reading new line--------" severity error;
			end loop;
			ext_idata <= word_block;
	   		wait for io_clk_period;
		end loop;
		fifoin_write <= '0';
		wait;
	END PROCESS;
	-- ===========================================================


	-- ===========================================================
	-- =================== DATA VERIFICATION =====================
	tb_verifydata : PROCESS
		variable 	line_data, errorMsg	: 	LINE;
		variable 	word_block 			:  	std_logic_vector(owidth-1 downto 0) := (others=>'0');
		variable 	read_result			: 	boolean;
		variable	loop_enable 		: 	std_logic := '1';
		variable	temp_read			: 	string(1 to 5);
		variable 	valid_line			:	boolean := true;
		variable 	hash_count			: 	integer := 1;
		variable	word_count			: 	integer := 1;
		constant 	hash_words			: 	integer := hashsize/owidth;
	begin
		wait for 6*clk_period;
		-- read header
		while ( not endfile (dataout_file)) and ( loop_enable = '1' ) loop
			if endfile (dataout_file) then
				loop_enable := '0';
			end if;

			readline(dataout_file, line_data);
			read(line_data, temp_read);
			if (temp_read = cons_md) then
				loop_enable := '0';
			end if;
		end loop;

		while (not endfile (dataout_file) and valid_line and (not force_exit)) loop
			-- get data to compare
			hread( line_data, word_block, read_result );
			while (((read_result = false) or (valid_line = false)) and (not endfile( dataout_file ))) loop		   -- if false then read new line
				readline(dataout_file, line_data);
				read(line_data, temp_read, read_result);	-- read line header
				if ( temp_read /= cons_md ) then
					valid_line := false;
				else
					valid_line := true;
				end if;
				if ( temp_read = cons_eof ) then
					force_exit <= true;
				end if;
				hread( line_data, word_block, read_result );-- read data
			end loop;


			-- if the core is slow in outputing the digested message, wait ...
			if ( valid_line ) then
				fifoout_read <= '1';
				if ( fifoout_empty = '1') then
					fifoout_read <= '0';
					wait until fifoout_empty = '0';
					wait for io_clk_period/2;
					fifoout_read <= '1';
				end if;


				if fifo_mode=1 then	-- one_wait_state
					wait for io_clk_period; -- wait a cycle for data to come out
				end if;

				if ext_odata /= word_block then
					if ( simulation_pass = '0' ) then
						simulation_pass <= '1';
					end if;
					write (errorMsg, string'("Hash #"));
					write (errorMsg, integer'image(hash_count));
					write (errorMsg, string'(" Word #"));
					write (errorMsg,  integer'image(word_count));
					write(errorMsg, string'(" fails at "));
					write(errorMsg, now);
					writeline(log_file,errorMsg);
					report "---------Hash #"  & integer'image(hash_count) & " Word #" & integer'image(word_count) & " at " & time'image(now) & " fails --------" severity error;
				else
					report "---------Hash #"  & integer'image(hash_count) & " Word #" & integer'image(word_count) & " at " & time'image(now) & " passes --------" severity error;
				end if;
				word_count := word_count + 1;
				if ( word_count > hash_words ) then
					word_count := 1;
					hash_count := hash_count + 1;
				end if;


				if (fifo_mode=0) then	 -- zero_wait_state
					wait for io_clk_period; -- wait a cycle for data to come out
				end if;

			end if;
		end loop;

		fifoout_read <= '0';

		wait for io_clk_period;


		if ( simulation_pass = '1' ) then
			report "FAIL (1): SIMULATION FINISHED || Input/Output files :: " & ifile_name & "/" & ofile_name severity error;
			write(result_file, "fail");
		else
			report "PASS (0): SIMULATION FINISHED || Input/Output files :: " & ifile_name & "/" & ofile_name severity error;
			write(result_file, "pass");
		end if;
		stop_clock <= true;
	  	wait;
	end process;
	-- ===========================================================


	-- ===========================================================
	-- =================== Test MODE =====================
	input_test : process

	begin
		if test_mode = 1 or test_mode = 2 then
			wait until rising_edge( fifoin_read );
			wait for io_clk_period;
			stall_fifoin_empty <= '1';
			wait for io_clk_period*input_stall_cycles;
			stall_fifoin_empty <= '0';
		else
			wait;
		end if;
	end process;


	output_test : process

	begin
		if test_mode = 1 or test_mode = 3 then
			wait until rising_edge( fifoout_write );
			wait for io_clk_period;
			stall_fifoout_full <= '1';
			wait for io_clk_period*output_stall_cycles;
			stall_fifoout_full <= '0';
		else
			wait;
		end if;
	end process;


	invalid_param_check : process
		variable pad_pass, split_pass, algo_pass, interface_pass, fifo_pass, test_pass : integer := 0;
	begin
		if (( pad_mode /= pad ) and ( pad_mode /= nopad )) then
			pad_pass := 1;
		end if;
		if (( split_type /= no_split ) and ( split_type /= fixed_split ) and ( split_type /= random_split )) then
			split_pass := 1;
		end if;
		if ((interface_type /= one_clk) and (interface_type /= two_clk)) then
			interface_pass := 1;
		end if;
		if ((fifo_mode > 2) or (fifo_style > 1)) then
			fifo_pass := 1;
		end if;
		if (test_mode > 3) or (test_mode < 0) then
			test_pass := 1;
		end if;

		if ( pad_pass = 1 or split_pass = 1 or algo_pass = 1 or interface_pass = 1  or fifo_pass = 1 ) then
			if ( pad_pass = 1 ) then
				report "Invalid padding mode ==> "& pad_str &". Only pad or nopad mode is allowed." severity warning;
			end if;
			if ( split_pass = 1 ) then
				report "Invalid split type ==> " & split_str & ". Only no_split, fixed_split or random_split is allowed." severity warning;
			end if;
			if ( interface_pass = 1 ) then
				report	"Invalid interface type ==> " & interface_str & ". Valid interface types are one_clk or two_clk" severity warning;
			end if;
			if ( fifo_pass = 1 ) then
				report "Invalid fifo mode or fifo style" severity warning;
			end if;
			if ( test_pass = 1) then
				report "Invalid test mode (Only value between 0 and 3 is allowed!)" severity warning;
			end if;


			report "Invalid core parameters!! Please see above for the list." severity failure;
			global_stop <= '0';
		end if;
		wait;
	end process;


-- ================================================================
-- # This section is used for testing the tb without the core.
-- # Must comment below process in order to run the core properly.
-- # Valid signals that can be manipulated in the below process are the handshake signals from a hash core.
-- # They are -- fifoin_read, fifoout_empty
-- ================================================================
--	inputtest : process
--	begin
--		fifoin_read <= '1';
--		fifoout_empty <= '0';
--		wait;
--	end process;
END;
