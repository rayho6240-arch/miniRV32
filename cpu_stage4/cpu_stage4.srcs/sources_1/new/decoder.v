module decoder(
    input  [15:0] instr,      // 【升級】指令寬度從 11-bit 變成 16-bit
    
    output [3:0]  op,         // 【升級】Opcode 變成 4-bit，可以容納 16 種指令
    output [2:0]  rs1,
    output [2:0]  rs2,
    output [2:0]  rd,
    output [5:0]  imm,        // 【新增】從指令中切下來的 6-bit 立即數 (數字)
    
    // --- 控制訊號 (Control Signals) ---
    output reg RegWrite,      // 允許寫回暫存器
    output reg MemtoReg,      // 1: 寫回記憶體資料, 0: 寫回 ALU 結果
    output reg MemWrite,      // 允許寫入記憶體
    output reg MemRead,       // 允許讀取記憶體
    output reg ALUSrc,        // 【新增】0: ALU 吃 RS2, 1: ALU 吃立即數(imm)
    output reg Branch         //用於跳轉指令
);

    // 1. 拆解 16-bit 指令 (硬體接線)
    assign op  = instr[15:12]; // 前 4 個 bit 是指令代碼
    assign rd  = instr[11:9];  // 接下來 3 個 bit 是目的地
    assign rs1 = instr[8:6];   // 接下來 3 個 bit 是來源 1
    assign rs2 = instr[2:0];   // 最後 3 個 bit 是來源 2 (只有部分指令會用到)
    assign imm = instr[5:0];   // 【精華】把最後 6 個 bit 當作常數數字

    // 2. 根據 op 產生控制訊號
    always @(*) begin
        // 預設所有控制訊號為 0，避免產生 Latch (未知狀態)
        RegWrite = 0;
        MemtoReg = 0;
        MemWrite = 0;
        MemRead  = 0;
        ALUSrc   = 0;

        case (op)
            4'b0000: begin // ADD (暫存器 + 暫存器)
                RegWrite = 1;
                ALUSrc   = 0; // ALU 第二輸入選 RS2
            end
            
            4'b0001: begin // SUB (暫存器 - 暫存器)
                RegWrite = 1;
                ALUSrc   = 0;
            end
            
            4'b0010: begin // ADDI (新增：暫存器 + 立即數)
                RegWrite = 1;
                ALUSrc   = 1; // 【關鍵】ALU 第二輸入改選 imm
            end

            4'b0100: begin // LW (讀取記憶體)
                RegWrite = 1;
                MemtoReg = 1; // 資料來自 Memory
                MemRead  = 1;
                ALUSrc   = 1; // 【改變】我們未來用 RS1 + imm 來算位址
            end

            4'b0101: begin // SW (寫入記憶體)
                MemWrite = 1;
                ALUSrc = 1; // 位址一樣用 RS1 + imm 來算
            end
            
            4'b1000: begin // BEQ (Branch if Equal)
                RegWrite = 0; // 跳轉指令不寫入暫存器
                ALUSrc   = 0; // 比較兩個暫存器 (RS1 vs RS2)
                // 我們需要一個新訊號告訴 Top：這是一條 Branch 指令
                Branch   = 1; 
            end
            
            default: ; // 其他未定義指令不做事
        endcase
    end

endmodule