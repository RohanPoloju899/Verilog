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




