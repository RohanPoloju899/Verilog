//y=((a&b)^c)|(d|e)
module fault_injection(
    input a,
    input b,
    input c,
    input d,
    input e,
    input fault_enable_g1,
    input fault_select_g1,
    output y
);
    wire G1;
    wire G2;
    wire G4;
    wire temp_G1;
    and(G1,a,b);
    assign temp_G1=fault_enable_g1?(fault_select_g1?1'b0:1'b1):G1;
    xor(G2,temp_G1,c);
    or(G4,d,e);
    or(y,G2,G4);
    
endmodule

module fault_injection_tb();
    reg a;
    reg b;
    reg c;
    reg d;
    reg e;
    reg fault_enable_g1;
    reg fault_select_g1;
    wire y;
    
    fault_injection uut(
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .fault_enable_g1(fault_enable_g1),
        .fault_select_g1(fault_select_g1),
        .y(y)
    );
    
    initial begin
            fault_enable_g1=0;fault_select_g1=0;
            a=0;b=0;c=0;d=0;e=0;
        #10 a=0;b=0;c=1;d=0;e=0;
        #10 a=0;b=1;c=0;d=0;e=0;
        #10 a=0;b=1;c=1;d=0;e=0;
        #10 a=1;b=0;c=0;d=0;e=0;
        #10 a=1;b=0;c=1;d=0;e=0;
        #10 a=1;b=1;c=0;d=0;e=0;
        #10 a=1;b=1;c=1;d=0;e=0;
        
        #10 fault_enable_g1=1;fault_select_g1=0;
            a=0;b=0;c=0;d=0;e=0;
        #10 a=0;b=0;c=1;d=0;e=0;
        #10 a=0;b=1;c=0;d=0;e=0;
        #10 a=0;b=1;c=1;d=0;e=0;
        #10 a=1;b=0;c=0;d=0;e=0;
        #10 a=1;b=0;c=1;d=0;e=0;
        #10 a=1;b=1;c=0;d=0;e=0;
        #10 a=1;b=1;c=1;d=0;e=0;
        
        #10 fault_select_g1=1;
            a=0;b=0;c=0;d=0;e=0;
        #10 a=0;b=0;c=1;d=0;e=0;
        #10 a=0;b=1;c=0;d=0;e=0;
        #10 a=0;b=1;c=1;d=0;e=0;
        #10 a=1;b=0;c=0;d=0;e=0;
        #10 a=1;b=0;c=1;d=0;e=0;
        #10 a=1;b=1;c=0;d=0;e=0;
        #10 a=1;b=1;c=1;d=0;e=0;
        
        #10 $finish;
    end
 endmodule
      
