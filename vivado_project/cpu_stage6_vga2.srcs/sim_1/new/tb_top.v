`timescale 1ns / 1ps

module tb_top();

    // 宣告要接給 top 模組的虛擬訊號
    reg clk;
    reg rst_n;
    reg btn;
    
    wire [31:0] dbg_pc;
    wire [31:0] dbg_instr;

    // 實例化你的 CPU (待測物)
    top u_top (
        .clk(clk),
        .rst_n(rst_n),
        .btn(btn),
        .dbg_pc(dbg_pc),
        .dbg_instr(dbg_instr)
    );

    // 產生時鐘訊號 (每 5ns 翻轉一次，週期 10ns = 100MHz)
    always #5 clk = ~clk;

    // 模擬腳本：這就是你扮演上帝的地方
    initial begin
        // 1. 系統初始化
        clk = 0;
        rst_n = 0;   // 按下重置按鈕
        btn = 0;     // 按鈕沒被按下
        
        // 2. 等待一段時間後，放開重置按鈕，讓 CPU 開始執行
        #20;         
        rst_n = 1;
        
        // 此時 CPU 應該會卡在 inst.hex 的第 2~3 行 (監聽按鈕)
        #100;
        
        // 3. 模擬玩家按下跳躍按鈕！
        $display("--> player press button");
        btn = 1;     
        #20;         // 按住 2個 Clock 週期
        
        // 4. 玩家放開按鈕
        $display("--> player loose button！");
        btn = 0;     
        
        // 讓他再跑一陣子觀察 x12 是否有成功 +1
        #100;
        
        // 5. 結束模擬
        $finish;
    end

endmodule