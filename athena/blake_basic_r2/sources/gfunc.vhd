-- =========================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =========================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;		
use work.sha3_pkg.all;
use work.sha3_blake_package.all;


entity gfunc_modified is
	generic ( 	iw : integer := 32; 
				h : integer := 256; 
				ADDER_TYPE : integer := SCCA_BASED );
	port(
		ain : in std_logic_vector(iw-1 downto 0);
		bin : in  std_logic_vector(iw-1 downto 0);
      	cin : in  std_logic_vector(iw-1 downto 0);
      	din : in  std_logic_vector(iw-1 downto 0);      
		const_0 : in  std_logic_vector(iw-1 downto 0);	
		const_1 : in  std_logic_vector(iw-1 downto 0);
      	aout : out std_logic_vector(iw-1 downto 0);
      	bout : out std_logic_vector(iw-1 downto 0);
      	cout : out std_logic_vector(iw-1 downto 0);
      	dout : out std_logic_vector(iw-1 downto 0)
		);		 
end gfunc_modified;

--}} end of automatically maintained section

architecture struct of gfunc_modified is
	signal csa_a1_1, csa_a1_2, csa_a2_1, csa_a2_2 : std_logic_vector(iw-1 downto 0);

	signal  D_hold2, D_hold3     :   STD_LOGIC_VECTOR(iw-1 downto 0);
	signal  hold_D1, hold_B2     :   STD_LOGIC_VECTOR(iw-1 downto 0);
	signal  hold_B1, hold_D2              :   STD_LOGIC_VECTOR(iw-1 downto 0);
	signal  D_hold5, D_hold6              :   STD_LOGIC_VECTOR(iw-1 downto 0);
	signal  hold_A1,  hold_C1             :   std_logic_vector (iw-1 downto 0); 
	signal  hold_A2, hold_C2	          :   std_logic_vector (iw-1 downto 0);
begin 
	
	D_hold2 <= din xor hold_A1;					 
	hold_C1 <= hold_D1+ cin;
	D_hold3 <= hold_C1 xor bin;
	
	D_hold5 <= hold_A2 xor hold_D1;
	hold_C2 <= hold_C1 + hold_D2;
	D_hold6 <= hold_C2 xor hold_B1;
	
	-- output data
	aout   <= hold_A2;
	bout   <= hold_B2;
	cout   <= hold_C2;
	dout   <= hold_D2;
	
	SCCA_BASED_GEN : if ADDER_TYPE = SCCA_BASED generate
		hold_A1 <= const_0 + ain + bin;
		hold_A2 <= const_1 + hold_A1 + hold_B1;
	end generate;
	CSA_BASED_GEN : if ADDER_TYPE = CSA_BASED generate
		csa_a1 : csa generic map ( n => iw ) port map ( a => const_0, b => ain, cin => bin, s => csa_a1_1,cout => csa_a1_2);
		csa_a2 : csa generic map ( n => iw ) port map ( a => const_1, b => hold_A1, cin => hold_B1, s => csa_a2_1,cout => csa_a2_2);
		
		hold_A1 <= csa_a1_1 + (csa_a1_2(iw-2 downto 0) & '0');
		hold_A2 <= csa_a2_1 + (csa_a2_2(iw-2 downto 0) & '0');
	end generate;
	
	arch_32 : if h <= 256 generate
		hold_d1 <= rolx(D_hold2, 32-g_rot_arch32(0));
		hold_B1 <= rolx(D_hold3, 32-g_rot_arch32(1));
		hold_D2 <= rolx(D_hold5, 32-g_rot_arch32(2));
		hold_B2 <= rolx(D_hold6, 32-g_rot_arch32(3));
	end generate;
	
	arch_64 : if h > 256 generate
		hold_d1 <= rolx(D_hold2, 64-g_rot_arch64(0));
		hold_B1 <= rolx(D_hold3, 64-g_rot_arch64(1));
		hold_D2 <= rolx(D_hold5, 64-g_rot_arch64(2));
		hold_B2 <= rolx(D_hold6, 64-g_rot_arch64(3));
	end generate;	
end struct;
