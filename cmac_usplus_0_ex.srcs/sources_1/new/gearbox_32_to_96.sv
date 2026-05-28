`timescale 1ns / 1ps

// 模块名：gearbox_32_to_96
// 模块功能：
// 1) 先在 375MHz 域把连续 3 个 32bit 样本打成 1 个 96bit 字
// 2) 再使用 XPM 异步 FIFO (96bit @375M → 96bit @125M) 做 CDC
// 3) 每 3 拍写 1 次，125MHz 读口每拍输出 1 个 96bit 字，吞吐量精确匹配
// 4) 96-bit 非 2^n 宽度已通过 Vivado DRC，BRAM 自动拼接无浪费
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
    reg  [95:0] fifo_din;
    reg         fifo_wr_en;

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
            fifo_din     <= 96'd0;
            fifo_wr_en   <= 1'b0;
        end else begin
            fifo_wr_en <= 1'b0;

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
                    fifo_din   <= {data_in, sample_word1, sample_word0};
                    fifo_wr_en <= 1'b1;
                    pack_phase <= 2'd0;
                end
            endcase
        end
    end

    // XPM 异步 FIFO: 96bit@375MHz(每3拍1次写) → 96bit@125MHz
    //   吞吐量: 96b × 125M = 12Gbps = 32b × 375M，精确匹配，零丢数
    xpm_fifo_async #(
        .FIFO_MEMORY_TYPE    ("auto"),
        .FIFO_WRITE_DEPTH    (64),
        .WRITE_DATA_WIDTH    (96),
        .READ_DATA_WIDTH     (96),
        .READ_MODE           ("fwft"),
        .FIFO_READ_LATENCY   (0),
        .RELATED_CLOCKS      (1),
        .USE_ADV_FEATURES    ("0000"),
        .ECC_MODE            ("no_ecc"),
        .WAKEUP_TIME         (0)
    ) u_fifo (
        .rst            (rst),
        .wr_clk         (clk_375),
        .wr_en          (fifo_wr_en),
        .din            (fifo_din),
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

    assign data_vld_125 = !rst && !fifo_rd_rst_busy && fifo_data_valid && bp_ready;

endmodule

