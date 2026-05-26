`timescale 1ns / 1ps

module tb_top();

    // 1. 訊號宣告
    reg clk;
    reg rst_n; // 補上宣告
    wire [7:0] dbg_rs1;
    wire [7:0] dbg_rs2;
    wire [7:0] dbg_alu;

    // 2. 實例化 Top
    top uut (
        .clk(clk),
        // 注意：如果你的 top.v 沒有 rst_n 輸入，
        // 記得去 PC 模組跟 top.v 把 rst_n 接好
        .rst_n(rst_n), 
        .dbg_rs1(dbg_rs1),
        .dbg_rs2(dbg_rs2),
        .dbg_alu(dbg_alu)
    );

    // 3. 產生時脈 (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 每 5ns 翻轉一次
    end

    // 4. 重置邏輯與模擬控制
    initial begin
        rst_n = 0;      // 開始時重置
        #12 rst_n = 1;  // 12ns 後放開，確保跳過第一個 T=0 的上升沿
        
        $display("--------------------------------------------------");
        $display("Time\t PC\t OP\t RS1\t RS2\t RD\t ALU_Out");
        $display("--------------------------------------------------");

        #100;           // 執行一段時間
        $display("--------------------------------------------------");
        $display("模擬結束");
        $stop;
    end

    // 5. 強化版觀察窗
    // 改用 $monitor 或是更精準的採樣時間
    always @(posedge clk) begin
        // 在上升沿後 2ns 觀察，此時組合邏輯 (ALU) 已經穩定
        #2; 
        $display("Time:%d | PC:%d | OP:%b | RS1:%d | RS2:%d | RD:%d | ALU:%d", 
                 $time, uut.pc, uut.op, uut.rs1, uut.rs2, uut.rd, dbg_alu);
    end

endmodule