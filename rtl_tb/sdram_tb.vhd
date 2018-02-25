
----------------------------------------------------------------------------------
-- sdram controller from mist project (verilog)
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

library mist;

library fmf;


entity sdram_tb is
end entity sdram_tb;


architecture testbench of sdram_tb is

    constant clk_period : time := ( 1 sec) / 32_000_000;

    signal simulation_run : boolean := true;

    signal tb_sd_data : std_logic_vector(15 downto 0) := ( others => 'Z');
    signal tb_sd_addr : std_logic_vector(12 downto 0);
    signal tb_sd_dqm  : std_logic_vector( 1 downto 0);
    signal tb_sd_ba   : std_logic_vector( 1 downto 0);
    signal tb_sd_cs   : std_logic;
    signal tb_sd_we   : std_logic;
    signal tb_sd_ras  : std_logic;
    signal tb_sd_cas  : std_logic;
    --
    signal tb_init    : std_logic := '1';
    signal tb_clk     : std_logic := '0';
    signal tb_clkref  : std_logic := '0';
    --
    signal tb_din     : std_logic_vector( 7 downto 0) := "00000000";
    signal tb_dout    : std_logic_vector( 7 downto 0);
    signal tb_addr    : std_logic_vector(24 downto 0) := ( others => '0');
    signal tb_oe      : std_logic := '0';
    signal tb_we      : std_logic := '0';


