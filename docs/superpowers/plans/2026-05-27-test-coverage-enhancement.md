# Test Coverage Enhancement Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Add 5 high-value test items to tb_fpga_top_integrated.sv to cover end-to-end data integrity, backpressure recovery, reset resilience, real UDP path, and DDR4 wraparound.

**Architecture:** All additions go into a single file `tb_fpga_top_integrated.sv`. Each Task adds one Phase (Phase 7-11) of test logic, plus supporting infrastructure (scoreboard FIFO, CRC calculation, UDP packet builder). The CMAC stub is enhanced to support RX packet injection for real UDP path testing.

**Tech Stack:** SystemVerilog, Vivado XSIM

---

### Task 1: End-to-End CRC Scoreboard (Phase 7)

**Files:**
- Modify: `cmac_usplus_0_ex.srcs/sim_1/new/tb_fpga_top_integrated.sv`

**Design:** The ADC stub generates deterministic data: I = `{ts[31:0], sample[31:0], sample[31:0]}`, Q = `~I`. We can reconstruct the expected CMAC output from the sample counter and timestamp. Instead of storing all data (impossible for long runs), we'll compute a running CRC-32 over both the expected input data and the actual CMAC output data, then compare. This proves bit-level correctness across the DDR4 round-trip.

- [ ] **Step 1: Add CRC-32 function and scoreboard signals**

Insert after the existing `adc_pcie/` signal declarations (around line 377):

```systemverilog
    // =========================================================================
    // Phase 7: End-to-End CRC Scoreboard
    // =========================================================================
    // CRC-32 (Ethernet polynomial) for data integrity checking
    function automatic [31:0] crc32_update(input [31:0] crc, input [7:0] data);
    begin
        crc32_update = crc;
        for (int b = 0; b < 8; b++) begin
            if (crc32_update[31] ^ data[b])
                crc32_update = {crc32_update[30:0], 1'b0} ^ 32'h04C11DB7;
            else
                crc32_update = {crc32_update[30:0], 1'b0};
        end
    end
    endfunction

    function automatic [31:0] crc32_word(input [31:0] crc, input [511:0] word, input [63:0] keep);
    begin
        crc32_word = crc;
        for (int i = 0; i < 64; i++) begin
            if (keep[i])
                crc32_word = crc32_update(crc32_word, word[i*8 +: 8]);
        end
    end
    endfunction

    reg [31:0] expected_crc = 32'hFFFFFFFF;
    reg [31:0] actual_crc   = 32'hFFFFFFFF;
    reg        crc_enable   = 1'b0;
    reg [63:0] sample_count_125 = 64'd0;
    reg [63:0] timestamp_125    = 64'd0;

    // Track expected ADC data at 125MHz domain
    always @(posedge dut.clk_adc_125) begin
        if (dut.adc_ready) begin
            sample_count_125 <= sample_count_125 + 1'b1;
            timestamp_125    <= timestamp_125 + 1'b1;
        end
    end

    // Build expected CMAC beat0 from sample counter (matches ADC stub pattern)
    function automatic [511:0] build_expected_beat0(input [63:0] sample, input [63:0] ts, input [14:0] seq);
    begin
        build_expected_beat0 = {
            1'b1, seq, ts[15:0],         // sync=1, seq, ts
            ts[31:0], sample[31:0], sample[31:0],     // I0 = {ts_lo, sample_lo, sample_lo}
            {~ts[31:0]}, {~sample[31:0]}, {~sample[31:0]}, // Q0 = ~I0
            ts[31:0], (sample+1)[31:0], (sample+1)[31:0],   // I1
            {~ts[31:0]}, {~(sample+1)[31:0]}, {~(sample+1)[31:0]}, // Q1
            ts[31:0], (sample+2)[31:0], (sample+2)[31:0]    // I2 (partial)
        };
    end
    endfunction

    // Expected CRC: compute over what ADC stub would produce
    reg [63:0] exp_sample_base = 64'd0;
    reg [14:0] exp_seq = 15'd0;

    always @(posedge dut.clk_adc_125) begin
        if (crc_enable && dut.adc_ready) begin
            // ADC produces one pair (I+Q) per 125MHz cycle
            // Packer assembles 5 pairs into 2-beat burst
            // Expected beat0 = {sync=1, seq, ts[15:0], I0, Q0, I1, Q1, I2[95:0]}
            expected_crc <= crc32_word(expected_crc,
                build_expected_beat0(exp_sample_base, timestamp_125, exp_seq),
                64'hFFFF_FFFF_FFFF_FFFF);
            exp_sample_base <= exp_sample_base + 5;
            exp_seq <= exp_seq + 1;
        end
    end

    // Actual CRC: compute over CMAC TX output data
    always @(posedge dut.usr_mac_clk) begin
        if (crc_enable && dut.cmac_tx_tvalid && dut.cmac_tx_tready) begin
            actual_crc <= crc32_word(actual_crc, dut.cmac_tx_tdata, dut.cmac_tx_tkeep);
        end
    end
```

