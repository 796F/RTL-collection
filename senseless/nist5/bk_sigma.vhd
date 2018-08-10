--  
-- Copyright (c) 2018 Allmine Inc
--

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
library work;
    use work.bk_globals.all;

entity bk_sigma is

port (  clk :     in  std_logic;
        round_w : in  std_logic_vector(3 downto 0);
        msg:      in  std_logic_vector(1023 downto 0);
        sigma:    out std_logic_vector(1023 downto 0)
     );
end bk_sigma;

    
architecture rtl of bk_sigma is
    
    ----------------------------------------------------------------------------
    -- Internal signal declarations
    ----------------------------------------------------------------------------
	component bk_reg 
	port (  clk     : in  std_logic;
			st_in   : in  std_logic_vector(1023 downto 0);
			st_out  : out std_logic_vector(1023 downto 0)
		 );
	end component;

    signal sigma_i : std_logic_vector(1023 downto 0);
    signal msg0  : std_logic_vector(63 downto 0);
    signal msg1  : std_logic_vector(63 downto 0);
    signal msg2  : std_logic_vector(63 downto 0);
    signal msg3  : std_logic_vector(63 downto 0);
    signal msg4  : std_logic_vector(63 downto 0);
    signal msg5  : std_logic_vector(63 downto 0);
    signal msg6  : std_logic_vector(63 downto 0);
    signal msg7  : std_logic_vector(63 downto 0);
    signal msg8  : std_logic_vector(63 downto 0);
    signal msg9  : std_logic_vector(63 downto 0);
    signal msg10 : std_logic_vector(63 downto 0);
    signal msg11 : std_logic_vector(63 downto 0);
    signal msg12 : std_logic_vector(63 downto 0);
    signal msg13 : std_logic_vector(63 downto 0);
    signal msg14 : std_logic_vector(63 downto 0);
    signal msg15 : std_logic_vector(63 downto 0);
    signal sigma0  : std_logic_vector(63 downto 0);
    signal sigma1  : std_logic_vector(63 downto 0);
    signal sigma2  : std_logic_vector(63 downto 0);
    signal sigma3  : std_logic_vector(63 downto 0);
    signal sigma4  : std_logic_vector(63 downto 0);
    signal sigma5  : std_logic_vector(63 downto 0);
    signal sigma6  : std_logic_vector(63 downto 0);
    signal sigma7  : std_logic_vector(63 downto 0);
    signal sigma8  : std_logic_vector(63 downto 0);
    signal sigma9  : std_logic_vector(63 downto 0);
    signal sigma10 : std_logic_vector(63 downto 0);
    signal sigma11 : std_logic_vector(63 downto 0);
    signal sigma12 : std_logic_vector(63 downto 0);
    signal sigma13 : std_logic_vector(63 downto 0);
    signal sigma14 : std_logic_vector(63 downto 0);
    signal sigma15 : std_logic_vector(63 downto 0);
    signal C0  : std_logic_vector(63 downto 0);
    signal C1  : std_logic_vector(63 downto 0);
    signal C2  : std_logic_vector(63 downto 0);
    signal C3  : std_logic_vector(63 downto 0);
    signal C4  : std_logic_vector(63 downto 0);
    signal C5  : std_logic_vector(63 downto 0);
    signal C6  : std_logic_vector(63 downto 0);
    signal C7  : std_logic_vector(63 downto 0);
    signal C8  : std_logic_vector(63 downto 0);
    signal C9  : std_logic_vector(63 downto 0);
    signal C10 : std_logic_vector(63 downto 0);
    signal C11 : std_logic_vector(63 downto 0);
    signal C12 : std_logic_vector(63 downto 0);
    signal C13 : std_logic_vector(63 downto 0);
    signal C14 : std_logic_vector(63 downto 0);
    signal C15 : std_logic_vector(63 downto 0);

