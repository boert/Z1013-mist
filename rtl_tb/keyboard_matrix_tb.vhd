----------------------------------------------------------------------------------
-- testbench for stimulation ascii to Z1013-key-matrix conversation 
-- (Z1013 mist project)
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

entity keyboard_matrix_tb is
end entity keyboard_matrix_tb;


architecture testbench of keyboard_matrix_tb is

    constant clk_period       : time          := (1 sec / 10_000_000);
    signal simulation_run     : boolean       := true;

    -- helpers
    procedure press_key
    ( 
        signal p : out std_logic; 
        signal r : out std_logic
    ) is
    begin
        r <= '0';
        p <= '1';
        wait for clk_period;
        p <= '0';
        wait for clk_period;
    end procedure press_key;
        
    procedure release_key
    ( 
        signal p : out std_logic; 
        signal r : out std_logic
    ) is
    begin
        p <= '0';
        r <= '1';
        wait for clk_period;
        r <= '0';
        wait for clk_period;
    end procedure release_key;


    -- Z1013 side
    signal tb_clk             : std_logic   := '0';
    signal tb_column          : std_logic_vector( 7 downto 0) := x"00";
    signal tb_column_en_n     : std_logic   := '0';
    signal tb_row             : std_logic_vector( 7 downto 0);  -- to PIO port B
    -- ascii input
    signal tb_ascii           : std_logic_vector( 7 downto 0);
    signal tb_ascii_press     : std_logic   := '0';
    signal tb_ascii_release   : std_logic   := '0';


begin

    tb_clk          <= not tb_clk after clk_period / 2 when simulation_run;

    keyboard_matrix_inst : entity work.keyboard_matrix
    port map
    (
        clk            => tb_clk,             -- : in    std_logic;
        -- Z1013 side
        column         => tb_column,          -- : in    std_logic_vector( 7 downto 0);
        column_en_n    => tb_column_en_n,     -- : in    std_logic;
        row            => tb_row,             -- : out   std_logic_vector( 7 downto 0);  -- to PIO port B
        -- ascii input                        
        ascii          => tb_ascii,           -- : in    std_logic_vector( 7 downto 0);
        ascii_press    => tb_ascii_press,     -- : in    std_logic;
        ascii_release  => tb_ascii_release    -- : in    std_logic;
    );

    z1013: process
        variable column : natural range 0 to 7 := 0;
    begin
        if simulation_run then
            wait for 3 * clk_period;
            tb_column   <= std_logic_vector( to_unsigned( column, tb_column'length));

            -- enable pulse
            wait for 1 * clk_period;
            tb_column_en_n  <= '0';
            wait for 1 * clk_period;
            tb_column_en_n  <= '1';

            -- next column
            if column < 7 then
                column  := column + 1;
            else
                column  := 0;
            end if;
        else
            wait;
        end if;
    end process;
   

    stimuli: process
    begin
        report "press (and release) single keys";
        wait for 20 * clk_period;

        tb_ascii <= x"0d";
        press_key( tb_ascii_press, tb_ascii_release);
        wait for 200 * clk_period;
       
        release_key( tb_ascii_press, tb_ascii_release);
        wait for 500 * clk_period;


        tb_ascii <= x"20";
        press_key( tb_ascii_press, tb_ascii_release);
        wait for 200 * clk_period;
       
        release_key( tb_ascii_press, tb_ascii_release);
        wait for 500 * clk_period;


        tb_ascii <= std_logic_vector( to_unsigned( character'pos( 'X'), 8));
        press_key( tb_ascii_press, tb_ascii_release);
        wait for 200 * clk_period;
       
        release_key( tb_ascii_press, tb_ascii_release);
        wait for 500 * clk_period;


        report "press S1 key (mapped to F1)";
        tb_ascii <= x"f1";
        press_key( tb_ascii_press, tb_ascii_release);
        wait for 200 * clk_period;

        release_key( tb_ascii_press, tb_ascii_release);
        wait for 500 * clk_period;
        
        report "press multiple keys";
        tb_ascii <= std_logic_vector( to_unsigned( character'pos( 'q'), 8));
        press_key( tb_ascii_press, tb_ascii_release);
        wait for 200 * clk_period;

        tb_ascii <= std_logic_vector( to_unsigned( character'pos( 'S'), 8));
        press_key( tb_ascii_press, tb_ascii_release);

        wait for 500 * clk_period;

        tb_ascii <= std_logic_vector( to_unsigned( character'pos( 'q'), 8));
        release_key( tb_ascii_press, tb_ascii_release);
        wait for 200 * clk_period;

        tb_ascii <= std_logic_vector( to_unsigned( character'pos( 'S'), 8));
        release_key( tb_ascii_press, tb_ascii_release);
        
        wait for 500 * clk_period;

        report "press keys very fast";
        tb_ascii <= std_logic_vector( to_unsigned( character'pos( 'A'), 8));
        press_key( tb_ascii_press, tb_ascii_release);
        wait for 70 * clk_period;

        tb_ascii <= std_logic_vector( to_unsigned( character'pos( 'B'), 8));
        press_key( tb_ascii_press, tb_ascii_release);

        wait for 500 * clk_period;

        tb_ascii <= std_logic_vector( to_unsigned( character'pos( 'B'), 8));
        release_key( tb_ascii_press, tb_ascii_release);
        wait for 70 * clk_period;

        tb_ascii <= std_logic_vector( to_unsigned( character'pos( 'A'), 8));
        release_key( tb_ascii_press, tb_ascii_release);


        wait for 500 * clk_period;
        report "simulation end";
        simulation_run <= false;
        wait;

    end process;

end architecture testbench;

