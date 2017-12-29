onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /scancode_tb/simulation_run
add wave -noupdate /scancode_tb/tb_clk
add wave -noupdate -radix hexadecimal /scancode_tb/tb_scancode
add wave -noupdate /scancode_tb/tb_scancode_en
add wave -noupdate /scancode_tb/tb_layout_select
add wave -noupdate -radix hexadecimal /scancode_tb/tb_ascii
add wave -noupdate /scancode_tb/tb_ascii_press
add wave -noupdate /scancode_tb/tb_ascii_release
add wave -noupdate -divider scancode_ascii
add wave -noupdate -expand /scancode_tb/scancode_ascii_inst/r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3135105 ps} 0}
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
WaveRestoreZoom {0 ps} {9817500 ps}
