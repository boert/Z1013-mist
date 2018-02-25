----------------------------------------------------------------------------------
-- sdram controller from mist project (verilog)
-- 
-- Copyright (c) 2018 by Bert Lange
-- https://github.com/boert/Z1013-mist
-- based on the verilog version (sdram.v) by Till Harbaum
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


entity sdram is
port
(
    -- interface to the MT48LC16M16 chip
    sd_data : inout std_logic_vector(15 downto 0);  -- 16 bit bidirectional data bus
    sd_addr : out   std_logic_vector(12 downto 0);  -- 13 bit multiplexed address bus
    sd_dqm  : out   std_logic_vector( 1 downto 0);  -- two byte masks
    sd_ba   : out   std_logic_vector( 1 downto 0);  -- two banks
    sd_cs   : out   std_logic;                      -- a single chip select
    sd_we   : out   std_logic;                      -- write enable
    sd_ras  : out   std_logic;                      -- row address select
    sd_cas  : out   std_logic;                      -- columns address select
    -- system interface
    init    : in    std_logic;                      -- init signal after FPGA config to initialize RAM
    clk     : in    std_logic;                      -- sdram is accessed at up to 128MHz
    clkref  : in    std_logic;                      -- reference clock to sync to
    -- cpu/chipset interface
    din     : in    std_logic_vector( 7 downto 0);  -- data input from chipset/cpu
    dout    : out   std_logic_vector( 7 downto 0);  -- data output to chipset/cpu
    addr    : in    std_logic_vector(24 downto 0);  -- 25 bit byte address
    oe      : in    std_logic;              -- cpu/chipset requests read
    we      : in    std_logic               -- cpu/chipset requests write
);
end entity sdram;


architecture rtl of sdram is

    -- no burst configured
    constant RASCAS_DELAY           : natural                       := 3;       -- tRCD>=20ns -> 2 cycles@64MHz
    constant BURST_LENGTH           : std_logic_vector( 2 downto 0) := "000";   -- 000=none, 001=2, 010=4, 011=8
    constant ACCESS_TYPE            : std_logic                     := '0';     -- 0=sequential, 1=interleaved
    constant CAS_LATENCY            : natural                       := 2;       -- 2/3 allowed
    constant OP_MODE                : std_logic_vector( 1 downto 0) := "00";    -- only 00 (standard operation) allowed
    constant NO_WRITE_BURST         : std_logic                     := '1';     -- 0= write burst enabled, 1=only single access write
    
    constant MODE                   : std_logic_vector( 12 downto 0) := 
            "000" & 
            NO_WRITE_BURST & 
            OP_MODE & 
            std_logic_vector( to_unsigned( CAS_LATENCY, 3)) &
            ACCESS_TYPE &
            BURST_LENGTH;

    constant STATE_IDLE             : natural   := 0;
    constant STATE_CMD_START        : natural   := 1;
    constant STATE_CMD_CONT         : natural   := STATE_CMD_START + RASCAS_DELAY - 1;
    constant STATE_PRELAST          : natural   := 5;
    constant STATE_LAST             : natural   := 7;
    type state_t is ( SYNC, IDLE, START, WAITSTATE, CONTINUE, WS, READ);
    signal state : state_t;

    -- all possible commands
    type cmd_t is ( CMD_INHIBIT, CMD_NOP, CMD_ACTIVE, CMD_READ, CMD_WRITE, CMD_BURST_TERMINATE, CMD_PRECHARGE, CMD_AUTO_REFRESH, CMD_LOAD_MODE);

    function to_sd_cmd( cmd : cmd_t) return std_logic_vector is
        variable result :   std_logic_vector( 3 downto 0) := "ZZZZ";
    begin
        case cmd is
            --                             result :=  /CS /RAS /CAS /WE 
            when CMD_INHIBIT            => result := "1111";
            when CMD_NOP                => result := "0111";
            when CMD_ACTIVE             => result := "0011";
            when CMD_READ               => result := "0101";
            when CMD_WRITE              => result := "0100";
            when CMD_BURST_TERMINATE    => result := "0110";
            when CMD_PRECHARGE          => result := "0010";
            when CMD_AUTO_REFRESH       => result := "0001";
            when CMD_LOAD_MODE          => result := "0000";
        end case;
        return result;
    end function to_sd_cmd;

    signal q            : unsigned( 2 downto 0) := "000";
    signal reset        : unsigned( 4 downto 0) := "11111";
    signal sd_cmd       : cmd_t; --std_logic_vector( 3 downto 0); -- current command sent to sd ram
    signal sd_cmd_slv   : std_logic_vector( 3 downto 0); -- current command sent to sd ram
    signal reset_addr   : std_logic_vector( 12 downto 0);
    signal run_addr     : std_logic_vector( 12 downto 0);

