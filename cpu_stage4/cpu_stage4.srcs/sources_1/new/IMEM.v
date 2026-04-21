`timescale 1ns / 1ps

module IMEM(
    input  [3:0] addr,
    output [15:0] instr  // 【升級】指令輸出通道從 11 根線拓寬為 16 根線
);
    // 【升級】記憶體陣列：16 個格子，每個格子現在能裝 16-bit
    reg [15:0] memory [0:15];

    integer i;
    initial begin
        // 先將所有記憶體清空為 NOP (全 0)
        for (i = 0; i < 16; i = i + 1)
            memory[i] = 16'b0000_000_000_000000; 

        // --- 16-bit 最新測試指令 ---
        // 格式：[15:12] OP | [11:9] RD | [8:6] RS1 | [5:0] IMM 或 RS2

        // (0) ADDI R2, R0, 7 
        // 說明：R2 = 0 + 7 (驗證：把常數 7 載入 R2)
        // OP=0010(ADDI), RD=010(R2), RS1=000(R0), IMM=000111 (7)
        memory[0] = 16'b0010_010_000_000111; 

        // (1) ADDI R3, R0, 3
        // 說明：R3 = 0 + 3 (驗證：把常數 3 載入 R3)
        // OP=0010(ADDI), RD=011(R3), RS1=000(R0), IMM=000011 (3)
        memory[1] = 16'b0010_011_000_000011;

        // (2) SUB R1, R2, R3
        // 說明：R1 = 7 - 3 = 4 (驗證：ALU 是否能正常進行暫存器相減)
        // OP=0001(SUB), RD=001(R1), RS1=010(R2), RS2=011(R3)
        // 注意：[5:3] 不重要填0，[2:0] 填 RS2
        memory[2] = 16'b0001_001_010_000011;
        
    end
    
    // 讀出對應位址的指令
    assign instr = memory[addr]; 
    
endmodule
