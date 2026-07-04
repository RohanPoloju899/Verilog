`timescale 1ns/1ps;
module lfsr (
	input clk,
	input rst_n,
	output reg [7:0] q
);
	/*reg [26:0] count=0;
	reg clk1hz=0;
	
	always @(posedge clk) begin
		if(count==49_999_999) begin
			count<=0;
			clk1hz<=~clk1hz;
		end
		else 
			count<=count+1;
	end*/

	wire feedback;
	assign feedback=q[7]^q[5]^q[4]^q[3];
	
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) 
			q<=8'b00000001;
		else
			q<={q[6:0],feedback};
	end
endmodule

module lfsr_tb();
    reg clk;
	reg rst_n;
	wire [7:0] q;
	
	lfsr uut(
	   .clk(clk),
	   .rst_n(rst_n),
	   .q(q)
	);
	
	always #5 clk=~clk;
	
	initial begin
	   clk=1;rst_n=0;
	   #10;
	   rst_n=1;
	   #200;
	   $finish;
    end

    always @(posedge clk) begin
        #1;
        $display("time:%.1f ns lfsr:%b",$realtime,q);
    end
endmodule
	   
	
set_property IOSTANDARD LVCMOS33 [get_ports {q[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {q[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {q[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {q[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {q[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {q[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {q[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {q[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property PACKAGE_PIN A4 [get_ports {q[7]}]
set_property PACKAGE_PIN B4 [get_ports {q[6]}]
set_property PACKAGE_PIN A3 [get_ports {q[5]}]
set_property PACKAGE_PIN B3 [get_ports {q[4]}]
set_property PACKAGE_PIN A2 [get_ports {q[3]}]
set_property PACKAGE_PIN B2 [get_ports {q[2]}]
set_property PACKAGE_PIN C3 [get_ports {q[1]}]
set_property PACKAGE_PIN E6 [get_ports {q[0]}]
set_property PACKAGE_PIN F14 [get_ports clk]
set_property PACKAGE_PIN K1 [get_ports rst_n]

set_property -dict { PACKAGE_PIN A4  IOSTANDARD LVCMOS33 } [get_ports {q[7]}]
set_property -dict { PACKAGE_PIN B4  IOSTANDARD LVCMOS33 } [get_ports {q[6]}]
set_property -dict { PACKAGE_PIN A3  IOSTANDARD LVCMOS33 } [get_ports {q[5]}]
set_property -dict { PACKAGE_PIN B3  IOSTANDARD LVCMOS33 } [get_ports {q[4]}]
set_property -dict { PACKAGE_PIN A2  IOSTANDARD LVCMOS33 } [get_ports {q[3]}]
set_property -dict { PACKAGE_PIN B2  IOSTANDARD LVCMOS33 } [get_ports {q[2]}]
set_property -dict { PACKAGE_PIN C3  IOSTANDARD LVCMOS33 } [get_ports {q[1]}]
set_property -dict { PACKAGE_PIN E6  IOSTANDARD LVCMOS33 } [get_ports {q[0]}]

set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports clk]
set_property -dict { PACKAGE_PIN K1  IOSTANDARD LVCMOS33 } [get_ports rst_n]




