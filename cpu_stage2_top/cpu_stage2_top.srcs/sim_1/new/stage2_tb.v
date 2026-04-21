`timescale 1ns / 1ps

module stage2_tb;

    // =========================
    // clock
    // =========================
    reg clk = 0;
    always #5 clk = ~clk;  // 100MHz

    // =========================
    // DUT
    // =========================
    wire [7:0] dbg_rs1;
    wire [7:0] dbg_rs2;
    wire [7:0] dbg_alu;

    top uut (
        .clk(clk),
        .dbg_rs1(dbg_rs1),
        .dbg_rs2(dbg_rs2),
        .dbg_alu(dbg_alu)
    );

    // =========================
    // dump waveform
    // =========================
    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, top_tb);
    end

    // =========================
    // debug monitor
    // =========================
    initial begin
        $display("time | pc | rs1_data rs2_data alu_out");
        $display("----------------------------------------");

        $monitor("%4t | %h | %h %h %h",
            $time,
            uut.pc,
            dbg_rs1,
            dbg_rs2,
            dbg_alu
        );
    end

    // =========================
    // run control
    // =========================
    initial begin
        #200;

        $display("Final simulation done");
        $finish;
    end

endmodule