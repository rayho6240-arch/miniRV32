module top(
    //input clk,              // 系統主時鐘 (125MHz -> 需接 PLL)
    //input clk_25M,          // 由 PLL 產生的 25MHz 像素時鐘
    input wire  clk_in125,        // 修改：接開發板的 125MHz 腳位
    input wire rst_n,
    input wire btn,
    // 實體顯示輸出
    output wire       TMDS_clk_p,
    output wire       TMDS_clk_n,
    output wire [2:0] TMDS_data_p,
    output wire [2:0] TMDS_data_n,
    // 調試用
    output wire [31:0] dbg_pc,
    output wire [31:0] dbg_instr
);


    // --- 定義內部時鐘線路 ---
    wire clk_25M;  // 像素時鐘
    wire clk_125M; // HDMI 序列時鐘
    wire locked;   // PLL 穩定訊號 (選接)

    clk_wiz_0 u_pll (
        .clk_in1(clk_in125), // 接板子腳位
        .resetn(rst_n),      // 接重置按鈕
        .clk_out1(clk_25M),  // 給 VGA 和 CPU
        .clk_out2(clk_125M), // 給 dvi_generator
        .locked(locked)
    );
    
    wire clk; // 定義 CPU 使用的時鐘
    assign clk = clk_25M;
    
    
    
    
    
    // 定義內部用的同步訊號線 (承接 vga_timing 的輸出)
    wire vga_hsync, vga_vsync;
    wire [23:0] rgb_out_final; 

    // 這裡是原本 assign HDMI_RGB 的邏輯，改賦值給內部線路
    assign rgb_out_final = (vga_active && pixel_data) ? 24'hFFFFFF : 24'h000000;

    dvi_generator u_hdmi (
        .clk_pix(clk_25M),      
        .clk_pix_5x(clk_125M),  
        .rst(!locked),           // 建議用 PLL 的 locked 訊號取反作為重置
        .de(vga_active),        
        .data_r(rgb_out_final[23:16]),
        .data_g(rgb_out_final[15:8]), 
        .data_b(rgb_out_final[7:0]),  
        .ctrl_hsync(vga_hsync),  // 確保這裡名稱與下方 u_vga 的輸出對應
        .ctrl_vsync(vga_vsync),  // 確保這裡名稱與下方 u_vga 的輸出對應
        .tmds_clk_p(TMDS_clk_p),
        .tmds_clk_n(TMDS_clk_n),
        .tmds_data_p(TMDS_data_p),
        .tmds_data_n(TMDS_data_n)
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
        .hsync(vga_hsync), // 修改：名稱改為內部線路 vga_hsync
        .vsync(vga_vsync)  // 修改：名稱改為內部線路 vga_vsync
    );

    wire [16:0] vram_read_addr = (vga_y[9:1] * 320) + vga_x[9:1];
    reg pixel_data;
    always @(posedge clk_25M) pixel_data <= vram[vram_read_addr];
    wire [23:0] HDMI_RGB;
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
    wire [31:0] alu_b;   
    ALU_32 u_alu(.a(rd1), .b(alu_b), .alu_op(alu_op), .result(alu_out), .zero(zero));

    assign dbg_pc = pc;
    assign dbg_instr = instr;

endmodule