- [ ] **Step 2: Add Phase 7 test sequence**

Insert after Phase 6 (before the Summary section at line 666):

```systemverilog
        // ====== Phase 7: End-to-End CRC Integrity ======
        $display("\n  --- Phase 7: End-to-End CRC Integrity ---");
        // Reset CRC accumulators
        expected_crc = 32'hFFFFFFFF;
        actual_crc   = 32'hFFFFFFFF;
        exp_sample_base = 64'd0;
        exp_seq = 15'd0;
        crc_enable = 1'b1;

        // Run for enough cycles to accumulate at least 200 packets through DDR4
        repeat(10000) @(posedge clk_50m_in);

        crc_enable = 1'b0;
        $display("  [INFO] Expected CRC32=0x%08h  Actual CRC32=0x%08h",
                 ~expected_crc, ~actual_crc);
        pass_fail(expected_crc === actual_crc, "7a: End-to-end CRC32 match");

        // Per-packet format check (spot-check 8 more packets)
        cmac_cap_idx = 0;
        repeat(500) @(posedge clk_50m_in);
        if (cmac_cap_idx >= 2) begin
            pass_fail(cmac_cap_data[0][511] === 1'b1, "7b: Post-CRC Beat0 sync=1");
            pass_fail(cmac_cap_tlast[1] === 1'b1, "7c: Post-CRC tlast on Beat1");
        end
```

- [ ] **Step 3: Update pass/fail count expectations in Summary (line 669)**

No code change — `pass_cnt` tracks automatically.

- [ ] **Step 4: Verify syntax**

Run: `xvlog --nolog tb_fpga_top_integrated.sv`
Expected: No compile errors.

---

### Task 2: Backpressure with Data Recovery Verification (Phase 8)

**Files:**
- Modify: `cmac_usplus_0_ex.srcs/sim_1/new/tb_fpga_top_integrated.sv`

**Design:** Before forcing S2MM stall, record `wr_ptr_confirmed` and `rx_cdc_wr_count`. After stall release, wait for drain, then verify `wr_ptr_confirmed` advanced by at least the amount corresponding to the data that was in the FIFO during stall.

- [ ] **Step 1: Add Phase 8 test sequence**

Insert after Phase 7 (before Summary):

```systemverilog
        // ====== Phase 8: Backpressure + Data Recovery ======
        $display("\n  --- Phase 8: Backpressure + Data Recovery ---");
        reset_counters();

        // Let pipeline stabilize
        repeat(500) @(posedge clk_50m_in);

        // Record pre-stall state
        reg [31:0] pre_stall_wr_ptr;
        reg [11:0] pre_stall_fifo_count;
        @(posedge dut.c0_ddr4_ui_clk);
        pre_stall_wr_ptr    = dut.wr_ptr_confirmed;
        pre_stall_fifo_count = dut.rx_cdc_wr_count;
        $display("  [INFO] Pre-stall: wr_ptr=0x%08h fifo=%0d", pre_stall_wr_ptr, pre_stall_fifo_count);

        // Force S2MM stall
        force dut.s2mm_cmd_tready = 1'b0;
        repeat(2000) @(posedge clk_50m_in);

        // Record during-stall state
        reg [11:0] stall_fifo_count;
        @(posedge dut.c0_ddr4_ui_clk);
        stall_fifo_count = dut.rx_cdc_wr_count;
        $display("  [INFO] During-stall: fifo=%0d (expect > pre-stall)", stall_fifo_count);
        pass_fail(stall_fifo_count >= pre_stall_fifo_count + 4,
                  "8a: FIFO filled during stall");

        // Release stall
        release dut.s2mm_cmd_tready;
        repeat(2000) @(posedge clk_50m_in);

        // Record post-drain state
        reg [31:0] post_stall_wr_ptr;
        reg [11:0] post_stall_fifo_count;
        @(posedge dut.c0_ddr4_ui_clk);
        post_stall_wr_ptr     = dut.wr_ptr_confirmed;
        post_stall_fifo_count = dut.rx_cdc_wr_count;
        $display("  [INFO] Post-stall: wr_ptr=0x%08h fifo=%0d", post_stall_wr_ptr, post_stall_fifo_count);

        // Verify: FIFO drained
        pass_fail(post_stall_fifo_count <= 4,
                  "8b: FIFO drained after release");

        // Verify: wr_ptr advanced (data was committed to DDR4, not lost)
        reg [31:0] wr_ptr_delta = post_stall_wr_ptr - pre_stall_wr_ptr;
        $display("  [INFO] wr_ptr delta: %0d bytes (expected >= %0d)",
                 wr_ptr_delta, stall_fifo_count * 64);
        pass_fail(wr_ptr_delta >= stall_fifo_count * 64,
                  "8c: All stalled data committed to DDR4");

        // Verify: MM2S can read the recovered data
        repeat(500) @(posedge clk_50m_in);
        pass_fail(dbg_mm2s_sts_cnt > 0, "8d: MM2S reads post-stall data");
```

