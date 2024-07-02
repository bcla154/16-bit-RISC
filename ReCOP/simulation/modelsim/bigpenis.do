onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /recop_tb/DUT/datapath_inst/program_counter
add wave -noupdate -radix hexadecimal /recop_tb/DUT/control_unit_inst/instruction
add wave -noupdate /recop_tb/DUT/control_unit_inst/current_stage
add wave -noupdate -radix decimal /recop_tb/DUT/datapath_inst/inst_alu/operand_1
add wave -noupdate -radix decimal /recop_tb/DUT/datapath_inst/inst_alu/operand_2
add wave -noupdate -radix decimal /recop_tb/DUT/datapath_inst/inst_alu/result
add wave -noupdate -radix decimal /recop_tb/DUT/datapath_inst/inst_alu/alu_out
add wave -noupdate -radix decimal /recop_tb/DUT/data_mem_inst/address
add wave -noupdate -radix decimal /recop_tb/DUT/data_mem_inst/data
add wave -noupdate -radix decimal /recop_tb/DUT/data_mem_inst/wren
add wave -noupdate -radix decimal /recop_tb/DUT/data_mem_inst/q
add wave -noupdate /recop_tb/DUT/datapath_inst/inst_alu/alu_op1_mux
add wave -noupdate /recop_tb/DUT/datapath_inst/inst_alu/alu_op2_mux
add wave -noupdate /recop_tb/DUT/datapath_inst/inst_alu/alu_operation
add wave -noupdate -radix decimal /recop_tb/DUT/datapath_inst/data_memory_input
add wave -noupdate -radix decimal /recop_tb/DUT/datapath_inst/data_memory_address_out
add wave -noupdate -radix hexadecimal /recop_tb/DUT/datapath_inst/rd2_signal
add wave -noupdate /recop_tb/DUT/datapath_inst/inst_register_file/address_b
add wave -noupdate -radix decimal /recop_tb/DUT/datapath_inst/inst_register_file/q_b
add wave -noupdate -radix decimal /recop_tb/DUT/SIP
add wave -noupdate -radix decimal /recop_tb/DUT/SOP
add wave -noupdate /recop_tb/DUT/datapath_inst/inst_alu/zero_flag
add wave -noupdate /recop_tb/DUT/datapath_inst/inst_alu/clr_z
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {402738 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 366
configure wave -valuecolwidth 40
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
configure wave -timelineunits ns
update
WaveRestoreZoom {272880 ps} {722480 ps}
