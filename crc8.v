module crc8_gen (
    input  wire [7:0] data_in,
    output reg  [7:0] crc_out
);

    integer i;
    reg [15:0] dividend;

    always @(*) begin
        dividend = {data_in, 8'b0};   // Append 8 zeros

        for (i = 15; i >= 8; i = i - 1)
            if (dividend[i])
                dividend[i -: 9] = dividend[i -: 9] ^ 9'b100000111;

        crc_out = dividend[7:0];
    end

endmodule

module crc8_top (
    input  wire SW0, SW1, SW2, SW3,
    input  wire SW4, SW5, SW6, SW7,

    output wire LED0, LED1, LED2, LED3,
    output wire LED4, LED5, LED6, LED7
);

    wire [7:0] data_in;
    wire [7:0] crc_out;

    // Combine individual inputs into an 8-bit bus
    assign data_in = {SW7, SW6, SW5, SW4, SW3, SW2, SW1, SW0};

    crc8_gen U1 (
        .data_in(data_in),
        .crc_out(crc_out)
    );

    // Split CRC output bus into individual outputs
    assign {LED7, LED6, LED5, LED4, LED3, LED2, LED1, LED0} = crc_out;

endmodule

`timescale 1ns/1ps

module crc8_tb;

    reg SW0, SW1, SW2, SW3;
    reg SW4, SW5, SW6, SW7;

    wire LED0, LED1, LED2, LED3;
    wire LED4, LED5, LED6, LED7;

    // Instantiate DUT
    crc8_top uut (
        .SW0(SW0), .SW1(SW1), .SW2(SW2), .SW3(SW3),
        .SW4(SW4), .SW5(SW5), .SW6(SW6), .SW7(SW7),

        .LED0(LED0), .LED1(LED1), .LED2(LED2), .LED3(LED3),
        .LED4(LED4), .LED5(LED5), .LED6(LED6), .LED7(LED7)
    );

    initial begin
        $dumpfile("crc8.vcd");
        $dumpvars(0, crc8_tb);

        // Initial input = 0
        {SW7, SW6, SW5, SW4, SW3, SW2, SW1, SW0} = 8'b00000000;

        #5;

        // Apply input at 5 ns
        {SW7, SW6, SW5, SW4, SW3, SW2, SW1, SW0} = 8'b10111011;

        #5;

        // Observe output until 10 ns
        $finish;
    end

endmodule




























module crc8_gen (
    input  wire [7:0] data_in,
    output reg  [7:0] crc_out
);

    integer i;
    reg [15:0] dividend;

    always @(*) begin
        dividend = {data_in, 8'b0};

        for (i = 15; i >= 8; i = i - 1)
            if (dividend[i])
                dividend[i -: 9] = dividend[i -: 9] ^ 9'b100000111;

        crc_out = dividend[7:0];
    end

endmodule


module crc8_top (
    input  wire SW0, SW1, SW2, SW3,
    input  wire SW4, SW5, SW6, SW7,

    input  wire fault_en,
    input  wire [2:0] fault_sel,

    output wire LED0, LED1, LED2, LED3,
    output wire LED4, LED5, LED6, LED7
);

    wire [7:0] data_in;
    wire [7:0] crc_out;
    reg  [7:0] led_out;

    assign data_in = {SW7, SW6, SW5, SW4, SW3, SW2, SW1, SW0};

    crc8_gen U1 (
        .data_in(data_in),
        .crc_out(crc_out)
    );

    always @(*) begin
        led_out = crc_out;

        if (fault_en)
            led_out[fault_sel] = ~crc_out[fault_sel];
    end

    assign {LED7, LED6, LED5, LED4, LED3, LED2, LED1, LED0} = led_out;

endmodule

`timescale 1ns/1ps

module crc8_tb;

    reg SW0, SW1, SW2, SW3;
    reg SW4, SW5, SW6, SW7;

    reg fault_en;
    reg [2:0] fault_sel;

    wire LED0, LED1, LED2, LED3;
    wire LED4, LED5, LED6, LED7;

    // Instantiate DUT
    crc8_top uut (
        .SW0(SW0), .SW1(SW1), .SW2(SW2), .SW3(SW3),
        .SW4(SW4), .SW5(SW5), .SW6(SW6), .SW7(SW7),

        .fault_en(fault_en),
        .fault_sel(fault_sel),

        .LED0(LED0), .LED1(LED1), .LED2(LED2), .LED3(LED3),
        .LED4(LED4), .LED5(LED5), .LED6(LED6), .LED7(LED7)
    );

    initial begin
        $dumpfile("crc8.vcd");
        $dumpvars(0, crc8_tb);

        // Initial values
        {SW7,SW6,SW5,SW4,SW3,SW2,SW1,SW0} = 8'b00000000;
        fault_en  = 1'b0;
        fault_sel = 3'd0;

        #5;

        // Normal operation
        {SW7,SW6,SW5,SW4,SW3,SW2,SW1,SW0} = 8'b10111011;

        #10;

        // Inject fault on LED3
        fault_en  = 1'b1;
        fault_sel = 3'd3;

        #10;

        // Disable fault
        fault_en = 1'b0;

        #10;

        $finish;
    end

endmodule

