# AGENTS.md — AI 编码助手指南

> 本文件告诉 AI 如何在本工程中正确工作。
> 来源: impakt73/ai-rust-hw-dev (AGENTS.md 概念), OpenHW CVA6 (AI政策)

## 项目元信息

| 项 | 值 |
|----|-----|
| 器件 | XCKU5P-FFVB676-2-I |
| 工具 | Vivado 2025.2 |
| 语言 | SystemVerilog |
| 仿真 | xsim (TB 桩加速, 83/83 PASS) |
| 综合 | synth_1 (需修复后重跑) |
| 顶层 | fpga_top_integrated.sv |

## 项目概述

XCKU5P 数据采集卡 — ADC 双通道 1.5GSPS → DDR4 512MB 环形缓冲 → 100G CMAC 实时发送 / PCIe XDMA 备份排空。

```
ADC LVDS (32 lane, 1.5GSPS) → gearbox → packer(512b×2) → CDC FIFO
  → DDR4 S2MM (BTT=128) → DDR4 → MM2S (BTT=128)
  → ddr4_readout_demux → CMAC TX (100G ETH) / PCIe XDMA C2H (备份)
CMAC RX → rx_demux → ARP/ICMP/UDP cmd parser (控制面)
```

## 时钟域

| 时钟名 | 频率 | 来源 | 用途 |
|--------|------|------|------|
| sys_clk_50m | 50 MHz | 板载晶振 | clk_wiz 输入 → 100MHz init_clk |
| usr_mac_clk | 322 MHz | CMAC IP 输出 | 数据面主时钟 |
| c0_ddr4_ui_clk | 333 MHz | DDR4 MIG 输出 | 存储接口时钟 |
| clk_adc_125 | 125 MHz | adc_top clk_wiz 输出 | ADC packer + CDC FIFO 写侧 |
| pcie_clk_125 | 125 MHz | XDMA IP 输出 | PCIe C2H 通路 |

**异步时钟组**: `{usr_mac_clk, c0_ddr4_ui_clk, clk_adc_125, pcie_clk_125}` — 已在 `integrated.xdc` 中声明

## RTL 编码规范

> 编码风格参照: lowRISC/style-guides (被 OpenHW CVA6 采用)

### 复位风格
- 使用同步复位: `always @(posedge clk) if (rst) ...`
- 异步复位仅限外部输入边界，用 `xpm_cdc_sync_rst` 转同步
- 所有控制寄存器必须有复位初值
- 纯数据路径（有 valid 控制时）可以不复位

### 跨时钟域 (CDC)
- 单比特控制: `xpm_cdc_single` (2+级同步)
- 多比特数据: `xpm_cdc_handshake` 或 `xpm_fifo_async`
- 计数器/指针: `xpm_cdc_gray`
- 单周期脉冲: `xpm_cdc_pulse`
- **禁止**: 跨域信号无 CDC 直连
- **约束**: 所有异步时钟组在 `.xdc` 中声明 `set_clock_groups -asynchronous`

### 命名约定 (lowRISC 风格)
- 低有效: `_n` (如 `rst_n`)
- 时钟: `_clk`
- 复位: `_rst` / `_rst_n`
- AXI: `s_axi_*` / `m_axi_*`
- AXI-Stream: `s_axis_*` / `m_axis_*`

