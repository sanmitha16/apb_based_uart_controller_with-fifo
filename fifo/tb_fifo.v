`timescale 1ns/1ps

module tb_fifo;

    reg clk;
    reg rst;

    reg wr_en;
    reg rd_en;

    reg [7:0] wr_data;

    wire [7:0] rd_data;

    wire full;
    wire empty;

    fifo uut (

        .clk(clk),
        .rst(rst),

        .wr_en(wr_en),
        .rd_en(rd_en),

        .wr_data(wr_data),

        .rd_data(rd_data),

        .full(full),
        .empty(empty)
    );

    // Clock
    always #10 clk = ~clk;

    initial begin

        // GTKWave
        $dumpfile("fifo.vcd");
        $dumpvars(0, tb_fifo);

        clk = 0;
        rst = 1;

        wr_en = 0;
        rd_en = 0;

        wr_data = 0;

        #50;
        rst = 0;

        // ---------------- WRITE DATA ----------------

        #20;
        wr_en = 1;
        wr_data = 8'hA1;

        #20;
        wr_data = 8'hB2;

        #20;
        wr_data = 8'hC3;

        #20;
        wr_en = 0;

        // ---------------- READ DATA ----------------

        #40;
        rd_en = 1;

        #60;
        rd_en = 0;

        #100;

        $finish;
    end

endmodule
