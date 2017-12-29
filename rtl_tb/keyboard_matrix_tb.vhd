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
    signal tb_ascii_clk       : std_logic   := '0';
    signal tb_reset_n         : std_logic   := '1';
    signal tb_ascii           : std_logic_vector( 7 downto 0);
    signal tb_ascii_press     : std_logic   := '0';
    signal tb_ascii_release   : std_logic   := '0';


begin

    tb_clk          <= not tb_clk after clk_period / 2 when simulation_run;
    tb_ascii_clk    <= tb_clk;

    keyboard_matrix_inst : entity work.keyboard_matrix
    port map
    (
        -- Z1013 side
        clk            => tb_clk,             -- : in    std_logic;
        column         => tb_column,          -- : in    std_logic_vector( 7 downto 0);
        column_en_n    => tb_column_en_n,     -- : in    std_logic;
        row            => tb_row,             -- : out   std_logic_vector( 7 downto 0);  -- to PIO port B
        -- ascii input                        
        ascii_clk      => tb_ascii_clk,       -- : in    std_logic;
        reset_n        => tb_reset_n,         -- : in    std_logic;
        ascii          => tb_ascii,           -- : in    std_logic_vector( 7 downto 0);
        ascii_press    => tb_ascii_press,     -- : in    std_logic;
        ascii_release  => tb_ascii_release    -- : in    std_logic;
    );
   

    stimuli: process
    begin
        wait for 20 * clk_period;

        tb_ascii <= x"0d";

        press_key( tb_ascii_press, tb_ascii_release);
        wait for 20 * clk_period;
       
        release_key( tb_ascii_press, tb_ascii_release);
        
        wait for 20 * clk_period;
        wait for 20 * clk_period;


        tb_ascii <= std_logic_vector( to_unsigned( character'pos( 'Z'), 8));

        press_key( tb_ascii_press, tb_ascii_release);
        wait for 20 * clk_period;
       
        release_key( tb_ascii_press, tb_ascii_release);
        
        wait for 20 * clk_period;
        wait for 20 * clk_period;



        tb_ascii <= x"f1";

        press_key( tb_ascii_press, tb_ascii_release);
        wait for 20 * clk_period;
       
        release_key( tb_ascii_press, tb_ascii_release);
        
        wait for 20 * clk_period;
        wait for 20 * clk_period;

        simulation_run <= false;
        wait;

    end process;

end architecture testbench;

