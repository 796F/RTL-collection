 -- =====================================================================
-- Copyright © 2010-2011 by Cryptographic Engineering Research Group (CERG),
-- ECE Department, George Mason University
-- Fairfax, VA, U.S.A.
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;   
use ieee.numeric_std.all;
use work.sha3_pkg.all;	 
use work.groestl_pkg.all;	

-- Groestl ShiftRow  implemented as combinational function
-- possible generics values: hs = {GROESTL_DATA_SIZE_SMALL, GROESTL_DATA_SIZE_BIG} 
-- they are corresponding to 256 and 512 versions respectively

entity groestl_shiftrow is
generic (n	:integer := GROESTL_DATA_SIZE_SMALL);
port( 
	input 		: in std_logic_vector(n-1 downto 0);
    output 		: out std_logic_vector(n-1 downto 0));
end groestl_shiftrow;
  
architecture groestl_shiftrow of groestl_shiftrow is
begin	

gen256: if n=GROESTL_DATA_SIZE_SMALL generate

output <= 	input(511 downto 504) & input(439 downto 432) & input(367 downto 360) & input(295 downto 288) & 
			input(223 downto 216) & input(151 downto 144)  & input(79 downto 72) & input(7 downto 0) &
			input(447 downto 440) & input(375 downto 368) & input(303 downto 296) & input(231 downto 224) & 
			input(159 downto 152) & input(87 downto 80)  & input(15 downto 8) & input(455 downto 448) &
			input(383 downto 376) & input(311 downto 304) & input(239 downto 232) & input(167 downto 160) & 
			input(95 downto 88) & input(23 downto 16)  & input(463 downto 456) & input(391 downto 384) &
			input(319 downto 312) & input(247 downto 240) & input(175 downto 168) & input(103 downto 96) & 
			input(31 downto 24) & input(471 downto 464)  & input(399 downto 392) & input(327 downto 320) &
			input(255 downto 248) & input(183 downto 176) & input(111 downto 104) & input(39 downto 32) & 
			input(479 downto 472) & input(407 downto 400)  & input(335 downto 328) & input(263 downto 256) &
			input(191 downto 184) & input(119 downto 112) & input(47 downto 40) & input(487 downto 480) & 
			input(415 downto 408) & input(343 downto 336)  & input(271 downto 264) & input(199 downto 192) &
			input(127 downto 120) & input(55 downto 48) & input(495 downto 488) & input(423 downto 416) & 
			input(351 downto 344) & input(279 downto 272)  & input(207 downto 200) & input(135 downto 128) &
			input(63 downto 56) & input(503 downto 496) & input(431 downto 424) & input(359 downto 352) & 
			input(287 downto 280) & input(215 downto 208)  & input(143 downto 136) & input(71 downto 64);
end generate;


gen512: if n=GROESTL_DATA_SIZE_BIG generate

output <= 	input(1023 downto 1016) & input(951 downto 944) & input(879 downto 872) & input(807 downto 800) & input(735 downto 728) & input(663 downto 656) & input(591 downto 584) & input(263 downto 256) & 
			input(959 downto 952) & input(887 downto 880) & input(815 downto 808) & input(743 downto 736) & input(671 downto 664) & input(599 downto 592) & input(527 downto 520) & input(199 downto 192) &
			input(895 downto 888) & input(823 downto 816) & input(751 downto 744) & input(679 downto 672) & input(607 downto 600) & input(535 downto 528) & input(463 downto 456) & input(135 downto 128) & 
			input(831 downto 824) & input(759 downto 752) & input(687 downto 680) & input(615 downto 608) & input(543 downto 536) & input(471 downto 464) & input(399 downto 392) & input(71 downto 64) &
			input(767 downto 760) & input(695 downto 688) & input(623 downto 616) & input(551 downto 544) & input(479 downto 472) & input(407 downto 400) &	input(335 downto 328) &	input(7 downto 0) &	 	
			input(703 downto 696) & input(631 downto 624) & input(559 downto 552) & input(487 downto 480) & input(415 downto 408) & input(343 downto 336) & input(271 downto 264) & input(967 downto 960) & 
			input(639 downto 632) & input(567 downto 560) & input(495 downto 488) & input(423 downto 416) & input(351 downto 344) & input(279 downto 272) & input(207 downto 200) & input(903 downto 896) & 
			input(575 downto 568) & input(503 downto 496) & input(431 downto 424) & input(359 downto 352) & input(287 downto 280) & input(215 downto 208) & input(143 downto 136) & input(839 downto 832) & 
			input(511 downto 504) & input(439 downto 432) & input(367 downto 360) & input(295 downto 288) & input(223 downto 216) & input(151 downto 144) & input(79 downto 72) & input(775 downto 768) & 
			input(447 downto 440) & input(375 downto 368) & input(303 downto 296) & input(231 downto 224) & input(159 downto 152) & input(87 downto 80)  & input(15 downto 8) & input(711 downto 704) & 
			input(383 downto 376) & input(311 downto 304) & input(239 downto 232) & input(167 downto 160) & input(95 downto 88)   & input(23 downto 16) & input(975 downto 968)   & input(647 downto 640) & 
			input(319 downto 312) & input(247 downto 240) & input(175 downto 168) & input(103 downto 96)  & input(31 downto 24) & input(983 downto 976)   & input(911 downto 904) & input(583 downto 576) & 
			input(255 downto 248) & input(183 downto 176) & input(111 downto 104) & input(39 downto 32) & input(991 downto 984)   & input(919 downto 912) & input(847 downto 840) & input(519 downto 512) & 
			input(191 downto 184) & input(119 downto 112) & input(47 downto 40) & input(999 downto 992)   & input(927 downto 920) & input(855 downto 848) & input(783 downto 776) & input(455 downto 448) & 
			input(127 downto 120) & input(55 downto 48) & input(1007 downto 1000) & input(935 downto 928) & input(863 downto 856) & input(791 downto 784) & input(719 downto 712) & input(391 downto 384) & 
			input(63 downto 56) & input(1015 downto 1008) & input(943 downto 936) & input(871 downto 864) & input(799 downto 792) & input(727 downto 720) & input(655 downto 648) & input(327 downto 320);
end generate;


end groestl_shiftrow; 
