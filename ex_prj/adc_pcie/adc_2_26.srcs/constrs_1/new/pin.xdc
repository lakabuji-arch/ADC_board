################################################################################
# 1. Clock definitions and timing constraints
################################################################################
# ADC source-synchronous clock (375MHz = 2.666ns)
create_clock -period 2.666 -name adc_dclk_p [get_ports adc_dclk_p]

# PCIe reference clock (100MHz = 10.000ns)
create_clock -period 10.000 -name pcie_refclk [get_ports pcie_refclk_p]

# Asynchronous clock groups: include all generated clocks derived from ADC and PCIe roots
set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks adc_dclk_p] \
    -group [get_clocks -include_generated_clocks pcie_refclk]

# CDC false paths: async reset and raw ADC input
set_false_path -through [get_nets -hier -filter {NAME =~ *rst_375_m2*}]
set_false_path -from [get_ports sys_rst_n]
set_false_path -from [get_ports {adc_di_* adc_did_* adc_dq_* adc_dqd_*}]

# False path for adc_ready CDC sync registers (dual-FF synchronizers)
set_false_path -to [get_cells -hier {*adc_ready_s?_reg*}]

# False path for PERST# to XDMA internal reset
set_false_path -to [get_cells -hier rst_125_sync_reg*]

################################################################################
# 2. I/O and hardware configuration
################################################################################
set_property DIFF_TERM_ADV TERM_100 [get_ports {adc_dclk_p {adc_di_p[*]} {adc_did_p[*]} {adc_dq_p[*]} {adc_dqd_p[*]}}]

# 4 banks: set internal VREF
set_property INTERNAL_VREF 0.9 [get_iobanks 66]
set_property INTERNAL_VREF 0.9 [get_iobanks 67]

# Optimize: force IDDR into IOB
set_property IOB TRUE [get_cells -hier -filter {NAME =~ *u_adc_part*gen_lane[*].u_iddr}]
set_property ASYNC_REG true [get_cells -hier -filter {NAME =~ *rst_375_m*_reg*}]

# ==============================================================================
# CDC timing constraints (gearbox replaced with 96->96 XPM FIFO; no extra max_delay needed)
# ==============================================================================

# False path from ADC status to PCIe reset de-assertion
set_false_path -to [get_cells -hier rst_125_sync_reg*]

# Disable specific DRC check
set_property IS_ENABLED 0 [get_drc_checks ADEF-911]

################################################################################
# 3. Pin mapping
################################################################################
# --- Global reset (N26 is dedicated PERSTN0 path) ---
set_property PACKAGE_PIN N26 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]

# --- ADC interface ---
# Bank 66 - I
set_property PACKAGE_PIN G15 [get_ports {adc_di_p[0]}]
set_property PACKAGE_PIN E15 [get_ports {adc_di_p[1]}]
set_property PACKAGE_PIN B15 [get_ports {adc_di_p[2]}]
set_property PACKAGE_PIN H16 [get_ports {adc_di_p[3]}]
set_property PACKAGE_PIN E16 [get_ports {adc_di_p[4]}]
set_property PACKAGE_PIN D16 [get_ports {adc_di_p[5]}]
set_property PACKAGE_PIN C17 [get_ports {adc_di_p[6]}]
set_property PACKAGE_PIN A17 [get_ports {adc_di_p[7]}]


set_property PACKAGE_PIN C18 [get_ports adc_dclk_p]
set_property PACKAGE_PIN H17 [get_ports {adc_did_p[0]}]
set_property PACKAGE_PIN H18 [get_ports {adc_did_p[1]}]
set_property PACKAGE_PIN F18 [get_ports {adc_did_p[2]}]
set_property PACKAGE_PIN G20 [get_ports {adc_did_p[3]}]
set_property PACKAGE_PIN F20 [get_ports {adc_did_p[4]}]
set_property PACKAGE_PIN E21 [get_ports {adc_did_p[5]}]
set_property PACKAGE_PIN A19 [get_ports {adc_did_p[6]}]
set_property PACKAGE_PIN C21 [get_ports {adc_did_p[7]}]

