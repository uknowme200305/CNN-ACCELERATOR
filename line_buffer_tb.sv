`timescale 1ns/1ps
module tb_line_buffer;

    parameter WIDTH = 4;

    logic clk, rst, en;
    logic [7:0] pixel_in;
    logic [7:0] pixel_out;
    bit fail;

    line_buffer #(.WIDTH(WIDTH)) DUT (
        .clk(clk),
        .rst(rst),
        .en(en),
        .pixel_in(pixel_in),
        .pixel_out(pixel_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("line_buffer.vcd");
        $dumpvars(0, tb_line_buffer);
    end

    initial begin
        clk = 0;
        rst = 1;
        en  = 0;
        pixel_in = 0;
        fail = 0;

        @(posedge clk);
        rst = 0;
        en  = 1;

        // Feed pixels 1..6
        pixel_in = 8'd1; @(posedge clk);
        if (pixel_out !== 0) fail=1;

        pixel_in = 8'd2; @(posedge clk);
        if (pixel_out !== 0) fail=1;

        pixel_in = 8'd3; @(posedge clk);
        if (pixel_out !== 0) fail=1;

        pixel_in = 8'd4; @(posedge clk);
        if (pixel_out !== 8'd1) fail=1;

        pixel_in = 8'd5; @(posedge clk);
        if (pixel_out !== 8'd2) fail=1;

        pixel_in = 8'd6; @(posedge clk);
        if (pixel_out !== 8'd3) fail=1;

        if (!fail)
            $display("LINE BUFFER TEST PASSED");
        else
            $display("LINE BUFFER TEST FAILED");

        $finish;
    end

endmodule
