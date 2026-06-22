`timescale 1ns/1ps

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
    wire w1,w2,w3,w4;      // LFSR outputs -> scan chain inputs
    wire sc0_out,sc1_out;  // intermediate scan chain outputs
    wire scan_out;         // final scan chain output -> MISR input

    lfsr lfsr0(
        .clk(clk),
        .w0(w0),
        .load(load),
        .rst(rst),
        .q0(w1),.q1(w2),.q2(w3),.q3(w4)
    );

    // Three parallel scan chains, each fed by one LFSR tap,
    // scan_in driven by another LFSR tap as the seed
    scan_chain sc0(
        .d0(w1),.d1(w2),.d2(w3),
        .scan_in(w4),
        .scan_enable(scan_enable),
        .clk(clk),
        .scan_out(sc0_out)
    );

    scan_chain sc1(
        .d0(w2),.d1(w3),.d2(w4),
        .scan_in(w1),
        .scan_enable(scan_enable),
        .clk(clk),
        .scan_out(sc1_out)
    );

    scan_chain sc2(
        .d0(w3),.d1(w4),.d2(w1),
        .scan_in(w2),
        .scan_enable(scan_enable),
        .clk(clk),
        .scan_out(scan_out)
    );

    misr misr0(
        .clk(clk),
        .s0(sc0_out),.s1(sc1_out),.s2(scan_out),.s3(w1),
        .rst(rst),
        .misr_signature0(misr_signature0),
        .misr_signature1(misr_signature1),
        .misr_signature2(misr_signature2),
        .misr_signature3(misr_signature3)
    );

endmodule

`timescale 1ns/1ps

module stumps_tb;

    reg rst, clk, w0, load, scan_enable;
    wire misr_signature0, misr_signature1, misr_signature2, misr_signature3;

    stumps dut (
        .rst(rst), .clk(clk), .w0(w0), .load(load), .scan_enable(scan_enable),
        .misr_signature0(misr_signature0), .misr_signature1(misr_signature1),
        .misr_signature2(misr_signature2), .misr_signature3(misr_signature3)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("stumps_tb.vcd");
        $dumpvars(0, stumps_tb);

        clk = 0; w0 = 0; load = 0; scan_enable = 0;

        // reset
        rst = 1;
        @(posedge clk); @(posedge clk);
        rst = 0;

        // load seed into LFSR
        load = 1; w0 = 1;
        @(posedge clk);
        load = 0;

        // free-run LFSR a bit
        repeat (3) @(posedge clk);

        // scan shift
        scan_enable = 1;
        repeat (4) @(posedge clk);

        // capture
        scan_enable = 0;
        @(posedge clk);

        $display("MISR signature = %b%b%b%b",
                   misr_signature3, misr_signature2, misr_signature1, misr_signature0);

        $finish;
    end

endmodule
