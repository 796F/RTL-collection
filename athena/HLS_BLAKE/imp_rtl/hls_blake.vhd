-------------------------------------------------------------------------------
--! @file       hls_blake.vhd
--! @brief      Top-level for HLS-based BLAKE
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
use ieee.std_logic_1164.all;

entity hls_blake is
    port (
        rst 	   : in  std_logic;
        clk 	   : in  std_logic;
        din		   : in  std_logic_vector(63 downto 0);
        src_read   : out std_logic;
        src_ready  : in  std_logic;
        dout	   : out std_logic_vector(63 downto 0);
        dst_write  : out std_logic;
        dst_ready  : in  std_logic
    );
end entity hls_blake;

architecture structure of hls_blake is
    constant BLOCKSIZE  : integer := 512;
    constant WORDSIZE   : integer := 32;
    constant HASHSIZE   : integer := 256;
    
    signal msg          : std_logic_vector(511 downto 0);
    signal msg_reg      : std_logic_vector(511 downto 0);    
    signal msg_write    : std_logic;
    signal msg_full_n   : std_logic;
    signal crypto_idle  : std_logic;
    signal crypto_ready : std_logic;
        
    signal last         : std_logic_vector(0 downto 0);
    signal size         : std_logic_vector(31 downto 0);
    
    signal hash         : std_logic_vector(255 downto 0);
    signal hash_ready   : std_logic;
    signal hash_read    : std_logic;
    
    signal msg2         : std_logic_vector(511 downto 0);
    signal msg_reg2     : std_logic_vector(511 downto 0);
    signal msg_in       : std_logic_vector(511 downto 0);
    signal hash2        : std_logic_vector(255 downto 0);
begin
    u_input_processor:
    entity work.fifo_interface_din(behav)
    port map (
        ap_clk      => clk,
        ap_rst      => rst,
        din_dout    => din,
        din_empty_n => src_ready,
        din_read    => src_read,
        msg_din     => msg,
        msg_write   => msg_write,
        msg_full_n  => msg_full_n,
        size        => size,
        last        => last
    );
    
    
    process(clk)
    begin
        if rising_edge( clk ) then                        
            msg_full_n <= crypto_idle or crypto_ready;
            
            if msg_write = '1' then
                msg_reg <= msg;
            end if;
        end if;
    end process;
    
    gen_m:
    for i in 0 to 15 generate
        msg2    (BLOCKSIZE-i*WORDSIZE-1 downto BLOCKSIZE-(i+1)*WORDSIZE) <= msg    ((i+1)*WORDSIZE-1 downto i*WORDSIZE);
        msg_reg2(BLOCKSIZE-i*WORDSIZE-1 downto BLOCKSIZE-(i+1)*WORDSIZE) <= msg_reg((i+1)*WORDSIZE-1 downto i*WORDSIZE);
    end generate;
    gen2:
    for i in 0 to 7 generate
        hash2(HASHSIZE-i*WORDSIZE-1 downto HASHSIZE-(i+1)*WORDSIZE) <= hash((i+1)*WORDSIZE-1 downto i*WORDSIZE);        
    end generate;
    
    msg_in <= msg2 when msg_write = '1' else msg_reg2;
    
    u_crypto_core:
    entity work.BLAKE32(behav)
    port map (
        ap_clk          => clk,
        ap_rst          => rst,
        ap_start        => msg_write,
        ap_done         => open,
        ap_idle         => crypto_idle,
        ap_ready        => crypto_ready,            
        data            => msg2,
        data_reg        => msg_reg2,
        
        output_r        => hash,
        output_r_ap_vld => hash_ready,
        output_r_ap_ack => hash_read,
        last            => last,
        size            => size    
    );
    
    u_output_processor:
    entity work.fifo_interface_dout(behav)
    port map (
        ap_clk          => clk,
        ap_rst          => rst,
        hash_dout       => hash2,
        hash_empty_n    => hash_ready,
        hash_read       => hash_read,
        dout_din        => dout,
        dout_full_n     => dst_ready,
        dout_write      => dst_write
    );
    
end architecture structure;