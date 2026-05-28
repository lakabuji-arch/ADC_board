`timescale 1ns / 1ps

// 模块名：pcie_ctrl_layer3
// 模块功能：
// 1) 作为 AXI-Lite 从设备接口，提供抓取控制与状态读取。
// 2) 寄存器映射：
//    0x00: 控制寄存器（bit0 = capture_en）
//    0x04: 状态寄存器（bit0 = capture_done, bit1 = fifo_full）
//    0x08: 数据计数寄存器（data_count）
module pcie_ctrl_layer3 (
    // ==================== 时钟与复位 ====================
    input  wire         clk_125,         // AXI-Lite 时钟
    input  wire         rst_n,           // 低有效复位

    // ==================== AXI-Lite 接口 ====================
    // 写地址通道
    input  wire [31:0]  s_axil_awaddr,
    input  wire [2:0]   s_axil_awprot,
    input  wire         s_axil_awvalid,
    output wire         s_axil_awready,
    // 写数据通道
    input  wire [31:0]  s_axil_wdata,
    input  wire [3:0]   s_axil_wstrb,
    input  wire         s_axil_wvalid,
    output wire         s_axil_wready,
    // 写响应通道
    output wire [1:0]   s_axil_bresp,
    output wire         s_axil_bvalid,
    input  wire         s_axil_bready,
    // 读地址通道
    input  wire [31:0]  s_axil_araddr,
    input  wire [2:0]   s_axil_arprot,
    input  wire         s_axil_arvalid,
    output wire         s_axil_arready,
    // 读数据通道
    output reg  [31:0]  s_axil_rdata,
    output wire [1:0]   s_axil_rresp,
    output wire         s_axil_rvalid,
    input  wire         s_axil_rready,

    // ==================== 内部控制/状态接口 ====================
    output reg          reg_capture_en,      // 抓取使能输出到 Layer2
    input  wire         status_capture_done, // 抓取完成标志
    input  wire         status_fifo_full,    // FIFO 满标志
    input  wire [31:0]  status_data_count    // 数据计数值
);

    // ===== 1) 内部状态寄存器 =====
    reg [31:0] ctrl_reg;
    reg        bvalid_r;
    reg        rvalid_r;

    // AW/W channels may arrive out of order; buffer until both valid
    reg        aw_pending;
    reg [31:0] awaddr_latched;
    reg        w_pending;
    reg [31:0] wdata_latched;
    reg [3:0]  wstrb_latched;

    // ===== 2) AXI-Lite д·�� =====
    // 在无未完成的写响应时接受新请求
    assign s_axil_awready = !bvalid_r && !aw_pending;
    assign s_axil_wready  = !bvalid_r && !w_pending;
    assign s_axil_bresp   = 2'b00;
    assign s_axil_bvalid  = bvalid_r;

    always @(posedge clk_125 or negedge rst_n) begin
        if (!rst_n) begin
            reg_capture_en <= 1'b0;
            ctrl_reg <= 32'd0;
            bvalid_r <= 1'b0;
            aw_pending <= 1'b0;
            awaddr_latched <= 32'd0;
            w_pending <= 1'b0;
            wdata_latched <= 32'd0;
            wstrb_latched <= 4'd0;
        end else begin
            // 捕捉 AW/W 通道（可能不同时到达）
            if (s_axil_awvalid && s_axil_awready) begin
                aw_pending <= 1'b1;
                awaddr_latched <= s_axil_awaddr;
            end
            if (s_axil_wvalid && s_axil_wready) begin
                w_pending <= 1'b1;
                wdata_latched <= s_axil_wdata;
                wstrb_latched <= s_axil_wstrb;
            end

            // 当地址和数据都到达时执行写操作，发出 BVALID
            if (!bvalid_r && aw_pending && w_pending) begin
                case (awaddr_latched[7:0])
                    8'h00: begin
                        // 控制寄存器写，strobe 有效时更新对应位
                        if (wstrb_latched[0]) begin
                            ctrl_reg <= wdata_latched;
                            reg_capture_en <= wdata_latched[0];
                        end
                    end
                    default: begin end
                endcase
                bvalid_r <= 1'b1;
                aw_pending <= 1'b0;
                w_pending <= 1'b0;
            end else if (bvalid_r && s_axil_bready) begin
                bvalid_r <= 1'b0;
            end

            // 抓取完成后自动关闭 capture_en，防止重复触发
            if (status_capture_done) begin
                reg_capture_en <= 1'b0;
            end
        end
    end

    // ===== 3) AXI-Lite 读通路 =====
    // 当前读事务被接受 (rvalid && rready) 或空闲时允许新读请求
    assign s_axil_arready = !rvalid_r || s_axil_rready;
    assign s_axil_rresp   = 2'b00;
    assign s_axil_rvalid  = rvalid_r;

    always @(posedge clk_125 or negedge rst_n) begin
        if (!rst_n) begin
            s_axil_rdata <= 32'd0;
            rvalid_r <= 1'b0;
        end else if (!rvalid_r && s_axil_arvalid) begin
            case (s_axil_araddr[7:0])
                8'h00: s_axil_rdata <= {31'd0, reg_capture_en};
                8'h04: s_axil_rdata <= {30'd0, status_fifo_full, status_capture_done};
                8'h08: s_axil_rdata <= status_data_count;
                default: s_axil_rdata <= 32'hDEADBEEF;
            endcase
            rvalid_r <= 1'b1;
        end else if (rvalid_r && s_axil_rready) begin
            rvalid_r <= 1'b0;
        end
    end

endmodule
