----------------------------------------------------------------------------------
-- testbench for osd (Z1013 mist project)
-- 
-- Copyright (c) 2018 by Bert Lange
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

library std;
use std.textio.all;

library mist;


entity osd_tb is
end entity osd_tb;


architecture testbench of osd_tb is

    constant pixel_clock_period  : time := 1 sec / 60_000_000;

    signal simulation_run        : boolean := true;

    signal tb_pixel_clock        : std_logic := '0';
    --
    signal tb_red                : std_logic_vector( 5 downto 0);
    signal tb_green              : std_logic_vector( 5 downto 0);
    signal tb_blue               : std_logic_vector( 5 downto 0);
    signal tb_hsync              : std_logic;
    signal tb_vsync              : std_logic;
	--
	signal tb_spi_sck            : std_logic := '0';
	signal tb_spi_ss3            : std_logic := '1';
	signal tb_spi_di             : std_logic := '0';
	signal tb_spi_do             : std_logic;
    --
    signal tb_red_out            : std_logic_vector( 5 downto 0);
    signal tb_green_out          : std_logic_vector( 5 downto 0);
    signal tb_blue_out           : std_logic_vector( 5 downto 0);
    signal tb_hsync_out          : std_logic;
    signal tb_vsync_out          : std_logic;
    -- 
    signal spi_send              : std_logic_vector( 7 downto 0);
    signal spi_receive           : std_logic_vector( 7 downto 0);


    -- inspired by:
    -- http://www.lothar-miller.de/s9y/archives/31-SPI-Slave-im-CPLD.html#extended; 
    --
    -- SPI settings for SAM7X
    -- SPI_CR = EN
    -- SPI_MR = MSTR, MODFDIS = mode fault detection disable, 0x0E << 16 NPCS[3:0] = ?
    -- SPI_CS = CPOL, 48 << 8, 00 << 16, 01 << 24
    -- CPOL = 1, NCPHA = 0
    --     inactive clock state is 1
    --     data is changed on the leading edge of clk (falling edge)
    --     and captured on the following edge of clk (rising edge)
    --     bitrate = 48 MHz / 48
    --     delay before spck = 0
    --     delay between consecutive transfers = 32 / 48 MHz = 0,66 us
    procedure spi_transfer(
        signal tx_data  : inout std_logic_vector( 7 downto 0);
        signal rx_data  : inout std_logic_vector( 7 downto 0);
        signal spi_clk  : out   std_logic;
        signal spi_mosi : out   std_logic;
        signal spi_miso : in    std_logic) is
        variable l  : line;
    begin
        write( l, string'( "send: 0x"));
        hwrite( l, tx_data);

        spi_mosi    <= tx_data( tx_data'high);
        wait for 10 ns;
        for index in tx_data'range loop
            spi_clk <= '0';
            wait for 20 ns;
            tx_data <= tx_data( 6 downto 0) & '0';
            rx_data <= rx_data( 6 downto 0) & spi_miso;
            spi_clk  <= '1';
            wait for 20 ns;
            spi_mosi <= tx_data( tx_data'high);
        end loop;
        wait for 20 ns;
        write( l, string'( "   receive: 0x"));
        hwrite( l, rx_data);
        if( unsigned( rx_data) > 31) and ( unsigned( rx_data) < 128) then
            write( l, string'( " (")); 
            write( l, character'val( to_integer( unsigned( rx_data))));
            write( l, string'( ")")); 
        end if;
        writeline( output, l);
    end procedure spi_transfer;
    
	
	procedure disable_osd(
        signal tx_data  : inout std_logic_vector( 7 downto 0);
        signal rx_data  : inout std_logic_vector( 7 downto 0);
        signal spi_csn  : out   std_logic;
        signal spi_clk  : out   std_logic;
        signal spi_mosi : out   std_logic;
        signal spi_miso : in    std_logic) is
    begin
        report( "disable osd");
        
		spi_csn         <= '0';
        tx_data         <= x"40";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);
        
		spi_csn         <= '1';
		wait for 200 ns;
    end procedure;
    
	
	procedure enable_osd(
        signal tx_data  : inout std_logic_vector( 7 downto 0);
        signal rx_data  : inout std_logic_vector( 7 downto 0);
        signal spi_csn  : out   std_logic;
        signal spi_clk  : out   std_logic;
        signal spi_mosi : out   std_logic;
        signal spi_miso : in    std_logic) is
    begin
        report( "enable osd");
        
		spi_csn         <= '0';
        tx_data         <= x"41";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);
        
		spi_csn         <= '1';
		wait for 200 ns;
    end procedure;
    
	
	procedure write_osd(
        signal tx_data  : inout std_logic_vector( 7 downto 0);
        signal rx_data  : inout std_logic_vector( 7 downto 0);
        signal spi_csn  : out   std_logic;
        signal spi_clk  : out   std_logic;
        signal spi_mosi : out   std_logic;
        signal spi_miso : in    std_logic) is
    begin
        report( "write osd");
        
		spi_csn         <= '0';
        tx_data         <= x"20";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        wait for 1 us;
        tx_data         <= std_logic_vector( to_unsigned( character'pos( 'H') , 8));
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        wait for 1 us;
        tx_data         <= std_logic_vector( to_unsigned( character'pos( 'e') , 8));
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        wait for 1 us;
        tx_data         <= std_logic_vector( to_unsigned( character'pos( 'l') , 8));
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        wait for 1 us;
        tx_data         <= std_logic_vector( to_unsigned( character'pos( 'l') , 8));
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        wait for 1 us;
        tx_data         <= std_logic_vector( to_unsigned( character'pos( 'o') , 8));
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        wait for 1 us;
        tx_data         <= std_logic_vector( to_unsigned( character'pos( '!') , 8));
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);
        
		spi_csn         <= '1';
		wait for 200 ns;
    end procedure;

begin

    -- clock gen
    tb_pixel_clock <= not tb_pixel_clock after pixel_clock_period / 2 when simulation_run;

    -- video gen
    video_gen : entity work.vga_controller_800_600
    port map
    (
        rst         => '0',                   -- : in std_logic;
        pixel_clk   => tb_pixel_clock,        -- : in std_logic;
        --
        HS          => tb_hsync,              -- : out std_logic;
        VS          => tb_vsync,              -- : out std_logic;
        hcount      => open,                  -- : out std_logic_vector(10 downto 0);
        vcount      => open,                  -- : out std_logic_vector(10 downto 0);
        blank       => open                   -- : out std_logic
    );

    dut: entity mist.osd
    port map
    (
        -- OSDs pixel clock
	    pclk           => tb_pixel_clock,      -- : in  std_logic;
        -- SPI interface                       -- 
		sck            => tb_spi_sck,          -- : in  std_logic;
		ss             => tb_spi_ss3,          -- : in  std_logic;
		sdi            => tb_spi_di,           -- : in  std_logic;
		-- VGA signals coming from core
		red_in         => tb_red,              -- : in  std_logic_vector( 5 downto 0);
		green_in       => tb_green,            -- : in  std_logic_vector( 5 downto 0);
		blue_in        => tb_blue,             -- : in  std_logic_vector( 5 downto 0);
        hs_in          => tb_hsync,            -- : in  std_logic;
        vs_in          => tb_vsync,            -- : in  std_logic;
		-- VGA signals going to video connector
		red_out        => tb_red_out,          -- : out std_logic_vector( 5 downto 0);
		green_out      => tb_green_out,        -- : out std_logic_vector( 5 downto 0);
		blue_out       => tb_blue_out,         -- : out std_logic_vector( 5 downto 0);
        hs_out         => tb_hsync_out,        -- : out std_logic;
        vs_out         => tb_vsync_out         -- : out std_logic
    );


    main: process
    begin
        wait for 17 ms;

        enable_osd(         spi_send, spi_receive, tb_spi_ss3, tb_spi_sck, tb_spi_di, tb_spi_do);
        write_osd(          spi_send, spi_receive, tb_spi_ss3, tb_spi_sck, tb_spi_di, tb_spi_do);


        wait for 20 ms;
        simulation_run  <= false;
        report "Simulation stopped by testbench.";
        wait;
    end process;


end architecture testbench;
