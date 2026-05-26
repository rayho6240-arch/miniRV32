module top(
    input clk,
    output [7:0] dbg_rs1,
    output [7:0] dbg_rs2,
    output [7:0] dbg_alu
);

    wire [7:0] rd1;
    wire [7:0] rd2;
    wire [7:0] alu_out;

    reg        RegWrite;
    reg  [2:0] rs1, rs2, rd;
    reg  [7:0] wd;

    RegFile rf(
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd1(rd1),
        .rd2(rd2),
        .RegWrite(RegWrite),
        .rd(rd),
        .wd(wd)
    );

    ALU_8 alu(
        .A(rd1),
        .B(rd2),
        .OP(1'b0),
        .Sum(alu_out),
        .OV()
    );

    // 🔥 DEBUG OUTPUT
    assign dbg_rs1 = rd1;
    assign dbg_rs2 = rd2;
    assign dbg_alu = alu_out;

    reg [1:0] state = 0;

    always @(posedge clk) begin
        case(state)

            0: begin
                rs1 <= 3'd2;
                rs2 <= 3'd3;
                rd  <= 3'd1;
                RegWrite <= 0;
                state <= 1;
            end

            1: begin
                wd <= alu_out;
                RegWrite <= 1;
            end

            2: begin
                RegWrite <= 0;
            end

        endcase
    end

endmodule