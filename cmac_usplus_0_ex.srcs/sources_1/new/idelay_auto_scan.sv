`timescale 1ns / 1ps

// 模块名：idelay_auto_scan
// 模块功能：
// 1) 扫描 IDELAY tap（0~511），统计每个 tap 的采样错误率
// 2) 找到最大有效窗口，以窗口中心位置作为最优 tap
// 3) 输出 cntvaluein/load 供 IDELAYE3 装载，并拉高 scan_done
module idelay_auto_scan #(
    parameter integer ERR_THRESHOLD = 8,    // 每个 tap 采样次数, 增大抗噪声
    parameter integer MIN_EYE_WIDTH = 20    // 最小可接受窗口宽度
)(
    // ==================== 接口定义 ====================
    input  wire        clk,        // 扫描器时钟
    input  wire        rst,        // 高有效复位
    input  wire        raw_q1,     // DDR 采样器原始位 q1
    input  wire        raw_q2,     // DDR 采样器原始位 q2
    output reg         scan_done,  // 扫描完成标志
    output reg  [8:0]  cntvaluein, // 最优 tap 值
    output reg         load,       // 装载 tap 脉冲
    output reg         degraded    // 眼图窗口不足 (max_w < MIN_EYE_WIDTH)
);

    // ===== 1) 两级同步 + 模式匹配判断 =====
    reg q1_s1, q1_s2, q2_s1, q2_s2;
    always @(posedge clk) begin
        if (rst) begin
            {q1_s1, q1_s2, q2_s1, q2_s2} <= 4'b0;
        end else begin
            q1_s1 <= raw_q1; q1_s2 <= q1_s1;
            q2_s1 <= raw_q2; q2_s2 <= q2_s1;
        end
    end
    // 期望模式：q1=1 且 q2=0
    wire data_match = (q1_s2 === 1'b1 && q2_s2 === 1'b0);

    // ===== 2) 扫描状态机 =====
    // ST_SET/ST_WAIT：设置 tap 并等待稳定
    // ST_CHECK：对当前 tap 采样计数，累计错误
    // ST_CALC：计算最大窗口及最优 tap
    localparam ST_IDLE=0, ST_SET=1, ST_WAIT=2, ST_CHECK=3, ST_CALC=4, ST_DONE=5;
    reg [2:0] state = ST_IDLE;
    reg [8:0] tap_idx = 0;
    reg [7:0] wait_cnt=0,  error_cnt=0;
    reg [7:0] sample_cnt=0;

    reg [8:0] cur_start, best_start;
    reg [9:0] max_w;   // [9:0] prevents overflow when window width = 512
    reg       in_win;

    always @(posedge clk) begin
        if (rst) begin
            state <= ST_IDLE;
            scan_done <= 0;
            load <= 0;
            degraded <= 0;
            tap_idx <= 0;
            max_w <= 0;
            in_win <= 0;
            cur_start <= 0;
            best_start <= 0;
            cntvaluein <= 0;
        end else begin
            case(state)
                ST_IDLE: begin
                    tap_idx <= 0; 
                    max_w <= 0; 
                    in_win <= 0;
                    state <= ST_SET;
                end
                ST_SET: begin
                    load <= 1; 
                    cntvaluein <= tap_idx;
                    state <= ST_WAIT;
                end
                ST_WAIT: begin
                    load <= 0;
                    if (wait_cnt == 64) begin
                        wait_cnt <= 0; 
                        sample_cnt <= 0; 
                        error_cnt <= 0;
                        state <= ST_CHECK;
                    end else wait_cnt <= wait_cnt + 1;
                end
                ST_CHECK: begin
                    if (sample_cnt == 7'd127 ) begin
                        if (error_cnt <= ERR_THRESHOLD) begin 
                            if (!in_win) begin cur_start <= tap_idx; in_win <= 1; end
                            // 当前窗口变宽时刷新最优窗口记录
                            if (({1'b0, tap_idx} - {1'b0, (in_win ? cur_start : tap_idx)} + 10'd1) > max_w) begin
                                max_w <= {1'b0, tap_idx} - {1'b0, (in_win ? cur_start : tap_idx)} + 10'd1;
                                best_start <= in_win ? cur_start : tap_idx;
                            end
                        end else begin 
                            in_win <= 0;
                        end

                        if (tap_idx == 511) state <= ST_CALC;
                        else begin tap_idx <= tap_idx + 1; state <= ST_SET; end
                    end else begin
                        sample_cnt <= sample_cnt + 1;
                        if (!data_match) error_cnt <= error_cnt + 1;
                    end
                end
                ST_CALC: begin
                    if (max_w >= MIN_EYE_WIDTH) begin
                        cntvaluein <= best_start + (max_w >> 1);
                        degraded   <= 1'b0;
                    end else begin
                        cntvaluein <= 9'd0;
                        degraded   <= 1'b1;
                    end
                    load <= 1;
                    state <= ST_DONE;
                end
                ST_DONE: begin load <= 0; scan_done <= 1; end
                default: state <= ST_IDLE;
            endcase
        end
    end
endmodule