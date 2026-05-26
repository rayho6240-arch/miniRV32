`default_nettype none

module decoder_rv32(
    input  wire [31:0] instr,
    output wire [4:0]  rs1, rs2, rd,
    output wire [3:0]  alu_op,
    output wire        RegWrite, ALUSrc, MemWrite, MemRead, MemtoReg, Branch,
    output wire        Jump, Jalr // <--- 新增這兩個訊號
);

    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd  = instr[11:7];

    // --- 控制訊號邏輯更新 ---
    // RegWrite: R-type, I-type, LW, JAL, JALR 都需要寫暫存器
    assign RegWrite = (opcode == 7'b0110011) || (opcode == 7'b0010011) || 
                      (opcode == 7'b0000011) || (opcode == 7'b1101111) || (opcode == 7'b1100111);
    
    assign ALUSrc   = (opcode == 7'b0010011) || (opcode == 7'b0000011) || (opcode == 7'b0100011);
    assign MemRead  = (opcode == 7'b0000011);
    assign MemWrite = (opcode == 7'b0100011);
    assign MemtoReg = (opcode == 7'b0000011);
    assign Branch   = (opcode == 7'b1100011);
    
    // 跳轉控制
    assign Jump = (opcode == 7'b1101111); // JAL
    assign Jalr = (opcode == 7'b1100111); // JALR

    // 修正範例：如果是 R-type 的減法，或是 Branch 指令，都讓 ALU 執行減法模式
    // ⚠️ 修正重點：將 instr[30] 改為明確的布林條件判斷式 instr[30] == 1'b1
    assign alu_op = ((opcode == 7'b0110011 && instr[30] == 1'b1) || (opcode == 7'b1100011)) ? 4'b1000 : 4'b0000; 
    
endmodule