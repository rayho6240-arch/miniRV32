module PC(
    input clk,
    input rst_n,
    input [31:0] next_pc, // 【關鍵】新增這個輸入埠，用來接收 top 計算好的下一個地址
    output reg [31:0] pc
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'b0;      // 重置時從地址 0 開始
        end else begin
            pc <= next_pc;    // 每個時鐘週期，將下一跳地址存入 PC
        end
    end

endmodule