//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Wed Apr 29 21:36:13 2026
//Host        : LAPTOP-L8B3PG7A running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (btn,
    clk_create,
    hdmi_tx_clk_n,
    hdmi_tx_clk_p,
    hdmi_tx_n,
    hdmi_tx_p,
    rst_n);
  input [3:0]btn;
  input clk_create;
  output hdmi_tx_clk_n;
  output hdmi_tx_clk_p;
  output [2:0]hdmi_tx_n;
  output [2:0]hdmi_tx_p;
  input rst_n;

  wire [3:0]btn;
  wire clk_create;
  wire hdmi_tx_clk_n;
  wire hdmi_tx_clk_p;
  wire [2:0]hdmi_tx_n;
  wire [2:0]hdmi_tx_p;
  wire rst_n;

  design_1 design_1_i
       (.btn(btn),
        .clk_create(clk_create),
        .hdmi_tx_clk_n(hdmi_tx_clk_n),
        .hdmi_tx_clk_p(hdmi_tx_clk_p),
        .hdmi_tx_n(hdmi_tx_n),
        .hdmi_tx_p(hdmi_tx_p),
        .rst_n(rst_n));
endmodule
