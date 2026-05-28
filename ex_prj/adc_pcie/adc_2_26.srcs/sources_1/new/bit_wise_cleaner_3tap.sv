// 模块名：bit_wise_cleaner_3tap
// 模块功能：
// 1) 三级流水线 word-wise 清洗
// 2) 若 p1==p3 则输出 p1，否则输出中间值 p2
// 3) 抑制单拍毛刺，输出保持流水线延迟
module bit_wise_cleaner_3tap #(
    parameter WIDTH = 96
)(
    // ==================== 接口定义 ====================
    input  wire             clk,            // 工作时钟
    input  wire             rst_n,          // 低有效复位
    input  wire [WIDTH-1:0] din,            // 输入数据
    input  wire             v_in,           // 输入有效
    output reg  [WIDTH-1:0] dout,           // 输出数据
    output reg              v_out           // 输出有效
);
    // 流水线寄存器
    reg [WIDTH-1:0] p1, p2, p3;
    reg             v1, v2, v3;

    always @(posedge clk) begin
        if (!rst_n) begin
            {p1, p2, p3} <= 0;
            {v1, v2, v3} <= 0;
            dout <= 0;
            v_out <= 0;
        end else begin
            // 流水线移位
            p1 <= din; p2 <= p1; p3 <= p2;
            v1 <= v_in; v2 <= v1; v3 <= v2;

            // 判决逻辑
            if (p1 == p3) begin
                dout <= p1;
            end else begin
                dout <= p2;
            end
            
            v_out <= v2;
        end
    end
endmodule
