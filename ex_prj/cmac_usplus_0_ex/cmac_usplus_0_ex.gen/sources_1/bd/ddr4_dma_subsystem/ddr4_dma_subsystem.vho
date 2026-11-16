-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
-- -------------------------------------------------------------------------------
-- This file contains confidential and proprietary information
-- of AMD and is protected under U.S. and international copyright
-- and other intellectual property laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- AMD, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) AMD shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or AMD had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- AMD products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of AMD products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-- DO NOT MODIFY THIS FILE.

-- MODULE VLNV: amd.com:blockdesign:ddr4_dma_subsystem:1.0

-- The following code must appear in the VHDL architecture header.

-- COMP_TAG     ------ Begin cut for COMPONENT Declaration ------
COMPONENT ddr4_dma_subsystem
  PORT (
    C0_SYS_CLK_0_clk_n : IN STD_LOGIC;
    C0_SYS_CLK_0_clk_p : IN STD_LOGIC;
    C0_DDR4_0_act_n : OUT STD_LOGIC;
    C0_DDR4_0_adr : OUT STD_LOGIC_VECTOR(16 DOWNTO 0);
    C0_DDR4_0_ba : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    C0_DDR4_0_bg : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    C0_DDR4_0_ck_c : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    C0_DDR4_0_ck_t : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    C0_DDR4_0_cke : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    C0_DDR4_0_cs_n : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    C0_DDR4_0_dm_n : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    C0_DDR4_0_dq : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    C0_DDR4_0_dqs_c : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    C0_DDR4_0_dqs_t : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    C0_DDR4_0_odt : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    C0_DDR4_0_reset_n : OUT STD_LOGIC;
    S_AXIS_S2MM_0_tdata : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
    S_AXIS_S2MM_0_tkeep : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    S_AXIS_S2MM_0_tlast : IN STD_LOGIC;
    S_AXIS_S2MM_0_tready : OUT STD_LOGIC;
    S_AXIS_S2MM_0_tvalid : IN STD_LOGIC;
    M_AXIS_MM2S_0_tdata : OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
    M_AXIS_MM2S_0_tkeep : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    M_AXIS_MM2S_0_tlast : OUT STD_LOGIC;
    M_AXIS_MM2S_0_tready : IN STD_LOGIC;
    M_AXIS_MM2S_0_tvalid : OUT STD_LOGIC;
    S_AXIS_S2MM_CMD_0_tdata : IN STD_LOGIC_VECTOR(71 DOWNTO 0);
    S_AXIS_S2MM_CMD_0_tready : OUT STD_LOGIC;
    S_AXIS_S2MM_CMD_0_tvalid : IN STD_LOGIC;
    S_AXIS_MM2S_CMD_0_tdata : IN STD_LOGIC_VECTOR(71 DOWNTO 0);
    S_AXIS_MM2S_CMD_0_tready : OUT STD_LOGIC;
    S_AXIS_MM2S_CMD_0_tvalid : IN STD_LOGIC;
    M_AXIS_S2MM_STS_0_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    M_AXIS_S2MM_STS_0_tkeep : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    M_AXIS_S2MM_STS_0_tlast : OUT STD_LOGIC;
    M_AXIS_S2MM_STS_0_tready : IN STD_LOGIC;
    M_AXIS_S2MM_STS_0_tvalid : OUT STD_LOGIC;
    M_AXIS_MM2S_STS_0_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    M_AXIS_MM2S_STS_0_tkeep : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    M_AXIS_MM2S_STS_0_tlast : OUT STD_LOGIC;
    M_AXIS_MM2S_STS_0_tready : IN STD_LOGIC;
    M_AXIS_MM2S_STS_0_tvalid : OUT STD_LOGIC;
    sys_rst : IN STD_LOGIC;
    c0_init_calib_complete_0 : OUT STD_LOGIC;
    mm2s_err_0 : OUT STD_LOGIC;
    s2mm_err_0 : OUT STD_LOGIC;
    c0_ddr4_ui_clk : OUT STD_LOGIC
  );
END COMPONENT;
-- COMP_TAG_END ------  End cut for COMPONENT Declaration  ------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

