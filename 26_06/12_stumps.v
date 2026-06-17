module dff (
    input clk,
    input d,
    input rst,
    output reg q
);
    always @(posedge clk or posedge rst) begin
        if(rst) 
            q<=1'b0;
        else
            q<=d;
    end
endmodule

module lfsr(
    input clk,
    input d,
    input rst,
    input seed,
    output reg q
);
    wire w0,w1,w2,w3,w4,w5,w6;
    
    dff d0(
        .clk(clk),
        .d(w0|w6),
        .rst(rst),
        .q(w1)
    );  

    dff d1(
        .clk(clk),
        .d(w1),
        .rst(rst),
        .q(w2)
    );  

    dff d2(
        .clk(clk),
        .d(w2),
        .rst(rst),
        .q(w3)
    );

    dff d3(
        .clk(clk),
        .d(w3),
        .rst(rst),
        .q(w4)
    );

    assign w6=w5|w1;
endmodule

  
    
