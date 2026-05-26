`timescale 1ns / 1ps

module top(
    input clk,
    input rst_n,
    output [7:0] dbg_rs1,
    output [7:0] dbg_rs2,
    output [7:0] dbg_alu
);

    // --- Wire 定義 ---
    wire [7:0] rd1, rd2; //read data
    wire [7:0] alu_out;  
    wire [3:0] pc;
    wire [10:0] instr;   //data: instruction
    wire [2:0] rs1, rs2, rd; //readsource(address) //rd is the destination(addess)
    wire [1:0] op;  //00,01,10,11
    
    // Data Memory 讀出的資料
    wire [7:0] dmem_out;
    
    // 新增：控制訊號 (應由 decoder 產生)
    wire RegWrite;    // 決定是否寫回暫存器 (sw 指令時為 0)
    wire MemtoReg;    // 0: 寫回 ALU 結果, 1: 寫回 Memory 資料
    wire MemWrite;    // 1: 執行 sw 指令
    wire MemRead;     // 1: 執行 lw 指令

    // --- 修改點 1: 寫回暫存器的資料選擇 (MUX) ---
    wire [7:0] final_wd;
    assign final_wd = (MemtoReg) ? dmem_out : alu_out; 
    //data instead of control //以此wire 存著這個data


    // --- 模組實例化 ---
    
    PC pc_inst(
        .clk(clk),
        .rst_n(rst_n),
        .pc(pc)
    );
    
    IMEM imem_inst(
        .addr(pc),
        .instr(instr)
    );
    
    // 注意：你的 decoder 需要擴充輸出這些控制訊號
    decoder dec_inst(
        .instr(instr),
        .op(op),   //control siginal
        .rs1(rs1),
        .rs2(rs2),//resource
        .rd(rd), //destination
        .RegWrite(RegWrite), // 新增 control signal Output
        .MemtoReg(MemtoReg), // 新增
        .MemWrite(MemWrite), // 新增
        .MemRead(MemRead)    // 新增
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


    wire zero;
    ALU_8 alu(
        .a(rd1),
        .b(rd2),
        .alu_op(op),
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