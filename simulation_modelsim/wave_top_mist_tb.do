onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider testbench
add wave -noupdate /top_mist_tb/simulation_run
add wave -noupdate /top_mist_tb/tb_clk27
add wave -noupdate /top_mist_tb/tb_led_yellow
add wave -noupdate /top_mist_tb/tb_test_point_tp1
add wave -noupdate -divider reset
add wave -noupdate /top_mist_tb/top_mist_i0/sys_reset_n
add wave -noupdate -divider cpu
add wave -noupdate /top_mist_tb/top_mist_i0/redz0mb1e_1/boot_state
add wave -noupdate -radix hexadecimal /top_mist_tb/top_mist_i0/redz0mb1e_1/T80_1/A
add wave -noupdate -radix hexadecimal /top_mist_tb/top_mist_i0/redz0mb1e_1/T80_1/DI
add wave -noupdate /top_mist_tb/top_mist_i0/redz0mb1e_1/T80_1/DO
add wave -noupdate -divider io
add wave -noupdate -group dRAM /top_mist_tb/tb_dram_clk
add wave -noupdate -group dRAM /top_mist_tb/tb_dram_a
add wave -noupdate -group dRAM /top_mist_tb/tb_dram_ba
add wave -noupdate -group dRAM /top_mist_tb/tb_dram_cs_n
add wave -noupdate -group dRAM /top_mist_tb/tb_dram_dq
add wave -noupdate -group dRAM /top_mist_tb/tb_dram_ras_n
add wave -noupdate -group dRAM /top_mist_tb/tb_dram_cas_n
add wave -noupdate -group dRAM /top_mist_tb/tb_dram_we_n
add wave -noupdate -group VGA /top_mist_tb/top_mist_i0/vga_blue
add wave -noupdate -group VGA /top_mist_tb/top_mist_i0/vga_green
add wave -noupdate -group VGA /top_mist_tb/top_mist_i0/vga_red
add wave -noupdate -group VGA /top_mist_tb/top_mist_i0/vga_hsync
add wave -noupdate -group VGA /top_mist_tb/top_mist_i0/vga_vsync
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {61439048179 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {27332066001 ps} {97993036685 ps}
