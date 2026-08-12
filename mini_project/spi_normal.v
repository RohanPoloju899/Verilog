`timescale 1ns/1ps

//==================================================
// NORMAL SPI MASTER - NO CLOCK GATING
// SPI MODE 0
//
// Rising edge  : sample MISO
// Falling edge : change MOSI
//==================================================

module spi_normal
#(
    parameter IDLE_CYCLES = 3
)
(
    input  wire       clk,
    input  wire       reset,
    input  wire       start,
    input  wire [7:0] tx_data,
    input  wire       miso,

    output reg        mosi,
    output reg [7:0]  rx_data,

    output reg        busy,
    output reg        done,
    output reg        cs
);

reg [7:0] tx_shift;
reg [7:0] rx_shift;

reg [3:0] bit_count;

reg transaction_done;


//==================================================
// SPI MASTER
//==================================================

// Rising edge: SAMPLE MISO
always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        tx_shift <= 0;
        rx_shift <= 0;
        rx_data <= 0;

        bit_count <= 0;

        mosi <= 0;

        busy <= 0;
        done <= 0;
        cs <= 1;

        transaction_done <= 0;
    end

    else
    begin
        done <= 0;

        // Start transaction
        if (start && !busy)
        begin
            tx_shift <= tx_data;
            rx_shift <= 0;

            bit_count <= 0;

            // First MOSI bit is available before
            // the first rising edge
            mosi <= tx_data[7];

            busy <= 1;
            cs <= 0;

            transaction_done <= 0;
        end

        // Receive data on rising edge
        else if (busy)
        begin
            rx_shift <= {rx_shift[6:0], miso};

            if (bit_count == 7)
            begin
                rx_data <= {rx_shift[6:0], miso};

                busy <= 0;
                done <= 1;

                cs <= 1;

                transaction_done <= 1;
            end

            else
            begin
                bit_count <= bit_count + 1;
            end
        end
    end
end


//==================================================
// MOSI CHANGES ON FALLING EDGE
//==================================================

always @(negedge clk or posedge reset)
begin
    if (reset)
    begin
        mosi <= 0;
        tx_shift <= 0;
    end

    else if (busy)
    begin
        tx_shift <= {tx_shift[6:0], 1'b0};

        mosi <= tx_shift[6];
    end
end

endmodule


//==================================================
// SPI SLAVE MODEL
//==================================================

module spi_slave_model
(
    input  wire clk,
    input  wire reset,
    input  wire cs,
    input  wire mosi,

    output reg miso
);

reg [7:0] rx_shift;
reg [7:0] slave_tx;
reg [3:0] bit_count;


//==================================================
// Slave response
//==================================================

initial
begin
    slave_tx = 8'b1100_0011;
end


//==================================================
// Rising edge: SAMPLE MOSI
//==================================================

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        rx_shift <= 0;
        bit_count <= 0;
    end

    else if (!cs)
    begin
        rx_shift <= {rx_shift[6:0], mosi};

        if (bit_count < 8)
            bit_count <= bit_count + 1;
    end
end


//==================================================
// Falling edge: CHANGE MISO
//==================================================

always @(negedge clk or posedge reset)
begin
    if (reset)
    begin
        miso <= 0;
    end

    else if (!cs)
    begin
        if (bit_count < 8)
            miso <= slave_tx[7-bit_count];
        else
            miso <= 0;
    end

    else
    begin
        miso <= 0;
    end
end

endmodule


//==================================================
// TESTBENCH
//==================================================

module tb_spi_normal;

reg clk;
reg reset;
reg start;

reg [7:0] tx_data;

wire mosi;
wire miso;

wire [7:0] rx_data;

wire busy;
wire done;
wire cs;


//==================================================
// DUT
//==================================================

spi_normal dut
(
    .clk(clk),
    .reset(reset),
    .start(start),
    .tx_data(tx_data),
    .miso(miso),

    .mosi(mosi),
    .rx_data(rx_data),

    .busy(busy),
    .done(done),
    .cs(cs)
);


//==================================================
// SPI SLAVE
//==================================================

spi_slave_model slave
(
    .clk(clk),
    .reset(reset),
    .cs(cs),
    .mosi(mosi),

    .miso(miso)
);


//==================================================
// SYSTEM CLOCK
//==================================================

initial
begin
    clk = 0;

    forever
        #5 clk = ~clk;
end


//==================================================
// TEST SEQUENCE
//==================================================

initial
begin

    reset = 1;
    start = 0;
    tx_data = 8'b1010_1100;

    #20;

    reset = 0;


    //==============================================
    // FIRST TRANSACTION
    //==============================================

    #10;

    start = 1;

    #10;

    start = 0;


    // Wait for transfer
    #150;


    //==============================================
    // SECOND TRANSACTION
    //==============================================

    tx_data = 8'b0101_0011;

    start = 1;

    #10;

    start = 0;


    #150;

    $finish;

end


//==================================================
// WAVEFORM
//==================================================

/*initial
begin
    $dumpfile("spi_normal.vcd");

    $dumpvars(0, tb_spi_normal);
end*/

endmodule
