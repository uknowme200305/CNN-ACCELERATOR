`timescale 1ns/1ps
module tb();
    logic clk,rst,en;
    logic [7:0]d;
    logic [7:0]q;
    bit fail; 

    // instatiation
    reg_block #(.WIDTH(8)) DUT(.clk(clk) , .rst(rst) , .en(en) , .d(d) , .q(q));

    // clock generation 

    always #5 clk = ~clk;

    //task definition

    task apply(input logic t_rst , input logic t_en , input logic [7:0] t_d); 
    begin 
        rst = t_rst;
        en = t_en;
        d = t_d;
        @(posedge clk);
    end 
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end
    // definign stimulus 

    // initial state 
    initial begin
    clk= 0;
    rst=0;
    en=0;
    d=0;

    apply(1,0,8'hA6); 
    if (q!==8'h00)  begin 
        $display("TEST FAILED at time %0t", $time);
        fail = 1;
    end
    apply(0,1,8'hA6); 
    if (q!==8'hA6) begin
        $display("TEST FAILED at time %0t", $time);
        fail = 1;
    end
    apply(0,0,8'h3C);
    if (q!==8'hA6) begin
    $display("TEST FAILED at time %0t", $time);
        fail = 1;
    end
    apply(0,1,8'h3C);
    if (q!==8'h3C) begin
        $display("TEST FAILED at time %0t", $time);
        fail = 1;
    end
    apply(1,1,8'h3C);
    if (q!==8'h00) begin
        $display("TEST FAILED at time %0t", $time);
        fail = 1;
    end

    if(fail) $display("TEST FAILED");
    else $display("TEST PASSED"); 
    $finish;
    end
endmodule 