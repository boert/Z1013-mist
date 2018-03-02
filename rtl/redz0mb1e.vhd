------------------------------------------------------------------------------
-- Project    : Red Zombie
------------------------------------------------------------------------------
-- File       :  redzombie.vhd
-- Author     :  fpgakuechle
-- Company    : hobbyist
-- Created    : 2012-12
-- Last update: 2013-04-15
-- Licence     : GNU General Public License (http://www.gnu.de/documents/gpl.de.html)
------------------------------------------------------------------------------
-- Description: 
-- top structural, clues CPU, RAM and IO- control together
-- red zombie (z1013 at starterkit) topfile
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.pkg_redz0mb1e.all;

library support;
library T80;


entity redz0mb1e is
    port
    (
        RESET_n               : in std_logic;
        --
        cpu_clk               : in std_logic;
        cpu_hold_n            : in std_logic;
        video_clk             : in std_logic;
        -- ascii from keyboard (or serial line)
        ascii                 : in std_logic_vector( 7 downto 0);
        ascii_press           : in std_logic;
        ascii_release         : in std_logic;
        -- vga interface
        red_o                 : out std_logic;
        blue_o                : out std_logic;
        green_o               : out std_logic;
        vsync_o               : out std_logic;
        hsync_o               : out std_logic;
        col_fg                : in  T_COLOR;
        col_bg                : in  T_COLOR;
        -- SRAM interface
        ramAddr               : out std_logic_vector(15 downto 0);
        ramData_in            : in  std_logic_vector(7 downto 0);
        ramData_out           : out std_logic_vector(7 downto 0);
        ramOe_N               : out std_logic; 
        ramCE_N               : out std_logic;
        ramWe_N               : out std_logic;
        -- user port (PIO port A) for joystick
        x4_in                 : in  std_logic_vector(7 downto 0);
        x4_out                : out std_logic_vector(7 downto 0);
        --
        sound_out             : out std_logic;
        -- PETERS extension
        clk_2MHz_4MHz         : out std_logic
    );
end entity redz0mb1E;


architecture behave of redz0mb1E is

    signal boot_state       : std_logic := '1';
    signal CEN              : std_logic;
    signal WAIT_n           : std_logic := '1';
    signal int_sense_n      : std_logic;
    --                      
    signal M1_n             : std_logic;
    signal IOREQ_n          : std_logic;
    signal mreq_n           : std_logic;
    signal RFSH_n           : std_logic;
    --                      
    signal RD_n             : std_logic;
    signal WR_n             : std_logic;
    --                      
    signal addr             : std_logic_vector(15 downto 0);
    signal data2cpu         : std_logic_vector(7 downto 0);
    --                      
    signal data4PIO         : std_logic_vector(7 downto 0);
    signal data4RAM         : std_logic_vector(7 downto 0);
    signal data4ROM         : std_logic_vector(7 downto 0);
    signal data4video       : std_logic_vector(7 downto 0);
    signal data4ext         : std_logic_vector(7 downto 0);
    signal data4CPU         : std_logic_vector(7 downto 0);
  
    --memory block select
    signal sel_rom_n        : std_logic;
    signal sel_vram_n       : std_logic;
    signal sel_dram_n       : std_logic;
  
    --io
    signal sel_io_pio_n     : std_logic;  --pio_select
    signal sel_io_kybrow_n  : std_logic;
    signal sel_io_1_n       : std_logic;
  
    signal wait_io_pio_n    : std_logic := '1';
    --                      
    signal porta4pio        : std_logic_vector(7 downto 0);
    signal portb4pio        : std_logic_vector(7 downto 0);
                            
    signal porta2pio        : std_logic_vector(7 downto 0):= (others => '0');
    signal portb2pio        : std_logic_vector(7 downto 0):= (others => '0');
                            
    signal stba2PIO_n       : std_logic  := '0';
    signal stbb2PIO_n       : std_logic  := '0';
                              
    signal rdya4PIO_n       : std_logic;
    signal rdyb4PIO_n       : std_logic;
                            
    signal IRQEna2PIO       : std_logic := '1';
    signal IRQEna4PIO       : std_logic;
                              
    signal astb2PIO_n       : std_logic := '1'; 
    signal bstb2PIO_n       : std_logic := '1'; 

    -- signals for address decoder
    signal cs_mem_n         : std_logic_vector(3 downto 0);
    signal cs_io_n          : std_logic_vector(3 downto 0);
    signal write_protect    : std_logic;
  
    -- signals for peters extension
    signal extension_reg        : std_logic_vector(7 downto 0);
    constant  ext_video_32_64   : natural := 7;
    constant  ext_clk_2MHz_4MHz : natural := 6;
    constant  ext_2nd_zgen      : natural := 5;
    constant  ext_romdis        : natural := 4;
    constant  ext_we_F000       : natural := 2;
    constant  ext_we_F800       : natural := 1;
  
  
begin

    -- Z80/U880
    T80_1 : entity t80.T80s
    generic map
    (
        Mode    => 0,
        T2Write => 0,
        IOWait  => 1                      -- std IO-cycle
    )
    port map 
    (
        RESET_n => reset_n,
        CLK_n   => cpu_clk,
        WAIT_n  => wait_n,                -- no waits @ 1st implement
        INT_n   => int_sense_n,
        NMI_n   => '1',                   -- no NMI implemented
        BUSRQ_n => '1',                   -- no 2nd busmaster (dma) used yet
        M1_n    => M1_n,
        IORQ_n  => IOREQ_n,               -- IO Request
        mreq_n  => mreq_n,
        RFSH_n  => rfsh_n,                -- refresh deselects all mem devices
        HALT_n  => open,                  -- not used at 1st impl
        BUSAK_n => open,                  -- bus freeing (for DMA) not used yet
        A       => Addr,
        RD_n    => RD_n,
        WR_n    => WR_n,
        DI      => Data2cpu,
        DO      => data4CPU
    );


    -- ROM
    rom_sys_1: entity work.rom_sys
    port map 
    (
        clk     => cpu_clk,
        cs_ni   => sel_rom_n,
        oe_ni   => rd_n,
        data_o  => data4rom,
        addr_i  => addr(11 downto 0)
    );


    -- RAM access
    RAM_control_p: process(sel_dram_n, wr_n, data4cpu, addr)
    begin
        -- read (default)
        ramWe_N     <= '1';
        ramOe_N     <= '0';
        ramData_out <= (others => '-');

        -- activate SDRAM auto refresh
        if rfsh_n = '0' then
            ramWe_N     <= '1';
            ramOe_N     <= '1';
        end if;

        -- mem access
        if sel_dram_n = '0' and wr_n = '0' and write_protect = '0' then
            -- write to RAM
            ramWe_N     <= '0';     
            ramOe_N     <= '1';
            ramData_out <= data4cpu;
        end if;         

        ramCe_N         <= sel_dram_n;
        ramAddr         <= addr(15 downto 0);
    end process;
    data4ram <= ramData_in;


    -- Boot State Controller        
    -- keep CPU reading of NOP until ROM is reached
    boot_state_control: process(cpu_clk, reset_n)
    begin
        if reset_n = '0' then
            boot_state <= '1';
        elsif rising_edge( cpu_clk) then
            if boot_state = '1' and sel_rom_n = '0' then -- ROM selektiert
                boot_state <= '0';  
            end if;
        end if;
    end process;    
  

    -- datain - mux
    -- PIO

    pio_1: entity work.pio
    port map 
    (
        clk             => cpu_clk,
        ce_ni           => sel_io_pio_n,
        IOREQn_i        => IOREQ_n,
        data_o          => data4PIO,
        data_i          => data4cpu,
        RD_n            => RD_n,
        M1_n            => M1_n,
        sel_b_nA        => addr(1),
        sel_c_nD        => addr(0),
        IRQEna_i        => IRQEna2PIO,
        IRQEna_o        => IRQEna4PIO,
        INTn_o          => int_sense_n,
        astb_n          => astb2PIO_n,                 -- Data strobe in, is able to generate IREQ
        ardy_n          => rdya4PIO_n,
        porta_o         => porta4pio,
        porta_i         => porta2pio,
        bstb_n          => bstb2PIO_n,
        brdy_n          => rdyb4PIO_n,
        portb_o         => portb4pio,
        portb_i         => portb2pio
    );

    -- PIO port A (X4) for user port (joystick)
    x4_out      <= porta4pio;
    porta2pio   <= x4_in;

    -- PIO port B for sound
    sound_out   <= portb4pio( 7);


    -- eingabegerät zu tastenbuffer

    keyboard_matrix_inst : entity work.keyboard_matrix
    port map
    (
        clk             => cpu_clk,                       -- : in    std_logic;
        -- Z1013 side
        column          => data4cpu,                      -- : in    std_logic_vector( 7 downto 0);
        column_en_n     => sel_io_kybrow_n,               -- : in    std_logic;
        row             => portb2pio,                     -- : out   std_logic_vector( 7 downto 0);  -- to PIO port B
        -- keyboard side (from scancode decoder)
        ascii           => ascii,                         -- : in    std_logic_vector( 7 downto 0);
        ascii_press     => ascii_press,                   -- : in    std_logic;
        ascii_release   => ascii_release                  -- : in    std_logic;
    );


    --Ausgabegerät
    --Bildspeicher + Zeichengenerator + Ausgabe optionen

    video_1 : entity work.video
    generic map
    (
        G_ReadOnly  => false
    )
    port map
    (
        clk             => cpu_clk,
        rst_i           => reset_n,
        --
        cs_ni           => sel_vram_n,
        we_ni           => wr_n,
        data_i          => data4cpu,
        data_o          => data4video,      
        addr_i          => addr(9 downto 0),
        romsel_i        => extension_reg( ext_2nd_zgen),
        mode64x16_i     => extension_reg( ext_video_32_64),
        --
        video_clk       => video_clk,                 -- : in std_logic;
        red_o           => red_o,
        blue_o          => blue_o,
        green_o         => green_o,
        vsync_o         => vsync_o,
        hsync_o         => hsync_o,
        col_fg          => col_fg,
        col_bg          => col_bg
    );

  
    -- adressdecode
    addr_decode_1 : entity work.addr_decode
    port map 
    (
        addr_i          => addr,
        ioreq_ni        => ioreq_n,
        mreq_ni         => mreq_n,
        rfsh_ni         => rfsh_n,
        rom_disable     => extension_reg( ext_romdis),
        we_F000         => extension_reg( ext_we_F000),
        we_F800         => extension_reg( ext_we_F800),
        --
        write_protect   => write_protect,
        cs_mem_no       => cs_mem_n,
        cs_io_no        => cs_io_n
    );

    -- memory selection
    sel_vram_n      <= cs_mem_n(1);
    sel_rom_n       <= cs_mem_n(2);
    sel_dram_n      <= cs_mem_n(3);

    -- io selection
    sel_io_pio_n    <= cs_io_n(0);
    sel_io_1_n      <= cs_io_n(1);  
    sel_io_kybrow_n <= cs_io_n(2);


    -- signals to CPU

    -- A B AND
    -- 0 0  0
    -- 0 1  0
    -- 1 0  0
    -- 1 1  1
    wait_n <= wait_io_pio_n and cpu_hold_n;

    -- data BUS to cpu
    data2cpu <= "00000000" when boot_state      = '1' else  -- NOP on startup
                data4PIO   when sel_io_pio_n    = '0' else
                data4ext   when sel_io_1_n      = '0' else
                data4ROM   when sel_rom_n       = '0' else
                data4video when sel_vram_n      = '0' else
                data4RAM;


    -- extension register 'PETERS-Platine'
    process
    begin
        wait until rising_edge( cpu_clk);
        if wr_n = '0' and sel_io_1_n = '0' then
            extension_reg(7 downto 4)	<= data4cpu(7 downto 4);
            extension_reg(2 downto 1)	<= data4cpu(2 downto 1);
        end if;
        if reset_n = '0' then
            extension_reg   <= ( others => '0');
        end if;
        data4ext    <= extension_reg;
    end process;

    clk_2MHz_4MHz <= extension_reg( ext_clk_2MHz_4MHz);

end architecture;
