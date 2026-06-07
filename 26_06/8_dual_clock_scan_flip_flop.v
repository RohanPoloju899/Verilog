`timescale 1ns/1ps;
module dcsff (
    input  D, scan_input, scan_enable,
    input  data_clock, scan_clock,
    input rst,
    output reg Q
);
    wire d_mux  = scan_enable ? scan_input : D;
    wire clock_mux = scan_enable ? scan_clock : data_clock;

    always @(posedge clock_mux)
        if(rst)
            Q<=1'b0;
        else
            Q <= d_mux;

endmodule

module dcsff_tb;
    reg D, scan_input, scan_enable;
    reg data_clock, scan_clock;
    reg rst;
    wire Q;

    dcsff uut(
        .D(D), .scan_input(scan_input), .scan_enable(scan_enable),
        .data_clock(data_clock), .scan_clock(scan_clock),.rst(rst),
        .Q(Q)
    );

    initial begin
        $dumpfile("dcsff_wave.vcd");
        $dumpvars(0, dcsff_tb);
    end

    always #5 data_clock=~data_clock;
    always #5 scan_clock=~scan_clock;

    integer i;

    reg [7:0] pattern=8'b11010010;

    initial begin
        D=0; scan_input=0; scan_enable=0;
        data_clock=0; scan_clock=0;
        rst=1;

        #10;

        rst=0;
        scan_enable=1;
        for(i=7;i>=0;i=i-1) begin
            scan_input=pattern[i];
            #10;
        end
        #10;
        $finish;
    end
endmodule 
