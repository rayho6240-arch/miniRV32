vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xil_defaultlib

vmap xpm modelsim_lib/msim/xpm
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../../ipstatic" "+incdir+../../../../../../../../../Applications/AMD_Vivado/2025.2/Vivado/data/rsb/busdef" \
"D:/Applications/AMD_Vivado/2025.2/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm  -93  \
"D:/Applications/AMD_Vivado/2025.2/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../ipstatic" "+incdir+../../../../../../../../../Applications/AMD_Vivado/2025.2/Vivado/data/rsb/busdef" \
"../../../../cpu_stage6_vga.gen/sources_1/ip/clk_wiz_2/clk_wiz_2_clk_wiz.v" \
"../../../../cpu_stage6_vga.gen/sources_1/ip/clk_wiz_2/clk_wiz_2.v" \

vlog -work xil_defaultlib \
"glbl.v"