-- INST_TAG     ------ Begin cut for INSTANTIATION Template ------
your_instance_name : ddr4_dma_subsystem
  PORT MAP (
    C0_SYS_CLK_0_clk_n => C0_SYS_CLK_0_clk_n,
    C0_SYS_CLK_0_clk_p => C0_SYS_CLK_0_clk_p,
    C0_DDR4_0_act_n => C0_DDR4_0_act_n,
    C0_DDR4_0_adr => C0_DDR4_0_adr,
    C0_DDR4_0_ba => C0_DDR4_0_ba,
    C0_DDR4_0_bg => C0_DDR4_0_bg,
    C0_DDR4_0_ck_c => C0_DDR4_0_ck_c,
    C0_DDR4_0_ck_t => C0_DDR4_0_ck_t,
    C0_DDR4_0_cke => C0_DDR4_0_cke,
    C0_DDR4_0_cs_n => C0_DDR4_0_cs_n,
    C0_DDR4_0_dm_n => C0_DDR4_0_dm_n,
    C0_DDR4_0_dq => C0_DDR4_0_dq,
    C0_DDR4_0_dqs_c => C0_DDR4_0_dqs_c,
    C0_DDR4_0_dqs_t => C0_DDR4_0_dqs_t,
    C0_DDR4_0_odt => C0_DDR4_0_odt,
    C0_DDR4_0_reset_n => C0_DDR4_0_reset_n,
    S_AXIS_S2MM_0_tdata => S_AXIS_S2MM_0_tdata,
    S_AXIS_S2MM_0_tkeep => S_AXIS_S2MM_0_tkeep,
    S_AXIS_S2MM_0_tlast => S_AXIS_S2MM_0_tlast,
    S_AXIS_S2MM_0_tready => S_AXIS_S2MM_0_tready,
    S_AXIS_S2MM_0_tvalid => S_AXIS_S2MM_0_tvalid,
    M_AXIS_MM2S_0_tdata => M_AXIS_MM2S_0_tdata,
    M_AXIS_MM2S_0_tkeep => M_AXIS_MM2S_0_tkeep,
    M_AXIS_MM2S_0_tlast => M_AXIS_MM2S_0_tlast,
    M_AXIS_MM2S_0_tready => M_AXIS_MM2S_0_tready,
    M_AXIS_MM2S_0_tvalid => M_AXIS_MM2S_0_tvalid,
    S_AXIS_S2MM_CMD_0_tdata => S_AXIS_S2MM_CMD_0_tdata,
    S_AXIS_S2MM_CMD_0_tready => S_AXIS_S2MM_CMD_0_tready,
    S_AXIS_S2MM_CMD_0_tvalid => S_AXIS_S2MM_CMD_0_tvalid,
    S_AXIS_MM2S_CMD_0_tdata => S_AXIS_MM2S_CMD_0_tdata,
    S_AXIS_MM2S_CMD_0_tready => S_AXIS_MM2S_CMD_0_tready,
    S_AXIS_MM2S_CMD_0_tvalid => S_AXIS_MM2S_CMD_0_tvalid,
    M_AXIS_S2MM_STS_0_tdata => M_AXIS_S2MM_STS_0_tdata,
    M_AXIS_S2MM_STS_0_tkeep => M_AXIS_S2MM_STS_0_tkeep,
    M_AXIS_S2MM_STS_0_tlast => M_AXIS_S2MM_STS_0_tlast,
    M_AXIS_S2MM_STS_0_tready => M_AXIS_S2MM_STS_0_tready,
    M_AXIS_S2MM_STS_0_tvalid => M_AXIS_S2MM_STS_0_tvalid,
    M_AXIS_MM2S_STS_0_tdata => M_AXIS_MM2S_STS_0_tdata,
    M_AXIS_MM2S_STS_0_tkeep => M_AXIS_MM2S_STS_0_tkeep,
    M_AXIS_MM2S_STS_0_tlast => M_AXIS_MM2S_STS_0_tlast,
    M_AXIS_MM2S_STS_0_tready => M_AXIS_MM2S_STS_0_tready,
    M_AXIS_MM2S_STS_0_tvalid => M_AXIS_MM2S_STS_0_tvalid,
    sys_rst => sys_rst,
    c0_init_calib_complete_0 => c0_init_calib_complete_0,
    mm2s_err_0 => mm2s_err_0,
    s2mm_err_0 => s2mm_err_0,
    c0_ddr4_ui_clk => c0_ddr4_ui_clk
  );
-- INST_TAG_END ------  End cut for INSTANTIATION Template  ------

-- You must compile the wrapper file ddr4_dma_subsystem.vhd when simulating
-- the module, ddr4_dma_subsystem. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.
