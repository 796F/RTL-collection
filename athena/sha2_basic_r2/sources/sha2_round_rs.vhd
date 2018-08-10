-- =====================================================================
-- Copyright © 2010-11 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 
use work.sha3_pkg.all;
use work.sha2_pkg.all;

entity sha2_round_rs is
generic( n : integer :=HASH_SIZE_256/SHA2_WORDS_NUM);
port(	 
	sel_gh		:in std_logic;	 
	kw		:in std_logic_vector(n-1 downto 0);
	kwire		:in std_logic_vector(n-1 downto 0);
   	wwire		:in std_logic_vector(n-1 downto 0);	
	ain		:in std_logic_vector(n-1 downto 0);
	bin		:in std_logic_vector(n-1 downto 0);
	cin		:in std_logic_vector(n-1 downto 0);
	din		:in std_logic_vector(n-1 downto 0);
	ein		:in std_logic_vector(n-1 downto 0);
	fin		:in std_logic_vector(n-1 downto 0);
	gin		:in std_logic_vector(n-1 downto 0);
	hin		:in std_logic_vector(n-1 downto 0);	  
	kwhwire		:out std_logic_vector(n-1 downto 0);
	aout		:out std_logic_vector(n-1 downto 0);
	bout		:out std_logic_vector(n-1 downto 0);
	cout		:out std_logic_vector(n-1 downto 0);
	dout		:out std_logic_vector(n-1 downto 0);
	eout		:out std_logic_vector(n-1 downto 0);
	fout		:out std_logic_vector(n-1 downto 0);
	gout		:out std_logic_vector(n-1 downto 0);
	hout		:out std_logic_vector(n-1 downto 0));
end sha2_round_rs;

architecture basic of sha2_round_rs	is	
	signal	cf0_reg	: std_logic_vector(n-1 downto 0);
	signal	cf1_reg	: std_logic_vector(n-1 downto 0);
	signal	ch_reg		: std_logic_vector(n-1 downto 0);
	signal	maj_reg		: std_logic_vector(n-1 downto 0);	
	signal g_or_h				:std_logic_vector(n-1 downto 0);	


begin 	   	

a32: if n=HASH_SIZE_256/STATE_REG_NUM generate	
s0		: entity work.sha2_sigma_func(sha2_sigma_func) 	generic map (n=>n, func=>"cf", a=>ARCH32_CF0_1, b=>ARCH32_CF0_2, c=>ARCH32_CF0_3) port map (x=>ain, o=>CF0_reg);	
s1		: entity work.sha2_sigma_func(sha2_sigma_func) 	generic map (n=>n, func=>"cf", a=>ARCH32_CF1_1, b=>ARCH32_CF1_2, c=>ARCH32_CF1_3) port map (x=>ein, o=>CF1_reg);	 
end generate;

a64: if n=HASH_SIZE_512/STATE_REG_NUM generate	
s0		: entity work.sha2_sigma_func(sha2_sigma_func) 	generic map (n=>n, func=>"cf", a=>ARCH64_CF0_1, b=>ARCH64_CF0_2, c=>ARCH64_CF0_3) port map (x=>ain, o=>CF0_reg);	
s1		: entity work.sha2_sigma_func(sha2_sigma_func) 	generic map (n=>n, func=>"cf", a=>ARCH64_CF1_1, b=>ARCH64_CF1_2, c=>ARCH64_CF1_3) port map (x=>ein, o=>CF1_reg);	 
end generate;


	c1		: entity work.sha2_ch_func(sha2_ch_func)		generic map (n=>n) port map (x=>ein, y=>fin, z=>gin, o=>ch_reg);	
	m1		: entity work.sha2_maj_func(sha2_maj_func)	generic map (n=>n) port map (x=>ain, y=>bin, z=>cin, o=>maj_reg);
		
	eout <= ch_reg + cf1_reg + kw + din;

	aout <= kw + maj_reg + cf0_reg + ch_reg +cf1_reg; 	
	
	g_or_h <= hin when sel_gh='1' else gin;

	kwhwire <= g_or_h + kwire + wwire;
	 
		bout <= ain;
		cout <= bin;
		dout <= cin;
		fout <= ein;
		gout <= fin;
		hout <= gin;
		
end basic;	

