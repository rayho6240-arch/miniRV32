module ALU_32(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0]  alu_op,  // 暫時延用 4-bit 編碼，稍後再對齊 RISC-V 標準
    output reg [31:0] result,
    output wire zero
);

    always @(*) begin
        case(alu_op)
            4'b0000: result = a + b;           // ADD
            4'b1000: result = a - b;           // SUB
            4'b0001: result = a << b[4:0];     // SLL
            4'b0101: result = a >> b[4:0];     // SRL
            4'b1101: result = $signed(a) >>> b[4:0]; // SRA (算術右移)
            4'b0010: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT (C 語言 if 的核心)
            4'b0011: result = (a < b) ? 32'd1 : 32'd0; // SLTU
            4'b0100: result = a ^ b;           // XOR
            4'b0110: result = a | b;           // OR
            4'b0111: result = a & b;           // AND
            default: result = 32'b0;
        endcase
    end
    
    // 零值檢測 (用於 Branch 指令)
    assign zero = (result == 32'b0);

endmodule