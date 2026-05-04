module IMEM(
    input wire [31:0] addr,    
    output wire [31:0] instr    
);

    reg [31:0] rom [0:255];
    integer i;

    initial begin
        // 強制初始化為 NOP
        for (i = 0; i < 256; i = i + 1) rom[i] = 32'h00000013; 
        

        $readmemh("D:\Programing\VerilogProject\miniRV32\cpu_stage6_vga\instr.hex", rom);
    end

    assign instr = rom[addr[31:2]];

endmodule