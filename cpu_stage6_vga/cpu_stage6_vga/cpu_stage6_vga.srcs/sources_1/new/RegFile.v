`timescale 1ns / 1ps

module RegFile(
    input wire clk,
    input wire [4:0] rs1,    // 32 個寄存器需要 5-bit 地址 (2^5 = 32)
    input wire [4:0] rs2,
    input wire [4:0] rd,
    input wire [31:0] wd,    // 資料寬度升級為 32-bit
    input wire RegWrite,
    output wire [31:0] rd1,
    output wire [31:0] rd2
);
    // 定義 32 個 32-bit 的寄存器
    reg [31:0] rf [0:31];

    // 初始化寄存器
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) rf[i] = 32'b0;
    end

    // 寫入邏輯：只有在 RegWrite 為高，且目標不是 x0 時才寫入
    always @(posedge clk) begin
        if (RegWrite && (rd != 5'd0)) begin
            rf[rd] <= wd;
        end
    end

    // 讀取邏輯：x0 恆為 0，其餘正常讀取
    assign rd1 = (rs1 == 5'd0) ? 32'b0 : rf[rs1];
    assign rd2 = (rs2 == 5'd0) ? 32'b0 : rf[rs2];

endmodule