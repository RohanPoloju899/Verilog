`timescale 1ns/1ps;

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
    input w0,
    input load,
    input rst,
    output q1,q2,q3
);
    wire w1,w2,w3,w4,w5;
    
    dff d0(
        .clk(clk),
        .d(load?w0:w5),
        .rst(rst),
        .q(w1)
    );  

    dff d1(
        .clk(clk),
        .d(w1),
        .rst(rst),
        .q(w2)
    );  

    assign q1=w2;

    dff d2(
        .clk(clk),
        .d(w2),
        .rst(rst),
        .q(w3)
    );

    assign q2=w3;

    dff d3(
        .clk(clk),
        .d(w3),
        .rst(rst),
        .q(w4)
    );

    assign q3=w4;

    assign w5=w4^w1;
    
endmodule

module lfsr_tb();
    reg clk,load,w0,rst;
    wire q1,q2,q3;

    lfsr uut(
        .clk(clk),.load(load),.w0(w0),.rst(rst),
        .q1(q1),.q2(q2),.q3(q3)
    );

    initial begin
        $dumpfile("lfsr_wave.vcd");
        $dumpvars(0,lfsr_tb);
    end

    always #5 clk=~clk;

    initial begin
        clk=0;

        rst=1;
        load=0;w0=0;
        #10;

        rst=0;
        load=1;w0=1;
        #10;
        
        load=0;w0=0;
        #160;
        $finish;
    end

    initial begin
        $monitor("%0t: %b%b%b",$time,q1,q2,q3);
    end
endmodule
