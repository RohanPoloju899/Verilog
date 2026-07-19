module sequence_detector(
	input clk,
	input rst_n,
	input x,
	output y
);

	parameter s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100;
	
	reg [2:0] state,next_state;
	
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			state<=s0;
		else
			state<=next_state;
	end
	
	always @(*) begin
		case (state)
			s0: next_state =x?s1:s0;
			s1: next_state =x?s1:s2;
			s2: next_state =x?s3:s0;
			s3: next_state =x?s4:s2;
			s4: next_state =x?s1:s2;
			default: next_state=s0;
		endcase
	end
	
	assign y=(state==s4);
endmodule

module sequence_detector_tb;
	reg clk,rst_n,x;
	wire y;
	
	sequence_detector uut(
		.clk(clk),.rst_n(rst_n),.x(x),
		.y(y)
	);
	
	always #5 clk=~clk;
	
	initial begin
		$dumpfile("sequence_detector.vcd");
		$dumpvars(0,sequence_detector_tb);
	end
	
	integer i;
	
	initial begin
		clk=0;
		rst_n=0;
		x=0;
		#10;
		
		rst_n=1;
		for(i=0;i<20;i=i+1) begin
			x=$random%2;
			#10;
		end
		
		$finish;
	end
	
	initial begin
		$monitor("at time:%0t x:%0b y:%0b",$time,x,y); 
	end
endmodule
		
