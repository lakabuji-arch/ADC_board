`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_fpga_top_front — 前侧 ADC→Packer 验证
// DUT:       adc_top + adc_packer_512 + gearbox_32_to_96 + idelay_auto_scan
// 时钟:      adc_dclk(375M), clk_125(125M)
//
// 验证项:
//   - ADC IDELAY 自动扫描收敛 → adc_ready
//   - Packer 正常输出有效数据
//   - tlast 0/1 交替 (2-beat burst 格式)
//   - Scoreboard: sync bit=1, seq 递增, beat/frame 计数
//   - S2MM 地址推进 (> 8KB 证明数据在流动)
//
// IP Stubs: clk_wiz_1, IDELAYCTRL, IBUFDS, IDELAYE3 (随机眼图), IDDRE1, adc_spi_config
////////////////////////////////////////////////////////////////////////////////

// ============================================================================
// tb_fpga_top_front — 前侧仿真: ADC输入 → packer → scoreboard
// 验证: ADC对齐, packer 5对/2拍格式, HDR/tlast/seq完整性
// ============================================================================

module tb_fpga_top_front;

    reg adc_dclk=1'b0, clk_ref_300m=1'b0, clk_125=1'b0;
    always #1.333 adc_dclk    =~adc_dclk;
    always #1.667 clk_ref_300m=~clk_ref_300m;
    always #4.000 clk_125     =~clk_125;

    reg sys_rst_n=1'b0;
    initial begin repeat(50) @(posedge clk_125); sys_rst_n<=1'b1; end

    // ADC LVDS data (toggling pattern)
    wire data_hi = adc_dclk;
    wire [7:0] adc_di_p={8{data_hi}},  adc_di_n={8{~data_hi}};
    wire [7:0] adc_did_p={8{data_hi}}, adc_did_n={8{~data_hi}};
    wire [7:0] adc_dq_p={8{data_hi}},  adc_dq_n={8{~data_hi}};
    wire [7:0] adc_dqd_p={8{data_hi}}, adc_dqd_n={8{~data_hi}};

    // DUT: adc_top (real RTL + behavioral primitives)
    wire adc_ready, adc_clk_125m_out;
    wire [95:0] adc_data_i, adc_data_q;
    wire adc_vld_i, adc_vld_q;
    wire adc_spi_cs_n, adc_spi_sclk, adc_spi_sdi, adc_cal;

    adc_top u_adc(
        .sys_rst_n(sys_rst_n), .adc_dclk_p(adc_dclk), .adc_dclk_n(~adc_dclk),
        .adc_spi_cs_n(adc_spi_cs_n), .adc_spi_sclk(adc_spi_sclk),
        .adc_spi_sdi(adc_spi_sdi), .adc_spi_sdo(1'b0), .adc_cal(adc_cal),
        .adc_di_p(adc_di_p), .adc_di_n(adc_di_n),
        .adc_did_p(adc_did_p), .adc_did_n(adc_did_n),
        .adc_dq_p(adc_dq_p), .adc_dq_n(adc_dq_n),
        .adc_dqd_p(adc_dqd_p), .adc_dqd_n(adc_dqd_n),
        .adc_ready(adc_ready), .adc_clk_125m_out(adc_clk_125m_out),
        .adc_data_i_out(adc_data_i), .adc_data_q_out(adc_data_q),
        .adc_vld_i_out(adc_vld_i), .adc_vld_q_out(adc_vld_q),
        .bp_ready_i(1'b1), .bp_ready_q(1'b1)
    );

    // Packer (real RTL)
    wire [511:0] packer_tdata;
    wire [63:0]  packer_tkeep;
    wire         packer_tvalid, packer_tlast;
    assign       packer_tready = 1'b1;

    adc_packer_512 #(.SNAPSHOT_LEN(65536)) u_packer(
        .clk_125(adc_clk_125m_out), .rst_n(adc_ready),
        .data_i_bus(adc_data_i), .data_q_bus(adc_data_q),
        .adc_vld_i(adc_vld_i), .adc_vld_q(adc_vld_q),
        .adc_ready(adc_ready), .capture_en(1'b1),
        .m_axis_tdata(packer_tdata), .m_axis_tkeep(packer_tkeep),
        .m_axis_tvalid(packer_tvalid), .m_axis_tlast(packer_tlast),
        .m_axis_tready(packer_tready), .capture_done()
    );

    // Scoreboard — verifies packer output format
    reg [14:0] sb_seq_exp; reg sb_expect_tlast;
    reg [31:0] sb_beats, sb_frames; reg sb_err, sb_done;

    always @(posedge adc_clk_125m_out) begin
        if(!adc_ready) begin
            sb_seq_exp<=0; sb_expect_tlast<=0;
            sb_beats<=0; sb_frames<=0; sb_err<=0; sb_done<=0;
        end else if(!sb_done) begin
            if(packer_tvalid && packer_tready) begin
                if(packer_tdata[511]!=1'b1 && sb_beats>15)   sb_err<=1;
                if(packer_tlast!=sb_expect_tlast && sb_beats>15) sb_err<=1;
                if(!packer_tlast) begin
                    if(packer_tdata[510:496]!=sb_seq_exp && sb_beats>15) sb_err<=1;
                    sb_seq_exp<=sb_seq_exp+1;
                end
                sb_expect_tlast<=packer_tlast?1'b0:1'b1;
                sb_beats<=sb_beats+1;
                if(packer_tlast) sb_frames<=sb_frames+1;
                if(sb_beats>=1999) sb_done<=1;
            end
        end
    end

    // S2MM addr tracker (same logic as fpga_top_integrated)
    localparam [31:0] BUF_BASE=32'h1000_0000, BUF_END=BUF_BASE+(512*1024*1024)-128;
    reg [31:0] s2mm_addr;

    always @(posedge adc_clk_125m_out) begin
        if(!adc_ready) s2mm_addr<=BUF_BASE;
        else if(packer_tvalid && packer_tready)
            s2mm_addr<=(s2mm_addr>=BUF_END)?BUF_BASE:s2mm_addr+128;
    end

    // Test
    integer pass, fail, ii;
    initial begin
        pass=0; fail=0;
        $display("+-------------------------------------------+");
        $display("|  tb_fpga_top_front  ADC->Packer verification");
        $display("+-------------------------------------------+");

        // 1. ADC alignment (IDELAY scan + SPI config)
        $write("  ADC align: ");
        for(ii=0;ii<50000&&!adc_ready;ii++) @(posedge adc_clk_125m_out);
        if(adc_ready) begin $display("PASS (%0d cyc)",ii); pass++; end
        else begin $display("FAIL"); fail++; end

        repeat(200) @(posedge adc_clk_125m_out);

        // 2. Packer producing output
        $write("  Packer active: ");
        if(packer_tvalid) begin $display("PASS"); pass++; end
        else begin $display("FAIL"); fail++; end

        // 3. tlast toggling (verify 0/1 alternation)
        $write("  tlast pattern: ");
        begin integer o,z; o=0; z=0;
            for(ii=0;ii<200;ii++) begin @(posedge adc_clk_125m_out);
                if(packer_tvalid) begin if(packer_tlast) o++; else z++; end
            end
            if(o>20&&z>20) begin $display("PASS (0:%0d 1:%0d)",z,o); pass++; end
            else begin $display("FAIL (0:%0d 1:%0d)",z,o); fail++; end
        end

        // 4-6. Scoreboard checks (2000 beats)
        wait(sb_done);

        $write("  Data integrity: ");
        if(!sb_err) begin $display("PASS (%0d beats/%0d frames)",sb_beats,sb_frames); pass++; end
        else begin $display("FAIL (%0d beats)",sb_beats); fail++; end

        $write("  Frame count: ");
        if(sb_frames>400) begin $display("PASS"); pass++; end
        else begin $display("FAIL (%0d frames)",sb_frames); fail++; end

        $write("  S2MM addr: ");
        if(s2mm_addr>BUF_BASE+8192) begin $display("PASS (0x%08h)",s2mm_addr); pass++; end
        else begin $display("FAIL (0x%08h)",s2mm_addr); fail++; end

        $display("+-------------------------------------------+");
        if(fail==0) $display("|  ALL %0d PASS",pass);
        else        $display("|  %0d PASS %0d FAIL",pass,fail);
        $display("|  Sim: %0t ns",$time);
        $display("+-------------------------------------------+");
        if(fail>0) $error("%0d FAIL",fail);
        $finish;
    end

    initial begin #8_000_000; $display("TIMEOUT"); $finish; end

endmodule

// ============================================================================
// BEHAVIORAL STUBS
// ============================================================================

module clk_wiz_1(input clk_in1_p,clk_in1_n, output reg clk_out1,clk_out2,clk_out3, input reset, output reg locked);
    initial begin clk_out1=0;clk_out2=0;clk_out3=0;locked=0; end
    always #1.333 clk_out1=~clk_out1; always #1.667 clk_out2=~clk_out2; always #4.000 clk_out3=~clk_out3;
    always @(posedge clk_out3 or posedge reset) if(reset) locked<=0; else locked<=1;
endmodule

module IDELAYCTRL #(parameter SIM_DEVICE="ULTRASCALE") (output reg RDY, input REFCLK, RST);
    always @(posedge REFCLK or posedge RST) if(RST) RDY<=0; else RDY<=1;
endmodule

module IBUFDS(input I,IB, output O); assign O=I; endmodule

module IDELAYE3 #(parameter DELAY_TYPE="VAR_LOAD", DELAY_FORMAT="COUNT", SIM_DEVICE="ULTRASCALE") (
    input IDATAIN, output reg DATAOUT, input CLK,LOAD,EN_VTC,RST, input [8:0] CNTVALUEIN,
    input CASC_IN,CASC_RETURN,DATAIN,INC,CE
);
    reg [8:0] tap; integer gs,ge;
    initial begin gs=32+({$random}%350); ge=gs+30+({$random}%80); if(ge>500) ge=500; end
    always @(posedge CLK or posedge RST) if(RST) tap<=0; else if(LOAD) tap<=CNTVALUEIN;
    always @* DATAOUT = (tap>=gs && tap<=ge) ? IDATAIN : ~IDATAIN;
endmodule

module IDDRE1 #(parameter DDR_CLK_EDGE="SAME_EDGE_PIPELINED", IS_CB_INVERTED=1'b1) (
    input D, output reg Q1,Q2, input C,CB,R
);
    always @(posedge C or posedge R) if(R) Q1<=0; else Q1<=D;
    always @(negedge C or posedge R) if(R) Q2<=0; else Q2<=D;
endmodule

module adc_spi_config #(parameter CLK_DIV_CNT=20) (
    input clk,rst_n,start_en,all_scan_done, input spi_sdo,
    output reg spi_cs_n,spi_sclk,spi_sdi,config_done,cal_trigger
);
    reg [7:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin spi_cs_n<=1;spi_sclk<=0;spi_sdi<=0;config_done<=0;cal_trigger<=0;cnt<=0; end
        else if(start_en&&all_scan_done&&!config_done) begin
            if(cnt<100) cnt<=cnt+1; else begin config_done<=1; cal_trigger<=1; end
        end else if(config_done) cal_trigger<=0;
    end
endmodule
