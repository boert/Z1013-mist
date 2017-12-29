----------------------------------------------------------------------------------
-- testbench for scancode to ascii conversaiotn (Z1013 mist project)
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


entity scancode_tb is
end entity scancode_tb;


architecture testbench of scancode_tb is

    constant clk_period         : time          := (1 sec / 10_000_000);
    signal simulation_run       : boolean       := true;

    -- helpers
    procedure toggle( signal s : out std_logic) is
    begin
        s <= '1';
        wait for clk_period;
        s <= '0';
        wait for clk_period;
    end procedure toggle;

    signal tb_clk               : std_logic     := '0';
    signal tb_scancode          : std_logic_vector( 7 downto 0) := x"00";
    signal tb_scancode_en       : std_logic     := '0';
    --                          
    signal tb_layout_select     : std_logic     := '0';  -- 0 = en, 1 = de
    --                                                  
    signal tb_ascii             : std_logic_vector( 7 downto 0);
    signal tb_ascii_press       : std_logic;
    signal tb_ascii_release     : std_logic;


begin

    tb_clk <= not tb_clk after clk_period / 2 when simulation_run;


    scancode_ascii_inst : entity support.scancode_ascii
    port map
    (
        clk           =>  tb_clk,            -- : in    std_logic;
        --
        scancode      =>  tb_scancode,       -- : in    std_logic_vector( 7 downto 0);
        scancode_en   =>  tb_scancode_en,    -- : in    std_logic;
        --
        layout_select =>  tb_layout_select,  -- : in    std_logic;  -- 0 = en, 1 = de
        --
        ascii         =>  tb_ascii,          -- : out   std_logic_vector( 7 downto 0);
        ascii_press   =>  tb_ascii_press,    -- : out   std_logic;
        ascii_release =>  tb_ascii_release   -- : out   std_logic;
    );
    
    stimuli: process
    begin
        wait for 3 * clk_period;

        -- press
        tb_scancode <= x"e0";
        toggle( tb_scancode_en);
        
        tb_scancode <= x"14";
        toggle( tb_scancode_en);
        
        wait for 5 * clk_period;
        
        tb_scancode <= x"1c";
        toggle( tb_scancode_en);
        
        wait for 15 * clk_period;

        -- release
        tb_scancode <= x"f0";
        toggle( tb_scancode_en);

        tb_scancode <= x"1c";
        toggle( tb_scancode_en);

        tb_scancode <= x"e0";
        toggle( tb_scancode_en);
        
        tb_scancode <= x"f0";
        toggle( tb_scancode_en);

        tb_scancode <= x"14";
        toggle( tb_scancode_en);


        wait for 25 * clk_period;

        -- press
        tb_scancode <= x"29";
        toggle( tb_scancode_en);
        
        wait for 15 * clk_period;

        -- release
        tb_scancode <= x"f0";
        toggle( tb_scancode_en);

        tb_scancode <= x"29";
        toggle( tb_scancode_en);


        wait for 25 * clk_period;

        -- press
        tb_scancode <= x"59";
        toggle( tb_scancode_en);

        -- press
        tb_scancode <= x"1c";
        toggle( tb_scancode_en);
        
        wait for 15 * clk_period;

        -- release
        tb_scancode <= x"f0";
        toggle( tb_scancode_en);

        tb_scancode <= x"59";
        toggle( tb_scancode_en);
        
        wait for 5 * clk_period;

        -- release
        tb_scancode <= x"f0";
        toggle( tb_scancode_en);

        tb_scancode <= x"1c";
        toggle( tb_scancode_en);

        simulation_run <= false;
        wait;

    end process;

end architecture testbench;
