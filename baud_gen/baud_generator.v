module baud_generator(

    input clk,
    input rst,

    output reg baud_tick
);

    // VERY SLOW BAUD FOR DEBUGGING

    parameter DIVISOR = 100;

    reg [15:0] counter;

    always @(posedge clk or posedge rst) begin

        if(rst) begin

            counter <= 0;
            baud_tick <= 0;
        end

        else begin

            if(counter == DIVISOR-1) begin

                counter <= 0;

                baud_tick <= 1'b1;
            end

            else begin

                counter <= counter + 1'b1;

                baud_tick <= 1'b0;
            end
        end
    end

endmodule
