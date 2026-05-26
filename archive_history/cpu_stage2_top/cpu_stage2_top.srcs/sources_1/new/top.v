`timescale 1ns / 1ps

module top(
    input clk,
    input rst_n,
    output [7:0] dbg_rs1,
    output [7:0] dbg_rs2,
    output [7:0] dbg_alu
);

    wire [7:0] rd1;
    wire [7:0] rd2;
    wire [7:0] alu_out;
    wire [3:0] pc;
    wire [10:0] instr;
    wire [2:0] rs1, rs2, rd; 
    wire [1:0] op;
    
    wire       RegWrite;
    assign RegWrite = 1'b1;
    wire [7:0] wd;
    assign wd = alu_out;
    
    
    
    PC pc_inst(
        .clk(clk),
        .rst_n(rst_n),
        .pc(pc)
    );
    
    IMEM imem_inst(
        .addr(pc),
        .instr(instr)
    );
    
    decoder dec_inst(
        .op(op),
        .instr(instr),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd)
    );
    
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
        .OP(op),
        .Sum(alu_out),
        .OV()
    );


    //DEBUG OUTPUT
    assign dbg_rs1 = rd1;
    assign dbg_rs2 = rd2;
    assign dbg_alu = alu_out;

endmodule