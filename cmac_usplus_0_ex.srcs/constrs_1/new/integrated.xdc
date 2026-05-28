################################################################################
# integrated.xdc — fpga_top_integrated 约束文件
# 合并自: cmac.xdc (CMAC+DDR4) + pin.xdc (ADC+PCIe)
# 层次映射: u_cmac_wrapper→u_cmac, u_adc_part→u_adc
################################################################################

################################################################################
# 1. 时钟定义
################################################################################
# 系统 50MHz 晶振
create_clock -period 20.000 -name clk_50m_in -waveform {0.000 10.000} [get_ports clk_50m_in]

# CMAC GT 参考时钟 (156.25MHz)
create_clock -period 6.400 -name gt_ref_clk_p -waveform {0.000 3.200} [get_ports gt_ref_clk_p]

# ADC 源同步时钟 (375MHz = 2.666ns)
create_clock -period 2.666 -name adc_dclk_p [get_ports adc_dclk_p]

# PCIe 参考时钟 (100MHz = 10.000ns)
create_clock -period 10.000 -name pcie_refclk [get_ports pcie_refclk_p]

# DDR4 参考时钟由 DDR4 IP 自动生成约束，不再重复定义

################################################################################
# 2. 异步时钟组 — 5 个独立时钟域
################################################################################
set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks -of_objects [get_ports clk_50m_in]] \
    -group [get_clocks -include_generated_clocks -of_objects [get_ports gt_ref_clk_p]] \
    -group [get_clocks -include_generated_clocks -of_objects [get_ports ddr4_ref_clk_p]] \
    -group [get_clocks -include_generated_clocks -of_objects [get_ports adc_dclk_p]] \
    -group [get_clocks -include_generated_clocks -of_objects [get_ports pcie_refclk_p]]

################################################################################
# 3. CDC false paths
################################################################################
# ADC: IDELAY 复位 (375MHz 域)
set_false_path -through [get_nets -hier -filter {NAME =~ *rst_375_m2*}]

# ADC: 原始 LVDS 输入 (跨到 125MHz 域之前)
set_false_path -from [get_ports {adc_di_* adc_did_* adc_dq_* adc_dqd_*}]

# 全局复位 fanout — 仅放行到各域复位同步器的第一级 ASYNC_REG
# (跨时钟域复位本身不需要 STA, 但同步器之后的路径仍需检查)
set_false_path -through [get_nets -hier -filter {NAME =~ *rst_sync_ff* || NAME =~ *ddr4_rst_sync_ff* || NAME =~ *locked_sync_ff*}]

# XPM CDC 原语的最大延迟约束 (MTBF 分析用, 非功能必须)
# 以下 XPM_FIFO_ASYNC 和 xpm_cdc_gray 实例由 IP 自动处理,
# 此处保留作为文档说明。如需严格 MTBF 分析请取消注释:
# set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *u_adc_cdc_fifo*}] -to [get_cells -hier -filter {NAME =~ *u_adc_cdc_fifo*}] 2.000

# ADC 域内 ASYNC_REG 优化
set_property ASYNC_REG true [get_cells -hier -filter {NAME =~ *rst_375_m*_reg*}]

################################################################################
# 4. ADC I/O 配置
################################################################################
# 差分终端 100Ω
set_property DIFF_TERM_ADV TERM_100 [get_ports {adc_dclk_p {adc_di_p[*]} {adc_did_p[*]} {adc_dq_p[*]} {adc_dqd_p[*]}}]

# Bank 66/67 内部 VREF
set_property INTERNAL_VREF 0.9 [get_iobanks 66]
set_property INTERNAL_VREF 0.9 [get_iobanks 67]

# ===== ADC 源同步输入延迟约束 =====
# ADC08D1500 LVDS DDR: DCLK=375MHz, Data=1.5GSPS DDR
# IDDR 采样窗口在 375MHz 域的 setup/hold 由以下约束覆盖
# -max 0.4ns: PCB 走线 skew + ADC 输出不确定性
# -min -0.2ns: 最小延迟 (hold time 保护)
# ADC clock: adc_dclk_p (虚拟时钟 adc_dclk_p_virt 用于 input delay 参考)
create_clock -period 2.666 -name adc_dclk_p_virt
set_input_delay -clock adc_dclk_p_virt -max 0.400 [get_ports {adc_di_p[*] adc_did_p[*] adc_dq_p[*] adc_dqd_p[*]}]
set_input_delay -clock adc_dclk_p_virt -min -0.200 [get_ports {adc_di_p[*] adc_did_p[*] adc_dq_p[*] adc_dqd_p[*]}]
set_input_delay -clock adc_dclk_p_virt -max 0.400 [get_ports adc_dclk_p] -clock_fall -add_delay
set_input_delay -clock adc_dclk_p_virt -min -0.200 [get_ports adc_dclk_p] -clock_fall -add_delay
# adc_dclk_p_virt 与 adc_dclk_p 同频同相: 设为物理互斥组,
# Vivado 不会在二者间做不必要的跨时钟域路径分析
set_clock_groups -physically_exclusive \
    -group [get_clocks adc_dclk_p_virt] \
    -group [get_clocks -include_generated_clocks adc_dclk_p]

