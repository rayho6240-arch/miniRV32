module top(
    //input clk,              // 系統主時鐘 (125MHz -> 需接 PLL)
    //input clk_25M,          // 由 PLL 產生的 25MHz 像素時鐘
    input clk_in125,        // 修改：接開發板的 125MHz 腳位
    input rst_n,
    input btn,
    // 實體顯示輸出
    output HDMI_HSYNC,
    output HDMI_VSYNC,
    output [23:0] HDMI_RGB,
    // 調試用
    output [31:0] dbg_pc,
    output [31:0] dbg_instr
);


    // --- 定義內部時鐘線路 ---
    wire clk;      // CPU 用的 25MHz
    wire clk_25M;  // HDMI/VGA 用的 25.175MHz

    // --- 實例化 PLL IP ---
    // 這邊的名稱必須跟你產生的 IP 名稱一致 (通常是 clk_wiz_0)
    clk_wiz_0 u_pll (
        .clk_in1(clk_in125),   // 原始輸入
        .clk_out1(clk),        // 輸出 25M 給 CPU
        .clk_out2(clk_25M)     // 輸出 25.175M 給 VGA/HDMI
        // 如果你有勾選 reset，這裡要接 .reset(~rst_n)
    );








    // --- 連接線定義 (維持原樣) ---
    wire [31:0] pc, next_pc, pc_plus_4;
    wire [31:0] instr;
    wire [31:0] rd1, rd2, wd, alu_out, dmem_out, imm;
    wire [4:0]  rs1, rs2, rd;
    wire [3:0]  alu_op;
    wire        RegWrite, ALUSrc, MemWrite, MemRead, MemtoReg, Branch, zero;
    wire Jump, Jalr, Lui, Aui;
    wire [31:0] jump_target = pc + imm;
    wire [31:0] jalr_target = (rd1 + imm) & 32'hFFFFFFFE;

    // --- 1. MMIO 與寫回邏輯 ---
    wire [31:0] io_read_data = (alu_out == 32'h4000_0000) ? {31'b0, btn} : dmem_out;

    assign wd = (Jump || Jalr) ? pc_plus_4 : 
                (Lui)          ? imm : 
                (Aui)          ? jump_target : 
                (MemtoReg)     ? io_read_data : 
                                 alu_out;

    // --- 2. PC 與 Branch 邏輯 (維持原樣) ---
    wire [2:0] funct3 = instr[14:12];
    wire take_branch = (funct3 == 3'b000) ? zero :           // BEQ
                       (funct3 == 3'b001) ? !zero :          // BNE
                       (funct3 == 3'b100) ? alu_out[0] :     // BLT
                       (funct3 == 3'b101) ? !alu_out[0] :    // BGE
                       1'b0;

    assign next_pc = (Jalr) ? jalr_target : 
                     (Jump || (Branch && take_branch)) ? jump_target : 
                     pc_plus_4;

    // --- 3. 顯示子系統 (VRAM) ---
    (* ram_style = "block" *) reg [0:0] vram [0:76799]; // 320x240
    wire is_vram = (alu_out[31:20] == 12'h500);
    
    // CPU 寫入埠
    always @(posedge clk) begin
        if (MemWrite && is_vram)
            vram[alu_out[16:0]] <= rd2[0]; 
    end

    // HDMI 讀取掃描
    wire [9:0] vga_x, vga_y;
    wire vga_active;
    vga_timing u_vga (
        .clk_25M(clk_25M),
        .rst_n(rst_n),
        .curr_x(vga_x), .curr_y(vga_y),
        .active_video(vga_active),
        .hsync(HDMI_HSYNC), .vsync(HDMI_VSYNC)
    );

    wire [16:0] vram_read_addr = (vga_y[9:1] * 320) + vga_x[9:1];
    reg pixel_data;
    always @(posedge clk_25M) pixel_data <= vram[vram_read_addr];

    assign HDMI_RGB = (vga_active && pixel_data) ? 24'hFFFFFF : 24'h000000;

    // --- 4. 模組實例化 ---
    PC u_pc(.clk(clk), .rst_n(rst_n), .next_pc(next_pc), .pc(pc));
    IMEM u_imem(.addr(pc), .instr(instr));

    decoder_rv32 u_dec(
        .instr(instr),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .alu_op(alu_op),
        .RegWrite(RegWrite), .ALUSrc(ALUSrc),
        .MemWrite(MemWrite), .MemRead(MemRead),
        .MemtoReg(MemtoReg), .Branch(Branch),
        .Jump(Jump), .Jalr(Jalr), .Lui(Lui), .Aui(Aui) // <--- 補齊 Aui
    );

    ImmGen u_immgen(.instr(instr), .imm(imm));
    RegFile u_rf(.clk(clk), .rs1(rs1), .rs2(rs2), .rd(rd), .wd(wd), .RegWrite(RegWrite), .rd1(rd1), .rd2(rd2));
    data_mem u_dmem(.clk(clk), .mem_write(MemWrite), .mem_read(MemRead), .addr(alu_out), .wd(rd2), .rd(dmem_out));
    ALU_32 u_alu(.a(rd1), .b(alu_b), .alu_op(alu_op), .result(alu_out), .zero(zero));

    assign dbg_pc = pc;
    assign dbg_instr = instr;

endmodule