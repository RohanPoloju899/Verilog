module adaptive_huffman_feedback (
    input clk,
    input rst,
    input [1:0] symbol_in,   // 4 possible symbols: 0,1,2,3
    output reg [1:0] huff_code,
    output reg [1:0] prev_symbol
);

    reg [7:0] freq [0:3];
    integer i;
    reg [1:0] max_symbol;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_symbol <= 0;
            huff_code   <= 0;

            for(i=0;i<4;i=i+1)
                freq[i] <= 0;
        end
        else begin
            // feedback register
            prev_symbol <= symbol_in;

            // update frequency
            freq[symbol_in] <= freq[symbol_in] + 1;

            // find most frequent symbol
            max_symbol = 0;
            for(i=1;i<4;i=i+1)
                if(freq[i] > freq[max_symbol])
                    max_symbol = i;

            // simple Huffman-like assignment
            if(symbol_in == max_symbol)
                huff_code <= 2'b0;      // shortest code
            else if(symbol_in == prev_symbol)
                huff_code <= 2'b10;
            else
                huff_code <= 2'b11;
        end
    end

endmodule

`timescale 1ns/1ps

module tb;

    reg clk;
    reg rst;
    reg [1:0] symbol_in;

    wire [1:0] huff_code;
    wire [1:0] prev_symbol;

    adaptive_huffman_feedback dut(
        .clk(clk),
        .rst(rst),
        .symbol_in(symbol_in),
        .huff_code(huff_code),
        .prev_symbol(prev_symbol)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        symbol_in = 0;

        #10 rst = 0;

        symbol_in = 2'b00; #10;
        symbol_in = 2'b01; #10;
        symbol_in = 2'b00; #10;
        symbol_in = 2'b10; #10;
        symbol_in = 2'b00; #10;
        symbol_in = 2'b00; #10;
        symbol_in = 2'b11; #10;
        symbol_in = 2'b00; #10;

        #20 $finish;
    end

    initial begin
        $monitor("t=%0t sym=%b prev=%b code=%b",
                  $time, symbol_in, prev_symbol, huff_code);
    end

endmodule
