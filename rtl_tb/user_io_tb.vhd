----------------------------------------------------------------------------------
-- testbench for user_io (vhdl version) used by the Z1013 mist project
-- 
-- Copyright (c) 2017, 2018 by Bert Lange
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

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

library mist;


entity user_io_tb is
end entity user_io_tb;


architecture testbench of user_io_tb is

    signal simulation_run           : boolean   := true;

    constant ps2_clk_period         : time      := ( 1 sec) / 25000; -- normally ~14 kHz

    constant tb_STRLEN              : natural   := 9;

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


    procedure read_config_string(
        signal tx_data  : inout std_logic_vector( 7 downto 0);
        signal rx_data  : inout std_logic_vector( 7 downto 0);
        signal spi_csn  : out   std_logic;
        signal spi_clk  : out   std_logic;
        signal spi_mosi : out   std_logic;
        signal spi_miso : in    std_logic) is
    begin
        report( "read config string");
        spi_csn         <= '0';
        tx_data         <= x"14";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);
        tx_data <= x"00";
        wait for 1 ps;
        for index in 1 to tb_STRLEN loop
            spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);
        end loop;
        spi_csn         <= '1';
        wait for 100 ns;
    end procedure;


    procedure write_status(
        signal tx_data  : inout std_logic_vector( 7 downto 0);
        signal rx_data  : inout std_logic_vector( 7 downto 0);
        signal spi_csn  : out   std_logic;
        signal spi_clk  : out   std_logic;
        signal spi_mosi : out   std_logic;
        signal spi_miso : in    std_logic) is
    begin
        report( "write status (core reset)");
        spi_csn         <= '0';
        tx_data         <= x"15";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data <= x"01";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data <= x"00";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        spi_csn         <= '1';
        wait for 200 ns;
    end procedure;


    procedure write_status32(
        signal tx_data  : inout std_logic_vector( 7 downto 0);
        signal rx_data  : inout std_logic_vector( 7 downto 0);
        signal spi_csn  : out   std_logic;
        signal spi_clk  : out   std_logic;
        signal spi_mosi : out   std_logic;
        signal spi_miso : in    std_logic) is
    begin
        report( "write 32 bit status (core reset)");
        spi_csn         <= '0';
        tx_data         <= x"1e";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data <= x"01";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data <= x"aa";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data <= x"bb";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data <= x"cc";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        spi_csn         <= '1';
        wait for 200 ns;
    end procedure;


    procedure write_buttons(
        signal tx_data  : inout std_logic_vector( 7 downto 0);
        signal rx_data  : inout std_logic_vector( 7 downto 0);
        signal spi_csn  : out   std_logic;
        signal spi_clk  : out   std_logic;
        signal spi_mosi : out   std_logic;
        signal spi_miso : in    std_logic) is
    begin
        report( "set button state");
        spi_csn         <= '0';
        tx_data         <= x"01";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data         <= x"01";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data         <= x"02";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data         <= x"04";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data         <= x"08";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        spi_csn         <= '1';
        wait for 100 ns;
    end procedure;


    procedure write_ps2_keys(
        signal tx_data  : inout std_logic_vector( 7 downto 0);
        signal rx_data  : inout std_logic_vector( 7 downto 0);
        signal spi_csn  : out   std_logic;
        signal spi_clk  : out   std_logic;
        signal spi_mosi : out   std_logic;
        signal spi_miso : in    std_logic) is
    begin
        report( "emulate some PS/2 keys");
        spi_csn         <= '0';
        tx_data         <= x"05";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data         <= x"f0";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data         <= x"f8";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data         <= x"e0";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data         <= x"e8";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        spi_csn         <= '1';
        -- PS/2 output will take some time
        wait for  2000 us;
    end procedure;


    procedure write_joystick(
        signal tx_data  : inout std_logic_vector( 7 downto 0);
        signal rx_data  : inout std_logic_vector( 7 downto 0);
        signal spi_csn  : out   std_logic;
        signal spi_clk  : out   std_logic;
        signal spi_mosi : out   std_logic;
        signal spi_miso : in    std_logic) is
    begin
        report( "write joystick 0");
        spi_csn         <= '0';
        tx_data         <= x"02";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data         <= x"ff";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data         <= x"fe";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data         <= x"fc";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data         <= x"f8";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        spi_csn         <= '1';
        wait for 100 ns;

        report( "write joystick 1");
        spi_csn         <= '0';
        tx_data         <= x"03";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        tx_data         <= x"aa";
        wait for 1 ps;
        spi_transfer( tx_data, rx_data, spi_clk, spi_mosi, spi_miso);

        spi_csn         <= '1';
        wait for 100 ns;
    end procedure;

       
    signal spi_send    : std_logic_vector( 7 downto 0);
    signal spi_receive : std_logic_vector( 7 downto 0);

    -- testbench driven
    signal tb_conf_str              : std_logic_vector(( 8 * tb_STRLEN) - 1 downto 0) := string_to_slv( "testbench");
    signal tb_SPI_CLK               : std_logic := '1';
    signal tb_SPI_SS_IO             : std_logic := '1';
    signal tb_SPI_MOSI              : std_logic;
    signal tb_sd_lba                : std_logic_vector( 31 downto 0);
    signal tb_sd_rd                 : std_logic;
    signal tb_sd_wr                 : std_logic;
    signal tb_sd_conf               : std_logic;
    signal tb_sd_sdhc               : std_logic;
    signal tb_sd_din                : std_logic_vector( 7 downto 0);
    signal tb_ps2_clk               : std_logic := '0';
    signal tb_serial_data           : std_logic_vector( 7 downto 0);
    signal tb_serial_strobe         : std_logic;
    signal tb_clk                   : std_logic := '0';

    -- dut driven
    signal tb_SPI_MISO              : std_logic;
    signal tb_joystick_0            : std_logic_vector( 7 downto 0);
    signal tb_joystick_1            : std_logic_vector( 7 downto 0);
    signal tb_joystick_analog_0     : std_logic_vector( 15 downto 0);
    signal tb_joystick_analog_1     : std_logic_vector( 15 downto 0);
    signal tb_buttons               : std_logic_vector( 1 downto 0);
    signal tb_switches              : std_logic_vector( 1 downto 0);
    signal tb_status                : std_logic_vector( 31 downto 0);
    signal tb_sd_ack                : std_logic;
    signal tb_sd_dout               : std_logic_vector( 7 downto 0);
    signal tb_sd_dout_strobe        : std_logic;
    signal tb_sd_din_strobe         : std_logic;
    signal tb_ps2_kbd_clk           : std_logic;
    signal tb_ps2_kbd_data          : std_logic;
    signal tb_ps2_mouse_clk         : std_logic;
    signal tb_ps2_mouse_data        : std_logic;
    signal tb_scancode              : std_logic_vector( 7 downto 0);
    signal tb_scancode_en           : std_logic;