begin
    
    process
    begin
        wait until rising_edge( clk);
	    -- 32Mhz counter synchronous to 4 Mhz clock
        -- force counter to pass state 5->6 exactly after the rising edge of clkref
	    -- since clkref is two clocks early
        if (( q = 6) and ( clkref = '0')) or
           (( q = 7) and ( clkref = '1')) or
           (( q /= 6) and ( q /= 7)) then
            q   <= q + 1;
        end if;
    end process;

    process
        variable clkref_1   : std_logic;
        variable count      : natural range 0 to RASCAS_DELAY - 1;
    begin
        wait until rising_edge( clk);

        -- default
        sd_cmd  <= CMD_INHIBIT;

        -- fsm
        case state is

            when SYNC =>
                if clkref_1 = '0' and clkref = '1' then
                    state   <= WAITSTATE;
                    count   := RASCAS_DELAY - 1; 
                    if reset = 13 then
                        sd_cmd  <= CMD_PRECHARGE;
                    end if;
                    if reset =  2 then
                        sd_cmd  <= CMD_LOAD_MODE;
                    end if;
                    if reset =  0 then
                        if we = '1' or oe = '1' then
                            sd_cmd  <= CMD_ACTIVE;
                        else
                            sd_cmd  <= CMD_AUTO_REFRESH;
                        end if;
                    end if;
                end if;

            when IDLE =>
                state   <= START;    

            when START =>
                state   <= WAITSTATE;
                count   := count - 1;

            when WAITSTATE =>
                if count > 0 then
                    count   := count - 1;
                else
                    state   <= CONTINUE;
                    if reset =  0 then
                        if we = '1' then
                            sd_cmd  <= CMD_WRITE;
                        elsif oe = '1' then
                            sd_cmd  <= CMD_READ;
                        end if;
                    end if;
                end if;

            when CONTINUE =>
                state   <= WS;

            when WS =>
                state   <= READ;

            when READ =>
                state   <= SYNC;
                dout    <= sd_data( 7 downto 0);

        end case;
        clkref_1    := clkref;
    end process;

    -- ---------------------------------------------------------------------
    -- --------------------------- startup/reset ---------------------------
    -- ---------------------------------------------------------------------

    -- wait 1ms (32 clkref cycles) after FPGA config is done before going
    -- into normal operation. Initialize the ram in the last 16 reset cycles (cycles 15-0)
    process
    begin
        wait until rising_edge( clk);
        if init = '1' then
            reset   <= "11111";
--      elsif q = STATE_PRELAST and reset > 0 then
        elsif state = READ and reset > 0 then
            reset   <= reset - 1;
        end if;
    end process;

    -- ---------------------------------------------------------------------
    -- ------------------ generate ram control signals ---------------------
    -- ---------------------------------------------------------------------

    -- drive control signals according to current command
    sd_cmd_slv  <= to_sd_cmd( sd_cmd);
    sd_cs       <= sd_cmd_slv( 3);
    sd_ras      <= sd_cmd_slv( 2);
    sd_cas      <= sd_cmd_slv( 1);
    sd_we       <= sd_cmd_slv( 0);

    sd_data <= "00000000" & din when we = '1' else ( others => 'Z');

--  dout    <= sd_data( 7 downto 0) when falling_edge( clkref);

--  process
--  begin
--      wait until rising_edge( clk);
--      sd_cmd  <= CMD_INHIBIT;

--      if reset > 0 then
--          if q = STATE_IDLE then
--              if reset = 13 then
--                  sd_cmd  <= CMD_PRECHARGE;
--              end if;
--              if reset =  2 then
--                  sd_cmd  <= CMD_LOAD_MODE;
--              end if;
--          end if;
--      else
--          if q = STATE_IDLE then
--              if we = '1' or oe = '1' then
--                  sd_cmd  <= CMD_ACTIVE;
--              else
--                  sd_cmd  <= CMD_AUTO_REFRESH;
--              end if;
--          elsif q = STATE_CMD_CONT then
--              if we = '1' then
--                  sd_cmd  <= CMD_WRITE;
--              elsif oe = '1' then
--                  sd_cmd  <= CMD_READ;
--              end if;
--          end if;
--      end if;
--  end process;

    reset_addr  <= "0010000000000" when reset = 13 else MODE;

--  run_addr    <= addr( 20 downto 8) when q = STATE_CMD_START else "0010" & addr( 23) & addr( 7 downto 0);
    run_addr    <= addr( 20 downto 8) when state = START else "0010" & addr( 23) & addr( 7 downto 0);

    sd_addr     <= reset_addr when reset > 0 else run_addr;
    sd_ba       <= addr( 22 downto 21);
    sd_dqm      <= "11" when reset = 31 else "00";

end architecture rtl;
