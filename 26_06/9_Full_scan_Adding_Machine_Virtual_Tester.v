module scan_dff (
    input  wire clk,
    input  wire rst,
    input  wire scan_en,
    input  wire d,
    input  wire scan_in,
    output reg  q
);

always @(posedge clk or posedge rst) begin
    if (rst)
        q <= 1'b0;
    else if (scan_en)
        q <= scan_in;
    else
        q <= d;
end

endmodule

module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);

assign sum  = a ^ b ^ cin;
assign cout = (a & b) | (b & cin) | (a & cin);

endmodule

module full_scan_adder (

    input  wire clk,
    input  wire rst,

    input  wire scan_en,
    input  wire scan_in,
    output wire scan_out

);

    wire a_q;
    wire b_q;
    wire cin_q;

    wire sum;
    wire cout;

    wire sum_q;
    wire cout_q;

    //-------------------------------------------------
    // Scan input registers
    //-------------------------------------------------

    scan_dff ff_a (
        .clk(clk),
        .rst(rst),
        .scan_en(scan_en),
        .d(1'b0),
        .scan_in(scan_in),
        .q(a_q)
    );

    scan_dff ff_b (
        .clk(clk),
        .rst(rst),
        .scan_en(scan_en),
        .d(1'b0),
        .scan_in(a_q),
        .q(b_q)
    );

    scan_dff ff_cin (
        .clk(clk),
        .rst(rst),
        .scan_en(scan_en),
        .d(1'b0),
        .scan_in(b_q),
        .q(cin_q)
    );

    //-------------------------------------------------
    // Functional Logic
    //-------------------------------------------------

    full_adder FA (
        .a(a_q),
        .b(b_q),
        .cin(cin_q),
        .sum(sum),
        .cout(cout)
    );

    //-------------------------------------------------
    // Output Capture Registers
    //-------------------------------------------------

    scan_dff ff_sum (
        .clk(clk),
        .rst(rst),
        .scan_en(scan_en),
        .d(sum),
        .scan_in(cin_q),
        .q(sum_q)
    );

    scan_dff ff_cout (
        .clk(clk),
        .rst(rst),
        .scan_en(scan_en),
        .d(cout),
        .scan_in(sum_q),
        .q(cout_q)
    );

    assign scan_out = cout_q;

endmodule

module tb;

reg clk;
reg rst;
reg scan_en;
reg scan_in;
wire scan_out;

full_scan_adder dut(
    .clk(clk),
    .rst(rst),
    .scan_en(scan_en),
    .scan_in(scan_in),
    .scan_out(scan_out)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    scan_en = 1;
    scan_in = 0;

    #10 rst = 0;

    // Load A=1, B=1, Cin=0
    scan_in = 1; #10;
    scan_in = 1; #10;
    scan_in = 0; #10;

    // Capture adder response
    scan_en = 0;
    #10;

    // Shift out response
    scan_en = 1;

    repeat(5) begin
        #10;
        $display("scan_out=%b", scan_out);
    end

    $finish;
end

endmodule
