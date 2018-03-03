onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /user_io_tb/tb_conf_str
add wave -noupdate /user_io_tb/tb_SPI_CLK
add wave -noupdate /user_io_tb/tb_SPI_SS_IO
add wave -noupdate /user_io_tb/tb_SPI_MOSI
add wave -noupdate /user_io_tb/tb_SPI_MISO
add wave -noupdate /user_io_tb/dut/bit_cnt
add wave -noupdate -radix unsigned /user_io_tb/dut/byte_cnt
add wave -noupdate -group sd /user_io_tb/tb_sd_lba
add wave -noupdate -group sd /user_io_tb/tb_sd_rd
add wave -noupdate -group sd /user_io_tb/tb_sd_wr
add wave -noupdate -group sd /user_io_tb/tb_sd_conf
add wave -noupdate -group sd /user_io_tb/tb_sd_sdhc
add wave -noupdate -group sd /user_io_tb/tb_sd_din
add wave -noupdate -group sd /user_io_tb/tb_sd_ack
add wave -noupdate -group sd /user_io_tb/tb_sd_dout
add wave -noupdate -group sd /user_io_tb/tb_sd_dout_strobe
add wave -noupdate -group sd /user_io_tb/tb_sd_din_strobe
add wave -noupdate /user_io_tb/tb_serial_data
add wave -noupdate /user_io_tb/tb_serial_strobe
add wave -noupdate -group joystick /user_io_tb/tb_joystick_0
add wave -noupdate -group joystick /user_io_tb/tb_joystick_1
add wave -noupdate -group joystick /user_io_tb/tb_joystick_analog_0
add wave -noupdate -group joystick /user_io_tb/tb_joystick_analog_1
add wave -noupdate /user_io_tb/tb_buttons
add wave -noupdate /user_io_tb/tb_switches
add wave -noupdate /user_io_tb/dut/but_sw
add wave -noupdate -radix hexadecimal /user_io_tb/tb_status
add wave -noupdate /user_io_tb/tb_ps2_clk
add wave -noupdate /user_io_tb/tb_ps2_kbd_clk
add wave -noupdate /user_io_tb/tb_ps2_kbd_data
add wave -noupdate /user_io_tb/tb_ps2_mouse_clk
add wave -noupdate /user_io_tb/tb_ps2_mouse_data
add wave -noupdate -group {PS2 keyboard internals} -radix hexadecimal -childformat {{/user_io_tb/dut/ps2_kbd_fifo(7) -radix hexadecimal} {/user_io_tb/dut/ps2_kbd_fifo(6) -radix hexadecimal} {/user_io_tb/dut/ps2_kbd_fifo(5) -radix hexadecimal} {/user_io_tb/dut/ps2_kbd_fifo(4) -radix hexadecimal} {/user_io_tb/dut/ps2_kbd_fifo(3) -radix hexadecimal} {/user_io_tb/dut/ps2_kbd_fifo(2) -radix hexadecimal} {/user_io_tb/dut/ps2_kbd_fifo(1) -radix hexadecimal} {/user_io_tb/dut/ps2_kbd_fifo(0) -radix hexadecimal}} -subitemconfig {/user_io_tb/dut/ps2_kbd_fifo(7) {-height 16 -radix hexadecimal} /user_io_tb/dut/ps2_kbd_fifo(6) {-height 16 -radix hexadecimal} /user_io_tb/dut/ps2_kbd_fifo(5) {-height 16 -radix hexadecimal} /user_io_tb/dut/ps2_kbd_fifo(4) {-height 16 -radix hexadecimal} /user_io_tb/dut/ps2_kbd_fifo(3) {-height 16 -radix hexadecimal} /user_io_tb/dut/ps2_kbd_fifo(2) {-height 16 -radix hexadecimal} /user_io_tb/dut/ps2_kbd_fifo(1) {-height 16 -radix hexadecimal} /user_io_tb/dut/ps2_kbd_fifo(0) {-height 16 -radix hexadecimal}} /user_io_tb/dut/ps2_kbd_fifo
add wave -noupdate -group {PS2 keyboard internals} -radix unsigned /user_io_tb/dut/ps2_kbd_wptr
add wave -noupdate -group {PS2 keyboard internals} -radix unsigned /user_io_tb/dut/ps2_kbd_rptr
add wave -noupdate -group {PS2 keyboard internals} -radix unsigned /user_io_tb/dut/ps2_kbd_tx_state
add wave -noupdate -group {PS2 keyboard internals} -radix hexadecimal /user_io_tb/dut/ps2_kbd_tx_byte
add wave -noupdate -group {PS2 keyboard internals} /user_io_tb/dut/ps2_kbd_parity
add wave -noupdate -group {PS2 keyboard internals} /user_io_tb/dut/ps2_kbd_r_inc
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {899263 ps} 0} {{Cursor 2} {2910005 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 244
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {2226 us}
