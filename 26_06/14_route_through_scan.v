module scan_dff(
    input clk,
    input scan_en,
    input d,
    input scan_in,
    output reg q
);

always @(posedge clk)
begin
    if(scan_en)
        q <= scan_in;
    else
        q <= d;
end

endmodule

module rts_scan_chain(

    input clk,
    input scan_en,
    input scan_in,

    input reorder,

    output scan_out

);

wire q0,q1,q2,q3;

scan_dff ff0(
    .clk(clk),
    .scan_en(scan_en),
    .d(1'b0),
    .scan_in(scan_in),
    .q(q0)
);

wire ff1_scan_in;
wire ff2_scan_in;

assign ff1_scan_in = reorder ? q2 : q0;
assign ff2_scan_in = reorder ? q0 : q1;

scan_dff ff1(
    .clk(clk),
    .scan_en(scan_en),
    .d(1'b0),
    .scan_in(ff1_scan_in),
    .q(q1)
);

scan_dff ff2(
    .clk(clk),
    .scan_en(scan_en),
    .d(1'b0),
    .scan_in(ff2_scan_in),
    .q(q2)
);

scan_dff ff3(
    .clk(clk),
    .scan_en(scan_en),
    .d(1'b0),
    .scan_in(q1),
    .q(q3)
);

assign scan_out = q3;

endmodule

module tb;

reg clk;
reg scan_en;
reg scan_in;
reg reorder;

wire scan_out;

rts_scan_chain dut(
    .clk(clk),
    .scan_en(scan_en),
    .scan_in(scan_in),
    .reorder(reorder),
    .scan_out(scan_out)
);

always #5 clk = ~clk;

initial
begin

    clk = 0;
    scan_en = 1;

    $display("Normal Scan Order");
    reorder = 0;

    scan_in=1; #10;
    scan_in=0; #10;
    scan_in=1; #10;
    scan_in=1; #10;

    #20;

    $display("RTS Reordered Scan Chain");
    reorder = 1;

    scan_in=0; #10;
    scan_in=1; #10;
    scan_in=0; #10;
    scan_in=1; #10;

    #50;
    $finish;

end

always @(posedge clk)
begin
    $display("time=%0t scan_out=%b",
              $time, scan_out);
end

endmodule
