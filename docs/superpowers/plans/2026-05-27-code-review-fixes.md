# Code Review 修复计划 — 2026-05-27

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 修复代码审查发现的 4 Critical + 7 Important 问题

**Architecture:** 按文件分组修复，每个 Task 对应一个文件。先修 Critical（C1-C4），再修 Important（I1-I7）。C2/I2/I4 三个 issue 都在 fpga_top_integrated.sv 中，合并到同一个 Task。

**Tech Stack:** SystemVerilog, Vivado 2025.2, XSIM

**Base path:** `cmac_usplus_0_ex.srcs/sources_1/new/`

---

### Task 1: 修复 C1 — ddr4_subsystem_top.sv RX CDC FIFO wr_rst_busy 保护

**Files:**
- Modify: `cmac_usplus_0_ex.srcs/sources_1/new/ddr4_subsystem_top.sv`

- [ ] **Step 1: 读取文件确认当前代码**

当前 `ddr4_subsystem_top.sv` 中 RX CDC FIFO 实例化缺少 `wr_rst_busy` / `rd_rst_busy` 端口连接，`S_AXIS_RX_tready` 仅用 `!rx_fifo_full` 门控。

- [ ] **Step 2: 修改 FIFO 实例化，连接 rst_busy 信号**

找到 `xpm_fifo_async` 实例化的 RX CDC FIFO（搜索 `RX_CDC_FIFO` 或 `xpm_fifo_async`），添加：

```systemverilog
// 在实例化参数中添加：
.USE_ADV_FEATURES("1000"),       // 使能 wr_rst_busy / rd_rst_busy 输出

// 在端口连接中添加：
.wr_rst_busy(rx_fifo_wr_rst_busy),
.rd_rst_busy(rx_fifo_rd_rst_busy),

// 在模块内部声明 wire：
wire rx_fifo_wr_rst_busy;
wire rx_fifo_rd_rst_busy;
```

- [ ] **Step 3: 修改 tready 和 read enable 门控**

```systemverilog
// 将：
assign S_AXIS_RX_tready = !rx_fifo_full;

// 改为：
assign S_AXIS_RX_tready = !rx_fifo_full && !rx_fifo_wr_rst_busy;

// 同样门控读侧：
assign bd_s2mm_tvalid = !rx_fifo_empty && !rx_fifo_rd_rst_busy;
```

- [ ] **Step 4: 验证语法**

Run: `cd cmac_usplus_0_ex && xvlog --nolog ../cmac_usplus_0_ex.srcs/sources_1/new/ddr4_subsystem_top.sv`
Expected: 无编译错误

- [ ] **Step 5: Commit**

```bash
git add cmac_usplus_0_ex.srcs/sources_1/new/ddr4_subsystem_top.sv
git commit -m "fix(ddr4): add wr_rst_busy/rd_rst_busy guard on RX CDC FIFO tready"
```

---

### Task 2: 修复 C2/I2/I4 — fpga_top_integrated.sv (3 issues)

**Files:**
- Modify: `cmac_usplus_0_ex.srcs/sources_1/new/fpga_top_integrated.sv`

- [ ] **Step 1: 读取文件确认当前代码**

C2: `adc_fifo_rst = ~adc_rst_n || ~usr_mac_rst_n;` — 双域组合 OR
I2: `soft_rst_cnt` 4-bit 在 0 时减 1 会绕回 15
I4: `ctrl_base_addr` wire 未连接到 S2MM base address

- [ ] **Step 2: 修复 C2 — ADC CDC FIFO 复位去毛刺**

搜索 `adc_fifo_rst`，将组合逻辑的 OR 改为经同步的版本：

```systemverilog
// 原代码：
// assign adc_fifo_rst = ~adc_rst_n || ~usr_mac_rst_n;

// 修复：将 usr_mac_clk 域复位同步到 clk_adc_125 域后再 OR
(* ASYNC_REG = "TRUE" *) reg [1:0] mac_rst_sync_125 = 2'b11;
always_ff @(posedge clk_adc_125) begin
    mac_rst_sync_125 <= {mac_rst_sync_125[0], ~usr_mac_rst_n};
end
wire adc_fifo_rst = ~adc_rst_n || mac_rst_sync_125[1];
```

注意：`clk_adc_125` 和 `usr_mac_rst_n` 信号名需与文件中实际名称匹配。检查 usr_mac_rst_n 的连接源（来自 cmac_100g_wrapper 的 `usr_mac_rst_n` 输出或 `mac_rst_n` 端口名）。

