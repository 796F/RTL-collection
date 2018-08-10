-- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.sha3_shabal_package.ALL;
use work.sha3_pkg.all;

entity shabal_compact_datapath is	  
	generic ( h : integer := 256 );
	port (
		-- external
		clk : in std_logic;					  
		rst : in std_logic;
		din : in std_logic_vector(31 downto 0);
		-- internal	in
		ctrl 		: in std_logic_vector(24 downto 0);	
		-- internal out
		zc0 		: out std_logic;		
		----------
		dout : out std_logic_vector(31 downto 0)		
		);
end shabal_compact_datapath;

architecture struct of shabal_compact_datapath is 	
	-- WW
	signal ww, ww_out  : std_logic_vector(31 downto 0);
	signal added_ww : std_logic_vector(32 downto 0);
	signal ww_carry : std_logic;
	-- MM		 
	signal mm_in, mm2_in, din_switch_endian : std_logic_vector(31 downto 0);
	signal mm : array_16x32;
	signal mm0 : std_logic_vector(31 downto 0);	 
	
	-- CC	  
	signal cc_in : std_logic_vector(31 downto 0);	  
	signal cc_pre_in : std_logic_vector(31 downto 0);	  
	signal cc_out, cc_out2 : std_logic_vector(31 downto 0);
	signal c_dram, c_shfreg : array_16x32;
		
	-- CP
	signal cp : array_12x32;				   
	signal a_or_c, cp_in : std_logic_vector(31 downto 0);
	signal cp0 : std_logic_vector(31 downto 0);
	
	-- BB
	signal bb : array_16x32;
	signal bmux1, bmux2, badd, bb_in : std_logic_vector(31 downto 0);
	signal bb0, bb_o1, bb_o2, bb_o3 : std_logic_vector(31 downto 0);
	
	-- AA	   
	signal aa : array_12x32;   
	signal cpp, aw, a_or_iv, aa_in : std_logic_vector(31 downto 0);
	signal aa0, aa11 : std_logic_vector(31 downto 0);
	
	-- calculation
	signal new_a, new_b : std_logic_vector(31 downto 0);
	signal c_minus_m : std_logic_vector(31 downto 0);	
	
	-- control in signals			  
	signal ein, sout : std_logic;	-- din dout
	signal lctr, ectr : std_logic;		-- word counter
	signal sm2, sm, em : std_logic; 	-- m
	signal sf, sfinal : std_logic; -- misc
	signal sb, eb : std_logic;			-- eb
	signal ec : std_logic; 			-- c	
	signal sacp, scp, ecp : std_logic; 	-- cp
	signal sw, ew, sw_add : std_logic; 	-- w
	signal sa, ea : std_logic; 			-- a		
	signal c_addr : std_logic_vector(3 downto 0); -- c
	signal ecd : std_logic;
	-- c counter
	signal c : std_logic_vector(22 downto 0);
	
	signal iv_b, iv_c, iv_a : std_logic_vector(31 downto 0);
	-- din, dout		 
	
	constant aiv : array_16x32 := get_a_iv_compact( h );
	constant biv : array_16x32 := get_b_iv( h );
	constant civ : array_16x32 := get_c_iv( h );
	