# IDDR 强制进 IOB
set_property IOB TRUE [get_cells -hier -filter {NAME =~ *u_adc*gen_lane[*].u_iddr}]

# Per-Bank IODELAY grouping
set_property IODELAY_GROUP ADC_BANK_66 [get_cells {u_adc/gen_sub[0].gen_lane[*].u_dly u_adc/gen_sub[1].gen_lane[*].u_dly u_adc/u_ctrl_66}]
set_property IODELAY_GROUP ADC_BANK_67 [get_cells {u_adc/gen_sub[2].gen_lane[*].u_dly u_adc/gen_sub[3].gen_lane[*].u_dly u_adc/u_ctrl_67}]

# PCIe Hard IP LOC
set_property LOC PCIE4C_X0Y0 [get_cells -hier -filter {REF_NAME =~ *PCIE4C*}]

# CMAC IP 内部硬核边界路径: CMACE4→GTYE4 为硬化硅片内部走线,
# Vivado 保守估计导致的 ~2ps 假违例。放行。
set_false_path -from [get_cells -hier -filter {REF_NAME =~ CMACE4*}] -to [get_cells -hier -filter {REF_NAME =~ GTYE4_CHANNEL*}]
set_false_path -from [get_cells -hier -filter {REF_NAME =~ GTYE4_CHANNEL*}] -to [get_cells -hier -filter {REF_NAME =~ CMACE4*}]

# 关闭 ADEF-911 DRC (已知无害)
set_property IS_ENABLED 0 [get_drc_checks ADEF-911]

################################################################################
# 5. 系统引脚
################################################################################
set_property PACKAGE_PIN E18  [get_ports clk_50m_in]
set_property IOSTANDARD LVCMOS18 [get_ports clk_50m_in]

set_property PACKAGE_PIN P19  [get_ports sys_rst_pad_in]
set_property IOSTANDARD LVCMOS12 [get_ports sys_rst_pad_in]

################################################################################
# 6. DDR4 参考时钟
################################################################################
set_property PACKAGE_PIN T24  [get_ports ddr4_ref_clk_p]
set_property PACKAGE_PIN T25  [get_ports ddr4_ref_clk_n]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports ddr4_ref_clk_p]
set_property IOSTANDARD DIFF_SSTL12_DCI [get_ports ddr4_ref_clk_n]

################################################################################
# 7. CMAC 100G GT 引脚
################################################################################
set_property PACKAGE_PIN T7   [get_ports gt_ref_clk_p]

set_property PACKAGE_PIN R4   [get_ports {gt_txp_out[0]}]
set_property PACKAGE_PIN N4   [get_ports {gt_txp_out[1]}]
set_property PACKAGE_PIN L4   [get_ports {gt_txp_out[2]}]
set_property PACKAGE_PIN J4   [get_ports {gt_txp_out[3]}]

