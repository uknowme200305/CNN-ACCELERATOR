`timescale 1ns/1ps
module add_sub_tb();
    logic clk; 
    logic [7:0] a; 
    logic [7:0] b; 
    logic sub; 
    logic [7:0] result;
    bit fail; 
    logic carry_or_borrow;

    //instantiation 
    add_sub #(.WIDTH(8)) DUT(.a(a) , .b(b) , .sub(sub) , .result(result), .carry_or_borrow(carry_or_borrow));
    // clock generation
    always #10 clk = ~clk;

    //task definition
    task apply(input logic [7:0] t_a , input logic [7:0] t_b , input logic t_sub);
    begin
        a = t_a; 
        b = t_b;
        sub = t_sub;
        @(posedge clk);
    end
    endtask 

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, add_sub_tb);
    end

    //stimulus 

    initial begin 
        //inital condition 
        clk = 0; 
        a=0; 
        b=0; 
        sub = 0 ; 
        fail = 0; 

        //test cases : 
        //add normal
        apply(8'd15 , 8'd10 , 1'b0); // 15 + 10 = 25
        if (result !== 8'd25 || carry_or_borrow!==1'b0) begin
            $display("TEST FAILED at time %0t", $time);
            fail = 1;
        end
        // add with expected carry 

        apply(8'hFF , 8'h01 , 1'b0);
        if (result !== 8'h00 || carry_or_borrow!==1'b1) begin
            $display("TEST FAILED at time %0t", $time);
            fail = 1;
        end

        // sub normal
        apply(8'd20 , 8'd5 , 1'b1); // 20 - 5 = 15
        if (result !== 8'd15 || carry_or_borrow!==1'b0) begin
            $display("TEST FAILED at time %0t", $time);
            fail = 1;
        end     
        // sub with expected borrow
        apply(8'd5 , 8'd10 , 1'b1); // 5 - 10 = 251 (with borrow)
        if (result !== 8'd251 || carry_or_borrow!==1'b1) begin
            $display("TEST FAILED at time %0t", $time);
            fail = 1;
        end
        $display("TEST PASSED");
        $finish; 
    end
endmodule