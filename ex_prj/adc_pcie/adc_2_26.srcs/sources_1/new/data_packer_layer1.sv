`timescale 1ns / 1ps

// 模块名：data_packer_layer1
// 模块功能：
// 1) 将 I/Q 两路 96bit 数据打包为 256bit AXI-Stream 数据
// 2) 每拍携带 64bit 时间戳，格式为 {timestamp, Q, I}
// 3) 在 SNAPSHOT_LEN 拍后输出最后一拍 m_axis_tlast
module data_packer_layer1 #(
    parameter integer SNAPSHOT_LEN = 65536 
)(
    // ==================== 时钟与复位 ====================
    input  wire         clk_125,       // 工作时钟
    input  wire         rst_n,         // 低有效复位
    
    // ==================== ADC 数据流输入 ====================
    input  wire [95:0]  data_i_bus,    // I 路数据输入
    input  wire [95:0]  data_q_bus,    // Q 路数据输入
    input  wire         adc_vld_i,     // I 路逐拍有效 (来自清洗器)
    input  wire         adc_vld_q,     // Q 路逐拍有效 (来自清洗器)
    input  wire         adc_ready,     // ADC 系统就绪 (SPI 完成后恒=1)
    
    // ==================== 控制输入 ====================
    input  wire         capture_en,    // 抓取使能
    
    // ==================== AXIS 输出 ====================
    output reg  [255:0] m_axis_tdata,  // 输出打包数据
    output reg          m_axis_tvalid, // 输出有效
    output reg          m_axis_tlast,  // 输出末拍
    input  wire         m_axis_tready, // 下游可接收 (URAM 写通道)
    output wire         capture_done   // 抓取完成
);

    reg [63:0] timestamp_cnt;
    reg [31:0] burst_cnt;
    reg        is_capturing;

    // ADC 数据有效：adc_ready 恒为 1 (SPI完成后)，逐拍门控用 adc_vld_i & adc_vld_q
    wire data_valid = adc_ready && adc_vld_i && adc_vld_q;

    // ===== 1) 带背压的捕获状态机 =====
    always @(posedge clk_125) begin
        if (!rst_n) begin
            is_capturing  <= 1'b0;
            burst_cnt     <= 32'd0;
            timestamp_cnt <= 64'd1;
            m_axis_tdata  <= 256'd0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast  <= 1'b0;
        end else begin
            // 捕获使能关闭后, 时间戳回1, 状态回空闲
            if (!capture_en) begin
                is_capturing  <= 1'b0;
                timestamp_cnt <= 64'd1;
                m_axis_tvalid <= 1'b0;
                m_axis_tlast  <= 1'b0;
            end
            // 启动：第一拍在 capture_en 上升沿立即输出 (零延迟启动)
            else if (!is_capturing && capture_en && data_valid) begin
                is_capturing  <= 1'b1;
                burst_cnt     <= 32'd1;
                m_axis_tvalid <= 1'b1;
                m_axis_tdata  <= {timestamp_cnt, data_q_bus, data_i_bus};
                timestamp_cnt <= timestamp_cnt + 1'b1;
            end
            // 捕获中：tready 握手控制数据推进
            else if (is_capturing) begin
                if (m_axis_tready || !m_axis_tvalid) begin
                    // 下游已接收上一拍 (或首拍待发), 推进到下一数据
                    if (burst_cnt == SNAPSHOT_LEN) begin
                        // 已发完 SNAPSHOT_LEN 拍, 结束
                        m_axis_tvalid <= 1'b0;
                        m_axis_tlast  <= 1'b0;
                        is_capturing  <= 1'b0;
                    end else begin
                        m_axis_tvalid <= 1'b1;
                        m_axis_tdata  <= {timestamp_cnt, data_q_bus, data_i_bus};
                        m_axis_tlast  <= (burst_cnt == SNAPSHOT_LEN - 1);
                        burst_cnt     <= burst_cnt + 1'b1;
                        timestamp_cnt <= timestamp_cnt + 1'b1;
                    end
                end
                // else: tready=0 且 tvalid=1 → 保持当前数据不变, 等待下游
            end
        end
    end
    
    // 末拍同周期给出 done，避免跨周期判断
    assign capture_done = (m_axis_tvalid && m_axis_tlast);

endmodule