module latch(
    input clk,
    input D,
    output reg Q
);
    always @(*) begin
        if(clk)
            Q<=D;
    end
endmodule

module lssd(
    input clk0,
    input clk1,
    input A,
    input B,
    output C
);
    wire w0,w1,w2,w3,w4,w5;

    latch l0(
        .clk(clk0),
        .D(A),
        .Q(w0)
    );

    latch l1(
        .clk(clk0),
        .D(B),
        .Q(w1)
    );

    latch l2(
        .clk(clk1),
        .D(w0),
        .Q(w2)
    );

    latch l3(
        .clk(clk1),
        .D(w1),
        .Q(w3)
    );

    assign w4=w2&w3;

    latch l4(
        .clk(clk0),
        .D(w4),
        .Q(w5)
    );

    latch l5(
        .clk(clk1),
        .D(w5),
        .Q(C)
    );
endmodule

    



    