### 参数化 (CVA6 规范)
- 用 `parameter`，不用 `` `ifdef``
- 新功能默认 parameter=0 (关闭)

### Vivado 加速设置
- 综合/实现前始终添加: `set_param general.maxThreads 8`
- 来源: AMD 官方推荐 (UG835)

## 关键设计决策

1. **BTT=128** — packer 2-beat burst 作为逻辑帧，CDC FIFO 577b={tlast,tkeep,tdata} 保留帧结构，128B = 2×512b AXI beat = 1×MIG DDR4 burst
2. **TX Packet FIFO PACKET_FIFO=true** — DDR4 MM2S 有气泡，收齐完整包才吐出，杜绝 CMAC TX Underflow
3. **wr_ptr_confirmed 保守策略** — MM2S 读指针跟随 S2MM status 确认后的地址，绝不读未落盘数据
4. **链路去抖** — RS-FEC 重对齐连续 ≥32 周期才确认真断，≥1000 周期稳定对齐才释放复位
5. **S2MM 无 UDP 门控** — 纯 ADC 模式下写指针独立推进，UDP REC/STOP 不阻塞硬件写通路
6. **play_enable 门控 MM2S** — UDP START_PLAY 后使能读出；纯 ADC 模式 buf_empty=0 自动启动

## 工程结构

```
cmac_usplus_0_ex/                       ← Vivado 工程根目录
├── cmac_usplus_0_ex.xpr                ← Vivado 工程文件
├── cmac_usplus_0_ex.srcs/
│   ├── sources_1/new/                  ← RTL 源码 (21 文件)
│   │   ├── fpga_top_integrated.sv      ← 顶层
│   │   ├── fpga_top_100g.sv            ← 100G 子系统顶层
│   │   ├── cmac_100g_wrapper.sv        ← CMAC 协议栈封装
│   │   ├── cmac_axi_master.sv          ← CMAC AXI 初始化
│   │   ├── rx_demux.sv                 ← ETH/IP/UDP 协议分流
│   │   ├── arp_responder.sv            ← ARP 响应
│   │   ├── icmp_responder.sv           ← ICMP Echo 响应
│   │   ├── udp_100g_deframer_pro.sv     ← UDP 解帧
│   │   ├── udp_100g_framer_pro.sv      ← UDP 组帧
│   │   ├── udp_cmd_parser.sv           ← UDP:8001 命令解析
│   │   ├── udp_100g_config_slave.sv    ← AXI4-Lite 配置寄存器
│   │   ├── udp_100g_statistics.sv      ← 统计计数器
│   │   ├── axis_tx_arbiter.sv          ← TX 仲裁器
│   │   ├── ddr4_subsystem_top.sv       ← DDR4 BD 封装
│   │   ├── ddr4_readout_demux.sv       ← DDR4 读出分流
│   │   ├── datamover_ctrl.sv           ← DataMover 控制
│   │   ├── adc_top.sv                  ← ADC 前端 (IBUFDS+IDELAY+IDDRE1)
│   │   ├── adc_packer_512.sv           ← 512b 打包器
│   │   ├── adc_spi_config.sv           ← ADC SPI 配置
│   │   ├── gearbox_32_to_96.sv         ← 32→96 变速
│   │   └── idelay_auto_scan.sv         ← IDELAY 自动扫描
│   ├── sim_1/new/                      ← 仿真 testbench
│   │   ├── tb_fpga_top_integrated.sv   ← 集成测试 (83/83 PASS)
│   │   ├── tb_fpga_top_front.sv        ← ADC→packer 测试
│   │   └── tb_fpga_top_back.sv         ← MM2S+CMAC/PCIe 测试
│   └── constrs_1/new/
│       └── integrated.xdc              ← 时序/引脚/CDC 约束
├── cmac_usplus_0_ex.gen/               ← IP 生成文件 (clk_wiz, MIG, CMAC, XDMA)
├── cmac_usplus_0_ex.runs/              ← 综合/实现运行目录
├── scripts/                            ← 辅助脚本
│   ├── run_sim_regression.tcl
│   ├── export_sim.tcl
│   └── run_sim.bat
├── docs/superpowers/plans/             ← 实施计划
├── fpgahub/                            ← AI 辅助开发工具
├── AGENTS.md                           ← 本文件
└── PROJECT_SUMMARY.txt                 ← 工程架构文档
```

## 仿真验证

### 当前状态 (xsim, 2026-05-28)
- 全链路集成测试 **83/83 ALL PASSED**
- 覆盖: 11 个 Phase (详见 TB 文件头注释)
  - Phase 1-6: 子系统就绪、DDR4 数据通路、背压恢复、UDP CDC 门控、复位压力、并发 (56项, 已归档)
  - Phase 7: 数据流存活 (3项, 已归档)
  - Phase 8: 背压恢复 (4项, 活跃) — 验证 wr_ptr 在 stall 期间持续推进
  - Phase 9-11: 复位完整性、UDP 命令、DDR4 回绕 (20项, 已归档)
- TB 文件: `tb_fpga_top_integrated.sv` (仿真用 cmac_100g_wrapper/adc_top/xdma_0 行为桩)
- **注意**: TB 桩模块覆盖真实 RTL 模块, 仿真行为与硬件不一致 (如 ctrl 信号在桩内硬连线)

### 仿真无法覆盖 (需上板)
- CMAC RS-FEC / GT 链路训练 (需真实 SerDes + 对端)
- XDMA PCIe DMA 传输 (需 Root Complex + 驱动)
- ADC SPI 配置时序 (需真实 ADC 芯片)
- DDR4 满缓冲回绕 512MB (仿真时间不可接受)
- 时序收敛 STA / 长时间烤机

## 验证规范

> 当前使用 xsim + SystemVerilog testbench, 行为桩加速仿真。
> cocotb 环境未部署, 迁移需先 `pip install cocotb` + 安装仿真器后端。

### 验证检查清单（声称"完成"前的硬性要求）
- [x] 综合通过 (`synth_design` 无 ERROR)
- [x] 仿真通过 (xsim testbench 83/83 PASS)
- [ ] 时序收敛 (WNS ≥ 0, WHS ≥ 0)
- [x] 新增信号有复位初值
- [x] 跨域信号全部经过 CDC (12 条路径已验证)
- [x] 新增异步时钟组已约束
- [x] Vivado 加速参数已设置: `set_param general.maxThreads 8`
- [ ] 代码 lint 通过 (Verible 可用但未集成到 CI)

## UDP 命令协议

| 命令 | 端口 | 说明 |
|------|------|------|
| START_REC (0x01) | UDP:8001 | 开始记录 ADC → DDR4 |
| STOP_REC (0x02) | UDP:8001 | 停止记录 |
| START_PLAY (0x03) | UDP:8001 | 开始播放 DDR4 → CMAC |
| STOP_PLAY (0x04) | UDP:8001 | 停止播放 |
| GET_STATUS (0x05) | UDP:8001 | 查询状态 (不改变状态) |

响应: FPGA → PC, src=8001, dst=请求方源端口 (动态回传)

状态机: IDLE → RECORDING ⇄ PLAYBACK → IDLE (SOFT_RESET 任意状态可回 IDLE)

## AI 使用规则

> 来源: OpenHW CVA6 (CONTRIBUTING.md)

### ✅ 允许
- AI 辅助写代码、写 testbench、写约束
- AI 审查代码、分析报告
- AI 参与设计讨论

### ❌ 禁止
- AI 生成的代码不经人类审查直接提交
- 自动化 AI PR
- 让 AI 代替你和 reviewer 讨论
- 提交你自己不理解的代码

## 调试哲学

> 来源: impakt73/ai-rust-hw-dev (AGENTS.md)

- ❌ 永远不要靠抽象推理
- ✅ 永远用仿真数据说话
- ✅ 先缩小范围，再二分法定位

## RTL 代码审查修复记录 (2026-05-27)

以下修复已应用到源码, 所有仿真回归通过。

| ID | 严重度 | 文件 | 修复内容 |
|----|--------|------|----------|
| C1 | Critical | ddr4_subsystem_top.sv | RX CDC FIFO 增加 wr_rst_busy/rd_rst_busy 门控 |
| C2 | Critical | fpga_top_integrated.sv | ADC FIFO 复位 usr_mac_rst_n 经 2-FF 同步到 clk_adc_125 后再 OR |
| C3 | Critical | rx_demux.sv | 路由逻辑去重: 统一 next_state_from_idle 组合块 |
| C4 | Critical | udp_cmd_parser.sv | s_axis_tready 门控为 `(state == ST_IDLE)` 防静默丢命令 |
| I2 | Important | fpga_top_integrated.sv | soft_rst_cnt 显式 ==0 停止, 避免 4-bit 回绕 |
| S1 | Synthesis | fpga_top_integrated.sv | 移除仿真专用 tb_rx 端口 (真实 cmac_100g_wrapper 无此端口) |
| S2 | Synthesis | adc_top.sv | unpacked array 拼接展开为独立 assign |

## 综合注意事项

- **tb_rx 端口**: 仿真专用, 已从 fpga_top_integrated.sv 移除, 综合不再报错
- **cmac_100g_wrapper**: 仿真使用 TB 桩模块覆盖, 综合使用 `cmac_usplus_0_ex.srcs/sources_1/new/` 下的真实 RTL
- **adc_top.sv**: unpacked array 拼接赋值已展开为独立 assign, 兼容 Vivado 综合器
