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

`timescale 1ns/1ps;

module full_adder_fault_tb;
    reg A;
    reg B;
    reg Cin;

    reg fault_enable_A;
    reg fault_enable_B;
    reg fault_enable_Cin;
    reg fault_enable_Sum;
    reg fault_enable_Cout;
    
    reg fault_select_A;
    reg fault_select_B;
    reg fault_select_Cin;
    reg fault_select_Sum;
    reg fault_select_Cout;

    wire Sum;
    wire Cout;

    full_adder_fault uut(
        .A(A),
        .B(B),
        .Cin(Cin),

        .fault_enable_A(fault_enable_A),
        .fault_enable_B(fault_enable_B),
        .fault_enable_Cin(fault_enable_Cin),
        .fault_enable_Sum(fault_enable_Sum),
        .fault_enable_Cout(fault_enable_Cout),
        
        .fault_select_A(fault_select_A),
        .fault_select_B(fault_select_B),
        .fault_select_Cin(fault_select_Cin),
        .fault_select_Sum(fault_select_Sum),
        .fault_select_Cout(fault_select_Cout),

        .Sum(Sum),
        .Cout(Cout)
    );

    initial begin
        $dumpfile("full_adder_fault.vcd");
        $dumpvars(0,full_adder_fault_tb);
    end

    initial begin
        fault_enable_A=0;fault_enable_B=0;fault_enable_Cin=0;fault_enable_Sum=0;fault_enable_Cout=0;
        fault_select_A=0;fault_select_B=0;fault_select_Cin=0;fault_select_Sum=0;fault_select_Cout=0;

            A=0;B=0;Cin=0;
        #10 A=0;B=0;Cin=1;
        #10 A=0;B=1;Cin=0;
        #10 A=0;B=1;Cin=1;
        #10 A=1;B=0;Cin=0;
        #10 A=1;B=0;Cin=1;
        #10 A=1;B=1;Cin=0;
        #10 A=1;B=1;Cin=1;

        #10 fault_enable_A=1;fault_select_A=0;

            A=0;B=0;Cin=0;
        #10 A=0;B=0;Cin=1;
        #10 A=0;B=1;Cin=0;
        #10 A=0;B=1;Cin=1;
        #10 A=1;B=0;Cin=0;
        #10 A=1;B=0;Cin=1;
        #10 A=1;B=1;Cin=0;
        #10 A=1;B=1;Cin=1;

        #10 fault_select_A=1;

            A=0;B=0;Cin=0;
        #10 A=0;B=0;Cin=1;
        #10 A=0;B=1;Cin=0;
        #10 A=0;B=1;Cin=1;
        #10 A=1;B=0;Cin=0;
        #10 A=1;B=0;Cin=1;
        #10 A=1;B=1;Cin=0;
        #10 A=1;B=1;Cin=1;

        #10 $finish;
    end
endmodule

