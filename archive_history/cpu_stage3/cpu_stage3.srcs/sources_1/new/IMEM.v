`timescale 1ns / 1ps


module IMEM(
    input [3:0] addr,
    output [10:0] instr
    );
    reg [10:0] memory [0:15];

    integer i;
    initial begin
        // 1. 先將所有記憶體清空為 NOP
        for (i = 0; i < 16; i = i + 1)
            memory[i] = 11'b00_000_000_000; 

        // --- 開始編寫測試指令 ---

        // (0) SW R2, 位址(R2+R0) 
        // OP=11, RD=R2(010), RS1=R2(010), RS2=R0(000)
        // 效果：位址 (3+0=3) 的記憶體會被存入 R2 的值 (3)
        memory[0] = 11'b11_010_010_000; 

        // (1) ADD R1, R2, R3
        // OP=00, RD=R1(001), RS1=R2(010), RS2=R3(011)
        // 效果：R1 = 3 + 5 = 8
        memory[1] = 11'b00_001_010_011;

        // (2) LW R4, 位址(R2+R0)
        // OP=10, RD=R4(100), RS1=R2(010), RS2=R0(000)
        // 效果：從位址 3 讀出資料 (3)，存入 R4
        memory[2] = 11'b10_100_010_000;

        // (3) SUB R5, R1, R1
        // OP=01, RD=R5(101), RS1=R1(001), RS2=R1(001)
        // 效果：R5 = 8 - 8 = 0 (用來觸發 ALU 的 Zero Flag)
        memory[3] = 11'b01_101_001_001;
    end
    
    
    assign instr = memory[addr]; 
    
endmodule
