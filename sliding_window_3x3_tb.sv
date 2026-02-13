`timescale 1ns/1ps
module tb_sliding_window_3x3;

    parameter IMG_W = 5;

    logic clk, rst, en;
    logic [7:0] pixel_in;

    logic [7:0] w00, w01, w02;
    logic [7:0] w10, w11, w12;
    logic [7:0] w20, w21, w22;
    logic window_valid;

    bit fail;

    // DUT
    sliding_window_3x3 #(.IMG_W(IMG_W)) DUT (
        .clk(clk),
        .rst(rst),
        .en(en),
        .pixel_in(pixel_in),
        .w00(w00), .w01(w01), .w02(w02),
        .w10(w10), .w11(w11), .w12(w12),
        .w20(w20), .w21(w21), .w22(w22),
        .window_valid(window_valid)
    );

    // Clock: 10ns period
    always #5 clk = ~clk;

    // Dump waves
    initial begin
        $dumpfile("sliding_window.vcd");
        $dumpvars(0, tb_sliding_window_3x3);
    end

    // Test image: 5×5
    // Row-major: p00=0, p01=1, ...
    byte image [0:24];

    integer i;

    initial begin
        // Prepare image
        for (i = 0; i < 25; i = i + 1)
            image[i] = i;

        // Init
        clk = 0;
        rst = 1;
        en  = 0;
        pixel_in = 0;
        fail = 0;

        @(posedge clk);
        rst = 0;
        en  = 1;

        // Stream pixels
        for (i = 0; i < 25; i = i + 1) begin
            pixel_in = image[i];
            @(posedge clk);

            if (window_valid) begin
                // Expected top-left index of window
                int row = i / IMG_W;
                int col = i % IMG_W;

                // Only check when valid (row>=2 && col>=2)
                if (row >= 2 && col >= 2) begin
                    if (w00 !== image[(row-2)*IMG_W + (col-2)]) fail=1;
                    if (w01 !== image[(row-2)*IMG_W + (col-1)]) fail=1;
                    if (w02 !== image[(row-2)*IMG_W + (col-0)]) fail=1;

                    if (w10 !== image[(row-1)*IMG_W + (col-2)]) fail=1;
                    if (w11 !== image[(row-1)*IMG_W + (col-1)]) fail=1;
                    if (w12 !== image[(row-1)*IMG_W + (col-0)]) fail=1;

                    if (w20 !== image[(row-0)*IMG_W + (col-2)]) fail=1;
                    if (w21 !== image[(row-0)*IMG_W + (col-1)]) fail=1;
                    if (w22 !== image[(row-0)*IMG_W + (col-0)]) fail=1;

                    if (fail)
                        $display("FAIL at pixel index %0d (row=%0d col=%0d)", i, row, col);
                end
            end
        end

        if (!fail)
            $display("SLIDING WINDOW TEST PASSED");
        else
            $display("SLIDING WINDOW TEST FAILED");

        $finish;
    end

endmodule
