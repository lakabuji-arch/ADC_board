`timescale 1ns / 1ps

// 顶层模块 top_system_wrapper
// 模块功能：
// 1) 接收 ADC 采集数据，经过 FIFO/清洗/打包后送 PCIe 上传通路
// 2) 处理 adc_ready/复位信号在不同时钟域之间的安全同步
module top_system_wrapper #(
    parameter integer SNAPSHOT_LEN = 65536, // 抓取深度
    parameter integer FIFO_COUNT_W = $clog2(SNAPSHOT_LEN) + 1,
    parameter integer SIM_MODE      = 0      // 1 = bypass pcie_link_up for simulation
)(
    // ==================== 1) PCIe 物理接口 ====================
    input  wire         pcie_refclk_p, pcie_refclk_n, // PCIe 参考时钟差分对
    input  wire [0:0]   pcie_rx_p, pcie_rx_n,         // PCIe 接收差分对（x1）
    output wire [0:0]   pcie_tx_p, pcie_tx_n,         // PCIe 发送差分对（x1）

    // ==================== 2) ADC 模拟接口 ====================
    input  wire         adc_dclk_p, adc_dclk_n,       // ADC DCLK 差分输入（源同步时钟）
    output wire         adc_spi_cs_n,                 // SPI 片选（低有效）
    output wire         adc_spi_sclk,                 // SPI 时钟
    output wire         adc_spi_sdi,                  // SPI 数据输出（主发从收）
    input  wire         adc_spi_sdo,                  // SPI 数据输入（从发主收）
    output wire         adc_cal,                      // ADC 外部校准脉冲
    input  wire [7:0]   adc_di_p,  adc_di_n,          // I 路通道 A 数据（8bit）
    input  wire [7:0]   adc_did_p, adc_did_n,         // I 路通道 B 数据（8bit）
    input  wire [7:0]   adc_dq_p,  adc_dq_n,          // Q 路通道 A 数据（8bit）
    input  wire [7:0]   adc_dqd_p, adc_dqd_n,         // Q 路通道 B 数据（8bit）

    // ==================== 3) 全局控制与状态 ====================
    input  wire         sys_rst_n,                  // 板级复位（PERST#，低有效）
    output wire         adc_ready,                  // ADC + 系统就绪标志
    output wire         pcie_link_up,               // PCIe 链路训练完成标志
    // ==================== 4) 调试探针（仅仿真用） ====================
    output wire [255:0] dbg_packer_tdata,           // Layer1 打包器输出数据
    output wire         dbg_packer_tvalid,          // Layer1 打包器输出有效
    output wire         dbg_capture_done,           // URAM 抓取完成
    output wire [FIFO_COUNT_W-1:0]  dbg_fifo_count  // URAM FIFO 计数
);

    wire [255:0] dbg_packer_tdata_w;
    wire dbg_packer_tvalid_w, dbg_capture_done_w;
    wire [FIFO_COUNT_W-1:0] dbg_fifo_count_w;
    assign dbg_packer_tdata  = dbg_packer_tdata_w;
    assign dbg_packer_tvalid = dbg_packer_tvalid_w;
    assign dbg_capture_done  = dbg_capture_done_w;
    assign dbg_fifo_count    = dbg_fifo_count_w;

    // ===== 0) 复位输入缓冲 =====
    // 将外部复位经 IBUF 缓冲，再分发到内部逻辑，避免 IO 直接驱动长线网络。
    wire sys_rst_n_buf;
    IBUF u_sys_rst_ibuf (.O(sys_rst_n_buf), .I(sys_rst_n));

    // ===== 1) 内部时钟 =====
    // clk_adc_125  : ADC 采集/校准时钟域
    // clk_pcie_125 : PCIe 数据/控制域
    wire        clk_adc_125;
    wire        clk_pcie_125;   

    // ===== 2) 内部数据通路 =====
    wire [95:0] adc_raw_i, adc_raw_q;
    wire        gb_vld_i, gb_vld_q;   
    wire [95:0] fifo_dout_i, fifo_dout_q;
    wire        fifo_vld_i, fifo_vld_q;

    // 主数据路径直通：命名为 stream_*，明确表示这是送往 PCIe 的采样流
    wire [95:0] stream_data_i, stream_data_q;
    wire        stream_vld_i,  stream_vld_q;

    // ===== 3) adc_ready 到 PCIe 域的复位关 =====
    // 先将 adc_ready 同步到 clk_pcie_125，再生成同步复位关 rst_125_sync。
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg adc_ready_s1 = 1'b0, adc_ready_s2 = 1'b0;
    always @(posedge clk_pcie_125) begin
        adc_ready_s1 <= adc_ready;
        adc_ready_s2 <= adc_ready_s1;
    end
    
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) reg [3:0] rst_125_sync = 4'hF;
    always @(posedge clk_pcie_125) begin
        // 复位条件：ADC 未就绪 或 外部复位有效
        rst_125_sync <= {rst_125_sync[2:0], (!adc_ready_s2 || !sys_rst_n_buf)};
    end

    // adc_ready is generated in clk_adc_125 domain (same as FIFO write clock),
    // so no CDC sync needed here. Direct use prevents losing first 2 valid samples.
    
    // ===== 5) ADC 采集链模块例化 =====
    // 端口说明：
    // - 输入：差分对 DCLK、SPI 回读、32路差分数据
    // - 输出：SPI 控制、adc_cal、I/Q 96bit 数据及 valid、adc_ready
    adc_top u_adc_part (
        .sys_rst_n          (sys_rst_n_buf), // 系统复位输入
        .adc_dclk_p         (adc_dclk_p),    // ADC 输入时钟正
        .adc_dclk_n         (adc_dclk_n),    // ADC 输入时钟负
        .adc_spi_cs_n       (adc_spi_cs_n),  // SPI 片选输出
        .adc_spi_sclk       (adc_spi_sclk),  // SPI 时钟输出
        .adc_spi_sdi        (adc_spi_sdi),   // SPI 数据输出
        .adc_spi_sdo        (adc_spi_sdo),   // SPI 数据输入
        .adc_cal            (adc_cal),       // ADC CAL 脉冲输出
        .adc_di_p           (adc_di_p),      // I 路 A 数据
        .adc_di_n           (adc_di_n),      // I 路 A 数据
        .adc_did_p          (adc_did_p),     // I 路 B 数据
        .adc_did_n          (adc_did_n),     // I 路 B 数据
        .adc_dq_p           (adc_dq_p),      // Q 路 A 数据
        .adc_dq_n           (adc_dq_n),      // Q 路 A 数据
        .adc_dqd_p          (adc_dqd_p),     // Q 路 B 数据
        .adc_dqd_n          (adc_dqd_n),     // Q 路 B 数据
        .adc_ready          (adc_ready),     // ADC 就绪标志
        .adc_clk_125m_out   (clk_adc_125),   // 输出域 125MHz 时钟
        .adc_data_i_out     (adc_raw_i),     // I 路原始 96bit
        .adc_data_q_out     (adc_raw_q),     // Q 路原始 96bit
        .adc_vld_i_out      (gb_vld_i),      // I 路有效
        .adc_vld_q_out      (gb_vld_q),      // Q 路有效
        .bp_ready_i         (bp_ready_i),    // I 路反压
        .bp_ready_q         (bp_ready_q)     // Q 路反压
    );

    // ===== 6) 双通道异步 FIFO 跨时钟 =====
    // 写域：clk_adc_125，读域：clk_pcie_125。
    // 只在 adc_ready=1 时允许写入，防止未稳定数据进入 FIFO。
    wire fifo_wr_en_i = gb_vld_i && adc_ready;
    wire fifo_wr_en_q = gb_vld_q && adc_ready;
    
    // 读使能策略：非空即读，允许 underflow（无有效数据时忽略）。
    wire fifo_empty_i, fifo_empty_q;
    wire fifo_full_i, fifo_full_q;
    wire fifo_rd_en_i = ~fifo_empty_i; // 只要非空就读
    wire fifo_rd_en_q = ~fifo_empty_q;
    // 反压：FIFO 将满时暂停 gearbox 读，防止溢出
    wire bp_ready_i = ~fifo_full_i;
    wire bp_ready_q = ~fifo_full_q;

    fifo_generator_0 u_fifo_i (
        .rst        (rst_125_sync[3]), // FIFO 复位（PCIe 域同步生成）
        .wr_clk     (clk_adc_125),     // 写时钟
        .wr_en      (fifo_wr_en_i),    // I 路写使能
        .din        (adc_raw_i),       // I 路写数据
        .rd_clk     (clk_pcie_125),    // 读时钟
        .rd_en      (fifo_rd_en_i),    // I 路读使能
        .dout       (fifo_dout_i),     // I 路读数据
        .full       (fifo_full_i),       // 反压到 gearbox
        .empty      (fifo_empty_i),    // I 路空标志
        .valid      (fifo_vld_i)       // I 路读出有效
    );

    fifo_generator_0 u_fifo_q (
        .rst        (rst_125_sync[3]), // FIFO 复位
        .wr_clk     (clk_adc_125),     // 写时钟
        .wr_en      (fifo_wr_en_q),    // Q 路写使能
        .din        (adc_raw_q),       // Q 路写数据
        .rd_clk     (clk_pcie_125),    // 读时钟
        .rd_en      (fifo_rd_en_q),    // Q 路读使能
        .dout       (fifo_dout_q),     // Q 路读数据
        .full       (fifo_full_q),       // 反压到 gearbox
        .empty      (fifo_empty_q),    // Q 路空标志
        .valid      (fifo_vld_q)       // Q 路读出有效
    );

    // ===== 7) FIFO 输出直通 =====
    // 低时延采集优先，避免 4tap/3tap 对真实采样序列做重排或重复。
    assign stream_data_i = fifo_dout_i;
    assign stream_data_q = fifo_dout_q;
    assign stream_vld_i  = fifo_vld_i;
    assign stream_vld_q  = fifo_vld_q;

    // ===== 8) PCIe 数据上传模块例化 =====
    // adc_ready  : SPI 配置完成 → 恒为 1 (level)
    // adc_vld_i/q: FIFO 逐拍有效 → 防 FIFO 下溢时采垃圾数据
    pcie_top #(
        .SIM_MODE           (SIM_MODE),
        .SNAPSHOT_LEN       (SNAPSHOT_LEN),
        .FIFO_COUNT_W       (FIFO_COUNT_W)
    ) u_pcie_part (
        .pcie_refclk_p      (pcie_refclk_p),              // PCIe 参考时钟正
        .pcie_refclk_n      (pcie_refclk_n),              // PCIe 参考时钟负
        .pcie_perst_n       (sys_rst_n_buf),              // PCIe 复位输入
        .pcie_rx_p          (pcie_rx_p),                  // PCIe RX 正
        .pcie_rx_n          (pcie_rx_n),                  // PCIe RX 负
        .pcie_tx_p          (pcie_tx_p),                  // PCIe TX 正
        .pcie_tx_n          (pcie_tx_n),                  // PCIe TX 负
        .adc_data_i         (stream_data_i),              // I 路输出采样流
        .adc_data_q         (stream_data_q),              // Q 路输出采样流
        .adc_vld_i          (stream_vld_i),               // I 路逐拍有效
        .adc_vld_q          (stream_vld_q),               // Q 路逐拍有效
        .adc_ready          (adc_ready),                  // ADC SPI 校准就绪
        .pcie_link_up       (pcie_link_up),               // Link 状态输出
        .clk_125_out        (clk_pcie_125),               // 输出 PCIe 域 125MHz
        .dbg_packer_tdata   (dbg_packer_tdata_w),
        .dbg_packer_tvalid  (dbg_packer_tvalid_w),
        .dbg_capture_done   (dbg_capture_done_w),
        .dbg_fifo_count     (dbg_fifo_count_w)
    );

endmodule