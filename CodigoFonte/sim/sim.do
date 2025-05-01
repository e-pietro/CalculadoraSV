if {[file isdirectory work]} {vdel -all -lib work}
vlib work
vmap work work

vlog -work work ../rtl/calculadora_top.sv
vlog -work work ../rtl/calculadora.sv
vlog -work work ../rtl/display_ctrl.sv
vlog -work work tb_calculadora_top.sv
vsim -voptargs=+acc work.tb_Calculadora_Top

quietly set StdArithNoWarnings 1
quietly set StdVitalGlitchNoWarnings 1

do wave.do
run 630000ns
