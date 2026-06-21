module tap_controller(
    input tck,
    input tms,
    input trst,
    output reg [3:0] state
);

    parameter TEST_LOGIC_RESET = 4'd0,
              RUN_TEST_IDLE    = 4'd1,
              SELECT_DR_SCAN   = 4'd2,
              CAPTURE_DR       = 4'd3,
              SHIFT_DR         = 4'd4,
              EXIT1_DR         = 4'd5,
              PAUSE_DR         = 4'd6,
              EXIT2_DR         = 4'd7,
              UPDATE_DR        = 4'd8,
              SELECT_IR_SCAN   = 4'd9,
              CAPTURE_IR       = 4'd10,
              SHIFT_IR         = 4'd11,
              EXIT1_IR         = 4'd12,
              PAUSE_IR         = 4'd13,
              EXIT2_IR         = 4'd14,
              UPDATE_IR        = 4'd15;

    always @(posedge tck or posedge trst) begin
        if(trst)
            state <= TEST_LOGIC_RESET;
        else begin
            case(state)

            TEST_LOGIC_RESET:
                state <= tms ? TEST_LOGIC_RESET : RUN_TEST_IDLE;

            RUN_TEST_IDLE:
                state <= tms ? SELECT_DR_SCAN : RUN_TEST_IDLE;

            SELECT_DR_SCAN:
                state <= tms ? SELECT_IR_SCAN : CAPTURE_DR;

            CAPTURE_DR:
                state <= tms ? EXIT1_DR : SHIFT_DR;

            SHIFT_DR:
                state <= tms ? EXIT1_DR : SHIFT_DR;

            EXIT1_DR:
                state <= tms ? UPDATE_DR : PAUSE_DR;

            PAUSE_DR:
                state <= tms ? EXIT2_DR : PAUSE_DR;

            EXIT2_DR:
                state <= tms ? UPDATE_DR : SHIFT_DR;

            UPDATE_DR:
                state <= tms ? SELECT_DR_SCAN : RUN_TEST_IDLE;

            SELECT_IR_SCAN:
                state <= tms ? TEST_LOGIC_RESET : CAPTURE_IR;

            CAPTURE_IR:
                state <= tms ? EXIT1_IR : SHIFT_IR;

            SHIFT_IR:
                state <= tms ? EXIT1_IR : SHIFT_IR;

            EXIT1_IR:
                state <= tms ? UPDATE_IR : PAUSE_IR;

            PAUSE_IR:
                state <= tms ? EXIT2_IR : PAUSE_IR;

            EXIT2_IR:
                state <= tms ? UPDATE_IR : SHIFT_IR;

            UPDATE_IR:
                state <= tms ? SELECT_DR_SCAN : RUN_TEST_IDLE;

            default:
                state <= TEST_LOGIC_RESET;

            endcase
        end
    end

endmodule

`timescale 1ns/1ps

module tap_tb;

    reg tck=0, tms=0, trst=1;
    wire [3:0] state;

    tap_controller dut (
        .tck(tck),
        .tms(tms),
        .trst(trst),
        .state(state)
    );

    always #5 tck = ~tck;

    task step;
        input t;
        input [3:0] exp;
        begin
            tms = t;
            @(posedge tck);
            #1;
            $display("%s state=%0d",
                     (state==exp) ? "PASS" : "FAIL",
                     state);
        end
    endtask

    initial begin
        $dumpfile("tap.vcd");
        $dumpvars(0,tap_tb);

        // Reset
        @(posedge tck);
        #1;
        trst = 0;

        // DR path
        step(0,1);  // RTI
        step(1,2);  // Select DR
        step(0,3);  // Capture DR
        step(0,4);  // Shift DR
        step(1,5);  // Exit1 DR
        step(0,6);  // Pause DR
        step(1,7);  // Exit2 DR
        step(1,8);  // Update DR
        step(0,1);  // RTI

        // IR path
        step(1,2);   // Select DR
        step(1,9);   // Select IR
        step(0,10);  // Capture IR
        step(0,11);  // Shift IR
        step(1,12);  // Exit1 IR
        step(0,13);  // Pause IR
        step(1,14);  // Exit2 IR
        step(1,15);  // Update IR
        step(0,1);   // RTI

        // Back to reset
        step(1,2);
        step(1,9);
        step(1,0);

        $finish;
    end

endmodule

endmodule
