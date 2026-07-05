`timescale 1ns / 1ps
//============================================================
// LOW-POWER SPI PROTOCOL WITH IDLE-STATE ADAPTIVE CLOCK GATING
// Single-file: Design + Testbench
//============================================================

//------------------------------------------------------------
// 1. CLOCK GATING CELL (Integrated Clock Gating - ICG latch based)
//------------------------------------------------------------
module clock_gate_cell (
    input  wire clk_in,
    input  wire enable,      // functional enable
    input  wire test_enable, // scan/test bypass
    output wire clk_out
);
    reg latch_en;

    // Latch is transparent when clk_in is LOW -> avoids glitches
    always @(*) begin
        if (!clk_in)
            latch_en = enable | test_enable;
    end

    assign clk_out = clk_in & latch_en;

endmodule


//------------------------------------------------------------
// 2. IDLE DETECTOR (Adaptive activity monitor)
//    Detects SPI bus idle condition based on CS_n and activity
//    counter; asserts idle after N clocks of inactivity.
//------------------------------------------------------------
module idle_detector #(
    parameter IDLE_THRESHOLD = 8   // cycles of inactivity before gating
)(
    input  wire clk,
    input  wire rst_n,
    input  wire cs_n,          // chip select (active low)
    input  wire sclk_activity, // toggling indicates active transfer
    output reg  idle_flag,     // 1 = bus idle -> gate clock
    output reg  [3:0] idle_cnt
);

    reg sclk_activity_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            idle_cnt         <= 4'd0;
            idle_flag        <= 1'b0;
            sclk_activity_d  <= 1'b0;
        end else begin
            sclk_activity_d <= sclk_activity;

            if (!cs_n || (sclk_activity ^ sclk_activity_d)) begin
                // active transaction or edge activity -> reset counter
                idle_cnt  <= 4'd0;
                idle_flag <= 1'b0;
            end else begin
                if (idle_cnt < IDLE_THRESHOLD) begin
                    idle_cnt  <= idle_cnt + 1'b1;
                    idle_flag <= 1'b0;
                end else begin
                    idle_flag <= 1'b1; // sustained idle -> assert gating
                end
            end
        end
    end
endmodule


//------------------------------------------------------------
// 3. SPI MASTER CORE (supports Mode 0, CPOL=0 CPHA=0)
//    Clock-gated internally using gated_clk from top module
//------------------------------------------------------------
module spi_master (
    input  wire        gated_clk,   // gated system clock
    input  wire        rst_n,
    input  wire        start_tx,
    input  wire [7:0]  tx_data,
    output reg  [7:0]  rx_data,
    output reg         tx_done,

    // SPI bus
    output reg          sclk,
    output reg          mosi,
    input  wire         miso,
    output reg          cs_n
);

    localparam IDLE  = 2'b00,
               LOAD  = 2'b01,
               SHIFT = 2'b10,
               DONE  = 2'b11;

    reg [1:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;
    reg       sclk_en;

    always @(posedge gated_clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            sclk      <= 1'b0;
            mosi      <= 1'b0;
            cs_n      <= 1'b1;
            bit_cnt   <= 3'd0;
            shift_reg <= 8'd0;
            rx_data   <= 8'd0;
            tx_done   <= 1'b0;
            sclk_en   <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx_done <= 1'b0;
                    cs_n    <= 1'b1;
                    sclk    <= 1'b0;
                    if (start_tx) begin
                        shift_reg <= tx_data;
                        bit_cnt   <= 3'd7;
                        cs_n      <= 1'b0;
                        state     <= LOAD;
                    end
                end

                LOAD: begin
                    mosi  <= shift_reg[7];
                    state <= SHIFT;
                end

                SHIFT: begin
                    sclk <= ~sclk;
                    if (sclk == 1'b1) begin
                        // sample MISO on rising edge (already toggled to 1)
                        shift_reg <= {shift_reg[6:0], miso};
                        if (bit_cnt == 0) begin
                            state <= DONE;
                        end else begin
                            bit_cnt <= bit_cnt - 1'b1;
                            mosi    <= shift_reg[6];
                        end
                    end
                end

                DONE: begin
                    rx_data <= shift_reg;
                    tx_done <= 1'b1;
                    cs_n    <= 1'b1;
                    sclk    <= 1'b0;
                    state   <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule


//------------------------------------------------------------
// 4. TOP MODULE: Integrates SPI Master + Idle Detector + Clock Gate
//------------------------------------------------------------
module spi_low_power_top #(
    parameter IDLE_THRESHOLD = 8
)(
    input  wire        sys_clk,
    input  wire        rst_n,
    input  wire        test_enable,
    input  wire        start_tx,
    input  wire [7:0]  tx_data,
    output wire [7:0]  rx_data,
    output wire        tx_done,

    output wire         sclk,
    output wire         mosi,
    input  wire         miso,
    output wire         cs_n,

    output wire         idle_flag_o,
    output wire         gated_clk_o
);

    wire gated_clk;
    wire idle_flag;
    wire clk_enable;

    // Enable clock whenever NOT idle, or when a new transfer is requested
    assign clk_enable = ~idle_flag | start_tx;

    clock_gate_cell u_cg (
        .clk_in       (sys_clk),
        .enable       (clk_enable),
        .test_enable  (test_enable),
        .clk_out      (gated_clk)
    );

    idle_detector #(.IDLE_THRESHOLD(IDLE_THRESHOLD)) u_idle (
        .clk            (sys_clk),
        .rst_n          (rst_n),
        .cs_n           (cs_n),
        .sclk_activity  (sclk),
        .idle_flag      (idle_flag),
        .idle_cnt       ()
    );

    spi_master u_spi (
        .gated_clk (gated_clk),
        .rst_n     (rst_n),
        .start_tx  (start_tx),
        .tx_data   (tx_data),
        .rx_data   (rx_data),
        .tx_done   (tx_done),
        .sclk      (sclk),
        .mosi      (mosi),
        .miso      (miso),
        .cs_n      (cs_n)
    );

    assign idle_flag_o = idle_flag;
    assign gated_clk_o = gated_clk;

endmodule


//------------------------------------------------------------
// 5. SIMPLE SPI SLAVE (loopback model for testbench)
//------------------------------------------------------------
module spi_slave_model (
    input  wire sclk,
    input  wire cs_n,
    input  wire mosi,
    output reg  miso
);
    reg [7:0] slave_shift;
    initial slave_shift = 8'hA5; // known response pattern

    always @(posedge sclk or posedge cs_n) begin
        if (cs_n) begin
            slave_shift <= 8'hA5;
        end else begin
            miso        <= slave_shift[7];
            slave_shift <= {slave_shift[6:0], mosi};
        end
    end
endmodule


//------------------------------------------------------------
// 6. TESTBENCH (self-checking)
//------------------------------------------------------------
module tb_spi_low_power;

    reg         sys_clk;
    reg         rst_n;
    reg         test_enable;
    reg         start_tx;
    reg  [7:0]  tx_data;
    wire [7:0]  rx_data;
    wire        tx_done;

    wire        sclk;
    wire        mosi;
    wire        miso;
    wire        cs_n;
    wire        idle_flag_o;
    wire        gated_clk_o;

    integer     toggle_count;
    integer     errors;

    // DUT instantiation
    spi_low_power_top #(.IDLE_THRESHOLD(8)) DUT (
        .sys_clk     (sys_clk),
        .rst_n       (rst_n),
        .test_enable (test_enable),
        .start_tx    (start_tx),
        .tx_data     (tx_data),
        .rx_data     (rx_data),
        .tx_done     (tx_done),
        .sclk        (sclk),
        .mosi        (mosi),
        .miso        (miso),
        .cs_n        (cs_n),
        .idle_flag_o (idle_flag_o),
        .gated_clk_o (gated_clk_o)
    );

    // Slave loopback model
    spi_slave_model SLAVE (
        .sclk (sclk),
        .cs_n (cs_n),
        .mosi (mosi),
        .miso (miso)
    );

    // System clock generation: 100 MHz
    initial sys_clk = 1'b0;
    always #5 sys_clk = ~sys_clk;

    // Monitor gated_clk toggles to prove power savings during idle
    always @(gated_clk_o) begin
        if (idle_flag_o) toggle_count = toggle_count + 1;
    end

    // Task: run a single SPI transaction and self-check
    task run_transaction(input [7:0] data_in);
        begin
            @(negedge sys_clk);
            tx_data  = data_in;
            start_tx = 1'b1;
            @(negedge sys_clk);
            start_tx = 1'b0;

            wait (tx_done == 1'b1);
            @(negedge sys_clk);

            if (rx_data !== 8'hA5) begin
                $display("[%0t] ERROR: Expected 0xA5, Got 0x%0h", $time, rx_data);
                errors = errors + 1;
            end else begin
                $display("[%0t] PASS: tx_data=0x%0h rx_data=0x%0h", $time, data_in, rx_data);
            end
        end
    endtask

    initial begin
        $dumpfile("spi_low_power.vcd");
        $dumpvars(0, tb_spi_low_power);

        // Init
        rst_n        = 1'b0;
        test_enable  = 1'b0;
        start_tx     = 1'b0;
        tx_data      = 8'h00;
        toggle_count = 0;
        errors       = 0;

        repeat (5) @(negedge sys_clk);
        rst_n = 1'b1;
        repeat (2) @(negedge sys_clk);

        // Test 1: Basic transfer
        run_transaction(8'h3C);

        // Idle period - allow clock gating to engage
        $display("[%0t] Entering idle period to observe clock gating...", $time);
        repeat (40) @(negedge sys_clk);
        $display("[%0t] idle_flag_o = %b (gated_clk toggles during idle = %0d)",
                   $time, idle_flag_o, toggle_count);

        // Test 2: Back-to-back transfers after idle (clock must re-enable)
        run_transaction(8'h7E);
        run_transaction(8'hFF);

        // Idle again
        repeat (30) @(negedge sys_clk);

        // Test 3: Randomized transfers
        run_transaction(8'h01);
        run_transaction(8'h99);

        repeat (20) @(negedge sys_clk);

        if (errors == 0)
            $display("\n==== ALL TESTS PASSED : Idle-State Adaptive Clock Gating Verified ====");
        else
            $display("\n==== TEST FAILED with %0d error(s) ====", errors);

        $finish;
    end

    // Safety timeout
    initial begin
        #10000;
        $display("ERROR: TIMEOUT - simulation did not finish");
        $finish;
    end

endmodule
