onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /keyboard_matrix_tb/simulation_run
add wave -noupdate -expand -group z1013 /keyboard_matrix_tb/tb_clk
add wave -noupdate -expand -group z1013 -radix unsigned /keyboard_matrix_tb/tb_column
add wave -noupdate -expand -group z1013 /keyboard_matrix_tb/tb_column_en_n
add wave -noupdate -expand -group z1013 /keyboard_matrix_tb/tb_row
add wave -noupdate -expand -group z1013 /keyboard_matrix_tb/tb_row(3)
add wave -noupdate -expand -group z1013 /keyboard_matrix_tb/tb_row(2)
add wave -noupdate -expand -group z1013 /keyboard_matrix_tb/tb_row(1)
add wave -noupdate -expand -group z1013 /keyboard_matrix_tb/tb_row(0)
add wave -noupdate /keyboard_matrix_tb/tb_ascii_clk
add wave -noupdate -radix hexadecimal /keyboard_matrix_tb/tb_ascii
add wave -noupdate /keyboard_matrix_tb/tb_ascii_press
add wave -noupdate /keyboard_matrix_tb/tb_ascii_release
add wave -noupdate -divider dut
add wave -noupdate /keyboard_matrix_tb/keyboard_matrix_inst/selected_column
add wave -noupdate -expand /keyboard_matrix_tb/keyboard_matrix_inst/r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {143007053 ps} 0}
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
configure wave -timelineunits ms
update
WaveRestoreZoom {139934612 ps} {146224180 ps}