- [ ] **Step 2: Verify syntax**

Run: `xvlog --nolog tb_fpga_top_integrated.sv`
Expected: No compile errors.

---

### Task 3: Reset with Data Integrity (Phase 9)

**Files:**
- Modify: `cmac_usplus_0_ex.srcs/sim_1/new/tb_fpga_top_integrated.sv`

**Design:** Run CRC before soft reset, verify CRC continues to match after recovery. This proves the data pipeline is not just alive but correct after reset.

- [ ] **Step 1: Add Phase 9 test sequence**

Insert after Phase 8:

```systemverilog
        // ====== Phase 9: Reset with Data Integrity ======
        $display("\n  --- Phase 9: Reset with Data Integrity ---");

        // Pre-reset CRC
        expected_crc = 32'hFFFFFFFF;
        actual_crc   = 32'hFFFFFFFF;
        crc_enable = 1'b1;
        repeat(3000) @(posedge clk_50m_in);
        crc_enable = 1'b0;

        reg [31:0] pre_rst_expected_crc = ~expected_crc;
        reg [31:0] pre_rst_actual_crc   = ~actual_crc;
        $display("  [INFO] Pre-reset: expected=0x%08h actual=0x%08h",
                 pre_rst_expected_crc, pre_rst_actual_crc);
        pass_fail(pre_rst_expected_crc === pre_rst_actual_crc,
                  "9a: CRC match before reset");

        // Issue soft reset
        force dut.ctrl_soft_reset = 1'b1;
        repeat(10) @(posedge clk_50m_in);
        release dut.ctrl_soft_reset;

        // Wait for recovery
        repeat(300) @(posedge clk_50m_in);
        pass_fail(adc_ready_out,   "9b: ADC ready after reset");
        pass_fail(ddr4_calib_done, "9c: DDR4 stable after reset");

        // Wait for S2MM to restart
        phase3_wait_cycles = 0;
        while ((dbg_s2mm_sts_cnt == 0) && (phase3_wait_cycles < 3000)) begin
            @(posedge clk_50m_in); phase3_wait_cycles = phase3_wait_cycles + 1;
        end
        pass_fail(dbg_s2mm_sts_cnt > 0, "9d: S2MM restarted");

        // Post-reset CRC
        reset_counters();
        expected_crc = 32'hFFFFFFFF;
        actual_crc   = 32'hFFFFFFFF;
        crc_enable = 1'b1;
        repeat(3000) @(posedge clk_50m_in);
        crc_enable = 1'b0;

        $display("  [INFO] Post-reset: expected=0x%08h actual=0x%08h",
                 ~expected_crc, ~actual_crc);
        pass_fail(expected_crc === actual_crc,
                  "9e: CRC match after reset (data integrity preserved)");
```

---

### Task 4: UDP Command via Real RX Path (Phase 10)

**Files:**
- Modify: `cmac_usplus_0_ex.srcs/sim_1/new/tb_fpga_top_integrated.sv`

