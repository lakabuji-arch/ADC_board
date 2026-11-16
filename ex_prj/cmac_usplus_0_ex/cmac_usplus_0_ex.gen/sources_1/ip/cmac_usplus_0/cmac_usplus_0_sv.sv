// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// -------------------------------------------------------------------------------
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
// DO NOT MODIFY THIS FILE.

// MODULE VLNV: xilinx.com:ip:cmac_usplus:3.1

`timescale 1ps / 1ps

`include "vivado_interfaces.svh"

module cmac_usplus_0_sv (
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_tx" *)
  (* X_INTERFACE_MODE = "slave axis_tx" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axis_tx, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *)
  vivado_axis_v1_0.slave axis_tx,
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_rx" *)
  (* X_INTERFACE_MODE = "master axis_rx" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axis_rx, TDATA_NUM_BYTES 64, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *)
  vivado_axis_v1_0.master axis_rx,
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi" *)
  (* X_INTERFACE_MODE = "slave s_axi" *)
  (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
  vivado_axi4_lite_v1_0.slave s_axi,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [3:0] gt_txp_out,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [3:0] gt_txn_out,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire [3:0] gt_rxp_in,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire [3:0] gt_rxn_in,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire gt_txusrclk2,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire [11:0] gt_loopback_in,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire gt_ref_clk_out,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [3:0] gt_rxrecclkout,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [3:0] gt_powergoodout,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire gtwiz_reset_tx_datapath,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire gtwiz_reset_rx_datapath,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire s_axi_aclk,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire s_axi_sreset,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire pm_tick,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_rsfec_am_lock0,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_rsfec_am_lock1,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_rsfec_am_lock2,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_rsfec_am_lock3,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_rsfec_corrected_cw_inc,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_rsfec_cw_inc,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] stat_rx_rsfec_err_count0_inc,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] stat_rx_rsfec_err_count1_inc,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] stat_rx_rsfec_err_count2_inc,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] stat_rx_rsfec_err_count3_inc,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_rsfec_hi_ser,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_rsfec_lane_alignment_status,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [13:0] stat_rx_rsfec_lane_fill_0,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [13:0] stat_rx_rsfec_lane_fill_1,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [13:0] stat_rx_rsfec_lane_fill_2,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [13:0] stat_rx_rsfec_lane_fill_3,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [7:0] stat_rx_rsfec_lane_mapping,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_rsfec_uncorrected_cw_inc,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [31:0] user_reg0,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire sys_reset,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire gt_ref_clk_p,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire gt_ref_clk_n,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire init_clk,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [7:0] rx_otn_bip8_0,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [7:0] rx_otn_bip8_1,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [7:0] rx_otn_bip8_2,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [7:0] rx_otn_bip8_3,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [7:0] rx_otn_bip8_4,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [65:0] rx_otn_data_0,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [65:0] rx_otn_data_1,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [65:0] rx_otn_data_2,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [65:0] rx_otn_data_3,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [65:0] rx_otn_data_4,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire rx_otn_ena,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire rx_otn_lane0,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire rx_otn_vlmarker,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [55:0] rx_preambleout,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire usr_rx_reset,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire gt_rxusrclk2,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_aligned,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_aligned_err,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] stat_rx_bad_code,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] stat_rx_bad_fcs,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bad_preamble,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bad_sfd,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_0,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_1,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_10,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_11,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_12,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_13,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_14,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_15,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_16,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_17,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_18,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_19,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_2,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_3,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_4,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_5,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_6,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_7,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_8,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_bip_err_9,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [19:0] stat_rx_block_lock,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_broadcast,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] stat_rx_fragment,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_0,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_1,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_10,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_11,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_12,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_13,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_14,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_15,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_16,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_17,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_18,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_19,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_2,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_3,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_4,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_5,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_6,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_7,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_8,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [1:0] stat_rx_framing_err_9,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_0,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_1,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_10,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_11,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_12,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_13,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_14,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_15,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_16,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_17,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_18,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_19,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_2,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_3,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_4,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_5,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_6,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_7,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_8,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_framing_err_valid_9,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_got_signal_os,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_hi_ber,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_inrangeerr,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_internal_local_fault,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_jabber,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_local_fault,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [19:0] stat_rx_mf_err,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [19:0] stat_rx_mf_len_err,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [19:0] stat_rx_mf_repeat_err,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_misaligned,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_multicast,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_oversize,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_1024_1518_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_128_255_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_1519_1522_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_1523_1548_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_1549_2047_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_2048_4095_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_256_511_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_4096_8191_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_512_1023_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_64_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_65_127_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_8192_9215_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_bad_fcs,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_packet_large,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] stat_rx_packet_small,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_pause,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [15:0] stat_rx_pause_quanta0,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [15:0] stat_rx_pause_quanta1,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [15:0] stat_rx_pause_quanta2,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [15:0] stat_rx_pause_quanta3,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [15:0] stat_rx_pause_quanta4,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [15:0] stat_rx_pause_quanta5,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [15:0] stat_rx_pause_quanta6,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [15:0] stat_rx_pause_quanta7,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [15:0] stat_rx_pause_quanta8,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [8:0] stat_rx_pause_req,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [8:0] stat_rx_pause_valid,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_user_pause,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire core_rx_reset,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire rx_clk,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_received_local_fault,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_remote_fault,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_status,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] stat_rx_stomped_fcs,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [19:0] stat_rx_synced,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [19:0] stat_rx_synced_err,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] stat_rx_test_pattern_mismatch,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_toolong,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [6:0] stat_rx_total_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [13:0] stat_rx_total_good_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_total_good_packets,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] stat_rx_total_packets,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_truncated,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [2:0] stat_rx_undersize,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_unicast,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_rx_vlan,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [19:0] stat_rx_pcsl_demuxed,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_0,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_1,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_10,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_11,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_12,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_13,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_14,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_15,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_16,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_17,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_18,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_19,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_2,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_3,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_4,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_5,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_6,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_7,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_8,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [4:0] stat_rx_pcsl_number_9,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_bad_fcs,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_broadcast,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_frame_error,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_local_fault,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_multicast,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_1024_1518_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_128_255_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_1519_1522_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_1523_1548_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_1549_2047_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_2048_4095_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_256_511_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_4096_8191_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_512_1023_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_64_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_65_127_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_8192_9215_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_large,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_packet_small,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [5:0] stat_tx_total_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [13:0] stat_tx_total_good_bytes,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_total_good_packets,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_total_packets,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_unicast,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_vlan,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire ctl_tx_send_idle,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire ctl_tx_send_rfi,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire ctl_tx_send_lfi,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire core_tx_reset,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [8:0] stat_tx_pause_valid,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_pause,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire stat_tx_user_pause,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire [8:0] ctl_tx_pause_req,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire ctl_tx_resend_pause,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire tx_ovfout,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire tx_unfout,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire [55:0] tx_preamblein,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire usr_tx_reset,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire core_drp_reset,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire drp_clk,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire [9:0] drp_addr,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire [15:0] drp_di,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire drp_en,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire [15:0] drp_do,
  (* X_INTERFACE_IGNORE = "true" *)
  output wire drp_rdy,
  (* X_INTERFACE_IGNORE = "true" *)
  input wire drp_we
);

  // interface wire assignments
  assign axis_rx.TDEST = 0;
  assign axis_rx.TID = 0;
  assign axis_rx.TSTRB = 0;

  cmac_usplus_0 inst (
    .gt_txp_out(gt_txp_out),
    .gt_txn_out(gt_txn_out),
    .gt_rxp_in(gt_rxp_in),
    .gt_rxn_in(gt_rxn_in),
    .gt_txusrclk2(gt_txusrclk2),
    .gt_loopback_in(gt_loopback_in),
    .gt_ref_clk_out(gt_ref_clk_out),
    .gt_rxrecclkout(gt_rxrecclkout),
    .gt_powergoodout(gt_powergoodout),
    .gtwiz_reset_tx_datapath(gtwiz_reset_tx_datapath),
    .gtwiz_reset_rx_datapath(gtwiz_reset_rx_datapath),
    .s_axi_aclk(s_axi_aclk),
    .s_axi_sreset(s_axi_sreset),
    .pm_tick(pm_tick),
    .s_axi_awaddr(s_axi.AWADDR),
    .s_axi_awvalid(s_axi.AWVALID),
    .s_axi_awready(s_axi.AWREADY),
    .s_axi_wdata(s_axi.WDATA),
    .s_axi_wstrb(s_axi.WSTRB),
    .s_axi_wvalid(s_axi.WVALID),
    .s_axi_wready(s_axi.WREADY),
    .s_axi_bresp(s_axi.BRESP),
    .s_axi_bvalid(s_axi.BVALID),
    .s_axi_bready(s_axi.BREADY),
    .s_axi_araddr(s_axi.ARADDR),
    .s_axi_arvalid(s_axi.ARVALID),
    .s_axi_arready(s_axi.ARREADY),
    .s_axi_rdata(s_axi.RDATA),
    .s_axi_rresp(s_axi.RRESP),
    .s_axi_rvalid(s_axi.RVALID),
    .s_axi_rready(s_axi.RREADY),
    .stat_rx_rsfec_am_lock0(stat_rx_rsfec_am_lock0),
    .stat_rx_rsfec_am_lock1(stat_rx_rsfec_am_lock1),
    .stat_rx_rsfec_am_lock2(stat_rx_rsfec_am_lock2),
    .stat_rx_rsfec_am_lock3(stat_rx_rsfec_am_lock3),
    .stat_rx_rsfec_corrected_cw_inc(stat_rx_rsfec_corrected_cw_inc),
    .stat_rx_rsfec_cw_inc(stat_rx_rsfec_cw_inc),
    .stat_rx_rsfec_err_count0_inc(stat_rx_rsfec_err_count0_inc),
    .stat_rx_rsfec_err_count1_inc(stat_rx_rsfec_err_count1_inc),
    .stat_rx_rsfec_err_count2_inc(stat_rx_rsfec_err_count2_inc),
    .stat_rx_rsfec_err_count3_inc(stat_rx_rsfec_err_count3_inc),
    .stat_rx_rsfec_hi_ser(stat_rx_rsfec_hi_ser),
    .stat_rx_rsfec_lane_alignment_status(stat_rx_rsfec_lane_alignment_status),
    .stat_rx_rsfec_lane_fill_0(stat_rx_rsfec_lane_fill_0),
    .stat_rx_rsfec_lane_fill_1(stat_rx_rsfec_lane_fill_1),
    .stat_rx_rsfec_lane_fill_2(stat_rx_rsfec_lane_fill_2),
    .stat_rx_rsfec_lane_fill_3(stat_rx_rsfec_lane_fill_3),
    .stat_rx_rsfec_lane_mapping(stat_rx_rsfec_lane_mapping),
    .stat_rx_rsfec_uncorrected_cw_inc(stat_rx_rsfec_uncorrected_cw_inc),
    .user_reg0(user_reg0),
    .sys_reset(sys_reset),
    .gt_ref_clk_p(gt_ref_clk_p),
    .gt_ref_clk_n(gt_ref_clk_n),
    .init_clk(init_clk),
    .rx_axis_tvalid(axis_rx.TVALID),
    .rx_axis_tdata(axis_rx.TDATA),
    .rx_axis_tlast(axis_rx.TLAST),
    .rx_axis_tkeep(axis_rx.TKEEP),
    .rx_axis_tuser(axis_rx.TUSER),
    .rx_otn_bip8_0(rx_otn_bip8_0),
    .rx_otn_bip8_1(rx_otn_bip8_1),
    .rx_otn_bip8_2(rx_otn_bip8_2),
    .rx_otn_bip8_3(rx_otn_bip8_3),
    .rx_otn_bip8_4(rx_otn_bip8_4),
    .rx_otn_data_0(rx_otn_data_0),
    .rx_otn_data_1(rx_otn_data_1),
    .rx_otn_data_2(rx_otn_data_2),
    .rx_otn_data_3(rx_otn_data_3),
    .rx_otn_data_4(rx_otn_data_4),
    .rx_otn_ena(rx_otn_ena),
    .rx_otn_lane0(rx_otn_lane0),
    .rx_otn_vlmarker(rx_otn_vlmarker),
    .rx_preambleout(rx_preambleout),
    .usr_rx_reset(usr_rx_reset),
    .gt_rxusrclk2(gt_rxusrclk2),
    .stat_rx_aligned(stat_rx_aligned),
    .stat_rx_aligned_err(stat_rx_aligned_err),
    .stat_rx_bad_code(stat_rx_bad_code),
    .stat_rx_bad_fcs(stat_rx_bad_fcs),
    .stat_rx_bad_preamble(stat_rx_bad_preamble),
    .stat_rx_bad_sfd(stat_rx_bad_sfd),
    .stat_rx_bip_err_0(stat_rx_bip_err_0),
    .stat_rx_bip_err_1(stat_rx_bip_err_1),
    .stat_rx_bip_err_10(stat_rx_bip_err_10),
    .stat_rx_bip_err_11(stat_rx_bip_err_11),
    .stat_rx_bip_err_12(stat_rx_bip_err_12),
    .stat_rx_bip_err_13(stat_rx_bip_err_13),
    .stat_rx_bip_err_14(stat_rx_bip_err_14),
    .stat_rx_bip_err_15(stat_rx_bip_err_15),
    .stat_rx_bip_err_16(stat_rx_bip_err_16),
    .stat_rx_bip_err_17(stat_rx_bip_err_17),
    .stat_rx_bip_err_18(stat_rx_bip_err_18),
    .stat_rx_bip_err_19(stat_rx_bip_err_19),
    .stat_rx_bip_err_2(stat_rx_bip_err_2),
    .stat_rx_bip_err_3(stat_rx_bip_err_3),
    .stat_rx_bip_err_4(stat_rx_bip_err_4),
    .stat_rx_bip_err_5(stat_rx_bip_err_5),
    .stat_rx_bip_err_6(stat_rx_bip_err_6),
    .stat_rx_bip_err_7(stat_rx_bip_err_7),
    .stat_rx_bip_err_8(stat_rx_bip_err_8),
    .stat_rx_bip_err_9(stat_rx_bip_err_9),
    .stat_rx_block_lock(stat_rx_block_lock),
    .stat_rx_broadcast(stat_rx_broadcast),
    .stat_rx_fragment(stat_rx_fragment),
    .stat_rx_framing_err_0(stat_rx_framing_err_0),
    .stat_rx_framing_err_1(stat_rx_framing_err_1),
    .stat_rx_framing_err_10(stat_rx_framing_err_10),
    .stat_rx_framing_err_11(stat_rx_framing_err_11),
    .stat_rx_framing_err_12(stat_rx_framing_err_12),
    .stat_rx_framing_err_13(stat_rx_framing_err_13),
    .stat_rx_framing_err_14(stat_rx_framing_err_14),
    .stat_rx_framing_err_15(stat_rx_framing_err_15),
    .stat_rx_framing_err_16(stat_rx_framing_err_16),
    .stat_rx_framing_err_17(stat_rx_framing_err_17),
    .stat_rx_framing_err_18(stat_rx_framing_err_18),
    .stat_rx_framing_err_19(stat_rx_framing_err_19),
    .stat_rx_framing_err_2(stat_rx_framing_err_2),
    .stat_rx_framing_err_3(stat_rx_framing_err_3),
    .stat_rx_framing_err_4(stat_rx_framing_err_4),
    .stat_rx_framing_err_5(stat_rx_framing_err_5),
    .stat_rx_framing_err_6(stat_rx_framing_err_6),
    .stat_rx_framing_err_7(stat_rx_framing_err_7),
    .stat_rx_framing_err_8(stat_rx_framing_err_8),
    .stat_rx_framing_err_9(stat_rx_framing_err_9),
    .stat_rx_framing_err_valid_0(stat_rx_framing_err_valid_0),
    .stat_rx_framing_err_valid_1(stat_rx_framing_err_valid_1),
    .stat_rx_framing_err_valid_10(stat_rx_framing_err_valid_10),
    .stat_rx_framing_err_valid_11(stat_rx_framing_err_valid_11),
    .stat_rx_framing_err_valid_12(stat_rx_framing_err_valid_12),
    .stat_rx_framing_err_valid_13(stat_rx_framing_err_valid_13),
    .stat_rx_framing_err_valid_14(stat_rx_framing_err_valid_14),
    .stat_rx_framing_err_valid_15(stat_rx_framing_err_valid_15),
    .stat_rx_framing_err_valid_16(stat_rx_framing_err_valid_16),
    .stat_rx_framing_err_valid_17(stat_rx_framing_err_valid_17),
    .stat_rx_framing_err_valid_18(stat_rx_framing_err_valid_18),
    .stat_rx_framing_err_valid_19(stat_rx_framing_err_valid_19),
    .stat_rx_framing_err_valid_2(stat_rx_framing_err_valid_2),
    .stat_rx_framing_err_valid_3(stat_rx_framing_err_valid_3),
    .stat_rx_framing_err_valid_4(stat_rx_framing_err_valid_4),
    .stat_rx_framing_err_valid_5(stat_rx_framing_err_valid_5),
    .stat_rx_framing_err_valid_6(stat_rx_framing_err_valid_6),
    .stat_rx_framing_err_valid_7(stat_rx_framing_err_valid_7),
    .stat_rx_framing_err_valid_8(stat_rx_framing_err_valid_8),
    .stat_rx_framing_err_valid_9(stat_rx_framing_err_valid_9),
    .stat_rx_got_signal_os(stat_rx_got_signal_os),
    .stat_rx_hi_ber(stat_rx_hi_ber),
    .stat_rx_inrangeerr(stat_rx_inrangeerr),
    .stat_rx_internal_local_fault(stat_rx_internal_local_fault),
    .stat_rx_jabber(stat_rx_jabber),
    .stat_rx_local_fault(stat_rx_local_fault),
    .stat_rx_mf_err(stat_rx_mf_err),
    .stat_rx_mf_len_err(stat_rx_mf_len_err),
    .stat_rx_mf_repeat_err(stat_rx_mf_repeat_err),
    .stat_rx_misaligned(stat_rx_misaligned),
    .stat_rx_multicast(stat_rx_multicast),
    .stat_rx_oversize(stat_rx_oversize),
    .stat_rx_packet_1024_1518_bytes(stat_rx_packet_1024_1518_bytes),
    .stat_rx_packet_128_255_bytes(stat_rx_packet_128_255_bytes),
    .stat_rx_packet_1519_1522_bytes(stat_rx_packet_1519_1522_bytes),
    .stat_rx_packet_1523_1548_bytes(stat_rx_packet_1523_1548_bytes),
    .stat_rx_packet_1549_2047_bytes(stat_rx_packet_1549_2047_bytes),
    .stat_rx_packet_2048_4095_bytes(stat_rx_packet_2048_4095_bytes),
    .stat_rx_packet_256_511_bytes(stat_rx_packet_256_511_bytes),
    .stat_rx_packet_4096_8191_bytes(stat_rx_packet_4096_8191_bytes),
    .stat_rx_packet_512_1023_bytes(stat_rx_packet_512_1023_bytes),
    .stat_rx_packet_64_bytes(stat_rx_packet_64_bytes),
    .stat_rx_packet_65_127_bytes(stat_rx_packet_65_127_bytes),
    .stat_rx_packet_8192_9215_bytes(stat_rx_packet_8192_9215_bytes),
    .stat_rx_packet_bad_fcs(stat_rx_packet_bad_fcs),
    .stat_rx_packet_large(stat_rx_packet_large),
    .stat_rx_packet_small(stat_rx_packet_small),
    .stat_rx_pause(stat_rx_pause),
    .stat_rx_pause_quanta0(stat_rx_pause_quanta0),
    .stat_rx_pause_quanta1(stat_rx_pause_quanta1),
    .stat_rx_pause_quanta2(stat_rx_pause_quanta2),
    .stat_rx_pause_quanta3(stat_rx_pause_quanta3),
    .stat_rx_pause_quanta4(stat_rx_pause_quanta4),
    .stat_rx_pause_quanta5(stat_rx_pause_quanta5),
    .stat_rx_pause_quanta6(stat_rx_pause_quanta6),
    .stat_rx_pause_quanta7(stat_rx_pause_quanta7),
    .stat_rx_pause_quanta8(stat_rx_pause_quanta8),
    .stat_rx_pause_req(stat_rx_pause_req),
    .stat_rx_pause_valid(stat_rx_pause_valid),
    .stat_rx_user_pause(stat_rx_user_pause),
    .core_rx_reset(core_rx_reset),
    .rx_clk(rx_clk),
    .stat_rx_received_local_fault(stat_rx_received_local_fault),
    .stat_rx_remote_fault(stat_rx_remote_fault),
    .stat_rx_status(stat_rx_status),
    .stat_rx_stomped_fcs(stat_rx_stomped_fcs),
    .stat_rx_synced(stat_rx_synced),
    .stat_rx_synced_err(stat_rx_synced_err),
    .stat_rx_test_pattern_mismatch(stat_rx_test_pattern_mismatch),
    .stat_rx_toolong(stat_rx_toolong),
    .stat_rx_total_bytes(stat_rx_total_bytes),
    .stat_rx_total_good_bytes(stat_rx_total_good_bytes),
    .stat_rx_total_good_packets(stat_rx_total_good_packets),
    .stat_rx_total_packets(stat_rx_total_packets),
    .stat_rx_truncated(stat_rx_truncated),
    .stat_rx_undersize(stat_rx_undersize),
    .stat_rx_unicast(stat_rx_unicast),
    .stat_rx_vlan(stat_rx_vlan),
    .stat_rx_pcsl_demuxed(stat_rx_pcsl_demuxed),
    .stat_rx_pcsl_number_0(stat_rx_pcsl_number_0),
    .stat_rx_pcsl_number_1(stat_rx_pcsl_number_1),
    .stat_rx_pcsl_number_10(stat_rx_pcsl_number_10),
    .stat_rx_pcsl_number_11(stat_rx_pcsl_number_11),
    .stat_rx_pcsl_number_12(stat_rx_pcsl_number_12),
    .stat_rx_pcsl_number_13(stat_rx_pcsl_number_13),
    .stat_rx_pcsl_number_14(stat_rx_pcsl_number_14),
    .stat_rx_pcsl_number_15(stat_rx_pcsl_number_15),
    .stat_rx_pcsl_number_16(stat_rx_pcsl_number_16),
    .stat_rx_pcsl_number_17(stat_rx_pcsl_number_17),
    .stat_rx_pcsl_number_18(stat_rx_pcsl_number_18),
    .stat_rx_pcsl_number_19(stat_rx_pcsl_number_19),
    .stat_rx_pcsl_number_2(stat_rx_pcsl_number_2),
    .stat_rx_pcsl_number_3(stat_rx_pcsl_number_3),
    .stat_rx_pcsl_number_4(stat_rx_pcsl_number_4),
    .stat_rx_pcsl_number_5(stat_rx_pcsl_number_5),
    .stat_rx_pcsl_number_6(stat_rx_pcsl_number_6),
    .stat_rx_pcsl_number_7(stat_rx_pcsl_number_7),
    .stat_rx_pcsl_number_8(stat_rx_pcsl_number_8),
    .stat_rx_pcsl_number_9(stat_rx_pcsl_number_9),
    .stat_tx_bad_fcs(stat_tx_bad_fcs),
    .stat_tx_broadcast(stat_tx_broadcast),
    .stat_tx_frame_error(stat_tx_frame_error),
    .stat_tx_local_fault(stat_tx_local_fault),
    .stat_tx_multicast(stat_tx_multicast),
    .stat_tx_packet_1024_1518_bytes(stat_tx_packet_1024_1518_bytes),
    .stat_tx_packet_128_255_bytes(stat_tx_packet_128_255_bytes),
    .stat_tx_packet_1519_1522_bytes(stat_tx_packet_1519_1522_bytes),
    .stat_tx_packet_1523_1548_bytes(stat_tx_packet_1523_1548_bytes),
    .stat_tx_packet_1549_2047_bytes(stat_tx_packet_1549_2047_bytes),
    .stat_tx_packet_2048_4095_bytes(stat_tx_packet_2048_4095_bytes),
    .stat_tx_packet_256_511_bytes(stat_tx_packet_256_511_bytes),
    .stat_tx_packet_4096_8191_bytes(stat_tx_packet_4096_8191_bytes),
    .stat_tx_packet_512_1023_bytes(stat_tx_packet_512_1023_bytes),
    .stat_tx_packet_64_bytes(stat_tx_packet_64_bytes),
    .stat_tx_packet_65_127_bytes(stat_tx_packet_65_127_bytes),
    .stat_tx_packet_8192_9215_bytes(stat_tx_packet_8192_9215_bytes),
    .stat_tx_packet_large(stat_tx_packet_large),
    .stat_tx_packet_small(stat_tx_packet_small),
    .stat_tx_total_bytes(stat_tx_total_bytes),
    .stat_tx_total_good_bytes(stat_tx_total_good_bytes),
    .stat_tx_total_good_packets(stat_tx_total_good_packets),
    .stat_tx_total_packets(stat_tx_total_packets),
    .stat_tx_unicast(stat_tx_unicast),
    .stat_tx_vlan(stat_tx_vlan),
    .ctl_tx_send_idle(ctl_tx_send_idle),
    .ctl_tx_send_rfi(ctl_tx_send_rfi),
    .ctl_tx_send_lfi(ctl_tx_send_lfi),
    .core_tx_reset(core_tx_reset),
    .stat_tx_pause_valid(stat_tx_pause_valid),
    .stat_tx_pause(stat_tx_pause),
    .stat_tx_user_pause(stat_tx_user_pause),
    .ctl_tx_pause_req(ctl_tx_pause_req),
    .ctl_tx_resend_pause(ctl_tx_resend_pause),
    .tx_axis_tready(axis_tx.TREADY),
    .tx_axis_tvalid(axis_tx.TVALID),
    .tx_axis_tdata(axis_tx.TDATA),
    .tx_axis_tlast(axis_tx.TLAST),
    .tx_axis_tkeep(axis_tx.TKEEP),
    .tx_axis_tuser(axis_tx.TUSER),
    .tx_ovfout(tx_ovfout),
    .tx_unfout(tx_unfout),
    .tx_preamblein(tx_preamblein),
    .usr_tx_reset(usr_tx_reset),
    .core_drp_reset(core_drp_reset),
    .drp_clk(drp_clk),
    .drp_addr(drp_addr),
    .drp_di(drp_di),
    .drp_en(drp_en),
    .drp_do(drp_do),
    .drp_rdy(drp_rdy),
    .drp_we(drp_we)
  );

endmodule