- [ ] **Step 3: 修复 I2 — soft_rst_cnt 回绕**

搜索 `soft_rst_cnt`，将减法回绕改为显式停止：

```systemverilog
// 原代码类似：
// else if (soft_rst_active)
//     soft_rst_cnt <= soft_rst_cnt - 1'b1;

// 修复：
else if (soft_rst_active) begin
    if (soft_rst_cnt == 0)
        soft_rst_active <= 1'b0;
    else
        soft_rst_cnt <= soft_rst_cnt - 1'b1;
end
```

- [ ] **Step 4: 修复 I4 — ctrl_base_addr 死信号（移除或连接）**

搜索 `ctrl_base_addr` 在 fpga_top_integrated.sv 中的位置：

**方案 A（推荐）**: 移除死信号。在 cmac_100g_wrapper 实例化的端口连接中注释掉 `ctrl_base_addr`，在声明中删除该 wire。

**方案 B**: 如果 BASE_ADDR 命令需要实际生效，将 `ctrl_base_addr` 连接到 S2MM 写地址生成器，替换 `DDR4_BUF_BASE` 参数。但这需要增加寄存器逻辑。

选择方案 A：删除 `ctrl_base_addr` wire 声明和端口连接（该信号从 cmac_100g_wrapper → udp_cmd_parser 输出，在 fpga_top_integrated 层只是经过但不使用）。

实际上 `ctrl_base_addr` 是 `cmac_100g_wrapper` 的输出端口，从 `udp_cmd_parser` 来。在 `fpga_top_integrated` 中，`ctrl_base_addr` 定义为 wire 但未连接到任何地方。确认它是悬空的，然后删除 wire 声明即可，或者在 cmac_100g_wrapper 实例化时用 `/* unused */` 标注。

- [ ] **Step 5: 验证语法**

Run: `xvlog --nolog ../cmac_usplus_0_ex.srcs/sources_1/new/fpga_top_integrated.sv`
Expected: 无编译错误

- [ ] **Step 6: Commit**

```bash
git add cmac_usplus_0_ex.srcs/sources_1/new/fpga_top_integrated.sv
git commit -m "fix(top): fix ADC FIFO reset glitch, soft_rst_cnt wrap, and dead ctrl_base_addr"
```

---

### Task 3: 修复 C3 — rx_demux.sv 路由逻辑去重

**Files:**
- Modify: `cmac_usplus_0_ex.srcs/sources_1/new/rx_demux.sv`

- [ ] **Step 1: 读取文件确认当前代码**

`route_target` 的 `always_comb` 块和 `state` 的 `always_ff` 块包含相同的路由判断逻辑。

- [ ] **Step 2: 提取统一的 next_state 组合逻辑**

```systemverilog
// 新增：统一的路由目标计算，替换分散的 route_target 和 state 更新
wire state_t route_target_next;
always_comb begin
    unique casez ({err_in_frame, s_axis_tvalid, state})
        // IDLE 状态：根据首拍协议字段决定目标
        {1'b?, 1'b1, IDLE}: begin
            if (err_in_frame)
                route_target_next = DRAIN;
            else if (eth_type_class == 16'h0806)
                route_target_next = PASS_M0;
            else if (eth_type_class == 16'h0800 && ip_proto == 8'h01 && ipv4_to_local)
                route_target_next = PASS_M1;
            else if (eth_type_class == 16'h0800 && ip_proto == 8'h11 && ipv4_to_local)
                route_target_next = is_udp_cmd ? PASS_M3 : PASS_M2;
            else
                route_target_next = DRAIN;
        end
        // 包中间：保持当前通道
        default: route_target_next = state;
    endcase
end
```

- [ ] **Step 3: 用统一的 route_target_next 替换 state 更新逻辑**

```systemverilog
// 简化后的 always_ff state 更新：
always_ff @(posedge clk) begin
    if (!rst_n) begin
        state <= IDLE;
    end else begin
        if (s_axis_tvalid && s_axis_tlast)
            state <= IDLE;
        else if (s_axis_tvalid && state == IDLE)
            state <= route_target_next;
        // else: state 保持不变
    end
end
```

- [ ] **Step 4: 删除废弃的 route_target 声明和 always_comb 块**

移除原来的 `state_t state, route_target;` 声明中的 `route_target`，删除原来的 `always_comb begin ... route_target = ... end` 块。

- [ ] **Step 5: 更新输出流水线中的 route_target 引用**

将 `case (route_target)` 改为 `case (route_target_next)`。注意流水线延迟：输出寄存器用 `s_axis_tvalid && !block_out` 门控，此时 `route_target_next` 已稳定。

