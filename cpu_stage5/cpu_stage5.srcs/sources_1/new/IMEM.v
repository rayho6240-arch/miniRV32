
module IMEM(
    input  [31:0] addr,    // 來自 PC 的 32-bit 地址
    output [31:0] instr    // 輸出的 32-bit 指令
);

    // 定義存儲陣列：64 個空間，每個空間 32-bit 寬
    reg [31:0] rom [0:63];

    // 初始化：這裡放入真正的 RISC-V 機器碼 (十六進制)
    initial begin
        // 範例指令：
        rom[0] = 32'h00500113; // addi x2, x0, 5  (x2 = 0 + 5)
        rom[1] = 32'h002101b3; // add  x3, x2, x2  (x3 = 5 + 5 = 10)
        rom[2] = 32'h00000013; // nop
        // ... 其餘初始化為 0
    end

    // 【關鍵】定址轉換：因為 PC 是 +4 跳轉，讀取陣列時要 addr / 4
    // 使用 addr[31:2] 取代直接用 addr
    assign instr = rom[addr[31:2]];

endmodule