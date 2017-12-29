----------------------------------------------------------------------------------
-- top module for the Z1013 mist project
-- 
-- Copyright (c) 2017 by Bert Lange
-- https://github.com/boert/Z1013-mist
-- 
-- This source file is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published
-- by the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This source file is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library mist;
use mist.mist_components.osd;
use mist.mist_components.sdram;
use mist.mist_components.user_io;
use mist.mist_components.data_io;

library support;
library overlay;


entity top_mist is
    port (
        -- system
        clk_27                    : in    std_logic_vector(1 downto 0);     -- clk 12, clk 13
        reset_n                   : in    std_logic;                        -- clk 6, pin 89, really?

        -- basic input
        -- no inputs

        -- basic output
        led_yellow_n              : out   std_logic;                        -- io 7 
        test_point_tp1            : out   std_logic;                        -- io 33, was sdram_cke on prototype
                                                                           
        -- basic communication                                             
        uart_rx                   : in    std_logic;                        -- io 31
        uart_tx                   : inout std_logic;                        -- io 46

        -- dRAM pin connections
        dram_dq                   : inout std_logic_vector(15 downto 0);    -- io 104, 103, 101, 100, 99, 98, 87, 86, 68, 69, 71, 72, 76, 77, 79, 83
        dram_a                    : out   std_logic_vector(12 downto 0);    -- io 32, 30, 50, 28, 11, 10, 8, 6, 4, 39, 42, 44, 49 
        dram_clk                  : out   std_logic;                        -- io 43
        dram_we_n                 : out   std_logic;                        -- io 66
        dram_cas_n                : out   std_logic;                        -- io 64
        dram_ras_n                : out   std_logic;                        -- io 60
        dram_cs_n                 : out   std_logic;                        -- io 59
        dram_dqm                  : out   std_logic_vector(1 downto 0);     -- io 85, 67
        dram_ba                   : out   std_logic_vector(1 downto 0);     -- io 51, 58

        -- vga out signals
        vga_red                   : out   std_logic_vector(5 downto 0);     -- io 144, 143, 142, 141, 137, 135
        vga_green                 : out   std_logic_vector(5 downto 0);     -- io 114, 113, 112, 111, 110, 106
        vga_blue                  : out   std_logic_vector(5 downto 0);     -- io 133, 132, 125, 121, 120, 115
        vga_hsync                 : out   std_logic;                        -- io 119
        vga_vsync                 : out   std_logic;                        -- io 136
    
        -- audio
        audior                    : out   std_logic;                         -- io 80
        audiol                    : out   std_logic;                         -- io 65

        -- SPI interface to ARM io controller
        spi_do                    : out   std_logic;
        spi_di                    : in    std_logic;
        spi_sck                   : in    std_logic;
        spi_ss2                   : in    std_logic;
        spi_ss3                   : in    std_logic;
        spi_ss4                   : in    std_logic;
        conf_data0                : in    std_logic
    );
end entity top_mist;


