module top(
    input  wire        clk_in125,     // 外部 125MHz 時鐘輸入
    input  wire        rst_n,         // 全局非同步重置 (Active Low)
    input  wire        btn,           // 按鈕輸入 (MMIO)
    // HDMI 差分輸出
    output wire        TMDS_clk_p,  TMDS_clk_n,
    output wire [2:0]  TMDS_data_p, TMDS_data_n,
    // Debug 訊號
    output wire [31:0] dbg_pc,
    output wire [31:0] dbg_instr
);

    // =========================================================================
    // 1. 時鐘系統 (Clock System)
    // =========================================================================
    wire clk_25M;   // 像素時鐘 (640x480 @ 60Hz)
    wire clk_125M;  // HDMI 序列化時鐘 (5x clk_25M)
    wire locked;    // PLL 穩定信號
    wire clk;       // CPU 主頻時鐘

    clk_wiz_0 u_pll (
        .clk_in1(clk_in125), 
        .resetn(rst_n),      
        .clk_out1(clk_25M),
        .clk_out2(clk_125M),
        .locked(locked)      
    );

    assign clk = clk_25M; // CPU 與像素時鐘同步

    // =========================================================================
    // 2. RISC-V CPU 核心模組
    // =========================================================================
    // --- 指令與資料連線 ---
    wire [31:0] pc, next_pc, pc_plus_4;
    wire [31:0] instr;
    wire [31:0] rd1, rd2, wd, alu_out, dmem_out, imm;
    wire [4:0]  rs1, rs2, rd;
    wire [3:0]  alu_op;
    wire        RegWrite, ALUSrc, MemWrite, MemRead, MemtoReg, Branch, zero;
    wire        Jump, Jalr, Lui, Aui;

    // --- 分支與跳轉邏輯 ---
    wire [31:0] jump_target = pc + imm;
    wire [31:0] jalr_target = (rd1 + imm) & 32'hFFFFFFFE;
    assign pc_plus_4 = pc + 4;

    wire [2:0] funct3 = instr[14:12];
    wire take_branch = (funct3 == 3'b000) ? zero :           // BEQ
                       (funct3 == 3'b001) ? !zero :          // BNE
                       (funct3 == 3'b100) ? alu_out[0] :     // BLT
                       (funct3 == 3'b101) ? !alu_out[0] :    // BGE
                       1'b0;

    assign next_pc = (Jalr) ? jalr_target : 
                     (Jump || (Branch && take_branch)) ? jump_target : 
                     pc_plus_4;

    // --- CPU 子模組實例化 ---
    PC u_pc(.clk(clk), .rst_n(rst_n), .next_pc(next_pc), .pc(pc));
    IMEM u_imem(.addr(pc), .instr(instr));

    decoder_rv32 u_dec(
        .instr(instr), .rs1(rs1), .rs2(rs2), .rd(rd), .alu_op(alu_op),
        .RegWrite(RegWrite), .ALUSrc(ALUSrc), .MemWrite(MemWrite), .MemRead(MemRead),
        .MemtoReg(MemtoReg), .Branch(Branch), .Jump(Jump), .Jalr(Jalr), .Lui(Lui), .Aui(Aui)
    );

    ImmGen u_immgen(.instr(instr), .imm(imm));
    RegFile u_rf(.clk(clk), .rs1(rs1), .rs2(rs2), .rd(rd), .wd(wd), .RegWrite(RegWrite), .rd1(rd1), .rd2(rd2));
    
    // ALU 與來源選擇
    wire [31:0] alu_b = (ALUSrc) ? imm : rd2; 
    ALU_32 u_alu(.a(rd1), .b(alu_b), .alu_op(alu_op), .result(alu_out), .zero(zero));

    // Data Memory 與 MMIO (周邊輸入)
    data_mem u_dmem(.clk(clk), .mem_write(MemWrite), .mem_read(MemRead), .addr(alu_out), .wd(rd2), .rd(dmem_out));
    wire [31:0] io_read_data = (alu_out == 32'h4000_0000) ? {31'b0, btn} : dmem_out;

    // 寫回暫存器 (Write-back)
    assign wd = (Jump || Jalr) ? pc_plus_4 : 
                (Lui)          ? imm : 
                (Aui)          ? jump_target : 
                (MemtoReg)     ? io_read_data : alu_out;

    // =========================================================================
    // 3. 顯示子系統 (VRAM & VGA Timing)
    // =========================================================================
    (* ram_style = "block" *) reg [0:0] vram [0:76799]; // 320x240 解析度
    wire is_vram = (alu_out[31:20] == 12'h500); // 映射位址 0x500xxxxx
    
    // CPU 寫入 VRAM
    always @(posedge clk) begin
        if (MemWrite && is_vram)
            vram[alu_out[16:0]] <= rd2[0]; 
    end

    // VGA 時序產生
    wire [9:0] vga_x, vga_y;
    wire vga_active, vga_hsync, vga_vsync;
    vga_timing u_vga (
        .clk_25M(clk_25M), .rst_n(rst_n),
        .curr_x(vga_x), .curr_y(vga_y), .active_video(vga_active),
        .hsync(vga_hsync), .vsync(vga_vsync)
    );

    // 像素讀取與色彩生成
    wire [16:0] vram_read_addr = (vga_y[9:1] * 320) + vga_x[9:1];
    reg pixel_data; // 必須宣告為 reg 以配合時序讀取
    always @(posedge clk_25M) begin
        pixel_data <= vram[vram_read_addr];
    end

    wire [23:0] rgb_out_final = (vga_active && pixel_data) ? 24'hFFFFFF : 24'h000000;
    
    
    //~~~~~~~~~~~~~~~~~~~~
    // --- 可以註解原本的 VRAM 讀取邏輯 ---
        //PLL (u_pll)：運作正常，時鐘頻率正確。
        //VGA 時序 (u_vga)：vga_active, hsync, vsync 邏輯正確，螢幕才能鎖定訊號。
        //HDMI 轉換 (u_hdmi & OBUFDS)：差分對接線正確，訊號成功送出。
    // reg pixel_data;
    // always @(posedge clk_25M) pixel_data <= vram[vram_read_addr];
    // assign rgb_out_final = (vga_active && pixel_data) ? 24'hFFFFFF : 24'h000000;

    // --- 換成測試用彩條邏輯 ---
    //assign rgb_out_final = vga_active ? {vga_x[7:0], vga_y[7:0], 8'hFF} : 24'h000000;
    //~~~~~~~~~~~~~~~~~~~~~~~~
    
    

    // =========================================================================
    // 4. HDMI 輸出處理 (HDMI Generator & OBUFDS)
    // =========================================================================
    wire tmds_ch0_s, tmds_ch1_s, tmds_ch2_s, tmds_chc_s;

    dvi_generator u_hdmi (
        .i_pix_clk      (clk_25M),      
        .i_pix_clk_5x   (clk_125M),     
        .i_rst          (!locked),      // 時鐘鎖定前保持重置
        .i_de           (vga_active),   
        .i_data_ch0     (rgb_out_final[7:0]),   // Blue
        .i_data_ch1     (rgb_out_final[15:8]),  // Green
        .i_data_ch2     (rgb_out_final[23:16]), // Red
        .i_ctrl_ch0     ({vga_vsync, vga_hsync}), // Ch0 同步信號
        .i_ctrl_ch1     (2'b00), .i_ctrl_ch2 (2'b00),
        .o_tmds_ch0_serial (tmds_ch0_s),
        .o_tmds_ch1_serial (tmds_ch1_s),
        .o_tmds_ch2_serial (tmds_ch2_s),
        .o_tmds_chc_serial (tmds_chc_s)
    );

    // 單端轉差分 (Xilinx Primitives)
    OBUFDS u_buf_c (.I(tmds_chc_s), .O(TMDS_clk_p),  .OB(TMDS_clk_n));
    OBUFDS u_buf_0 (.I(tmds_ch0_s), .O(TMDS_data_p[0]), .OB(TMDS_data_n[0]));
    OBUFDS u_buf_1 (.I(tmds_ch1_s), .O(TMDS_data_p[1]), .OB(TMDS_data_n[1]));
    OBUFDS u_buf_2 (.I(tmds_ch2_s), .O(TMDS_data_p[2]), .OB(TMDS_data_n[2]));

    // =========================================================================
    // 5. Debug 輸出
    // =========================================================================
    assign dbg_pc = pc;
    assign dbg_instr = instr;

endmodule