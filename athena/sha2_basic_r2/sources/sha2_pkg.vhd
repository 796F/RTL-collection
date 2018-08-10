-- =====================================================================
-- Copyright © 2010-11 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;   
use work.sha3_pkg.all;

package sha2_pkg is 	
	

constant DISTRIBUTED				: integer:=0; 
constant BRAM						: integer:=1; 
	
constant STATE_REG_NUM			: integer:=8;	
constant BLOCK_SIZE_512			: integer:=512;
constant BLOCK_SIZE_1024			: integer:=1024;

constant SHA2_WORDS_NUM			: integer := 16;

constant ARCH_32				: integer:=BLOCK_SIZE_512/SHA2_WORDS_NUM;
constant ARCH_64				: integer:=BLOCK_SIZE_1024/SHA2_WORDS_NUM;

constant HASH_BLOCKS_256		: integer:=HASH_SIZE_256/ARCH_32;
constant HASH_BLOCKS_512		: integer:=HASH_SIZE_512/ARCH_64;

constant LEN_BLOCKS				: integer:=2;

constant LOG_2_2				: integer:=1; -- the biggest number of hash blocks (3bits couter for 6,7,8 blocks) 
constant LOG_2_4				: integer:=2; -- the biggest number of hash blocks (3bits couter for 6,7,8 blocks) 
constant LOG_2_8				: integer:=3; -- the biggest number of hash blocks (3bits couter for 6,7,8 blocks) 
constant LOG_2_16				: integer:=4; -- the biggest number of hash blocks (3bits couter for 6,7,8 blocks) 
constant LOG_2_32				: integer:=5; -- the biggest number of hash blocks (3bits couter for 6,7,8 blocks) 
constant LOG_2_64				: integer:=6;  
constant LOG_2_80				: integer:=7;   
constant LOG_2_512				: integer:=9;   
constant LOG_2_1024				: integer:=10;   

constant ROUNDS_64				: integer:=64;
constant ROUNDS_80				: integer:=80;
constant ROUND_16				: integer:=16;
constant ROUND_17				: integer:=17;

constant ARCH32_CF0_1				: integer:=2;					
constant ARCH32_CF0_2				: integer:=13;					
constant ARCH32_CF0_3				: integer:=22;					
constant ARCH32_CF1_1				: integer:=6;					
constant ARCH32_CF1_2				: integer:=11;					
constant ARCH32_CF1_3				: integer:=25;					
constant ARCH32_MS0_1			: integer:=7;					
constant ARCH32_MS0_2			: integer:=18;					
constant ARCH32_MS0_3			: integer:=3;					
constant ARCH32_MS1_1			: integer:=17;					
constant ARCH32_MS1_2			: integer:=19;					
constant ARCH32_MS1_3			: integer:=10;	  

constant ARCH64_CF0_1				: integer:=28;					
constant ARCH64_CF0_2				: integer:=34;					
constant ARCH64_CF0_3				: integer:=39;					
constant ARCH64_CF1_1				: integer:=14;					
constant ARCH64_CF1_2				: integer:=18;					
constant ARCH64_CF1_3				: integer:=41;					
constant ARCH64_MS0_1			: integer:=1;					
constant ARCH64_MS0_2			: integer:=8;					
constant ARCH64_MS0_3			: integer:=7;					
constant ARCH64_MS1_1			: integer:=19;					
constant ARCH64_MS1_2			: integer:=61;					
constant ARCH64_MS1_3			: integer:=6;
				
constant SHA256_AINIT 			:std_logic_vector(ARCH_32-1 downto 0):= X"6a09e667"; 
constant SHA256_BINIT 			:std_logic_vector(ARCH_32-1 downto 0):= X"bb67ae85"; 
constant SHA256_CINIT 			:std_logic_vector(ARCH_32-1 downto 0):= X"3c6ef372"; 
constant SHA256_DINIT 			:std_logic_vector(ARCH_32-1 downto 0):= X"a54ff53a"; 
constant SHA256_EINIT 			:std_logic_vector(ARCH_32-1 downto 0):= X"510e527f"; 
constant SHA256_FINIT 			:std_logic_vector(ARCH_32-1 downto 0):= X"9b05688c"; 
constant SHA256_GINIT 			:std_logic_vector(ARCH_32-1 downto 0):= X"1f83d9ab"; 
constant SHA256_HINIT 			:std_logic_vector(ARCH_32-1 downto 0):= X"5be0cd19";   

constant SHA512_AINIT 			:std_logic_vector(ARCH_64-1 downto 0):= X"6a09e667f3bcc908";
constant SHA512_BINIT 			:std_logic_vector(ARCH_64-1 downto 0):= X"bb67ae8584caa73b";
constant SHA512_CINIT 			:std_logic_vector(ARCH_64-1 downto 0):= X"3c6ef372fe94f82b";
constant SHA512_DINIT 			:std_logic_vector(ARCH_64-1 downto 0):= X"a54ff53a5f1d36f1";
constant SHA512_EINIT 			:std_logic_vector(ARCH_64-1 downto 0):= X"510e527fade682d1";
constant SHA512_FINIT 			:std_logic_vector(ARCH_64-1 downto 0):= X"9b05688c2b3e6c1f";
constant SHA512_GINIT 			:std_logic_vector(ARCH_64-1 downto 0):= X"1f83d9abfb41bd6b";
constant SHA512_HINIT 			:std_logic_vector(ARCH_64-1 downto 0):= X"5be0cd19137e2179";

end sha2_pkg;



