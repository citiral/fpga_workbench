transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Source/fpga_workbench {C:/Source/fpga_workbench/DE0_Nano.v}
vlog -vlog01compat -work work +incdir+C:/Source/fpga_workbench {C:/Source/fpga_workbench/ram1.v}
vlog -vlog01compat -work work +incdir+C:/Source/fpga_workbench {C:/Source/fpga_workbench/chip8.v}

vlog -vlog01compat -work work +incdir+C:/Source/fpga_workbench {C:/Source/fpga_workbench/chip8_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  chip8_tb

add wave *
view structure
view signals
run -all
