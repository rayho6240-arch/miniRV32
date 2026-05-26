`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg rst_n;
    wire [31:0] dbg_pc;
    wire [31:0] dbg_instr;

    // 實例化頂層模組
    top u_top (
        .clk(clk),
        .rst_n(rst_n),
        .dbg_pc(dbg_pc),
        .dbg_instr(dbg_instr)
    );

    // 產生時鐘 (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // 測試流程
    initial begin
        // 1. 初始化系統
        rst_n = 0;
        
        // 2. 解除重置，開始跑程式
        #20 rst_n = 1; 

        // 3. 設定模擬時間 (2000ns 足夠跑完基本測試)
        #2000;
        
        $display("======= simulation done=======");
        $finish;
    end

    // 監控系統：實時印出 CPU 狀態
    initial begin
        $display("time\tPC\tinst\t\tx3(result)\tx1(backaddr)");
        $display("------------------------------------------------------------");
        // 根據你的 RegFile.v，內部陣列名稱是 rf
        $monitor("%0t\t%h\t%h\t%d\t%h", 
                 $time, 
                 dbg_pc, 
                 dbg_instr, 
                 u_top.u_rf.rf[3],  // 監控 x3 暫存器 (通常放運算結果)
                 u_top.u_rf.rf[1]); // 監控 x1 暫存器 (通常放 JAL 返回位址)
    end

endmodule