begin  -- Rtl
    
    sigma_i <= sigma0 & sigma1 & sigma2 & sigma3 & sigma4 & sigma5 & sigma6 & sigma7 & sigma8 & sigma9 & sigma10 & sigma11 & sigma12 & sigma13 & sigma14 & sigma15;
    sigmar_i : bk_reg
        port map(   clk,
                    sigma_i,
                    sigma
                );

    msg0  <= msg(1023 downto 960);
    msg1  <= msg( 959 downto 896);
    msg2  <= msg( 895 downto 832);
    msg3  <= msg( 831 downto 768);
    msg4  <= msg( 767 downto 704);
    msg5  <= msg( 703 downto 640);
    msg6  <= msg( 639 downto 576);
    msg7  <= msg( 575 downto 512);
    msg8  <= msg( 511 downto 448);
    msg9  <= msg( 447 downto 384);
    msg10 <= msg( 383 downto 320);
    msg11 <= msg( 319 downto 256);
    msg12 <= msg( 255 downto 192);
    msg13 <= msg( 191 downto 128);
    msg14 <= msg( 127 downto  64);
    msg15 <= msg(  63 downto   0);

    C0  <= const_t(1023 downto 960);
    C1  <= const_t( 959 downto 896);
    C2  <= const_t( 895 downto 832);
    C3  <= const_t( 831 downto 768);
    C4  <= const_t( 767 downto 704);
    C5  <= const_t( 703 downto 640);
    C6  <= const_t( 639 downto 576);
    C7  <= const_t( 575 downto 512);
    C8  <= const_t( 511 downto 448);
    C9  <= const_t( 447 downto 384);
    C10 <= const_t( 383 downto 320);
    C11 <= const_t( 319 downto 256);
    C12 <= const_t( 255 downto 192);
    C13 <= const_t( 191 downto 128);
    C14 <= const_t( 127 downto  64);
    C15 <= const_t(  63 downto   0);
    
    process (round_w, C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15, msg0, msg1, msg2, msg3, msg4, msg5, msg6, msg7, msg8, msg9, msg10, msg11, msg12, msg13, msg14, msg15)
    begin
    case round_w is
        when "0000" =>
            sigma0  <= msg14 xor C15 xor C10;
            sigma1  <= msg10 xor C11 xor C14;
            sigma2  <= msg4  xor C5  xor C8 ;
            sigma3  <= msg8  xor C9  xor C4 ;
            sigma4  <= msg9  xor C8  xor C15;
            sigma5  <= msg15 xor C14 xor C9 ;
            sigma6  <= msg13 xor C12 xor C6 ;
            sigma7  <= msg6  xor C7  xor C13;
            sigma8  <= msg1  xor C0  xor C12;
            sigma9  <= msg12 xor C13 xor C1 ;
            sigma10 <= msg0  xor C1  xor C2 ;
            sigma11 <= msg2  xor C3  xor C0 ;
            sigma12 <= msg11 xor C10 xor C7 ;
            sigma13 <= msg7  xor C6  xor C11;
            sigma14 <= msg5  xor C4  xor C3 ;
            sigma15 <= msg3  xor C2  xor C5 ;
        when "0001" =>
            sigma0  <= msg12 xor C7  xor C8 ;
            sigma1  <= msg3  xor C4  xor C11;
            sigma2  <= msg9  xor C1  xor C0 ;
            sigma3  <= msg10 xor C2  xor C12; 
            sigma4  <= msg14 xor C3  xor C2 ;
            sigma5  <= msg11 xor C0  xor C5 ;
            sigma6  <= msg5  xor C9  xor C13;
            sigma7  <= msg6  xor C6  xor C15;
            sigma8  <= msg1  xor C14 xor C14;
            sigma9  <= msg0  xor C10 xor C10;
            sigma10 <= msg15 xor C5  xor C6 ;
            sigma11 <= msg7  xor C13 xor C3 ;
            sigma12 <= msg13 xor C11 xor C1 ;
            sigma13 <= msg8  xor C12 xor C7 ;
            sigma14 <= msg4  xor C15 xor C4 ;
            sigma15 <= msg2  xor C8  xor C9 ;
        when "0010" =>
            sigma0  <= msg12 xor C1  xor C9 ;
            sigma1  <= msg14 xor C4  xor C7 ;
            sigma2  <= msg10 xor C6  xor C1 ;
            sigma3  <= msg13 xor C7  xor C3 ;
            sigma4  <= msg7  xor C15 xor C12;
            sigma5  <= msg2  xor C0  xor C13;
            sigma6  <= msg0  xor C8  xor C14;
            sigma7  <= msg9  xor C10 xor C11;
            sigma8  <= msg5  xor C5  xor C6 ;
            sigma9  <= msg11 xor C3  xor C2 ;
            sigma10 <= msg4  xor C2  xor C10;
            sigma11 <= msg8  xor C14 xor C5 ;
            sigma12 <= msg15 xor C9  xor C0 ;
            sigma13 <= msg3  xor C12 xor C4 ;
            sigma14 <= msg6  xor C13 xor C8 ;
            sigma15 <= msg1  xor C11 xor C15;
        when "0011" =>
            sigma0  <= msg1  xor C7  xor C0 ;
            sigma1  <= msg13 xor C4  xor C9 ;
            sigma2  <= msg10 xor C10 xor C7 ;
            sigma3  <= msg0  xor C9  xor C5 ;
            sigma4  <= msg8  xor C6  xor C4 ;
            sigma5  <= msg12 xor C0  xor C2 ;
            sigma6  <= msg11 xor C5  xor C15;
            sigma7  <= msg14 xor C8  xor C10;
            sigma8  <= msg7  xor C11 xor C1 ;
            sigma9  <= msg3  xor C3  xor C14;
            sigma10 <= msg6  xor C14 xor C12;
            sigma11 <= msg5  xor C13 xor C11;
            sigma12 <= msg9  xor C2  xor C8 ;
            sigma13 <= msg15 xor C15 xor C6 ;
            sigma14 <= msg2  xor C1  xor C13;
            sigma15 <= msg4  xor C12 xor C3 ;
        when "0100" =>
            sigma0  <= msg4  xor C4  xor C12;
            sigma1  <= msg11 xor C11 xor C2 ;
            sigma2  <= msg12 xor C8  xor C10;
            sigma3  <= msg6  xor C15 xor C6 ;
            sigma4  <= msg1  xor C9  xor C11;
            sigma5  <= msg10 xor C12 xor C0 ;
            sigma6  <= msg13 xor C6  xor C3 ;
            sigma7  <= msg14 xor C13 xor C8 ;
            sigma8  <= msg5  xor C2  xor C13;
            sigma9  <= msg15 xor C3  xor C4 ;
            sigma10 <= msg3  xor C5  xor C5 ;
            sigma11 <= msg2  xor C7  xor C7 ;
            sigma12 <= msg7  xor C10 xor C14;
            sigma13 <= msg8  xor C1  xor C15;
            sigma14 <= msg9  xor C14 xor C9 ;
            sigma15 <= msg0  xor C0  xor C1 ;
        when "0101" =>
            sigma0  <= msg1  xor C2  xor C5 ;
            sigma1  <= msg11 xor C7  xor C12;
            sigma2  <= msg14 xor C9  xor C15;
            sigma3  <= msg12 xor C14 xor C1 ;
            sigma4  <= msg13 xor C15 xor C13;
            sigma5  <= msg9  xor C4  xor C14;
            sigma6  <= msg8  xor C13 xor C10;
            sigma7  <= msg3  xor C6  xor C4 ;
            sigma8  <= msg4  xor C11 xor C7 ;
            sigma9  <= msg10 xor C5  xor C0 ;
            sigma10 <= msg2  xor C10 xor C3 ;
            sigma11 <= msg7  xor C8  xor C6 ;
            sigma12 <= msg15 xor C1  xor C2 ;
            sigma13 <= msg0  xor C12 xor C9 ;
            sigma14 <= msg6  xor C3  xor C11;
            sigma15 <= msg5  xor C0  xor C8 ;
        when "0110" =>
            sigma0  <= msg5  xor C14 xor C11;
            sigma1  <= msg15 xor C8  xor C13;
            sigma2  <= msg9  xor C0  xor C14;
            sigma3  <= msg4  xor C13 xor C7 ;
            sigma4  <= msg0  xor C5  xor C1 ;
            sigma5  <= msg2  xor C15 xor C12;
            sigma6  <= msg11 xor C6  xor C9 ;
            sigma7  <= msg12 xor C2  xor C3 ;
            sigma8  <= msg1  xor C12 xor C0 ;
            sigma9  <= msg8  xor C7  xor C5 ;
            sigma10 <= msg3  xor C1  xor C4 ;
            sigma11 <= msg6  xor C10 xor C15;
            sigma12 <= msg14 xor C11 xor C6 ;
            sigma13 <= msg10 xor C3  xor C8 ;
            sigma14 <= msg13 xor C9  xor C10;
            sigma15 <= msg7  xor C4  xor C2 ;
        when "0111" =>
            sigma0  <= msg13 xor C8  xor C15;
            sigma1  <= msg10 xor C4  xor C6 ;
            sigma2  <= msg3  xor C7  xor C9 ;
            sigma3  <= msg7  xor C3  xor C14;
            sigma4  <= msg1  xor C13 xor C3 ;
            sigma5  <= msg6  xor C9  xor C11;
            sigma6  <= msg9  xor C5  xor C8 ;
            sigma7  <= msg12 xor C6  xor C0 ;
            sigma8  <= msg4  xor C1  xor C2 ;
            sigma9  <= msg14 xor C10 xor C12;
            sigma10 <= msg0  xor C11 xor C7 ;
            sigma11 <= msg2  xor C14 xor C13;
            sigma12 <= msg5  xor C12 xor C4 ;
            sigma13 <= msg11 xor C15 xor C1 ;
            sigma14 <= msg15 xor C2  xor C5 ;
            sigma15 <= msg8  xor C0  xor C10;
        when "1000" =>
            sigma0  <= msg14 xor C5  xor C2 ;
            sigma1  <= msg9  xor C12 xor C10;
            sigma2  <= msg7  xor C0  xor C4 ;
            sigma3  <= msg13 xor C1  xor C8 ;
            sigma4  <= msg11 xor C13 xor C6 ;
            sigma5  <= msg0  xor C15 xor C7 ;
            sigma6  <= msg12 xor C4  xor C5 ;
            sigma7  <= msg15 xor C10 xor C1 ;
            sigma8  <= msg1  xor C6  xor C11;
            sigma9  <= msg4  xor C3  xor C15;
            sigma10 <= msg3  xor C14 xor C14;
            sigma11 <= msg2  xor C9  xor C9 ;
            sigma12 <= msg5  xor C11 xor C12;
            sigma13 <= msg8  xor C2  xor C3 ;
            sigma14 <= msg10 xor C7  xor C0 ;
            sigma15 <= msg6  xor C8  xor C13;
        when "1001" =>
            sigma0  <= msg15 xor C13 xor C1 ;
            sigma1  <= msg6  xor C5  xor C0 ;
            sigma2  <= msg1  xor C10 xor C3 ;
            sigma3  <= msg12 xor C12 xor C2 ;
            sigma4  <= msg3  xor C8  xor C5 ;
            sigma5  <= msg7  xor C1  xor C4 ;
            sigma6  <= msg5  xor C7  xor C7 ;
            sigma7  <= msg4  xor C6  xor C6 ;
            sigma8  <= msg2  xor C4  xor C9 ;
            sigma9  <= msg10 xor C14 xor C8 ;
            sigma10 <= msg0  xor C2  xor C11;
            sigma11 <= msg9  xor C15 xor C10;
            sigma12 <= msg13 xor C3  xor C13;
            sigma13 <= msg14 xor C0  xor C12;
            sigma14 <= msg11 xor C9  xor C15;
            sigma15 <= msg8  xor C11 xor C14;
        when others =>
            sigma0  <= X"0000000000000000";
            sigma1  <= X"0000000000000000";
            sigma2  <= X"0000000000000000";
            sigma3  <= X"0000000000000000";
            sigma4  <= X"0000000000000000";
            sigma5  <= X"0000000000000000";
            sigma6  <= X"0000000000000000";
            sigma7  <= X"0000000000000000";
            sigma8  <= X"0000000000000000";
            sigma9  <= X"0000000000000000";
            sigma10 <= X"0000000000000000";
            sigma11 <= X"0000000000000000";
            sigma12 <= X"0000000000000000";
            sigma13 <= X"0000000000000000";
            sigma14 <= X"0000000000000000";
            sigma15 <= X"0000000000000000";
    end case;
    end process;

end rtl;
