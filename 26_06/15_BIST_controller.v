module bist_controller(

    input clk,
    input rst,
    input start,

    input signature_match,

    output reg scan_en,
    output reg capture_en,
    output reg test_rst,

    output reg done,
    output reg pass

);

parameter IDLE    = 3'd0;
parameter RESET   = 3'd1;
parameter SHIFT   = 3'd2;
parameter CAPTURE = 3'd3;
parameter COMPARE = 3'd4;
parameter DONE    = 3'd5;

reg [2:0] state;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        state <= IDLE;
        done  <= 0;
        pass  <= 0;
    end

    else
    begin
        case(state)

            IDLE:
                if(start)
                    state <= RESET;

            RESET:
                state <= SHIFT;

            SHIFT:
                state <= CAPTURE;

            CAPTURE:
                state <= COMPARE;

            COMPARE:
            begin
                pass  <= signature_match;
                state <= DONE;
            end

            DONE:
                done <= 1;

        endcase
    end
end

always @(*)
begin

    scan_en    = 0;
    capture_en = 0;
    test_rst   = 0;

    case(state)

        RESET:
            test_rst = 1;

        SHIFT:
            scan_en = 1;

        CAPTURE:
            capture_en = 1;

    endcase

end

endmodule

module tb;

reg clk;
reg rst;
reg start;
reg signature_match;

wire scan_en;
wire capture_en;
wire test_rst;
wire done;
wire pass;

bist_controller dut(
    .clk(clk),
    .rst(rst),
    .start(start),
    .signature_match(signature_match),
    .scan_en(scan_en),
    .capture_en(capture_en),
    .test_rst(test_rst),
    .done(done),
    .pass(pass)
);

always #5 clk = ~clk;

initial
begin

    clk = 0;
    rst = 1;
    start = 0;
    signature_match = 0;

    #10 rst = 0;

    //--------------------------------
    // PASS CASE
    //--------------------------------

    signature_match = 1;

    start = 1;
    #10;
    start = 0;

    #60;

    $display("PASS TEST");
    $display("done=%b pass=%b",done,pass);

    //--------------------------------
    // RESET
    //--------------------------------

    rst = 1;
    #10;
    rst = 0;

    //--------------------------------
    // FAIL CASE
    //--------------------------------

    signature_match = 0;

    start = 1;
    #10;
    start = 0;

    #60;

    $display("FAIL TEST");
    $display("done=%b pass=%b",done,pass);

    #20;
    $finish;

end

always @(posedge clk)
begin
    $display("time=%0t scan=%b capture=%b reset=%b done=%b pass=%b",
             $time,
             scan_en,
             capture_en,
             test_rst,
             done,
             pass);
end

endmodule
