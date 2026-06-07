module apb_uart_slave(

    input PCLK,
    input PRESET,

    input [7:0] PADDR,
    input [7:0] PWDATA,

    output reg [7:0] PRDATA,

    input PWRITE,
    input PSEL,
    input PENABLE,

    output PREADY,

    // -----------------------------------------
    // TX FIFO
    // -----------------------------------------

    output reg tx_wr_en,
    output reg [7:0] tx_wr_data,

    input tx_fifo_full,

    // -----------------------------------------
    // RX FIFO
    // -----------------------------------------

    output reg rx_rd_en,

    input [7:0] rx_rd_data,
    input rx_fifo_empty
);

    assign PREADY = 1'b1;

    // -----------------------------------------
    // READ DELAY FLAG
    // -----------------------------------------

    reg read_pending;

    always @(posedge PCLK or posedge PRESET) begin

        if(PRESET) begin

            PRDATA <= 8'h00;

            tx_wr_en <= 0;
            tx_wr_data <= 0;

            rx_rd_en <= 0;

            read_pending <= 0;
        end

        else begin

            tx_wr_en <= 0;
            rx_rd_en <= 0;

            // =====================================
            // WRITE
            // =====================================

            if(PSEL && PENABLE && PWRITE) begin

                if(PADDR == 8'h00) begin

                    if(!tx_fifo_full) begin

                        tx_wr_data <= PWDATA;

                        tx_wr_en <= 1;
                    end
                end
            end

            // =====================================
            // READ REQUEST
            // =====================================

            if(PSEL && PENABLE && !PWRITE) begin

                if(PADDR == 8'h04) begin

                    if(!rx_fifo_empty) begin

                        rx_rd_en <= 1;

                        read_pending <= 1;
                    end
                end
            end

            // =====================================
            // CAPTURE FIFO DATA NEXT CLOCK
            // =====================================

            if(read_pending) begin

                PRDATA <= rx_rd_data;

                read_pending <= 0;
            end
        end
    end

endmodule
