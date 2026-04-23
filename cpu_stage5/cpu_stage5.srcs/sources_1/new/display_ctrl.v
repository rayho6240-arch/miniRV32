`timescale 1ns / 1ps
module display_ctrl(
    input clk,          // 建議使用 25MHz (標準 VGA 時鐘)
    input rst_n,
    input [2:0] vram_data,    // 從 VRAM 讀出來的顏色
    output [7:0] vram_addr,   // 送往 VRAM 的讀取地址
    output reg hsync,
    output reg vsync,
    output reg [2:0] rgb      // 最終輸出給螢幕的顏色
);

    // 以 640x480 @ 60Hz 為基準，但我們只取中間一小塊
    reg [9:0] h_cnt; 
    reg [9:0] v_cnt;

    // --- 水平與垂直計數邏輯 ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_cnt <= 0;
            v_cnt <= 0;
        end else begin
            if (h_cnt == 799) begin
                h_cnt <= 0;
                if (v_cnt == 524) v_cnt <= 0;
                else v_cnt <= v_cnt + 1;
            end else h_cnt <= h_cnt + 1;
        end
    end

    // --- 同步訊號產生 ---
    always @(*) begin
        hsync = (h_cnt < 96) ? 0 : 1; // Sync pulse width = 96
        vsync = (v_cnt < 2)  ? 0 : 1; // Sync pulse width = 2
    end

    // --- VRAM 地址計算 (16x16 解析度) ---
    // 我們選取螢幕中央一塊區域顯示，避免邊緣裁切
    wire is_visible = (h_cnt >= 10'd300 && h_cnt < 10'd316) && 
                  (v_cnt >= 10'd200 && v_cnt < 10'd216);
    
    // 將 640x480 的座標對應到 16x16 的 VRAM 地址
    wire [3:0] row = v_cnt[3:0] - 4'd8; // 簡化座標，或確保數值範圍正確
    wire [3:0] col = h_cnt[3:0] - 4'd12; 
    assign vram_addr = {row, col};
    // --- 像素輸出邏輯 ---
    always @(*) begin
        if (is_visible)
            rgb = vram_data; // 顯示 VRAM 內容
        else
            rgb = 3'b000;    // 消隱區或非顯示區輸出黑色
    end

endmodule
