module master #(
    parameter DATA_WIDTH=8
)(
    input clk,
    input rst_n,  
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out
);
    reg [DATA_WIDTH-1:0] s1;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            s1<=0;
        else begin
            s1<=data_in;
        end
    end
    
    assign data_out=s1;
endmodule
         
