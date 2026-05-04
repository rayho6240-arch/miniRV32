`default_nettype none  // 回復嚴格模式，確保合成器不亂猜線路

module top(
    input  wire        clk_create,    // PYNQ-Z2 原生 125MHz (或 50MHz) 震盪器輸入
    input  wire        rst_n,         // 主動低電平重置訊號
    input  wire [3:0]  btn,           // 實體按鈕 (btn[0] 可控小恐龍)
    
    // HDMI 物理引腳
    output wire [2:0]  hdmi_tx_p,
    output wire [2:0]  hdmi_tx_n,
    output wire        hdmi_tx_clk_p,
    output wire        hdmi_tx_clk_n,
    
    // Debug 輸出
    output wire [31:0] dbg_pc,
    output wire [31:0] dbg_instr
);

    // ============================================================
    // 1. 時鐘系統 (實例化 Clocking Wizard IP)
    // ============================================================
    // 將原本的 input 改為內部 wire，由這裡的 IP 負責發電
    wire clk_pix; 
    wire clk_pix_5x; 
    wire clk_cpu; 
    wire locked;

    clk_wiz_2 u_clk_gen (
        .clk_in1(clk_create), // 吃外部實體時脈
        .resetn(rst_n),       // IP 通常是高電平重置，這裡做反相
        .clk_out1(clk_cpu),   // 輸出給 CPU
        .clk_out2(clk_pix),   // 輸出給 VGA 掃描
        .clk_out3(clk_pix_5x),// 輸出給 HDMI TMDS
        .locked(locked)       // PLL 鎖定訊號
    );

    // ============================================================
    // 2. 按鈕同步 (防止亞穩態)
    // ============================================================
    reg [3:0] btn_sync_1, btn_sync_2;
    always @(posedge clk_cpu) begin
        btn_sync_1 <= btn;
        btn_sync_2 <= btn_sync_1;
    end

    // ============================================================
    // 3. CPU 內部訊號與連線
    // ============================================================
    wire [31:0] pc, next_pc, pc_plus_4;
    wire [31:0] instr, rd1, rd2, wd, alu_out, dmem_out, imm, raw_mem_out;
    wire [4:0]  rs1, rs2, rd;
    wire [3:0]  alu_op;
    wire        RegWrite, ALUSrc, MemWrite, MemRead, MemtoReg, Branch, zero;
    wire        Jump, Jalr;

    // PC 邏輯
    assign pc_plus_4 = pc + 32'd4;
    wire [31:0] jump_target = pc + imm;
    wire [31:0] jalr_target = (rd1 + imm) & 32'hFFFFFFFE;
    assign next_pc = (Jalr) ? jalr_target :
                     (Jump || (Branch && zero)) ? jump_target : 
                     pc_plus_4;

    PC u_pc(
        .clk(clk_cpu),
        .rst_n(rst_n && locked), // 確保 PLL 穩定後 CPU 才啟動
        .next_pc(next_pc),
        .pc(pc)
    );

    IMEM u_imem(
        .addr(pc),
        .instr(instr)
    );

    decoder_rv32 u_dec(
        .instr(instr),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .alu_op(alu_op),
        .RegWrite(RegWrite), .ALUSrc(ALUSrc),
        .MemWrite(MemWrite), .MemRead(MemRead),
        .MemtoReg(MemtoReg), .Branch(Branch),
        .Jump(Jump), .Jalr(Jalr)
    );

    ImmGen u_immgen(.instr(instr), .imm(imm));

    RegFile u_rf(
        .clk(clk_cpu),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .wd(wd),
        .RegWrite(RegWrite),
        .rd1(rd1), .rd2(rd2)
    );

    ALU_32 u_alu(
        .a(rd1), .b(ALUSrc ? imm : rd2),
        .alu_op(alu_op),
        .result(alu_out),
        .zero(zero)
    );

    // ============================================================
    // 4. 地址解碼 (MMIO 與 VRAM)
    // ============================================================
    wire is_mmio_btn = (alu_out == 32'h0000_8000);
    wire is_vram     = (alu_out >= 32'h0000_9000 && alu_out <= 32'h0000_9FFF);
    wire is_dmem     = (alu_out <  32'h0000_8000);

    // CPU 寫入資料 MUX (決定寫入 DMEM 還是 VRAM)
    data_mem u_dmem(
        .clk(clk_cpu),
        .mem_write(MemWrite && is_dmem),
        .mem_read(MemRead && is_dmem),
        .addr(alu_out),
        .wd(rd2),
        .rd(raw_mem_out)
    );

    // CPU 讀取資料 MUX
    wire [31:0] vram_cpu_out; // VRAM 給 CPU 的讀取值
    assign dmem_out = (is_mmio_btn) ? {28'b0, btn_sync_2} :
                      (is_vram)     ? vram_cpu_out : 
                                      raw_mem_out;

    // 回寫資料到暫存器
    assign wd = (Jump || Jalr) ? pc_plus_4 : 
                (MemtoReg)     ? dmem_out : 
                                 alu_out;

    // ============================================================
    // 5. VRAM 與 HDMI 顯示邏輯
    // ============================================================
    wire [11:0] pixel_addr_to_vram;
    wire [23:0] vram_pixel_rgb;
    wire [10:0] sx, sy;
    wire hsync, vsync, de;

    // VRAM 實例化
    vram u_vram (
        .clk_cpu(clk_cpu),
        .we(MemWrite && is_vram),
        .addr_cpu(alu_out[11:0]),
        .data_in(rd2),
        .clk_pixel(clk_pix),
        .addr_pixel(pixel_addr_to_vram),
        .data_out(vram_pixel_rgb)
        // ⚠️ 備註：如果你有實作 CPU 讀取 VRAM 的功能，記得把 vram_cpu_out 接出來
        // .data_out_cpu(vram_cpu_out) 
    );

    // 螢幕計時產生器 (640x480)
    display_timings #(
        .H_RES(640),
        .V_RES(480)
    ) u_timings (
        .i_pix_clk(clk_pix),
        .rst(!locked),
        .sx(sx),
        .sy(sy),
        .hsync(hsync),
        .vsync(vsync),
        .de(de)
    );

    // 映射邏輯：將螢幕座標對應到 VRAM 位址 (左上角 64x64)
    wire is_drawing_area = (sx < 64 && sy < 64);
    assign pixel_addr_to_vram = {sy[5:0], sx[5:0]};

    // 顏色混算：畫圖區顯示 VRAM，其餘背景深藍色
    wire [7:0] out_r = (de && is_drawing_area) ? vram_pixel_rgb[23:16] : 8'h00;
    wire [7:0] out_g = (de && is_drawing_area) ? vram_pixel_rgb[15:8]  : 8'h00;
    wire [7:0] out_b = (de && is_drawing_area) ? vram_pixel_rgb[7:0]   : (de ? 8'h33 : 8'h00);

    // HDMI 訊號產生
    dvi_generator u_hdmi_gen (
        .clk_pix(clk_pix),
        .clk_pix_5x(clk_pix_5x),
        .rst(!locked),
        .de(de),
        .data_r(out_r),
        .data_g(out_g),
        .data_b(out_b),
        .ctrl_hsync(hsync),
        .ctrl_vsync(vsync),
        .tmds_clk_p(hdmi_tx_clk_p),
        .tmds_clk_n(hdmi_tx_clk_n),
        .tmds_p(hdmi_tx_p),
        .tmds_n(hdmi_tx_n)
    );

    // Debug
    assign dbg_pc = pc;
    assign dbg_instr = instr;

endmodule