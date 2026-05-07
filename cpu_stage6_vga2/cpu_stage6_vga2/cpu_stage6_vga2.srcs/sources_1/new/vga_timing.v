module vga_timing(
    input wire clk_25M,       // 25.175 MHz 或 25 MHz
    input wire rst_n,
    output reg [9:0] curr_x,
    output reg [9:0] curr_y,
    output wire hsync, vsync, active_video
);
    // 640x480 標準時序
    parameter H_ACTIVE = 640, H_FP = 16, H_SYNC = 96, H_BP = 48, H_TOTAL = 800;
    parameter V_ACTIVE = 480, V_FP = 10, V_SYNC = 2, V_BP = 33, V_TOTAL = 525;

    reg [9:0] h_cnt, v_cnt;

    always @(posedge clk_25M or negedge rst_n) begin
        if (!rst_n) begin h_cnt <= 0; v_cnt <= 0; end
        else begin
            if (h_cnt == H_TOTAL - 1) begin
                h_cnt <= 0;
                v_cnt <= (v_cnt == V_TOTAL - 1) ? 0 : v_cnt + 1;
            end else h_cnt <= h_cnt + 1;
        end
    end

    assign hsync = ~(h_cnt >= (H_ACTIVE + H_FP) && h_cnt < (H_ACTIVE + H_FP + H_SYNC));
    assign vsync = ~(v_cnt >= (V_ACTIVE + V_FP) && v_cnt < (V_ACTIVE + V_FP + V_SYNC));
    assign active_video = (h_cnt < H_ACTIVE) && (v_cnt < V_ACTIVE);
    
    always @(*) begin curr_x = h_cnt; curr_y = v_cnt; end
endmodule