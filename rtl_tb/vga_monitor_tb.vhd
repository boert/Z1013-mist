----------------------------------------------------------------------------------
-- testbench, simulate a vga monitor and save single frames
-- ppm (pixmap) or bpm
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

library std;
use std.textio.all;


entity vga_monitor_tb is
    generic
    (
        file_name_prefix : string := "frame_"
    );
    port
    (
        simulation_run : in  boolean := true;
        red            : in  std_logic_vector(7 downto 0);
        green          : in  std_logic_vector(7 downto 0);
        blue           : in  std_logic_vector(7 downto 0);
        h_sync         : in  std_logic;
        v_sync         : in  std_logic
    );
end entity vga_monitor_tb;


architecture testbench of vga_monitor_tb is


--  constant pixel_clock_period : time := 141 ns; -- zu schnell
--  constant pixel_clock_period : time := 248 ns;
    constant pixel_clock_period : time := 669 ns; -- super!

    -- define the maximum picture dimensions
    constant max_width  : natural := 800;
    constant max_height : natural := 600;

    type     rgb_t is record
        red   : natural range 0 to 255;
        green : natural range 0 to 255;
        blue  : natural range 0 to 255;
    end record;
    type     image_t is array( natural range <>, natural range <>) of rgb_t;


    signal   pixel_clock : std_ulogic := '0';
    signal   h_sync_old  : std_logic;
    signal   v_sync_old  : std_logic;


    --------------------------------------------------------------------------
    -- helper function to avoid metavalues warnings
    function to01( i : std_logic_vector) return std_logic_vector is
        variable result : std_logic_vector( i'range);
    begin
        for index in i'range loop
            if i( index) = '1' then
                result( index) := '1';
            else
                result( index) := '0';
            end if;
        end loop;
        return result;
    end function;

        
    --------------------------------------------------------------------------
    -- type definition
    type     charfile_t is file of character;

    --------------------------------------------------------------------------
    -- write a byte to character file
    procedure write_byte( file f : charfile_t; i : integer) is
    begin
        write( f, character'val( i));
    end procedure;
    
    --------------------------------------------------------------------------
    -- write a string to character file
    procedure write_string( file f : charfile_t; s : string) is
    begin
        for i in s'range loop
            write( f, s(i) ); 
        end loop;
    end procedure;

    --------------------------------------------------------------------------
    -- write a word (2 byte) to character file
    procedure write_word( file f : charfile_t; i : integer) is
    begin
        write( f, character'val(( i ) mod 256));
        write( f, character'val(( i / 256) mod 256));
    end procedure;

    --------------------------------------------------------------------------
    -- write a double word (4 byte) to character file
    procedure write_dword( file f : charfile_t; i : integer) is
    begin
        write( f, character'val(( i ) mod 256));
        write( f, character'val(( i / 256) mod 256));
        write( f, character'val(( i / 65536) mod 256));
        write( f, character'val(( i / (256 * 65536)) mod 256));
    end procedure;

    --------------------------------------------------------------------------
    -- helper function to check and cut image dimensions
    procedure dimension_check(
        width  : inout natural;
        height : inout natural
        ) is
    begin
        if width > max_width then
            report "image width cutted from " & integer'image( width) & " to " & integer'image( max_width) severity warning;
            width := max_width;
        end if;
        if height > max_height then
            report "image height cutted from " & integer'image( height) & " to " & integer'image( max_height) severity warning;
            height := max_height;
        end if;
    end procedure;



    procedure image_write_ppm
    ( 
        filename      : string; 
        width, height : inout natural;
        image         : image_t
    ) is
        file     image_file     : charfile_t;
    begin
        dimension_check( width, height);
        report "write image file: " & filename & "  size: " & integer'image( width) & " x " & integer'image( height);
        file_open( image_file, filename, write_mode);
        write_string( image_file, "P6");
        write( image_file, lf);
        write_string( image_file, integer'image( width));
        write( image_file, lf);
        write_string( image_file, integer'image( height));
        write( image_file, lf);
        write_string( image_file, "255");
        write( image_file, lf);

        for y in 0 to height-1 loop
            for x in 0 to width-1 loop
                write_byte( image_file, image( x, y).red);
                write_byte( image_file, image( x, y).green);
                write_byte( image_file, image( x, y).blue);
            end loop;
        end loop;
        
        file_close( image_file);
    end procedure;


    procedure image_write_bpm
    ( 
        filename      : string; 
        width, height : inout natural;
        image         : image_t
    ) is
        constant BI_RGB         : integer := 0;
        file     image_file     : charfile_t;
        variable fill           : natural;
        variable size           : natural;
    begin
        dimension_check( width, height);
        report "write image file: " & filename & "  size: " & integer'image( width) & " x " & integer'image( height);
        size := width * height * 3;
        -- fill up line to make it a multiple of 4
        -- x mod 4 = 0 --> 0 
        -- x mod 4 = 3 --> 1 
        -- x mod 4 = 2 --> 2 
        -- x mod 4 = 1 --> 3 
        fill := (width * 3) mod 4;
        if fill > 0 then
            fill := 4 - fill;
        end if;
        file_open( image_file, filename, write_mode);

        -- http://de.wikipedia.org/wiki/Windows_Bitmap 
        
        -- bitmap file header (14 Byte)
        write_string( image_file, "BM");        -- bfType
        write_dword( image_file, 14 + 40 + size + fill * height); -- bfSize
        write_dword( image_file, 0);            -- bfReserved
        write_dword( image_file, 54);           -- bfOffBits
        
        -- bitmap info header (40 Byte)         
        write_dword( image_file, 40);           -- biSize
        write_dword( image_file, width);        -- biWidth
        write_dword( image_file, height);       -- biHeight
        write_word( image_file, 1);             -- biPlanes
        write_word( image_file, 24);            -- biBitCount
        write_dword( image_file, BI_RGB);       -- biCompression
        write_dword( image_file, size);         -- biSizeImage
        write_dword( image_file, 0);            -- biXPelsPerMeter
        write_dword( image_file, 0);            -- biYPelsPerMeter
        write_dword( image_file, 0);            -- biClrUsed
        write_dword( image_file, 0);            -- biClrImportant

        -- no color msk
        -- no color table
        -- picture data
        for y in height-1 downto 0 loop
            for x in 0 to width-1 loop
                write_byte( image_file, image( x, y).blue);
                write_byte( image_file, image( x, y).green);
                write_byte( image_file, image( x, y).red);
            end loop;
            -- fill up line to make it a multiple of 4
            for i in 1 to fill loop
                write_byte( image_file, 0);
            end loop;
        end loop;
        
        file_close( image_file);
    end procedure;

begin

    pixel_clock <= not pixel_clock after pixel_clock_period / 2 when simulation_run;
    
    catch_picture: process
        variable h_sync_rising  : boolean;
        variable h_sync_falling : boolean;
        variable v_sync_rising  : boolean;
        variable v_sync_falling : boolean;
        --
        variable red_int        : integer;
        variable green_int      : integer;
        variable blue_int       : integer;
        --
        variable image          : image_t( 0 to max_width-1, 0 to max_height-1);
        variable pixelcount     : integer := 0;
        variable linecount      : integer := 0;
        --
        variable frame_count    : integer := 0;
    begin
        
        -- do stuff on pixelclock
        wait until rising_edge( pixel_clock);

        -- sync edge detectors
        h_sync_rising := false;
        if h_sync_old = '0' and h_sync = '1' then
            h_sync_rising := true;
        end if;
        h_sync_falling := false;
        if h_sync_old = '1' and h_sync = '0' then
            h_sync_falling := true;
        end if;

        v_sync_rising := false;
        if v_sync_old = '0' and v_sync = '1' then
            v_sync_rising := true;
        end if;
        v_sync_falling := false;
        if v_sync_old = '1' and v_sync = '0' then
            v_sync_falling := true;
        end if;



        -- counters
        if v_sync_falling then

            -- write image file
            image_write_bpm( file_name_prefix & integer'image( frame_count) & ".bpm", pixelcount, linecount, image);

            frame_count := frame_count + 1;
            linecount   := 0;
        end if;

        if h_sync_falling then
            if v_sync = '1' then
                linecount  := linecount + 1;
            end if;
        end if;
        
        if h_sync_rising then
            if v_sync = '1' then
                pixelcount := 0;
            end if;
        end if;


        -- data conversion
        if v_sync = '1' and h_sync = '1' then
            red_int    := to_integer( unsigned( to01( red)));
            green_int  := to_integer( unsigned( to01( green)));
            blue_int   := to_integer( unsigned( to01( blue)));

--      report "red   " & integer'image( red_int) &
--             "  green " & integer'image( green_int) &
--             "  blue  " & integer'image( blue_int);

            if pixelcount < max_width and linecount < max_height then
                image( pixelcount, linecount).red   := red_int;
                image( pixelcount, linecount).green := green_int;
                image( pixelcount, linecount).blue  := blue_int;
            end if;

            pixelcount := pixelcount + 1;
        end if;

        h_sync_old <= h_sync;
        v_sync_old <= v_sync;

    end process;

end architecture testbench;
