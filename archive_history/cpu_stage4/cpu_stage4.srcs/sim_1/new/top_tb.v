`timescale 1ns / 1ps

module top_tb;
    reg clk;
    reg rst_n;
    wire [7:0] dbg_rs1, dbg_rs2, dbg_alu;

    // Instantiate the upgraded CPU body (uut = Unit Under Test)
    top uut (
        .clk(clk),
        .rst_n(rst_n),
        .dbg_rs1(dbg_rs1),
        .dbg_rs2(dbg_rs2),
        .dbg_alu(dbg_alu)
    );

    // Generate clock heartbeat (10ns period)
    always #5 clk = ~clk;
    
    

    initial begin
        // --- Power up and System Reset ---
        clk = 0;
        rst_n = 0;
        
        #12 rst_n = 1; // Release reset at 12ns, PC starts from 0

        // 【新增】等 1ns 讓訊號穩定，先拍下 PC:0 的瞬間
        #1; 
        $display("Time:%0t | PC:%d | Instr:%b", $time, uut.pc, uut.instr);
        $display("         | ALU_Out:%d | Final_WD:%d", uut.alu_out, uut.final_wd);
        $display("---------------------------------------------------------");


        
        $display("=========================================================");
        $display("  Start Simulation");
        $display("=========================================================");

        // --- Auto-Observation Logic ---
        // repeat(3) means we observe for 4 clock cycles, enough for our 3 instructions
        repeat(10) begin
            @(negedge clk); // Snapshot at the falling edge of the clock (data is stable)
            
            $display("Time:%0t | PC:%d | Instr:%b", $time, uut.pc, uut.instr);
            $display("         | ALU_Out:%d | Final_WD:%d", uut.alu_out, uut.final_wd);
            $display("---------------------------------------------------------");
        end
        
        #20;
        $display("Done Simulation");
        $finish;
    end

endmodule