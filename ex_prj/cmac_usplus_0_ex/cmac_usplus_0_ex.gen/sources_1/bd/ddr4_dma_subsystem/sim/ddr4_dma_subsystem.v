//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Mon Nov 16 14:16:23 2026
//Host        : wangshihao running 64-bit major release  (build 9200)
//Command     : generate_target ddr4_dma_subsystem.bd
//Design      : ddr4_dma_subsystem
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "ddr4_dma_subsystem,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=ddr4_dma_subsystem,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=4,numReposBlks=4,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_axi4_cnt=4,da_board_cnt=13,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "ddr4_dma_subsystem.hwdef" *) 
module ddr4_dma_subsystem
   (C0_DDR4_0_act_n,
    C0_DDR4_0_adr,
    C0_DDR4_0_ba,
    C0_DDR4_0_bg,
    C0_DDR4_0_ck_c,
    C0_DDR4_0_ck_t,
    C0_DDR4_0_cke,
    C0_DDR4_0_cs_n,
    C0_DDR4_0_dm_n,
    C0_DDR4_0_dq,
    C0_DDR4_0_dqs_c,
    C0_DDR4_0_dqs_t,
    C0_DDR4_0_odt,
    C0_DDR4_0_reset_n,
    C0_SYS_CLK_0_clk_n,
    C0_SYS_CLK_0_clk_p,
    M_AXIS_MM2S_0_tdata,
    M_AXIS_MM2S_0_tkeep,
    M_AXIS_MM2S_0_tlast,
    M_AXIS_MM2S_0_tready,
    M_AXIS_MM2S_0_tvalid,
    M_AXIS_MM2S_STS_0_tdata,
    M_AXIS_MM2S_STS_0_tkeep,
    M_AXIS_MM2S_STS_0_tlast,
    M_AXIS_MM2S_STS_0_tready,
    M_AXIS_MM2S_STS_0_tvalid,
    M_AXIS_S2MM_STS_0_tdata,
    M_AXIS_S2MM_STS_0_tkeep,
    M_AXIS_S2MM_STS_0_tlast,
    M_AXIS_S2MM_STS_0_tready,
    M_AXIS_S2MM_STS_0_tvalid,
    S_AXIS_MM2S_CMD_0_tdata,
    S_AXIS_MM2S_CMD_0_tready,
    S_AXIS_MM2S_CMD_0_tvalid,
    S_AXIS_S2MM_0_tdata,
    S_AXIS_S2MM_0_tkeep,
    S_AXIS_S2MM_0_tlast,
    S_AXIS_S2MM_0_tready,
    S_AXIS_S2MM_0_tvalid,
    S_AXIS_S2MM_CMD_0_tdata,
    S_AXIS_S2MM_CMD_0_tready,
    S_AXIS_S2MM_CMD_0_tvalid,
    c0_ddr4_ui_clk,
    c0_init_calib_complete_0,
    mm2s_err_0,
    s2mm_err_0,
    sys_rst);
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 ACT_N" *) (* X_INTERFACE_MODE = "Master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME C0_DDR4_0, AXI_ARBITRATION_SCHEME RD_PRI_REG, BURST_LENGTH 8, CAN_DEBUG false, CAS_LATENCY 19, CAS_WRITE_LATENCY 14, CS_ENABLED true, CUSTOM_PARTS no_file_loaded, DATA_MASK_ENABLED DM_NO_DBI, DATA_WIDTH 32, MEMORY_PART MT40A512M16LY-075, MEMORY_TYPE Components, MEM_ADDR_MAP ROW_COLUMN_BANK, SLOT Single, TIMEPERIOD_PS 750" *) output C0_DDR4_0_act_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 ADR" *) output [16:0]C0_DDR4_0_adr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 BA" *) output [1:0]C0_DDR4_0_ba;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 BG" *) output [0:0]C0_DDR4_0_bg;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 CK_C" *) output [0:0]C0_DDR4_0_ck_c;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 CK_T" *) output [0:0]C0_DDR4_0_ck_t;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 CKE" *) output [0:0]C0_DDR4_0_cke;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 CS_N" *) output [0:0]C0_DDR4_0_cs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 DM_N" *) inout [3:0]C0_DDR4_0_dm_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 DQ" *) inout [31:0]C0_DDR4_0_dq;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 DQS_C" *) inout [3:0]C0_DDR4_0_dqs_c;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 DQS_T" *) inout [3:0]C0_DDR4_0_dqs_t;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 ODT" *) output [0:0]C0_DDR4_0_odt;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddr4:1.0 C0_DDR4_0 RESET_N" *) output C0_DDR4_0_reset_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 C0_SYS_CLK_0 CLK_N" *) (* X_INTERFACE_MODE = "Slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME C0_SYS_CLK_0, CAN_DEBUG false, FREQ_HZ 100000000" *) input C0_SYS_CLK_0_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 C0_SYS_CLK_0 CLK_P" *) input C0_SYS_CLK_0_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S_0 TDATA" *) (* X_INTERFACE_MODE = "Master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS_MM2S_0, FREQ_HZ 333250000, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) output [511:0]M_AXIS_MM2S_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S_0 TKEEP" *) output [63:0]M_AXIS_MM2S_0_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S_0 TLAST" *) output M_AXIS_MM2S_0_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S_0 TREADY" *) input M_AXIS_MM2S_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S_0 TVALID" *) output M_AXIS_MM2S_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S_STS_0 TDATA" *) (* X_INTERFACE_MODE = "Master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS_MM2S_STS_0, FREQ_HZ 333250000, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) output [7:0]M_AXIS_MM2S_STS_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S_STS_0 TKEEP" *) output [0:0]M_AXIS_MM2S_STS_0_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S_STS_0 TLAST" *) output M_AXIS_MM2S_STS_0_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S_STS_0 TREADY" *) input M_AXIS_MM2S_STS_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_MM2S_STS_0 TVALID" *) output M_AXIS_MM2S_STS_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_S2MM_STS_0 TDATA" *) (* X_INTERFACE_MODE = "Master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS_S2MM_STS_0, FREQ_HZ 333250000, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) output [7:0]M_AXIS_S2MM_STS_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_S2MM_STS_0 TKEEP" *) output [0:0]M_AXIS_S2MM_STS_0_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_S2MM_STS_0 TLAST" *) output M_AXIS_S2MM_STS_0_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_S2MM_STS_0 TREADY" *) input M_AXIS_S2MM_STS_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_S2MM_STS_0 TVALID" *) output M_AXIS_S2MM_STS_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_MM2S_CMD_0 TDATA" *) (* X_INTERFACE_MODE = "Slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_MM2S_CMD_0, FREQ_HZ 333250000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 9, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [71:0]S_AXIS_MM2S_CMD_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_MM2S_CMD_0 TREADY" *) output S_AXIS_MM2S_CMD_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_MM2S_CMD_0 TVALID" *) input S_AXIS_MM2S_CMD_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM_0 TDATA" *) (* X_INTERFACE_MODE = "Slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_S2MM_0, FREQ_HZ 333250000, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [511:0]S_AXIS_S2MM_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM_0 TKEEP" *) input [63:0]S_AXIS_S2MM_0_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM_0 TLAST" *) input S_AXIS_S2MM_0_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM_0 TREADY" *) output S_AXIS_S2MM_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM_0 TVALID" *) input S_AXIS_S2MM_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM_CMD_0 TDATA" *) (* X_INTERFACE_MODE = "Slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_S2MM_CMD_0, FREQ_HZ 333250000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 9, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [71:0]S_AXIS_S2MM_CMD_0_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM_CMD_0 TREADY" *) output S_AXIS_S2MM_CMD_0_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_S2MM_CMD_0 TVALID" *) input S_AXIS_S2MM_CMD_0_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.C0_DDR4_UI_CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.C0_DDR4_UI_CLK, CLK_DOMAIN ddr4_dma_subsystem_ddr4_0_0_c0_ddr4_ui_clk, FREQ_HZ 333250000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.00" *) output c0_ddr4_ui_clk;
  output c0_init_calib_complete_0;
  output mm2s_err_0;
  output s2mm_err_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.SYS_RST RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.SYS_RST, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) input sys_rst;

  wire C0_DDR4_0_act_n;
  wire [16:0]C0_DDR4_0_adr;
  wire [1:0]C0_DDR4_0_ba;
  wire [0:0]C0_DDR4_0_bg;
  wire [0:0]C0_DDR4_0_ck_c;
  wire [0:0]C0_DDR4_0_ck_t;
  wire [0:0]C0_DDR4_0_cke;
  wire [0:0]C0_DDR4_0_cs_n;
  wire [3:0]C0_DDR4_0_dm_n;
  wire [31:0]C0_DDR4_0_dq;
  wire [3:0]C0_DDR4_0_dqs_c;
  wire [3:0]C0_DDR4_0_dqs_t;
  wire [0:0]C0_DDR4_0_odt;
  wire C0_DDR4_0_reset_n;
  wire C0_SYS_CLK_0_clk_n;
  wire C0_SYS_CLK_0_clk_p;
  wire [511:0]M_AXIS_MM2S_0_tdata;
  wire [63:0]M_AXIS_MM2S_0_tkeep;
  wire M_AXIS_MM2S_0_tlast;
  wire M_AXIS_MM2S_0_tready;
  wire M_AXIS_MM2S_0_tvalid;
  wire [7:0]M_AXIS_MM2S_STS_0_tdata;
  wire [0:0]M_AXIS_MM2S_STS_0_tkeep;
  wire M_AXIS_MM2S_STS_0_tlast;
  wire M_AXIS_MM2S_STS_0_tready;
  wire M_AXIS_MM2S_STS_0_tvalid;
  wire [7:0]M_AXIS_S2MM_STS_0_tdata;
  wire [0:0]M_AXIS_S2MM_STS_0_tkeep;
  wire M_AXIS_S2MM_STS_0_tlast;
  wire M_AXIS_S2MM_STS_0_tready;
  wire M_AXIS_S2MM_STS_0_tvalid;
  wire [71:0]S_AXIS_MM2S_CMD_0_tdata;
  wire S_AXIS_MM2S_CMD_0_tready;
  wire S_AXIS_MM2S_CMD_0_tvalid;
  wire [511:0]S_AXIS_S2MM_0_tdata;
  wire [63:0]S_AXIS_S2MM_0_tkeep;
  wire S_AXIS_S2MM_0_tlast;
  wire S_AXIS_S2MM_0_tready;
  wire S_AXIS_S2MM_0_tvalid;
  wire [71:0]S_AXIS_S2MM_CMD_0_tdata;
  wire S_AXIS_S2MM_CMD_0_tready;
  wire S_AXIS_S2MM_CMD_0_tvalid;
  wire [31:0]axi_datamover_0_M_AXI_MM2S_ARADDR;
  wire [1:0]axi_datamover_0_M_AXI_MM2S_ARBURST;
  wire [3:0]axi_datamover_0_M_AXI_MM2S_ARCACHE;
  wire [3:0]axi_datamover_0_M_AXI_MM2S_ARID;
  wire [7:0]axi_datamover_0_M_AXI_MM2S_ARLEN;
  wire [2:0]axi_datamover_0_M_AXI_MM2S_ARPROT;
  wire axi_datamover_0_M_AXI_MM2S_ARREADY;
  wire [2:0]axi_datamover_0_M_AXI_MM2S_ARSIZE;
  wire [3:0]axi_datamover_0_M_AXI_MM2S_ARUSER;
  wire axi_datamover_0_M_AXI_MM2S_ARVALID;
  wire [511:0]axi_datamover_0_M_AXI_MM2S_RDATA;
  wire axi_datamover_0_M_AXI_MM2S_RLAST;
  wire axi_datamover_0_M_AXI_MM2S_RREADY;
  wire [1:0]axi_datamover_0_M_AXI_MM2S_RRESP;
  wire axi_datamover_0_M_AXI_MM2S_RVALID;
  wire [31:0]axi_datamover_0_M_AXI_S2MM_AWADDR;
  wire [1:0]axi_datamover_0_M_AXI_S2MM_AWBURST;
  wire [3:0]axi_datamover_0_M_AXI_S2MM_AWCACHE;
  wire [3:0]axi_datamover_0_M_AXI_S2MM_AWID;
  wire [7:0]axi_datamover_0_M_AXI_S2MM_AWLEN;
  wire [2:0]axi_datamover_0_M_AXI_S2MM_AWPROT;
  wire axi_datamover_0_M_AXI_S2MM_AWREADY;
  wire [2:0]axi_datamover_0_M_AXI_S2MM_AWSIZE;
  wire [3:0]axi_datamover_0_M_AXI_S2MM_AWUSER;
  wire axi_datamover_0_M_AXI_S2MM_AWVALID;
  wire axi_datamover_0_M_AXI_S2MM_BREADY;
  wire [1:0]axi_datamover_0_M_AXI_S2MM_BRESP;
  wire axi_datamover_0_M_AXI_S2MM_BVALID;
  wire [511:0]axi_datamover_0_M_AXI_S2MM_WDATA;
  wire axi_datamover_0_M_AXI_S2MM_WLAST;
  wire axi_datamover_0_M_AXI_S2MM_WREADY;
  wire [63:0]axi_datamover_0_M_AXI_S2MM_WSTRB;
  wire axi_datamover_0_M_AXI_S2MM_WVALID;
  wire c0_ddr4_ui_clk;
  wire c0_init_calib_complete_0;
  wire ddr4_0_c0_ddr4_ui_clk_sync_rst;
  wire mm2s_err_0;
  wire [0:0]proc_sys_reset_0_interconnect_aresetn;
  wire [0:0]proc_sys_reset_0_peripheral_aresetn;
  wire s2mm_err_0;
  wire [30:0]smartconnect_0_M00_AXI_ARADDR;
  wire [1:0]smartconnect_0_M00_AXI_ARBURST;
  wire [3:0]smartconnect_0_M00_AXI_ARCACHE;
  wire [7:0]smartconnect_0_M00_AXI_ARLEN;
  wire [0:0]smartconnect_0_M00_AXI_ARLOCK;
  wire [2:0]smartconnect_0_M00_AXI_ARPROT;
  wire [3:0]smartconnect_0_M00_AXI_ARQOS;
  wire smartconnect_0_M00_AXI_ARREADY;
  wire [2:0]smartconnect_0_M00_AXI_ARSIZE;
  wire smartconnect_0_M00_AXI_ARVALID;
  wire [30:0]smartconnect_0_M00_AXI_AWADDR;
  wire [1:0]smartconnect_0_M00_AXI_AWBURST;
  wire [3:0]smartconnect_0_M00_AXI_AWCACHE;
  wire [7:0]smartconnect_0_M00_AXI_AWLEN;
  wire [0:0]smartconnect_0_M00_AXI_AWLOCK;
  wire [2:0]smartconnect_0_M00_AXI_AWPROT;
  wire [3:0]smartconnect_0_M00_AXI_AWQOS;
  wire smartconnect_0_M00_AXI_AWREADY;
  wire [2:0]smartconnect_0_M00_AXI_AWSIZE;
  wire smartconnect_0_M00_AXI_AWVALID;
  wire smartconnect_0_M00_AXI_BREADY;
  wire [1:0]smartconnect_0_M00_AXI_BRESP;
  wire smartconnect_0_M00_AXI_BVALID;
  wire [255:0]smartconnect_0_M00_AXI_RDATA;
  wire smartconnect_0_M00_AXI_RLAST;
  wire smartconnect_0_M00_AXI_RREADY;
  wire [1:0]smartconnect_0_M00_AXI_RRESP;
  wire smartconnect_0_M00_AXI_RVALID;
  wire [255:0]smartconnect_0_M00_AXI_WDATA;
  wire smartconnect_0_M00_AXI_WLAST;
  wire smartconnect_0_M00_AXI_WREADY;
  wire [31:0]smartconnect_0_M00_AXI_WSTRB;
  wire smartconnect_0_M00_AXI_WVALID;
  wire sys_rst;

  ddr4_dma_subsystem_axi_datamover_0_0 axi_datamover_0
       (.m_axi_mm2s_aclk(c0_ddr4_ui_clk),
        .m_axi_mm2s_araddr(axi_datamover_0_M_AXI_MM2S_ARADDR),
        .m_axi_mm2s_arburst(axi_datamover_0_M_AXI_MM2S_ARBURST),
        .m_axi_mm2s_arcache(axi_datamover_0_M_AXI_MM2S_ARCACHE),
        .m_axi_mm2s_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .m_axi_mm2s_arid(axi_datamover_0_M_AXI_MM2S_ARID),
        .m_axi_mm2s_arlen(axi_datamover_0_M_AXI_MM2S_ARLEN),
        .m_axi_mm2s_arprot(axi_datamover_0_M_AXI_MM2S_ARPROT),
        .m_axi_mm2s_arready(axi_datamover_0_M_AXI_MM2S_ARREADY),
        .m_axi_mm2s_arsize(axi_datamover_0_M_AXI_MM2S_ARSIZE),
        .m_axi_mm2s_aruser(axi_datamover_0_M_AXI_MM2S_ARUSER),
        .m_axi_mm2s_arvalid(axi_datamover_0_M_AXI_MM2S_ARVALID),
        .m_axi_mm2s_rdata(axi_datamover_0_M_AXI_MM2S_RDATA),
        .m_axi_mm2s_rlast(axi_datamover_0_M_AXI_MM2S_RLAST),
        .m_axi_mm2s_rready(axi_datamover_0_M_AXI_MM2S_RREADY),
        .m_axi_mm2s_rresp(axi_datamover_0_M_AXI_MM2S_RRESP),
        .m_axi_mm2s_rvalid(axi_datamover_0_M_AXI_MM2S_RVALID),
        .m_axi_s2mm_aclk(c0_ddr4_ui_clk),
        .m_axi_s2mm_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .m_axi_s2mm_awaddr(axi_datamover_0_M_AXI_S2MM_AWADDR),
        .m_axi_s2mm_awburst(axi_datamover_0_M_AXI_S2MM_AWBURST),
        .m_axi_s2mm_awcache(axi_datamover_0_M_AXI_S2MM_AWCACHE),
        .m_axi_s2mm_awid(axi_datamover_0_M_AXI_S2MM_AWID),
        .m_axi_s2mm_awlen(axi_datamover_0_M_AXI_S2MM_AWLEN),
        .m_axi_s2mm_awprot(axi_datamover_0_M_AXI_S2MM_AWPROT),
        .m_axi_s2mm_awready(axi_datamover_0_M_AXI_S2MM_AWREADY),
        .m_axi_s2mm_awsize(axi_datamover_0_M_AXI_S2MM_AWSIZE),
        .m_axi_s2mm_awuser(axi_datamover_0_M_AXI_S2MM_AWUSER),
        .m_axi_s2mm_awvalid(axi_datamover_0_M_AXI_S2MM_AWVALID),
        .m_axi_s2mm_bready(axi_datamover_0_M_AXI_S2MM_BREADY),
        .m_axi_s2mm_bresp(axi_datamover_0_M_AXI_S2MM_BRESP),
        .m_axi_s2mm_bvalid(axi_datamover_0_M_AXI_S2MM_BVALID),
        .m_axi_s2mm_wdata(axi_datamover_0_M_AXI_S2MM_WDATA),
        .m_axi_s2mm_wlast(axi_datamover_0_M_AXI_S2MM_WLAST),
        .m_axi_s2mm_wready(axi_datamover_0_M_AXI_S2MM_WREADY),
        .m_axi_s2mm_wstrb(axi_datamover_0_M_AXI_S2MM_WSTRB),
        .m_axi_s2mm_wvalid(axi_datamover_0_M_AXI_S2MM_WVALID),
        .m_axis_mm2s_cmdsts_aclk(c0_ddr4_ui_clk),
        .m_axis_mm2s_cmdsts_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .m_axis_mm2s_sts_tdata(M_AXIS_MM2S_STS_0_tdata),
        .m_axis_mm2s_sts_tkeep(M_AXIS_MM2S_STS_0_tkeep),
        .m_axis_mm2s_sts_tlast(M_AXIS_MM2S_STS_0_tlast),
        .m_axis_mm2s_sts_tready(M_AXIS_MM2S_STS_0_tready),
        .m_axis_mm2s_sts_tvalid(M_AXIS_MM2S_STS_0_tvalid),
        .m_axis_mm2s_tdata(M_AXIS_MM2S_0_tdata),
        .m_axis_mm2s_tkeep(M_AXIS_MM2S_0_tkeep),
        .m_axis_mm2s_tlast(M_AXIS_MM2S_0_tlast),
        .m_axis_mm2s_tready(M_AXIS_MM2S_0_tready),
        .m_axis_mm2s_tvalid(M_AXIS_MM2S_0_tvalid),
        .m_axis_s2mm_cmdsts_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .m_axis_s2mm_cmdsts_awclk(c0_ddr4_ui_clk),
        .m_axis_s2mm_sts_tdata(M_AXIS_S2MM_STS_0_tdata),
        .m_axis_s2mm_sts_tkeep(M_AXIS_S2MM_STS_0_tkeep),
        .m_axis_s2mm_sts_tlast(M_AXIS_S2MM_STS_0_tlast),
        .m_axis_s2mm_sts_tready(M_AXIS_S2MM_STS_0_tready),
        .m_axis_s2mm_sts_tvalid(M_AXIS_S2MM_STS_0_tvalid),
        .mm2s_err(mm2s_err_0),
        .s2mm_err(s2mm_err_0),
        .s_axis_mm2s_cmd_tdata(S_AXIS_MM2S_CMD_0_tdata),
        .s_axis_mm2s_cmd_tready(S_AXIS_MM2S_CMD_0_tready),
        .s_axis_mm2s_cmd_tvalid(S_AXIS_MM2S_CMD_0_tvalid),
        .s_axis_s2mm_cmd_tdata(S_AXIS_S2MM_CMD_0_tdata),
        .s_axis_s2mm_cmd_tready(S_AXIS_S2MM_CMD_0_tready),
        .s_axis_s2mm_cmd_tvalid(S_AXIS_S2MM_CMD_0_tvalid),
        .s_axis_s2mm_tdata(S_AXIS_S2MM_0_tdata),
        .s_axis_s2mm_tkeep(S_AXIS_S2MM_0_tkeep),
        .s_axis_s2mm_tlast(S_AXIS_S2MM_0_tlast),
        .s_axis_s2mm_tready(S_AXIS_S2MM_0_tready),
        .s_axis_s2mm_tvalid(S_AXIS_S2MM_0_tvalid));
  ddr4_dma_subsystem_ddr4_0_0 ddr4_0
       (.c0_ddr4_act_n(C0_DDR4_0_act_n),
        .c0_ddr4_adr(C0_DDR4_0_adr),
        .c0_ddr4_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .c0_ddr4_ba(C0_DDR4_0_ba),
        .c0_ddr4_bg(C0_DDR4_0_bg),
        .c0_ddr4_ck_c(C0_DDR4_0_ck_c),
        .c0_ddr4_ck_t(C0_DDR4_0_ck_t),
        .c0_ddr4_cke(C0_DDR4_0_cke),
        .c0_ddr4_cs_n(C0_DDR4_0_cs_n),
        .c0_ddr4_dm_dbi_n(C0_DDR4_0_dm_n),
        .c0_ddr4_dq(C0_DDR4_0_dq),
        .c0_ddr4_dqs_c(C0_DDR4_0_dqs_c),
        .c0_ddr4_dqs_t(C0_DDR4_0_dqs_t),
        .c0_ddr4_odt(C0_DDR4_0_odt),
        .c0_ddr4_reset_n(C0_DDR4_0_reset_n),
        .c0_ddr4_s_axi_araddr(smartconnect_0_M00_AXI_ARADDR),
        .c0_ddr4_s_axi_arburst(smartconnect_0_M00_AXI_ARBURST),
        .c0_ddr4_s_axi_arcache(smartconnect_0_M00_AXI_ARCACHE),
        .c0_ddr4_s_axi_arid(1'b0),
        .c0_ddr4_s_axi_arlen(smartconnect_0_M00_AXI_ARLEN),
        .c0_ddr4_s_axi_arlock(smartconnect_0_M00_AXI_ARLOCK),
        .c0_ddr4_s_axi_arprot(smartconnect_0_M00_AXI_ARPROT),
        .c0_ddr4_s_axi_arqos(smartconnect_0_M00_AXI_ARQOS),
        .c0_ddr4_s_axi_arready(smartconnect_0_M00_AXI_ARREADY),
        .c0_ddr4_s_axi_arsize(smartconnect_0_M00_AXI_ARSIZE),
        .c0_ddr4_s_axi_arvalid(smartconnect_0_M00_AXI_ARVALID),
        .c0_ddr4_s_axi_awaddr(smartconnect_0_M00_AXI_AWADDR),
        .c0_ddr4_s_axi_awburst(smartconnect_0_M00_AXI_AWBURST),
        .c0_ddr4_s_axi_awcache(smartconnect_0_M00_AXI_AWCACHE),
        .c0_ddr4_s_axi_awid(1'b0),
        .c0_ddr4_s_axi_awlen(smartconnect_0_M00_AXI_AWLEN),
        .c0_ddr4_s_axi_awlock(smartconnect_0_M00_AXI_AWLOCK),
        .c0_ddr4_s_axi_awprot(smartconnect_0_M00_AXI_AWPROT),
        .c0_ddr4_s_axi_awqos(smartconnect_0_M00_AXI_AWQOS),
        .c0_ddr4_s_axi_awready(smartconnect_0_M00_AXI_AWREADY),
        .c0_ddr4_s_axi_awsize(smartconnect_0_M00_AXI_AWSIZE),
        .c0_ddr4_s_axi_awvalid(smartconnect_0_M00_AXI_AWVALID),
        .c0_ddr4_s_axi_bready(smartconnect_0_M00_AXI_BREADY),
        .c0_ddr4_s_axi_bresp(smartconnect_0_M00_AXI_BRESP),
        .c0_ddr4_s_axi_bvalid(smartconnect_0_M00_AXI_BVALID),
        .c0_ddr4_s_axi_rdata(smartconnect_0_M00_AXI_RDATA),
        .c0_ddr4_s_axi_rlast(smartconnect_0_M00_AXI_RLAST),
        .c0_ddr4_s_axi_rready(smartconnect_0_M00_AXI_RREADY),
        .c0_ddr4_s_axi_rresp(smartconnect_0_M00_AXI_RRESP),
        .c0_ddr4_s_axi_rvalid(smartconnect_0_M00_AXI_RVALID),
        .c0_ddr4_s_axi_wdata(smartconnect_0_M00_AXI_WDATA),
        .c0_ddr4_s_axi_wlast(smartconnect_0_M00_AXI_WLAST),
        .c0_ddr4_s_axi_wready(smartconnect_0_M00_AXI_WREADY),
        .c0_ddr4_s_axi_wstrb(smartconnect_0_M00_AXI_WSTRB),
        .c0_ddr4_s_axi_wvalid(smartconnect_0_M00_AXI_WVALID),
        .c0_ddr4_ui_clk(c0_ddr4_ui_clk),
        .c0_ddr4_ui_clk_sync_rst(ddr4_0_c0_ddr4_ui_clk_sync_rst),
        .c0_init_calib_complete(c0_init_calib_complete_0),
        .c0_sys_clk_n(C0_SYS_CLK_0_clk_n),
        .c0_sys_clk_p(C0_SYS_CLK_0_clk_p),
        .sys_rst(sys_rst));
  ddr4_dma_subsystem_proc_sys_reset_0_0 proc_sys_reset_0
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(ddr4_0_c0_ddr4_ui_clk_sync_rst),
        .interconnect_aresetn(proc_sys_reset_0_interconnect_aresetn),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .slowest_sync_clk(c0_ddr4_ui_clk));
  ddr4_dma_subsystem_smartconnect_0_0 smartconnect_0
       (.M00_AXI_araddr(smartconnect_0_M00_AXI_ARADDR),
        .M00_AXI_arburst(smartconnect_0_M00_AXI_ARBURST),
        .M00_AXI_arcache(smartconnect_0_M00_AXI_ARCACHE),
        .M00_AXI_arlen(smartconnect_0_M00_AXI_ARLEN),
        .M00_AXI_arlock(smartconnect_0_M00_AXI_ARLOCK),
        .M00_AXI_arprot(smartconnect_0_M00_AXI_ARPROT),
        .M00_AXI_arqos(smartconnect_0_M00_AXI_ARQOS),
        .M00_AXI_arready(smartconnect_0_M00_AXI_ARREADY),
        .M00_AXI_arsize(smartconnect_0_M00_AXI_ARSIZE),
        .M00_AXI_arvalid(smartconnect_0_M00_AXI_ARVALID),
        .M00_AXI_awaddr(smartconnect_0_M00_AXI_AWADDR),
        .M00_AXI_awburst(smartconnect_0_M00_AXI_AWBURST),
        .M00_AXI_awcache(smartconnect_0_M00_AXI_AWCACHE),
        .M00_AXI_awlen(smartconnect_0_M00_AXI_AWLEN),
        .M00_AXI_awlock(smartconnect_0_M00_AXI_AWLOCK),
        .M00_AXI_awprot(smartconnect_0_M00_AXI_AWPROT),
        .M00_AXI_awqos(smartconnect_0_M00_AXI_AWQOS),
        .M00_AXI_awready(smartconnect_0_M00_AXI_AWREADY),
        .M00_AXI_awsize(smartconnect_0_M00_AXI_AWSIZE),
        .M00_AXI_awvalid(smartconnect_0_M00_AXI_AWVALID),
        .M00_AXI_bready(smartconnect_0_M00_AXI_BREADY),
        .M00_AXI_bresp(smartconnect_0_M00_AXI_BRESP),
        .M00_AXI_bvalid(smartconnect_0_M00_AXI_BVALID),
        .M00_AXI_rdata(smartconnect_0_M00_AXI_RDATA),
        .M00_AXI_rlast(smartconnect_0_M00_AXI_RLAST),
        .M00_AXI_rready(smartconnect_0_M00_AXI_RREADY),
        .M00_AXI_rresp(smartconnect_0_M00_AXI_RRESP),
        .M00_AXI_rvalid(smartconnect_0_M00_AXI_RVALID),
        .M00_AXI_wdata(smartconnect_0_M00_AXI_WDATA),
        .M00_AXI_wlast(smartconnect_0_M00_AXI_WLAST),
        .M00_AXI_wready(smartconnect_0_M00_AXI_WREADY),
        .M00_AXI_wstrb(smartconnect_0_M00_AXI_WSTRB),
        .M00_AXI_wvalid(smartconnect_0_M00_AXI_WVALID),
        .S00_AXI_awaddr(axi_datamover_0_M_AXI_S2MM_AWADDR),
        .S00_AXI_awburst(axi_datamover_0_M_AXI_S2MM_AWBURST),
        .S00_AXI_awcache(axi_datamover_0_M_AXI_S2MM_AWCACHE),
        .S00_AXI_awid(axi_datamover_0_M_AXI_S2MM_AWID),
        .S00_AXI_awlen(axi_datamover_0_M_AXI_S2MM_AWLEN),
        .S00_AXI_awlock(1'b0),
        .S00_AXI_awprot(axi_datamover_0_M_AXI_S2MM_AWPROT),
        .S00_AXI_awqos({1'b0,1'b0,1'b0,1'b0}),
        .S00_AXI_awready(axi_datamover_0_M_AXI_S2MM_AWREADY),
        .S00_AXI_awsize(axi_datamover_0_M_AXI_S2MM_AWSIZE),
        .S00_AXI_awuser(axi_datamover_0_M_AXI_S2MM_AWUSER),
        .S00_AXI_awvalid(axi_datamover_0_M_AXI_S2MM_AWVALID),
        .S00_AXI_bready(axi_datamover_0_M_AXI_S2MM_BREADY),
        .S00_AXI_bresp(axi_datamover_0_M_AXI_S2MM_BRESP),
        .S00_AXI_bvalid(axi_datamover_0_M_AXI_S2MM_BVALID),
        .S00_AXI_wdata(axi_datamover_0_M_AXI_S2MM_WDATA),
        .S00_AXI_wlast(axi_datamover_0_M_AXI_S2MM_WLAST),
        .S00_AXI_wready(axi_datamover_0_M_AXI_S2MM_WREADY),
        .S00_AXI_wstrb(axi_datamover_0_M_AXI_S2MM_WSTRB),
        .S00_AXI_wvalid(axi_datamover_0_M_AXI_S2MM_WVALID),
        .S01_AXI_araddr(axi_datamover_0_M_AXI_MM2S_ARADDR),
        .S01_AXI_arburst(axi_datamover_0_M_AXI_MM2S_ARBURST),
        .S01_AXI_arcache(axi_datamover_0_M_AXI_MM2S_ARCACHE),
        .S01_AXI_arid(axi_datamover_0_M_AXI_MM2S_ARID),
        .S01_AXI_arlen(axi_datamover_0_M_AXI_MM2S_ARLEN),
        .S01_AXI_arlock(1'b0),
        .S01_AXI_arprot(axi_datamover_0_M_AXI_MM2S_ARPROT),
        .S01_AXI_arqos({1'b0,1'b0,1'b0,1'b0}),
        .S01_AXI_arready(axi_datamover_0_M_AXI_MM2S_ARREADY),
        .S01_AXI_arsize(axi_datamover_0_M_AXI_MM2S_ARSIZE),
        .S01_AXI_aruser(axi_datamover_0_M_AXI_MM2S_ARUSER),
        .S01_AXI_arvalid(axi_datamover_0_M_AXI_MM2S_ARVALID),
        .S01_AXI_rdata(axi_datamover_0_M_AXI_MM2S_RDATA),
        .S01_AXI_rlast(axi_datamover_0_M_AXI_MM2S_RLAST),
        .S01_AXI_rready(axi_datamover_0_M_AXI_MM2S_RREADY),
        .S01_AXI_rresp(axi_datamover_0_M_AXI_MM2S_RRESP),
        .S01_AXI_rvalid(axi_datamover_0_M_AXI_MM2S_RVALID),
        .aclk(c0_ddr4_ui_clk),
        .aresetn(proc_sys_reset_0_interconnect_aresetn));
endmodule
