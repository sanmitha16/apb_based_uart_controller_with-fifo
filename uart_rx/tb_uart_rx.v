`timescale 1ns/1ps

module tb_uart_rx;

    reg clk;
    reg rst;

    reg baud_tick;

    reg rx;

    wire [7:0] rx_data;
    wire rx_done;

    uart_rx uut (

        .clk(clk),
        .rst(rst),

        .baud_tick(baud_tick),

        .rx(rx),

        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // Clock generation
    always #10 clk = ~clk;

    // Baud tick generation
    always begin
        #200;
        baud_tick = 1;
        #20;
        baud_tick = 0;
    end

    initial begin

        // GTKWave
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);

        clk = 0;
        rst = 1;

        baud_tick = 0;

        rx = 1;

        #50;
        rst = 0;

        // ---------------- SEND UART FRAME ----------------

        // START BIT
        #180;
        rx = 0;

        // DATA BITS (LSB FIRST)
        #220 rx = 0;
        #220 rx = 1;
        #220 rx = 0;
        #220 rx = 0;
        #220 rx = 1;
        #220 rx = 1;
        #220 rx = 0;
        #220 rx = 1;

        // STOP BIT
        #220 rx = 1;

        // Wait
        #1000;

        $finish;
    end

endmodule