**Design:** Enhance the cmac_100g_wrapper stub to accept test-controlled RX packet injection. The testbench drives a properly formatted UDP command packet through the stub → rx_demux → udp_cmd_parser → real CDC path. This tests the complete control plane without `force`.

- [ ] **Step 1: Enhance cmac_100g_wrapper stub with RX injection**

Replace the existing cmac_100g_wrapper stub in the testbench (lines 698-741). The key change: add an input port for test-controlled RX data injection.

The stub already passes `m_axis_rx_tdata/tkeep/tvalid/tlast/tready` ports through. Currently `m_axis_rx_tvalid = 1'b0` (line 726). We change this to be driven by a testbench-controlled injection FSM.

Add these signals before the stub module:

```systemverilog
    // =========================================================================
    // Phase 10: UDP RX packet injection
    // =========================================================================
    reg         tb_rx_inject_go = 1'b0;
    reg  [511:0] tb_rx_pkt_data [0:7];
    reg  [63:0]  tb_rx_pkt_keep [0:7];
    reg  [2:0]   tb_rx_pkt_len = 3'd1;  // beats in packet
    wire         tb_rx_busy;
```

Replace the cmac_100g_wrapper stub with enhanced version:

```systemverilog
module cmac_100g_wrapper (
    input wire gt_ref_clk_p,gt_ref_clk_n, input wire[3:0]gt_rxp_in,gt_rxn_in,
    output wire[3:0]gt_txp_out,gt_txn_out, input wire init_clk,sys_reset,
    output reg usr_mac_clk,usr_mac_rst_n,mac_link_up,
    output reg [511:0]m_axis_rx_tdata, output reg [63:0]m_axis_rx_tkeep,
    output reg m_axis_rx_tvalid,m_axis_rx_tlast, input wire m_axis_rx_tready,
    output wire o_payload_cmd_valid, output wire[15:0]o_payload_bytes,
    input wire[511:0]s_axis_tx_tdata, input wire[63:0]s_axis_tx_tkeep,
    input wire s_axis_tx_tvalid,s_axis_tx_tlast, input wire[15:0]s_axis_tx_tuser,
    output wire s_axis_tx_tready, input wire[15:0]i_tx_payload_bytes,
    input wire tx_meta_empty, output wire o_tx_meta_rd_en, input wire[8:0]tx_pause_req,
    output wire ctrl_start_rec,ctrl_stop_rec,ctrl_start_play,ctrl_stop_play,
    output wire[31:0]ctrl_base_addr, output wire ctrl_soft_reset,
    input wire[15:0]stat_s2mm_cmd_cnt,stat_mm2s_cmd_cnt,
    input wire[11:0]stat_rx_wr_count,stat_tx_wr_count,
    input wire stat_s2mm_err,stat_mm2s_err,
    input wire[31:0]s_udp_cfg_axi_awaddr, input wire s_udp_cfg_axi_awvalid,
    output wire s_udp_cfg_axi_awready, input wire[31:0]s_udp_cfg_axi_wdata,
    input wire[3:0]s_udp_cfg_axi_wstrb, input wire s_udp_cfg_axi_wvalid,
    output wire s_udp_cfg_axi_wready, output wire[1:0]s_udp_cfg_axi_bresp,
    output wire s_udp_cfg_axi_bvalid, input wire s_udp_cfg_axi_bready,
    input wire[31:0]s_udp_cfg_axi_araddr, input wire s_udp_cfg_axi_arvalid,
    output wire s_udp_cfg_axi_arready, output wire[31:0]s_udp_cfg_axi_rdata,
    output wire[1:0]s_udp_cfg_axi_rresp, output wire s_udp_cfg_axi_rvalid,
    input wire s_udp_cfg_axi_rready,
    // Testbench RX injection ports
    input wire         tb_rx_inject_go,
    input wire [511:0] tb_rx_pkt_data [0:7],
    input wire [63:0]  tb_rx_pkt_keep [0:7],
    input wire [2:0]   tb_rx_pkt_len,
    output reg         tb_rx_busy
);
    assign gt_txp_out=4'd0;assign gt_txn_out=4'd0;
    assign o_payload_cmd_valid=1'b0;assign o_payload_bytes=16'd0;
    assign s_axis_tx_tready=1'b1;assign o_tx_meta_rd_en=1'b0;
    assign ctrl_start_rec=1'b0;assign ctrl_stop_rec=1'b0;
    assign ctrl_start_play=1'b0;assign ctrl_stop_play=1'b0;
    assign ctrl_base_addr=32'd0;assign ctrl_soft_reset=1'b0;
    assign s_udp_cfg_axi_awready=1'b0;assign s_udp_cfg_axi_wready=1'b0;
    assign s_udp_cfg_axi_bresp=2'b00;assign s_udp_cfg_axi_bvalid=1'b0;
    assign s_udp_cfg_axi_arready=1'b0;assign s_udp_cfg_axi_rdata=32'd0;
    assign s_udp_cfg_axi_rresp=2'b00;assign s_udp_cfg_axi_rvalid=1'b0;
    initial begin usr_mac_clk=1'b0;usr_mac_rst_n=1'b0;mac_link_up=1'b0; end
    always #1.553 usr_mac_clk=~usr_mac_clk;
    always @(posedge usr_mac_clk or posedge sys_reset)
        if(sys_reset)begin usr_mac_rst_n<=1'b0;mac_link_up<=1'b0;end
        else          begin usr_mac_rst_n<=1'b1;mac_link_up<=1'b1;end

    // ==== RX Injection FSM ====
    reg [2:0] rx_beat;
    always @(posedge usr_mac_clk) begin
        if (sys_reset || !usr_mac_rst_n) begin
            m_axis_rx_tvalid <= 1'b0;
            m_axis_rx_tdata  <= 512'd0;
            m_axis_rx_tkeep  <= 64'd0;
            m_axis_rx_tlast  <= 1'b0;
            tb_rx_busy       <= 1'b0;
            rx_beat          <= 3'd0;
        end else if (tb_rx_inject_go && !tb_rx_busy) begin
            tb_rx_busy       <= 1'b1;
            rx_beat          <= 3'd0;
            m_axis_rx_tvalid <= 1'b1;
            m_axis_rx_tdata  <= tb_rx_pkt_data[0];
            m_axis_rx_tkeep  <= tb_rx_pkt_keep[0];
            m_axis_rx_tlast  <= (tb_rx_pkt_len == 3'd1);
        end else if (tb_rx_busy && m_axis_rx_tvalid && m_axis_rx_tready) begin
            if (m_axis_rx_tlast) begin
                m_axis_rx_tvalid <= 1'b0;
                tb_rx_busy       <= 1'b0;
            end else begin
                rx_beat <= rx_beat + 1'b1;
                m_axis_rx_tdata <= tb_rx_pkt_data[rx_beat + 1'b1];
                m_axis_rx_tkeep <= tb_rx_pkt_keep[rx_beat + 1'b1];
                m_axis_rx_tlast <= (rx_beat + 1'b1 == tb_rx_pkt_len - 3'd1);
            end
        end
    end
endmodule
```

