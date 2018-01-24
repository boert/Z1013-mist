------------------------------------------------------------------------------
-- Project    : Red Zombie
------------------------------------------------------------------------------
-- File       : charrom.vhd
-- Company    : hobbyist
-- Created    : 2012-12
-- Adopted    : fpgakuechle
-- Lizenz     : GNU General Public License (http://www.gnu.de/documents/gpl.de.html)
-- Last update: 2013-02-28
------------------------------------------------------------------------------
-- Description: 
-- ROM used as character generator
-- the real bitmap of this character set is stored in the package
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_redz0mb1e.all;
use work.bm100_pkg.all;                 --character ROM

entity char_rom is
  port(
    clk         : in  std_logic;        --videoclk (i.e. 40MHz for 800x600@60
    data_o      : out std_logic_vector(7 downto 0);
    addr_char_i : in  std_logic_vector(7 downto 0);
    addr_line_i : in  std_logic_vector(2 downto 0));
end entity char_rom;

architecture behave of char_rom is

  signal crom_array : T_BM100_MEM := C_BM100_MEM_ARRAY_INIT;  --character rom
  signal crom_index : T_BM100_INDEX;

begin

  crom_index <= to_integer(unsigned(addr_char_i & addr_line_i));

  process
  begin
    wait until rising_edge(clk);
    data_o <= std_logic_vector(to_unsigned(crom_array(crom_index), 8));
  end process;

end architecture behave;
