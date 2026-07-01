module parallel_to_serial #(
    parameter DATA_WIDTH=8
)(
    input clk,
    input rst_n,  
    input load,
    input [DATA_WIDTH-1:0] data_in,
    output reg data_out
);
    reg [DATA_WIDTH-1:0] shift_reg;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            shift_reg<='0;
            data_out<='0;
        end
        else if (load) begin
            shift_reg<=data_in;
        end
        else begin
            data_out<=shift_reg[DATA_WIDTH-1];
            shift_reg<={shift_reg[DATA_WIDTH-2:0],1'b0};
        end
    end
    
endmodule

`timescale 1ns/1ps;

module parallel_to_serial_tb #(
    parameter DATA_WIDTH=8
);
    reg clk;
    reg rst_n;
    reg load;
    reg [DATA_WIDTH-1:0] data_in;
    wire data_out;

    parallel_to_serial cut(
        .clk(clk),
        .rst_n(rst_n),
        .load(load),
        .data_in(data_in),
        .data_out(data_out)
    );

    localparam [DATA_WIDTH-1:0] test_pattern=8'b10110100;

    always #5 clk=~clk;
    initial begin
        clk=0;rst_n=0;load=0;data_in=test_pattern;
        #10;
        rst_n=1;
        #10;
        load=1;
        #10;
        load=0;
        #200;
        $finish;
    end
    always @(posedge clk) begin
        $display("Time: %0dns data_out: %b",$time,data_out);
    end
endmodule
