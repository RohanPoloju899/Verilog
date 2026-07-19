module ir(
	input tck,trst_n,tdi,capture_ir,shift_ir,update_ir,
	output tdo,
	output reg [3:0] ir
);
	reg [3:0] shift_reg;
	
	assign tdo=shift_reg[0];
	
  always @(posedge tck or negedge trst_n) begin
		if(!trst_n) begin
			shift_reg<=4'b0000;
			ir<=4'b0000;
		end
		else if(capture_ir)
			shift_reg<=4'b0001;
		else if(shift_ir)
			shift_reg<={tdi,shift_reg[3:1]};
		else if(update_ir)
			ir<=shift_reg;
	end
endmodule
			