- [ ] **Step 2: BUGFIX — Remove 2D array ports from stub**

SystemVerilog module ports can't be unpacked 2D arrays that are passed positionally. Convert `tb_rx_pkt_data` and `tb_rx_pkt_keep` to flattened 1D ports and use a helper function to index.

**Revised approach — simpler:** Instead of passing array ports, pass a simple `go` flag and build the packet data from the testbench side using force on a simpler injection mechanism. Or better: just use 8 separate input ports for each beat.

Actually, the simplest approach: make the stub accept a single 512b data word + a beat index, using a simple state machine. The testbench sets the data for each beat before pulsing `go`.

**Revised stub additions (minimal):**
```systemverilog
    // Testbench RX injection ports (simple interface)
    input wire         tb_rx_go,           // pulse to start injection
    input wire [511:0] tb_rx_data,         // data for current beat
    input wire [63:0]  tb_rx_keep,         // keep for current beat
    input wire [2:0]   tb_rx_beats,        // total beats in packet
    output reg         tb_rx_busy,         // 1 = injection in progress
    output reg         tb_rx_ack           // pulse: ready for next beat data
);
```

Then in the testbench, we load each beat's data and pulse `go` once per beat. But this is getting complex. Let me use a simpler approach.

**Simplest approach:** Add a single port `tb_rx_data_valid` that, when pulsed, injects a complete pre-formatted UDP packet from a fixed array inside the stub. The testbench just needs to set up the packet content beforehand via a separate mechanism.

Actually the SIMPLEST approach that avoids port complexity: use `force` on the internal RX signals of the stub. But that's back to force...

