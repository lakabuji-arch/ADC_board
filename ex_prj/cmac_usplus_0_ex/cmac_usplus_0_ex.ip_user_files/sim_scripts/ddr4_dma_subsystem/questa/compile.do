vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/xpm
vlib questa_lib/msim/proc_sys_reset_v5_0_17
vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/smartconnect_v1_0
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/axi_register_slice_v2_1_36
vlib questa_lib/msim/axi_vip_v1_1_22
vlib questa_lib/msim/microblaze_v11_0_16
vlib questa_lib/msim/lmb_v10_v3_0_16
vlib questa_lib/msim/lmb_bram_if_cntlr_v4_0_27
vlib questa_lib/msim/blk_mem_gen_v8_4_12
vlib questa_lib/msim/iomodule_v3_1_13
vlib questa_lib/msim/axi_datamover_v5_1_37

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap xpm questa_lib/msim/xpm
vmap proc_sys_reset_v5_0_17 questa_lib/msim/proc_sys_reset_v5_0_17
vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap smartconnect_v1_0 questa_lib/msim/smartconnect_v1_0
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_36 questa_lib/msim/axi_register_slice_v2_1_36
vmap axi_vip_v1_1_22 questa_lib/msim/axi_vip_v1_1_22
vmap microblaze_v11_0_16 questa_lib/msim/microblaze_v11_0_16
vmap lmb_v10_v3_0_16 questa_lib/msim/lmb_v10_v3_0_16
vmap lmb_bram_if_cntlr_v4_0_27 questa_lib/msim/lmb_bram_if_cntlr_v4_0_27
vmap blk_mem_gen_v8_4_12 questa_lib/msim/blk_mem_gen_v8_4_12
vmap iomodule_v3_1_13 questa_lib/msim/iomodule_v3_1_13
vmap axi_datamover_v5_1_37 questa_lib/msim/axi_datamover_v5_1_37

vlog -work xilinx_vip  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"D:/Vivado_2025_2/2025.2/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"D:/Vivado_2025_2/2025.2/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"D:/Vivado_2025_2/2025.2/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work proc_sys_reset_v5_0_17  -93  \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/9438/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_1/sim/bd_141e_psr_aclk_0.vhd" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/0848/hdl/sc_switchboard_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_2/sim/bd_141e_arsw_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_3/sim/bd_141e_rsw_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_4/sim/bd_141e_awsw_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_5/sim/bd_141e_wsw_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_6/sim/bd_141e_bsw_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/3d9a/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_7/sim/bd_141e_s00mmu_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/7785/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_8/sim/bd_141e_s00tr_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/3051/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_9/sim/bd_141e_s00sic_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/852f/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_10/sim/bd_141e_s00a2s_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_11/sim/bd_141e_sawn_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_12/sim/bd_141e_swn_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_13/sim/bd_141e_sbn_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_14/sim/bd_141e_s01mmu_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_15/sim/bd_141e_s01tr_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_16/sim/bd_141e_s01sic_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_17/sim/bd_141e_s01a2s_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_18/sim/bd_141e_sarn_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_19/sim/bd_141e_srn_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/fca9/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_20/sim/bd_141e_m00s2a_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_21/sim/bd_141e_m00arn_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_22/sim/bd_141e_m00rn_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_23/sim/bd_141e_m00awn_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_24/sim/bd_141e_m00wn_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_25/sim/bd_141e_m00bn_0.sv" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/e44a/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/ip/ip_26/sim/bd_141e_m00e_0.sv" \

vlog -work xil_defaultlib  -incr -mfcu   +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/bd_0/sim/bd_141e.v" \

vcom -work smartconnect_v1_0  -93  \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/cb42/hdl/sc_ultralite_v1_0_rfs.vhd" \

vlog -work smartconnect_v1_0  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/cb42/hdl/sc_ultralite_v1_0_rfs.sv" \

vlog -work axi_infrastructure_v1_1_0  -incr -mfcu   +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_36  -incr -mfcu   +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/bc4b/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_22  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/b16a/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_smartconnect_0_0/sim/ddr4_dma_subsystem_smartconnect_0_0.sv" \

vcom -work microblaze_v11_0_16  -93  \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/c957/hdl/microblaze_v11_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/bd_0/ip/ip_0/sim/bd_8936_microblaze_I_0.vhd" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/bd_0/ip/ip_1/sim/bd_8936_rst_0_0.vhd" \

vcom -work lmb_v10_v3_0_16  -93  \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/dac4/hdl/lmb_v10_v3_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/bd_0/ip/ip_2/sim/bd_8936_ilmb_0.vhd" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/bd_0/ip/ip_3/sim/bd_8936_dlmb_0.vhd" \

vcom -work lmb_bram_if_cntlr_v4_0_27  -93  \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/7cd0/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/bd_0/ip/ip_4/sim/bd_8936_dlmb_cntlr_0.vhd" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/bd_0/ip/ip_5/sim/bd_8936_ilmb_cntlr_0.vhd" \

