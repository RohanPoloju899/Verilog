module boundary_scan(

    input clk,
    input rst,

    input [2:0] instruction,

    input [7:0] data_in,

    output reg [7:0] data_out

);

parameter BYPASS = 3'b000;
parameter EXTEST = 3'b001;
parameter SAMPLE = 3'b010;
parameter INTEST = 3'b011;
parameter IDCODE = 3'b100;

reg [7:0] boundary_reg;
reg [7:0] internal_reg;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        boundary_reg <= 8'h00;
        internal_reg <= 8'h00;
        data_out <= 8'h00;
    end

    else
    begin
        case(instruction)

            BYPASS:
                data_out <= data_in;

            EXTEST:
            begin
                boundary_reg <= data_in;
                data_out <= boundary_reg;
            end

            SAMPLE:
                data_out <= data_in;

            INTEST:
            begin
                internal_reg <= data_in + 1;
                data_out <= internal_reg;
            end

            IDCODE:
                data_out <= 8'hA5;

            default:
                data_out <= 8'h00;

        endcase
    end
end

endmodule

module tb;

reg clk;
reg rst;

reg [2:0] instruction;
reg [7:0] data_in;

wire [7:0] data_out;

boundary_scan dut(
    .clk(clk),
    .rst(rst),
    .instruction(instruction),
    .data_in(data_in),
    .data_out(data_out)
);

always #5 clk = ~clk;

initial
begin

    clk = 0;
    rst = 1;

    #10;
    rst = 0;

    //---------------------------------
    // BYPASS
    //---------------------------------
    instruction = 3'b000;
    data_in = 8'h12;

    #10;
    $display("BYPASS : data_out=%h",data_out);

    //---------------------------------
    // EXTEST
    //---------------------------------
    instruction = 3'b001;
    data_in = 8'h34;

    #10;
    $display("EXTEST : data_out=%h",data_out);

    //---------------------------------
    // SAMPLE
    //---------------------------------
    instruction = 3'b010;
    data_in = 8'h56;

    #10;
    $display("SAMPLE : data_out=%h",data_out);

    //---------------------------------
    // INTEST
    //---------------------------------
    instruction = 3'b011;
    data_in = 8'h78;

    #10;
    $display("INTEST : data_out=%h",data_out);

    //---------------------------------
    // IDCODE
    //---------------------------------
    instruction = 3'b100;
    data_in = 8'h00;

    #10;
    $display("IDCODE : data_out=%h",data_out);

    #20;
    $finish;

end

endmodule
