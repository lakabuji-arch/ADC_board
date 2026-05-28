`timescale 1ns / 1ps

// 模块名：adc_top
// 模块功能：
// 1) 由 ADC DCLK 生成 375M/300M/125M 时钟域
// 2) 将 32 路差分数据通过 IBUFDS + IDELAYE3 + IDDRE1 完成采集
// 3) 自动扫描 IDELAY 延时 tap 值，通过 SPI 配置 ADC 芯片
// 4) 发出 CAL 脉冲，采集数据对齐输出 I/Q 96bit@125MHz 总线
module adc_top(
    input wire          sys_rst_n,      // 系统复位输入，低有效

    // ==================== 1) ADC 时钟接口 ====================
    input wire          adc_dclk_p, adc_dclk_n,

    // ==================== 2) ADC SPI 接口 ====================
    output wire         adc_spi_cs_n, adc_spi_sclk, adc_spi_sdi,
    input  wire         adc_spi_sdo,
    output reg          adc_cal,        // ADC 校准脉冲输出

    // ==================== 3) ADC 数据接口 ====================
    input wire[7:0]     adc_di_p,  adc_di_n,
    input wire[7:0]     adc_did_p, adc_did_n,
    input wire[7:0]     adc_dq_p,  adc_dq_n,
    input wire[7:0]     adc_dqd_p, adc_dqd_n,

    // ==================== 4) 模块状态输出 ====================
    output wire         adc_ready,              // ADC 及系统就绪标志
    output wire         adc_clk_125m_out,       // 输出域 125MHz 时钟
    output wire [95:0]  adc_data_i_out,         // I 路 96bit 数据
    output wire [95:0]  adc_data_q_out,         // Q 路 96bit 数据
    output wire         adc_vld_i_out,          // I 路数据有效
    output wire         adc_vld_q_out,          // Q 路数据有效
    input  wire         bp_ready_i,             // I 路下游反压 (1=可接收)
    input  wire         bp_ready_q              // Q 路下游反压 (1=可接收)
);

    // ===== 1) 内部信号定义 =====
    wire clk_125m, clk_375m, clk_ref_300m, mmcm_locked;
    wire [31:0] raw_q1, raw_q2;
    wire [8:0]  auto_tap_val [31:0];
    wire [31:0] auto_load_en, scan_done_all, degraded_lane;
    wire [7:0]  p_pins [3:0], n_pins [3:0];
    wire        spi_config_done, cal_trigger;
    reg         cal_trigger_d;
    // ADC08D1500 CAL pulse: min 4 DCLK cycles (~10.7ns). 500 cycles @125MHz = 4µs safe margin
    localparam [19:0] CAL_PULSE_CYCLES = 20'd500;

`ifdef SYNTHESIS
    localparam string IDELAY_SIM_DEVICE = "ULTRASCALE_PLUS";
