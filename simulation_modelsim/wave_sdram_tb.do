onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sdram_tb/simulation_run
add wave -noupdate -expand -group sdram /sdram_tb/tb_sd_data
add wave -noupdate -expand -group sdram /sdram_tb/tb_sd_addr
add wave -noupdate -expand -group sdram /sdram_tb/tb_sd_dqm
add wave -noupdate -expand -group sdram /sdram_tb/tb_sd_ba
add wave -noupdate -expand -group sdram /sdram_tb/tb_sd_cs
add wave -noupdate -expand -group sdram /sdram_tb/tb_sd_we
add wave -noupdate -expand -group sdram /sdram_tb/tb_sd_ras
add wave -noupdate -expand -group sdram /sdram_tb/tb_sd_cas
add wave -noupdate -expand -group system /sdram_tb/tb_init
add wave -noupdate -expand -group system /sdram_tb/tb_clk
add wave -noupdate -expand -group system /sdram_tb/tb_clkref
add wave -noupdate -expand -group interface /sdram_tb/tb_din
add wave -noupdate -expand -group interface /sdram_tb/tb_dout
add wave -noupdate -expand -group interface /sdram_tb/tb_addr
add wave -noupdate -expand -group interface /sdram_tb/tb_oe
add wave -noupdate -expand -group interface /sdram_tb/tb_we
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7140577 ps} 0} {{Cursor 2} {1000000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 292
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
WaveRestoreZoom {0 ps} {28150352 ps}
