`timescale 1ns / 1ps

// 模块名：axis_width_converter_256_to_64
// 模块功能：
// 1) 将上游每拍 256bit AXIS 数据拆分为连续 4 拍 64bit
// 2) 保证 tdata/tvalid/tlast 在输出端时序对齐
module axis_width_converter_256_to_64 (
    // ==================== 时钟与复位 ====================
    input  wire         clk,            // 工作时钟
    input  wire         rst_n,          // 低有效复位

    // ==================== 输入 AXIS（256bit） ====================
    input  wire [255:0] s_axis_tdata,   // 输入数据
    input  wire         s_axis_tvalid,  // 输入有效
    input  wire         s_axis_tlast,   // 输入末拍
    output reg          s_axis_tready,  // 本模块可接收

    // ==================== 输出 AXIS（64bit） ====================
    output reg  [63:0]  m_axis_tdata,   // 输出数据
    output reg          m_axis_tvalid,  // 输出有效
    output reg          m_axis_tlast,   // 输出末拍
    input  wire         m_axis_tready   // 下游可接收
);

    // ===== 1) 状态机 =====
    localparam IDLE = 1'b0;
    localparam SEND = 1'b1;

    reg         state;
    reg [1:0]   beat_cnt;   // 记录当前输出第几拍（0~3）
    reg [255:0] data_reg;   // 缓存的 256bit 输入数据
    reg         last_reg;   // 缓存输入的末拍标志

    // ===== 2) 位宽转换逻辑 =====
    always @(posedge clk) begin
        if (!rst_n) begin
            state         <= IDLE;
            beat_cnt      <= 2'd0;
            s_axis_tready <= 1'b1;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast  <= 1'b0;
            m_axis_tdata  <= 64'd0;
            data_reg      <= 256'd0;
            last_reg      <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    // 接收一个完整 256bit 数据包
                    if (s_axis_tvalid && s_axis_tready) begin
                        data_reg      <= s_axis_tdata;
                        last_reg      <= s_axis_tlast;
                        s_axis_tready <= 1'b0;
                        m_axis_tvalid <= 1'b1;
                        beat_cnt      <= 2'd0;
                        
                        // 第一拍：取低 64bit 直接发出
                        m_axis_tdata  <= s_axis_tdata[63:0];
                        m_axis_tlast  <= 1'b0;
                        state         <= SEND;
                    end
                end

                SEND: begin
                    // 下游 ready 时发送后续拍
                    if (m_axis_tready) begin
                        if (beat_cnt == 2'd3) begin
                            // 第 4 拍发送结束，回到空闲
                            beat_cnt      <= 2'd0;
                            s_axis_tready <= 1'b1;
                            m_axis_tvalid <= 1'b0;
                            m_axis_tlast  <= 1'b0;
                            state         <= IDLE;
                        end else begin
                            // 继续发送剩余数据片段
                            beat_cnt      <= beat_cnt + 1'b1;
                            
                            case(beat_cnt + 1'b1)
                                2'd1: m_axis_tdata <= data_reg[127:64];
                                2'd2: m_axis_tdata <= data_reg[191:128];
                                2'd3: m_axis_tdata <= data_reg[255:192];
                                default: m_axis_tdata <= 64'd0;
                            endcase

                            // 原始包最后一拍才置 tlast
                            m_axis_tlast  <= (last_reg && (beat_cnt == 2'd2));
                        end
                    end
                end
            endcase
        end
    end
endmodule
