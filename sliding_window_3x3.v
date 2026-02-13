module sliding_window_3x3 #(
    parameter IMG_W = 5
)(
    input  clk,
    input  rst,
    input  en,
    input  [7:0] pixel_in,

    output reg [7:0] w00, w01, w02,
                     w10, w11, w12,
                     w20, w21, w22,

    output reg window_valid
);

    // Line buffers
    wire [7:0] lb0_out, lb1_out;

    line_buffer #(.WIDTH(IMG_W)) lb0 (
        .clk(clk), .rst(rst), .en(en),
        .pixel_in(pixel_in),
        .pixel_out(lb0_out)
    );

    line_buffer #(.WIDTH(IMG_W)) lb1 (
        .clk(clk), .rst(rst), .en(en),
        .pixel_in(lb0_out),
        .pixel_out(lb1_out)
    );

    // Counters
    reg [$clog2(IMG_W)-1:0] col_cnt;
    reg [$clog2(IMG_W)-1:0] row_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            col_cnt <= 0;
            row_cnt <= 0;
            window_valid <= 0;
            {w00,w01,w02,w10,w11,w12,w20,w21,w22} <= 0;
        end
        else if (en) begin
            // Column shift
            w02 <= w01;  w01 <= w00;
            w12 <= w11;  w11 <= w10;
            w22 <= w21;  w21 <= w20;

            // Load new column
            w00 <= pixel_in;
            w10 <= lb0_out;
            w20 <= lb1_out;

            // Column counter
            if (col_cnt == IMG_W-1) begin
                col_cnt <= 0;
                row_cnt <= row_cnt + 1;
            end else begin
                col_cnt <= col_cnt + 1;
            end

            // Valid window condition
            window_valid <= (row_cnt >= 2) && (col_cnt >= 2);
        end
    end

endmodule
