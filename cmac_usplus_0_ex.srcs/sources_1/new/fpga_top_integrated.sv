`timescale 1ns / 1ps

// ============================================================================
// fpga_top_integrated — ADC采集 + DDR4环形缓冲 + CMAC 100G/PCIe双通路读出
//
// 数据流:
//   ADC (375M DDR) → Gearbox (96b×2@125M) → Packer (512b@125M)
//     → CDC FIFO (125→322M) → S_AXIS_RX → DDR4 (S2MM)
//     → DataMover MM2S → M_AXIS_TX (512b@322M) → Demux
//       → CMAC TX (主通路, 100G ETH 实时发送)
//       → XDMA C2H (备份通路, PCIe Gen2×1 慢速排空)
//
// CMAC RX 仅用于 UDP 控制命令和 ARP/ICMP 协议栈。
// ============================================================================

module fpga_top_integrated #(
    parameter [31:0] DDR4_BUF_BASE = 32'h1000_0000,
    parameter integer DDR4_BUF_MB  = 512
)(
    // ==================== 系统 ====================
    input  wire         clk_50m_in,
    input  wire         sys_rst_pad_in,      // 高有效复位 (PERST#/按钮)

    // ==================== CMAC 100G GT ====================
    input  wire         gt_ref_clk_p,
    input  wire         gt_ref_clk_n,
    input  wire [3:0]   gt_rxp_in,
    input  wire [3:0]   gt_rxn_in,
    output wire [3:0]   gt_txp_out,
    output wire [3:0]   gt_txn_out,

    // ==================== DDR4 ====================
    output wire         ddr4_act_n,
    output wire [16:0]  ddr4_adr,
    output wire [1:0]   ddr4_ba,
    output wire [0:0]   ddr4_bg,
    output wire [0:0]   ddr4_ck_c,
    output wire [0:0]   ddr4_ck_t,
    output wire [0:0]   ddr4_cke,
    output wire [0:0]   ddr4_cs_n,
    inout  wire [3:0]   ddr4_dm_n,
    inout  wire [31:0]  ddr4_dq,
    inout  wire [3:0]   ddr4_dqs_c,
    inout  wire [3:0]   ddr4_dqs_t,
    output wire [0:0]   ddr4_odt,
    output wire         ddr4_reset_n,
    input  wire         ddr4_ref_clk_p,
    input  wire         ddr4_ref_clk_n,

    // ==================== ADC ====================
    input  wire         adc_dclk_p,
    input  wire         adc_dclk_n,
    output wire         adc_spi_cs_n,
    output wire         adc_spi_sclk,
    output wire         adc_spi_sdi,
    input  wire         adc_spi_sdo,
    output wire         adc_cal,
    input  wire [7:0]   adc_di_p,   adc_di_n,
    input  wire [7:0]   adc_did_p,  adc_did_n,
    input  wire [7:0]   adc_dq_p,   adc_dq_n,
    input  wire [7:0]   adc_dqd_p,  adc_dqd_n,

    // ==================== PCIe ====================
    input  wire         pcie_refclk_p,
    input  wire         pcie_refclk_n,
    input  wire [0:0]   pcie_rx_p,
    input  wire [0:0]   pcie_rx_n,
    output wire [0:0]   pcie_tx_p,
    output wire [0:0]   pcie_tx_n,

    // ==================== 状态 ====================
    output wire         adc_ready_out,
    output wire         pcie_link_up,
    output wire         ddr4_calib_done,
    output wire [3:0]   led_out
);

    // =========================================================================
    // 0. 时钟 & 复位定义
    // =========================================================================
    wire        clk_100m, clk_100m_locked;
    wire        usr_mac_clk, usr_mac_rst_n, mac_link_up;
    wire        c0_ddr4_ui_clk;
    wire        ddr4_calib_complete;
    wire        dm_rst_n;       // DDR4 DataMover 域复位 (等 calib+locked+delayed)
    wire        clk_adc_125;
    wire        adc_rst_n;
    wire        clk_pcie_125;
    wire        pcie_rst_n;

    // =========================================================================
    // 1. clk_wiz_0: 50MHz → 100MHz (CMAC init_clk)
    // =========================================================================
    clk_wiz_0 u_clk_wiz (
        .clk_out1 (clk_100m),
        .clk_out2 (),
        .reset    (sys_rst_pad_in),
        .locked   (clk_100m_locked),
        .clk_in1  (clk_50m_in)
    );

    // =========================================================================
    // 2. CMAC 100G 子系统
    // =========================================================================
    wire [511:0] cmac_rx_tdata;
    wire [63:0]  cmac_rx_tkeep;
    wire         cmac_rx_tvalid, cmac_rx_tlast, cmac_rx_tready;
    wire         rx_payload_cmd_valid_322m;
    wire [15:0]  rx_payload_bytes_322m;

    wire [511:0] cmac_tx_tdata;
    wire [63:0]  cmac_tx_tkeep;
    wire         cmac_tx_tvalid, cmac_tx_tlast, cmac_tx_tready;
    wire         tx_meta_empty_322m;
    wire [15:0]  tx_meta_len_322m;
    wire         tx_meta_rd_en;

    wire        ctrl_start_rec, ctrl_stop_rec, ctrl_start_play, ctrl_stop_play;
    wire        ctrl_soft_reset;
    wire [31:0] ctrl_base_addr;  // exposed for testbench force-override (Phase 4 BASE_ADDR)

    // 状态回传 (CDC 333→322 后送给 cmac_wrapper)
    wire [15:0] stat_s2mm_cmd_cnt_322, stat_mm2s_cmd_cnt_322;
    wire [11:0] stat_rx_wr_count_322,  stat_tx_wr_count_322;
    wire        stat_s2mm_err_322,     stat_mm2s_err_322;

    cmac_100g_wrapper u_cmac (
        .gt_ref_clk_p        (gt_ref_clk_p),
        .gt_ref_clk_n        (gt_ref_clk_n),
        .gt_rxp_in           (gt_rxp_in),
        .gt_rxn_in           (gt_rxn_in),
        .gt_txp_out          (gt_txp_out),
        .gt_txn_out          (gt_txn_out),
        .init_clk            (clk_100m),
        .sys_reset           (sys_rst_pad_in),
        .usr_mac_clk         (usr_mac_clk),
        .usr_mac_rst_n       (usr_mac_rst_n),
        .mac_link_up         (mac_link_up),

        // RX — 控制包经过内部 UDP parser, 数据包不进 DDR4
        .m_axis_rx_tdata     (cmac_rx_tdata),
        .m_axis_rx_tkeep     (cmac_rx_tkeep),
        .m_axis_rx_tvalid    (cmac_rx_tvalid),
        .m_axis_rx_tlast     (cmac_rx_tlast),
        .m_axis_rx_tready    (cmac_rx_tready),
        .o_payload_cmd_valid (rx_payload_cmd_valid_322m),
        .o_payload_bytes     (rx_payload_bytes_322m),

        // TX — 数据来自 DDR4 读出
        .s_axis_tx_tdata     (cmac_tx_tdata),
        .s_axis_tx_tkeep     (cmac_tx_tkeep),
        .s_axis_tx_tvalid    (cmac_tx_tvalid),
        .s_axis_tx_tlast     (cmac_tx_tlast),
        .s_axis_tx_tuser     (16'd0),
        .s_axis_tx_tready    (cmac_tx_tready),
        .i_tx_payload_bytes  (tx_meta_len_322m),
        .tx_meta_empty       (tx_meta_empty_322m),
        .o_tx_meta_rd_en     (tx_meta_rd_en),
        .tx_pause_req        (9'd0),

        // 控制 (UDP 命令解析输出 → CDC 到 DDR4 域)
        .ctrl_start_rec      (ctrl_start_rec),
        .ctrl_stop_rec       (ctrl_stop_rec),
        .ctrl_start_play     (ctrl_start_play),
        .ctrl_stop_play      (ctrl_stop_play),
        .ctrl_base_addr      (ctrl_base_addr),
        .ctrl_soft_reset     (ctrl_soft_reset),

        // 状态 (CDC 333→322 后回传给 CMAC)
        .stat_s2mm_cmd_cnt   (stat_s2mm_cmd_cnt_322),
        .stat_mm2s_cmd_cnt   (stat_mm2s_cmd_cnt_322),
        .stat_rx_wr_count    (stat_rx_wr_count_322),
        .stat_tx_wr_count    (stat_tx_wr_count_322),
        .stat_s2mm_err       (stat_s2mm_err_322),
        .stat_mm2s_err       (stat_mm2s_err_322),

        // AXI-Lite 从接口 (JTAG→AXI 或 XDMA Master, 用于寄存器访问)
        .s_udp_cfg_axi_awaddr  (32'd0),
        .s_udp_cfg_axi_awvalid (1'b0),
        .s_udp_cfg_axi_awready (),
        .s_udp_cfg_axi_wdata   (32'd0),
        .s_udp_cfg_axi_wstrb   (4'd0),
        .s_udp_cfg_axi_wvalid  (1'b0),
        .s_udp_cfg_axi_wready  (),
        .s_udp_cfg_axi_bresp   (),
        .s_udp_cfg_axi_bvalid  (),
        .s_udp_cfg_axi_bready  (1'b0),
        .s_udp_cfg_axi_araddr  (32'd0),
        .s_udp_cfg_axi_arvalid (1'b0),
        .s_udp_cfg_axi_arready (),
        .s_udp_cfg_axi_rdata   (),
        .s_udp_cfg_axi_rresp   (),
        .s_udp_cfg_axi_rvalid  (),
        .s_udp_cfg_axi_rready  (1'b0)
    );

    // CMAC RX 数据不写 DDR4，始终 ready 以免阻塞协议栈
    assign cmac_rx_tready = 1'b1;

    // =========================================================================
    // 3. ADC 采集子系统 (clk_adc_125 域)
    // =========================================================================
    wire [95:0]  adc_data_i, adc_data_q;
    wire         adc_vld_i, adc_vld_q;
    wire         adc_ready;

    adc_top u_adc (
        .sys_rst_n          (~sys_rst_pad_in),
        .adc_dclk_p         (adc_dclk_p),
        .adc_dclk_n         (adc_dclk_n),
        .adc_spi_cs_n       (adc_spi_cs_n),
        .adc_spi_sclk       (adc_spi_sclk),
        .adc_spi_sdi        (adc_spi_sdi),
        .adc_spi_sdo        (adc_spi_sdo),
        .adc_cal            (adc_cal),
        .adc_di_p           (adc_di_p),
        .adc_di_n           (adc_di_n),
        .adc_did_p          (adc_did_p),
        .adc_did_n          (adc_did_n),
        .adc_dq_p           (adc_dq_p),
        .adc_dq_n           (adc_dq_n),
        .adc_dqd_p          (adc_dqd_p),
        .adc_dqd_n          (adc_dqd_n),
        .adc_ready          (adc_ready),
        .adc_clk_125m_out   (clk_adc_125),
        .adc_data_i_out     (adc_data_i),
        .adc_data_q_out     (adc_data_q),
        .adc_vld_i_out      (adc_vld_i),
        .adc_vld_q_out      (adc_vld_q),
        .bp_ready_i         (!adc_fifo_prog_full && !adc_fifo_full),  // 下游缓冲满时暂停 ADC
        .bp_ready_q         (!adc_fifo_prog_full && !adc_fifo_full)
    );

    assign adc_rst_n  = adc_ready;
    assign adc_ready_out = adc_ready;

    // Synchronize usr_mac_clk reset into clk_adc_125 domain before OR
    (* ASYNC_REG = "TRUE" *) reg [1:0] mac_rst_sync_125 = 2'b11;
    always_ff @(posedge clk_adc_125) begin
        mac_rst_sync_125 <= {mac_rst_sync_125[0], ~usr_mac_rst_n};
    end
    assign adc_fifo_rst = ~adc_rst_n || mac_rst_sync_125[1];

    // =========================================================================
    // 4. ADC → DDR4 写入通路
    //    adc_packer_512 (125M) → XPM async FIFO (125→322M) → S_AXIS_RX (322M)
    // =========================================================================
    wire [511:0] packer_512_tdata;
    wire [63:0]  packer_512_tkeep;
    wire         packer_512_tvalid, packer_512_tlast;
    wire         packer_512_tready;

    adc_packer_512 u_packer_512 (
        .clk_125        (clk_adc_125),
        .rst_n          (adc_rst_n),
        .data_i_bus     (adc_data_i),
        .data_q_bus     (adc_data_q),
        .adc_vld_i      (adc_vld_i),
        .adc_vld_q      (adc_vld_q),
        .adc_ready      (adc_ready),
        .capture_en     (1'b1),   // 开始采集后就持续打包
        .m_axis_tdata   (packer_512_tdata),
        .m_axis_tkeep   (packer_512_tkeep),
        .m_axis_tvalid  (packer_512_tvalid),
        .m_axis_tlast   (packer_512_tlast),
        .m_axis_tready  (packer_512_tready),
        .capture_done   ()
    );

    // XPM async FIFO: 577b @ 125MHz (ADC) → 577b @ 322MHz (usr_mac_clk)
    //   【修复 2026-05-19】扩宽到 577b = {tlast[0], tkeep[63:0], tdata[511:0]}
    //   保留 packer 的 2-beat burst 结构 (Beat0:Header, Beat1:Payload)
    wire        adc_fifo_rst;
    wire        adc_fifo_wr_rst_busy, adc_fifo_rd_rst_busy;
    wire        adc_fifo_empty, adc_fifo_full, adc_fifo_prog_full;
    wire [576:0] adc_fifo_dout;

    wire adc_fifo_wr_en = packer_512_tvalid && !adc_fifo_full && !adc_fifo_prog_full && !adc_fifo_wr_rst_busy;
    assign packer_512_tready = !adc_fifo_full && !adc_fifo_prog_full && !adc_fifo_wr_rst_busy;

    xpm_fifo_async #(
        .FIFO_MEMORY_TYPE    ("auto"),
        .FIFO_WRITE_DEPTH    (512),
        .WRITE_DATA_WIDTH    (577),
        .READ_DATA_WIDTH     (577),
        .READ_MODE           ("fwft"),
        .FIFO_READ_LATENCY   (0),
        .RELATED_CLOCKS      (0),
        .CDC_SYNC_STAGES     (3),
        .USE_ADV_FEATURES    ("1000"),  // enable prog_full for early backpressure
        .PROG_FULL_THRESH    (480),
        .ECC_MODE            ("no_ecc"),
        .WAKEUP_TIME         (0)
    ) u_adc_cdc_fifo (
        .rst            (adc_fifo_rst),
        .wr_clk         (clk_adc_125),
        .wr_en          (adc_fifo_wr_en),
        .din            ({packer_512_tlast, packer_512_tkeep, packer_512_tdata}),
        .rd_clk         (usr_mac_clk),
        .rd_en          (adc_fifo_rd_en),
        .dout           (adc_fifo_dout),
        .empty          (adc_fifo_empty),
        .full           (adc_fifo_full),
        .prog_full      (adc_fifo_prog_full),
        .wr_rst_busy    (adc_fifo_wr_rst_busy),
        .rd_rst_busy    (adc_fifo_rd_rst_busy),
        .data_valid     (),
        .sleep          (1'b0),
        .injectdbiterr  (1'b0),
        .injectsbiterr  (1'b0)
    );

    // CDC FIFO 输出 → S_AXIS_RX (恢复原始信号)
    wire [511:0] axis_rx_tdata;
    wire [63:0]  axis_rx_tkeep;
    wire         axis_rx_tvalid, axis_rx_tlast, axis_rx_tready;
    wire         adc_fifo_rd_en;

    // FWFT 模式下 dout 在 empty=0 时即有效，按 AXI 握手驱动 rd_en。
    assign axis_rx_tvalid  = !adc_fifo_empty && !adc_fifo_rd_rst_busy;
    assign adc_fifo_rd_en  = axis_rx_tvalid && axis_rx_tready;
    assign {axis_rx_tlast, axis_rx_tkeep, axis_rx_tdata} = adc_fifo_dout;

    // =========================================================================
    // 5. DDR4 子系统
    // =========================================================================
    wire [511:0] axis_tx_tdata;
    wire [63:0]  axis_tx_tkeep;
    wire         axis_tx_tvalid, axis_tx_tlast, axis_tx_tready;

    reg  [71:0]  s2mm_cmd_tdata;
    reg          s2mm_cmd_tvalid;
    wire         s2mm_cmd_tready;
    wire [71:0]  mm2s_cmd_tdata;
    wire         mm2s_cmd_tvalid, mm2s_cmd_tready;
    wire [7:0]   s2mm_sts_tdata, mm2s_sts_tdata;
    wire         s2mm_sts_tvalid, mm2s_sts_tvalid;
    wire         s2mm_err, mm2s_err;
    wire [11:0]  rx_cdc_wr_count, tx_cdc_wr_count;
    wire         rx_cdc_full;

    ddr4_subsystem_top u_ddr4 (
        .usr_mac_clk                (usr_mac_clk),
        .usr_mac_rst_n              (usr_mac_rst_n),
        .c0_ddr4_ui_clk             (c0_ddr4_ui_clk),
        .sys_rst                    (sys_rst_pad_in),
        .dm_rst_n                   (dm_rst_n),
        .c0_init_calib_complete     (ddr4_calib_complete),

        .diff_clock_rtl_0_clk_p     (ddr4_ref_clk_p),
        .diff_clock_rtl_0_clk_n     (ddr4_ref_clk_n),

        .ddr4_rtl_0_act_n           (ddr4_act_n),
        .ddr4_rtl_0_adr             (ddr4_adr),
        .ddr4_rtl_0_ba              (ddr4_ba),
        .ddr4_rtl_0_bg              (ddr4_bg),
        .ddr4_rtl_0_ck_c            (ddr4_ck_c),
        .ddr4_rtl_0_ck_t            (ddr4_ck_t),
        .ddr4_rtl_0_cke             (ddr4_cke),
        .ddr4_rtl_0_cs_n            (ddr4_cs_n),
        .ddr4_rtl_0_dm_n            (ddr4_dm_n),
        .ddr4_rtl_0_dq              (ddr4_dq),
        .ddr4_rtl_0_dqs_c           (ddr4_dqs_c),
        .ddr4_rtl_0_dqs_t           (ddr4_dqs_t),
        .ddr4_rtl_0_odt             (ddr4_odt),
        .ddr4_rtl_0_reset_n         (ddr4_reset_n),

        // ADC data → DDR4 (替代 CMAC RX)
        .S_AXIS_RX_tdata            (axis_rx_tdata),
        .S_AXIS_RX_tkeep            (axis_rx_tkeep),
        .S_AXIS_RX_tvalid           (axis_rx_tvalid),
        .S_AXIS_RX_tlast            (axis_rx_tlast),
        .S_AXIS_RX_tready           (axis_rx_tready),

        // DDR4 → CMAC/PCIe
        .M_AXIS_TX_tdata            (axis_tx_tdata),
        .M_AXIS_TX_tkeep            (axis_tx_tkeep),
        .M_AXIS_TX_tvalid           (axis_tx_tvalid),
        .M_AXIS_TX_tlast            (axis_tx_tlast),
        .M_AXIS_TX_tready           (axis_tx_tready),

        .S_AXIS_S2MM_CMD_0_tdata    (s2mm_cmd_tdata),
        .S_AXIS_S2MM_CMD_0_tvalid   (s2mm_cmd_tvalid),
        .S_AXIS_S2MM_CMD_0_tready   (s2mm_cmd_tready),
        .M_AXIS_S2MM_STS_0_tdata    (s2mm_sts_tdata),
        .M_AXIS_S2MM_STS_0_tvalid   (s2mm_sts_tvalid),
        .M_AXIS_S2MM_STS_0_tready   (1'b1),

        .S_AXIS_MM2S_CMD_0_tdata    (mm2s_cmd_tdata),
        .S_AXIS_MM2S_CMD_0_tvalid   (mm2s_cmd_tvalid),
        .S_AXIS_MM2S_CMD_0_tready   (mm2s_cmd_tready),
        .M_AXIS_MM2S_STS_0_tdata    (mm2s_sts_tdata),
        .M_AXIS_MM2S_STS_0_tvalid   (mm2s_sts_tvalid),
        .M_AXIS_MM2S_STS_0_tready   (1'b1),

        .s2mm_err_0                 (s2mm_err),
        .mm2s_err_0                 (mm2s_err),
        .rx_cdc_wr_count            (rx_cdc_wr_count),
        .tx_cdc_wr_count            (tx_cdc_wr_count),
        .rx_fifo_full               (rx_cdc_full)
    );

    assign ddr4_calib_done = ddr4_calib_complete;

    // =========================================================================
    // 6. DDR4 → CMAC / PCIe 读出分发
    // =========================================================================
    wire [511:0] demux_cmac_tdata;
    wire [63:0]  demux_cmac_tkeep;
    wire         demux_cmac_tvalid, demux_cmac_tlast, demux_cmac_tready;
    wire [63:0]  demux_pcie_tdata;
    wire [7:0]   demux_pcie_tkeep;    // 【新增】PCIe C2H tkeep
    wire         demux_pcie_tvalid, demux_pcie_tlast, demux_pcie_tready;
    wire [31:0]  rd_ptr_mon;

    ddr4_readout_demux #(
        .BUF_BASE       (DDR4_BUF_BASE),
        .BUF_SIZE_MB    (DDR4_BUF_MB)
    ) u_readout (
        .ddr4_ui_clk        (c0_ddr4_ui_clk),
        .ddr4_ui_rst_n      (dm_rst_n),
        .wr_ptr_shadow      (wr_ptr_confirmed),    // 等 S2MM status 确认后才推进
        .play_enable        (play_active_sync[1]),  // 【修复】UDP START_PLAY 控制
        .soft_rst           (soft_rst_active),      // 【新增】UDP SOFT_RESET 清零计数器
        .mm2s_cmd_tdata     (mm2s_cmd_tdata),
        .mm2s_cmd_tvalid    (mm2s_cmd_tvalid),
        .mm2s_cmd_tready    (mm2s_cmd_tready),
        .mm2s_sts_tdata     (mm2s_sts_tdata),
        .mm2s_sts_tvalid    (mm2s_sts_tvalid),
        .mm2s_cmd_cnt       (stat_mm2s_cmd_cnt_333), // 【新增】MM2S 命令计数

        .usr_mac_clk        (usr_mac_clk),
        .usr_mac_rst_n      (usr_mac_rst_n),
        .s_axis_tdata       (axis_tx_tdata),
        .s_axis_tkeep       (axis_tx_tkeep),
        .s_axis_tvalid      (axis_tx_tvalid),
        .s_axis_tlast       (axis_tx_tlast),
        .s_axis_tready      (axis_tx_tready),

        .cmac_tx_tdata      (demux_cmac_tdata),
        .cmac_tx_tkeep      (demux_cmac_tkeep),
        .cmac_tx_tvalid     (demux_cmac_tvalid),
        .cmac_tx_tlast      (demux_cmac_tlast),
        .cmac_tx_tready     (demux_cmac_tready),

        .pcie_clk_125       (clk_pcie_125),
        .pcie_rst_n         (pcie_rst_n),
        .pcie_c2h_tdata     (demux_pcie_tdata),
        .pcie_c2h_tkeep     (demux_pcie_tkeep),     // 【新增】PCIe tkeep
        .pcie_c2h_tvalid    (demux_pcie_tvalid),
        .pcie_c2h_tlast     (demux_pcie_tlast),
        .pcie_c2h_tready    (demux_pcie_tready),

        .rd_ptr_mon         (rd_ptr_mon),
        .buffer_empty       ()
    );

    // CMAC TX path — 直接连接
    assign cmac_tx_tdata   = demux_cmac_tdata;
    assign cmac_tx_tkeep   = demux_cmac_tkeep;
    assign cmac_tx_tvalid  = demux_cmac_tvalid;
    assign cmac_tx_tlast   = demux_cmac_tlast;
    assign demux_cmac_tready = cmac_tx_tready;

    // =========================================================================
    // 7. S2MM 命令生成 (c0_ddr4_ui_clk 域, 333MHz)
    //    ADC packer 输出 2-beat burst (Beat0:HDR, Beat1:Payload, tlast=1)
    //    → BTT=128 / 命令，匹配完整的 2-beat 帧。
    //
    //    RX CDC FIFO (深度 4096) 缓冲 beat，BD 按需通过 s2mm_cmd_tready
    //    反压命令速率。天然匹配 322M→333M CDC。
    // =========================================================================
    localparam [31:0] BUF_END  = DDR4_BUF_BASE + (DDR4_BUF_MB * 1024 * 1024) - 128;
    localparam [31:0] BUF_SIZE_BYTES = DDR4_BUF_MB * 1024 * 1024;
    localparam [31:0] BUF_SAFE = 32'd1048576;  // 1MB safety margin
    localparam [31:0] S2MM_CMD_FLAGS_BTT = {1'b1, 1'b1, 6'h00, 1'b1, 7'd0, 16'd128};

    reg [31:0] s2mm_addr_333;
    reg [31:0] wr_ptr_confirmed;
    reg [15:0] s2mm_cnt_reg = 16'd0;
    reg        rec_manual_mode = 1'b0;  // latch: 首次 START_REC 后进入手动模式

    // Buffer overrun guard: stop writing when unread > BUF_SIZE - BUF_SAFE
    //   环形缓冲绕回：写-读 = (wr >= rd) ? wr - rd : (BUF_END - rd) + (wr - BASE)
    wire [31:0] buf_unread = (s2mm_addr_333 >= rd_ptr_mon)
        ? (s2mm_addr_333 - rd_ptr_mon)
        : (BUF_END - rd_ptr_mon + s2mm_addr_333 - DDR4_BUF_BASE);
    wire buf_overrun = buf_unread > (BUF_SIZE_BYTES - BUF_SAFE);
    wire s2mm_write_en = !soft_rst_active && !buf_overrun &&
                         (!rec_manual_mode || rec_active_sync[1]);

    always_ff @(posedge c0_ddr4_ui_clk) begin
        if (!dm_rst_n) begin
            s2mm_addr_333    <= DDR4_BUF_BASE;
            wr_ptr_confirmed <= DDR4_BUF_BASE;
            s2mm_cmd_tvalid  <= 1'b0;
            s2mm_cmd_tdata   <= 72'd0;
            s2mm_cnt_reg     <= 16'd0;
        end else begin
            // S2MM 传输完成 → 确认 128B 已落盘
            if (s2mm_sts_tvalid) begin
                if (wr_ptr_confirmed >= BUF_END)
                    wr_ptr_confirmed <= DDR4_BUF_BASE;
                else
                    wr_ptr_confirmed <= wr_ptr_confirmed + 32'd128;
            end

            if (s2mm_cmd_tvalid && s2mm_cmd_tready) begin
                s2mm_cmd_tvalid <= 1'b0;
                s2mm_cnt_reg    <= s2mm_cnt_reg + 1'b1;
            end

            if (soft_rst_active)
                s2mm_cnt_reg <= 16'd0;

            if (!s2mm_cmd_tvalid && s2mm_write_en) begin
                s2mm_cmd_tdata  <= {8'h00, s2mm_addr_333, S2MM_CMD_FLAGS_BTT};
                s2mm_cmd_tvalid <= 1'b1;
                if (s2mm_addr_333 >= BUF_END)
                    s2mm_addr_333 <= DDR4_BUF_BASE;
                else
                    s2mm_addr_333 <= s2mm_addr_333 + 32'd128;
            end
        end
    end

    // =========================================================================
    // 8. UDP 命令控制 CDC (usr_mac_clk → c0_ddr4_ui_clk)
    // =========================================================================
    reg         rec_active_322  = 1'b0;
    reg         play_active_322 = 1'b0;
    (* ASYNC_REG = "TRUE" *) reg [1:0] rec_active_sync  = 2'd0;
    (* ASYNC_REG = "TRUE" *) reg [1:0] play_active_sync = 2'd0;
    always_ff @(posedge usr_mac_clk) begin
        if (!usr_mac_rst_n) begin
            rec_active_322  <= 1'b0;
            play_active_322 <= 1'b0;
            rec_manual_mode <= 1'b0;
        end else begin
            if (ctrl_soft_reset) begin
                rec_active_322  <= 1'b0;
                play_active_322 <= 1'b0;
                rec_manual_mode <= 1'b0;  // back to auto-write on soft reset
            end else begin
                if (ctrl_start_rec) begin
                    rec_active_322  <= 1'b1;
                    rec_manual_mode <= 1'b1;   // latch manual mode forever
                end
                if (ctrl_stop_rec)   rec_active_322  <= 1'b0;
                if (ctrl_start_play) play_active_322 <= 1'b1;
                if (ctrl_stop_play)  play_active_322 <= 1'b0;
            end
        end
    end

    always_ff @(posedge c0_ddr4_ui_clk) begin
        rec_active_sync  <= {rec_active_sync[0],  rec_active_322};
        play_active_sync <= {play_active_sync[0], play_active_322};
    end

    // 软复位 CDC (toggle → edge detect)
    reg soft_rst_toggle_322 = 1'b0;
    always_ff @(posedge usr_mac_clk) begin
        if (!usr_mac_rst_n)
            soft_rst_toggle_322 <= 1'b0;
        else if (ctrl_soft_reset)
            soft_rst_toggle_322 <= ~soft_rst_toggle_322;
    end

    (* ASYNC_REG = "TRUE" *) reg [1:0] soft_rst_toggle_sync = 2'd0;
    reg soft_rst_toggle_333_d = 1'b0;
    reg soft_rst_active = 1'b0;
    reg [3:0] soft_rst_cnt = 4'd0;

    always_ff @(posedge c0_ddr4_ui_clk) begin
        if (!dm_rst_n) begin
            soft_rst_toggle_sync  <= 2'd0;
            soft_rst_active       <= 1'b0;
            soft_rst_cnt          <= 4'd0;
            soft_rst_toggle_333_d <= 1'b0;
        end else begin
            soft_rst_toggle_sync  <= {soft_rst_toggle_sync[0], soft_rst_toggle_322};
            soft_rst_toggle_333_d <= soft_rst_toggle_sync[1];
            if (soft_rst_toggle_sync[1] != soft_rst_toggle_333_d) begin
                soft_rst_active <= 1'b1;
                soft_rst_cnt    <= 4'd15;
            end else if (soft_rst_active) begin
                if (soft_rst_cnt == 0)
                    soft_rst_active <= 1'b0;
                else
                    soft_rst_cnt <= soft_rst_cnt - 1'b1;
            end
        end
    end

    // =========================================================================
    // 9. 状态回传 CDC (c0_ddr4_ui_clk → usr_mac_clk)
    // =========================================================================
    wire [15:0] stat_s2mm_cmd_cnt_333, stat_mm2s_cmd_cnt_333;
    wire [11:0] stat_tx_wr_count_333;
    wire        stat_s2mm_err_333,     stat_mm2s_err_333;

    xpm_cdc_gray #(.DEST_SYNC_FF(3), .SIM_ASSERT_CHK(0), .WIDTH(16)) u_cdc_s2mm_cnt (
        .src_clk(c0_ddr4_ui_clk), .src_in_bin(stat_s2mm_cmd_cnt_333),
        .dest_clk(usr_mac_clk),   .dest_out_bin(stat_s2mm_cmd_cnt_322)
    );
    xpm_cdc_gray #(.DEST_SYNC_FF(3), .SIM_ASSERT_CHK(0), .WIDTH(16)) u_cdc_mm2s_cnt (
        .src_clk(c0_ddr4_ui_clk), .src_in_bin(stat_mm2s_cmd_cnt_333),
        .dest_clk(usr_mac_clk),   .dest_out_bin(stat_mm2s_cmd_cnt_322)
    );
    // rx_cdc_wr_count 已在 usr_mac_clk 域，直连即可
    assign stat_rx_wr_count_322 = rx_cdc_wr_count;

    xpm_cdc_gray #(.DEST_SYNC_FF(3), .SIM_ASSERT_CHK(0), .WIDTH(12)) u_cdc_tx_wr_cnt (
        .src_clk(c0_ddr4_ui_clk), .src_in_bin(stat_tx_wr_count_333),
        .dest_clk(usr_mac_clk),   .dest_out_bin(stat_tx_wr_count_322)
    );

    (* ASYNC_REG = "TRUE" *) reg [1:0] s2mm_err_sync, mm2s_err_sync;
    always_ff @(posedge usr_mac_clk) begin
        s2mm_err_sync <= {s2mm_err_sync[0], stat_s2mm_err_333};
        mm2s_err_sync <= {mm2s_err_sync[0], stat_mm2s_err_333};
    end
    assign stat_s2mm_err_322 = s2mm_err_sync[1];
    assign stat_mm2s_err_322 = mm2s_err_sync[1];

    // =========================================================================
    // 10. DDR4 复位生成 (c0_ddr4_ui_clk 域)
    //     dm_rst_n: 等 calib_complete + clk_100m_locked + ~333ms 后释放
    // =========================================================================
    (* ASYNC_REG = "TRUE" *) reg [2:0] ddr4_rst_sync_ff = 3'b111;
    always_ff @(posedge c0_ddr4_ui_clk) begin
        ddr4_rst_sync_ff <= {ddr4_rst_sync_ff[1:0], sys_rst_pad_in};
    end
    wire ddr4_rst_n = ~ddr4_rst_sync_ff[2];

    (* ASYNC_REG = "TRUE" *) reg [1:0] locked_sync_ff = 2'b00;
    always_ff @(posedge c0_ddr4_ui_clk) begin
        if (!ddr4_rst_n)
            locked_sync_ff <= 2'b00;
        else
            locked_sync_ff <= {locked_sync_ff[0], clk_100m_locked};
    end
    wire clk_100m_locked_sync = locked_sync_ff[1];

    wire ddr4_ready = ddr4_calib_complete && clk_100m_locked_sync;
`ifdef XILINX_SIMULATOR
    localparam [28:0] DDR4_READY_CNT_MAX = 29'd500;