vlog -work blk_mem_gen_v8_4_12  -incr -mfcu   +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/42f3/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -mfcu   +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/bd_0/ip/ip_6/sim/bd_8936_lmb_bram_I_0.v" \

vcom -work xil_defaultlib  -93  \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/bd_0/ip/ip_7/sim/bd_8936_second_dlmb_cntlr_0.vhd" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/bd_0/ip/ip_8/sim/bd_8936_second_ilmb_cntlr_0.vhd" \

vlog -work xil_defaultlib  -incr -mfcu   +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/bd_0/ip/ip_9/sim/bd_8936_second_lmb_bram_I_0.v" \

vcom -work iomodule_v3_1_13  -93  \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/e11b/hdl/iomodule_v3_1_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/bd_0/ip/ip_10/sim/bd_8936_iomodule_0_0.vhd" \

vlog -work xil_defaultlib  -incr -mfcu   +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/bd_0/sim/bd_8936.v" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_0/sim/ddr4_dma_subsystem_ddr4_0_0_microblaze_mcs.v" \

vlog -work xil_defaultlib  -incr -mfcu  -sv -L smartconnect_v1_0 -L axi_vip_v1_1_22 -L xilinx_vip  +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/phy/ddr4_dma_subsystem_ddr4_0_0_phy_ddr4.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy_behav.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/iob/ddr4_phy_v2_2_iob_byte.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/iob/ddr4_phy_v2_2_iob.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/clocking/ddr4_phy_v2_2_pll.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_tristate_wrapper.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_riuor_wrapper.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_control_wrapper.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_byte_wrapper.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_bitslice_wrapper.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/ip_top/ddr4_dma_subsystem_ddr4_0_0_phy.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_wtr.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ref.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_rd_wr.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_periodic.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_group.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ecc_merge_enc.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ecc_gen.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ecc_fi_xor.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ecc_dec_fix.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ecc_buf.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ecc.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_ctl.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_cmd_mux_c.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_cmd_mux_ap.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_arb_p.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_arb_mux_p.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_arb_c.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_arb_a.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_act_timer.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc_act_rank.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/controller/ddr4_v2_2_mc.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ui/ddr4_v2_2_ui_wr_data.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ui/ddr4_v2_2_ui_rd_data.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ui/ddr4_v2_2_ui_cmd.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ui/ddr4_v2_2_ui.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_ar_channel.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_aw_channel.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_b_channel.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_cmd_arbiter.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_cmd_fsm.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_cmd_translator.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_fifo.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_incr_cmd.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_r_channel.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_w_channel.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_wr_cmd_fsm.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_wrap_cmd.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_a_upsizer.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_register_slice.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axi_upsizer.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_axic_register_slice.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_carry_and.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_carry_latch_and.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_carry_latch_or.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_carry_or.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_command_fifo.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_comparator.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_comparator_sel.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_comparator_sel_static.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_r_upsizer.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi/ddr4_v2_2_w_upsizer.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_addr_decode.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_read.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_reg_bank.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_reg.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_top.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/axi_ctrl/ddr4_v2_2_axi_ctrl_write.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/clocking/ddr4_v2_2_infrastructure.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_xsdb_bram.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_write.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_wr_byte.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_wr_bit.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_sync.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_read.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_rd_en.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_pi.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_mc_odt.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_debug_microblaze.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_cplx_data.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_cplx.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_config_rom.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_addr_decode.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_top.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal_xsdb_arbiter.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_cal.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_chipscope_xsdb_slave.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_v2_2_dp_AB9.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top/ddr4_dma_subsystem_ddr4_0_0_ddr4.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top/ddr4_dma_subsystem_ddr4_0_0_ddr4_mem_intfc.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal/ddr4_dma_subsystem_ddr4_0_0_ddr4_cal_riu.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top/ddr4_dma_subsystem_ddr4_0_0.sv" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/tb/ddr4_dma_subsystem_ddr4_0_0_microblaze_mcs_0.sv" \

vcom -work axi_datamover_v5_1_37  -93  \
"../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/d44a/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vcom -work xil_defaultlib  -93  \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_axi_datamover_0_0/sim/ddr4_dma_subsystem_axi_datamover_0_0.vhd" \
"../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_proc_sys_reset_0_0/sim/ddr4_dma_subsystem_proc_sys_reset_0_0.vhd" \

vlog -work xil_defaultlib  -incr -mfcu   +define+SIM_SPEED_UP= "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/f0b6/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/00fe/hdl/verilog" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ipshared/ec67/hdl" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+../../../../../../Vivado_2025_2/2025.2/Vivado/data/rsb/busdef" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/ip_1/rtl/map" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/ip_top" "+incdir+../../../../cmac_usplus_0_ex.gen/sources_1/bd/ddr4_dma_subsystem/ip/ddr4_dma_subsystem_ddr4_0_0/rtl/cal" "+incdir+D:/Vivado_2025_2/2025.2/Vivado/data/xilinx_vip/include" \
"../../../bd/ddr4_dma_subsystem/sim/ddr4_dma_subsystem.v" \

vlog -work xil_defaultlib \
"glbl.v"

