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

    reg tck;
    reg tms;
    reg trst;

    wire [3:0] state;

    tap_controller dut(
        .tck(tck),
        .tms(tms),
        .trst(trst),
        .state(state)
    );

    always #5 tck = ~tck;

    task check_state;
        input [3:0] expected;
        input [200:0] name;
        begin
            #1;
            if(state == expected)
                $display("PASS : %s (state=%0d)", name, state);
            else
                $display("FAIL : %s Expected=%0d Got=%0d",
                         name, expected, state);
        end
    endtask

    initial begin

        $dumpfile("tap.vcd");
        $dumpvars(0,tap_tb);

        tck  = 0;
        tms  = 0;
        trst = 1;

        //--------------------------------------------------
        // RESET
        //--------------------------------------------------
        #12;
        check_state(0,"TEST_LOGIC_RESET");

        //--------------------------------------------------
        // RUN_TEST_IDLE
        //--------------------------------------------------
        trst = 0;
        #10;
        check_state(1,"RUN_TEST_IDLE");

        //--------------------------------------------------
        // DR PATH
        //--------------------------------------------------
        tms = 1; #10;
        check_state(2,"SELECT_DR_SCAN");

        tms = 0; #10;
        check_state(3,"CAPTURE_DR");

        tms = 0; #10;
        check_state(4,"SHIFT_DR");

        tms = 1; #10;
        check_state(5,"EXIT1_DR");

        tms = 0; #10;
        check_state(6,"PAUSE_DR");

        tms = 1; #10;
        check_state(7,"EXIT2_DR");

        tms = 1; #10;
        check_state(8,"UPDATE_DR");

        tms = 0; #10;
        check_state(1,"RUN_TEST_IDLE");

        //--------------------------------------------------
        // IR PATH
        //--------------------------------------------------
        tms = 1; #10;
        check_state(2,"SELECT_DR_SCAN");

        tms = 1; #10;
        check_state(9,"SELECT_IR_SCAN");

        tms = 0; #10;
        check_state(10,"CAPTURE_IR");

        tms = 0; #10;
        check_state(11,"SHIFT_IR");

        tms = 1; #10;
        check_state(12,"EXIT1_IR");

        tms = 0; #10;
        check_state(13,"PAUSE_IR");

        tms = 1; #10;
        check_state(14,"EXIT2_IR");

        tms = 1; #10;
        check_state(15,"UPDATE_IR");

        tms = 0; #10;
        check_state(1,"RUN_TEST_IDLE");

        //--------------------------------------------------
        // RETURN TO RESET THROUGH TMS=1 PATH
        //--------------------------------------------------
        tms = 1; #10;
        check_state(2,"SELECT_DR_SCAN");

        tms = 1; #10;
        check_state(9,"SELECT_IR_SCAN");

        tms = 1; #10;
        check_state(0,"TEST_LOGIC_RESET");

        $display("\nTAP CONTROLLER TEST COMPLETE\n");

        #10;
        $finish;

    end

endmodule
