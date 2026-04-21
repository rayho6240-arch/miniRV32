`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/20 10:19:44
// Design Name: 
// Module Name: RegFile
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


module RegFile(
    input clk,

    // read ports
    input  [2:0] rs1, //register source 1
    input  [2:0] rs2, //register source 2
    output [7:0] rd1, //rd = Register Data for source 1
    output [7:0] rd2,

    // write port
    input        RegWrite,
    input  [2:0] rd,  //rd = Register Destination
    input  [7:0] wd   // write back data 8'bit
);


    // 8 registers, 8-bit each
    reg [7:0] R [0:7];
    

    integer i;

    // asynchronous read
    assign rd1 = (rs1 == 3'b000) ? 8'b0 : R[rs1];
    assign rd2 = (rs2 == 3'b000) ? 8'b0 : R[rs2];

    // synchronous write
    always @(posedge clk) begin
        if (RegWrite && rd != 3'b000) begin
            R[rd] <= wd;
        end
    end

    // init for simulation, now is just for test. we define a const 
    initial begin
        R[0] = 0;
        R[1] = 1;
        R[2] = 8'd3;
        R[3] = 8'd5;
        R[4] = 0;
        R[5] = 0;
        R[6] = 0;
        R[7] = 0;
    end

endmodule
