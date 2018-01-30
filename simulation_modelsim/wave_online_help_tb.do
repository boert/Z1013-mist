onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider testbench
add wave -noupdate /online_help_tb/tb_pixel_clock
add wave -noupdate /online_help_tb/tb_hsync
add wave -noupdate /online_help_tb/tb_vsync
add wave -noupdate -divider online_help
add wave -noupdate -divider fixed
add wave -noupdate /online_help_tb/dut/char_count
add wave -noupdate /online_help_tb/dut/char_width
add wave -noupdate /online_help_tb/dut/char_height
add wave -noupdate /online_help_tb/dut/text_width
add wave -noupdate /online_help_tb/dut/text_heigth
add wave -noupdate -divider signals
add wave -noupdate /online_help_tb/dut/hpulse
add wave -noupdate -format Analog-Step -height 84 -max 1584.0 -radix unsigned -childformat {{/online_help_tb/dut/hposition(10) -radix unsigned} {/online_help_tb/dut/hposition(9) -radix unsigned} {/online_help_tb/dut/hposition(8) -radix unsigned} {/online_help_tb/dut/hposition(7) -radix unsigned} {/online_help_tb/dut/hposition(6) -radix unsigned} {/online_help_tb/dut/hposition(5) -radix unsigned} {/online_help_tb/dut/hposition(4) -radix unsigned} {/online_help_tb/dut/hposition(3) -radix unsigned} {/online_help_tb/dut/hposition(2) -radix unsigned} {/online_help_tb/dut/hposition(1) -radix unsigned} {/online_help_tb/dut/hposition(0) -radix unsigned}} -subitemconfig {/online_help_tb/dut/hposition(10) {-height 16 -radix unsigned} /online_help_tb/dut/hposition(9) {-height 16 -radix unsigned} /online_help_tb/dut/hposition(8) {-height 16 -radix unsigned} /online_help_tb/dut/hposition(7) {-height 16 -radix unsigned} /online_help_tb/dut/hposition(6) {-height 16 -radix unsigned} /online_help_tb/dut/hposition(5) {-height 16 -radix unsigned} /online_help_tb/dut/hposition(4) {-height 16 -radix unsigned} /online_help_tb/dut/hposition(3) {-height 16 -radix unsigned} /online_help_tb/dut/hposition(2) {-height 16 -radix unsigned} /online_help_tb/dut/hposition(1) {-height 16 -radix unsigned} /online_help_tb/dut/hposition(0) {-height 16 -radix unsigned}} /online_help_tb/dut/hposition
add wave -noupdate /online_help_tb/dut/vpulse
add wave -noupdate -format Analog-Step -height 84 -max 601.0 -radix unsigned -childformat {{/online_help_tb/dut/vposition(10) -radix unsigned} {/online_help_tb/dut/vposition(9) -radix unsigned} {/online_help_tb/dut/vposition(8) -radix unsigned} {/online_help_tb/dut/vposition(7) -radix unsigned} {/online_help_tb/dut/vposition(6) -radix unsigned} {/online_help_tb/dut/vposition(5) -radix unsigned} {/online_help_tb/dut/vposition(4) -radix unsigned} {/online_help_tb/dut/vposition(3) -radix unsigned} {/online_help_tb/dut/vposition(2) -radix unsigned} {/online_help_tb/dut/vposition(1) -radix unsigned} {/online_help_tb/dut/vposition(0) -radix unsigned}} -subitemconfig {/online_help_tb/dut/vposition(10) {-height 16 -radix unsigned} /online_help_tb/dut/vposition(9) {-height 16 -radix unsigned} /online_help_tb/dut/vposition(8) {-height 16 -radix unsigned} /online_help_tb/dut/vposition(7) {-height 16 -radix unsigned} /online_help_tb/dut/vposition(6) {-height 16 -radix unsigned} /online_help_tb/dut/vposition(5) {-height 16 -radix unsigned} /online_help_tb/dut/vposition(4) {-height 16 -radix unsigned} /online_help_tb/dut/vposition(3) {-height 16 -radix unsigned} /online_help_tb/dut/vposition(2) {-height 16 -radix unsigned} /online_help_tb/dut/vposition(1) {-height 16 -radix unsigned} /online_help_tb/dut/vposition(0) {-height 16 -radix unsigned}} /online_help_tb/dut/vposition
add wave -noupdate -divider message
add wave -noupdate /online_help_tb/dut/message_pos
add wave -noupdate /online_help_tb/dut/message_data
add wave -noupdate /online_help_tb/dut/msg_overlay_bit
add wave -noupdate /online_help_tb/dut/msg_strcount
add wave -noupdate /online_help_tb/dut/msg_pixelpos
add wave -noupdate /online_help_tb/dut/msg_charpos
add wave -noupdate /online_help_tb/dut/msg_overlay_bit
add wave -noupdate -divider {online help}
add wave -noupdate /online_help_tb/dut/txt_strcount
add wave -noupdate /online_help_tb/dut/txt_pixelpos
add wave -noupdate /online_help_tb/dut/txt_charpos
add wave -noupdate /online_help_tb/dut/show_text
add wave -noupdate /online_help_tb/dut/txt_overlay_bit
add wave -noupdate /online_help_tb/dut/linepos
add wave -noupdate /online_help_tb/dut/txt_pos
add wave -noupdate -divider {VGA out}
add wave -noupdate /online_help_tb/tb_red_out
add wave -noupdate /online_help_tb/tb_green_out
add wave -noupdate /online_help_tb/tb_blue_out
add wave -noupdate /online_help_tb/tb_hsync_out
add wave -noupdate /online_help_tb/tb_vsync_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {1759121900 ps} 0}
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
WaveRestoreZoom {1616254492 ps} {2031947630 ps}
