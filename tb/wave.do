onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/vga_clk
add wave -noupdate /top/DE2_fpga/reset_n
add wave -noupdate /top/vga_hs
add wave -noupdate /top/vga_vs
add wave -noupdate /top/vga_blank
add wave -noupdate -divider Maze
add wave -noupdate -radix hexadecimal /top/DE2_fpga/maze/spotX
add wave -noupdate -radix hexadecimal /top/DE2_fpga/maze/spotY
add wave -noupdate -radix hexadecimal /top/DE2_fpga/maze/num_carreX
add wave -noupdate -radix hexadecimal /top/DE2_fpga/maze/offsetX
add wave -noupdate -radix hexadecimal /top/DE2_fpga/maze/num_carreY
add wave -noupdate -radix hexadecimal /top/DE2_fpga/maze/offsetY
add wave -noupdate -radix hexadecimal /top/DE2_fpga/maze/rom_addr
add wave -noupdate -radix hexadecimal /top/DE2_fpga/maze/wall_centerX
add wave -noupdate -radix hexadecimal /top/DE2_fpga/maze/wall_centerY
add wave -noupdate -radix hexadecimal /top/DE2_fpga/maze/wall_num
add wave -noupdate -divider Wall
add wave -noupdate -radix hexadecimal /top/DE2_fpga/wall/spotY
add wave -noupdate -radix hexadecimal /top/DE2_fpga/wall/spotX
add wave -noupdate -radix hexadecimal /top/DE2_fpga/wall/spotX_r
add wave -noupdate -radix hexadecimal /top/DE2_fpga/wall/wall_centerX
add wave -noupdate -radix hexadecimal /top/DE2_fpga/wall/wall_centerY
add wave -noupdate -radix hexadecimal /top/DE2_fpga/wall/offsetX
add wave -noupdate -radix hexadecimal /top/DE2_fpga/wall/offsetY
add wave -noupdate -radix hexadecimal /top/DE2_fpga/wall/rom
add wave -noupdate -radix hexadecimal /top/DE2_fpga/wall/rom_addr
add wave -noupdate -radix hexadecimal /top/DE2_fpga/wall/sprite_num
add wave -noupdate -radix hexadecimal /top/DE2_fpga/wall/wall_color
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {999602 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1255320 ns} {1256959 ns}
