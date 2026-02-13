// MAC UNIT --> MULTIPLIER AND ACCUMULATOR UNIT
//i/p --> a(input feature),b(weight), acc(previous_sum)

module mac_unit#(parameter IN_WIDTH = 8, ACC_WIDTH = 16)(
    input clk,
    input rst,
    input en,
    input [IN_WIDTH-1:0] a,
    input [IN_WIDTH-1:0] b,
    input [ACC_WIDTH-1:0] acc_in,
    output reg [ACC_WIDTH-1:0] acc_out
    );

    wire [2*IN_WIDTH-1:0] product;
    assign product = a*b; 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc_out <= 0;
        end
        else if (en) begin
            acc_out <= acc_in + product;
        end
        //else:hold value
    end

endmodule