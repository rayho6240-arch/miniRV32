`timescale 1ns / 1ps

module decoder(
    input [10:0] instr,
    output [1:0] op,
    output [2:0] rs1,
    output [2:0] rs2,
    output [2:0] rd,
    // 在 always 區塊中賦值的輸出必須宣告為 reg
    output reg RegWrite, 
    output reg MemtoReg, 
    output reg MemWrite, 
    output reg MemRead    
    );
    
    // 基本欄位拆解
    assign op  = instr[10:9];
    assign rd  = instr[8:6];
    assign rs1 = instr[5:3];
    assign rs2 = instr[2:0];
    
    // 控制訊號邏輯
    always @(*) begin
        // 先給預設值，避免產生不想要的 Latch
        RegWrite = 1'b0;
        MemtoReg = 1'b0;    //0 : ALU result //1 : Memory data //Who write to RegFile
        MemWrite = 1'b0;
        MemRead  = 1'b0;

    //這些東西會在top中以wire存著。是控制信號
        case (op)
            2'b00: begin // ADD
                RegWrite = 1'b1;
                MemtoReg = 1'b0; // regFile's data get from ALU's output
            end
            2'b01: begin // SUB
                RegWrite = 1'b1;
                MemtoReg = 1'b0; // 來源是 ALU
            end
            2'b10: begin // LW (Load Word)
                RegWrite = 1'b1;
                MemtoReg = 1'b1; // 來源是 Memory
                MemRead  = 1'b1;
            end
            2'b11: begin // SW (Store Word)
                RegWrite = 1'b0; // 不寫回暫存器
                MemWrite = 1'b1; // 開啟記憶體寫入
            end
            default: ; 
        endcase
    end
    
endmodule