architecture rtl of top_mist is

    ------------------------------------------------------------
    -- helper function
    -- convert string to a long logic vector
    --
    function string_to_slv ( str : string) return std_logic_vector is
        variable result   : std_logic_vector( 1 to 8 * str'length);
        variable position : integer; 
        variable char     : integer; 
    begin 
        for i in str'range loop
            position := 8 * i;
            char     := character'pos( str( i));
            result(position - 7 to position) := std_logic_vector( to_unsigned( char, 8)); 
        end loop; 
        return result;
    end function string_to_slv;

    
    ------------------------------------------------------------
    -- configuration string for osd
    --   field separator: ,
    --   line separator: ;
    --   forbidden symbols: / 
    --
    constant config_str   : string(1 to 109) := 
        "Z1013.16;" &   -- soc name
        "Z80;" &        -- extension for image files, attn: upper case
        "O2,Scanlines,On,Off;" & 
        "O3,Keyboard,en,de;" & 
        "O4,Online help,Off,On;" &
        "O5,Color scheme,bk/wt,bl/yl;" & 
        "T1,Reset";
        -- O = option
        -- T = toggle

    -- named bit numbers
    constant reset_bit    : natural := 1;
    constant scanline_bit : natural := 2;
    constant keyboard_bit : natural := 3;
    constant help_bit     : natural := 4;
    constant color_bit    : natural := 5;

    
    ------------------------------------------------------------
    -- signal declarations
    --
    signal sys_reset_n            : std_logic;
    signal sys_reset              : std_logic               := '1';
    signal reset_counter          : natural range 0 to 255  := 255;
    --                            
    signal debug_data             : std_logic_vector(7 downto 0);
    signal debug_addr             : std_logic_vector(15 downto 0);
    signal key_released           : std_logic;
    signal key_event              : std_logic;
    signal key_extended           : std_logic;
    signal kyb_char_rev           : std_logic_vector(7 downto 0);
    --                            
    signal clk_32Mhz              : std_logic;
    signal fb_clk                 : std_logic;
    signal video_clk              : std_logic;
    signal cpu_clk                : std_logic;
    signal cpu_clk_fast           : std_logic;
    signal cpu_clk_slow           : std_logic;
    signal ram_clk                : std_logic;
    signal leds                   : std_logic_vector(2 downto 0);
    --
    -- cpu_clk ( 4 MHz) to 15 kHz
    constant ps2clk_count_max     : integer := (4000000 / 15000 / 2) - 1;
    signal ps2clk_count           : integer range 0 to ps2clk_count_max := 0;
    signal ps2clk                 : std_logic                           := '0';
    signal ps2a_clk               : std_logic;
    signal ps2a_data              : std_logic;
    --
    --
    signal uart_data              : std_logic_vector (7 downto 0);
    signal uart_data_en           : std_logic;
    signal RX_Busy_old            : std_logic;
    signal Rx_Busy                : std_logic;
    --
    signal redz0mb1e_1_ramAddr      : std_logic_vector(15 downto 0);
    signal redz0mb1e_1_ramData_out  : std_logic_vector( 7 downto 0);
    signal redz0mb1e_1_ramCE_N      : std_logic;
    signal redz0mb1e_1_ramWe_N      : std_logic;
    signal redz0mb1e_1_ramOe_N      : std_logic;
    --
    signal sdram_din              : std_logic_vector(7 downto 0);
    signal sdram_dout             : std_logic_vector(7 downto 0);
    signal sdram_addr             : std_logic_vector(15 downto 0);
    signal sdram_oe               : std_logic;
    signal sdram_wr               : std_logic;
    --
    signal rom_dout               : std_logic_vector(7 downto 0);
    --
    signal user_io_status         : std_logic_vector( 7 downto 0);
    --
    signal data_io_index          : std_logic_vector(4 downto 0);
    signal data_io_inst_download  : std_logic;
    signal data_io_inst_wr        : std_logic;
    signal data_io_inst_addr      : std_logic_vector(24 downto 0);
    signal data_io_inst_data      : std_logic_vector(7 downto 0);
    --
    signal hs_decode_download     : std_logic;
    signal hs_decode_wr           : std_logic;
    signal hs_decode_addr         : std_logic_vector(15 downto 0);
    signal hs_decode_data         : std_logic_vector(7 downto 0);
    --
    signal hs_show_message        : std_logic; 
    signal hs_message_en          : std_logic; 
    signal hs_message             : character;
    signal hs_message_restart     : std_logic;
    --
    signal color_foreground       : std_logic_vector( 2 downto 0);
    signal color_background       : std_logic_vector( 2 downto 0);
    --                            
    signal sys_red                : std_logic;
    signal sys_green              : std_logic;
    signal sys_blue               : std_logic;
    signal sys_hsync              : std_logic;
    signal sys_vsync              : std_logic;
    --
    signal scanline_red_out       : std_logic_vector( 5 downto 0);
    signal scanline_green_out     : std_logic_vector( 5 downto 0);
    signal scanline_blue_out      : std_logic_vector( 5 downto 0);
    signal scanline_hsync_out     : std_logic;
    signal scanline_vsync_out     : std_logic;
    --
    signal onlinehelp_red_out     : std_logic_vector( 5 downto 0);
    signal onlinehelp_green_out   : std_logic_vector( 5 downto 0);
    signal onlinehelp_blue_out    : std_logic_vector( 5 downto 0);
    signal onlinehelp_hsync_out   : std_logic;
    signal onlinehelp_vsync_out   : std_logic;

    -- select the global clock source
    alias  sys_clk      : std_logic is clk_27(0);
    signal pll_locked   : std_logic;


begin

    -- fixed default outputs
    uart_tx        <= uart_rx;

    audior         <= '0';
    audiol         <= '0';


    -- generate all necessary clocks
    altpll0_inst: entity work.altpll0
    port map
    (
        inclk0   => sys_clk,      -- 27 MHz
        locked   => pll_locked,
        c0       => clk_32Mhz,    -- 32 MHz, -2.5 ns (was: 50MHz), sdram
        c1       => video_clk,    -- 40 MHz, SVGA 800x600@60Hz
        c2       => cpu_clk_fast, --  4 MHz
        c3       => cpu_clk_slow, --  2 MHz
        c4       => ram_clk       -- 32 MHz
    );
    cpu_clk <= cpu_clk_fast;


    -- visual check the clock on LED
    clock_blink_cpuclk: entity support.clock_blink
    generic map 
    (
        g_ticks_per_sec => 4_000_000
    )
    port map
    (
        clk     => cpu_clk_slow,
        blink_o => led_yellow_n
    );
    test_point_tp1  <= '0';

    
    ------------------------------------
    -- convert ps2 signals 
    -- to keyboard scancode
    --
    ps2_adapter: entity support.ps2_scancode
    port map
    (
        clk            => cpu_clk,      -- : in    std_ulogic;
        --
        ps2_data       => ps2a_data,    -- : in    std_logic;
        ps2_clock      => ps2a_clk,     -- : in    std_logic
        --
        scancode       => kyb_char_rev, -- : out   std_logic_vector( 7 downto 0);
        scancode_en    => key_event     -- : out   std_logic
    );


    ------------------------------------
    -- reset generator
    --
    process
    begin
        wait until rising_edge( cpu_clk);

        if reset_counter > 0 then
            reset_counter   <= reset_counter - 1;
        else
            sys_reset       <= '0';
        end if;

        -- all reset sources:
        if  ( user_io_status( reset_bit) = '1')
            or ( pll_locked = '0') 
            or ( data_io_inst_download = '1' and unsigned( data_io_index) = 0)
        then
            reset_counter   <= 255;
            sys_reset       <= '1';
        end if;

    end process;
    sys_reset_n <= not sys_reset;


    ------------------------------------
    -- redzomb1e
    --
    redz0mb1e_1 : entity work.redz0mb1e
    port map (
        -- system
     	reset_n               => sys_reset_n,               -- : in std_logic;
        --
        cpu_clk               => cpu_clk,                   -- : in std_logic;
        cpu_hold_n            => not( hs_decode_download),  -- : in std_logic;
        video_clk             => video_clk,                 -- : in std_logic;
        --                    
        kyb_in                => kyb_char_rev,
        key_released          => key_released,
        key_event             => key_event,
        key_extended          => key_extended,
        keyboard_layout_en_de => user_io_status( keyboard_bit),
        -- VGA                
        red_o                 => sys_red,
        blue_o                => sys_blue,
        green_o               => sys_green,
        vsync_o               => sys_vsync,                 -- check polarity
        hsync_o               => sys_hsync,
        -- color selection (original is white on black)
        col_fg                => color_foreground,          -- white
        col_bg                => color_background,          -- black
        -- SRAM interface
        ramAddr	              => redz0mb1e_1_ramAddr,       -- : out   std_logic_vector(15 downto 0);
        ramData_in            => sdram_dout,                -- : in    std_logic_vector(7 downto 0);
        ramData_out           => redz0mb1e_1_ramData_out,   -- : out   std_logic_vector(7 downto 0);
        ramOe_N	              => redz0mb1e_1_ramOe_N,       -- : out   std_logic; 
        ramCE_N	              => redz0mb1e_1_ramCE_N,       -- : out   std_logic;
        ramWe_N	              => redz0mb1e_1_ramWe_N,       -- : out   std_logic
        rom_data_in           => rom_dout                   -- : in    std_logic_vector(7 downto 0);
    );      


    ------------------------------------
    -- color selector
    --
    color_foreground <= "111" when user_io_status( color_bit) = '0' else "110";
    color_background <= "000" when user_io_status( color_bit) = '0' else "001";


    ------------------------------------
    -- sdram arbiter
    --
    sdram_din   <= redz0mb1e_1_ramData_out   when hs_decode_download = '0' else hs_decode_data;
    sdram_addr  <= redz0mb1e_1_ramAddr       when hs_decode_download = '0' else hs_decode_addr;
    sdram_wr    <= not( redz0mb1e_1_ramWe_N) when hs_decode_download = '0' else hs_decode_wr;
    sdram_oe    <= not( redz0mb1e_1_ramOe_N) when hs_decode_download = '0' else '1'; -- write only
   

    ------------------------------------
    -- internal block RAM, with load function
    -- size:    16k
    -- offset:  0x0000
    --
    ram : block is
        constant size   : natural := 16384;
        constant offset : natural := 0;
        type ram_type is array ( 0 to size - 1) of std_logic_vector( sdram_din'range);
        signal ram  : ram_type;
    begin

        process
        begin
            wait until rising_edge( cpu_clk);
            if sdram_wr = '1' then
                ram( to_integer( unsigned( sdram_addr))) <= sdram_din;
            end if;
            if unsigned( sdram_addr) < size then
                sdram_dout <= ram( to_integer( unsigned( sdram_addr)));
            else
                sdram_dout <= ( others => 'Z');
            end if;
        end process;

    end block ram;
    
    -- disable external dram
    dram_cs_n   <= '1';
    dram_we_n   <= '1';
    dram_ras_n  <= '1';
    dram_cas_n  <= '1';
    -- reduce simulation warnings about missing drivers
    dram_dq     <= ( others => 'Z');
    dram_a      <= ( others => 'Z');
    dram_clk    <= '0';
    dram_dqm    <= ( others => 'Z');
    dram_ba     <= ( others => 'Z');
   

    ------------------------------------
    -- clock generator for ps2clk
    -- used by user_io
    --
    process
    begin
        wait until rising_edge( cpu_clk);
        if ps2clk_count > 0 then
            ps2clk_count <= ps2clk_count - 1;
        else
            ps2clk_count <= ps2clk_count_max;
            ps2clk       <= not ps2clk;
        end if;
    end process;

    
    ------------------------------------
    -- io-module via arm controller
    --
    user_io_inst : user_io
    generic map
    (
        strlen         => config_str'length
    )
    port map
    (
        conf_str       => string_to_slv( config_str),
        -- external interface
        spi_clk        => spi_sck,
        spi_ss_io      => conf_data0,
        spi_miso       => spi_do,
        spi_mosi       => spi_di,
        --
		status         => user_io_status,      -- : out std_logic_vector( 7 downto 0);
        --
        -- connection to sd card emulation
		sd_lba         => ( others => '0'),    -- : in  std_logic_vector( 31 downto 0);
		sd_rd          => '0',                 -- : in  std_logic;
		sd_wr          => '0',                 -- : in  std_logic;
		sd_ack         => open,                -- : out std_logic;
		sd_conf        => '0',                 -- : in  std_logic;
		sd_sdhc        => '0',                 -- : in  std_logic;
		sd_dout        => open,                -- : out std_logic_vector( 7 downto 0); -- valid on rising edge of sd_dout_strobe
		sd_dout_strobe => open,                -- : out std_logic;
		sd_din         => ( others => '0'),    -- : in  std_logic_vector( 7 downto 0);
		sd_din_strobe  => open,                -- : out std_logic;
		-- ps2 keyboard emulation
		ps2_clk        => ps2clk,              -- : in  std_logic; -- 12-16khz provided by core
		ps2_kbd_clk    => ps2a_clk,            -- : out std_logic;
		ps2_kbd_data   => ps2a_data,           -- : out std_logic;
		ps2_mouse_clk  => open,                -- : out std_logic;
		ps2_mouse_data => open,                -- : out std_logic;
		-- serial com port 
		serial_data    => ( others => '0'),    -- : in  std_logic_vector( 7 downto 0);
		serial_strobe  => '0'                  -- : in  std_logic
    );
    
    
    data_io_inst : data_io 
    port map
    (
        -- io controller spi interface
        sck         => spi_sck,               -- : in    std_logic;
        ss          => spi_ss2,               -- : in    std_logic;
        sdi         => spi_di,                -- : in    std_logic;
        downloading => data_io_inst_download, -- : out   std_logic;              -- signal indication an active download
        index       => data_io_index,         -- : out   std_logic_vector(4 downto 0); -- menu index used to upload the file
        -- external ram interface
        clk         => cpu_clk,               -- : in    std_logic;
        wr          => data_io_inst_wr,       -- : out   std_logic;
        addr        => data_io_inst_addr,     -- : out   std_logic_vector(24 downto 0);
        data        => data_io_inst_data      -- : out   std_logic_vector(7 downto 0)
    );
    
    
    ------------------------------------
    -- decode z80 (headersave) files
    -- to bring them on the right memory address
    --
    headersave_decode_inst : entity support.headersave_decode
    port map
    (
        clk                 => cpu_clk,                 -- : in    std_logic;
        -- interface from data_io                   
        downloading         => data_io_inst_download,   -- : in    std_logic;    -- signal indication an active download
        wr                  => data_io_inst_wr,         -- : in    std_logic;
        addr                => data_io_inst_addr,       -- : in    std_logic_vector(24 downto 0);
        data                => data_io_inst_data,       -- : in    std_logic_vector(7 downto 0);
        -- interface to memory
        downloading_out     => hs_decode_download,      -- : out   std_logic;
        wr_out              => hs_decode_wr,            -- : out   std_logic;
        addr_out            => hs_decode_addr,          -- : out   std_logic_vector(15 downto 0);
        data_out            => hs_decode_data,          -- : out   std_logic_vector(7 downto 0)
        -- interface to message display
        show_message        => hs_show_message,         -- : out   std_logic;    -- enable or disable message display
        message_en          => hs_message_en,           -- : out   std_logic;    -- 0->1 take new message character
        message             => hs_message,              -- : out   character;
        message_restart     => hs_message_restart       -- : out   std_logic     -- restart with new message
    );
    

    ------------------------------------
    -- additional fancy video overlays
    -- (scanlines, osd and online_help)
    --
    scanline_inst : entity overlay.scanline
    port map
    (
        active      => not( user_io_status( scanline_bit)), -- : in  std_logic;
        pixel_clock => video_clk,              -- : in  std_logic;
        -- input signals
        red         => (others => sys_red),    -- : in  std_logic_vector( 5 downto 0);
        green       => (others => sys_green),  -- : in  std_logic_vector( 5 downto 0);
        blue        => (others => sys_blue),   -- : in  std_logic_vector( 5 downto 0);
        hsync       => sys_hsync,              -- : in  std_logic;
        vsync       => sys_vsync,              -- : in  std_logic;
        -- output signals
        red_out     => scanline_red_out,       -- : out std_logic_vector( 5 downto 0);
        green_out   => scanline_green_out,     -- : out std_logic_vector( 5 downto 0);
        blue_out    => scanline_blue_out,      -- : out std_logic_vector( 5 downto 0);
        hsync_out   => scanline_hsync_out,     -- : out std_logic;
        vsync_out   => scanline_vsync_out      -- : out std_logic
    );


    online_help_inst : entity overlay.online_help
    port map
    (
        active          => user_io_status( help_bit), -- : in  std_logic;
        pixel_clock     => video_clk,              -- : in  std_logic;
        -- input signals
        red             => scanline_red_out,       -- : in  std_logic_vector( 5 downto 0);
        green           => scanline_green_out,     -- : in  std_logic_vector( 5 downto 0);
        blue            => scanline_blue_out,      -- : in  std_logic_vector( 5 downto 0);
        hsync           => scanline_hsync_out,     -- : in  std_logic;
        vsync           => scanline_vsync_out,     -- : in  std_logic;
        -- message stuff
        show_message    => hs_show_message,        -- : in  std_logic;    -- enable or disable message display
        message_en      => hs_message_en,          -- : in  std_logic;    -- 0->1 take new message character
        message         => hs_message,             -- : in  character;
        message_restart => hs_message_restart,     -- : in  std_logic;    -- restart with new message
        -- output signals
        red_out         => onlinehelp_red_out,     -- : out std_logic_vector( 5 downto 0);
        green_out       => onlinehelp_green_out,   -- : out std_logic_vector( 5 downto 0);
        blue_out        => onlinehelp_blue_out,    -- : out std_logic_vector( 5 downto 0);
        hsync_out       => onlinehelp_hsync_out,   -- : out std_logic;
        vsync_out       => onlinehelp_vsync_out    -- : out std_logic
    );


    osd_inst: osd
    port map
    (
        -- OSDs pixel clock
	    pclk           => video_clk,           -- : in  std_logic;
        -- SPI interface                       -- 
		sck            => spi_sck,             -- : in  std_logic;
		ss             => spi_ss3,             -- : in  std_logic;
		sdi            => spi_di,              -- : in  std_logic;
		-- VGA signals coming from core
		red_in         => onlinehelp_red_out,    -- : in  std_logic_vector( 5 downto 0);
		green_in       => onlinehelp_green_out,  -- : in  std_logic_vector( 5 downto 0);
		blue_in        => onlinehelp_blue_out,   -- : in  std_logic_vector( 5 downto 0);
        hs_in          => onlinehelp_hsync_out,  -- : in  std_logic;
        vs_in          => onlinehelp_vsync_out,  -- : in  std_logic;
		-- VGA signals going to video connector
		red_out        => vga_red,             -- : out std_logic_vector( 5 downto 0);
		green_out      => vga_green,           -- : out std_logic_vector( 5 downto 0);
		blue_out       => vga_blue,            -- : out std_logic_vector( 5 downto 0);
        hs_out         => vga_hsync,           -- : out std_logic;
        vs_out         => vga_vsync            -- : out std_logic
    );

end architecture rtl;

