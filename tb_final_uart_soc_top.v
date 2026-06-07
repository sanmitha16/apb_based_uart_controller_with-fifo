`timescale 1ns/1ps

module tb_final_uart_soc_top;

    // -------------------------------------------------
    // APB SIGNALS
    // -------------------------------------------------

    reg PCLK;
    reg PRESET;

    reg [7:0] PADDR;
    reg [7:0] PWDATA;

    wire [7:0] PRDATA;

    reg PWRITE;
    reg PSEL;
    reg PENABLE;

    wire PREADY;

    // -------------------------------------------------
    // UART LOOPBACK
    // -------------------------------------------------

    wire tx;
    wire rx;

    assign rx = tx;

    // -------------------------------------------------
    // DUT
    // -------------------------------------------------

    final_uart_soc_top uut (

        .PCLK(PCLK),
        .PRESET(PRESET),

        .PADDR(PADDR),
        .PWDATA(PWDATA),

        .PRDATA(PRDATA),

        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),

        .PREADY(PREADY),

        .rx(rx),
        .tx(tx)
    );

    // -------------------------------------------------
    // CLOCK
    // -------------------------------------------------

    always #10 PCLK = ~PCLK;

    // -------------------------------------------------
    // TEST SEQUENCE
    // -------------------------------------------------

    initial begin

        // GTKWave dump
        $dumpfile("final_uart_soc.vcd");
        $dumpvars(0, tb_final_uart_soc_top);

        // Initialize
        PCLK = 0;
        PRESET = 1;

        PADDR = 0;
        PWDATA = 0;

        PWRITE = 0;
        PSEL = 0;
        PENABLE = 0;

        // -------------------------------------------------
        // RESET RELEASE
        // -------------------------------------------------

        #100;
        PRESET = 0;

        // =================================================
        // APB WRITE → TX FIFO
        // =================================================

        #40;

        // SETUP
        PADDR = 8'h00;

        PWDATA = 8'h3C;

        PWRITE = 1;

        PSEL = 1;

        PENABLE = 0;

        // ACCESS
        #20;
        PENABLE = 1;

        // END
        #20;

        PSEL = 0;
        PENABLE = 0;

        // =================================================
        // WAIT FOR UART LOOPBACK
        // =================================================

        #250000;

        // =================================================
        // APB READ ← RX FIFO
        // =================================================

        // SETUP
        PADDR = 8'h04;

        PWRITE = 0;

        PSEL = 1;

        PENABLE = 0;

        // ACCESS
        #20;
        PENABLE = 1;

        // END
        #20;

        PSEL = 0;
        PENABLE = 0;

        // Finish
        #2000;

        $finish;

    end

endmodule
