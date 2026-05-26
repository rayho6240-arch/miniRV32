`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg rst_n;
    wire [7:0] dbg_rs1, dbg_rs2, dbg_alu;

    // 實例化 Top 模組
    top uut (
        .clk(clk),
        .rst_n(rst_n),
        .dbg_rs1(dbg_rs1),
        .dbg_rs2(dbg_rs2),
        .dbg_alu(dbg_alu)
    );

    // 時鐘產生：10ns 為一個週期 (100MHz)
    always #5 clk = ~clk;

    initial begin
        // --- 初始化 ---
        clk = 0;
        rst_n = 0;
        
        // 在 IMEM 載入測試指令 (這裡假設你的 IMEM 支援 $readmemh 或手動賦值)
        // 注意：指令格式 [OP(2)][RD(3)][RS1(3)][RS2(3)]
        // 假設 OP: 00=ADD, 01=SUB, 10=LW, 11=SW
        // R2 初始值為 3, R3 初始值為 5 (根據你的 Spec)

        /*手動模擬 IMEM 內容 (請根據你的 IMEM 實作調整):
           instr[0] = 11_000_010_000; // SW: addr=R2+R0(3), data=R2(3) -> 把 3 存進位址 3
           instr[1] = 00_001_010_011; // ADD: R1 = R2 + R3 = 8
           instr[2] = 10_100_010_000; // LW: addr=R2+R0(3), rd=R4 -> 從位址 3 讀出 3 存入 R4
           instr[3] = 01_101_010_010; // SUB: R5 = R2 - R2 = 0 (測試 Zero Flag)
        */

        #12 rst_n = 1; // 釋放重置

        // --- 觀察過程 ---
        
        // 週期 1: 執行 SW
        #10;
        $display("Time:%t | PC:0 | SW  - Data:%d to Addr:%d", $time, dbg_rs2, dbg_alu);

        // 週期 2: 執行 ADD
        #10;
        $display("Time:%t | PC:1 | ADD - R1 = %d", $time, dbg_alu);

        // 週期 3: 執行 LW
        #10;
        $display("Time:%t | PC:2 | LW  - R4 loaded with %d", $time, uut.final_wd);

        // 週期 4: 執行 SUB
        #10;
        $display("Time:%t | PC:3 | SUB - Result: %d, Zero: %b", $time, dbg_alu, uut.zero);

        #50;
        $finish;
    end

endmodule