begin

    tb_ps2_clk  <= not tb_ps2_clk after ps2_clk_period / 2 when simulation_run;

    dut: entity mist.user_io
    generic map
    (
        strlen              => tb_STRLEN                --: integer := 0
    )                       
    port map 
    (                       
        -- config string
        conf_str            => tb_conf_str,             --: in  std_logic_vector(( 8 * STRLEN) - 1 downto 0);
        -- external interface                           
        SPI_CLK             => tb_SPI_CLK,              --: in  std_logic;
        SPI_SS_IO           => tb_SPI_SS_IO,            --: in  std_logic;
        SPI_MISO            => tb_SPI_MISO,             --: out std_logic;
        SPI_MOSI            => tb_SPI_MOSI,             --: in  std_logic;
        -- internal interfaces                          
        joystick_0          => tb_joystick_0,           --: out std_logic_vector( 7 downto 0);
        joystick_1          => tb_joystick_1,           --: out std_logic_vector( 7 downto 0);
        joystick_analog_0   => tb_joystick_analog_0,    --: out std_logic_vector( 15 downto 0);
        joystick_analog_1   => tb_joystick_analog_1,    --: out std_logic_vector( 15 downto 0);
        buttons             => tb_buttons,              --: out std_logic_vector( 1 downto 0);
        switches            => tb_switches,             --: out std_logic_vector( 1 downto 0);
        --
        status              => tb_status,               --: out std_logic_vector( 31 downto 0);
        -- connection to sd card emulation
        sd_lba              => tb_sd_lba,               --: in  std_logic_vector( 31 downto 0);
        sd_rd               => tb_sd_rd,                --: in  std_logic;
        sd_wr               => tb_sd_wr,                --: in  std_logic;
        sd_ack              => tb_sd_ack,               --: out std_logic;
        sd_conf             => tb_sd_conf,              --: in  std_logic;
        sd_sdhc             => tb_sd_sdhc,              --: in  std_logic;
        sd_dout             => tb_sd_dout,              --: out std_logic_vector( 7 downto 0); -- valid on rising edge of sd_dout_strobe
        sd_dout_strobe      => tb_sd_dout_strobe,       --: out std_logic;
        sd_din              => tb_sd_din,               --: in  std_logic_vector( 7 downto 0);
        sd_din_strobe       => tb_sd_din_strobe,        --: out std_logic;
        -- ps2 keyboard emulation
        ps2_clk             => tb_ps2_clk,              --: in  std_logic; -- 12-16khz provided by core
        ps2_kbd_clk         => tb_ps2_kbd_clk,          --: out std_logic;
        ps2_kbd_data        => tb_ps2_kbd_data,         --: out std_logic;
        ps2_mouse_clk       => tb_ps2_mouse_clk,        --: out std_logic;
        ps2_mouse_data      => tb_ps2_mouse_data,       --: out std_logic;
        -- serial com port 
        serial_data         => tb_serial_data,          --: in  std_logic_vector( 7 downto 0);
        serial_strobe       => tb_serial_strobe,        --: in  std_logic
        --
        -- FPGA clk domain
        clk                 => tb_clk,                  --: in  std_logic;
        -- ps2 keyboard scancodes
        scancode            => tb_scancode,             --: out std_logic_vector( 7 downto 0);
        scancode_en         => tb_scancode_en           --: out std_logic
    );


    main: process
    begin
        wait for 1 us;
        
        write_status(       spi_send, spi_receive, tb_SPI_SS_IO, tb_SPI_CLK, tb_SPI_MOSI, tb_SPI_MISO);
        write_status32(     spi_send, spi_receive, tb_SPI_SS_IO, tb_SPI_CLK, tb_SPI_MOSI, tb_SPI_MISO);
        write_buttons(      spi_send, spi_receive, tb_SPI_SS_IO, tb_SPI_CLK, tb_SPI_MOSI, tb_SPI_MISO);
        write_ps2_keys(     spi_send, spi_receive, tb_SPI_SS_IO, tb_SPI_CLK, tb_SPI_MOSI, tb_SPI_MISO);
        write_joystick(     spi_send, spi_receive, tb_SPI_SS_IO, tb_SPI_CLK, tb_SPI_MOSI, tb_SPI_MISO);
        read_config_string( spi_send, spi_receive, tb_SPI_SS_IO, tb_SPI_CLK, tb_SPI_MOSI, tb_SPI_MISO);
        wait for 100 us;
        simulation_run  <= false;
        report "Simulation stopped by testbench.";
        wait;
    end process;

end architecture testbench;
