`timescale 1ns / 1ps

// 模块名：pcie_buffer_layer2
// 模块功能：
// 1) 使用 XPM UltraRAM 实现数据缓存。
// 2) 写时序顺序写入，读时序顺序读出并转为 AXI-Stream。
// 3) 解决因 RAM 读延迟导致的 tvalid/tlast 时序对齐问题。
module pcie_buffer_layer2 #(
    parameter integer DATA_WIDTH = 256,
    parameter integer ADDR_WIDTH = 16,       // 2^16 = 65536
    parameter integer MEM_SIZE   = 16777216, // 65536 * 256 bits
    parameter integer READ_LATENCY = 3       // 读延迟，需与 XPM 设置一致
)(
    // ==================== 时钟与复位 ====================
    input  wire                   clk_125,       // 系统时钟
    input  wire                   rst_n,

    // ==================== 写数据接口（来自 Layer1） ====================
    input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire                   s_axis_tvalid,
    input  wire                   capture_en,    // 抓取使能

    // ==================== 读数据接口（送到 XDMA 通路） ====================
    output wire [DATA_WIDTH-1:0]  m_axis_tdata,
    output wire                   m_axis_tvalid,
    output wire                   m_axis_tlast,
    input  wire                   m_axis_tready,

    // ==================== 状态信号 ====================
    output reg                    capture_done,  // 缓存写入完成标志
    output wire [ADDR_WIDTH:0]    fifo_count     // 写入阶段=已写入量, 读出阶段=剩余未读量
);

    // ===== 1) 内部信号定义 =====
    reg  [ADDR_WIDTH-1:0] wr_addr;
    reg  [ADDR_WIDTH-1:0] rd_addr;
    reg                   writing;
    reg                   read_done; // 读出完成标志

    // 匹配 RAM 读延迟的 valid/last 信号
    reg [READ_LATENCY:0] vld_pipe;
    reg [READ_LATENCY:0] lst_pipe;

    wire rd_can_step = m_axis_tready || !m_axis_tvalid; // AXIS 协议：无效或 ready 时允许前进

    // ===== 2) 写地址指针（顺序写入模式） =====
    always @(posedge clk_125) begin
        if (!rst_n || !capture_en) begin
            wr_addr      <= 0;
            capture_done <= 1'b0;
            writing      <= 1'b1;
        end else if (writing && s_axis_tvalid) begin
            if (wr_addr == {ADDR_WIDTH{1'b1}}) begin
                writing      <= 1'b0;
                capture_done <= 1'b1;
            end else begin
                wr_addr <= wr_addr + 1'b1;
            end
        end
    end

    // ===== 3) 读地址指针（AXIS 协议） =====
    // 注意：vld_pipe/lst_pipe 延迟需匹配 READ_LATENCY 拍数
    always @(posedge clk_125) begin
        if (!rst_n || !capture_en) begin
            rd_addr   <= 0;
            vld_pipe  <= 0;
            lst_pipe  <= 0;
            read_done <= 1'b0;
        end else if (rd_can_step) begin

            // capture_done 信号需要延迟同步
            if (capture_done && !read_done) begin
                if (rd_addr == {ADDR_WIDTH{1'b1}}) begin
                    read_done <= 1'b1;
                end else begin
                    rd_addr <= rd_addr + 1'b1;
                end
            end

            vld_pipe <= {vld_pipe[READ_LATENCY-1:0], (capture_done && !read_done)};

            lst_pipe <= {lst_pipe[READ_LATENCY-1:0], (capture_done && !read_done && (rd_addr == {ADDR_WIDTH{1'b1}}))};
        end
    end

    // ===== 4) AXIS 输出信号 =====
    assign m_axis_tvalid = vld_pipe[READ_LATENCY];
    assign m_axis_tlast  = lst_pipe[READ_LATENCY];
    localparam integer BUF_DEPTH = 1 << ADDR_WIDTH;
    // 实时水位：写阶段=已写入量(wr_addr)，读阶段=剩余未读量(BUF_DEPTH - rd_addr)
    wire [ADDR_WIDTH:0] rd_count = {(ADDR_WIDTH+1){1'b0}} | rd_addr;
    assign fifo_count = capture_done ? (BUF_DEPTH - rd_count) : ({1'b0, wr_addr});

    // ===== 5) XPM 双端口 RAM，使用 UltraRAM =====
    xpm_memory_sdpram #(
        .ADDR_WIDTH_A            (ADDR_WIDTH),
        .ADDR_WIDTH_B            (ADDR_WIDTH),
        .BYTE_WRITE_WIDTH_A      (DATA_WIDTH),
        .CASCADE_HEIGHT          (0),
        .CLOCKING_MODE           ("common_clock"),
        .MEMORY_PRIMITIVE        ("ultra"),
        .MEMORY_SIZE             (MEM_SIZE),
        .READ_DATA_WIDTH_B       (DATA_WIDTH),
        .READ_RESET_VALUE_B      ("0"),
        .READ_LATENCY_B          (READ_LATENCY),
        .WRITE_DATA_WIDTH_A      (DATA_WIDTH),
        .WRITE_MODE_B            ("read_first"),
        .RST_MODE_B              ("SYNC")
    ) xpm_uram_inst (
        .clka           (clk_125),
        .ena            (s_axis_tvalid && writing),
        .wea            (1'b1),
        .addra          (wr_addr),
        .dina           (s_axis_tdata),

        .clkb           (clk_125),
        // 读使能：只在数据前进时使能，避免 backpressure 时浪费 RAM/数据带宽
        .enb            (rd_can_step),
        .regceb         (rd_can_step),
        .addrb          (rd_addr),
        .doutb          (m_axis_tdata),

        .rstb           (!rst_n),
        .sleep          (1'b0),
        .injectdbiterra (1'b0),
        .injectsbiterra (1'b0)
    );

endmodule
