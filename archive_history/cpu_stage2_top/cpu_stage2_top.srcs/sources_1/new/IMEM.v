`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/20 11:55:42
// Design Name: 
// Module Name: IMEM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IMEM(
    input [3:0] addr,
    output [10:0] instr
    );
    reg [10:0] memory [0:15];

    integer i;
    initial begin
        for (i = 0; i < 16; i = i + 1)
            memory[i] = 11'b00_000_000_000;  // NOP
    
        memory[0] = 11'b00_001_010_011; // ADD R1 = R2 + R3
        memory[1] = 11'b01_010_001_011; // SUB R2 = R1 - R3
        memory[2] = 11'b10_011_010_001; // AND R3 = R2 & R1
    end
    
    assign instr = memory[addr]; 
    
endmodule
