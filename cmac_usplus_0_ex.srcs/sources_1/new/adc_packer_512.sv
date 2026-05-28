`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// 模块: adc_packer_512
// 功能: ADC 样本打包器 — 5 对 I/Q 样本 → 2-beat 512-bit burst
// 时钟: clk_125 (125MHz, 来自 adc_top)
//
// 数据流:
//   输入: data_i_bus[95:0] + data_q_bus[95:0] (每 96b = 12 × 8bit ADC 样本)
//   缓冲: 8-entry 环形 buffer (ibuf[0:7], qbuf[0:7])
//   输出: 512-bit AXI-Stream, 2 拍一帧
//
// 帧格式 (2-beat burst):
//   Beat0(tlast=0): [511:480] HDR{sync=1, seq[14:0], ts[15:0]}
//                   [479:0]   I0,Q0,I1,Q1,I2  (5 × 96b)
//   Beat1(tlast=1): [511:32]  Q2,I3,Q3,I4,Q4  (5 × 96b)
//                   [31:0]    TS[31:0] (timestamp high word)
//
// 设计要点:
//   - 效率: 5 对/2 拍 = 93.75% (960/1024 bit)
//   - 快照控制: capture_en + SNAPSHOT_LEN 限制总帧数
//   - partial flush: 快照结束时 count<5 的残帧正确输出
//   - seq 号: 每帧递增, 用于 PC 端丢帧检测
//   - 时序印记: 48-bit 全局时间戳 (ts[15:0] in HDR + TS[31:0] in Beat1)
////////////////////////////////////////////////////////////////////////////////

// ============================================================================
// adc_packer_512 — 5-pair / 2-beat compact packer (93.75% efficiency)
//
// Input:  I[95:0] + Q[95:0] @ 125MHz  (12 ADC samples × 8bit per 96b word)
// Output: 512-bit AXI-Stream burst (2 beats per 5 pairs)
//
// Beat 0: [511:480] HDR[31:0]  {sync=1'b1, seq[14:0], ts[15:0]}
//         [479:384] I0, [383:288] Q0, [287:192] I1, [191:96] Q1, [95:0] I2
// Beat 1: [511:416] Q2, [415:320] I3, [319:224] Q3, [223:128] I4, [127:32] Q4
//         [ 31: 0] TS[31:0]  (timestamp high word)
//
// tlast=1 on Beat 1 marks the 2-beat frame boundary.
// 8-entry circular buffer prevents data loss during burst stall.
// ============================================================================

module adc_packer_512 #(
    parameter integer SNAPSHOT_LEN = 65536
)(
    input  wire         clk_125,
    input  wire         rst_n,

    input  wire [95:0]  data_i_bus,
    input  wire [95:0]  data_q_bus,
    input  wire         adc_vld_i,
    input  wire         adc_vld_q,
    input  wire         adc_ready,

    input  wire         capture_en,

    output wire [511:0] m_axis_tdata,
    output wire [63:0]  m_axis_tkeep,
    output wire         m_axis_tvalid,
    output wire         m_axis_tlast,
    input  wire         m_axis_tready,
    output wire         capture_done
);

    // =========================================================================
    // 8-entry circular buffer
    // =========================================================================
    reg [95:0]  ibuf [0:7];
    reg [95:0]  qbuf [0:7];
    reg [2:0]   wr_ptr, rd_ptr;
    reg [3:0]   count;                       // 0..8

    wire        buf_push  = data_valid && (count < 4'd8);
    wire        buf_has5  = (count >= 4'd5);

    // =========================================================================
    // Counters
    // =========================================================================
    reg [63:0]  timestamp_cnt;
    reg [14:0]  seq_cnt;
    reg [31:0]  burst_cnt;
    reg         is_capturing;
    reg         stopped;

    localparam OUT_IDLE  = 2'd0;
    localparam OUT_BEAT0 = 2'd1;
    localparam OUT_BEAT1 = 2'd2;

    reg [1:0]   out_state;
    reg [511:0] tdata_reg;
    reg         tvalid_reg;
    reg         tlast_reg;

    wire        data_valid = adc_ready && adc_vld_i && adc_vld_q;

    // =========================================================================
    // FSM
    // =========================================================================
    always @(posedge clk_125) begin
        if (!rst_n) begin
            is_capturing   <= 1'b0;
            stopped        <= 1'b0;
            burst_cnt      <= 32'd0;
            seq_cnt        <= 15'd0;
            timestamp_cnt  <= 64'd0;
            wr_ptr         <= 3'd0;
            rd_ptr         <= 3'd0;
            count          <= 4'd0;
            out_state      <= OUT_IDLE;
            tdata_reg      <= 512'd0;
            tvalid_reg     <= 1'b0;
            tlast_reg      <= 1'b0;
        end else begin

            // ---- Capture control ----
            if (!capture_en) begin
                is_capturing <= 1'b0;
                stopped      <= 1'b0;
            end else if (!is_capturing && capture_en && data_valid) begin
                is_capturing  <= 1'b1;
                burst_cnt     <= 32'd0;
                timestamp_cnt <= 64'd0;
                seq_cnt       <= 15'd0;
            end

            // ---- Push incoming data into circular buffer ----
            if (buf_push) begin
                ibuf[wr_ptr] <= data_i_bus;
                qbuf[wr_ptr] <= data_q_bus;
                wr_ptr       <= wr_ptr + 1'b1;
                count        <= count + 1'b1;

                if (is_capturing && !stopped) begin
                    if (burst_cnt == SNAPSHOT_LEN - 1) begin
                        is_capturing <= 1'b0;
                    end else begin
                        burst_cnt <= burst_cnt + 1'b1;
                    end
                end
            end

            // ---- Output FSM ----
            case (out_state)

                OUT_IDLE: begin
                    tvalid_reg <= 1'b0;
                    tlast_reg  <= 1'b0;

                    if (buf_has5 && m_axis_tready) begin
                        // Build Beat 0 from rd_ptr (gate with tready to avoid premature valid)
                        tdata_reg <= {
                            1'b1,
                            seq_cnt[14:0],
                            timestamp_cnt[15:0],
                            ibuf[rd_ptr],     qbuf[rd_ptr],
                            ibuf[rd_ptr+1],   qbuf[rd_ptr+1],
                            ibuf[rd_ptr+2]
                        };
                        tvalid_reg <= 1'b1;
                        tlast_reg  <= 1'b0;
                        out_state  <= OUT_BEAT0;
                    end else if (!is_capturing && count > 0 && burst_cnt >= SNAPSHOT_LEN - 1) begin
                        // Flush partial frame: build beat with whatever is in buffer
                        // (count < 5, pad missing with zeros)
                        tdata_reg <= {
                            1'b1,
                            seq_cnt[14:0],
                            timestamp_cnt[15:0],
                            (count>=1) ? ibuf[rd_ptr]   : 96'd0,
                            (count>=1) ? qbuf[rd_ptr]   : 96'd0,
                            (count>=2) ? ibuf[rd_ptr+1] : 96'd0,
                            (count>=2) ? qbuf[rd_ptr+1] : 96'd0,
                            (count>=3) ? ibuf[rd_ptr+2] : 96'd0
                        };
                        tvalid_reg <= 1'b1;
                        tlast_reg  <= (count <= 3);
                        out_state  <= (count <= 3) ? OUT_IDLE : OUT_BEAT0;
                        if (count <= 3) begin
                            rd_ptr  <= rd_ptr + count;
                            count   <= 4'd0;
                            stopped <= 1'b1;
                        end
                    end
                end

                OUT_BEAT0: begin
                    if (m_axis_tready) begin
                        // Build Beat 1
                        tdata_reg <= {
                            qbuf[rd_ptr+2],
                            ibuf[rd_ptr+3],   qbuf[rd_ptr+3],
                            ibuf[rd_ptr+4],   qbuf[rd_ptr+4],
                            timestamp_cnt[47:16]
                        };
                        tvalid_reg <= 1'b1;
                        tlast_reg  <= 1'b1;
                        out_state  <= OUT_BEAT1;
                    end
                end

                OUT_BEAT1: begin
                    if (m_axis_tready) begin
                        // Frame complete — pop 5 entries
                        rd_ptr      <= rd_ptr + 3'd5;
                        count       <= count - 4'd5;
                        seq_cnt     <= seq_cnt + 1'b1;
                        timestamp_cnt <= timestamp_cnt + 64'd5;

                        // Check if capture is done and this was the last frame
                        if (!is_capturing && count <= 4'd5) begin
                            stopped <= 1'b1;
                        end

                        // Back to IDLE (may immediately re-enter BEAT0 if buf_has5)
                        tvalid_reg <= 1'b0;
                        tlast_reg  <= 1'b0;
                        out_state  <= OUT_IDLE;
                    end
                end

            endcase
        end
    end

    // =========================================================================
    // Outputs
    // =========================================================================
    assign m_axis_tdata  = tdata_reg;
    assign m_axis_tvalid = tvalid_reg;
    assign m_axis_tlast  = tlast_reg;
    assign m_axis_tkeep  = 64'hFFFF_FFFF_FFFF_FFFF;
    assign capture_done  = stopped;

endmodule