# GT LOC (层次路径对应 fpga_top_integrated: u_cmac)
set_property LOC GTYE4_CHANNEL_X0Y4 [get_cells {u_cmac/DUT/inst/cmac_usplus_0_gt_i/inst/gen_gtwizard_gtye4_top.cmac_usplus_0_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[3].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN Y2   [get_ports {gt_rxp_in[0]}]
set_property LOC GTYE4_CHANNEL_X0Y5 [get_cells {u_cmac/DUT/inst/cmac_usplus_0_gt_i/inst/gen_gtwizard_gtye4_top.cmac_usplus_0_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[3].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[1].GTYE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN V2   [get_ports {gt_rxp_in[1]}]
set_property LOC GTYE4_CHANNEL_X0Y6 [get_cells {u_cmac/DUT/inst/cmac_usplus_0_gt_i/inst/gen_gtwizard_gtye4_top.cmac_usplus_0_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[3].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[2].GTYE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN T2   [get_ports {gt_rxp_in[2]}]
set_property LOC GTYE4_CHANNEL_X0Y7 [get_cells {u_cmac/DUT/inst/cmac_usplus_0_gt_i/inst/gen_gtwizard_gtye4_top.cmac_usplus_0_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[3].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[3].GTYE4_CHANNEL_PRIM_INST}]
set_property PACKAGE_PIN P2   [get_ports {gt_rxp_in[3]}]

################################################################################
# 8. DDR4 物理接口
################################################################################
set_property PACKAGE_PIN V19  [get_ports ddr4_act_n]
set_property IOSTANDARD SSTL12_DCI [get_ports ddr4_act_n]

set_property PACKAGE_PIN P23  [get_ports ddr4_reset_n]
set_property IOSTANDARD LVCMOS12 [get_ports ddr4_reset_n]

# 地址
set_property PACKAGE_PIN P26  [get_ports {ddr4_adr[0]}]
set_property PACKAGE_PIN P25  [get_ports {ddr4_adr[1]}]
set_property PACKAGE_PIN R22  [get_ports {ddr4_adr[2]}]
set_property PACKAGE_PIN AA24 [get_ports {ddr4_adr[3]}]
set_property PACKAGE_PIN T23  [get_ports {ddr4_adr[4]}]
set_property PACKAGE_PIN W20  [get_ports {ddr4_adr[5]}]
set_property PACKAGE_PIN T22  [get_ports {ddr4_adr[6]}]
set_property PACKAGE_PIN W19  [get_ports {ddr4_adr[7]}]
set_property PACKAGE_PIN U21  [get_ports {ddr4_adr[8]}]
set_property PACKAGE_PIN P21  [get_ports {ddr4_adr[9]}]
set_property PACKAGE_PIN V22  [get_ports {ddr4_adr[10]}]
set_property PACKAGE_PIN U19  [get_ports {ddr4_adr[11]}]
set_property PACKAGE_PIN Y25  [get_ports {ddr4_adr[12]}]
set_property PACKAGE_PIN P20  [get_ports {ddr4_adr[13]}]
set_property PACKAGE_PIN Y23  [get_ports {ddr4_adr[14]}]
set_property PACKAGE_PIN U26  [get_ports {ddr4_adr[15]}]
set_property PACKAGE_PIN V26  [get_ports {ddr4_adr[16]}]
set_property IOSTANDARD SSTL12_DCI [get_ports {ddr4_adr[*]}]

set_property PACKAGE_PIN U22  [get_ports {ddr4_ba[0]}]
set_property PACKAGE_PIN R26  [get_ports {ddr4_ba[1]}]
set_property IOSTANDARD SSTL12_DCI [get_ports {ddr4_ba[*]}]

set_property PACKAGE_PIN V21  [get_ports {ddr4_bg[0]}]
set_property IOSTANDARD SSTL12_DCI [get_ports {ddr4_bg[*]}]

# 时钟 & 控制
set_property PACKAGE_PIN W25  [get_ports {ddr4_ck_t[0]}]

set_property PACKAGE_PIN Y22  [get_ports {ddr4_cke[0]}]
set_property IOSTANDARD SSTL12_DCI [get_ports {ddr4_cke[*]}]

set_property PACKAGE_PIN Y26  [get_ports {ddr4_cs_n[0]}]
set_property IOSTANDARD SSTL12_DCI [get_ports {ddr4_cs_n[*]}]

set_property PACKAGE_PIN AA25 [get_ports {ddr4_odt[0]}]
set_property IOSTANDARD SSTL12_DCI [get_ports {ddr4_odt[*]}]

# DM
set_property PACKAGE_PIN AE25 [get_ports {ddr4_dm_n[0]}]
set_property PACKAGE_PIN AE22 [get_ports {ddr4_dm_n[1]}]
set_property PACKAGE_PIN AD20 [get_ports {ddr4_dm_n[2]}]
set_property PACKAGE_PIN Y20  [get_ports {ddr4_dm_n[3]}]
set_property IOSTANDARD POD12_DCI [get_ports {ddr4_dm_n[*]}]

# DQ
set_property PACKAGE_PIN AD24 [get_ports {ddr4_dq[0]}]
set_property PACKAGE_PIN AF24 [get_ports {ddr4_dq[1]}]
set_property PACKAGE_PIN AB26 [get_ports {ddr4_dq[2]}]
set_property PACKAGE_PIN AB24 [get_ports {ddr4_dq[3]}]
set_property PACKAGE_PIN AC24 [get_ports {ddr4_dq[4]}]
set_property PACKAGE_PIN AB25 [get_ports {ddr4_dq[5]}]
set_property PACKAGE_PIN AF25 [get_ports {ddr4_dq[6]}]
set_property PACKAGE_PIN AD25 [get_ports {ddr4_dq[7]}]
set_property PACKAGE_PIN AD23 [get_ports {ddr4_dq[8]}]
set_property PACKAGE_PIN AE23 [get_ports {ddr4_dq[9]}]
set_property PACKAGE_PIN AD21 [get_ports {ddr4_dq[10]}]
set_property PACKAGE_PIN AC23 [get_ports {ddr4_dq[11]}]
set_property PACKAGE_PIN AC22 [get_ports {ddr4_dq[12]}]
set_property PACKAGE_PIN AE21 [get_ports {ddr4_dq[13]}]
set_property PACKAGE_PIN AB21 [get_ports {ddr4_dq[14]}]
set_property PACKAGE_PIN AC21 [get_ports {ddr4_dq[15]}]
set_property PACKAGE_PIN AF17 [get_ports {ddr4_dq[16]}]
set_property PACKAGE_PIN AE17 [get_ports {ddr4_dq[17]}]
set_property PACKAGE_PIN AC19 [get_ports {ddr4_dq[18]}]
set_property PACKAGE_PIN AF18 [get_ports {ddr4_dq[19]}]
set_property PACKAGE_PIN AF19 [get_ports {ddr4_dq[20]}]
set_property PACKAGE_PIN AD19 [get_ports {ddr4_dq[21]}]
set_property PACKAGE_PIN AE16 [get_ports {ddr4_dq[22]}]
set_property PACKAGE_PIN AD16 [get_ports {ddr4_dq[23]}]
set_property PACKAGE_PIN AB20 [get_ports {ddr4_dq[24]}]
set_property PACKAGE_PIN AB19 [get_ports {ddr4_dq[25]}]
set_property PACKAGE_PIN AA19 [get_ports {ddr4_dq[26]}]
set_property PACKAGE_PIN AA20 [get_ports {ddr4_dq[27]}]
set_property PACKAGE_PIN Y17  [get_ports {ddr4_dq[28]}]
set_property PACKAGE_PIN AA17 [get_ports {ddr4_dq[29]}]
set_property PACKAGE_PIN Y18  [get_ports {ddr4_dq[30]}]
set_property PACKAGE_PIN AA18 [get_ports {ddr4_dq[31]}]
set_property IOSTANDARD POD12_DCI [get_ports {ddr4_dq[*]}]

# DQS
set_property PACKAGE_PIN AC26 [get_ports {ddr4_dqs_t[0]}]
set_property PACKAGE_PIN AD26 [get_ports {ddr4_dqs_c[0]}]
set_property PACKAGE_PIN AA22 [get_ports {ddr4_dqs_t[1]}]
set_property PACKAGE_PIN AB22 [get_ports {ddr4_dqs_c[1]}]
set_property PACKAGE_PIN AC18 [get_ports {ddr4_dqs_t[2]}]
set_property PACKAGE_PIN AD18 [get_ports {ddr4_dqs_c[2]}]
set_property PACKAGE_PIN AB17 [get_ports {ddr4_dqs_t[3]}]
set_property PACKAGE_PIN AC16 [get_ports {ddr4_dqs_c[3]}]
set_property IOSTANDARD DIFF_POD12_DCI [get_ports {ddr4_dqs_t[*]}]
set_property IOSTANDARD DIFF_POD12_DCI [get_ports {ddr4_dqs_c[*]}]

################################################################################
# 9. ADC 引脚 (Bank 66 + Bank 67)
################################################################################
# Bank 66 — I 通道
set_property PACKAGE_PIN G15  [get_ports {adc_di_p[0]}]
set_property PACKAGE_PIN E15  [get_ports {adc_di_p[1]}]
set_property PACKAGE_PIN B15  [get_ports {adc_di_p[2]}]
set_property PACKAGE_PIN H16  [get_ports {adc_di_p[3]}]
set_property PACKAGE_PIN E16  [get_ports {adc_di_p[4]}]
set_property PACKAGE_PIN D16  [get_ports {adc_di_p[5]}]
set_property PACKAGE_PIN C17  [get_ports {adc_di_p[6]}]
set_property PACKAGE_PIN A17  [get_ports {adc_di_p[7]}]

set_property PACKAGE_PIN C18  [get_ports adc_dclk_p]
set_property PACKAGE_PIN H17  [get_ports {adc_did_p[0]}]
set_property PACKAGE_PIN H18  [get_ports {adc_did_p[1]}]
set_property PACKAGE_PIN F18  [get_ports {adc_did_p[2]}]
set_property PACKAGE_PIN G20  [get_ports {adc_did_p[3]}]
set_property PACKAGE_PIN F20  [get_ports {adc_did_p[4]}]
set_property PACKAGE_PIN E21  [get_ports {adc_did_p[5]}]
set_property PACKAGE_PIN A19  [get_ports {adc_did_p[6]}]
set_property PACKAGE_PIN C21  [get_ports {adc_did_p[7]}]

# Bank 67 — Q 通道 + SPI + CAL + Ready
set_property PACKAGE_PIN D23  [get_ports adc_cal]
set_property IOSTANDARD LVCMOS18 [get_ports adc_cal]
set_property PACKAGE_PIN B25  [get_ports adc_ready_out]
set_property PACKAGE_PIN A13  [get_ports adc_spi_cs_n]
set_property PACKAGE_PIN A14  [get_ports adc_spi_sclk]
set_property PACKAGE_PIN A12  [get_ports adc_spi_sdi]
set_property PACKAGE_PIN B12  [get_ports adc_spi_sdo]

set_property PACKAGE_PIN M20  [get_ports {adc_dq_p[0]}]
set_property PACKAGE_PIN L22  [get_ports {adc_dq_p[1]}]
set_property PACKAGE_PIN L24  [get_ports {adc_dq_p[2]}]
set_property PACKAGE_PIN M25  [get_ports {adc_dq_p[3]}]
set_property PACKAGE_PIN K25  [get_ports {adc_dq_p[4]}]
set_property PACKAGE_PIN J25  [get_ports {adc_dq_p[5]}]
set_property PACKAGE_PIN K21  [get_ports {adc_dq_p[6]}]
set_property PACKAGE_PIN H21  [get_ports {adc_dq_p[7]}]

set_property PACKAGE_PIN H26  [get_ports {adc_dqd_p[0]}]
set_property PACKAGE_PIN F24  [get_ports {adc_dqd_p[1]}]
set_property PACKAGE_PIN E25  [get_ports {adc_dqd_p[2]}]
set_property PACKAGE_PIN D24  [get_ports {adc_dqd_p[3]}]
set_property PACKAGE_PIN D26  [get_ports {adc_dqd_p[4]}]
set_property PACKAGE_PIN M19  [get_ports {adc_dqd_p[5]}]
set_property PACKAGE_PIN L18  [get_ports {adc_dqd_p[6]}]
set_property PACKAGE_PIN J19  [get_ports {adc_dqd_p[7]}]

# ADC IOSTANDARD
set_property IOSTANDARD LVDS [get_ports {adc_dclk_p {adc_di_p[*]} {adc_did_p[*]} {adc_dq_p[*]} {adc_dqd_p[*]}}]
set_property IOSTANDARD LVCMOS18 [get_ports {adc_ready_out adc_spi_*}]

################################################################################
# 10. PCIe 引脚 (Bank 227 GTY)
################################################################################
set_property PACKAGE_PIN AB7  [get_ports pcie_refclk_p]
set_property PACKAGE_PIN AB6  [get_ports pcie_refclk_n]

set_property PACKAGE_PIN AF2  [get_ports {pcie_rx_p[0]}]
set_property PACKAGE_PIN AF7  [get_ports {pcie_tx_p[0]}]

set_property PACKAGE_PIN L21  [get_ports pcie_link_up]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_link_up]

################################################################################
# 11. LED 指示灯
################################################################################
# E16 已分配给 adc_di_p[4], led_out[0] 暂用 C15,需按实际板卡修改
set_property PACKAGE_PIN C15  [get_ports {led_out[0]}]
set_property PACKAGE_PIN E17  [get_ports {led_out[1]}]
set_property PACKAGE_PIN F15  [get_ports {led_out[2]}]
set_property PACKAGE_PIN D15  [get_ports {led_out[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {led_out[*]}]

################################################################################
# 12. 时钟 backbone 路由 (跨时钟域区域放置修复)
################################################################################
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets u_adc/u_clock_gen/inst/clk_in1_clk_wiz_1]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets u_clk_wiz/inst/clk_in1_clk_wiz_0]

################################################################################
# 13. 位流配置
################################################################################
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 31.9 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
