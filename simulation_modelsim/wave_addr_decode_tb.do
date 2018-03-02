onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /addr_decode_tb/tb_addr
add wave -noupdate /addr_decode_tb/tb_ioreq_n
add wave -noupdate /addr_decode_tb/tb_mreq_n
add wave -noupdate /addr_decode_tb/tb_we_F000
add wave -noupdate /addr_decode_tb/tb_we_F800
add wave -noupdate -divider <NULL>
add wave -noupdate /addr_decode_tb/tb_cs_io_n
add wave -noupdate /addr_decode_tb/sel_io_1_n
add wave -noupdate /addr_decode_tb/sel_io_kybrow_n
add wave -noupdate /addr_decode_tb/sel_io_pio_n
add wave -noupdate -divider <NULL>
add wave -noupdate -expand /addr_decode_tb/tb_cs_mem_n
add wave -noupdate /addr_decode_tb/sel_ram_n
add wave -noupdate /addr_decode_tb/sel_vram_n
add wave -noupdate /addr_decode_tb/sel_rom_n
add wave -noupdate /addr_decode_tb/tb_write_protect
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {433298833 ps} 0}
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
WaveRestoreZoom {0 ps} {1376361 ns}