begin

    tb_clk      <= not tb_clk       after clk_period / 2    when simulation_run;
    tb_clkref   <= not tb_clkref    after clk_period * 8    when simulation_run;


    dut: entity mist.sdram
    port map
    (
        -- interface to the MT48LC16M16 chip
        sd_data => tb_sd_data,   -- : inout std_logic_vector(15 downto 0);  -- 16 bit bidirectional data bus
        sd_addr => tb_sd_addr,   -- : out   std_logic_vector(12 downto 0);  -- 13 bit multiplexed address bus
        sd_dqm  => tb_sd_dqm,    -- : out   std_logic_vector( 1 downto 0);  -- two byte masks
        sd_ba   => tb_sd_ba,     -- : out   std_logic_vector( 1 downto 0);  -- two banks
        sd_cs   => tb_sd_cs,     -- : out   std_logic;                      -- a single chip select
        sd_we   => tb_sd_we,     -- : out   std_logic;                      -- write enable
        sd_ras  => tb_sd_ras,    -- : out   std_logic;                      -- row address select
        sd_cas  => tb_sd_cas,    -- : out   std_logic;                      -- columns address select
        -- system interface
        init    => tb_init,      -- : in    std_logic;                      -- init signal after FPGA config to initialize RAM
        clk     => tb_clk,       -- : in    std_logic;                      -- sdram is accessed at up to 128MHz
        clkref  => tb_clkref,    -- : in    std_logic;                      -- reference clock to sync to
        -- cpu/chipset interface
        din     => tb_din,       -- : in    std_logic_vector( 7 downto 0);  -- data input from chipset/cpu
        dout    => tb_dout,      -- : out   std_logic_vector( 7 downto 0);  -- data output to chipset/cpu
        addr    => tb_addr,      -- : in    std_logic_vector(24 downto 0);  -- 25 bit byte address
        oe      => tb_oe,        -- : in    std_logic;                      -- cpu/chipset requests read
        we      => tb_we         -- : in    std_logic                       -- cpu/chipset requests write
    );


    dram_model: entity fmf.mt48lc16m16a2
    generic map
    (
        mem_file_name   => "none"
    )
    port map
    (
        BA0     => tb_sd_ba( 0),       -- : IN    std_logic := 'U';
        BA1     => tb_sd_ba( 1),       -- : IN    std_logic := 'U';
        DQMH    => tb_sd_dqm( 1),      -- : IN    std_logic := 'U';
        DQML    => tb_sd_dqm( 0),      -- : IN    std_logic := 'U';
        DQ0     => tb_sd_data(  0),    -- : INOUT std_logic := 'U';
        DQ1     => tb_sd_data(  1),    -- : INOUT std_logic := 'U';
        DQ2     => tb_sd_data(  2),    -- : INOUT std_logic := 'U';
        DQ3     => tb_sd_data(  3),    -- : INOUT std_logic := 'U';
        DQ4     => tb_sd_data(  4),    -- : INOUT std_logic := 'U';
        DQ5     => tb_sd_data(  5),    -- : INOUT std_logic := 'U';
        DQ6     => tb_sd_data(  6),    -- : INOUT std_logic := 'U';
        DQ7     => tb_sd_data(  7),    -- : INOUT std_logic := 'U';
        DQ8     => tb_sd_data(  8),    -- : INOUT std_logic := 'U';
        DQ9     => tb_sd_data(  9),    -- : INOUT std_logic := 'U';
        DQ10    => tb_sd_data( 10),    -- : INOUT std_logic := 'U';
        DQ11    => tb_sd_data( 11),    -- : INOUT std_logic := 'U';
        DQ12    => tb_sd_data( 12),    -- : INOUT std_logic := 'U';
        DQ13    => tb_sd_data( 13),    -- : INOUT std_logic := 'U';
        DQ14    => tb_sd_data( 14),    -- : INOUT std_logic := 'U';
        DQ15    => tb_sd_data( 15),    -- : INOUT std_logic := 'U';
        CLK     => tb_clk,             -- : IN    std_logic := 'U';
        CKE     => '1',                -- : IN    std_logic := 'U';
        A0      => tb_sd_addr(  0),    -- : IN    std_logic := 'U';
        A1      => tb_sd_addr(  1),    -- : IN    std_logic := 'U';
        A2      => tb_sd_addr(  2),    -- : IN    std_logic := 'U';
        A3      => tb_sd_addr(  3),    -- : IN    std_logic := 'U';
        A4      => tb_sd_addr(  4),    -- : IN    std_logic := 'U';
        A5      => tb_sd_addr(  5),    -- : IN    std_logic := 'U';
        A6      => tb_sd_addr(  6),    -- : IN    std_logic := 'U';
        A7      => tb_sd_addr(  7),    -- : IN    std_logic := 'U';
        A8      => tb_sd_addr(  8),    -- : IN    std_logic := 'U';
        A9      => tb_sd_addr(  9),    -- : IN    std_logic := 'U';
        A10     => tb_sd_addr( 10),    -- : IN    std_logic := 'U';
        A11     => tb_sd_addr( 11),    -- : IN    std_logic := 'U';
        A12     => tb_sd_addr( 12),    -- : IN    std_logic := 'U';
        WENeg   => tb_sd_we,           -- : IN    std_logic := 'U';
        RASNeg  => tb_sd_ras,          -- : IN    std_logic := 'U';
        CSNeg   => tb_sd_cs,           -- : IN    std_logic := 'U';
        CASNeg  => tb_sd_cas           -- : IN    std_logic := 'U'
    );


    main: process
    begin
        wait for 100 us; -- wait for powerup 

        wait for 10 * clk_period;
        tb_init <= '0';

        wait for 10 us;
        wait until falling_edge( tb_clkref);
        tb_addr <= std_logic_vector( to_unsigned( 1000, tb_addr'length));
        tb_din  <= "10001110";
        tb_we   <= '1';
        wait until falling_edge( tb_clkref);
        tb_we   <= '0';
        wait until falling_edge( tb_clkref);
        wait until falling_edge( tb_clkref);
        tb_oe   <= '1';
        wait until falling_edge( tb_clkref);
        tb_oe   <= '0';
        wait for 1 ms;
        report "Simulation stopped by testbench.";
        simulation_run <= false;
        wait;
    end process;

end architecture testbench;