`else
    localparam string IDELAY_SIM_DEVICE = "ULTRASCALE";
`endif

    // ===== 2) 时钟生成模块 =====
    clk_wiz_1 u_clock_gen (
        .clk_in1_p(adc_dclk_p),    // ADC DCLK 正
        .clk_in1_n(adc_dclk_n),    // ADC DCLK 负
        .clk_out1(clk_375m),       // 高速时钟，供 IDDR 使用
        .clk_out2(clk_ref_300m),   // IDELAYCTRL 参考时钟
        .clk_out3(clk_125m),       // 输出/控制逻辑时钟
        .reset(~sys_rst_n),        // 时钟模块复位
        .locked(mmcm_locked)       // 锁定指示
    );

    // ===== 3) IDELAYCTRL 复位同步逻辑 =====
    // 采用 16 级移位确保同步
    // 300MHz 周期为 3.33ns，16 级延时 = 53.3ns，满足 Xilinx 规定 >=50ns 复位要求
    (* ASYNC_REG = "TRUE" *) reg [15:0] rst_300_sync = 16'hFFFF;
    always @(posedge clk_ref_300m or negedge mmcm_locked) begin
        if (!mmcm_locked)
            rst_300_sync <= 16'hFFFF;
        else
            rst_300_sync <= {rst_300_sync[14:0], 1'b0};
    end
    wire idelay_rst_300 = rst_300_sync[15]; // IDELAYCTRL 需要 50ns 的复位脉冲

    // 每个 I/O Bank 需要一个 IDELAYCTRL，共 4 个
    wire [1:0] idelay_rdy_vec;
    wire       idelay_all_ready = &idelay_rdy_vec;

    (* IODELAY_GROUP = "ADC_BANK_66" *)
    IDELAYCTRL #( .SIM_DEVICE(IDELAY_SIM_DEVICE) ) u_ctrl_66 (
        .RDY(idelay_rdy_vec[0]), .REFCLK(clk_ref_300m), .RST(idelay_rst_300)
    );

    (* IODELAY_GROUP = "ADC_BANK_67" *)
    IDELAYCTRL #( .SIM_DEVICE(IDELAY_SIM_DEVICE) ) u_ctrl_67 (
        .RDY(idelay_rdy_vec[1]), .REFCLK(clk_ref_300m), .RST(idelay_rst_300)
    );

    // ===== 4) CAL 脉冲发生逻辑 =====
    // SPI 配置完成后触发校准脉冲
    reg [19:0] cal_cnt;
    always @(posedge clk_125m) begin
        if (!mmcm_locked) begin
            adc_cal <= 1'b0;
            cal_cnt <= 0;
            cal_trigger_d <= 1'b0;
        end else begin
            cal_trigger_d <= cal_trigger;
            if ((cal_trigger && !cal_trigger_d) && cal_cnt == 0) begin
                adc_cal <= 1'b1;
                cal_cnt <= CAL_PULSE_CYCLES; // CAL 脉冲维持计数
            end else if (cal_cnt > 0) begin
                cal_cnt <= cal_cnt - 1;
                adc_cal <= 1'b1;
            end else begin
                adc_cal <= 1'b0;
            end
        end
    end

    // ===== 5) 375MHz 复位同步 =====
    (* ASYNC_REG = "TRUE" *) reg rst_375_m1 = 1'b1, rst_375_m2 = 1'b1;
    reg io_reset_sync = 1'b1;

    always @(posedge clk_125m)
        io_reset_sync <= !mmcm_locked || !idelay_all_ready;

    always @(posedge clk_375m) begin
        rst_375_m1 <= io_reset_sync;
        rst_375_m2 <= rst_375_m1;
    end

    // ===== 6) 32 路数据采集通路 =====
    assign p_pins[0] = adc_di_p;   assign n_pins[0] = adc_di_n;
    assign p_pins[1] = adc_did_p;  assign n_pins[1] = adc_did_n;
    assign p_pins[2] = adc_dq_p;   assign n_pins[2] = adc_dq_n;
    assign p_pins[3] = adc_dqd_p;  assign n_pins[3] = adc_dqd_n;

    genvar i, j;
    generate
        for (j = 0; j < 4; j = j + 1) begin : gen_sub
            for (i = 0; i < 8; i = i + 1) begin : gen_lane
                localparam idx = j * 8 + i;
                wire ibuf_o, idelay_o;
                // 差分缓冲
                IBUFDS u_buf ( .I(p_pins[j][i]), .IB(n_pins[j][i]), .O(ibuf_o) );
                // 当前 lane 的 IDELAY 自动扫描
                idelay_auto_scan u_scan (
                    .clk(clk_125m),                  // 扫描器时钟
                    .rst(io_reset_sync),             // 扫描复位
                    .raw_q1(raw_q1[idx]),            // DDR 采样高位 q1
                    .raw_q2(raw_q2[idx]),            // DDR 采样低位 q2
                    .scan_done(scan_done_all[idx]),  // 当前 lane 扫描完成
                    .cntvaluein(auto_tap_val[idx]),  // 最优延时 tap
                    .load(auto_load_en[idx]),        // 装载脉冲
                    .degraded(degraded_lane[idx])    // 眼图不足标志
                );
                (* IODELAY_GROUP = (j < 2) ? "ADC_BANK_66" : "ADC_BANK_67" *)
                IDELAYE3 #( .DELAY_TYPE("VAR_LOAD"), .DELAY_FORMAT("COUNT"), .SIM_DEVICE(IDELAY_SIM_DEVICE) ) u_dly (
                    .IDATAIN(ibuf_o),                 // 原始数据输入
                    .DATAOUT(idelay_o),               // 延时后输出
                    .CLK(clk_125m),                   // 控制时钟
                    .LOAD(auto_load_en[idx]),         // 装载 tap
                    .CNTVALUEIN(auto_tap_val[idx]),   // tap 值输入
                    .EN_VTC(scan_done_all[idx]),      // 扫描完成后使能动态调节
                    .RST(io_reset_sync),              // IDELAY 复位
                    .CASC_IN(1'b0), .CASC_RETURN(1'b0), .DATAIN(1'b0), .INC(1'b0), .CE(1'b0)
                );
                // DDR 采样器 q1/q2 输出
                IDDRE1 #( .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), .IS_CB_INVERTED(1'b1) ) u_iddr (
                    .D(idelay_o),      // 延时后数据
                    .Q1(raw_q1[idx]),  // 第一拍数据
                    .Q2(raw_q2[idx]),  // 第二拍数据
                    .C(clk_375m),      // 正时钟
                    .CB(clk_375m),     // 反时钟端，此处使用同相
                    .R(rst_375_m2)     // 复位
                );
            end
        end
    endgenerate

    // ===== 7) SPI 配置控制器 =====
    adc_spi_config #( .CLK_DIV_CNT(20) ) u_spi_cfg (
        .clk(clk_125m),                    // SPI 时钟源
        .rst_n(mmcm_locked),               // SPI 控制器复位释放
        .start_en(idelay_all_ready),       // 等待 IDELAYCTRL ready 后开始配置
        .all_scan_done(&scan_done_all),    // 全部 lane 扫描完成
        .spi_cs_n(adc_spi_cs_n),           // SPI 片选
        .spi_sclk(adc_spi_sclk),           // SPI 时钟
        .spi_sdi(adc_spi_sdi),             // SPI 输出
        .spi_sdo(adc_spi_sdo),             // SPI 输入
        .config_done(spi_config_done),     // SPI 配置完成
        .cal_trigger(cal_trigger)          // 触发 CAL 脉冲
    );

    // ===== 8) 输出级 Gearbox 转换 =====
    assign adc_ready = spi_config_done && (&scan_done_all);
    assign adc_clk_125m_out = clk_125m;

    // ADC08D1500 中 DId/DQd 比 DI/DQ 早 1 个输入采样周期；这里每个 16bit 半字按 {较早的 Dd, 较晚的 D} 排列，低 16bit 对应 q1，高 16bit 对应 q2。

    gearbox_32_to_96 u_gb_i (
        .clk_375(clk_375m),                           // 高速时钟
        .clk_125(clk_125m),                           // 低速时钟
        .rst(!adc_ready),                             // 未就绪时复位
        .data_in({raw_q2[15:0], raw_q1[15:0]}),       // I 路 32bit 原始拼接
        .bp_ready(bp_ready_i),                        // 下游反压
        .data_out(adc_data_i_out),                    // I 路 96bit 输出
        .data_vld_125(adc_vld_i_out)                  // I 路有效
    );
    gearbox_32_to_96 u_gb_q (
        .clk_375(clk_375m),                           // 高速时钟
        .clk_125(clk_125m),                           // 低速时钟
        .rst(!adc_ready),                             // 未就绪时复位
        .data_in({raw_q2[31:16], raw_q1[31:16]}),     // Q 路 32bit 原始拼接
        .bp_ready(bp_ready_q),                        // 下游反压
        .data_out(adc_data_q_out),                    // Q 路 96bit 输出
        .data_vld_125(adc_vld_q_out)                  // Q 路有效
    );

endmodule
