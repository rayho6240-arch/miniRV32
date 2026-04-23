`timescale 1ns / 1ps


module vram(
    input clk,
    input [7:0] write_addr, //the location cpu give --> light bull non the monitor
    input [2:0] din, // color select RGB
    input we,   //write in or not control
    input [7:0] read_addr, // 顯示控制器讀取的位址
    output reg [2:0] dout      // 輸出給顯示器的顏色
    );
    
    // 建立 256 個存儲單元 (16x16 像素)
    reg [2:0] mem [0:255];

    // CPU 寫入埠
    always @(posedge clk) begin
        if (we)
            mem[write_addr] <= din;
    end

    // 顯示器讀取埠 (非同步讀取以確保顯示流暢)
    always @(posedge clk) begin
        dout <= mem[read_addr];
    end
    
    
    
endmodule
