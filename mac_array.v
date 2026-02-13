module mac_array #(parameter NUM_MAC =4, IN_WIDTH = 8 , ACC_WIDTH = 16)(
    input clk,
    input rst,
    input en,
    input [NUM_MAC*IN_WIDTH-1:0] a, // input vector , but accomodating all the the macs
    input [NUM_MAC*IN_WIDTH-1:0] b,
    input [NUM_MAC*ACC_WIDTH-1:0] acc_in,
    output reg [NUM_MAC*ACC_WIDTH-1:0] acc_out
);

    //isntantiating multiple mac units
    genvar i; 
    generate 
        for (i= 0 , i< NUM_MAC , i = i+1) begin : MACS
            mac_unit_pipelined #(IN_WIDTH, ACC_WIDTH) mac_i (
                .clk(clk),
                .rst(rst),
                .en(en),
                .a(a[i*IN_WIDTH +: IN_WIDTH]), // SELECTING THE DESIRED BITS (start , width) from the start amount it stores width amount of bits for that particular mac unit
                .b(b[i*IN_WIDTH +: IN_WIDTH]),
                .acc_in(acc_in[i*ACC_WIDTH +: ACC_WIDTH]),
                .acc_out(acc_out[i*ACC_WIDTH +: ACC_WIDTH])
            );
        end
    endgenerate
endmodule