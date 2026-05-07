module decoder_rv32(
    input  wire [31:0] instr,
    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output wire [4:0]  rd,
    output reg [3:0] alu_op,
    output reg    RegWrite,
    output reg    ALUSrc,
    output reg    MemWrite,
    output reg    MemRead,
    output reg    MemtoReg,
    output reg    Branch,
    output reg    Jump,
    output reg    Jalr,
    output reg    Lui,
    output reg    Aui
);

    // 提取指令欄位
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd  = instr[11:7];

    always @(*) begin
        // --- 1. 設定預設值 (防止 Latch，這步最重要) ---
        alu_op   = 4'b0000; // 預設加法
        RegWrite = 0;
        ALUSrc   = 0;
        MemWrite = 0;
        MemRead  = 0;
        MemtoReg = 0;
        Branch   = 0;
        Jump     = 0;
        Jalr     = 0;
        Lui      = 0;
        Aui      = 0;

        case(opcode)
            // R-type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
            7'b0110011: begin
                RegWrite = 1;
                // 根據 funct3 和 funct7 決定 ALU 操作
                case(funct3)
                    3'b000: alu_op = (funct7[5]) ? 4'b1000 : 4'b0000; // SUB : ADD
                    3'b001: alu_op = 4'b0001; // SLL
                    3'b010: alu_op = 4'b0010; // SLT
                    3'b011: alu_op = 4'b0011; // SLTU
                    3'b100: alu_op = 4'b0100; // XOR
                    3'b101: alu_op = (funct7[5]) ? 4'b1101 : 4'b0101; // SRA : SRL
                    3'b110: alu_op = 4'b0110; // OR
                    3'b111: alu_op = 4'b0111; // AND
                endcase
            end

            // I-type 運算 (ADDI, SLTI, etc.)
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc   = 1; // 使用立即數
                case(funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b010: alu_op = 4'b0010; // SLTI
                    3'b100: alu_op = 4'b0100; // XORI
                    3'b110: alu_op = 4'b0110; // ORI
                    3'b111: alu_op = 4'b0111; // ANDI
                    // 位移類 I-type
                    3'b001: alu_op = 4'b0001; // SLLI
                    3'b101: alu_op = (funct7[5]) ? 4'b1101 : 4'b0101; // SRAI : SRLI
                endcase
            end

            // I-type Load (LW)
            7'b0000011: begin
                RegWrite = 1;
                ALUSrc   = 1;
                MemRead  = 1;
                MemtoReg = 1;
                alu_op   = 4'b0000; // 地址計算使用加法
            end

            // S-type Store (SW)
            7'b0100011: begin
                ALUSrc   = 1;
                MemWrite = 1;
                alu_op   = 4'b0000; // 地址計算使用加法
            end

            // B-type Branch (BEQ, BNE, BLT, BGE)
            7'b1100011: begin
                Branch = 1;
                alu_op = 4'b1000; // 內部使用減法做比較
            end

            // JAL (Jump and Link)
            7'b1101111: begin
                RegWrite = 1;
                Jump     = 1;
            end

            // JALR
            7'b1100111: begin
                RegWrite = 1;
                Jalr     = 1;
            end

            // LUI
            7'b0110111: begin
                RegWrite = 1;
                Lui      = 1;
            end

            // AUIPC
            7'b0010111: begin
                RegWrite = 1;
                Aui      = 1;
            end

            default: ; // NOP or Unknown
        endcase
    end
endmodule