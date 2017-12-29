----------------------------------------------------------------------------------
-- emulate keypress on Z1013 keyboard matrix
-- input is ascii
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


entity keyboard_matrix is
    port
    (
        -- Z1013 side
        clk             : in    std_logic;
        column          : in    std_logic_vector( 7 downto 0);
        column_en_n     : in    std_logic;
        row             : out   std_logic_vector( 7 downto 0);  -- to PIO port B
        -- ascii input
        ascii_clk       : in    std_logic;
        reset_n         : in    std_logic;
        ascii           : in    std_logic_vector( 7 downto 0);
        ascii_press     : in    std_logic;
        ascii_release   : in    std_logic
    );
end entity keyboard_matrix;


architecture rtl of keyboard_matrix is

    -- delay between S1..4 and other keypress
    function delay_max return integer is
    begin
        -- pragma translate_off
        return 10;                         -- some ticks for simulation
        -- pragma translate_on
        return 10 * 4_000_000 / 1_000;     -- 10 ms for synthesis
    end function delay_max;

    type matrix_t is array( 0 to 9) of std_logic_vector( 3 downto 0);

    signal selected_column  : natural range 0 to 9;
    signal matrix           : matrix_t  := ( others => ( others => '0'));
    signal s_keys           : std_logic_vector( 3 downto 0) := ( others => '0');

    type key_entry_t is record
        active  : std_logic;
        column  : natural range 0 to 9;
        row     : natural range 0 to 3;
        s_keys  : std_logic_vector( 0 to 3);
    end record;
    type key_table_t is array( natural range <>) of key_entry_t;

    -- S1 Buchstaben XYZ, Zahlen, Sonderzeichen
    -- S2 wie S1 und S3
    -- S3 = shift (Kleinbuchstaben)
    -- S4 = control
    constant ascii_key_table : key_table_t( 0 to 255) := (
        -- 0x00, Z1 S4
        16#00# => ( '1', 0, 1, "0001"),
        16#01# => ( '1', 1, 1, "0001"),
        16#02# => ( '1', 2, 1, "0001"),
        16#03# => ( '1', 3, 1, "0001"),
        16#04# => ( '1', 4, 1, "0001"),
        16#05# => ( '1', 5, 1, "0001"),
        16#06# => ( '1', 6, 1, "0001"),
        16#07# => ( '1', 7, 1, "0001"),
        -- 0x08, Z2 S4
        16#08# => ( '1', 4, 3, "0000"), -- links,  ( '1', 0, 2, "0001"),
        16#09# => ( '1', 6, 3, "0000"), -- rechts, ( '1', 1, 2, "0001"),
        16#0a# => ( '1', 2, 2, "0001"),
        16#0b# => ( '1', 3, 2, "0001"),
        16#0c# => ( '1', 4, 2, "0001"),
        16#0d# => ( '1', 7, 3, "0000"), -- enter,  ( '1', 5, 2, "0001"),
        16#0e# => ( '1', 6, 2, "0001"),
        16#0f# => ( '1', 7, 2, "0001"),
        -- 0x10, Z0 S4
        16#10# => ( '1', 0, 0, "0001"),
        16#11# => ( '1', 1, 0, "0001"),
        16#12# => ( '1', 2, 0, "0001"),
        16#13# => ( '1', 3, 0, "0001"),
        16#14# => ( '1', 4, 0, "0001"),
        16#15# => ( '1', 5, 0, "0001"),
        16#16# => ( '1', 6, 0, "0001"),
        16#17# => ( '1', 7, 0, "0001"),
        -- 0x18
        16#18# => ( '0', 0, 0, "0001"),
        16#19# => ( '0', 1, 0, "0001"),
        16#1a# => ( '0', 2, 0, "0001"),
        16#1b# => ( '0', 3, 0, "0001"),
        16#1c# => ( '0', 4, 0, "0001"),
        16#1d# => ( '0', 5, 0, "0001"),
        16#1e# => ( '0', 6, 0, "0001"),
        16#1f# => ( '0', 7, 0, "0001"),
        -- 0x20, Z1 S2
        16#20# => ( '1', 0, 1, "0100"),
        16#21# => ( '1', 1, 1, "0100"),
        16#22# => ( '1', 2, 1, "0100"),
        16#23# => ( '1', 3, 1, "0100"),
        16#24# => ( '1', 4, 1, "0100"),
        16#25# => ( '1', 5, 1, "0100"),
        16#26# => ( '1', 6, 1, "0100"),
        16#27# => ( '1', 7, 1, "0100"),
        -- 0x28, Z2 S2
        16#28# => ( '1', 0, 2, "0100"),
        16#29# => ( '1', 1, 2, "0100"),
        16#2a# => ( '1', 2, 2, "0100"),
        16#2b# => ( '1', 3, 2, "0100"),
        16#2c# => ( '1', 4, 2, "0100"),
        16#2d# => ( '1', 5, 2, "0100"),
        16#2e# => ( '1', 6, 2, "0100"),
        16#2f# => ( '1', 7, 2, "0100"),
        -- 0x30, Z1 S1
        16#30# => ( '1', 0, 1, "1000"),
        16#31# => ( '1', 1, 1, "1000"),
        16#32# => ( '1', 2, 1, "1000"),
        16#33# => ( '1', 3, 1, "1000"),
        16#34# => ( '1', 4, 1, "1000"),
        16#35# => ( '1', 5, 1, "1000"),
        16#36# => ( '1', 6, 1, "1000"),
        16#37# => ( '1', 7, 1, "1000"),
        -- 0x38, Z2 S1
        16#38# => ( '1', 0, 2, "1000"),
        16#39# => ( '1', 1, 2, "1000"),
        16#3a# => ( '1', 2, 2, "1000"),
        16#3b# => ( '1', 3, 2, "1000"),
        16#3c# => ( '1', 4, 2, "1000"),
        16#3d# => ( '1', 5, 2, "1000"),
        16#3e# => ( '1', 6, 2, "1000"),
        16#3f# => ( '1', 7, 2, "1000"),
        -- 0x40, Z0 ohne shift
        16#40# => ( '1', 0, 0, "0000"),
        16#41# => ( '1', 1, 0, "0000"),
        16#42# => ( '1', 2, 0, "0000"),
        16#43# => ( '1', 3, 0, "0000"),
        16#44# => ( '1', 4, 0, "0000"),
        16#45# => ( '1', 5, 0, "0000"),
        16#46# => ( '1', 6, 0, "0000"),
        16#47# => ( '1', 7, 0, "0000"),
        -- 0x48, Z1 ohne shift
        16#48# => ( '1', 0, 1, "0000"),
        16#49# => ( '1', 1, 1, "0000"),
        16#4a# => ( '1', 2, 1, "0000"),
        16#4b# => ( '1', 3, 1, "0000"),
        16#4c# => ( '1', 4, 1, "0000"),
        16#4d# => ( '1', 5, 1, "0000"),
        16#4e# => ( '1', 6, 1, "0000"),
        16#4f# => ( '1', 7, 1, "0000"),
        -- 0x50, Z2 ohne shift
        16#50# => ( '1', 0, 2, "0000"),
        16#51# => ( '1', 1, 2, "0000"),
        16#52# => ( '1', 2, 2, "0000"),
        16#53# => ( '1', 3, 2, "0000"),
        16#54# => ( '1', 4, 2, "0000"),
        16#55# => ( '1', 5, 2, "0000"),
        16#56# => ( '1', 6, 2, "0000"),
        16#57# => ( '1', 7, 2, "0000"),
        -- 0x58, Z0 S1
        16#58# => ( '1', 0, 0, "1000"),
        16#59# => ( '1', 1, 0, "1000"),
        16#5a# => ( '1', 2, 0, "1000"),
        16#5b# => ( '1', 3, 0, "1000"),
        16#5c# => ( '1', 4, 0, "1000"),
        16#5d# => ( '1', 5, 0, "1000"),
        16#5e# => ( '1', 6, 0, "1000"),
        16#5f# => ( '1', 7, 0, "1000"),
        -- 0x60, Z0 S3
        16#60# => ( '1', 0, 0, "0010"),
        16#61# => ( '1', 1, 0, "0010"),
        16#62# => ( '1', 2, 0, "0010"),
        16#63# => ( '1', 3, 0, "0010"),
        16#64# => ( '1', 4, 0, "0010"),
        16#65# => ( '1', 5, 0, "0010"),
        16#66# => ( '1', 6, 0, "0010"),
        16#67# => ( '1', 7, 0, "0010"),
        -- 0x68, Z1 S3
        16#68# => ( '1', 0, 1, "0010"),
        16#69# => ( '1', 1, 1, "0010"),
        16#6a# => ( '1', 2, 1, "0010"),
        16#6b# => ( '1', 3, 1, "0010"),
        16#6c# => ( '1', 4, 1, "0010"),
        16#6d# => ( '1', 5, 1, "0010"),
        16#6e# => ( '1', 6, 1, "0010"),
        16#6f# => ( '1', 7, 1, "0010"),
        -- 0x70, Z2 S3
        16#70# => ( '1', 0, 2, "0010"),
        16#71# => ( '1', 1, 2, "0010"),
        16#72# => ( '1', 2, 2, "0010"),
        16#73# => ( '1', 3, 2, "0010"),
        16#74# => ( '1', 4, 2, "0010"),
        16#75# => ( '1', 5, 2, "0010"),
        16#76# => ( '1', 6, 2, "0010"),
        16#77# => ( '1', 7, 2, "0010"),
        -- 0x78, Z0 S2
        16#78# => ( '1', 0, 0, "0100"),
        16#79# => ( '1', 1, 0, "0100"),
        16#7a# => ( '1', 2, 0, "0100"),
        16#7b# => ( '1', 3, 0, "0100"),
        16#7c# => ( '1', 4, 0, "0100"),
        16#7d# => ( '1', 5, 0, "0100"),
        16#7e# => ( '1', 6, 0, "0100"),
        16#7f# => ( '1', 7, 0, "0100"),
        -- map functions keys to S-keys
        16#f1# => ( '1', 0, 3, "1000"),
        16#f2# => ( '1', 1, 3, "0100"),
        16#f3# => ( '1', 2, 3, "0010"),
        16#f4# => ( '1', 3, 3, "0001"),
        others => ( '0', 0, 0, "0000")
    );

    signal delay            : natural range 0 to delay_max - 1;
    signal apply_keypress   : std_logic;
    signal apply_keyrelease : std_logic;
    signal table_address    : integer range 0 to 255;
    signal table_entry      : key_entry_t;
    --
    signal key_press        : std_logic_vector( 3 downto 0);
    signal key_release      : std_logic_vector( 3 downto 0);