实际仔细看：原来的代码中 `route_target` 是组合逻辑，在 `always_ff` 输出块中用 `case(route_target)` 选择通道。合并后直接用 `route_target_next` 替代即可，因为它是纯组合信号，在同一个时钟沿被采样。

- [ ] **Step 6: 验证语法**

Run: `xvlog --nolog ../cmac_usplus_0_ex.srcs/sources_1/new/rx_demux.sv`
Expected: 无编译错误

- [ ] **Step 7: Commit**

```bash
git add cmac_usplus_0_ex.srcs/sources_1/new/rx_demux.sv
git commit -m "fix(rx_demux): deduplicate route logic into single combinational block"
```

---

### Task 4: 修复 C4 — udp_cmd_parser.sv 防止静默丢命令

**Files:**
- Modify: `cmac_usplus_0_ex.srcs/sources_1/new/udp_cmd_parser.sv`

- [ ] **Step 1: 修改 s_axis_tready**

```systemverilog
// 将：
assign s_axis_tready = 1'b1;

// 改为：
assign s_axis_tready = (state == ST_IDLE);
```

仅当 FSM 处于 IDLE 状态（可以处理新命令）时才告知上游就绪。

- [ ] **Step 2: 验证语法**

Run: `xvlog --nolog ../cmac_usplus_0_ex.srcs/sources_1/new/udp_cmd_parser.sv`
Expected: 无编译错误

- [ ] **Step 3: Commit**

```bash
git add cmac_usplus_0_ex.srcs/sources_1/new/udp_cmd_parser.sv
git commit -m "fix(cmd_parser): gate s_axis_tready with IDLE state to prevent silent drop"
```

---

### Task 5: 修复 I1 — ddr4_readout_demux.sv PCIe 通路携带 tlast

**Files:**
- Modify: `cmac_usplus_0_ex.srcs/sources_1/new/ddr4_readout_demux.sv`

- [ ] **Step 1: 读取文件确认当前 PCIe FIFO 实例化**

确认 PCIe CDC FIFO 当前只存储 512b tdata。

- [ ] **Step 2: 扩展 FIFO 宽度到 513b (512b data + 1b tlast)**

```systemverilog
// 将 FIFO WRITE_DATA_WIDTH / READ_DATA_WIDTH 从 512 改为 513：
.WRITE_DATA_WIDTH(513),
.READ_DATA_WIDTH(513),

// din 添加 tlast：
.din({s_axis_tlast, s_axis_tdata}),

// dout 解析出 tlast：
wire pcie_fifo_tlast;
wire [511:0] pcie_fifo_tdata;
assign {pcie_fifo_tlast, pcie_fifo_tdata} = fifo_dout;
```

- [ ] **Step 3: 在 PCIE_SEND 状态使用 fifo tlast**

在 PCIE_SEND 状态中，用 `pcie_fifo_tlast` 驱动 `pcie_c2h_tlast`（在合适的子拍时机）。

```systemverilog
// PCIE_SEND 状态中，tlast 由 FIFO 的 pcie_fifo_tlast 决定：
pcie_c2h_tlast <= (sub_beat_cnt == last_sub_beat) && pcie_fifo_tlast;
```

- [ ] **Step 4: 验证语法**

Run: `xvlog --nolog ../cmac_usplus_0_ex.srcs/sources_1/new/ddr4_readout_demux.sv`
Expected: 无编译错误

- [ ] **Step 5: Commit**

```bash
git add cmac_usplus_0_ex.srcs/sources_1/new/ddr4_readout_demux.sv
git commit -m "fix(ddr4_readout): extend PCIe FIFO to carry tlast for proper packet termination"
```

---

### Task 6: 修复 I5 — cmac_axi_master.sv 延迟提前退出

**Files:**
- Modify: `cmac_usplus_0_ex.srcs/sources_1/new/cmac_axi_master.sv`

- [ ] **Step 1: 添加 gt_powergoodout 输入端口**

在模块端口中添加：
```systemverilog
input wire [3:0] gt_powergoodout,  // GT 电源状态，全 1 表示 GT 复位完成
```

- [ ] **Step 2: 修改 ST_DELAY 退出条件**

```systemverilog
// 将：
if (delay_cnt == 24'hFFFFFF)
    state <= ST_WR_RSFEC_EN;

// 改为：
if (delay_cnt == 24'hFFFFFF || &gt_powergoodout)
    state <= ST_WR_RSFEC_EN;
```

