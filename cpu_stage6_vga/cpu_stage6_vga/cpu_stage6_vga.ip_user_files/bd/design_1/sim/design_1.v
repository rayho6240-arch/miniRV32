//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Wed Apr 29 21:36:13 2026
//Host        : LAPTOP-L8B3PG7A running 64-bit major release  (build 9200)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
   (btn,
    clk_create,
    hdmi_tx_clk_n,
    hdmi_tx_clk_p,
    hdmi_tx_n,
    hdmi_tx_p,
    rst_n);
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.BTN DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.BTN, LAYERED_METADATA undef" *) input [3:0]btn;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_CREATE CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_CREATE, CLK_DOMAIN design_1_clk_create, FREQ_HZ 125000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input clk_create;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.HDMI_TX_CLK_N DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.HDMI_TX_CLK_N, LAYERED_METADATA undef" *) output hdmi_tx_clk_n;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.HDMI_TX_CLK_P DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.HDMI_TX_CLK_P, LAYERED_METADATA undef" *) output hdmi_tx_clk_p;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.HDMI_TX_N DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.HDMI_TX_N, LAYERED_METADATA undef" *) output [2:0]hdmi_tx_n;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.HDMI_TX_P DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.HDMI_TX_P, LAYERED_METADATA undef" *) output [2:0]hdmi_tx_p;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RST_N RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RST_N, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input rst_n;

  wire [3:0]btn;
  wire clk_create;
  wire clk_wiz_0_clk_out1;
  wire clk_wiz_0_clk_out2;
  wire clk_wiz_0_clk_out3;
  wire clk_wiz_0_locked;
  wire hdmi_tx_clk_n;
  wire hdmi_tx_clk_p;
  wire [2:0]hdmi_tx_n;
  wire [2:0]hdmi_tx_p;
  wire rst_n;

  design_1_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(clk_create),
        .clk_out1(clk_wiz_0_clk_out1),
        .clk_out2(clk_wiz_0_clk_out2),
        .clk_out3(clk_wiz_0_clk_out3),
        .locked(clk_wiz_0_locked),
        .resetn(rst_n));
  design_1_top_0_2 top_0
       (.btn(btn),
        .clk_cpu(clk_wiz_0_clk_out3),
        .clk_pix(clk_wiz_0_clk_out1),
        .clk_pix_5x(clk_wiz_0_clk_out2),
        .hdmi_tx_clk_n(hdmi_tx_clk_p),
        .hdmi_tx_clk_p(hdmi_tx_clk_n),
        .hdmi_tx_n(hdmi_tx_n),
        .hdmi_tx_p(hdmi_tx_p),
        .locked(clk_wiz_0_locked),
        .rst_n(rst_n));
endmodule
