`timescale 1ns / 1ps

// 模块名：gearbox_32_to_96
// 模块功能：
// 1) 先在 375MHz 域把连续 3 个 32bit 样本打成 1 个 96bit 字
// 2) 再使用合法的 96bit->96bit XPM 异步 FIFO 做 375MHz->125MHz CDC
// 3) 低 32bit 对应最早样本，高 32bit 对应最新样本
module gearbox_32_to_96 (
    input  wire        clk_375,      // 高速输入时钟域 (375MHz)
    input  wire        clk_125,      // 低速输出时钟域 (125MHz)
    input  wire        rst,          // 高有效复位（由 adc_ready 控制）
    input  wire [31:0] data_in,      // 32bit 连续输入数据
    input  wire        bp_ready,     // 下游可接收标志，0 = 暂停读 FIFO
    output wire [95:0] data_out,     // 96bit 输出数据
    output wire        data_vld_125  // 输出有效（level, FIFO 非空即为 1）
);

    reg  [31:0] sample_word0;
    reg  [31:0] sample_word1;
    reg  [1:0]  pack_phase;
    reg  [95:0] fifo_din_96;
    reg         fifo_wr_en_96;

    wire        fifo_empty;
    wire        fifo_full;
    wire        fifo_wr_rst_busy;
    wire        fifo_rd_rst_busy;
    wire        fifo_data_valid;

    always @(posedge clk_375) begin
        if (rst || fifo_wr_rst_busy) begin
            sample_word0 <= 32'd0;
            sample_word1 <= 32'd0;
            pack_phase   <= 2'd0;
            fifo_din_96  <= 96'd0;
            fifo_wr_en_96 <= 1'b0;
        end else begin
            fifo_wr_en_96 <= 1'b0;

            case (pack_phase)
                2'd0: begin
                    sample_word0 <= data_in;
                    pack_phase   <= 2'd1;
                end

                2'd1: begin
                    sample_word1 <= data_in;
                    pack_phase   <= 2'd2;
                end

                default: begin
                    fifo_din_96  <= {data_in, sample_word1, sample_word0};
                    fifo_wr_en_96 <= 1'b1;
                    pack_phase   <= 2'd0;
                end
            endcase
        end
    end

    // XPM 异步 FIFO: 96bit@375MHz(每 3 拍 1 次写) → 96bit@125MHz
    //   规避 32->96 宽变换在 Vivado 2025.2 XPM 中的非法 DRC 组合。
    xpm_fifo_async #(
        .FIFO_MEMORY_TYPE    ("auto"),             // 自动选择 BRAM/distributed
        .FIFO_WRITE_DEPTH    (64),                 // 留足启动/相位漂移缓冲
        .WRITE_DATA_WIDTH    (96),
        .READ_DATA_WIDTH     (96),
        .READ_MODE           ("fwft"),             // first-word fall-through, 零读延时
        .FIFO_READ_LATENCY   (0),                  // fwft 模式下设为 0
        .RELATED_CLOCKS      (1),                  // 同源时钟, 使能优化路径
        .USE_ADV_FEATURES    ("0000"),            // 关闭未使用的 prog_full/prog_empty 特性
        .ECC_MODE            ("no_ecc"),
        .WAKEUP_TIME         (0)
    ) u_fifo (
        .rst            (rst),
        .wr_clk         (clk_375),
        .wr_en          (fifo_wr_en_96),
        .din            (fifo_din_96),
        .rd_clk         (clk_125),
        .rd_en          (!rst && !fifo_rd_rst_busy && !fifo_empty && bp_ready),
        .dout           (data_out),
        .empty          (fifo_empty),
        .full           (fifo_full),
        .wr_rst_busy    (fifo_wr_rst_busy),
        .rd_rst_busy    (fifo_rd_rst_busy),
        .sleep          (1'b0),
        .injectdbiterr  (1'b0),
        .injectsbiterr  (1'b0),
        // 未使用的输出
        .wr_ack         (),
        .overflow       (),
        .prog_full      (),
        .wr_data_count  (),
        .rd_data_count  (),
        .underflow      (),
        .prog_empty     (),
        .almost_empty   (),
        .almost_full    (),
        .data_valid     (fifo_data_valid),
        .sbiterr        (),
        .dbiterr        ()
    );

    // 有效信号: 只在读域真正给出有效数据时拉高
    assign data_vld_125 = !rst && !fifo_rd_rst_busy && fifo_data_valid;

endmodule

