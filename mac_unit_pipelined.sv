`timescale 1ns/1ps
module mac_unit_pipelined_tb();
    logic clk; 
    logic rst;
    logic en;
    logic [7:0] a; 
    logic [7:0] b; 
    logic [15:0] acc_in;
    logic [15:0] acc_out;
    bit fail;

    //instantiation
    mac_unit_pipelined #(.IN_WIDTH(8), .ACC_WIDTH(16)) DUT(
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
        $dumpvars(0, mac_unit_pipelined_tb);
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

        //case 1 : reset functionality
        apply(8'd10, 8'd20, 16'd100, 1'b1, 1'b0);
        rst =1'b1;
        rst = 1'b0;
        if (acc_out !== 16'd0) begin
            $display("TEST FAILED at time %0t: Reset functionality", $time);
            fail = 1;
        end
        @(posedge clk);
        @(posedge clk);
        //to test no other values remained at pipeline stages
        if (acc_out !== 16'd0) begin
            $display("TEST FAILED at time %0t: Reset functionality", $time);
            fail = 1;
        end


        //case 2 : normal operation
        apply(8'd3, 8'd4, 16'd10, 1'b1, 1'b0); // 3*4 + 10 = 22
        //wait for 2 cycles due to pipelining
        @(posedge clk);
        @(posedge clk);
        if (acc_out !== 16'd22) begin
            $display("TEST FAILED at time %0t: Normal operation", $time);
            fail = 1;
        end

        apply(8'd5, 8'd6, 16'd0, 1'b1, 1'b0); // 5*6 + 0 = 30
        //wait for 2 cycles due to pipelining
        @(posedge clk);
        @(posedge clk);
        if (acc_out !== 16'd30) begin
            $display("TEST FAILED at time %0t: Normal operation", $time);
            fail = 1;
        end
        @(posedge clk);
        @(posedge clk);

        //stronger reset 

        apply(8'd3, 8'd4, 16'd10, 1'b1, 1'b0); // start op
        @(posedge clk); // op is in pipeline

        apply(0,0,0,0,1); // assert reset
        if (acc_out !== 0) begin
            $display("TEST FAILED at time %0t: Stronger reset", $time);
            fail = 1;
        end

        // wait pipeline latency
        @(posedge clk);
        @(posedge clk);

        // old result must NOT appear
        if (acc_out !== 0) begin
            $display("TEST FAILED at time %0t: Stronger reset", $time);
            fail = 1;
        end

        @posedge clk;
        @posedge clk;

        //enable check after sure that nothing is there in the pipeline
        apply(8'd7, 8'd8, 16'd50, 1'b0, 1'b0);// en = 0, acc_out should hold previous value 30
        @(posedge clk);
        @(posedge clk); //flushing the pipeline
        if(acc_out !== 16'd00)begin
            $display("TEST FAILED at time %0t: Enable functionality", $time);
            fail = 1;
        end

        if (fail == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("SOME TESTS FAILED");
        end
        $finish;
    end

endmodule