----------------------------------------------------------------------------------
-- package for all components of overlay library
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

package overlay_package is


    component online_help is
        generic
        (
            init_message    : string := "Z1013.64"
        );
        port
        (
            active          : in  std_logic;
            pixel_clock     : in  std_logic;
            -- input signals
            red             : in  std_logic_vector( 5 downto 0);
            green           : in  std_logic_vector( 5 downto 0);
            blue            : in  std_logic_vector( 5 downto 0);
            hsync           : in  std_logic;
            vsync           : in  std_logic;
            -- message stuff
            show_message    : in  std_logic;    -- enable or disable message display
            message_en      : in  std_logic;    -- 0->1 take new message character
            message         : in  character;
            message_restart : in  std_logic;    -- restart with new message
            -- output signals
            red_out         : out std_logic_vector( 5 downto 0);
            green_out       : out std_logic_vector( 5 downto 0);
            blue_out        : out std_logic_vector( 5 downto 0);
            hsync_out       : out std_logic;
            vsync_out       : out std_logic
        );
    end component online_help;


    component scanline is
        port
        (
            active      : in  std_logic;
            pixel_clock : in  std_logic;
            -- input signals
            red         : in  std_logic_vector( 5 downto 0);
            green       : in  std_logic_vector( 5 downto 0);
            blue        : in  std_logic_vector( 5 downto 0);
            hsync       : in  std_logic;
            vsync       : in  std_logic;
            -- output signals
            red_out     : out std_logic_vector( 5 downto 0);
            green_out   : out std_logic_vector( 5 downto 0);
            blue_out    : out std_logic_vector( 5 downto 0);
            hsync_out   : out std_logic;
            vsync_out   : out std_logic
        );
    end component scanline;


end package overlay_package;
