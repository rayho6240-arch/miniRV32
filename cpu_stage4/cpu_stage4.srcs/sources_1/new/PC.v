`timescale 1ns / 1ps

module PC(
    input clk,
    input rst_n,
    input PCSrc,           // 【新增】跳轉開關 (1: 跳轉, 0: 繼續走)
    input [3:0] target_pc, // 【新增】跳轉的目標地址
    output reg [3:0] pc
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= 4'b0000;
        else begin
            if (PCSrc)
                pc <= target_pc; // 執行跳轉
            else
                pc <= pc + 1;    // 繼續直線前進
        end
    end

endmodule