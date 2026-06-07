module uart_rx(

    input clk,
    input rst,

    input baud_tick,
    input rx,

    output reg [7:0] rx_data,
    output reg rx_done
);

    // -------------------------------------------------
    // STATES
    // -------------------------------------------------

    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter STOP  = 2'b11;

    reg [1:0] state;

    reg [7:0] data_reg;

    reg [2:0] bit_index;

    reg sample_enable;

    // -------------------------------------------------
    // RX FSM
    // -------------------------------------------------

    always @(posedge clk or posedge rst) begin

        if(rst) begin

            state <= IDLE;

            rx_data <= 0;

            rx_done <= 0;

            data_reg <= 0;

            bit_index <= 0;

            sample_enable <= 0;
        end

        else begin

            rx_done <= 0;

            case(state)

                // -------------------------------------------------
                // IDLE
                // -------------------------------------------------

                IDLE: begin

                    if(rx == 0) begin

                        state <= START;

                        sample_enable <= 0;
                    end
                end

                // -------------------------------------------------
                // START
                // -------------------------------------------------

                START: begin

                    if(baud_tick) begin

                        state <= DATA;

                        bit_index <= 0;

                        sample_enable <= 1;
                    end
                end

                // -------------------------------------------------
                // DATA
                // -------------------------------------------------

                DATA: begin

                    if(baud_tick && sample_enable) begin

                        data_reg[bit_index] <= rx;

                        if(bit_index == 7) begin

                            state <= STOP;
                        end

                        else begin

                            bit_index <= bit_index + 1;
                        end
                    end
                end

                // -------------------------------------------------
                // STOP
                // -------------------------------------------------

                STOP: begin

                    if(baud_tick) begin

                        rx_data <= data_reg;

                        rx_done <= 1;

                        state <= IDLE;
                    end
                end

            endcase
        end
    end

endmodule
