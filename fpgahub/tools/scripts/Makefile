# FPGA 开发自动化 Makefile
# 适配: cmac_usplus_0_ex — XCKU5P 数据采集卡

# ============================================================
# 工程配置
# ============================================================
PROJECT  ?= cmac_usplus_0_ex
TOP      ?= fpga_top_integrated
PART     ?= xcku5p-ffvb676-2-i
XPR      ?= ../$(PROJECT).xpr
JOBS     := 8

# ============================================================
# 路径
# ============================================================
SRC_DIR  := ../imports
SIM_DIR  := ../cmac_usplus_0_ex.sim
SCRIPTS  := ../scripts
OUT_DIR  := output
RPT_DIR  := reports
CONSTRAINTS := ../imports

# 工具路径
PYTHON   := python
VERIBLE  := C:\verible\verible-v0.0-4053-g89d4d98a-win64\verible-verilog-lint.exe
VERIBLE_FORMAT := C:\verible\verible-v0.0-4053-g89d4d98a-win64\verible-verilog-format.exe
VIVADO   := vivado

# ============================================================
# 仿真 (xsim — 使用已有 Tcl 脚本)
# ============================================================
.PHONY: sim
sim:
	@echo "Running xsim simulation ($(TOP))..."
	cd $(SCRIPTS) && $(VIVADO) -mode batch -source run_tb_fpga_top_integrated.tcl

.PHONY: sim-front
sim-front:
	cd $(SCRIPTS) && $(VIVADO) -mode batch -source run_tb_front.tcl

.PHONY: sim-back
sim-back:
	cd $(SCRIPTS) && $(VIVADO) -mode batch -source run_tb_back.tcl

# ============================================================
# 代码检查
# ============================================================
.PHONY: lint
lint:
	@echo "Running Verible lint..."
	$(VERIBLE) $(SRC_DIR)/*.sv $(SRC_DIR)/*.v

.PHONY: format
format:
	@echo "Formatting with Verible..."
	$(VERIBLE_FORMAT) --inplace $(SRC_DIR)/*.sv $(SRC_DIR)/*.v

# ============================================================
# Vivado 综合 (project mode)
# ============================================================
.PHONY: synth
synth:
	@echo "Running synthesis ($(PART))..."
	$(VIVADO) -mode batch -nojournal -nolog -source scripts/run_synth.tcl \
	  -tclargs $(XPR)

# ============================================================
# Vivado 全流程 (综合 + 实现 + bitstream)
# ============================================================
.PHONY: build
build:
	@echo "Building $(TOP) for $(PART)..."
	@mkdir -p $(OUT_DIR) $(RPT_DIR)
	$(VIVADO) -mode batch -nojournal -nolog -source scripts/run_build.tcl \
	  -tclargs $(XPR) $(OUT_DIR) $(RPT_DIR)

# ============================================================
# 时序报告
# ============================================================
.PHONY: timing
timing:
	@echo "Loading timing check..."
	$(VIVADO) -mode batch -nojournal -nolog -source scripts/check_timing.tcl -tclargs $(XPR)

# ============================================================
# 打开 Vivado GUI
# ============================================================
.PHONY: gui
gui:
	$(VIVADO) $(XPR) &

# ============================================================
# 清理
# ============================================================
.PHONY: clean
clean:
	rm -rf *.jou *.log *.str .Xil
	rm -rf $(OUT_DIR) $(RPT_DIR)
	rm -rf vivado_*.str vivado_*.log
	rm -rf *.backup.jou *.backup.log
