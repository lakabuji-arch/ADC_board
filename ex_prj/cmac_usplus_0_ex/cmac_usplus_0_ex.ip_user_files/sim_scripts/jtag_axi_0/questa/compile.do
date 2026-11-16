vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xpm
vlib questa_lib/msim/jtag_axi
vlib questa_lib/msim/xil_defaultlib

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xpm questa_lib/msim/xpm
vmap jtag_axi questa_lib/msim/jtag_axi
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xilinx_vip  -incr -mfcu  -sv -L cmac_usplus_v3_1_24  +define+SIM_SPEED_UP= "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -incr -mfcu  -sv -L cmac_usplus_v3_1_24  +define+SIM_SPEED_UP= "+incdir+../../../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/ip/jtag_axi_0/hdl/verilog" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"D:/Vivado_2025_2/2025.2/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"D:/Vivado_2025_2/2025.2/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work jtag_axi  -incr -mfcu   +define+SIM_SPEED_UP= "+incdir+../../../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/ip/jtag_axi_0/hdl/verilog" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../ipstatic/hdl/jtag_axi_v1_2_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu   +define+SIM_SPEED_UP= "+incdir+../../../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/ip/jtag_axi_0/hdl/verilog" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/ip/jtag_axi_0/sim/jtag_axi_0.v" \

vlog -work xil_defaultlib \
"glbl.v"

