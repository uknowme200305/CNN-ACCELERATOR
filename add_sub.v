module add_sub #(parameter WIDTH = 8)
(input [WIDTH -1:0] a ,
input [WIDTH -1:0] b ,
input sub ,
output reg [WIDTH -1:0] result ,
output reg carry_or_borrow);


always@(*)begin
    if(sub)begin
        {carry_or_borrow  , result} = a-b;
    end
    else begin
        {carry_or_borrow  , result} = a+b;
    end
end

endmodule