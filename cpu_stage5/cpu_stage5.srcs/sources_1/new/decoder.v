
module decoder_rv32(
    input [31:0] instr,
    output [4:0] rs1, rs2, rd,
    output [3:0] alu_op,
    output RegWrite, ALUSrc, MemWrite, MemRead, MemtoReg, Branch
);


    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    // 1. 寄存器地址切片 (位置是固定的，這是 RISC-V 的優點)
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd  = instr[11:7];

    // 2. 控制訊號邏輯 (以常用的為例)
    assign RegWrite = (opcode == 7'b0110011) || (opcode == 7'b0010011) || (opcode == 7'b0000011); // R-type, I-type, LW
    assign ALUSrc   = (opcode == 7'b0010011) || (opcode == 7'b0000011) || (opcode == 7'b0100011); // 使用立即數
    assign MemRead  = (opcode == 7'b0000011); // LW
    assign MemWrite = (opcode == 7'b0100011); // SW
    assign MemtoReg = (opcode == 7'b0000011); // 把 Mem 資料寫回 Reg
    assign Branch   = (opcode == 7'b1100011); // BEQ/BNE

    // 3. ALU Op 簡易對應 (結合 funct3 與 funct7)
    // 這裡需要根據你的 ALU_32 設計來對應
    assign alu_op = (opcode == 7'b0110011 && funct7[5]) ? 4'b1000 : 4'b0000; // 範例：判斷 ADD 還是 SUB


endmodule