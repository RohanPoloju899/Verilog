`timescale 1ns / 1ps

module random_test(
    input A, B, Cin,
    output Sum, Cout
);
    assign Sum  = A ^ B ^ Cin;
    assign Cout = (A & B) | (B & Cin) | (A & Cin);
endmodule

module random_test_tb;
    reg A, B, Cin;
    wire Sum, Cout;
    
    random_test uut (
        .A(A), .B(B), .Cin(Cin), .Sum(Sum), .Cout(Cout)
    );
    
    reg exp_Sum, exp_Cout;
    integer i;

    reg error;

    always @(*) begin
        error = (Sum !== exp_Sum) || (Cout !== exp_Cout);
    end
    
    initial begin
        for (i = 0; i < 20; i = i + 1) begin
            A   = $random % 2;
            B   = $random % 2;
            Cin = $random % 2;
    
            exp_Sum  = A ^ B ^ Cin;
            exp_Cout = (A & B) | (B & Cin) | (A & Cin);

            #5;
        end
        $finish;
    end
endmodule
