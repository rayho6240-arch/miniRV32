`timescale 1ns / 1ps

module top_tb();
    reg clk;
    reg rst_n;
    
    // 觀察訊號
    wire [31:0] dbg_pc;
    wire [31:0] dbg_instr;

    // 實例化你的 CPU Top
    top uut (
        .clk(clk),
        .rst_n(rst_n),
        .dbg_pc(dbg_pc),
        .dbg_instr(dbg_instr)
    );

    // 產生時鐘：10ns 一個週期 (100MHz)
    always #5 clk = ~clk;

    initial begin
        // 初始化
        clk = 0;
        rst_n = 0;
        
        // 重置系統
        #10 rst_n = 1;
        
        // 執行一段時間
        #100;
        
        // 結束模擬
        $display("===== 模擬結束 =====");
        $finish;
    end

    // 核心監控邏輯：每一格時鐘印出目前的狀態
    always @(posedge clk) begin
        if (rst_n) begin
            $display("Time: %t | PC: %h | Instr: %h", $time, dbg_pc, dbg_instr);
            // 你也可以在 top 裡把 x1, x2 拉出來 dbg，這裡就能印出來
            // $display("x1: %d | x2: %d", uut.u_rf.rf[1], uut.u_rf.rf[2]);
        end
    end

endmodule