module stumps(
    input rst,
    input clk,
    input w0,
    input load,
    input scan_enable,
    output misr_signature0,
    output misr_signature1,
    output misr_signature2,
    output misr_signature3
);

    wire l0,l1,l2,l3;
    wire scan_out;

    // Pattern Generator
    lfsr lfsr0(
        .clk(clk),
        .w0(w0),
        .load(load),
        .rst(rst),
        .q0(l0),
        .q1(l1),
        .q2(l2),
        .q3(l3)
    );

    // CUT represented by scan chain
    scan_chain cut(
        .d0(l0),
        .d1(l1),
        .d2(l2),
        .scan_in(l3),
        .scan_enable(scan_enable),
        .clk(clk),
        .scan_out(scan_out)
    );

    // Response Compactor
    misr misr0(
        .clk(clk),
        .s0(l0),
        .s1(l1),
        .s2(l2),
        .s3(scan_out),
        .rst(rst),
        .misr_signature0(misr_signature0),
        .misr_signature1(misr_signature1),
        .misr_signature2(misr_signature2),
        .misr_signature3(misr_signature3)
    );

endmodule

`timescale 1ns/1ps

module stumps_tb;

    reg clk;
    reg rst;
    reg w0;
    reg load;
    reg scan_enable;

    wire sig0,sig1,sig2,sig3;

    stumps dut(
        .rst(rst),
        .clk(clk),
        .w0(w0),
        .load(load),
        .scan_enable(scan_enable),
        .misr_signature0(sig0),
        .misr_signature1(sig1),
        .misr_signature2(sig2),
        .misr_signature3(sig3)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("stumps.vcd");
        $dumpvars(0,stumps_tb);

        clk = 0;
        rst = 1;
        load = 0;
        scan_enable = 0;
        w0 = 0;

        #15 rst = 0;

        // Seed LFSR with 1
        load = 1;
        w0 = 1;
        #10;

        load = 0;

        // Run BIST
        repeat(15) begin
            #10;
            $display(
                "t=%0t MISR=%b%b%b%b",
                $time,
                sig3,sig2,sig1,sig0
            );
        end

        $finish;
    end

endmodule
