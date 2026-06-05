module dff (
    input clk,
    input d,
    input rst,
    output reg q
);
    always @(posedge clk or posedge rst) begin
        if(rst) 
            q<=1'b0;
        else
            q<=d;
    end
endmodule

module misr(
    input clk,
    input s0,s1,s2,s3,
    input rst,
    output [3:0] misr_signature
);
    wire w0,w1,w2,w3,w4,w5,w6,w7;

    assign w0=s0^w7;

    dff d0(
        .clk(clk),
        .d(w0),
        .rst(rst),
        .q(w1)
    );
    
    assign w2=s1^w1;

    dff d1(
        .clk(clk),
        .d(w2),
        .rst(rst),
        .q(w3)
    );
    
    assign w4=s2^w3;

    dff d2(
        .clk(clk),
        .d(w4),
        .rst(rst),
        .q(w5)
    );
    
    assign w6=s3^w5^w7;

    dff d3(
        .clk(clk),
        .d(w6),
        .rst(rst),
        .q(w7)
    );

    assign misr_signature={w1,w3,w5,w7};
endmodule

module misr_tb;
    reg clk;
    reg s0,s1,s2,s3;
    reg rst;

    wire [3:0] misr_signature;
    
    misr uut(
        .clk(clk),
        .rst(rst),
        .s0(s0),.s1(s1),.s2(s2),.s3(s3),
        .misr_signature(misr_signature)
    );

    initial begin
        $dumpfile("misr_wave.vcd");
        $dumpvars(0, misr_tb);
    end

    always #5 clk = ~clk;

    integer i;

    reg [7:0] pattern0=8'b10110110;
    reg [7:0] pattern1=8'b11010010;
    reg [7:0] pattern2=8'b11000011;
    reg [7:0] pattern3=8'b10111100;

    initial begin
        clk=0;
        rst=1;
        s0=0;
        s1=0;
        s2=0;
        s3=0;
        #10;

        rst=0;
        for(i=7;i>=0;i=i-1) begin
            s0=pattern0[i];
            s1=pattern1[i];
            s2=pattern2[i];
            s3=pattern3[i];
            #10;
        end

        #180;

        $finish;
    end

    always @(posedge clk)
        $display("t=%0t signature=%b", $time, misr_signature);
endmodule


    
