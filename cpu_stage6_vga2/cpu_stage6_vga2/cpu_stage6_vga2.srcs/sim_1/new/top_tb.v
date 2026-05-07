`timescale 1ns / 1ps

module top_tb();
    reg clk;
    reg rst_n;
    reg btn;
    
    wire [31:0] dbg_pc;
    wire [31:0] dbg_instr;

    // 實例化 CPU
    top uut (
        .clk(clk),
        .rst_n(rst_n),
        .btn(btn),
        .dbg_pc(dbg_pc),
        .dbg_instr(dbg_instr)
    );

    // 產生時鐘 (50MHz)
    always #10 clk = ~clk;

    initial begin
        // 初始化訊號
        clk = 0;
        rst_n = 0;
        btn = 0;

        $display("===== RISC-V RV32I Simulation Start =====");
        
        // 1. 重置系統
        #25 rst_n = 1;
        
        // 2. 模擬執行一段時間
        // 預期：
        // x1=10, x2=20, x3=30
        // x4=0x12345000 (LUI)
        // x5=0x00001010 (AUIPC)
        #500;

        // 3. 顯示結果
        $display("Final Status:");
        $display("PC      : %h", dbg_pc);
        $display("Instr   : %h", dbg_instr);
        
        // 這裡請確認你的 RegFile 內部的陣列名稱是否為 regs
        $display("Reg x1  : %d (Expected: 10)", uut.u_rf.rf[1]);
        $display("Reg x2  : %d (Expected: 20)", uut.u_rf.rf[2]);
        $display("Reg x3  : %d (Expected: 30)", uut.u_rf.rf[3]);
        $display("Reg x4  : %h (Expected: 12345000)", uut.u_rf.rf[4]);
        $display("Reg x5  : %h (Expected: 00001010)", uut.u_rf.rf[5]);
        
        // 檢查 Data Memory (假設裡面陣列叫 mem)
        $display("DMEM[0] : %d (Expected: 30)", uut.u_dmem.mem[0]);

        if (uut.u_rf.regs[3] == 30 && uut.u_dmem.mem[0] == 30)
            $display(">>> SUCCESS: CPU logic passed standard test! <<<");
        else
            $display(">>> ERROR: Value mismatch! Check your Decoder or MUX. <<<");

        $finish;
    end

    // 即時監控 PC
    always @(posedge clk) begin
        if (rst_n) begin
            $display("[Time %t] PC=%h | Instr=%h | x3=%d", $time, dbg_pc, dbg_instr, uut.u_rf.regs[3]);
        end
    end

endmodule