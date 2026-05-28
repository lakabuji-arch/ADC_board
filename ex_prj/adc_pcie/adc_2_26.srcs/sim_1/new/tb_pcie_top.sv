`timescale 1ns / 1ps

module tb_pcie_top();

    // --- 1. 定义主时钟 ---
    parameter integer TEST_LEN = 32; 
    reg clk_125 = 0;
    reg rst_n = 0;
    always #4 clk_125 = ~clk_125; // 125MHz

    // --- 2. 模块信号定义 (reg 类型) ---
    reg [95:0] adc_i = 0;
    reg [95:0] adc_q = 0;
    reg        adc_ready = 1;

    // --- 3. 实例化待测模块 ---
    pcie_top #(
        .SNAPSHOT_LEN(TEST_LEN)
    ) DUT (
        .pcie_refclk_p(1'b0), .pcie_refclk_n(1'b1),
        .pcie_perst_n(rst_n),
        .adc_data_i(adc_i), .adc_data_q(adc_q),
        .adc_vld_i(1'b1), .adc_vld_q(1'b1),  // tb 中数据始终有效
        .adc_ready(adc_ready),
        .pcie_link_up(), .capture_running()
    );

    // --- 4. 强制实例内部信号 (避免 Z 状态) ---
    initial begin
        force DUT.clk_125 = clk_125;
        force DUT.sys_rst_n_internal = rst_n;
    end

    // --- 5. AXI-Lite 写指令任务 ---
    task axil_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge clk_125);
            force DUT.axil_awaddr  = addr; 
            force DUT.axil_awvalid = 1'b1;
            force DUT.axil_wdata   = data; 
            force DUT.axil_wvalid  = 1'b1;
            wait(DUT.axil_bvalid); // 等待响应
            @(posedge clk_125);
            force DUT.axil_awvalid = 1'b0; 
            force DUT.axil_wvalid  = 1'b0;
        end
    endtask

    // --- 6. 发送模板：按签名的数据递增产生 ---
    // I 路：10, 11, 12... (递增数据)
    // Q 路：A0, A1, A2... (递增数据)
    integer i, k;
    always @(posedge clk_125) begin
        if (!rst_n) begin
            adc_i <= 0; adc_q <= 0; i <= 0;
        end else if (DUT.capture_en) begin
            for(k=0; k<12; k=k+1) begin
                adc_i[k*8 +: 8] <= 8'h10 + k + i[3:0]; 
                adc_q[k*8 +: 8] <= 8'hA0 + k + i[3:0];
            end
            i <= i + 1;
        end else begin
            i <= 0;
        end
    end

    // --- 7. 仿真激励流程 ---
    initial begin
        // A. 初始化和复位
        rst_n = 0; #100; rst_n = 1; #100;

        // B. SoC 端下发"抓取"指令
        axil_write(32'h0, 32'h1);
        $display("[%t] SoC: Write START issued.", $time);

        // C. 等待"自动关断"
        wait(DUT.capture_done);
        #20;
        if (DUT.capture_en == 1'b0)
            $display("[%t] SUCCESS: capture_en auto-cleared.", $time);

        // D. 模拟 PCIe 数据读出
        #100;
        force DUT.axis_fifo_ready = 1'b1;
        wait(DUT.axis_fifo_last);
        @(posedge clk_125);
        $display("[%t] XDMA: Stream Finished with TLAST.", $time);

        #500; $finish;
    end

endmodule