- [ ] **Step 3: 在 cmac_100g_wrapper 中连接 gt_powergoodout**

在 `cmac_100g_wrapper.sv` 中，`gt_powergoodout` 已经从 CMAC IP 输出（line 152），将其连接到 `u_axi_master` 实例化的新端口。

```systemverilog
// 在 cmac_axi_master u_axi_master 实例化中添加：
.gt_powergoodout(gt_powergoodout),
```

- [ ] **Step 4: 验证语法**

分别编译两个文件确认无错误。

- [ ] **Step 5: Commit**

```bash
git add cmac_usplus_0_ex.srcs/sources_1/new/cmac_axi_master.sv \
        cmac_usplus_0_ex.srcs/sources_1/new/cmac_100g_wrapper.sv
git commit -m "fix(cmac_axi): add gt_powergoodout early exit from 167ms delay"
```

---

### Task 7: 修复 I6 — icmp_responder.sv rx_cnt 显式归零

**Files:**
- Modify: `cmac_usplus_0_ex.srcs/sources_1/new/icmp_responder.sv`

- [ ] **Step 1: 在 IDLE 分支显式归零 rx_cnt**

```systemverilog
// 在 IDLE 状态的 always_ff 块开头添加：
IDLE: begin
    rx_cnt <= 5'd0;  // 【新增】显式归零，防止复位后首次非零
    if (icmp_req_match) begin
        ...
    end
end
```

注意：`rx_cnt <= 5'd0` 放在 `icmp_req_match` if 块之前，确保不被覆盖。如果 `icmp_req_match` 为真且非单拍包，`rx_cnt <= 5'd1` 会覆盖此值，逻辑不变。

- [ ] **Step 2: 验证语法**

Run: `xvlog --nolog ../cmac_usplus_0_ex.srcs/sources_1/new/icmp_responder.sv`
Expected: 无编译错误

- [ ] **Step 3: Commit**

```bash
git add cmac_usplus_0_ex.srcs/sources_1/new/icmp_responder.sv
git commit -m "fix(icmp): explicitly reset rx_cnt in IDLE state"
```

---

### Task 8: 修复 I3 — adc_packer_512.sv 首拍加 tready 检查（可选/低优先级）

**Files:**
- Modify: `cmac_usplus_0_ex.srcs/sources_1/new/adc_packer_512.sv`

- [ ] **Step 1: 添加 tready 门控**

将 IDLE→BEAT0 的转换条件中增加 `m_axis_tready` 检查：

```systemverilog
// 将：
if (buf_has5) begin
    // build beat 0, tvalid <= 1
    out_state <= OUT_BEAT0;
end

// 改为：
if (buf_has5 && m_axis_tready) begin
    tvalid_reg <= 1'b1;
    out_state <= OUT_BEAT0;
end
```

- [ ] **Step 2: 验证语法**

- [ ] **Step 3: Commit**

---

### Task 9: 修复 I7 — udp_100g_framer_pro.sv FLUSH_TAIL 期间防御性 tready

**Files:**
- Modify: `cmac_usplus_0_ex.srcs/sources_1/new/udp_100g_framer_pro.sv`

- [ ] **Step 1: 添加防御逻辑**

```systemverilog
// 如果要增加防御：在 FLUSH_TAIL 期间，如果上游错误地发来数据，丢弃它
// s_axis_tready 保持低（当前行为），在 always_ff 中 FLUSH_TAIL 最后一拍完成后回到 IDLE。

// 当前代码已正确：FLUSH_TAIL 持续 1 拍，发送 leftover 即回 IDLE。
// 无需修改代码，添加注释说明即可：

// FLUSH_TAIL: 仅持续 1 拍，发送 leftover 后立刻回到 IDLE。
// 上游在 tlast 后不应继续发数据，tready=0 仅为协议防御。
```

- [ ] **Step 2: 确认无需修改后跳过或仅添加注释**

---

### Task 10: 全量仿真验证

- [ ] **Step 1: 运行集成仿真**

```bash
cd cmac_usplus_0_ex
xvlog --nolog ../cmac_usplus_0_ex.srcs/sim_1/new/tb_fpga_top_integrated.sv
xelab tb_fpga_top_integrated
xsim tb_fpga_top_integrated --runall
```

Expected: 53/53 tests PASS (与修复前一致，无回归)

- [ ] **Step 2: 如有失败，使用 systematic-debugging skill 排查**

- [ ] **Step 3: Final commit**

```bash
git commit -m "chore: post-fix simulation verification — all 53 tests pass"
```
