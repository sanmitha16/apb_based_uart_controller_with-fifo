`timescale 1ns/1ps

module tb_baud_generator;

    reg clk;
    reg rst;

    wire baud_tick;

    // Instantiate DUT
    baud_generator #(
        .CLK_FREQ(50000000),
        .BAUD_RATE(115200)
    ) uut (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    // Clock generation
    always #10 clk = ~clk;

    initial begin

        // GTKWave dump file
        $dumpfile("baud_generator.vcd");

        // Dump all variables
        $dumpvars(0, tb_baud_generator);

        // Initialize signals
        clk = 0;
        rst = 1;

        // Hold reset
        #50;
        rst = 0;

        // Run simulation
        #10000;

        $finish;
    end

endmodule
