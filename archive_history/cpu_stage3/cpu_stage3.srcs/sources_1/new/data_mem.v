`timescale 1ns / 1ps


module data_mem (
    input        clk,
    input        mem_write,  // 來自 Decoder 的寫入致能訊號 (sw 指令)允許寫入否
    input        mem_read,   // 來自 Decoder 的讀取致能訊號 (lw 指令)允許讀取否
    input  [3:0] addr,       // 位址輸入 (來自 ALU 結果)
    input  [7:0] wd,         // 要寫入的資料 (來自 RegFile 的 RS2)
    output [7:0] rd          // 讀出的資料 (接回 RegFile 的寫入端)
);

    reg [7:0] ram [15:0];    // 16 個 8-bit 存儲單元

    // 寫入邏輯：在時鐘上升沿執行 (或配合你的 RegFile 下降沿策略)
    always @(posedge clk) begin
        if (mem_write)
            ram[addr] <= wd;
    end

    // 讀取邏輯：組合邏輯讀取 (非同步)，確保在同一個週期內資料可用
    assign rd = (mem_read) ? ram[addr] : 8'h00;

endmodule
