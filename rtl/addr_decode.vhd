--address decoder
--the original hardware is based on BCD-decimal decoders 7442
--chip selects are generated for
-- -System RAM       x0000 - x3FFF        (16k)               "1000"
-- -DK10             xE000 - E400           1k
--                
-- -Video  RAM (BWS) xEC00 - xEFFF          1k DK13           "0010"
-- -System ROM       xF000 - xF7FF          4k DK14+15        "0100"

-- -Perpehrie (keyboard/tape) controller (IO)
--
-- FPGAkuechle
-- this sources are declared to Open Source by the author

-- Bert Lange:
-- change for 64k layout
-- add ROM disable

library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;
use work.pkg_redz0mb1e.all;

entity addr_decode is
port (
    addr_i          : in  std_logic_vector(15 downto 0);
    ioreq_ni        : in  std_logic;
    mreq_ni         : in  std_logic;
    rfsh_ni         : in  std_logic;
    rom_disable     : in  std_logic;
    we_F000         : in  std_logic;
    we_F800         : in  std_logic;
    --
    write_protect   : out std_logic;
    cs_mem_no       : out std_logic_vector(3 downto 0); --low active
    cs_io_no        : out std_logic_vector(3 downto 0)  --low active
    );
end entity addr_decode;


architecture behave of addr_decode is

    signal mem_select           : boolean;    --mem access (not refresh)
    signal io_select            : boolean;
    signal cs_mem_int           : std_logic_vector(3 downto 0);
    signal cs_mem_int_romdis    : std_logic_vector(3 downto 0);
    signal cs_io_int            : std_logic_vector(3 downto 0);
  
begin
    
    -- write protection for F000/F800
    write_protect   <=
        '1' when addr_i(15 downto 10) = "111100" and we_F000 = '0' else
        '1' when addr_i(15 downto 10) = "111101" and we_F000 = '0' else
        '1' when addr_i(15 downto 10) = "111110" and we_F800 = '0' else
        '1' when addr_i(15 downto 10) = "111111" and we_F800 = '0' else
        '0';

    -- memory
    mem_select   <= mreq_ni = '0' and rfsh_ni = '1'; --skip refresh cycles
    with addr_i(15 downto 10) select  --1k pages
        cs_mem_int <=   "0111" when "111000",  --xE000  RAM (DK10)
                        "0111" when "111001",  --xE400  RAM (free) 
                        "0111" when "111010",  --xE800  RAM (free) 
                        "1101" when "111011",  --xEC00  VideoRAM
                        "1011" when "111100",  --xF000  Monitor-ROM
                        "1011" when "111101",  --xF400  Monitor-ROM  
                        "1011" when "111110",  --xF800  extra ROM
                        "1011" when "111111",  --xFC00  extra ROM
                        "0111" when others;    

    with addr_i(15 downto 10) select  --1k pages
        cs_mem_int_romdis 
                   <=   "0111" when "111000",  --xE000  RAM (DK10)
                        "0111" when "111001",  --xE400  RAM (free) 
                        "0111" when "111010",  --xE800  RAM (free) 
                        "1101" when "111011",  --xEC00  VideoRAM
                        "0111" when "111100",  --xF000  RAM (Monitor-ROM)
                        "0111" when "111101",  --xF400  RAM (Monitor-ROM)  
                        "0111" when "111110",  --xF800  RAM (extra ROM)
                        "0111" when "111111",  --xFC00  RAM (extra ROM)
                        "0111" when others;    

    cs_mem_no <= cs_mem_int         when mem_select and rom_disable = '0' else
                 cs_mem_int_romdis  when mem_select and rom_disable = '1' else
                 "1111";                     

    -- IO
    io_select <= ioreq_ni = '0';   
    with addr_i(7 downto 2) select  --4 byte pages
        cs_io_int  <=   "1110" when "000000",  --x00    PIO
                        "1101" when "000001",  --x04    iosel1, Peters-Platine 
                        "1011" when "000010",  --x08    keybrd driver - IOSEL2 
                        "1111" when others;    

    cs_io_no  <=  cs_io_int when io_select else  --only one selcted yet
                  "1111"; 

end architecture behave;
