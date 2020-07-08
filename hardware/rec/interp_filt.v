`ifndef UD
`define UD #1
`endif

`timescale 1ns / 1ps
`default_nettype none

// Using polyphase implementation of SINC52 filter (5th order, interp by 2)
// Transfer function y/x = 
// (1/2^5) * (1+z^-1)^5  =  
// (1/2^5) * (1 + 5z^-1 + 10z^-2 + 10z^-3 + 5z^-4 + z^-5)


module interp_filt #(parameter WIDTH = 16) (
	input	wire			clk2x,
	input	wire			clk4x,
	input	wire			enable,
	input	wire	[WIDTH-1:0]	x,
	output  reg	[WIDTH-1:0]	y	
);

// EXTRA width of data word to account for multiplication by 10 and additions
localparam EXTRA = 7; 

reg	[WIDTH+EXTRA-1:0]	res1;
reg	[WIDTH+EXTRA-1:0]	res2;
reg	[WIDTH+EXTRA-1:0]	res3;
reg	[WIDTH+EXTRA-1:0]	res4;

wire	[WIDTH+EXTRA-1:0]	x5;
wire	[WIDTH+EXTRA-1:0]	x10;

wire	[WIDTH+EXTRA-1:0]	y_a;
wire	[WIDTH+EXTRA-1:0]	y_b;


assign x5 = (x << 2) + x;
assign x10 = x5 << 1;

assign y_a = res2 + x; 
assign y_b = res4 + x5; 

always @(negedge clk4x) begin
	if (!enable) begin
		y <= 0;	
	end else begin	
		if (clk2x) begin
			// divide by 2^(filt order)
			// filt order = 5
			// equivalently, discard bits [4:0]:
			y <= y_a[WIDTH+EXTRA-3:EXTRA-3];
		end else begin
			y <= y_b[WIDTH+EXTRA-3:EXTRA-3];
		end
	end
end
	
always @(posedge clk2x) begin
	if (!enable) begin
		res1 <= 0;	 
		res2 <= 0;	 
		res3 <= 0;	 
		res4 <= 0;	 
	end else begin
		res1 <= x5;
		res2 <= res1 + x10;	
		res3 <= x;
		res4 <= res3 + x10;
	end
end

endmodule

