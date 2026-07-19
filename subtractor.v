module subtractor(
	input [3:0] A,B,
	output [3:0] Diff,
	output [3:0] Borrow
);
	assign {Borrow,Diff}=A-B;
	
endmodule

