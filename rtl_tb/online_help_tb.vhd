----------------------------------------------------------------------------------
-- testbench for online help (Z1013 mist project)
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library overlay;


entity online_help_tb is
end entity online_help_tb;


architecture testbench of online_help_tb is

    constant pixel_clock_period  : time := 1 sec / 60_000_000;

    signal simulation_run        : boolean := true;

    signal tb_active             : std_logic := '0';
    signal tb_pixel_clock        : std_logic := '0';
    --
    signal tb_red                : std_logic_vector( 5 downto 0);
    signal tb_green              : std_logic_vector( 5 downto 0);
    signal tb_blue               : std_logic_vector( 5 downto 0);
    signal tb_hsync              : std_logic;
    signal tb_vsync              : std_logic;
    --
    signal tb_red_out            : std_logic_vector( 5 downto 0);
    signal tb_green_out          : std_logic_vector( 5 downto 0);
    signal tb_blue_out           : std_logic_vector( 5 downto 0);
    signal tb_hsync_out          : std_logic;
    signal tb_vsync_out          : std_logic;

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

    -- online help
    dut: entity overlay.online_help 
    port map
    (
        active          =>  tb_active,       -- : in  std_logic;
        pixel_clock     =>  tb_pixel_clock,  -- : in  std_logic;
        -- input signals
        red             =>  tb_red,          -- : in  std_logic_vector( 5 downto 0);
        green           =>  tb_green,        -- : in  std_logic_vector( 5 downto 0);
        blue            =>  tb_blue,         -- : in  std_logic_vector( 5 downto 0);
        hsync           =>  tb_hsync,        -- : in  std_logic;
        vsync           =>  tb_vsync,        -- : in  std_logic;
        -- message stuff
        show_message    => '1',              -- : in  std_logic;    -- enable or disable message display
        message_en      => '0',              -- : in  std_logic;    -- 0->1 take new message character
        message         => ' ',              -- : in  character;
        message_restart => '0',              -- : in  std_logic;    -- restart with new message
        -- output signals
        red_out         =>  tb_red_out,      -- : out std_logic_vector( 5 downto 0);
        green_out       =>  tb_green_out,    -- : out std_logic_vector( 5 downto 0);
        blue_out        =>  tb_blue_out,     -- : out std_logic_vector( 5 downto 0);
        hsync_out       =>  tb_hsync_out,    -- : out std_logic;
        vsync_out       =>  tb_vsync_out     -- : out std_logic
    );

end architecture testbench;
