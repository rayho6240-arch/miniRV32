`timescale 1ns / 1ps

module IMEM(
    input  [3:0] addr,
    output [15:0] instr  // 【升級】指令輸出通道從 11 根線拓寬為 16 根線
);
    // 【升級】記憶體陣列：16 個格子，每個格子現在能裝 16-bit
    reg [15:0] memory [0:15];

    integer i;
    initial begin
        // 初始化記憶體
        for (i = 0; i < 16; i = i + 1)
            memory[i] = 16'b0000_000_000_000000; 

        // (0) ADDI R1, R0, 5  -> R1 = 5
        // Op:0010, Rd:001, Rs1:000, Imm:000101
        memory[0] = 16'b0010_001_000_000101; 

        // (1) ADDI R2, R0, 5  -> R2 = 5  //R2=R0+5
        // Op:0010, Rd:010, Rs1:000, Imm:000101
        memory[1] = 16'b0010_010_000_000101;

        // (2) BEQ R1, R2, Target:0 -> If R1==R2, jump to PC 0
        // Op:1000, Rd:XXX(dont care), Rs1:001, Rs2:010, Imm:000000 (Target PC 0)
        // 這裡我們把 target_pc 接在 imm[3:0]，所以最後四位填 0000
        memory[2] = 16'b1000_000_001_000000; // 最後四位改為 0000

        // (3) ADDI R3, R0, 9  -> 這行「不應該」被執行到
        memory[3] = 16'b0010_011_000_001001;
    end
    
    // 讀出對應位址的指令
    assign instr = memory[addr]; 
    
endmodule
