module fifo #(

    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16

)(

    input clk,
    input rst,

    input wr_en,
    input rd_en,

    input [DATA_WIDTH-1:0] wr_data,

    output reg [DATA_WIDTH-1:0] rd_data,

    output full,
    output empty

);

    // -------------------------------------------------
    // FIFO MEMORY
    // -------------------------------------------------

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // -------------------------------------------------
    // POINTERS
    // -------------------------------------------------

    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;

    // -------------------------------------------------
    // COUNT
    // -------------------------------------------------

    reg [4:0] count;

    // -------------------------------------------------
    // STATUS FLAGS
    // -------------------------------------------------

    assign full  = (count == DEPTH);

    assign empty = (count == 0);

    integer i;

    // -------------------------------------------------
    // FIFO LOGIC
    // -------------------------------------------------

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            wr_ptr <= 0;

            rd_ptr <= 0;

            count <= 0;

            rd_data <= 0;

            // Optional memory clear
            for(i = 0; i < DEPTH; i = i + 1)
                mem[i] <= 0;

        end

        else begin

            // -------------------------------------------------
            // WRITE ONLY
            // -------------------------------------------------

            if (wr_en && !rd_en && !full) begin

                mem[wr_ptr] <= wr_data;

                wr_ptr <= wr_ptr + 1;

                count <= count + 1;

            end

            // -------------------------------------------------
            // READ ONLY
            // -------------------------------------------------

            else if (rd_en && !wr_en && !empty) begin

                rd_data <= mem[rd_ptr];

                rd_ptr <= rd_ptr + 1;

                count <= count - 1;

            end

            // -------------------------------------------------
            // SIMULTANEOUS READ + WRITE
            // -------------------------------------------------

            else if (wr_en && rd_en && !full && !empty) begin

                // WRITE
                mem[wr_ptr] <= wr_data;

                wr_ptr <= wr_ptr + 1;

                // READ
                rd_data <= mem[rd_ptr];

                rd_ptr <= rd_ptr + 1;

                // COUNT REMAINS SAME

            end

        end

    end

endmodule
