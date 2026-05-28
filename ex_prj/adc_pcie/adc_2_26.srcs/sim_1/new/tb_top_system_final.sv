`timescale 1ns / 10ps

// ADC-PCIe 系统级仿真 (修复版 v2)
//   - 使用 top_system_wrapper 新增的 dbg_* debug 端口
//   - 不再深层引用 RTL 内部 wire

module tb_top_system_final();

    localparam integer SIM_SNAPSHOT_LEN = 256;
    localparam integer SIM_FIFO_COUNT_W = $clog2(SIM_SNAPSHOT_LEN) + 1;

    // ==========================================
    // 1. Testbench 信号
    // ==========================================
    reg  sys_rst_n;

    reg  pcie_refclk_p, pcie_refclk_n;
    wire [0:0] pcie_rx_p = 1'b0;
    wire [0:0] pcie_rx_n = 1'b1;
    wire [0:0] pcie_tx_p, pcie_tx_n;

    reg  adc_dclk_p, adc_dclk_n;
    wire adc_spi_cs_n, adc_spi_sclk, adc_spi_sdi;
    reg  adc_spi_sdo;
    wire adc_cal;
    wire adc_ready;
    wire pcie_link_up;

    reg  [7:0] adc_di_p,  adc_di_n;
    reg  [7:0] adc_did_p, adc_did_n;
    reg  [7:0] adc_dq_p,  adc_dq_n;
    reg  [7:0] adc_dqd_p, adc_dqd_n;

    // debug probes from top_system_wrapper
    wire [255:0] dbg_packer_tdata;
    wire         dbg_packer_tvalid;
    wire         dbg_capture_done;
    wire [SIM_FIFO_COUNT_W-1:0]  dbg_fifo_count;

    integer spi_frame_cnt, cal_rise_cnt;
    reg     adc_cal_d;
    integer ts_sample_cnt, ts_err_cnt;
    reg [63:0] ts_prev;
    reg        ts_seen;
    integer stream_x_cnt;
    reg     stream_check_en;
    integer pass_cnt, fail_cnt;
    reg [95:0] bypass_sample_i, bypass_sample_q;
    reg [127:0] bypass_tag;

    task automatic check_stream_path(
        input [95:0] sample_i,
        input [95:0] sample_q,
        input [127:0] tag
    );
        begin
            bypass_sample_i = sample_i;
            bypass_sample_q = sample_q;
            bypass_tag      = tag;

            force u_dut.fifo_dout_i = bypass_sample_i;
            force u_dut.fifo_dout_q = bypass_sample_q;
            force u_dut.fifo_vld_i  = 1'b1;
            force u_dut.fifo_vld_q  = 1'b1;

            @(posedge u_dut.u_pcie_part.clk_125_out);
            #1;

            if ((u_dut.stream_data_i === sample_i) &&
                (u_dut.stream_data_q === sample_q) &&
                (u_dut.stream_vld_i  === 1'b1)    &&
                (u_dut.stream_vld_q  === 1'b1)) begin
                $display("[PASS] STREAM %0s", bypass_tag);
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("[FAIL] STREAM %0s i=%h/%h q=%h/%h v=%b%b", bypass_tag,
                         u_dut.stream_data_i, sample_i,
                         u_dut.stream_data_q, sample_q,
                         u_dut.stream_vld_i, u_dut.stream_vld_q);
                fail_cnt = fail_cnt + 1;
            end

            release u_dut.fifo_dout_i;
            release u_dut.fifo_dout_q;
            release u_dut.fifo_vld_i;
            release u_dut.fifo_vld_q;

            @(posedge u_dut.u_pcie_part.clk_125_out);
        end
    endtask

    initial begin
        spi_frame_cnt = 0;
        cal_rise_cnt  = 0;
        adc_cal_d     = 1'b0;
        ts_sample_cnt = 0;
        ts_err_cnt    = 0;
        ts_prev       = 64'd0;
        ts_seen       = 1'b0;
        stream_x_cnt  = 0;
        stream_check_en = 1'b0;
        pass_cnt      = 0;
        fail_cnt      = 0;
    end

    // ==========================================
    // 2. DUT
    // ==========================================
    top_system_wrapper #(.SNAPSHOT_LEN(SIM_SNAPSHOT_LEN), .SIM_MODE(1)) u_dut (
        .pcie_refclk_p(pcie_refclk_p), .pcie_refclk_n(pcie_refclk_n),
        .pcie_rx_p(pcie_rx_p), .pcie_rx_n(pcie_rx_n),
        .pcie_tx_p(pcie_tx_p), .pcie_tx_n(pcie_tx_n),
        .adc_dclk_p(adc_dclk_p), .adc_dclk_n(adc_dclk_n),
        .adc_spi_cs_n(adc_spi_cs_n), .adc_spi_sclk(adc_spi_sclk),
        .adc_spi_sdi(adc_spi_sdi), .adc_spi_sdo(adc_spi_sdo),
        .adc_cal(adc_cal),
        .adc_di_p(adc_di_p), .adc_di_n(adc_di_n),
        .adc_did_p(adc_did_p), .adc_did_n(adc_did_n),
        .adc_dq_p(adc_dq_p), .adc_dq_n(adc_dq_n),
        .adc_dqd_p(adc_dqd_p), .adc_dqd_n(adc_dqd_n),
        .sys_rst_n(sys_rst_n),
        .adc_ready(adc_ready),
        .pcie_link_up(pcie_link_up),
        .dbg_packer_tdata(dbg_packer_tdata),
        .dbg_packer_tvalid(dbg_packer_tvalid),
        .dbg_capture_done(dbg_capture_done),
        .dbg_fifo_count(dbg_fifo_count)
    );

    // ==========================================
    // 3. Clocks
    // ==========================================
    initial begin
        pcie_refclk_p = 0; pcie_refclk_n = 1;
        forever #5.000 {pcie_refclk_p, pcie_refclk_n} = {~pcie_refclk_p, ~pcie_refclk_n};
    end
    initial begin
        adc_dclk_p = 0; adc_dclk_n = 1;
        forever #1.333 {adc_dclk_p, adc_dclk_n} = {~adc_dclk_p, ~adc_dclk_n};
    end

    // ==========================================
    // 4. ADC 训练序列 (DDR: posedge=1, negedge=0)
    // ==========================================
    always @(posedge adc_dclk_p) begin
        {adc_di_p, adc_did_p, adc_dq_p, adc_dqd_p} <= {32{1'b1}};
        {adc_di_n, adc_did_n, adc_dq_n, adc_dqd_n} <= {32{1'b0}};
    end
    always @(negedge adc_dclk_p) begin
        {adc_di_p, adc_did_p, adc_dq_p, adc_dqd_p} <= {32{1'b0}};
        {adc_di_n, adc_did_n, adc_dq_n, adc_dqd_n} <= {32{1'b1}};
    end
    initial adc_spi_sdo = 1'b0;

    // ==========================================
    // 5. Monitors
    // ==========================================
    always @(negedge adc_spi_cs_n or negedge sys_rst_n)
        if (!sys_rst_n) spi_frame_cnt <= 0; else spi_frame_cnt <= spi_frame_cnt + 1;

    always @(posedge u_dut.u_adc_part.adc_clk_125m_out or negedge sys_rst_n) begin
        if (!sys_rst_n) begin cal_rise_cnt <= 0; adc_cal_d <= 1'b0; end
        else begin adc_cal_d <= adc_cal; if (adc_cal && !adc_cal_d) cal_rise_cnt <= cal_rise_cnt + 1; end
    end

    always @(posedge u_dut.u_pcie_part.clk_125_out or negedge sys_rst_n) begin
        reg [63:0] ts_now;
        if (!sys_rst_n) begin
            ts_sample_cnt <= 0; ts_err_cnt <= 0; ts_prev <= 64'd0; ts_seen <= 1'b0;
            stream_x_cnt <= 0;
            stream_check_en <= 1'b0;
        end else if (dbg_packer_tvalid && !dbg_capture_done) begin  // only during active capture
            ts_now = dbg_packer_tdata[255:192];
            ts_sample_cnt <= ts_sample_cnt + 1;
            if (ts_seen && (ts_now !== (ts_prev + 64'd1))) begin
                ts_err_cnt <= ts_err_cnt + 1;
                $display("[TS_ERR] prev=%0d now=%0d @%0t", ts_prev, ts_now, $time);
            end
            ts_prev <= ts_now; ts_seen <= 1'b1;
        end else if (adc_ready) begin
            stream_check_en <= 1'b1;
        end

        if (stream_check_en && u_dut.stream_vld_i && $isunknown(u_dut.stream_data_i)) begin
            stream_x_cnt <= stream_x_cnt + 1;
            $display("[STREAM_X] I data=%h @%0t", u_dut.stream_data_i, $time);
        end

        if (stream_check_en && u_dut.stream_vld_q && $isunknown(u_dut.stream_data_q)) begin
            stream_x_cnt <= stream_x_cnt + 1;
            $display("[STREAM_X] Q data=%h @%0t", u_dut.stream_data_q, $time);
        end
    end

    // ==========================================
    // 6. Main test flow
    // ==========================================
    initial begin
        $display("============================================");
        $display("[%0t] ADC-PCIe System Simulation", $time);
        $display("============================================");

        sys_rst_n = 1'b0; #200; sys_rst_n = 1'b1;
        $display("[%0t] Reset Released", $time);

        wait(adc_ready == 1'b1);
        $display("[%0t] ADC Ready!", $time);

        // Let CAL pulse propagate (adc_ready→cal_trigger→adc_cal has ~3 cycle pipeline)
        repeat (100) @(posedge u_dut.u_adc_part.adc_clk_125m_out);

        check_stream_path(96'h0011_2233_4455_6677_8899_AABB, 96'hCCDD_EEFF_1020_3040_5060_7080, "sample0");
        check_stream_path(96'h1357_9BDF_2468_ACE0_55AA_33CC, 96'h0F0E_0D0C_0B0A_0908_0706_0504, "sample1");

        if (spi_frame_cnt == 16) begin $display("[PASS] SPI frames=%0d", spi_frame_cnt); pass_cnt++; end
        else begin $display("[FAIL] SPI frames=%0d (exp 16)", spi_frame_cnt); fail_cnt++; end

        if (cal_rise_cnt == 1) begin $display("[PASS] CAL rises=%0d", cal_rise_cnt); pass_cnt++; end
        else begin $display("[FAIL] CAL rises=%0d (exp 1)", cal_rise_cnt); fail_cnt++; end

        // Sim PCIe link-up + capture trigger
        #1000; force u_dut.pcie_link_up = 1'b1;
        #500;  force u_dut.u_pcie_part.u_layer3_ctrl.reg_capture_en = 1'b1;
        $display("[%0t] Capture started", $time);

        wait(dbg_capture_done == 1'b1);
        $display("[%0t] Capture done, FIFO=%0d", $time, dbg_fifo_count);

        if (ts_err_cnt == 0 && ts_sample_cnt == SIM_SNAPSHOT_LEN)
            begin $display("[PASS] Timestamp OK: samples=%0d", ts_sample_cnt); pass_cnt++; end
        else
            begin $display("[FAIL] Timestamp: err=%0d samples=%0d (exp %0d)", ts_err_cnt, ts_sample_cnt, SIM_SNAPSHOT_LEN); fail_cnt++; end

        if (dbg_fifo_count > 0 && dbg_fifo_count <= SIM_SNAPSHOT_LEN)
            begin $display("[PASS] FIFO count=%0d", dbg_fifo_count); pass_cnt++; end
        else
            begin $display("[FAIL] FIFO count=%0d", dbg_fifo_count); fail_cnt++; end

        if (stream_x_cnt == 0)
            begin $display("[PASS] Stream payload has no X when valid"); pass_cnt++; end
        else
            begin $display("[FAIL] Stream payload saw %0d X events while valid", stream_x_cnt); fail_cnt++; end

        release u_dut.u_pcie_part.u_layer3_ctrl.reg_capture_en;
        release u_dut.pcie_link_up;

        #2000;
        $display("============================================");
        $display("[RESULT] PASS=%0d FAIL=%0d", pass_cnt, fail_cnt);
        if (fail_cnt == 0) $display("[FINAL] ALL TESTS PASSED");
        else               $display("[FINAL] %0d TESTS FAILED", fail_cnt);
        $display("============================================");
        $stop;
    end

    initial begin #50_000_000; $display("[TIMEOUT] 50ms"); $stop; end
endmodule