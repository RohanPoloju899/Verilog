module lfsr #(
	parameter N=8
)(
	input clk,
	input rst_n,
	output reg [N-1:0] q
);
	reg [26:0] count=0;
	reg clk1hz=0;
	always @(posedge clk) begin
		if(count==49_999_999) begin
			count<=0;
			clk1hz<=~clk1hz;
		end
		else 
			count<=count+1;
	end

	wire feedback;
	assign feedback=q[N-1]^q[5]^q[4]^q[3];
	
	always @(posedge clk1hz or negedge rst_n) begin
		if(!rst_n) 
			q<=8'b00000001;
		else
			q<={feedback,q[N-1:1]};
	end
endmodule

set_property -dict{PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {clk}];
set_property -dict{PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {q[7]}];
set_property -dict{PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {q[6]}];
set_property -dict{PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {q[5]}];
set_property -dict{PACKAGE_PIN B3 IOSTANDARD LVCMOS33} [get_ports {q[4]}];
set_property -dict{PACKAGE_PIN A2 IOSTANDARD LVCMOS33} [get_ports {q[3]}];
set_property -dict{PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports {q[2]}];
set_property -dict{PACKAGE_PIN C3 IOSTANDARD LVCMOS33} [get_ports {q[1]}];
set_property -dict{PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports {q[0]}];


