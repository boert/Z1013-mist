onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {tb SPI}
add wave -noupdate /osd_tb/tb_spi_sck
add wave -noupdate /osd_tb/tb_spi_ss3
add wave -noupdate /osd_tb/tb_spi_di
add wave -noupdate -divider DUT
add wave -noupdate /osd_tb/dut/osd_enable
add wave -noupdate /osd_tb/dut/h_osd_active
add wave -noupdate /osd_tb/dut/v_osd_active
add wave -noupdate -radix unsigned /osd_tb/dut/osd_hcnt
add wave -noupdate -radix unsigned /osd_tb/dut/osd_vcnt
add wave -noupdate /osd_tb/dut/stretch
add wave -noupdate /osd_tb/dut/osd_byte
add wave -noupdate /osd_tb/dut/osd_pixel
add wave -noupdate -divider {tb VGA}
add wave -noupdate /osd_tb/tb_red_out
add wave -noupdate /osd_tb/tb_green_out
add wave -noupdate /osd_tb/tb_blue_out
add wave -noupdate /osd_tb/tb_hsync_out
add wave -noupdate /osd_tb/tb_vsync_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18911368515 ps} 0} {{Cursor 2} {22293528462 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 186
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
WaveRestoreZoom {22293410769 ps} {22293792050 ps}
