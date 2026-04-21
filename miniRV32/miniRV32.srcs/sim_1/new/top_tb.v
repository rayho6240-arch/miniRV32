`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/20 10:22:47
// Design Name: 
// Module Name: top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module top_tb;

    // =========================
    // clock
    // =========================
    reg clk = 0;
    always #5 clk = ~clk;  // 100MHz 模擬時脈

    // =========================
    // DUT (你的 CPU)
    // =========================
    top uut (
        .clk(clk)
    );

    // =========================
    // simulation control
    // =========================
    initial begin

        // 初始化 register file 內容（如果你 RegFile 有 initial block 就不用管）
        #10;

        // 跑一段時間讓 CPU 完成運算
        #200;

        // 結束 simulation
        $finish;
    end

endmodule