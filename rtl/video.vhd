------------------------------------------------------------------------------
-- Project    : Red Zombie
------------------------------------------------------------------------------
-- File       :  bm204_empty_pkg.vhd
-- Author     :  fpgakuechle
-- Company    : hobbyist
-- Created    : 2012-12
-- Last update: 2013-05-28
-- Licence    : GNU General Public License (http://www.gnu.de/documents/gpl.de.html) 
------------------------------------------------------------------------------
-- Description: 
--Video subsysten
--Video ram, character,rom, display output
--Z1013 display is 32 x 32 xharactes on a 8x8 font
--output format here is 800x600 pixel
--the z1013 display will stretched to 512x512 (ever font-element quadrupelt)
--and placed at 1st line starting at hor. pos 44
------------------------------------------------------------------------------
--Status: dimensions OK, same ghost pixels and a ghost pixel line 
-----------------------------------------------------------------------------
-- Bert Lange, 2018
-- - refactor
-- - add second character set
-- - change video timing to 1200x600 (with sync timing of 800x600)
--   to make 64x16 mode possible
--
library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;
use work.pkg_redz0mb1e.all;

entity video is
    generic
    (
        G_ReadOnly  : boolean := FALSE -- fixes Bild aus initialisierten videoram
    );
    port
    (
        clk         : in  std_logic;
        rst_i       : in  std_logic;
        -- cpu port to video memory
        cs_ni       : in  std_logic;
        we_ni       : in  std_logic;
        data_i      : in  std_logic_vector(7 downto 0);
        data_o      : out std_logic_vector(7 downto 0);
        addr_i      : in  std_logic_vector(9 downto 0);
        romsel_i    : in  std_logic;  
        mode64x16_i : in  std_logic;
        -- vga clock
        video_clk   : in  std_logic;
        -- vga output
        red_o       : out std_logic;
        blue_o      : out std_logic;
        green_o     : out std_logic;
        vsync_o     : out std_logic;
        hsync_o     : out std_logic;
        --
        col_fg      : in  T_COLOR;
        col_bg      : in  T_COLOR
    );
end entity video;

architecture behave of video is
    
    -- factor for changed horizontal timing (pixel_clk/40MHz = 1.5)
    function xFACTOR( x : integer) return integer is
    begin
        return x + x / 2;
    end function;

    -- constants for screen position
    constant HSTART32   : natural   := xFACTOR( 120);
    constant HSTART64   : natural   := 72;
    constant HRESET     : natural   := xFACTOR( 820);
    constant VSTART     : natural   := 44;
    constant COLRESET   : natural   := xFACTOR( 899);


    -- readonly port to video, --(address bus character rom)
    signal vram_video_addr      : std_logic_vector(9 downto 0):= (others => '0');
    signal data4crom            : std_logic_vector(7 downto 0);
    signal data4crom1           : std_logic_vector(7 downto 0);
    signal data4crom2           : std_logic_vector(7 downto 0);
    -- adress pointer to character rom
    --     charcter code feeded from videoram                                                                   
    signal crom_index_high      : std_logic_vector(7 downto 0);--:= (others => '0'); 
    signal blank_area           : std_logic;
    signal blank_line           : std_logic;
    
    -- video 800 x 600
    -- from svga signal generator 
    signal hcount               : unsigned(10 downto 0);
    signal vcount               : unsigned(10 downto 0);
    
    -- character 
    signal col_stretch          : natural range 0 to 2 := 0; 
                                                    -- every 3nd videoclock, used for horizontal stretching 32x32
                                                    -- every 2nd videoclock, used for horizontal stretching 64x16
    signal row_stretch          : boolean := false; -- true every 2nd row, used for vertival stretching
    signal col_fg_q, col_bg_q   : T_COLOR;
  
    signal pixel_col_q          : std_logic_vector(2 downto 0);
    signal pixel                : std_logic;

    -- a line of 8 pixels in a character
    signal char_line_q          : std_logic_vector(7 downto 0):= (others => '0');
  
    -- counting character hor. and vertical
 
    -- row within character --(8), incrementat every line
    signal rowInChar_cnt_q      : unsigned( 2 downto 0) := "000";
    signal colInChar_cnt_q      : unsigned( 2 downto 0) := "000";
    -- count all characters in a row
    signal CharCol_cnt_q        : unsigned(6 downto 0):= ( others => '1');  -- stopped
    signal CharRow_cnt_q        : unsigned(5 downto 0):= "100000";          -- stopped
 
    signal next_char_right      : boolean;
    signal vram_video_data      : std_logic_vector(7 downto 0);
    signal char_area            : std_logic;

    -- for 64x16 mode switching
    signal char_per_line        : natural range 0 to 64;
    signal stretch_factor       : natural range 0 to 2;
    signal hstart               : natural range 0 to HSTART32;

begin

    -- character ROM
    char_rom_1: entity work.char_rom
    port map (
        clk         => video_clk,
        data_o      => data4crom1,
        addr_char_i => crom_index_high,
        addr_line_i => std_logic_vector( rowInChar_cnt_q)
    );

    -- additional character ROM
    char_rom_2: entity work.charrom2
    port map (
        clk         => video_clk,
        data_o      => data4crom2,
        addr_char_i => crom_index_high,
        addr_line_i => std_logic_vector( rowInChar_cnt_q) 
    );

    -- select character ROM
    data4crom <= data4crom2 when romsel_i = '1' else data4crom1;

    video_ram_1: entity work.video_ram
    generic map
    (
        G_READONLY => G_READONLY
    )
    port map
    (
        cpu_clk      => clk,
        cpu_cs_ni    => cs_ni,
        cpu_we_ni    => we_ni,
        cpu_addr_i   => addr_i(9 downto 0),
        cpu_data_o   => data_o,
        cpu_data_i   => data_i,
        video_clk    => video_clk,
        video_addr_i => vram_video_addr,
        video_data_o => vram_video_data
    );
   
    -- read pointer to video ram
    process( CharRow_cnt_q, CharCol_cnt_q, mode64x16_i)
    begin
        if mode64x16_i = '0' then
            vram_video_addr   <= std_logic_vector(CharRow_cnt_q(4 downto 0) & CharCol_cnt_q(4 downto 0));
        else
            vram_video_addr   <= std_logic_vector(CharRow_cnt_q(4 downto 1) & CharCol_cnt_q(5 downto 0));
        end if;
    end process;
    
    -- changes for 64x16 mode
    char_per_line   <= 32       when mode64x16_i = '0' else 64;
    stretch_factor  <= 2        when mode64x16_i = '0' else  1;
    hstart          <= HSTART32 when mode64x16_i = '0' else HSTART64;
    blank_line      <= '0'      when mode64x16_i = '0' else CharRow_cnt_q( 0);

    -- video generation
    process
    begin
        wait until rising_edge( video_clk);
        -- horizontal
        -- colInChar 
        -- CharCol
        if hcount = hstart then
            CharCol_cnt_q <= (others => '0');
        elsif next_char_right and (col_stretch = 0) then
            if CharCol_cnt_q < char_per_line then   -- count until 32 chars, then stop
                CharCol_cnt_q <= CharCol_cnt_q + 1;
            end if;

            if CharRow_cnt_q < 32 and CharCol_cnt_q < char_per_line then
                char_area <= '1';
            else
                char_area <= '0';
            end if;
        end if;
       
        if hcount = hstart then
            colInChar_cnt_q <= "000";
            next_char_right <= false;
        else
            if col_stretch = 0 then
                if colInChar_cnt_q = 7 then
                    colInChar_cnt_q <= "000";
                    next_char_right <= true;
                    -- character code from videoram
                    crom_index_high <= vram_video_data;
                else
                    colInChar_cnt_q <= colInChar_cnt_q + 1;
                    next_char_right <= FALSE;
                end if;
            end if;
        end if;
       
        -- adress for crom increment
        -- vertical
        -- rowInChar
        if hcount = HRESET then
            if vcount = VSTART then
                row_stretch <= false;
            else
                row_stretch <= not row_stretch;
            end if;
            --
            if row_stretch then
                if rowInChar_cnt_q = 7 then
                    rowInChar_cnt_q <= "000";
                else
                    rowInChar_cnt_q <= rowInChar_cnt_q + 1;
                end if;
            end if;
        end if;

        -- CharRow
        if hcount = HRESET-1 then
            if vcount = VSTART then
                rowInChar_cnt_q <= "000";
                CharRow_cnt_q   <= (others => '0');
            elsif rowInChar_cnt_q = 7 and CharRow_cnt_q < 32 and row_stretch then
                CharRow_cnt_q <= CharRow_cnt_q + 1;
            end if;
        end if;
    end process;

    -- chipenable to stretch every pixel tree times in x direction 32x32
    -- chipenable to stretch every pixel two times in x direction 64x16
    process
    begin
        wait until rising_edge( video_clk);
        if hcount = COLRESET then
            col_stretch <= stretch_factor;
        else
            if col_stretch > 0 then
                col_stretch <= col_stretch - 1;
            else
                col_stretch <= stretch_factor;
            end if;
        end if;
    end process;
   
    -- serialize character rom
    process
    begin
        wait until rising_edge( video_clk);
        if col_stretch = 0 then  
            if next_char_right then
                char_line_q <= data4crom;
            else
                char_line_q(7 downto 0) <= char_line_q(6 downto 0) & '0';
            end if;
        end if;
    end process;

    pixel <= char_line_q( 7);

    -- color the pixel
    process
    begin
        wait until rising_edge( video_clk);
        -- sync in, prevent foreground color = background_colour    
        col_bg_q <= col_bg;
        if col_bg = col_fg then
            col_fg_q(0) <= not col_fg(0);
            col_fg_q(1) <=     col_fg(1);
            col_fg_q(2) <=     col_fg(2);
        else
            col_fg_q(0) <=     col_fg(0);
            col_fg_q(1) <=     col_fg(1);
            col_fg_q(2) <=     col_fg(2);
        end if;
       
        -- Foreground color only in visible area (32x32 characters)
        if blank_area = '0' then
            if char_area = '1' then
                if pixel = '1' and blank_line = '0' then
                    pixel_col_q <= col_fg_q;
                else
                    pixel_col_q <= col_bg_q;
                end if;
            else  -- out of 32x32 character area
                pixel_col_q <= "000";  --black out of 32x32 character araea
            end if;
        else
            pixel_col_q <= "000";
        end if;
    end process;

    blue_o   <= pixel_col_q(0);
    green_o  <= pixel_col_q(1);
    red_o    <= pixel_col_q(2);

    vga_controller_800_600_i0: entity work.vga_controller_800_600
    port map (
        rst       => '0',
        pixel_clk => video_clk,
        HS        => hsync_o,
        VS        => vsync_o,
        hcount    => hcount,
        vcount    => vcount,
        blank     => blank_area
    );

end architecture behave;
