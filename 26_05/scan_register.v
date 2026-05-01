`timescale 1ns / 1ps

module scan_shift_reg_delay #(
    parameter N = 8
)(
    input clk,
    input scan_en,                 // enable scan operation
    input scan_in,                 // serial input
    input [3:0] delay_cycles,      // user-defined delay
    output scan_out,
    output reg [N-1:0] q
);

    reg [3:0] count = 0;
    reg enable_shift = 0;

    // Delay control logic
    always @(posedge clk) begin
        if (scan_en) begin
            if (count < delay_cycles) begin
                count <= count + 1;
                enable_shift <= 0;   // HOLD
            end else begin
                enable_shift <= 1;   // SHIFT ENABLE
            end
        end else begin
            count <= 0;
            enable_shift <= 0;
        end
    end

    // Shift register
    always @(posedge clk) begin
        if (enable_shift)
            q <= {q[N-2:0], scan_in};
    end

    assign scan_out = q[N-1];

endmodule

`timescale 1ns / 1ps

module tb_scan_shift_reg_delay;

    reg clk;
    reg scan_en;
    reg scan_in;
    reg [3:0] delay_cycles;

    wire scan_out;
    wire [7:0] q;

    scan_shift_reg_delay #(8) uut (
        .clk(clk),
        .scan_en(scan_en),
        .scan_in(scan_in),
        .delay_cycles(delay_cycles),
        .scan_out(scan_out),
        .q(q)
    );

    // Clock (10 ns period)
    always #5 clk = ~clk;

    integer i;
    reg [7:0] pattern = 8'b10110011;

    initial begin
        clk = 0;
        scan_en = 1;

        delay_cycles = 3;  // 👈 try changing this

        // -------- Shift IN --------
        for (i = 0; i < 8; i = i + 1) begin
            scan_in = pattern[i];   // LSB first
            #10;
        end

        // Wait extra cycles to observe delay effect
        #40;

        // -------- Shift OUT --------
        scan_in = 0; // dummy bits
        for (i = 0; i < 8; i = i + 1) begin
            #10;
        end

        $finish;
    end

endmodule
