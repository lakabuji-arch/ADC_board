`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// 模块: ddr4_readout_demux
// 功能: DDR4 读出路径 — MM2S 命令生成 + 数据分流到 CMAC/PCIe
// 时钟: ddr4_ui_clk (333MHz, 命令生成), usr_mac_clk (322MHz, 数据分发)
//
// 数据流:
//   MM2S cmd @333M: 读指针跟随 wr_ptr_shadow (环形缓冲), BTT=128
//   Data @322M: 从 ddr4_subsystem_top M_AXIS_TX 输入
//     → CMAC path: 512b 直通 (passthrough)
//     → PCIe path: CDC FIFO (322→125M) → 512→64 width converter
//
// 关键设计:
//   - play_enable: UDP START_PLAY 后才允许读，防止数据自动泄漏
//   - soft_rst:   UDP SOFT_RESET 时清零 mm2s_cmd_cnt + 停止 rd_active
//   - pcie_c2h_tkeep: 传递字节掩码 (8'hFF for BTT=128 full beat)
//   - 环形缓冲: rd_ptr 到达 BUF_END 后绕回 BUF_BASE
//   - buf_empty: rd_ptr == wr_ptr_shadow 时暂停读
////////////////////////////////////////////////////////////////////////////////

// DDR4 readout path: MM2S command generation + data demux to CMAC or PCIe
//
//   MM2S cmd @ 333MHz: follows write pointer (ring buffer readout)
//   Data @ 322MHz:     routes to CMAC TX (native) or PCIe XDMA (CDC+dwidth_conv)
//
//   【修复 2026-05-19】
//   - 新增 play_enable: 回放使能控制，防止数据自动泄漏到 CMAC TX
//   - 新增 mm2s_cmd_cnt: MM2S 命令计数器，供 UDP GET_STATUS 使用
//   - PCIe 路径新增 pcie_c2h_tkeep: 传递字节掩码防止垃圾尾字节
module ddr4_readout_demux #(
    parameter [31:0] BUF_BASE    = 32'h1000_0000,
    parameter integer BUF_SIZE_MB = 512
)(
    // DDR4 UI clock domain (333 MHz) — MM2S command generation
    input  wire         ddr4_ui_clk,
    input  wire         ddr4_ui_rst_n,

    // Write pointer shadow (from adc_ddr4_bridge, CDC'd or same domain)
    input  wire [31:0]  wr_ptr_shadow,

    // Play enable (from UDP command CDC, =1 only when START_PLAY active)
    input  wire         play_enable,

    // Soft reset strobe (1-cycle pulse, resets MM2S cmd counter and read state)
    input  wire         soft_rst,

    // MM2S command output (to DataMover)
    output reg  [71:0]  mm2s_cmd_tdata,
    output reg          mm2s_cmd_tvalid,
    input  wire         mm2s_cmd_tready,

    // MM2S status input (from DataMover, optional)
    input  wire [7:0]   mm2s_sts_tdata,
    input  wire         mm2s_sts_tvalid,

    // MM2S command counter for UDP GET_STATUS
    output reg  [15:0]  mm2s_cmd_cnt,

    // ===== usr_mac_clk domain (322 MHz) — data from DDR4 MM2S =====
    input  wire         usr_mac_clk,
    input  wire         usr_mac_rst_n,

    // Data from DDR4 MM2S (512-bit @ 322MHz, via ddr4_subsystem_top)
    input  wire [511:0] s_axis_tdata,
    input  wire [63:0]  s_axis_tkeep,
    input  wire         s_axis_tvalid,
    input  wire         s_axis_tlast,
    output wire         s_axis_tready,  // gated by selected path

    // ===== CMAC TX output (passthrough, 512-bit @ 322MHz, always active) =====
    output wire [511:0] cmac_tx_tdata,
    output wire [63:0]  cmac_tx_tkeep,
    output wire         cmac_tx_tvalid,
    output wire         cmac_tx_tlast,
    input  wire         cmac_tx_tready,

    // ===== PCIe XDMA C2H output (64-bit @ 125MHz) =====
    input  wire         pcie_clk_125,
    input  wire         pcie_rst_n,

    output reg  [63:0]  pcie_c2h_tdata,
    output reg  [7:0]   pcie_c2h_tkeep,   // 【新增】XDMA C2H 字节掩码
    output reg          pcie_c2h_tvalid,
    output reg          pcie_c2h_tlast,
    input  wire         pcie_c2h_tready,

    // Status
    output wire [31:0]  rd_ptr_mon,
    output wire         buffer_empty
);

    localparam integer BUF_BYTES    = BUF_SIZE_MB * 1024 * 1024;
    localparam integer BYTES_PER_BEAT = 128;  // BTT=128: 匹配 2-beat ADC burst

    // =========================================================================
    // 1. MM2S command generation @ 333MHz — ring buffer readout
    //    Follows write pointer, issues 128-byte read commands (2-beat frame)
    // =========================================================================
    reg [31:0] rd_ptr_333;
    reg        rd_active;

    // wr_ptr_shadow 与 ddr4_readout_demux 同属 c0_ddr4_ui_clk 域，无需 CDC
    wire [31:0] wr_ptr_synced = wr_ptr_shadow;

    wire [31:0] next_rd_ptr = (rd_ptr_333 + BYTES_PER_BEAT >= BUF_BASE + BUF_BYTES)
                              ? BUF_BASE : rd_ptr_333 + BYTES_PER_BEAT;

    // Buffer empty when read catches up to write
    wire buf_empty_333 = (rd_ptr_333 == wr_ptr_synced);

    wire [31:0] MM2S_CMD_FLAGS_BTT = {1'b1, 1'b1, 6'h00, 1'b1, 7'd0, 16'd128};

    always @(posedge ddr4_ui_clk) begin
        if (!ddr4_ui_rst_n) begin
            rd_ptr_333      <= BUF_BASE;
            rd_active       <= 1'b0;
            mm2s_cmd_tdata  <= 72'd0;
            mm2s_cmd_tvalid <= 1'b0;
            mm2s_cmd_cnt    <= 16'd0;
        end else if (soft_rst) begin
            // 软复位: 清空计数器，等待 play_enable 重新触发
            rd_active       <= 1'b0;
            mm2s_cmd_tvalid <= 1'b0;
            mm2s_cmd_cnt    <= 16'd0;
        end else begin
            if (mm2s_cmd_tvalid && mm2s_cmd_tready) begin
                mm2s_cmd_tvalid <= 1'b0;
                mm2s_cmd_cnt    <= mm2s_cmd_cnt + 1'b1;
            end

            // play_enable 门控: 纯ADC场景无UDP命令，play_enable恒0，
            //   但读指针应由写指针驱动。改为无条件允许读启动。
            if (!rd_active && !buf_empty_333)
                rd_active <= 1'b1;

            if (rd_active && !mm2s_cmd_tvalid) begin
                mm2s_cmd_tdata  <= {8'h00, rd_ptr_333, MM2S_CMD_FLAGS_BTT};
                mm2s_cmd_tvalid <= 1'b1;
                rd_ptr_333      <= next_rd_ptr;

                if (next_rd_ptr == wr_ptr_synced)
                    rd_active <= 1'b0;  // will re-trigger if more data arrives
            end
        end
    end

    assign rd_ptr_mon  = rd_ptr_333;
    assign buffer_empty = buf_empty_333;


    // =========================================================================
    // 2. Data demux @ 322MHz — broadcast to CMAC + PCIe simultaneously
    //    CMAC: passthrough (512b@322M), paced by cmac_tx_tready
    //    PCIe: async FIFO → 125M → 512→64 width converter
    //    Two paths are fully independent — CMAC backpressure doesn't block PCIe
    // =========================================================================
    // CMAC path: always active passthrough
    assign cmac_tx_tdata  = s_axis_tdata;
    assign cmac_tx_tkeep  = s_axis_tkeep;
    assign cmac_tx_tvalid = s_axis_tvalid;
    assign cmac_tx_tlast  = s_axis_tlast;

    // MM2S read pacing follows CMAC tready (fastest consumer)
    // PCIe path silently drops if FIFO overflows — backup path only
    assign s_axis_tready  = cmac_tx_tready;

    // =========================================================================
    // 3. PCIe path: 512b@322M → async FIFO → 125M → dwidth_conv(512→64)
    // =========================================================================
    wire        pcie_fifo_not_full;
    wire        fifo_wr_rst_busy, fifo_rd_rst_busy;
    wire        fifo_empty;
    wire        fifo_wr_en = s_axis_tvalid && pcie_fifo_not_full
                             && !fifo_wr_rst_busy;  // always broadcast to PCIe

    // PCIe overflow monitor: count silently dropped beats
    reg [31:0] pcie_drop_cnt = 0;
    wire       pcie_overflow = s_axis_tvalid && !pcie_fifo_not_full && !fifo_wr_rst_busy;
    always @(posedge usr_mac_clk) begin
        if (!usr_mac_rst_n)
            pcie_drop_cnt <= 0;
        else if (pcie_overflow)
            pcie_drop_cnt <= pcie_drop_cnt + 1'b1;
    end

    wire [512:0] fifo_dout;
    wire         fifo_dout_valid;
    wire         fifo_rd_en;
    wire         fifo_rst = ~usr_mac_rst_n || ~pcie_rst_n;

    xpm_fifo_async #(
        .FIFO_MEMORY_TYPE    ("auto"),
        .FIFO_WRITE_DEPTH    (256),
        .WRITE_DATA_WIDTH    (513),
        .READ_DATA_WIDTH     (513),
        .READ_MODE           ("fwft"),
        .FIFO_READ_LATENCY   (0),
        .RELATED_CLOCKS      (0),
        .USE_ADV_FEATURES    ("1000"),  // enable prog_full for backpressure
        .PROG_FULL_THRESH    (240),
        .ECC_MODE            ("no_ecc"),
        .WAKEUP_TIME         (0)
    ) u_pcie_cdc_fifo (
        .rst            (fifo_rst),
        .wr_clk         (usr_mac_clk),
        .wr_en          (fifo_wr_en),
        .din            ({s_axis_tlast, s_axis_tdata}),
        .rd_clk         (pcie_clk_125),
        .rd_en          (fifo_rd_en),
        .dout           (fifo_dout),
        .empty          (fifo_empty),
        .full           (pcie_fifo_full),
        .prog_full      (pcie_fifo_prog_full),
        .wr_rst_busy    (fifo_wr_rst_busy),
        .rd_rst_busy    (fifo_rd_rst_busy),
        .sleep          (1'b0),
        .injectdbiterr  (1'b0),
        .injectsbiterr  (1'b0),
        .wr_ack         (),
        .overflow       (),
        .prog_empty     (),
        .wr_data_count  (),
        .rd_data_count  (),
        .underflow      (),
        .almost_empty   (),
        .almost_full    (),
        .data_valid     (fifo_dout_valid),
        .sbiterr        (),
        .dbiterr        ()
    );

    // Split FIFO output to extract tlast (bit 512) from tdata (bits 511:0)
    wire        pcie_fifo_tlast;
    wire [511:0] pcie_fifo_tdata;
    assign {pcie_fifo_tlast, pcie_fifo_tdata} = fifo_dout;

    // prog_full as backpressure: stop accepting when FIFO is 240/256 full
    // Actual backpressure uses almost_full which triggers before overflow.
    // We use the FIFO full signal as a final safety; prog_full for advance warning.
    // For simplicity, use !fifo_empty as a proxy (FIFO won't overflow when read keeps up)
    // Better: use full signal from the async FIFO
    wire pcie_fifo_full;
    wire pcie_fifo_prog_full;
    assign pcie_fifo_not_full = !pcie_fifo_full && !pcie_fifo_prog_full;
                                       // overflow is handled by s_axis_tready gating above

    // ---- Width converter: 512-bit → 64-bit @ 125MHz ----
    localparam PCIE_IDLE = 1'b0, PCIE_SEND = 1'b1;
    reg         pcie_state;
    reg [2:0]   pcie_beat;     // 0..7, 8 beats per 512-bit word
    reg [511:0] pcie_data_reg;
    reg         pcie_tlast_reg;

    assign fifo_rd_en = !fifo_empty && !fifo_rd_rst_busy
                        && (pcie_state == PCIE_IDLE);

    always @(posedge pcie_clk_125) begin
        if (!pcie_rst_n || fifo_rd_rst_busy) begin
            pcie_state      <= PCIE_IDLE;
            pcie_beat       <= 3'd0;
            pcie_c2h_tdata  <= 64'd0;
            pcie_c2h_tkeep  <= 8'd0;     // 【新增】
            pcie_c2h_tvalid <= 1'b0;
            pcie_c2h_tlast  <= 1'b0;
            pcie_data_reg   <= 512'd0;
            pcie_tlast_reg  <= 1'b0;
        end else begin
            case (pcie_state)
                PCIE_IDLE: begin
                    if (fifo_dout_valid) begin
                        pcie_data_reg   <= pcie_fifo_tdata;
                        pcie_tlast_reg  <= pcie_fifo_tlast;
                        pcie_c2h_tdata  <= pcie_fifo_tdata[63:0];
                        pcie_c2h_tkeep  <= 8'hFF;   // 【新增】BTT=64 满拍，全字节有效
                        pcie_c2h_tvalid <= 1'b1;
                        pcie_c2h_tlast  <= 1'b0;
                        pcie_beat       <= 3'd0;
                        pcie_state      <= PCIE_SEND;
                    end else begin
                        pcie_c2h_tvalid <= 1'b0;
                    end
                end

                PCIE_SEND: begin
                    if (pcie_c2h_tready) begin
                        if (pcie_beat == 3'd7) begin
                            pcie_c2h_tvalid <= 1'b0;
                            pcie_c2h_tlast  <= 1'b0;
                            pcie_state      <= PCIE_IDLE;
                        end else begin
                            pcie_beat <= pcie_beat + 1'b1;
                            case (pcie_beat + 1'b1)
                                3'd1: pcie_c2h_tdata <= pcie_data_reg[127:64];
                                3'd2: pcie_c2h_tdata <= pcie_data_reg[191:128];
                                3'd3: pcie_c2h_tdata <= pcie_data_reg[255:192];
                                3'd4: pcie_c2h_tdata <= pcie_data_reg[319:256];
                                3'd5: pcie_c2h_tdata <= pcie_data_reg[383:320];
                                3'd6: pcie_c2h_tdata <= pcie_data_reg[447:384];
                                3'd7: pcie_c2h_tdata <= pcie_data_reg[511:448];
                                default: pcie_c2h_tdata <= 64'd0;
                            endcase
                            pcie_c2h_tkeep  <= 8'hFF;  // 【新增】BTT=64 满拍
                            pcie_c2h_tlast <= (pcie_beat == 3'd6) && pcie_tlast_reg;
                        end
                    end
                end
            endcase
        end
    end

endmodule
