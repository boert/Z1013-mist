onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /auto_start_tb/simulation_run
add wave -noupdate -divider inputs
add wave -noupdate /auto_start_tb/tb_clk
add wave -noupdate /auto_start_tb/tb_enable
add wave -noupdate -radix hexadecimal /auto_start_tb/tb_autostart_addr
add wave -noupdate /auto_start_tb/tb_autostart_en
add wave -noupdate -divider outputs
add wave -noupdate /auto_start_tb/tb_active
add wave -noupdate -radix ascii /auto_start_tb/tb_ascii
add wave -noupdate /auto_start_tb/tb_ascii_press
add wave -noupdate /auto_start_tb/tb_ascii_release
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5125000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 230
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
WaveRestoreZoom {0 ps} {441003150 ns}
