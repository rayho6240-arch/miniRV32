`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/20 11:55:42
// Design Name: 
// Module Name: decoder
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


module decoder(
    input [10:0] instr,
    output [1:0] op,
    output [2:0] rs1,
    output [2:0] rs2,
    output [2:0] rd
    );
    
    assign op  = instr[10:9];
    assign rd  = instr[8:6];
    assign rs1 = instr[5:3];
    assign rs2 = instr[2:0];
    
endmodule
