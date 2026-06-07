`timescale 1ns/1ps

module tb_uart_tx;

    reg clk;
    reg rst;

    reg baud_tick;

    reg tx_start;
    reg [7:0] tx_data;

    wire tx;
    wire tx_busy;

    uart_tx uut (

        .clk(clk),
        .rst(rst),

        .baud_tick(baud_tick),

        .tx_start(tx_start),
        .tx_data(tx_data),

        .tx(tx),
        .tx_busy(tx_busy)
    );

    // Clock generation
    always #10 clk = ~clk;

    // Fake baud tick generation
    always begin
        #200;
        baud_tick = 1;
        #20;
        baud_tick = 0;
    end

    initial begin

        // GTKWave
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);

        clk = 0;
        rst = 1;

        baud_tick = 0;

        tx_start = 0;
        tx_data = 8'b10110010;

        #50;
        rst = 0;

        // Start transmission
        #100;

        tx_start = 1;

        #20;
        tx_start = 0;

        // Run simulation
        #5000;

        $finish;
    end

endmodule
