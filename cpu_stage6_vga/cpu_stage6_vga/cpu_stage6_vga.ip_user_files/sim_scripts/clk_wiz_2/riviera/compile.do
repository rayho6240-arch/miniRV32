transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../ipstatic" "+incdir+../../../../../../../../../Applications/AMD_Vivado/2025.2/Vivado/data/rsb/busdef" -l xpm -l xil_defaultlib \
"D:/Applications/AMD_Vivado/2025.2/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93  -incr \
"D:/Applications/AMD_Vivado/2025.2/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../ipstatic" "+incdir+../../../../../../../../../Applications/AMD_Vivado/2025.2/Vivado/data/rsb/busdef" -l xpm -l xil_defaultlib \
"../../../../cpu_stage6_vga.gen/sources_1/ip/clk_wiz_2/clk_wiz_2_clk_wiz.v" \
"../../../../cpu_stage6_vga.gen/sources_1/ip/clk_wiz_2/clk_wiz_2.v" \

vlog -work xil_defaultlib \
"glbl.v"

