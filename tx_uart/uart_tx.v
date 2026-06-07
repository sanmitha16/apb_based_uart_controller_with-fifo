module uart_tx(

    input clk,
    input rst,

    input baud_tick,

    input tx_start,
    input [7:0] tx_data,

    output reg tx,
    output reg tx_busy
);

    // -------------------------------------------------
    // STATES
    // -------------------------------------------------

    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter STOP  = 2'b11;

    reg [1:0] state;

    // -------------------------------------------------
    // INTERNALS
    // -------------------------------------------------

    reg [7:0] data_reg;

    reg [2:0] bit_index;

    // -------------------------------------------------
    // UART TX FSM
    // -------------------------------------------------

    always @(posedge clk or posedge rst) begin

        if(rst) begin

            state <= IDLE;

            tx <= 1'b1;

            tx_busy <= 1'b0;

            data_reg <= 8'b0;

            bit_index <= 3'b0;
        end

        else begin

            case(state)

                // -------------------------------------------------
                // IDLE
                // -------------------------------------------------

                IDLE: begin

                    tx <= 1'b1;

                    tx_busy <= 1'b0;

                    if(tx_start) begin

                        data_reg <= tx_data;

                        bit_index <= 3'd0;

                        tx_busy <= 1'b1;

                        state <= START;
                    end
                end

                // -------------------------------------------------
                // START BIT
                // -------------------------------------------------

                START: begin

                    if(baud_tick) begin

                        tx <= 1'b0;

                        state <= DATA;
                    end
                end

                // -------------------------------------------------
                // DATA BITS
                // -------------------------------------------------

                DATA: begin

                    if(baud_tick) begin

                        tx <= data_reg[bit_index];

                        if(bit_index == 3'd7) begin

                            state <= STOP;
                        end

                        else begin

                            bit_index <= bit_index + 1'b1;
                        end
                    end
                end

                // -------------------------------------------------
                // STOP BIT
                // -------------------------------------------------

                STOP: begin

                    if(baud_tick) begin

                        tx <= 1'b1;

                        tx_busy <= 1'b0;

                        state <= IDLE;
                    end
                end

            endcase
        end
    end

endmodule
