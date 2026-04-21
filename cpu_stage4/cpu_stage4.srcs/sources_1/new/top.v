`timescale 1ns / 1ps

module top(
    input clk,
    input rst_n,
    output [7:0] dbg_rs1,
    output [7:0] dbg_rs2,
    output [7:0] dbg_alu
);

    // --- Wire 定義 (V2.0 升級版) ---
    wire [7:0] rd1, rd2; 
    wire [7:0] alu_out;  
    wire [3:0] pc;
    
    wire [15:0] instr;       // 【修改】指令拓寬為 16-bit
    wire [2:0] rs1, rs2, rd; 
    wire [3:0] op;           // 【修改】Opcode 拓寬為 4-bit
    
    wire [7:0] dmem_out;
    wire RegWrite, MemtoReg, MemWrite, MemRead;
    wire zero;
    
    // --- 新增的 MUX 與立即數神經 ---
    wire ALUSrc;             // 控制 ALU B 端來源的訊號
    wire [5:0] imm;          // 從 Decoder 接收的 6-bit 立即數
    wire [7:0] imm_ext;      // 擴充成 8-bit 的立即數
    wire [7:0] alu_b_in;     // 最終送進 ALU B 端的資料

    wire [7:0] final_wd;  //wd: write data 
    assign final_wd = (MemtoReg) ? dmem_out : alu_out;
    
    // --- 立即數擴充 (Sign Extension) ---
    // 說明：把 6-bit 的最高位 (imm[5]) 複製兩次補在前面，湊成 8-bit，這叫做「符號擴充」，保留正負號。
    assign imm_ext = {{2{imm[5]}}, imm}; 

    // --- ALU B 端的軌道切換器 (MUX) ---
    // 說明：如果 ALUSrc 是 1，選 imm_ext；如果是 0，選 rd2
    assign alu_b_in = (ALUSrc) ? imm_ext : rd2;
    
    wire Branch;
    wire PCSrc;
    wire [3:0] target_pc;
    assign PCSrc = Branch & zero;
    assign target_pc = imm[3:0] ;  //邏輯運算中止條件默認是用ADDI 來執行, 資訊在立即數中
    

    // --- 模組實例化 ---
    
    PC pc_inst(
        .clk(clk),
        .rst_n(rst_n),
        .PCSrc(PCSrc),
        .target_pc(target_pc),
        .pc(pc)
    );
    
    IMEM imem_inst(
        .addr(pc),
        .instr(instr)
    );
    
    // 升級版 Decoder 接線
    decoder dec_inst(
        .instr(instr),
        .op(op),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm),           // 【新增接線】拉出 6-bit 立即數
        .RegWrite(RegWrite), 
        .MemtoReg(MemtoReg), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead),
        .ALUSrc(ALUSrc),      // 【新增接線】拉出 MUX 控制訊號
        .Branch(Branch)
    );
    
    RegFile rf(
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd1(rd1),
        .rd2(rd2),
        .RegWrite(RegWrite), // 改用 decoder 傳來的訊號
        .rd(rd),
        .wd(final_wd)        // 修改：改接 MUX 後的資料// from mem fetch(load) or push back alu result to memory 
    );


    // 升級版 ALU 接線 (乾淨俐落版)
    ALU_8 alu(
        .a(rd1),
        .b(alu_b_in),        
        .alu_op(op),         // 【恢復簡潔】直接把 Decoder 的 4-bit op 原封不動傳給 ALU
        .result(alu_out),
        .zero(zero)
    );

    
    // --- 修改點 2: 插入 Data Memory ---
    data_mem dmem(
        .clk(clk),
        .mem_write(MemWrite),
        .mem_read(MemRead),
        .addr(alu_out[3:0]), // 使用 ALU 的結果作為記憶體位址
        .wd(rd2),            // 要存入的 data 來自 RS2 (rd2)
        .rd(dmem_out)
    );

    // DEBUG OUTPUT
    assign dbg_rs1 = rd1;
    assign dbg_rs2 = rd2;
    assign dbg_alu = alu_out;

endmodule