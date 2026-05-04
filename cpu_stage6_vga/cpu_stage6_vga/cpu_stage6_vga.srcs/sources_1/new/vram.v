module vram (
    // Port A: 由 CPU 寫入 (cpu_clk)
    input wire           clk_cpu,
    input  wire          we,          // 寫入致能 (MemWrite && is_vram)
    input  wire   [11:0] addr_cpu,    // CPU 提供的位址 (對應螢幕座標)
    input  wire   [31:0] data_in,     // CPU 要寫入的顏色數據

    // Port B: 由 HDMI 控制器讀取 (pixel_clk)
    input   wire         clk_pixel,
    input  wire   [11:0] addr_pixel,  // HDMI 掃描到的像素位址
    output reg [23:0] data_out    // 輸出給螢幕的 RGB 顏色
);

    // 這裡我們定義 4096 個存儲單元 (可視為 64x64 的小圖塊，或簡化的顯示區)
    // 每個單元存儲 24-bit 顏色 (R:8, G:8, B:8)
    reg [23:0] mem [0:4095];

    // Port A: 寫入邏輯
    always @(posedge clk_cpu) begin
        if (we) begin
            mem[addr_cpu] <= data_in[23:0]; // 只取低 24 位元作為顏色
        end
    end

    // Port B: 讀取邏輯
    always @(posedge clk_pixel) begin
        data_out <= mem[addr_pixel];
    end

endmodule