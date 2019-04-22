#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file /home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/fpga_md5_impl0/launch_synplify.tcl
#-- Written on Sun Jan 27 20:59:05 2019

project -close
set filename "/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/fpga_md5_impl0/fpga_md5_impl0_syn.prj"
if ([file exists "$filename"]) {
	project -load "$filename"
	project_file -remove *
} else {
	project -new "$filename"
}
set create_new 0

#device options
set_option -technology ECP5UM5G
set_option -part LFE5UM5G_85F
set_option -package BG381C
set_option -speed_grade -8

if {$create_new == 1} {
#-- add synthesis options
	set_option -symbolic_fsm_compiler true
	set_option -resource_sharing true
	set_option -vlog_std v2001
	set_option -frequency auto
	set_option -maxfan 1000
	set_option -auto_constrain_io 0
	set_option -disable_io_insertion false
	set_option -retiming false; set_option -pipe true
	set_option -force_gsr false
	set_option -compiler_compatible 0
	set_option -dup false
	
	set_option -default_enum_encoding default
	
	
	
	set_option -write_apr_constraint 1
	set_option -fix_gated_and_generated_clocks 1
	set_option -update_models_cp 0
	set_option -resolve_multiple_driver 0
	
	
}
#-- add_file options
set_option -include_path "/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice"
add_file -verilog "/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/fpga_md5_impl0/source/cross_domain_buffer.v"
add_file -verilog "/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/fpga_md5_impl0/source/delay.v"
add_file -verilog "/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/fpga_md5_impl0/source/fpga-md5.v"
add_file -verilog "/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/fpga_md5_impl0/source/lcd_line_writer.v"
add_file -verilog "/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/fpga_md5_impl0/source/liquid_crystal_display.v"
add_file -verilog "/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/fpga_md5_impl0/source/md5_brute_forcer.v"
add_file -verilog "/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/fpga_md5_impl0/source/md5_chunk_generator.v"
add_file -verilog "/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/fpga_md5_impl0/source/md5_core.v"
add_file -verilog "/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/fpga_md5_impl0/source/md5_printable_chunk_generator.v"
add_file -verilog "/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/fpga_md5_impl0/source/spi_slave.v"
add_file -verilog "/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/top.v"
#-- top module name
set_option -top_module {fpga_md5}
project -result_file {/home/patrick/dev/fpga-md5/swedishhat/hardware/lattice/fpga_md5_impl0/fpga_md5_impl0.edi}
project -save "$filename"
