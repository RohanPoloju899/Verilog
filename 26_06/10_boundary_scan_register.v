module boundary_scan_register #(
    parameter N = 4
)(
    input clk,
    input rst,

    input capture_en,
    input shift_en,
    input update_en,

    input tdi,
    output tdo,

    input  [N-1:0] pin_in,
    output reg [N-1:0] pin_out
);

reg [N-1:0] bsr;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        bsr <= 0;
        pin_out <= 0;
    end

    else if(capture_en)
    begin
        bsr <= pin_in;
    end

    else if(shift_en)
    begin
        bsr <= {tdi, bsr[N-1:1]};
    end

    else if(update_en)
    begin
        pin_out <= bsr;
    end
end

assign tdo = bsr[0];

endmodule

module tb;

reg clk;
reg rst;

reg capture_en;
reg shift_en;
reg update_en;

reg tdi;

reg [3:0] pin_in;

wire [3:0] pin_out;
wire tdo;

boundary_scan_register dut(
    .clk(clk),
    .rst(rst),
    .capture_en(capture_en),
    .shift_en(shift_en),
    .update_en(update_en),
    .tdi(tdi),
    .tdo(tdo),
    .pin_in(pin_in),
    .pin_out(pin_out)
);

always #5 clk = ~clk;

initial
begin

    clk = 0;
    rst = 1;

    capture_en = 0;
    shift_en = 0;
    update_en = 0;

    #10 rst = 0;

    //----------------------------------
    // CAPTURE
    //----------------------------------
    pin_in = 4'b1010;

    capture_en = 1;
    #10;
    capture_en = 0;

    $display("Captured pin values");

    //----------------------------------
    // SHIFT
    //----------------------------------

    shift_en = 1;

    tdi = 1; #10;
    $display("TDO=%b",tdo);

    tdi = 1; #10;
    $display("TDO=%b",tdo);

    tdi = 0; #10;
    $display("TDO=%b",tdo);

    tdi = 0; #10;
    $display("TDO=%b",tdo);

    shift_en = 0;

    //----------------------------------
    // UPDATE
    //----------------------------------

    update_en = 1;
    #10;
    update_en = 0;

    $display("Pin_out = %b",pin_out);

    #20;
    $finish;

end

endmodule