`else
    localparam [28:0] DDR4_READY_CNT_MAX = 29'h13E0_0000;
`endif
    reg [28:0] ddr4_ready_cnt = 29'd0;
    reg        dm_rst_n_reg = 1'b0;
    always_ff @(posedge c0_ddr4_ui_clk) begin
        if (!ddr4_rst_n) begin
            ddr4_ready_cnt <= 29'd0;
            dm_rst_n_reg   <= 1'b0;
        end else begin
            if (ddr4_ready_cnt < DDR4_READY_CNT_MAX)
                ddr4_ready_cnt <= ddr4_ready_cnt + 1'b1;
            else if (ddr4_ready)
                dm_rst_n_reg <= 1'b1;
        end
    end
    assign dm_rst_n = dm_rst_n_reg;

    // dm_rst_n 跨域同步: 为各域添加 2-FF 同步器
    // usr_mac_clk 域
    (* ASYNC_REG = "TRUE" *) reg [1:0] dm_rst_mac_sync  = 2'b00;
    always_ff @(posedge usr_mac_clk)
        dm_rst_mac_sync <= {dm_rst_mac_sync[0], dm_rst_n};
    wire dm_rst_mac = dm_rst_mac_sync[1];
    // clk_adc_125 域
    (* ASYNC_REG = "TRUE" *) reg [1:0] dm_rst_adc_sync  = 2'b00;
    always_ff @(posedge clk_adc_125)
        dm_rst_adc_sync <= {dm_rst_adc_sync[0], dm_rst_n};
    wire dm_rst_adc = dm_rst_adc_sync[1];

    // =========================================================================
    // 11. PCIe XDMA 子系统 (备份通路)
    // =========================================================================
    wire pcie_refclk_gt, pcie_refclk_fabric;

    IBUFDS_GTE4 #(.REFCLK_HROW_CK_SEL(2'b00)) u_pcie_refclk_ibuf (
        .I      (pcie_refclk_p),
        .IB     (pcie_refclk_n),
        .CEB    (1'b0),
        .O      (pcie_refclk_gt),
        .ODIV2  (pcie_refclk_fabric)
    );

    xdma_0 u_xdma (
        .sys_clk                (pcie_refclk_fabric),
        .sys_clk_gt             (pcie_refclk_gt),
        .sys_rst_n              (~sys_rst_pad_in),
        .user_lnk_up            (pcie_link_up),
        .pci_exp_rxp            (pcie_rx_p),
        .pci_exp_rxn            (pcie_rx_n),
        .pci_exp_txp            (pcie_tx_p),
        .pci_exp_txn            (pcie_tx_n),
        .axi_aclk               (clk_pcie_125),
        .axi_aresetn            (pcie_rst_n),
        .usr_irq_req            (1'b0),
        .usr_irq_ack            (),
        .msix_enable            (),

        .m_axil_awaddr          (),
        .m_axil_awprot          (),
        .m_axil_awvalid         (),
        .m_axil_awready         (1'b0),
        .m_axil_wdata           (),
        .m_axil_wstrb           (),
        .m_axil_wvalid          (),
        .m_axil_wready          (1'b0),
        .m_axil_bvalid          (1'b0),
        .m_axil_bresp           (2'b00),
        .m_axil_bready          (),
        .m_axil_araddr          (),
        .m_axil_arprot          (),
        .m_axil_arvalid         (),
        .m_axil_arready         (1'b0),
        .m_axil_rdata           (32'd0),
        .m_axil_rresp           (2'b00),
        .m_axil_rvalid          (1'b0),
        .m_axil_rready          (),

        .s_axis_c2h_tdata_0     (demux_pcie_tdata),
        .s_axis_c2h_tkeep_0     (demux_pcie_tkeep),   // 【修复】使用 demux 输出的 tkeep
        .s_axis_c2h_tvalid_0    (demux_pcie_tvalid),
        .s_axis_c2h_tlast_0     (demux_pcie_tlast),
        .s_axis_c2h_tready_0    (demux_pcie_tready),

        .m_axis_h2c_tdata_0     (),
        .m_axis_h2c_tlast_0     (),
        .m_axis_h2c_tvalid_0    (),
        .m_axis_h2c_tready_0    (1'b0),
        .m_axis_h2c_tkeep_0     (),

        .s_axil_awaddr          (32'd0),
        .s_axil_awprot          (3'd0),
        .s_axil_awvalid         (1'b0),
        .s_axil_awready         (),
        .s_axil_wdata           (32'd0),
        .s_axil_wstrb           (4'd0),
        .s_axil_wvalid          (1'b0),
        .s_axil_wready          (),
        .s_axil_bvalid          (),
        .s_axil_bresp           (),
        .s_axil_bready          (1'b0),
        .s_axil_araddr          (32'd0),
        .s_axil_arprot          (3'd0),
        .s_axil_arvalid         (1'b0),
        .s_axil_arready         (),
        .s_axil_rdata           (),
        .s_axil_rresp           (),
        .s_axil_rvalid          (),
        .s_axil_rready          (1'b0),

        .cfg_mgmt_addr          (19'd0),
        .cfg_mgmt_write         (1'b0),
        .cfg_mgmt_write_data    (32'd0),
        .cfg_mgmt_byte_enable   (4'd0),
        .cfg_mgmt_read          (1'b0),
        .cfg_mgmt_read_data     (),
        .cfg_mgmt_read_write_done()
    );

    // =========================================================================
    // 12. TX meta CDC (333→322M): 跟原 fpga_top_100g 一致
    //     MM2S 命令发出时，记录 BTT 作为 TX 帧长度
    // =========================================================================
    xpm_fifo_async #(
        .FIFO_MEMORY_TYPE("distributed"),
        .FIFO_READ_LATENCY(0),
        .FIFO_WRITE_DEPTH(64),
        .READ_MODE("fwft"),
        .WRITE_DATA_WIDTH(16),
        .READ_DATA_WIDTH(16),
        .CDC_SYNC_STAGES(3)
    ) u_tx_meta_fifo (
        .rst    (~dm_rst_n),
        .wr_clk (c0_ddr4_ui_clk),
        .wr_en  (mm2s_cmd_tvalid && mm2s_cmd_tready),
        .din    (mm2s_cmd_tdata[15:0]),   // BTT from MM2S command
        .rd_clk (usr_mac_clk),
        .rd_en  (tx_meta_rd_en),
        .dout   (tx_meta_len_322m),
        .empty  (tx_meta_empty_322m),
        .sleep  (1'b0)
    );

    // =========================================================================
    // 13. 模式控制 & LED
    // =========================================================================

    reg [25:0] hb_cnt = 0;
    always_ff @(posedge clk_50m_in) hb_cnt <= hb_cnt + 1'b1;
    assign led_out[0] = hb_cnt[25];
    assign led_out[1] = mac_link_up;
    assign led_out[2] = adc_ready;
    assign led_out[3] = ddr4_calib_complete;

    // =========================================================================
    // 14. 诊断信号 (连接到 stat → UDP GET_STATUS → PC)
    // =========================================================================
    // S2MM 命令计数: 来自 S2MM 命令生成模块的 reg → wire
    assign stat_s2mm_cmd_cnt_333 = s2mm_cnt_reg;
    // MM2S 命令计数: 来自 ddr4_readout_demux 内部计数器
    //   (已在 u_readout 例化中通过 .mm2s_cmd_cnt() 连接)
    assign stat_tx_wr_count_333  = tx_cdc_wr_count;
    assign stat_s2mm_err_333     = s2mm_err;
    assign stat_mm2s_err_333     = mm2s_err;

endmodule