begin		
	-- control signals		
	ein 	<= ctrl(0);		ea		<= ctrl(1); 	sout <= ctrl(2);
	lctr 	<= ctrl(3); 	ectr 	<= ctrl(4);			
	sm2		<= ctrl(5);		sm		<= ctrl(6);		em	<= ctrl(7);
	sf		<= ctrl(8);		sfinal	<= ctrl(9);		
	sb		<= ctrl(10);	eb		<= ctrl(11);
							ec		<= ctrl(12);
	sacp 	<= ctrl(13); 	scp		<= ctrl(14);	ecp <= ctrl(15);
	sw	 	<= ctrl(16); 	ew		<= ctrl(17);	sw_add <= ctrl(18);
	sa		<= ctrl(19);	
	c_addr  <= ctrl(23 downto 20); ecd <= ctrl(24);  
	
	----------------
	-- din (reg ) --
	----------------
	din_switch_endian <= switch_endian_byte(din,32,32);

	----------					
	-- dout --
	----------	
	dout <= switch_endian_byte(bb0,32,32);
	
	
	--------------------
	-- word decounter --
	--------------------
	decounter_gen : entity work.decountern(struct) generic map ( N => 23, sub => 1 ) port map ( clk => clk, rst => rst, load => lctr, en => ectr, input => din(31 downto 9), output => c );
	zc0 <= '1' when c = 0 else '0';	 
	
	----------------
	-- m (shfreg) --		
	----------------	   
	c_minus_m <= cc_out2 - mm0; 		
	mm_in <= din_switch_endian when sm2 = '1' else mm0;
	mm2_in <= c_minus_m when sm = '1' else mm_in;			
	mm_shfreg_gen : process ( clk )
	begin
		if rising_edge(clk) then 
			if ( em = '1' ) then
				mm(15) <= mm2_in;
				for i in 0 to 14 loop
					mm(i) <= mm(i+1);
				end loop;
			end if;			
		end if;							
	end process;   
	mm0 <= mm(0);
	
	------------------
	--- b (shfreg) ---
	------------------	
	iv_b <= biv(conv_integer(c_addr));
	
	bmux1 <= iv_b when (sf = '1') else mm0;
	badd <= bmux1 + din_switch_endian;		
	bmux2 <= cc_out when sfinal = '1' else badd;
	bb_in <= rolx(bmux2,17) when sb = '1' else new_b;									  
	bb_shfreg_gen : process ( clk )
	begin
		if rising_edge( clk ) then
			if ( eb = '1' ) then
				bb(15) <= bb_in;
				for i in 0 to 14 loop
					bb(i) <= bb(i+1);
				end loop;
			end if;
		end if;
	end process; 
	bb0 <= bb(0);
	bb_o1 <= bb(o1);
	bb_o2 <= bb(o2);
	bb_o3 <= bb(o3);		   	
						
	------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------
	-- C 	
	--------------
	-- c (shf) --
	--------------	  
	iv_c <= civ(conv_integer(c_addr));
	cc_pre_in <= iv_c when sf = '1' else bb0;
	cc_in <= cc_pre_in when ecd = '1' else cc_out2;
	c_shfgen : process ( clk )
	begin
		if rising_edge( clk ) then
			if ( ec = '1' ) then
				c_shfreg(15) <= cc_in;
				for i in 0 to 14 loop
					c_shfreg(i) <= c_shfreg(i+1);
				end loop;
			end if;
		end if;
	end process; 
	cc_out2 <= c_shfreg(0);
	
	--------------
	-- c (dram) --
	--------------
	cdram_gen : process (clk)
	begin
		if rising_edge(clk) then				
			if (ecd = '1') then
				c_dram(conv_integer(unsigned(c_addr))) <= cc_in;
			end if;				
		end if;
	end process;											   
	cc_out <= c_dram(conv_integer(unsigned(c_addr)));
	------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------
	
	------------------
	-- cp (shfreg ) --
	------------------						   
	a_or_c <= aa0 when sacp = '1' else cc_out2;
	cpp <= cp0 + a_or_c;
	cp_in <= (others => '0') when scp = '1' else cpp;
	cp_shfreg_gen : process ( clk )
	begin
		if rising_edge( clk ) then
			if ( ecp = '1' ) then
				cp(11) <= cp_in;
				for i in 0 to 10 loop
					cp(i) <= cp(i+1);
				end loop;
			end if;
		end if;
	end process; 
	cp0 <= cp(0);
	
	------------------
	-- w counter	  
	------------------
	shfreg_w : entity work.shfreg(debug) generic map ( width => 32, depth => 2 ) port map ( clk => clk, en => ew, i => ww, o => ww_out );			
	ww <= added_ww(31 downto 0) when sw = '1' else (others => '0');
	ww_cgen : process ( clk )
	begin
		if rising_edge(clk) then 
			ww_carry <= added_ww(32);			
		end if;
	end process;						  	
	added_ww <= ('0' & ww_out ) + (sw_add or ww_carry);

	----------------
	-- a (shfreg) --		
	---------------- 
	iv_a <= aiv(conv_integer(c_addr));
	a_or_iv	<= iv_a when sf = '1' else cpp;
	aw <= a_or_iv xor ww;
	aa_in <= aw when sa = '1' else new_a; 	
	aa_shfreg_gen : process ( clk )
	begin
		if rising_edge( clk ) then
			if ( ea = '1' ) then
				aa(11) <= aa_in;
				for i in 0 to 10 loop
					aa(i) <= aa(i+1);
				end loop;
			end if;
		end if;
	end process;
	aa0 <= aa(0);
	aa11 <= aa(11);
	
	-----------------
	-- calculation --
	-----------------
	calc_gen : entity work.shabal_calc(struct) 
		port map (	a0 => aa0, a11 => aa11, c8 => cc_out, m0 => mm0,
					b0 => bb0,  bo1 => bb_o1, bo2 => bb_o2,
					bo3 => bb_o3, new_a => new_a, new_b => new_b);
				
	
end struct;