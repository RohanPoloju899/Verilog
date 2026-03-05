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