# Bank 67 - Q· + SPI + Ready
set_property PACKAGE_PIN D23 [get_ports adc_cal] 
set_property IOSTANDARD LVCMOS18 [get_ports adc_cal]
set_property PACKAGE_PIN B25 [get_ports adc_ready]
set_property PACKAGE_PIN A13 [get_ports adc_spi_cs_n]
set_property PACKAGE_PIN A14 [get_ports adc_spi_sclk]
set_property PACKAGE_PIN A12 [get_ports adc_spi_sdi]
set_property PACKAGE_PIN B12 [get_ports adc_spi_sdo]
set_property PACKAGE_PIN M20 [get_ports {adc_dq_p[0]}]
set_property PACKAGE_PIN L22 [get_ports {adc_dq_p[1]}]
set_property PACKAGE_PIN L24 [get_ports {adc_dq_p[2]}]
set_property PACKAGE_PIN M25 [get_ports {adc_dq_p[3]}]
set_property PACKAGE_PIN K25 [get_ports {adc_dq_p[4]}]
set_property PACKAGE_PIN J25 [get_ports {adc_dq_p[5]}]
set_property PACKAGE_PIN K21 [get_ports {adc_dq_p[6]}]
set_property PACKAGE_PIN H21 [get_ports {adc_dq_p[7]}]


set_property PACKAGE_PIN H26 [get_ports {adc_dqd_p[0]}]
set_property PACKAGE_PIN F24 [get_ports {adc_dqd_p[1]}]
set_property PACKAGE_PIN E25 [get_ports {adc_dqd_p[2]}]
set_property PACKAGE_PIN D24 [get_ports {adc_dqd_p[3]}]
set_property PACKAGE_PIN D26 [get_ports {adc_dqd_p[4]}]
set_property PACKAGE_PIN M19 [get_ports {adc_dqd_p[5]}]
set_property PACKAGE_PIN L18 [get_ports {adc_dqd_p[6]}]
set_property PACKAGE_PIN J19 [get_ports {adc_dqd_p[7]}]

# IO standard (ADC)
set_property IOSTANDARD LVDS [get_ports {adc_dclk_p {adc_di_p[*]} {adc_did_p[*]} {adc_dq_p[*]} {adc_dqd_p[*]}}]
set_property IOSTANDARD LVCMOS18 [get_ports {sys_rst_n adc_ready adc_spi_*}]

# --- PCIe interface (Bank 227 GTY) ---
# Reference clock (MGTREFCLK0_227 -> V6/V5)
set_property PACKAGE_PIN AB7 [get_ports pcie_refclk_p]
set_property PACKAGE_PIN AB6 [get_ports pcie_refclk_n]

# Link status indicator (Bank 65)
# K21 already used for adc_dq_p[6]; pcie_link_up moved to L21 per schematic
set_property PACKAGE_PIN L21 [get_ports pcie_link_up]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_link_up]

# GTY Lane 0 (RX: AF2, TX: AF7)
set_property PACKAGE_PIN AF2 [get_ports {pcie_rx_p[0]}]
set_property PACKAGE_PIN AF7 [get_ports {pcie_tx_p[0]}]

################################################################################
# 4. Per-Bank IODELAY grouping
################################################################################

# Group 1: Bank 66 (X0Y3) — I-ch(sub[0]) + ID-ch(sub[1]) in one IODELAY_GROUP
set_property IODELAY_GROUP ADC_BANK_66 [get_cells {u_adc_part/gen_sub[0].gen_lane[*].u_dly u_adc_part/gen_sub[1].gen_lane[*].u_dly u_adc_part/u_ctrl_66}]

# Group 2: Bank 67 (X0Y2) — Q-ch(sub[2]) + QD-ch(sub[3]) in one IODELAY_GROUP
set_property IODELAY_GROUP ADC_BANK_67 [get_cells {u_adc_part/gen_sub[2].gen_lane[*].u_dly u_adc_part/gen_sub[3].gen_lane[*].u_dly u_adc_part/u_ctrl_67}]

# Force clock root to X0Y1 (ADC clock region)
#set_property USER_CLOCK_ROOT {X0Y1} [get_nets -of [get_pins u_adc_part/u_clock_gen/inst/clkout1_buf/O]]

# PCIe Hard IP LOC — lock to PCIE4C block for timing closure
set_property LOC PCIE4C_X0Y0 [get_cells -hier -filter {REF_NAME =~ *PCIE4C*}]

################################################################################
# 5. Bitstream configuration
################################################################################
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]
