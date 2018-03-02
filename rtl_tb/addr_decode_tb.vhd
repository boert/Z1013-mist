----------------------------------------------------------------------------------
-- testbench for addr_decode
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

library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;


entity addr_decode_tb is
end entity addr_decode_tb;


architecture testbench of addr_decode_tb is

    signal tb_addr           : std_logic_vector(15 downto 0);
    signal tb_ioreq_n        : std_logic := '1';
    signal tb_mreq_n         : std_logic := '1';
    signal tb_rfsh_n         : std_logic := '1';
    signal tb_rom_disable    : std_logic := '0';
    signal tb_we_F000        : std_logic := '0';
    signal tb_we_F800        : std_logic := '0';
    --
    signal tb_write_protect  : std_logic;
    signal tb_cs_mem_n       : std_logic_vector(3 downto 0);
    signal tb_cs_io_n        : std_logic_vector(3 downto 0);
    --
    --
    alias sel_vram_n         : std_logic is tb_cs_mem_n( 1);
    alias sel_rom_n          : std_logic is tb_cs_mem_n( 2);
    alias sel_ram_n          : std_logic is tb_cs_mem_n( 3);
    --
    alias sel_io_pio_n       : std_logic is tb_cs_io_n( 0);
    alias sel_io_1_n         : std_logic is tb_cs_io_n( 1);  
    alias sel_io_kybrow_n    : std_logic is tb_cs_io_n( 2);

begin

    dut: entity work.addr_decode
    port map
    (
        addr_i          => tb_addr,                 -- : in  std_logic_vector(15 downto 0);
        ioreq_ni        => tb_ioreq_n,              -- : in  std_logic;
        mreq_ni         => tb_mreq_n,               -- : in  std_logic;
        rfsh_ni         => tb_rfsh_n,               -- : in  std_logic;
        rom_disable     => tb_rom_disable,          -- : in  std_logic;
        we_F000         => tb_we_F000,              -- : in  std_logic;
        we_F800         => tb_we_F800,              -- : in  std_logic;
        --
        write_protect   => tb_write_protect,        -- : out std_logic;
        cs_mem_no       => tb_cs_mem_n,             -- : out std_logic_vector(3 downto 0);--low active
        cs_io_no        => tb_cs_io_n               -- : out std_logic_vector(3 downto 0)  --low active
    );

    main: process
    begin

        tb_mreq_n   <= '0';
        for address in 0 to 65535 loop
            wait for 10 ns;
            tb_addr <= std_logic_vector( to_unsigned( address, tb_addr'length));
        end loop;
        tb_mreq_n   <= '1';

        wait for 100 us;

        tb_ioreq_n  <= '0';
        for address in 0 to 65535 loop
            wait for 10 ns;
            tb_addr <= std_logic_vector( to_unsigned( address, tb_addr'length));
        end loop;
        tb_ioreq_n  <= '1';

        wait;
    end process;

end architecture testbench;
