`timescale 1ns/1ps;

module nand_fault(
    input wire A,
    input wire B,

    input wire enable_fault_A,
    input wire enable_fault_B,
    input wire enable_fault_Y,

    input wire select_fault_A,
    input wire select_fault_B,
    input wire select_fault_Y,

    output wire Y
);

    wire A_temp;
    wire B_temp;
    wire Y_temp;

    assign A_temp=enable_fault_A?(select_fault_A?1'b1:1'b0):A;
    assign B_temp=enable_fault_B?(select_fault_B?1'b1:1'b0):B;

    assign Y_temp=~(A_temp&B_temp);

    assign Y=enable_fault_Y?(select_fault_Y?1'b1:1'b0):Y_temp;

endmodule



module nand_fault_tb;

    reg A;
    reg B;

    reg enable_fault_A;
    reg enable_fault_B;
    reg enable_fault_Y;

    reg select_fault_A;
    reg select_fault_B;
    reg select_fault_Y;

    wire Y;

    nand_fault uut(
        .A(A),
        .B(B),

        .enable_fault_A(enable_fault_A),
        .enable_fault_B(enable_fault_B),
        .enable_fault_Y(enable_fault_Y),

        .select_fault_A(select_fault_A),
        .select_fault_B(select_fault_B),
        .select_fault_Y(select_fault_Y),

        .Y(Y)
    );

    initial begin
        $dumpfile("nand_fault.vcd");
        $dumpvars(0,nand_fault_tb);
    end

    initial begin 
        A=0;B=0;
        enable_fault_A=0;enable_fault_B=0;enable_fault_Y=0;
        select_fault_A=0;select_fault_B=0;select_fault_Y=0;

            A=0;B=0;
        #10 A=0;B=1;
        #10 A=1;B=0;
        #10 A=1;B=1;
        
        #10 enable_fault_A=1;select_fault_A=0; //simulating A stuck at 0

            A=0;B=0;
        #10 A=0;B=1;
        #10 A=1;B=0;
        #10 A=1;B=1;

        #10 select_fault_A=1; //simulating A stuck at 1

            A=0;B=0;
        #10 A=0;B=1;
        #10 A=1;B=0;
        #10 A=1;B=1;

        #10 $finish;
    end
endmodule

    
