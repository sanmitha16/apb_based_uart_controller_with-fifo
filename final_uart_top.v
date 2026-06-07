module final_uart_soc_top(

    input PCLK,
    input PRESET,

    // APB Interface
    input [7:0] PADDR,
    input [7:0] PWDATA,

    output [7:0] PRDATA,

    input PWRITE,
    input PSEL,
    input PENABLE,

    output PREADY,

    // UART
    input rx,
    output tx
);

    // -------------------------------------------------
    // BAUD GENERATOR
    // -------------------------------------------------

    wire baud_tick;

    baud_generator baud_gen_inst(

        .clk(PCLK),
        .rst(PRESET),

        .baud_tick(baud_tick)
    );

    // -------------------------------------------------
    // APB <-> TX FIFO
    // -------------------------------------------------

    wire tx_wr_en;

    wire [7:0] tx_wr_data;

    wire tx_fifo_full;
    wire tx_fifo_empty;

    wire [7:0] tx_fifo_rd_data;

    reg tx_fifo_rd_en;

    // -------------------------------------------------
    // RX FIFO SIGNALS
    // -------------------------------------------------

    wire rx_fifo_empty;
    wire rx_fifo_full;

    wire [7:0] rx_fifo_rd_data;

    reg rx_fifo_wr_en;

    wire rx_rd_en;

    reg [7:0] rx_data_reg;

    // -------------------------------------------------
    // UART TX SIGNALS
    // -------------------------------------------------

    reg tx_start;

    reg [7:0] tx_data;

    wire tx_busy;

    // -------------------------------------------------
    // UART RX SIGNALS
    // -------------------------------------------------

    wire [7:0] rx_data;

    wire rx_done;

    // -------------------------------------------------
    // APB SLAVE
    // -------------------------------------------------

    apb_uart_slave apb_inst(

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
        .rx_fifo_empty(rx_fifo_empty),
        .rx_rd_data(rx_fifo_rd_data),
        .rx_rd_en(rx_rd_en)
    );

    // -------------------------------------------------
    // TX FIFO
    // -------------------------------------------------

    fifo tx_fifo(

        .clk(PCLK),
        .rst(PRESET),

        .wr_en(tx_wr_en),
        .rd_en(tx_fifo_rd_en),

        .wr_data(tx_wr_data),

        .rd_data(tx_fifo_rd_data),

        .full(tx_fifo_full),
        .empty(tx_fifo_empty)
    );

    // -------------------------------------------------
    // RX FIFO
    // -------------------------------------------------

    fifo rx_fifo(

        .clk(PCLK),
        .rst(PRESET),

        .wr_en(rx_fifo_wr_en),
        .rd_en(rx_rd_en),

        .wr_data(rx_data_reg),

        .rd_data(rx_fifo_rd_data),

        .full(rx_fifo_full),
        .empty(rx_fifo_empty)
    );

    // -------------------------------------------------
    // UART TX
    // -------------------------------------------------

    uart_tx uart_tx_inst(

        .clk(PCLK),
        .rst(PRESET),

        .baud_tick(baud_tick),

        .tx_start(tx_start),
        .tx_data(tx_data),

        .tx(tx),
        .tx_busy(tx_busy)
    );

    // -------------------------------------------------
    // UART RX
    // -------------------------------------------------

    uart_rx uart_rx_inst(

        .clk(PCLK),
        .rst(PRESET),

        .baud_tick(baud_tick),

        .rx(rx),

        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // -------------------------------------------------
    // TX CONTROL FSM
    // -------------------------------------------------

    parameter IDLE      = 3'd0;
    parameter READ_FIFO = 3'd1;
    parameter LOAD_TX   = 3'd2;
    parameter START_TX  = 3'd3;
    parameter WAIT_BUSY = 3'd4;

    reg [2:0] state;

    always @(posedge PCLK or posedge PRESET) begin

        if(PRESET) begin

            state <= IDLE;

            tx_fifo_rd_en <= 0;

            tx_start <= 0;

            tx_data <= 0;
        end

        else begin

            // DEFAULTS

            tx_fifo_rd_en <= 0;

            tx_start <= 0;

            case(state)

                // -------------------------------------------------
                // WAIT FOR FIFO DATA
                // -------------------------------------------------

                IDLE: begin

                    if(!tx_fifo_empty && !tx_busy) begin

                        tx_fifo_rd_en <= 1'b1;

                        state <= READ_FIFO;
                    end
                end

                // -------------------------------------------------
                // WAIT 1 CLOCK FOR FIFO OUTPUT
                // -------------------------------------------------

                READ_FIFO: begin

                    state <= LOAD_TX;
                end

                // -------------------------------------------------
                // LOAD FIFO DATA
                // -------------------------------------------------

                LOAD_TX: begin

                    tx_data <= tx_fifo_rd_data;

                    state <= START_TX;
                end

                // -------------------------------------------------
                // START UART TX
                // -------------------------------------------------

                START_TX: begin

                    tx_start <= 1'b1;

                    state <= WAIT_BUSY;
                end

                // -------------------------------------------------
                // WAIT FOR TX COMPLETE
                // -------------------------------------------------

                WAIT_BUSY: begin

                    if(!tx_busy) begin

                        state <= IDLE;
                    end
                end

            endcase
        end
    end

    // -------------------------------------------------
    // RX FIFO WRITE
    // -------------------------------------------------

    always @(posedge PCLK or posedge PRESET) begin

        if(PRESET) begin

            rx_fifo_wr_en <= 0;

            rx_data_reg <= 8'b0;
        end

        else begin

            rx_fifo_wr_en <= 0;

            if(rx_done) begin

                rx_data_reg <= rx_data;

                rx_fifo_wr_en <= 1'b1;
            end
        end
    end

endmodule
