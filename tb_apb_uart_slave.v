`timescale 1ns/1ps

module tb_apb_uart_slave;

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
    // FIFO INTERFACE SIGNALS
    // -------------------------------------------------

    wire tx_wr_en;
    wire [7:0] tx_wr_data;

    reg tx_fifo_full;

    wire rx_rd_en;

    reg [7:0] rx_rd_data;

    reg rx_fifo_empty;

    // -------------------------------------------------
    // DUT
    // -------------------------------------------------

    apb_uart_slave uut (

        .PCLK(PCLK),
        .PRESET(PRESET),

        .PADDR(PADDR),
        .PWDATA(PWDATA),

        .PRDATA(PRDATA),

        .PWRITE(PWRITE),
        .PSEL(PSEL),
        .PENABLE(PENABLE),

        .PREADY(PREADY),

        // TX FIFO
        .tx_wr_en(tx_wr_en),
        .tx_wr_data(tx_wr_data),
        .tx_fifo_full(tx_fifo_full),

        // RX FIFO
        .rx_rd_en(rx_rd_en),
        .rx_rd_data(rx_rd_data),
        .rx_fifo_empty(rx_fifo_empty)
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
        $dumpfile("apb_uart.vcd");
        $dumpvars(0, tb_apb_uart_slave);

        // Initialize
        PCLK = 0;
        PRESET = 1;

        PADDR = 0;
        PWDATA = 0;

        PWRITE = 0;
        PSEL = 0;
        PENABLE = 0;

        tx_fifo_full = 0;

        rx_rd_data = 8'hA5;
        rx_fifo_empty = 0;

        // -------------------------------------------------
        // RESET RELEASE
        // -------------------------------------------------

        #50;
        PRESET = 0;

        // =================================================
        // APB WRITE : TX FIFO
        // =================================================

        // SETUP PHASE
        #20;

        PADDR = 8'h00;

        PWDATA = 8'h3C;

        PWRITE = 1;

        PSEL = 1;

        PENABLE = 0;

        // ACCESS PHASE
        #20;

        PENABLE = 1;

        // END TRANSFER
        #20;

        PSEL = 0;
        PENABLE = 0;

        // =================================================
        // APB READ : RX FIFO
        // =================================================

        #40;

        // SETUP PHASE
        PADDR = 8'h04;

        PWRITE = 0;

        PSEL = 1;

        PENABLE = 0;

        // ACCESS PHASE
        #20;

        PENABLE = 1;

        // END TRANSFER
        #20;

        PSEL = 0;
        PENABLE = 0;

        // =================================================
        // APB READ : STATUS REGISTER
        // =================================================

        #40;

        // SETUP
        PADDR = 8'h08;

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
        #200;

        $finish;

    end

endmodule
