module data_mem(
    input wire clk,
    input wire mem_write,
    input wire mem_read,
    input wire [31:0] addr,
    input wire [31:0] wd,
    output wire [31:0] rd
);

    reg [31:0] ram [0:63];

    // 新增這段：初始化記憶體，消滅預設的 X 狀態！
    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1) begin
            ram[i] = 32'b0;
        end
    end

    always @(posedge clk) begin
        if (mem_write) begin
            ram[addr[31:2]] <= wd; 
        end
    end

    assign rd = (mem_read) ? ram[addr[31:2]] : 32'b0;

endmodule