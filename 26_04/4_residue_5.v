`timescale 1ns/1ps

module residue(
    input clk,
    input x,
    
    output reg [2:0] R
);
    
   reg [2:0] weight;
   
   wire [2:0] sum;
   assign sum = R + weight;

   initial begin
       R = 0;
       weight = 1;
   end
    
   always @(posedge clk) begin
       if (x)
           R <= (sum >= 5) ? (sum - 5) : sum;

       weight <= (2*weight >= 5) ? (2*weight - 5) : (2*weight);
   end

endmodule

module residue_tb;
    reg clk;
    reg x; 
    wire [2:0] R;
    
    residue uut(
        .clk(clk),
        .x(x),
        .R(R) 
    );  
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        
        x = 0;
        #10 x = 1;
        #10 x = 1;
        #10 x = 0;
        #10 x = 1;
        #10 x = 0;
        #10 x = 1;
        #10 x = 1;
        #10 x = 0;
        #10 x = 1;
        #10 $finish;
    end

endmodule
