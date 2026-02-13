`timescale 1ns/1ps
module mac_array_tb;

    parameter NUM_MAC   = 4;
    parameter IN_WIDTH  = 8;
    parameter ACC_WIDTH = 16;

    logic clk, rst, en;
    logic [NUM_MAC*IN_WIDTH-1:0]  a, b;
    logic [NUM_MAC*ACC_WIDTH-1:0] acc_in;
    logic [NUM_MAC*ACC_WIDTH-1:0] acc_out;
    bit fail;

    // DUT
    mac_array #(
        .NUM_MAC(NUM_MAC),
        .IN_WIDTH(IN_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .en(en),
        .a(a),
        .b(b),
        .acc_in(acc_in),
        .acc_out(acc_out)
    );

    // Clock: 20ns period
    always #10 clk = ~clk;

    // Dump
    initial begin
        $dumpfile("mac_array.vcd");
        $dumpvars(0, mac_array_tb);
    end

    initial begin
        clk = 0;
        rst = 1;
        en  = 0;
        a = 0;
        b = 0;
        acc_in = 0;
        fail = 0;

        // --------------------
        // Reset Test
        // --------------------
        @(posedge clk);
        if (acc_out !== 0) begin
            $display("FAIL: Reset test");
            fail = 1;
        end
        rst = 0;

        // --------------------
        // Parallel MAC Test
        // a = {48,65,0,2}
        // b = {4,3,0,4}
        // Expected:
        // lane0: 2*4  = 8
        // lane1: 0*0  = 0
        // lane2: 65*3 = 195
        // lane3: 48*4 = 192
        // --------------------
        a      = 32'h30_41_00_02;
        b      = 32'h04_03_00_04;
        acc_in = 0;
        en     = 1;

        // wait pipeline (2 cycles) + flush (2 cycles)
        repeat(4) @(posedge clk);

        if (acc_out[0*16 +:16] !== 16'd8)   fail = 1;
        if (acc_out[1*16 +:16] !== 16'd0)   fail = 1;
        if (acc_out[2*16 +:16] !== 16'd195) fail = 1;
        if (acc_out[3*16 +:16] !== 16'd192) fail = 1;

        if (fail) $display("FAIL: Parallel MAC test");

        // --------------------
        // Enable Hold Test
        // --------------------
        // Flush pipeline
        repeat(2) @(posedge clk);

        // Change inputs but disable
        a      = 32'h11_22_33_44;
        b      = 32'h55_66_77_88;
        acc_in = 64'hFFFF_FFFF_FFFF_FFFF;
        en     = 0;

        repeat(4) @(posedge clk);

        // Output must stay same as before
        if (acc_out[0*16 +:16] !== 16'd8)   fail = 1;
        if (acc_out[1*16 +:16] !== 16'd0)   fail = 1;
        if (acc_out[2*16 +:16] !== 16'd195) fail = 1;
        if (acc_out[3*16 +:16] !== 16'd192) fail = 1;

        if (fail)
            $display("SOME TESTS FAILED");
        else
            $display("ALL TESTS PASSED");

        $finish;
    end
endmodule
