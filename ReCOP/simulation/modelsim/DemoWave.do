onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_level_tb/recop/control_unit_inst/reset
add wave -noupdate -radix unsigned /top_level_tb/recop/datapath_inst/program_counter
add wave -noupdate /top_level_tb/clk
add wave -noupdate -radix hexadecimal /top_level_tb/fixed_number
add wave -noupdate -radix hexadecimal /top_level_tb/SWITCHES
add wave -noupdate -radix hexadecimal /top_level_tb/SOP_SIGNAL
add wave -noupdate -divider Recop
add wave -noupdate /top_level_tb/recop/control_unit_inst/current_stage
add wave -noupdate /top_level_tb/recop/control_unit_inst/opcode
add wave -noupdate -radix hexadecimal /top_level_tb/recop/SIP
add wave -noupdate /top_level_tb/recop/datapath_inst/program_counter
add wave -noupdate -radix hexadecimal /top_level_tb/recop/control_unit_inst/instruction
add wave -noupdate -radix hexadecimal /top_level_tb/recop/SOP
add wave -noupdate -radix hexadecimal /top_level_tb/recop/datapath_inst/inst_register_file/address_b
add wave -noupdate -radix hexadecimal /top_level_tb/recop/datapath_inst/inst_register_file/data_b
add wave -noupdate -radix hexadecimal /top_level_tb/recop/datapath_inst/inst_register_file/wren_b
add wave -noupdate -radix hexadecimal /top_level_tb/recop/datapath_inst/inst_register_file/q_b
add wave -noupdate -divider SSOP
add wave -noupdate /top_level_tb/recop/datapath_inst/ssop_flag
add wave -noupdate -radix hexadecimal /top_level_tb/recop/datapath_inst/read_data_two_signal
add wave -noupdate -divider RegFile
add wave -noupdate /top_level_tb/recop/control_unit_inst/SSOP_FLAG
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1449017 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 343
configure wave -valuecolwidth 164
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {8510682 ps}
