// 模块名：bit_wise_cleaner_4tap
// 模块功能：
// 1) 四级流水线 word-wise 清洗
// 2) 若 p1==p4 则输出 p1，否则输出 p3
// 3) 通过加宽观测窗口降低瞬时翻转的影响
module bit_wise_cleaner_4tap #(
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
    reg [WIDTH-1:0] p1, p2, p3, p4;
    reg             v1, v2, v3, v4;

    always @(posedge clk) begin
        if (!rst_n) begin
            {p1, p2, p3, p4} <= 0;
            {v1, v2, v3, v4} <= 0;
            dout <= 0; v_out <= 0;
        end else begin
            p1 <= din; p2 <= p1; p3 <= p2; p4 <= p3;
            v1 <= v_in; v2 <= v1; v3 <= v2; v4 <= v3;

            // 四窗口判决
            if (p1 == p4) begin
                dout <= p1;
            end else begin
                dout <= p3;
            end
            
            v_out <= v3; 
        end
    end
endmodule


