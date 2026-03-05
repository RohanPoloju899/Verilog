module full_adder_fault(
    input A,
    input B,
    input Cin,

    input fault_enable_A,
    input fault_enable_B,
    input fault_enable_Cin,
    input fault_enable_Sum,
    input fault_enable_Cout,
    
    input fault_select_A,
    input fault_select_B,
    input fault_select_Cin,
    input fault_select_Sum,
    input fault_select_Cout,

    output Sum,
    output Cout
);
    wire A_faulty;
    wire B_faulty;
    wire Cin_faulty;

    wire Sum_normal;
    wire Cout_normal;

    assign A_faulty=fault_enable_A?(fault_select_A?1'b1:1'b0):A;
    assign B_faulty=fault_enable_B?(fault_select_B?1'b1:1'b0):B;
    assign Cin_faulty=fault_enable_Cin?(fault_select_Cin?1'b1:1'b0):Cin;

    assign Sum_normal=A_faulty^B_faulty^Cin_faulty;
    assign Cout_normal=(A_faulty&B_faulty)|(Cin_faulty&(A_faulty|B_faulty));

    assign Sum=fault_enable_Sum?(fault_select_Sum?1'b1:1'b0):Sum_normal;
    assign Cout=fault_enable_Cout?(fault_select_Cout?1'b1:1'b0):Cout_normal;
endmodule

