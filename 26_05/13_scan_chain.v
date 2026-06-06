`timescale 1ns/1ps

module scan_dff (
    input clk,
    input scan_en,
    input scan_in,
    input d,
    output reg q
);

    wire d_mux;

    assign d_mux = scan_en ? scan_in : d;

    always @(posedge clk) begin
        q <= d_mux;
    end

endmodule

module scan_chain (
    input clk,
    input scan_en,
    input scan_in,
    input [7:0] d,

    output scan_out,
    output [7:0] q
);

    scan_dff ff0 (
        .clk(clk), 
        .scan_en(scan_en),
        .scan_in(scan_in),
        .d(d[0]),
        .q(q[0])
    );

    scan_dff ff1 (
        .clk(clk), 
        .scan_en(scan_en),
        .scan_in(q[0]),
        .d(d[1]),
        .q(q[1])
    );

    scan_dff ff2 (
        .clk(clk), 
        .scan_en(scan_en),
        .scan_in(q[1]),
        .d(d[2]),
        .q(q[2])
    );

    scan_dff ff3 (
        .clk(clk), 
        .scan_en(scan_en),
        .scan_in(q[2]),
        .d(d[3]),
        .q(q[3])
    );

    scan_dff ff4 (
        .clk(clk), 
        .scan_en(scan_en),
        .scan_in(q[3]),
        .d(d[4]),
        .q(q[4])
    );

    scan_dff ff5 (
        .clk(clk), 
        .scan_en(scan_en),
        .scan_in(q[4]),
        .d(d[5]),
        .q(q[5])
    );

    scan_dff ff6 (
        .clk(clk), 
        .scan_en(scan_en),
        .scan_in(q[5]),
        .d(d[6]),
        .q(q[6])
    );

    scan_dff ff7 (
        .clk(clk), 
        .scan_en(scan_en),
        .scan_in(q[6]),
        .d(d[7]),
        .q(q[7])
    );

    assign scan_out = q[7];

endmodule

`timescale 1ns/1ps

`timescale 1ns/1ps

module scan_chain_tb;

    reg clk;
    reg scan_en;
    reg scan_in;

    wire scan_out;
    wire [7:0] q;

    scan_chain uut (
        .clk(clk),
        .scan_en(scan_en),
        .scan_in(scan_in),
        .d(8'b0),        
        .scan_out(scan_out),
        .q(q)
    );
 
    initial begin
        $dumpfile("scan_chain_wave.vcd");
        $dumpvars(0, scan_chain_tb);
    end
    
    always #5 clk = ~clk;

    integer i;

    reg [7:0] pattern = 8'b10101101;

    initial begin
        clk = 0;
        scan_en = 1;  
        scan_in = 0;

        for (i = 0; i < 8; i = i + 1) begin
            scan_in = pattern[i];  

            #10;

        end
        $finish;
    end

endmodule