OK, let me think about this differently. The cmac_100g_wrapper stub output `m_axis_rx_*` signals go to the DUT's `rx_demux`. In the real tb, these come from the stub. For Phase 10, we can:

1. Keep the stub as-is
2. Create a small task in the testbench that uses `force` on `dut.u_cmac.u_demux.s_axis_tdata` etc. Wait, that goes back to force...

The cleanest approach without force and without complex port changes: add a simple RX inject port to the stub module that takes go/data/keep/last directly:

```systemverilog
    input wire         tb_rx_valid,    // active-high: inject this beat
    input wire [511:0] tb_rx_data,
    input wire [63:0]  tb_rx_keep,
    input wire         tb_rx_last
```

The stub drives m_axis_rx_* from tb_rx_* when tb_rx_valid is high, otherwise drives 0. The testbench task sends each beat of the UDP packet. Simple and clean.

- [ ] **Step 2 (revised): Simple port-based RX injection**

In the cmac_100g_wrapper stub, replace the `m_axis_rx_*` assignments with:

```systemverilog
    // Testbench RX injection
    input wire         tb_rx_valid,
    input wire [511:0] tb_rx_tdata,
    input wire [63:0]  tb_rx_tkeep,
    input wire         tb_rx_tlast,
    output reg         tb_rx_ready
);
    // ... existing code ...
    // Replace: assign m_axis_rx_tvalid=1'b0; etc.
    always @(posedge usr_mac_clk) begin
        if (sys_reset) begin
            m_axis_rx_tvalid <= 1'b0;
            tb_rx_ready      <= 1'b0;
        end else begin
            tb_rx_ready      <= !m_axis_rx_tvalid || m_axis_rx_tready;
            if (tb_rx_valid && tb_rx_ready) begin
                m_axis_rx_tvalid <= 1'b1;
                m_axis_rx_tdata  <= tb_rx_tdata;
                m_axis_rx_tkeep  <= tb_rx_tkeep;
                m_axis_rx_tlast  <= tb_rx_tlast;
            end else if (m_axis_rx_tvalid && m_axis_rx_tready) begin
                m_axis_rx_tvalid <= 1'b0;
            end
        end
    end
```

- [ ] **Step 3: Connect new ports in DUT instance**

In the `fpga_top_integrated dut(...)` instance, add:
```systemverilog
        .tb_rx_valid(tb_rx_valid),
        .tb_rx_tdata(tb_rx_tdata),
        .tb_rx_tkeep(tb_rx_tkeep),
        .tb_rx_tlast(tb_rx_tlast),
        .tb_rx_ready(tb_rx_ready)
```

BUT WAIT — these ports are on the cmac_100g_wrapper stub in the testbench, not on the DUT. The stub is instantiated inside the DUT as `u_cmac`. So we need to add these ports to the DUT itself and pass them through to u_cmac.

Actually, let me re-check the architecture. The testbench instantiates:
```systemverilog
fpga_top_integrated dut(...);
```

And fpga_top_integrated instantiates:
```systemverilog
cmac_100g_wrapper u_cmac(...);
```

For the testbench to inject into the stub, we'd need:
1. Add ports to fpga_top_integrated module
2. Pass them through to u_cmac

This means modifying both fpga_top_integrated.sv (to add pass-through ports) and the testbench (to wire them).

Alternatively, since the stub is defined INSIDE the testbench file (lines 698+), it replaces the real cmac_100g_wrapper at compile time. But the DUT is instantiated from the compiled library... 

Actually, in Vivado simulation, the stub is defined in the testbench file with the same module name `cmac_100g_wrapper`. Since SystemVerilog resolves modules by name, the stub definition takes precedence over the compiled DUT's version. So the DUT's `u_cmac` instance will bind to the testbench's stub module.

But the DUT's fpga_top_integrated module instantiates `cmac_100g_wrapper u_cmac(...)` with a specific port list. If we add new ports to the stub, we'd need to add them to the DUT's instance too, which means modifying fpga_top_integrated.sv.

This is getting complicated. For Phase 10, I'll keep it simple: DON'T modify the cmac_100g_wrapper stub's port list. Instead, use a shared variable or a different mechanism.

**ACTUALLY THE SIMPLEST APPROACH:** Don't modify the stub at all. Instead, directly drive the DUT's `rx_demux` input from the testbench using hierarchical reference. This is still force-based BUT it's driving the RX data signals rather than the control signals:

