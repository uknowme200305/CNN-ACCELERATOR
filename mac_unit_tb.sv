`timescale 1ns/1ps
module mac_unit_tb();
    logic clk; 
    logic rst;
    logic en;
    logic [7:0] a; 
    logic [7:0] b; 
    logic [15:0] acc_in;
    logic [15:0] acc_out;
    bit fail;

    //instantiation
    mac_unit #(.IN_WIDTH(8), .ACC_WIDTH(16)) DUT(
        .clk(clk), 
        .rst(rst), 
        .en(en), 
        .a(a), 
        .b(b), 
        .acc_in(acc_in), 
        .acc_out(acc_out)
    );

    //clock generation
    always #10 clk = ~clk;

    //task definition
    task apply(
        input logic [7:0] t_a, 
        input logic [7:0] t_b, 
        input logic [15:0] t_acc_in, 
        input logic t_en,
        input logic t_rst
    );
    begin
        a = t_a; 
        b = t_b; 
        acc_in = t_acc_in; 
        en = t_en;
        rst = t_rst;
        @(posedge clk);
    end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, mac_unit_tb);
    end

    //stimulus
    initial begin
        //initial condition
        clk = 0; 
        rst = 1;
        a = 0;
        b = 0;
        acc_in = 0;
        en = 0;
        fail = 0;

        //cases

        //1. reset 
        apply(8'd10, 8'd20, 16'd100, 1'b0, 1'b1);
        if (acc_out !== 16'd0) begin
            $display("TEST FAILED at time %0t: Reset failed", $time);
            fail = 1;
        end
        //2. normal MAC operation
        apply(8'd10, 8'd20, 16'd100, 1'b1, 1'b0); // acc_in + (10*20) = 100 + 200 = 300
        if (acc_out !== 16'd300) begin
            $display("TEST FAILED at time %0t: MAC operation failed", $time);
            fail = 1;
        end
        //3. MAC operation with different inputs
        apply(8'd5, 8'd4, 16'd300, 1'b1, 1'b0); // acc_in + (5*4) = 300 + 20 = 320
        if (acc_out !== 16'd320) begin
            $display("TEST FAILED at time %0t: MAC operation failed", $time);
            fail = 1;
        end
        #5 rst = 1; // Assert reset in between
        #10 rst = 0; // Deassert reset
        //4. Disable MAC operation
        apply(8'd15, 8'd10, 16'd320, 1'b0, 1'b0); // acc_out should remain 320
        if (acc_out !== 16'd320) begin
            $display("TEST FAILED at time %0t: Disable operation failed", $time);
            fail = 1;
        end
        //overflow case
        apply(8'h01, 8'hFF, 16'hFFFF, 1'b1, 1'b0); // acc_in + (1*255) = 65535 + 255= 65790 (due to overflow)
        if (acc_out !== 16'h00FE) begin
            $display("TEST FAILED at time %0t: Overflow handling failed", $time);
            fail = 1;
        end
        if (fail == 0) begin
            $display("ALL TESTS PASSED");
        end
        $finish;
    end

endmodule