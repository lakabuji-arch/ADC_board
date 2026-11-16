//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Mon Nov 16 14:04:37 2026
//Host        : wangshihao running 64-bit major release  (build 9200)
//Command     : generate_target ddr4_dma_subsystem_wrapper.bd
//Design      : ddr4_dma_subsystem_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module ddr4_dma_subsystem_wrapper
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
  output C0_DDR4_0_act_n;
  output [16:0]C0_DDR4_0_adr;
  output [1:0]C0_DDR4_0_ba;
  output [0:0]C0_DDR4_0_bg;
  output [0:0]C0_DDR4_0_ck_c;
  output [0:0]C0_DDR4_0_ck_t;
  output [0:0]C0_DDR4_0_cke;
  output [0:0]C0_DDR4_0_cs_n;
  inout [3:0]C0_DDR4_0_dm_n;
  inout [31:0]C0_DDR4_0_dq;
  inout [3:0]C0_DDR4_0_dqs_c;
  inout [3:0]C0_DDR4_0_dqs_t;
  output [0:0]C0_DDR4_0_odt;
  output C0_DDR4_0_reset_n;
  input C0_SYS_CLK_0_clk_n;
  input C0_SYS_CLK_0_clk_p;
  output [511:0]M_AXIS_MM2S_0_tdata;
  output [63:0]M_AXIS_MM2S_0_tkeep;
  output M_AXIS_MM2S_0_tlast;
  input M_AXIS_MM2S_0_tready;
  output M_AXIS_MM2S_0_tvalid;
  output [7:0]M_AXIS_MM2S_STS_0_tdata;
  output [0:0]M_AXIS_MM2S_STS_0_tkeep;
  output M_AXIS_MM2S_STS_0_tlast;
  input M_AXIS_MM2S_STS_0_tready;
  output M_AXIS_MM2S_STS_0_tvalid;
  output [7:0]M_AXIS_S2MM_STS_0_tdata;
  output [0:0]M_AXIS_S2MM_STS_0_tkeep;
  output M_AXIS_S2MM_STS_0_tlast;
  input M_AXIS_S2MM_STS_0_tready;
  output M_AXIS_S2MM_STS_0_tvalid;
  input [71:0]S_AXIS_MM2S_CMD_0_tdata;
  output S_AXIS_MM2S_CMD_0_tready;
  input S_AXIS_MM2S_CMD_0_tvalid;
  input [511:0]S_AXIS_S2MM_0_tdata;
  input [63:0]S_AXIS_S2MM_0_tkeep;
  input S_AXIS_S2MM_0_tlast;
  output S_AXIS_S2MM_0_tready;
  input S_AXIS_S2MM_0_tvalid;
  input [71:0]S_AXIS_S2MM_CMD_0_tdata;
  output S_AXIS_S2MM_CMD_0_tready;
  input S_AXIS_S2MM_CMD_0_tvalid;
  output c0_ddr4_ui_clk;
  output c0_init_calib_complete_0;
  output mm2s_err_0;
  output s2mm_err_0;
  input sys_rst;

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
  wire c0_ddr4_ui_clk;
  wire c0_init_calib_complete_0;
  wire mm2s_err_0;
  wire s2mm_err_0;
  wire sys_rst;

  ddr4_dma_subsystem ddr4_dma_subsystem_i
       (.C0_DDR4_0_act_n(C0_DDR4_0_act_n),
        .C0_DDR4_0_adr(C0_DDR4_0_adr),
        .C0_DDR4_0_ba(C0_DDR4_0_ba),
        .C0_DDR4_0_bg(C0_DDR4_0_bg),
        .C0_DDR4_0_ck_c(C0_DDR4_0_ck_c),
        .C0_DDR4_0_ck_t(C0_DDR4_0_ck_t),
        .C0_DDR4_0_cke(C0_DDR4_0_cke),
        .C0_DDR4_0_cs_n(C0_DDR4_0_cs_n),
        .C0_DDR4_0_dm_n(C0_DDR4_0_dm_n),
        .C0_DDR4_0_dq(C0_DDR4_0_dq),
        .C0_DDR4_0_dqs_c(C0_DDR4_0_dqs_c),
        .C0_DDR4_0_dqs_t(C0_DDR4_0_dqs_t),
        .C0_DDR4_0_odt(C0_DDR4_0_odt),
        .C0_DDR4_0_reset_n(C0_DDR4_0_reset_n),
        .C0_SYS_CLK_0_clk_n(C0_SYS_CLK_0_clk_n),
        .C0_SYS_CLK_0_clk_p(C0_SYS_CLK_0_clk_p),
        .M_AXIS_MM2S_0_tdata(M_AXIS_MM2S_0_tdata),
        .M_AXIS_MM2S_0_tkeep(M_AXIS_MM2S_0_tkeep),
        .M_AXIS_MM2S_0_tlast(M_AXIS_MM2S_0_tlast),
        .M_AXIS_MM2S_0_tready(M_AXIS_MM2S_0_tready),
        .M_AXIS_MM2S_0_tvalid(M_AXIS_MM2S_0_tvalid),
        .M_AXIS_MM2S_STS_0_tdata(M_AXIS_MM2S_STS_0_tdata),
        .M_AXIS_MM2S_STS_0_tkeep(M_AXIS_MM2S_STS_0_tkeep),
        .M_AXIS_MM2S_STS_0_tlast(M_AXIS_MM2S_STS_0_tlast),
        .M_AXIS_MM2S_STS_0_tready(M_AXIS_MM2S_STS_0_tready),
        .M_AXIS_MM2S_STS_0_tvalid(M_AXIS_MM2S_STS_0_tvalid),
        .M_AXIS_S2MM_STS_0_tdata(M_AXIS_S2MM_STS_0_tdata),
        .M_AXIS_S2MM_STS_0_tkeep(M_AXIS_S2MM_STS_0_tkeep),
        .M_AXIS_S2MM_STS_0_tlast(M_AXIS_S2MM_STS_0_tlast),
        .M_AXIS_S2MM_STS_0_tready(M_AXIS_S2MM_STS_0_tready),
        .M_AXIS_S2MM_STS_0_tvalid(M_AXIS_S2MM_STS_0_tvalid),
        .S_AXIS_MM2S_CMD_0_tdata(S_AXIS_MM2S_CMD_0_tdata),
        .S_AXIS_MM2S_CMD_0_tready(S_AXIS_MM2S_CMD_0_tready),
        .S_AXIS_MM2S_CMD_0_tvalid(S_AXIS_MM2S_CMD_0_tvalid),
        .S_AXIS_S2MM_0_tdata(S_AXIS_S2MM_0_tdata),
        .S_AXIS_S2MM_0_tkeep(S_AXIS_S2MM_0_tkeep),
        .S_AXIS_S2MM_0_tlast(S_AXIS_S2MM_0_tlast),
        .S_AXIS_S2MM_0_tready(S_AXIS_S2MM_0_tready),
        .S_AXIS_S2MM_0_tvalid(S_AXIS_S2MM_0_tvalid),
        .S_AXIS_S2MM_CMD_0_tdata(S_AXIS_S2MM_CMD_0_tdata),
        .S_AXIS_S2MM_CMD_0_tready(S_AXIS_S2MM_CMD_0_tready),
        .S_AXIS_S2MM_CMD_0_tvalid(S_AXIS_S2MM_CMD_0_tvalid),
        .c0_ddr4_ui_clk(c0_ddr4_ui_clk),
        .c0_init_calib_complete_0(c0_init_calib_complete_0),
        .mm2s_err_0(mm2s_err_0),
        .s2mm_err_0(s2mm_err_0),
        .sys_rst(sys_rst));
endmodule
