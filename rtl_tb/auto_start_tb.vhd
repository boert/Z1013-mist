----------------------------------------------------------------------------------
-- testbench for auto start module conversaiotn (Z1013 mist project)
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

library support;


entity auto_start_tb is
end entity auto_start_tb;


architecture testbench of auto_start_tb is

    constant clk_period         : time          := (1 sec / 4_000_000);
    signal simulation_run       : boolean       := true;

    signal tb_clk               : std_logic     := '0';
    signal tb_enable            : std_logic;
    --
    signal tb_autostart_addr    : std_logic_vector(15 downto 0);
    signal tb_autostart_en      : std_logic;
    --
    signal tb_active            : std_logic;
    signal tb_ascii             : std_logic_vector( 7 downto 0);
    signal tb_ascii_press       : std_logic;
    signal tb_ascii_release     : std_logic;

begin

    tb_clk      <= not tb_clk after clk_period / 2 when simulation_run;

    tb_enable   <= '1';

    dut: entity support.auto_start
    port map
    (
        clk             => tb_clk,                -- : in    std_logic;
        enable          => tb_enable,             -- : in    std_logic;
        --
        autostart_addr  => tb_autostart_addr,     -- : in    std_logic_vector(15 downto 0);
        autostart_en    => tb_autostart_en,       -- : in    std_logic;    -- start signal
        -- emulated keypresses
        active          => tb_active,             -- : out   std_logic;
        ascii           => tb_ascii,              -- : out   std_logic_vector( 7 downto 0);
        ascii_press     => tb_ascii_press,        -- : out   std_logic;
        ascii_release   => tb_ascii_release       -- : out   std_logic
    );

    main: process
    begin
        
        wait for 20 * clk_period;
        tb_autostart_addr   <= x"1a4f";
        tb_autostart_en     <= '1';

        wait for clk_period;
        tb_autostart_en     <= '0';

        wait until tb_active = '0';
        wait for 5 * clk_period;

        simulation_run <= false;
        wait;

    end process;

end architecture testbench;

