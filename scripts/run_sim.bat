@echo off
call D:\Vivado_2025_2\2025.2\Vivado\settings64.bat
cd /d D:\user\wangshihao\CMAC\CMAC_4_23\cmac_usplus_0_ex
vivado -mode batch -source scripts\run_sim_regression.tcl > sim_output.log 2>&1
echo Exit code: %ERRORLEVEL%
