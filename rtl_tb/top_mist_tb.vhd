----------------------------------------------------------------------------------
-- testbench for top module for the Z1013 mist project
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

entity top_mist_tb is
end entity top_mist_tb;

architecture testbench of top_mist_tb is
    
    constant clk_period                : time := 1 sec / 27_000_000;
    signal simulation_run              : boolean := true;

    signal tb_clk27                    : std_logic_vector(1 downto 0) := "00";
    signal tb_reset_n                  : std_logic;
    -- basic input
    -- basic output
    signal tb_led_yellow               : std_logic;
    signal tb_test_point_tp1           : std_logic;
    -- basic communation
    signal tb_uart_rx                  : std_logic;
    signal tb_uart_tx                  : std_logic;
    -- dRAM pin conctions
    signal tb_dram_dq                  : std_logic_vector(15 downto 0);
    signal tb_dram_a                   : std_logic_vector(12 downto 0);
    signal tb_dram_clk                 : std_logic;                    
    signal tb_dram_we_n                : std_logic;                   
    signal tb_dram_cas_n               : std_logic;                  
    signal tb_dram_ras_n               : std_logic;                
    signal tb_dram_cs_n                : std_logic;                 
    signal tb_dram_dqm                 : std_logic_vector(1 downto 0);               
    signal tb_dram_ba                  : std_logic_vector(1 downto 0);
    -- vga out
    signal tb_vga_red                  : std_logic_vector(7 downto 0);
    signal tb_vga_green                : std_logic_vector(7 downto 0);
    signal tb_vga_blue                 : std_logic_vector(7 downto 0);
    signal tb_vga_hsync                : std_logic;
    signal tb_vga_vsync                : std_logic;
    -- PS/2 connects (A = mouse, B = keyboard)
    signal tb_ps2a_clk                 : std_logic;
    signal tb_ps2a_data                : std_logic;
    -- 
    signal tb_ps2b_clk                 : std_logic;
    signal tb_ps2b_data                : std_logic;
    -- audio   
    signal tb_audior                   : std_logic;
    signal tb_audiol                   : std_logic;
    -- SPI interface to ARM io controller
    signal tb_spi_do                   : std_logic;
    signal tb_spi_di                   : std_logic := '0';
    signal tb_spi_sck                  : std_logic := '0';
    signal tb_spi_ss2                  : std_logic := '0';
    signal tb_spi_ss3                  : std_logic := '0';
    signal tb_spi_ss4                  : std_logic := '0';
    signal tb_conf_data0               : std_logic := '0';
    
begin


    ----------------------------------------
    -- stimuli

    tb_clk27   <= not tb_clk27 after clk_period / 2 when simulation_run;
    tb_reset_n <= '0' , '1' after 7.77 * clk_period;


    top_mist_i0: entity work.top_mist
    port map 
    (
        -- system
        clk_27          => tb_clk27,                  -- : in    std_logic_vector(1 downto 0);
        reset_n         => tb_reset_n,                -- : in    std_logic;
        -- basic input
        -- basic output
        led_yellow_n    => tb_led_yellow,             -- : out   std_logic;
        test_point_tp1  => tb_test_point_tp1,         -- : out   std_logic;
        -- basic communation
        uart_rx         => tb_uart_rx,                -- : in    std_logic;
        uart_tx         => tb_uart_tx,                -- : out   std_logic;
        -- dRAM pin conctions
        dram_dq         => tb_dram_dq,                -- : inout std_logic_vector(15 downto 0);
        dram_a          => tb_dram_a,                 -- : out   std_logic_vector(12 downto 0);
        dram_clk        => tb_dram_clk,               -- : out   std_logic;                    
        dram_we_n       => tb_dram_we_n,              -- : out   std_logic;         
        dram_cas_n      => tb_dram_cas_n,             -- : out   std_logic;     
        dram_ras_n      => tb_dram_ras_n,             -- : out   std_logic; 
        dram_cs_n       => tb_dram_cs_n,              -- : out   std_logic;     
        dram_dqm        => tb_dram_dqm,               -- : out   std_logic_vector(1 downto 0); 
        dram_ba         => tb_dram_ba,                -- : out   std_logic_vector(1 downto 0);

        -- vga out signal
        vga_red         => tb_vga_red(7 downto 2),    -- : out   std_logic_vector(5 downto 0);
        vga_green       => tb_vga_green(7 downto 2),  -- : out   std_logic_vector(5 downto 0);
        vga_blue        => tb_vga_blue(7 downto 2),   -- : out   std_logic_vector(5 downto 0);
        vga_hsync       => tb_vga_hsync,              -- : out   std_logic;
        vga_vsync       => tb_vga_vsync,              -- : out   std_logic;

        -- audio
        audior          => tb_audior,                 -- : out   std_logic;
        audiol          => tb_audiol,                 -- : out   std_logic;

        -- SPI interface to ARM io controller
        spi_do          => tb_spi_do,                 -- : out   std_logic;
        spi_di          => tb_spi_di,                 -- : in    std_logic;
        spi_sck         => tb_spi_sck,                -- : in    std_logic;
        spi_ss2         => tb_spi_ss2,                -- : in    std_logic;
        spi_ss3         => tb_spi_ss3,                -- : in    std_logic;
        spi_ss4         => tb_spi_ss4,                -- : in    std_logic;
        conf_data0      => tb_conf_data0              -- : in    std_logic
    );


    monitor_i0: entity work.vga_monitor_tb
    port map (
        simulation_run => simulation_run,          -- : in  boolean := true;
        red            => tb_vga_red,              -- : in  std_logic_vector(7 downto 0);
        green          => tb_vga_green,            -- : in  std_logic_vector(7 downto 0);
        blue           => tb_vga_blue,             -- : in  std_logic_vector(7 downto 0);
        h_sync         => tb_vga_hsync,            -- : in  std_logic;
        v_sync         => tb_vga_vsync             -- : in  std_logic
    );


    main: process
    begin
        wait for 100 ms;
        simulation_run <= false;
        report "simulation end.";
        wait; -- forever
    end process;


end architecture testbench;
