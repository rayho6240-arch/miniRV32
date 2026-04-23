module data_mem(
    input clk,
    input mem_write,    // 來自 Decoder 的 MemWrite
    input mem_read,     // 來自 Decoder 的 MemRead
    input [31:0] addr,  // 來自 ALU 的計算結果 (地址)
    input [31:0] wd,    // 要存入記憶體的資料 (來自 RegFile 的 rd2)
    output [31:0] rd    // 從記憶體讀出的資料
);

    // 定義 64 個 32-bit 的空間
    reg [31:0] ram [0:63];

    // 寫入邏輯：同步寫入
    always @(posedge clk) begin
        if (mem_write) begin
            ram[addr[31:2]] <= wd; // 地址右移兩位，對齊 Word
        end
    end

    // 讀取邏輯：非同步讀取 (也可以改同步，看你的設計需求)
    assign rd = (mem_read) ? ram[addr[31:2]] : 32'b0;

endmodule