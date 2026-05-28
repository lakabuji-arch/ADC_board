`timescale 1ns / 1ps

// 模块名：pcie_top
// 模块功能：
// 1) 发送通路：Layer1 打包 (256bit) -> Layer2 URAM 存储 (256bit) -> 位宽转换 (64bit) -> XDMA C2H 通道
// 2) 控制通路：XDMA AXI-Lite Master -> Layer3 寄存器 -> capture_en/capture_done
module pcie_top #(
    parameter integer SNAPSHOT_LEN = 65536,
    parameter integer FIFO_COUNT_W = $clog2(SNAPSHOT_LEN) + 1,
    parameter integer SIM_MODE      = 0   // 1 = bypass pcie_link_up for simulation
)(
    // ==================== 1) PCIe 物理接口 ====================
    input  wire         pcie_refclk_p, pcie_refclk_n, // 参考时钟差分对
    input  wire         pcie_perst_n,                 // PERST# 复位输入（低有效）
    input  wire [0:0]   pcie_rx_p, pcie_rx_n,         // PCIe 接收差分对（x1）
    output wire [0:0]   pcie_tx_p, pcie_tx_n,         // PCIe 发送差分对（x1）

    // ==================== 2) ADC 数据接口 ====================
    input  wire [95:0]  adc_data_i,                  // I 路 96bit 数据
    input  wire [95:0]  adc_data_q,                  // Q 路 96bit 数据
    input  wire         adc_vld_i,                   // I 路数据有效 (清洗器输出)
    input  wire         adc_vld_q,                   // Q 路数据有效 (清洗器输出)
    input  wire         adc_ready,                   // ADC SPI 校准就绪 (level)

    // ==================== 3) Status outputs ====================
    output wire         pcie_link_up,                // PCIe link is up
    output wire         capture_running,             // Currently capturing
    output wire         clk_125_out,                 // 125MHz user clock from XDMA
    // ==================== 4) Debug probe (sim-only) ====================
    output wire [255:0] dbg_packer_tdata,
    output wire         dbg_packer_tvalid,
    output wire         dbg_capture_done,
    output wire [FIFO_COUNT_W-1:0]  dbg_fifo_count
);

    // ===== 1) 内部信号定义 =====
    wire         clk_125;
    wire         sys_rst_n_internal;

    // AXI-Lite 信号：XDMA <-> Layer3
    wire [31:0]  axil_awaddr, axil_wdata, axil_araddr, axil_rdata;
    wire         axil_awvalid, axil_awready, axil_wvalid, axil_wready;
    wire         axil_arvalid, axil_arready, axil_rvalid, axil_rready;
    wire [1:0]   axil_bresp, axil_rresp;
    wire         axil_bvalid, axil_bready;
    wire [2:0]   axil_awprot, axil_arprot;
    wire [3:0]   axil_wstrb;

    // AXI-Stream 256bit 信号：Layer1 <-> Layer2
    wire [255:0] axis_packer_data;
    wire         axis_packer_valid, axis_packer_last;

    wire [255:0] axis_uram_data;
    wire         axis_uram_valid, axis_uram_last, axis_uram_ready;

    // AXI-Stream 64bit 信号：WidthConv -> XDMA
    wire [63:0]  axis_fifo_data;
    wire         axis_fifo_valid, axis_fifo_last, axis_fifo_ready;

    wire         capture_en;
    wire         capture_done;
    wire [FIFO_COUNT_W-1:0]  fifo_count;

    // Debug probe assignments (after signal declarations)
    assign dbg_packer_tdata  = axis_packer_data;
    assign dbg_packer_tvalid = axis_packer_valid;
    assign dbg_capture_done  = capture_done;
    assign dbg_fifo_count    = fifo_count;

    // 组合状态信号使能更高效的读取
    assign capture_running = capture_en && !capture_done;
    assign clk_125_out = clk_125;

    // ===== 0) 同步板级复位信号到 clk_125 =====
    // 正常模式：等 pcie_link_up 后再释放用户逻辑复位，确保 clk_125 稳定且链路就绪。
    // 仿真模式：PCIe 链路无法训练，直接释放复位。
    generate
        if (SIM_MODE) begin : gen_sim_rst
            // In simulation, PCIe link never trains; pass perst_n directly
            assign sys_rst_n_internal = pcie_perst_n;
        end else begin : gen_hw_rst
            (* ASYNC_REG = "TRUE" *) reg [3:0] rstn_sync = 4'b0000;
            always @(posedge clk_125 or negedge pcie_perst_n) begin
                if (!pcie_perst_n)
                    rstn_sync <= 4'b0000;
                else
                    rstn_sync <= {rstn_sync[2:0], pcie_link_up};
            end
            assign sys_rst_n_internal = rstn_sync[3];
        end
    endgenerate

    // ===== 2) PCIe 参考时钟缓冲 =====
    wire pcie_refclk_gt, pcie_refclk_fabric;
    IBUFDS_GTE4 #( .REFCLK_HROW_CK_SEL(2'b00) ) u_pcie_refclk_ibuf (
        .I(pcie_refclk_p),          // 正时钟输入
        .IB(pcie_refclk_n),         // 负时钟输入
        .CEB(1'b0),                 // 使能低有效
        .O(pcie_refclk_gt),         // GT 原始参考时钟
        .ODIV2(pcie_refclk_fabric)  // 二分频后系统参考时钟
    );

    // ===== 3) Layer1 数据打包模块 (256bit) =====
    data_packer_layer1 #(
        .SNAPSHOT_LEN(SNAPSHOT_LEN)
    ) u_layer1_packer (
        .clk_125(clk_125),                // 系统时钟
        .rst_n(sys_rst_n_internal),       // 内部复位
        .data_i_bus(adc_data_i),          // I 路数据
        .data_q_bus(adc_data_q),          // Q 路数据
        .adc_vld_i(adc_vld_i),            // I 路逐拍有效
        .adc_vld_q(adc_vld_q),            // Q 路逐拍有效
        .adc_ready(adc_ready),            // ADC 系统就绪
        .capture_en(capture_en),          // 抓取使能
        .m_axis_tdata(axis_packer_data),  // 输出 256bit 数据
        .m_axis_tvalid(axis_packer_valid),// 输出有效
        .m_axis_tlast(axis_packer_last),  // 抓取末尾标志
        .m_axis_tready(1'b1),             // URAM 始终可接收，无需反压
        .capture_done()                   // 本模块 done 未使用，以 Layer2 为准
    );


    localparam integer ADDR_W = $clog2(SNAPSHOT_LEN); // 根据抓取长度计算地址位宽

    // ===== 4) Layer2 缓存（UltraRAM, 256bit） =====
    pcie_buffer_layer2 #(
        .DATA_WIDTH(256),
        .ADDR_WIDTH(ADDR_W),
        .MEM_SIZE(SNAPSHOT_LEN*256),
        .READ_LATENCY(3)
    ) u_layer2_buffer (
        .clk_125(clk_125),
        .rst_n(sys_rst_n_internal),
        .s_axis_tdata(axis_packer_data),
        .s_axis_tvalid(axis_packer_valid),
        .capture_en(capture_en),
        .m_axis_tdata(axis_uram_data),
        .m_axis_tvalid(axis_uram_valid),
        .m_axis_tlast(axis_uram_last),
        .m_axis_tready(axis_uram_ready),
        .capture_done(capture_done),
        .fifo_count(fifo_count)
    );

    // ===== 5) Width converter (256bit -> 64bit) =====
    axis_width_converter_256_to_64 u_width_conv (
        .clk(clk_125),
        .rst_n(sys_rst_n_internal),
        .s_axis_tdata(axis_uram_data),
        .s_axis_tvalid(axis_uram_valid),
        .s_axis_tlast(axis_uram_last),
        .s_axis_tready(axis_uram_ready),
        .m_axis_tdata(axis_fifo_data),
        .m_axis_tvalid(axis_fifo_valid),
        .m_axis_tlast(axis_fifo_last),
        .m_axis_tready(axis_fifo_ready)
    );

    // ===== 6) Layer3 控制寄存器模块（AXI-Lite 从设备） =====
    pcie_ctrl_layer3 u_layer3_ctrl (
        .clk_125(clk_125),
        .rst_n(sys_rst_n_internal),
        .s_axil_awaddr(axil_awaddr),
        .s_axil_awprot(axil_awprot),
        .s_axil_awvalid(axil_awvalid),
        .s_axil_awready(axil_awready),
        .s_axil_wdata(axil_wdata),
        .s_axil_wstrb(axil_wstrb),
        .s_axil_wvalid(axil_wvalid),
        .s_axil_wready(axil_wready),
        .s_axil_bresp(axil_bresp),
        .s_axil_bvalid(axil_bvalid),
        .s_axil_bready(axil_bready),
        .s_axil_araddr(axil_araddr),
        .s_axil_arprot(axil_arprot),
        .s_axil_arvalid(axil_arvalid),
        .s_axil_arready(axil_arready),
        .s_axil_rdata(axil_rdata),
        .s_axil_rresp(axil_rresp),
        .s_axil_rvalid(axil_rvalid),
        .s_axil_rready(axil_rready),
        .reg_capture_en(capture_en),
        .status_capture_done(capture_done),
        .status_fifo_full(1'b0),
        .status_data_count({{(32-FIFO_COUNT_W){1'b0}}, fifo_count})
    );

    // ===== 7) XDMA 例化 =====
    xdma_0 u_xdma (
        .sys_clk(pcie_refclk_fabric),      // XDMA 系统参考时钟
        .sys_clk_gt(pcie_refclk_gt),       // XDMA GT 参考时钟
        .sys_rst_n(pcie_perst_n),          // XDMA 复位输入
        .user_lnk_up(pcie_link_up),        // 链路 up 指示
        .pci_exp_rxp(pcie_rx_p),           // PCIe RX 正
        .pci_exp_rxn(pcie_rx_n),           // PCIe RX 负
        .pci_exp_txp(pcie_tx_p),           // PCIe TX 正
        .pci_exp_txn(pcie_tx_n),           // PCIe TX 负
        .axi_aclk(clk_125),                // AXI 时钟
        .axi_aresetn(sys_rst_n_internal),  // AXI 复位

        // C2H channel (FPGA -> Host)
        .s_axis_c2h_tdata_0(axis_fifo_data),
        .s_axis_c2h_tvalid_0(axis_fifo_valid),
        .s_axis_c2h_tlast_0(axis_fifo_last),
        .s_axis_c2h_tready_0(axis_fifo_ready),

        // AXI-Lite master interface
        .m_axil_awaddr(axil_awaddr),
        .m_axil_awprot(axil_awprot),
        .m_axil_awvalid(axil_awvalid),
        .m_axil_awready(axil_awready),
        .m_axil_wdata(axil_wdata),
        .m_axil_wstrb(axil_wstrb),
        .m_axil_wvalid(axil_wvalid),
        .m_axil_wready(axil_wready),
        .m_axil_bresp(axil_bresp),
        .m_axil_bvalid(axil_bvalid),
        .m_axil_bready(axil_bready),
        .m_axil_araddr(axil_araddr),
        .m_axil_arprot(axil_arprot),
        .m_axil_arvalid(axil_arvalid),
        .m_axil_arready(axil_arready),
        .m_axil_rdata(axil_rdata),
        .m_axil_rresp(axil_rresp),
        .m_axil_rvalid(axil_rvalid),
        .m_axil_rready(axil_rready),

        .usr_irq_req(capture_done)
    );

endmodule
