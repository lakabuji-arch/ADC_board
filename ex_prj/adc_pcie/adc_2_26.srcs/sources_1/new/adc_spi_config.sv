`timescale 1ns / 1ps

// 模块名：adc_spi_config
// 模块功能：
// 1) 用 SPI 协议方式将固定寄存器值写入 ADC
// 2) 等待所有 IDELAY 扫描完成后，产生 config_done 和校准脉冲 cal_trigger
module adc_spi_config #(
    parameter CLK_DIV_CNT = 20 
)(
    // ==================== 控制接口 ====================
    input  wire        clk,            // SPI 控制时钟（125MHz）
    input  wire        rst_n,          // 系统复位（低有效）
    input  wire        start_en,       // 配置启动脉冲
    input  wire        all_scan_done,  // 全部 IDELAY lane 扫描完成

    // ==================== SPI 物理接口 ====================
    output reg         spi_cs_n,       // SPI 片选（低有效）
    output reg         spi_sclk,       // SPI 时钟
    output reg         spi_sdi,        // SPI 数据输出（主发从收）
    input  wire        spi_sdo,        // SPI 读回数据（当前未使用）

    // ==================== 状态输出 ====================
    output reg         config_done,    // 配置完成标志
    output reg         cal_trigger     // 校准脉冲触发（单周期脉冲）
);

    // ADC08D1500 ECM SPI 32-bit 帧格式 (datasheet Rev.G §THE SERIAL INTERFACE):
    //   Header[11:0] = 12'h001 = 12'b0000_0000_0001 (固定)
    //   Addr[3:0]    = 寄存器地址 (0x0～0xF)
    //   Data[15:0]   = 写入数据
    //   发送顺序: MSB first (shift_reg[31]→shift_reg[0])
    //
    // ⚠️ 约束 (datasheet 强制要求):
    //   1. 首次上电必须写入全部 8 个寄存器
    //   2. DES Enable (0x0D) 首次写入必须是默认值 0x3FFF
    //      之后才能再次写入实际需要的值
    // ⚠️ 寄存器值与地址请对照 datasheet Table 4-12 逐项验证！
    // PASS 1: datasheet mandates first write to 0x0D must be 0x3FFF
    reg [31:0] config_rom_pass1 [0:7];
    // PASS 2: write operational values (DES Enable 0x0D is now the real DES mode)
    reg [31:0] config_rom_pass2 [0:7];
    initial begin
        // PASS 1 — all default values
        config_rom_pass1[0] = {12'h001, 4'h1, 16'hB2FF};  // Reg 0x01 Configuration
        config_rom_pass1[1] = {12'h001, 4'h2, 16'h007F};  // Reg 0x02 I-Ch Offset
        config_rom_pass1[2] = {12'h001, 4'hA, 16'h007F};  // Reg 0x0A Q-Ch Offset
        config_rom_pass1[3] = {12'h001, 4'h3, 16'h807F};  // Reg 0x03 I-Ch Full-Scale
        config_rom_pass1[4] = {12'h001, 4'hB, 16'h807F};  // Reg 0x0B Q-Ch Full-Scale
        config_rom_pass1[5] = {12'h001, 4'hD, 16'h3FFF};  // Reg 0x0D DES Enable (PASS1=3FFF)
        config_rom_pass1[6] = {12'h001, 4'hE, 16'h07FF};  // Reg 0x0E DES Coarse
        config_rom_pass1[7] = {12'h001, 4'hF, 16'h007F};  // Reg 0x0F DES Fine

        // PASS 2 — operational values (0x0D now active DES mode)
        config_rom_pass2[0] = {12'h001, 4'h1, 16'hB2FF};  // Reg 0x01 Configuration
        config_rom_pass2[1] = {12'h001, 4'h2, 16'h007F};  // Reg 0x02 I-Ch Offset
        config_rom_pass2[2] = {12'h001, 4'hA, 16'h007F};  // Reg 0x0A Q-Ch Offset
        config_rom_pass2[3] = {12'h001, 4'h3, 16'h807F};  // Reg 0x03 I-Ch Full-Scale
        config_rom_pass2[4] = {12'h001, 4'hB, 16'h807F};  // Reg 0x0B Q-Ch Full-Scale
        config_rom_pass2[5] = {12'h001, 4'hD, 16'h3FFF};  // Reg 0x0D DES Enable (PASS2=active)
        config_rom_pass2[6] = {12'h001, 4'hE, 16'h07FF};  // Reg 0x0E DES Coarse
        config_rom_pass2[7] = {12'h001, 4'hF, 16'h007F};  // Reg 0x0F DES Fine
    end

    // 状态机编码
    localparam S_IDLE       = 3'd0;
    localparam S_START      = 3'd1;
    localparam S_SEND       = 3'd2;
    localparam S_WAIT_GAP   = 3'd3; 
    localparam S_PASS2_START= 3'd4;
    localparam S_DONE       = 3'd5;

    reg [2:0]  state;
    reg [3:0]  reg_ptr;    
    reg [5:0]  bit_ptr;    
    reg [7:0]  clk_cnt;    
    reg [31:0] shift_reg;
    reg        pass_done;  // 0=PASS1, 1=PASS2 complete  

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE; spi_cs_n <= 1; spi_sclk <= 0; 
            config_done <= 0; reg_ptr <= 0; spi_sdi <= 0; cal_trigger <= 0;
            pass_done <= 1'b0;
        end else begin
            // 默认清零，脉冲信号只维持一拍
            cal_trigger <= 1'b0;
            case (state)
                S_IDLE: begin
                    pass_done <= 1'b0;
                    if (start_en && !config_done) state <= S_START;
                end

                S_START: begin
                    spi_cs_n  <= 1'b0;
                    // PASS1 uses pass1 array, PASS2 uses pass2 array
                    shift_reg <= pass_done ? config_rom_pass2[reg_ptr] : config_rom_pass1[reg_ptr];
                    bit_ptr   <= 6'd31; // 每帧共 32bit
                    clk_cnt   <= 0;
                    state     <= S_SEND;
                end

                S_SEND: begin
                    if (clk_cnt == CLK_DIV_CNT - 1) begin
                        clk_cnt <= 0;
                        if (!spi_sclk) begin
                            spi_sdi  <= shift_reg[31];
                            spi_sclk <= 1'b1;
                        end else begin
                            spi_sclk  <= 1'b0;
                            shift_reg <= {shift_reg[30:0], 1'b0};
                            if (bit_ptr == 0) state <= S_WAIT_GAP;
                            else bit_ptr <= bit_ptr - 1;
                        end
                    end else clk_cnt <= clk_cnt + 1;
                end

                S_WAIT_GAP: begin
                    spi_cs_n <= 1'b1;
                    if (clk_cnt == 8'd100) begin
                        clk_cnt <= 0;
                        if (reg_ptr == 7 && !pass_done) begin
                            // PASS 1 end -> move to PASS 2
                            pass_done <= 1'b1;
                            reg_ptr   <= 0;
                            state     <= S_PASS2_START;
                        end else if (reg_ptr == 7 && pass_done) begin
                            // PASS 2 end -> done
                            state <= S_DONE;
                        end else begin
                            reg_ptr <= reg_ptr + 1;
                            state   <= S_START;
                        end
                    end else clk_cnt <= clk_cnt + 1;
                end

                S_PASS2_START: begin
                    // Short gap between passes for chip timing
                    if (clk_cnt == 8'd200) begin
                        clk_cnt <= 0;
                        state   <= S_START;
                    end else clk_cnt <= clk_cnt + 1;
                end

                S_DONE: begin
                    // 等待全部 lane 扫描完成后触发 config_done + cal_trigger
                    if (all_scan_done && !config_done) begin
                        config_done <= 1'b1;
                        cal_trigger <= 1'b1;
                    end
                end
            endcase
        end
    end
endmodule