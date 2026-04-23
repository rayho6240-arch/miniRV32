module top(
    input clk,
    input rst_n,
    // 調試用輸出
    output [31:0] dbg_pc,
    output [31:0] dbg_instr
);

    // --- 連接線定義 (全面 32-bit 化) ---
    wire [31:0] pc, next_pc, pc_plus_4;
    wire [31:0] instr;
    wire [31:0] rd1, rd2, wd, alu_out, dmem_out, imm;
    wire [4:0]  rs1, rs2, rd;
    wire [3:0]  alu_op;
    wire        RegWrite, ALUSrc, MemWrite, MemRead, MemtoReg, Branch, zero;

    // --- 1. PC 邏輯 (注意：RISC-V 標準是 PC + 4) ---
    assign pc_plus_4 = pc + 32'd4;
    // 這裡暫時不考慮 Branch 跳轉，先讓 PC 順著跑
    assign next_pc = (Branch && zero) ? (pc + imm) : pc_plus_4;

    PC u_pc(
        .clk(clk),
        .rst_n(rst_n),
        .next_pc(next_pc), // 修改 PC 模組以接收下一個地址
        .pc(pc)
    );

    // --- 2. 指令記憶體 (現在讀出 32-bit) ---
    IMEM u_imem(
        .addr(pc),
        .instr(instr)
    );

    // --- 3. 解碼器與立即數生成器 ---
    decoder_rv32 u_dec(
        .instr(instr),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .alu_op(alu_op),
        .RegWrite(RegWrite), .ALUSrc(ALUSrc),
        .MemWrite(MemWrite), .MemRead(MemRead),
        .MemtoReg(MemtoReg), .Branch(Branch)
    );

    ImmGen u_immgen(
        .instr(instr),
        .imm(imm)
    );

    // --- 4. 寄存器堆 (32x32) ---
    RegFile u_rf(
        .clk(clk),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .wd(wd),
        .RegWrite(RegWrite),
        .rd1(rd1), .rd2(rd2)
    );
    
    // 實例化 Data Memory
    data_mem u_dmem(
        .clk(clk),
        .mem_write(MemWrite),
        .mem_read(MemRead),
        .addr(alu_out),       // ALU 算出的地址 (例如：base + offset)
        .wd(rd2),             // 要存入的資料來自 rs2
        .rd(dmem_out)         // 讀出的資料送往回寫 MUX
    );


    // 回寫數據選擇 (MUX)
    // 如果是 Load 指令 (MemtoReg=1)，選 dmem_out；否則選 alu_out
    assign wd = (MemtoReg) ? dmem_out : alu_out;

    // --- 5. ALU 與 MUX ---
    wire [31:0] alu_b = (ALUSrc) ? imm : rd2;
    
    ALU_32 u_alu(
        .a(rd1),
        .b(alu_b),
        .alu_op(alu_op),
        .result(alu_out),
        .zero(zero)
    );



    // DEBUG
    assign dbg_pc = pc;
    assign dbg_instr = instr;

endmodule