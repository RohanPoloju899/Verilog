module crc8_gen (
    input  wire in0, in1, in2, in3, in4, in5, in6, in7,
    input  wire fault_en,
    input  wire [2:0] fault_sel,
    output wire out0, out1, out2, out3, out4, out5, out6, out7
);
    wire [7:0] data_in = {in7, in6, in5, in4, in3, in2, in1, in0};
    reg  [7:0] crc_out;
    reg  [7:0] crc_final;
    integer i;
    reg [15:0] dividend;
    parameter [8:0] POLY = 9'b100000111;   // x^8 + x^2 + x + 1

    always @(*) begin
        dividend = {data_in, 8'b0};
        for (i = 15; i >= 8; i = i - 1)
            if (dividend[i])
                dividend[i -: 9] = dividend[i -: 9] ^ POLY;
        crc_out = dividend[7:0];

        crc_final = crc_out;
        if (fault_en)
            crc_final[fault_sel] = ~crc_out[fault_sel];   // flip selected bit
    end

    assign {out7, out6, out5, out4, out3, out2, out1, out0} = crc_final;

endmodule

`timescale 1ns/1ps
module crc8_tb;
    reg in0, in1, in2, in3, in4, in5, in6, in7;
    reg fault_en;
    reg [2:0] fault_sel;
    wire out0, out1, out2, out3, out4, out5, out6, out7;

    crc8_gen uut (
        .in0(in0), .in1(in1), .in2(in2), .in3(in3),
        .in4(in4), .in5(in5), .in6(in6), .in7(in7),
        .fault_en(fault_en),
        .fault_sel(fault_sel),
        .out0(out0), .out1(out1), .out2(out2), .out3(out3),
        .out4(out4), .out5(out5), .out6(out6), .out7(out7)
    );

    initial begin
        $dumpfile("crc8.vcd");
        $dumpvars(0, crc8_tb);

        // ---- Settling: all lines 0 ----
        {in7,in6,in5,in4,in3,in2,in1,in0} = 8'b00000000;
        fault_en  = 0;
        fault_sel = 3'd0;
        #5;

        // ---- Normal mode ----
        {in7,in6,in5,in4,in3,in2,in1,in0} = 8'b10111011;
        fault_en  = 0;
        #5;

        // ---- Fault mode ----
        fault_en  = 1;
        fault_sel = 3'd3;    // flip bit 3
        #5;

        // ---- Normal mode again ----
        fault_en  = 0;
        #5;

        $finish;
    end
endmodule
