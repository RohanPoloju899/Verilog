`timescale 1ns/1ps;

module dff (
    input clk,d,rst,
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
    input clk,w0,load,rst,
    output q0,q1,q2,q3
);
    wire w1,w2,w3,w4,w5;

    dff d0(.clk(clk),.d(load?w0:w5),.rst(rst),.q(w1));  

    assign q0=w1;

    dff d1(.clk(clk),.d(w1),.rst(rst),.q(w2));  

    assign q1=w2;

    dff d2(.clk(clk),.d(w2),.rst(rst),.q(w3));

    assign q2=w3;

    dff d3(.clk(clk),.d(w3),.rst(rst),.q(w4));

    assign q3=w4;

    assign w5=w4^w1;

endmodule

module scan_dff (
    input clk,scan_en,scan_in,d,
    output reg q
);
    wire d_mux;
    assign d_mux = scan_en ? scan_in : d;
    always @(posedge clk) begin
        q <= d_mux;
    end
endmodule

module scan_chain(
    input d0,d1,d2,scan_in,scan_enable,clk,
    output scan_out
);
    wire w0,w1;

    scan_dff sff0(
        .clk(clk),
        .scan_en(scan_enable),
        .scan_in(scan_in),
        .d(d0),
        .q(w0)
    );

    scan_dff sff1(
        .clk(clk),
        .scan_en(scan_enable),
        .scan_in(w0),
        .d(d1),
        .q(w1)
    );

    scan_dff sff2(
        .clk(clk),
        .scan_en(scan_enable),
        .scan_in(w1),
        .d(d2),
        .q(scan_out)
    );

endmodule

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

module misr(
    input clk,
    input s0,s1,s2,s3,
    input rst,
    output misr_signature0,misr_signature1,misr_signature2,misr_signature3
);
    wire w0,w1,w2,w3,w4,w5,w6,w7;

    assign w0=s0^w7;

    dff d0(
        .clk(clk),
        .d(w0),
        .rst(rst),
        .q(w1)
    );
    
    assign w2=s1^w1;

    dff d1(
        .clk(clk),
        .d(w2),
        .rst(rst),
        .q(w3)
    );
    
    assign w4=s2^w3;

    dff d2(
        .clk(clk),
        .d(w4),
        .rst(rst),
        .q(w5)
    );
    
    assign w6=s3^w5^w7;

    dff d3(
        .clk(clk),
        .d(w6),
        .rst(rst),
        .q(w7)
    );

    assign misr_signature0=w1;
    assign misr_signature1=w3;
    assign misr_signature2=w5;
    assign misr_signature3=w7;
endmodule

module stumps(
    input rst,
    input clk,
    input w0,
    input load,
    input scan_enable,
    output misr_signature0,misr_signature1,misr_signature2,misr_signature3
);
    wire w1,w2,w3,w4;
    lfsr lfsr0(
        clk(clk),
        w0(w0),
        load(load),
        rst(rst),
        q0(w1),q1(w2),q2(w3),q3(w4)
    );





    

    

