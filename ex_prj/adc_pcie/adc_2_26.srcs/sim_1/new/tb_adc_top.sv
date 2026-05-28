`timescale 1ps / 1ps

module tb_adc_top();

    // --- 1. 信号定义 ---
    reg  sys_rst_n;
    reg  adc_dclk_p, adc_dclk_n;
    wire adc_spi_cs_n, adc_spi_sclk, adc_spi_sdi;
    reg  adc_spi_sdo = 1'b0;
    
    reg  [7:0] adc_di_p,  adc_di_n;
    reg  [7:0] adc_did_p, adc_did_n;
    reg  [7:0] adc_dq_p,  adc_dq_n;
    reg  [7:0] adc_dqd_p, adc_dqd_n;
    
    wire adc_ready;
    wire adc_cal;

    // --- 2. 修改 seed 声明 (直接赋值) ---
    integer global_seed;
    initial begin
        global_seed = 12345;
    end

    // --- 3. 模拟真实时钟 (375MHz, 周期 2666ps) ---
    // 模拟占空比失真 (DCD) 与随机抖动 (Jitter)
    initial begin
        adc_dclk_p = 0; adc_dclk_n = 1;
        forever begin
            #(1280 + $dist_uniform(global_seed, -20, 20)) adc_dclk_p = 1; adc_dclk_n = 0;
            #(1386 + $dist_uniform(global_seed, -20, 20)) adc_dclk_p = 0; adc_dclk_n = 1;
        end
    end

    // --- 4. 实例化待测模块 ---
    adc_top u_dut (
        .sys_rst_n      (sys_rst_n),
        .adc_dclk_p     (adc_dclk_p), .adc_dclk_n (adc_dclk_n),
        .adc_spi_cs_n   (adc_spi_cs_n), .adc_spi_sclk (adc_spi_sclk),
        .adc_spi_sdi    (adc_spi_sdi), .adc_spi_sdo  (adc_spi_sdo),
        .adc_cal        (adc_cal),
        .adc_di_p(adc_di_p), .adc_di_n(adc_di_n),
        .adc_did_p(adc_did_p), .adc_did_n(adc_did_n),
        .adc_dq_p(adc_dq_p), .adc_dq_n(adc_dq_n),
        .adc_dqd_p(adc_dqd_p), .adc_dqd_n(adc_dqd_n),
        .adc_ready      (adc_ready),
        .bp_ready_i     (1'b1),
        .bp_ready_q     (1'b1)
    );

    // --- 5. 模拟 32 路数据输入 (数据源为全周期翻转，加入相位偏移) ---
    genvar i, j;
    generate
        for (j = 0; j < 4; j = j + 1) begin : gen_bank_sim
            for (i = 0; i < 8; i = i + 1) begin : gen_lane_sim
                localparam idx = j * 8 + i;
                
                // 模拟每路 PCB 布线延迟 (Skew)：0 ~ 1200ps 均匀分布
            // 1.5Gbps 一位(UI)约 666ps，因此模拟了超过 1 个 UI 的偏差
                real pcb_skew;
                initial pcb_skew = (j * 150) + (i * 20) + $dist_uniform(global_seed, 0, 100);

                reg lane_data_raw;
                always @(*) begin
                    // 使用全周期翻转 (0101 训练码型)
                    // 叠加 PCB Skew 延迟
                    #(pcb_skew); 
                    lane_data_raw = ~adc_dclk_p;
                    
                    // 模拟采样时钟边沿的非确定性（边沿 40ps 内可能采样错误）
                    // 可用来验证 ERR_THRESHOLD 逻辑
                    if ($dist_uniform(global_seed, 0, 1000) < 5) begin
                        lane_data_raw = $random % 2; 
                    end
                end

                // 差分对分配
                always @(*) begin
                    case(j)
                        0: adc_di_p[i] = lane_data_raw;  1: adc_did_p[i] = lane_data_raw;
                        2: adc_dq_p[i] = lane_data_raw;  3: adc_dqd_p[i] = lane_data_raw;
                    endcase
                    case(j)
                        0: adc_di_n[i] = ~lane_data_raw; 1: adc_did_n[i] = ~lane_data_raw;
                        2: adc_dq_n[i] = ~lane_data_raw; 3: adc_dqd_n[i] = ~lane_data_raw;
                    endcase
                end
            end
        end
    endgenerate

    // --- 6.1 校准触发次数检查 ---
    integer cal_rise_cnt;
    reg adc_cal_d;
    always @(posedge u_dut.adc_clk_125m_out) begin
        if (!u_dut.mmcm_locked) begin
            cal_rise_cnt <= 0;
            adc_cal_d <= 1'b0;
        end else begin
            adc_cal_d <= adc_cal;
            if (adc_cal && !adc_cal_d)
                cal_rise_cnt <= cal_rise_cnt + 1;
        end
    end

    // --- 6. 主测试流程 ---
    initial begin
        sys_rst_n = 0;
        #5000 sys_rst_n = 1; // 等待时钟稳定
        $display("[%0t] >>> 实战仿真开始，复位已释放。", $time);

        // 判断准位
        fork
            begin
                wait(adc_ready == 1'b1);
                $display("[%0t] >>> [SUCCESS] 32路通道全部对准完成。", $time);
            end
            begin
                // 算法：512 个 Tap，每个 Tap 采样 128 次，约需要 1ms 实时时间
                #2_000_000_000; // 2ms 超时
                $display("[%0t] >>> [FAILURE] 仿真超时，判决失败。", $time);
                $finish;
            end
        join

        #50000;
        $display("-------------------------------------------");
        $display(">>> 各通道测试结果汇总 (零点即表示成功):");
        for(integer k=0; k<32; k=k+8)
            $display("CH%0d-CH%0d: %d, %d, %d, %d, %d, %d, %d, %d", 
                k, k+7, u_dut.auto_tap_val[k],   u_dut.auto_tap_val[k+1], u_dut.auto_tap_val[k+2], u_dut.auto_tap_val[k+3],
                        u_dut.auto_tap_val[k+4], u_dut.auto_tap_val[k+5], u_dut.auto_tap_val[k+6], u_dut.auto_tap_val[k+7]);
        $display("-------------------------------------------");

        if (cal_rise_cnt == 1)
            $display("[CHECK] PASS: adc_cal rising edge count = %0d", cal_rise_cnt);
        else
            $display("[CHECK] FAIL: adc_cal rising edge count = %0d (expected 1)", cal_rise_cnt);
        
        $finish;
    end

endmodule

