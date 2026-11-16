vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xilinx_vip
vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xil_defaultlib

vmap xilinx_vip modelsim_lib/msim/xilinx_vip
vmap xpm modelsim_lib/msim/xpm
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

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

vlog -work xpm  -incr -mfcu  -sv -L cmac_usplus_v3_1_24  +define+SIM_SPEED_UP= "+incdir+../../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"D:/Vivado_2025_2/2025.2/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"D:/Vivado_2025_2/2025.2/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L cmac_usplus_v3_1_24  +define+SIM_SPEED_UP= "+incdir+../../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../cmac_usplus_0_ex.srcs/sources_1/new/axis_100g_data_gen.sv" \
"../../../cmac_usplus_0_ex.srcs/sources_1/new/axis_100g_data_rx.sv" \
"../../../cmac_usplus_0_ex.srcs/sim_1/new/tb_system_loopback.sv" \

vlog -work xil_defaultlib \
"glbl.v"

