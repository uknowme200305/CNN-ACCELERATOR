module line_buffer#(parameter WIDTH = 4)(
    input clk,
    input rst,
    input en,
    input [15:0] pixel_in,
    output reg [15:0] pixel_out
);
    // buffer structure 8bit per pixel and total length WIDTH
    // | - - - - - - - |
    // | - - - - - - - |
    // | - - - - - - - |
    // | - - - - - - - |
    reg [7:0] buffer [0:WIDTH-1];
    integer i;
    always @(posedge clk or posedge rst) begin
        if(rst) begin 
            // reset the buffer
            for(i=0; i<WIDTH; i=i+1) begin
                buffer[i] <= 8'b0;
            end
        end
        else if(en) begin
            // shift the buffer and insert new pixel
            for(i=WIDTH-1; i>0; i=i-1) begin
                buffer[i] <= buffer[i-1];
            end
            buffer[0] <= pixel_in[7:0]; // assuming we take the lower 8 bits of pixel_in
        end
        //else hold
    end

    assign pixel_out = buffer[WIDTH-1] ; // output the last pixel in the buffer which got shifted
endmodule