begin
    
    -- Z1013 readout
    -- software select a column and read 4 bits for every row on PIO B, Bits 3..0
    -- column decoder
    process
    begin
        wait until rising_edge( clk);
        -- latch selected column
        if column_en_n = '0' then
            selected_column <= to_integer( unsigned( column));
        end if;
    end process;

    process( selected_column, matrix, s_keys)
    begin
        case selected_column is
            when 0 =>
                row <= "1111" & not( s_keys( 0) & matrix( selected_column)(2 downto 0));
            when 1 =>                             
                row <= "1111" & not( s_keys( 1) & matrix( selected_column)(2 downto 0));
            when 2 =>                             
                row <= "1111" & not( s_keys( 2) & matrix( selected_column)(2 downto 0));
            when 3 =>                             
                row <= "1111" & not( s_keys( 3) & matrix( selected_column)(2 downto 0));
            when others =>
                row <= "1111" & not( matrix( selected_column));
        end case;
    end process;


    -- keyboard side
    -- cleared bits in matrix mean pressed key
    process 
    begin
        wait until rising_edge( ascii_clk);
        -- shift key events
        key_press       <= key_press( 2 downto 0)   & ascii_press;
        key_release     <= key_release( 2 downto 0) & ascii_release;

        -- read conversion table
        table_address   <= to_integer( unsigned( ascii));
        table_entry     <= ascii_key_table( table_address);
        
        if delay > 0 then
            delay <= delay - 1;
        end if;

        -- apply delayed keypress
        if delay = 1 then
            
            if apply_keypress = '1' then
                matrix( table_entry.column)( table_entry.row) <= '1';
            end if;
            
            if apply_keyrelease = '1' then
                matrix( table_entry.column)( table_entry.row) <= '0';
            end if;

        end if;

        
        if table_entry.active = '1' and ( key_press( 3) = '1' or key_release( 3) = '1') then
            -- activate main key later
            delay               <= delay_max - 1;
            apply_keypress      <= key_press( 3);
            apply_keyrelease    <= key_release( 3);

            -- press additional S1 key
            if table_entry.s_keys( 0) = '1' and key_press( 3) = '1' then
                s_keys( 0) <= '1';
            end if;
            if table_entry.s_keys( 0) = '1' and key_release( 3) = '1' then
                s_keys( 0) <= '0';
            end if;
            -- press additional S2 key
            if table_entry.s_keys( 1) = '1' and key_press( 3) = '1' then
                s_keys( 1) <= '1';
            end if;
            if table_entry.s_keys( 1) = '1' and key_release( 3) = '1' then
                s_keys( 1) <= '0';
            end if;
            -- press additional S3 key
            if table_entry.s_keys( 2) = '1' and key_press( 3) = '1' then
                s_keys( 2) <= '1';
            end if;
            if table_entry.s_keys( 2) = '1' and key_release( 3) = '1' then
                s_keys( 2) <= '0';
            end if;
            -- press additional S4 key
            if table_entry.s_keys( 3) = '1' and key_press( 3) = '1' then
                s_keys( 3) <= '1';
            end if;
            if table_entry.s_keys( 3) = '1' and key_release( 3) = '1' then
                s_keys( 3) <= '0';
            end if;
        end if;

        if reset_n = '0' then
            s_keys <= ( others => '0');
            matrix <= ( others => ( others => '0'));
            delay  <= 0;
        end if;
    end process;

end architecture rtl;
