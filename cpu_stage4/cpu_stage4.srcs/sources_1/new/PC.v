`timescale 1ns / 1ps

module PC(
    input clk,
    input rst_n,           // 新增：重置輸入
    output reg [3:0] pc
);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            pc <= 4'd0;   // 當 rst_n 為 0 時，PC 歸零
        else 
            pc <= pc + 4'd1;
    end

endmodule