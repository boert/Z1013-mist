------------------------------------------------------------
-- package for all components of support library
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
------------------------------------------------------------

package support_package is


    component auto_start is
        generic
        (
            clk_frequency   : natural := 4000000
        );
        port
        (
            clk             : in    std_logic;
            enable          : in    std_logic;
            --
            autostart_addr  : in    std_logic_vector(15 downto 0);
            autostart_en    : in    std_logic;    -- start signal
            -- emulated keypresses
            active          : out   std_logic;
            ascii           : out   std_logic_vector( 7 downto 0);
            ascii_press     : out   std_logic;
            ascii_release   : out   std_logic
        );
    end component auto_start;


    component clock_blink is
      generic(
        G_TICKS_PER_SEC : integer := 10000
        );
      port(
        clk     : in  std_logic;
        blink_o : out std_logic);
    end component clock_blink;


    component headersave_decode is
        generic
        (
            clk_frequency   : natural := 4000000
        );
        port
        (
            clk             : in    std_logic;
            -- interface from data_io
            downloading     : in    std_logic;              -- signal indication an active download
            wr              : in    std_logic;
            addr            : in    std_logic_vector(24 downto 0);
            data            : in    std_logic_vector(7 downto 0);
            -- interface to memory
            downloading_out : out   std_logic;
            wr_out          : out   std_logic;
            addr_out        : out   std_logic_vector(15 downto 0);  -- z1013 has only 64k addressspace
            data_out        : out   std_logic_vector(7 downto 0);
            -- interface to message display
            show_message    : out   std_logic;    -- enable or disable message display
            message_en      : out   std_logic;    -- 0->1 take new message character
            message         : out   character;
            message_restart : out   std_logic;    -- restart with new message
            -- autostart support signals
            autostart_addr  : out   std_logic_vector(15 downto 0);
            autostart_en    : out   std_logic     -- start signal
        );
    end component headersave_decode;


    component ps2_scancode is
        port
        (
            clk            : in    std_ulogic;
            --             
            ps2_data       : in    std_logic;
            ps2_clock      : in    std_logic;
            --
            scancode       : out   std_logic_vector( 7 downto 0);
            scancode_en    : out   std_logic
        );
    end component ps2_scancode;


    component scancode_ascii is
        port
        (
            clk             : in    std_logic;
            --
            scancode        : in    std_logic_vector( 7 downto 0);
            scancode_en     : in    std_logic;
            -- switch layout
            layout_select   : in    std_logic;  -- 0 = en, 1 = de
            --
            ascii           : out   std_logic_vector( 7 downto 0);
            ascii_press     : out   std_logic;
            ascii_release   : out   std_logic
        );
    end component scancode_ascii;


end package support_package;