```systemverilog
// Phase 10: UDP command via RX path
task inject_udp_packet(input [47:0] dst_mac, input [47:0] src_mac,
                       input [31:0] dst_ip, input [31:0] src_ip,
                       input [15:0] dst_port, input [15:0] src_port,
                       input [7:0] cmd_byte, input [31:0] addr_word);
begin
    // Build minimal UDP packet (single beat, 42B header + payload)
    // Full packet: ETH(14) + IP(20) + UDP(8) + 4B cmd = 46B
    // This fits in one 512-bit beat
    
    // Wait for demux to be in IDLE (not mid-packet)
    @(posedge dut.usr_mac_clk);
    
    // Drive one beat through the rx_demux input
    force dut.u_cmac.u_demux.s_axis_tdata  = build_udp_cmd_pkt(...);
    force dut.u_cmac.u_demux.s_axis_tkeep  = 64'h0000_3FFF_FFFF_FFFF;  // 46 bytes
    force dut.u_cmac.u_demux.s_axis_tvalid = 1'b1;
    force dut.u_cmac.u_demux.s_axis_tlast  = 1'b1;
    
    // Wait for demux to accept (u_demux routes to ch3 -> udp_cmd_parser)
    @(posedge dut.usr_mac_clk);
    force dut.u_cmac.u_demux.s_axis_tvalid = 1'b0;
    release dut.u_cmac.u_demux.s_axis_tdata;
    release dut.u_cmac.u_demux.s_axis_tkeep;
    release dut.u_cmac.u_demux.s_axis_tvalid;
    release dut.u_cmac.u_demux.s_axis_tlast;
end
endtask
```

Actually this still uses `force` which the review criticized. But it forces at the demux INPUT, which is more realistic than forcing control signals (ctrl_start_rec etc.) directly. The rx_demux → udp_cmd_parser path is exercised.

But there's a fundamental issue: the CMAC stub outputs `m_axis_rx_tvalid = 0`. u_demux is driven by the stub's m_axis_rx_* outputs (through u_cmac in the DUT). The DUT's internal u_cmac is the real cmac_100g_wrapper (compiled from the RTL), not the stub. The stub only exists in the testbench scope.

Wait, Vivado's compiled simulation... when we compile the design, Vivado compiles the real cmac_100g_wrapper.sv from the design sources. When we compile the testbench, the stub module `cmac_100g_wrapper` in the tb file has the same name. In SystemVerilog, if two modules have the same name, it's an error unless one overrides the other (through library precedence).

In Vivado xsim, the testbench module takes precedence. So u_cmac inside fpga_top_integrated will bind to the TB stub, NOT the real RTL. This is the intended behavior for simulation acceleration.

So `dut.u_cmac` IS the stub. The stub's net_rx_* signals (internal to the real cmac_100g_wrapper) don't exist — only the ports exist. We can't force internal signals of the real wrapper because it's replaced by the stub.

OK, let me just go with the simplest approach that works: No port changes, no force. Just build the UDP packet in a task and write it to a $fopen file or use shared variables.

Actually, for the PLAN, let me just describe the approach and let the implementer figure out the details. The key requirement is: "test the real UDP command path (rx_demux → udp_cmd_parser → CDC) without using force on control signals."

Let me take a pragmatic approach in the plan and specify what to test, giving a clear but flexible implementation strategy.

Let me just write the plan and move on. Time is being wasted on over-thinking this. I'll specify the simplest approach: add inject ports to the cmac stub.<｜end▁of▁thinking｜>这个计划太长太复杂，我把 5 个测试直接写成最终计划，让 agent 执行。

<｜｜DSML｜｜tool_calls>
<｜｜DSML｜｜invoke name="Write">
<｜｜DSML｜｜parameter name="content" string="true"># Test Coverage Enhancement Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development.

**Goal:** Add 5 high-value test Phases (7-11) to tb_fpga_top_integrated.sv

**Architecture:** Single file modification. Add CRC-32 scoreboard infrastructure, then 5 new test phases. For Phase 10 (UDP real path), add RX injection ports to the cmac_100g_wrapper stub and pass them through fpga_top_integrated.

**Tech Stack:** SystemVerilog, Vivado XSIM

**File to modify:** `cmac_usplus_0_ex.srcs/sim_1/new/tb_fpga_top_integrated.sv`

---
