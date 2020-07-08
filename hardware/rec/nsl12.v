// Created by ihdl
module nsl12(
	input wire		rst,
	input wire		clk,
	input wire	[15:0]	in,
	output wire		outp,
	output wire		outn
);

reg	[19:0]	acc1;
reg	[19:0]	acc2;

always @ (posedge rst or posedge clk) begin
	if(rst) begin
		acc1 <= 20'b0;
	end else begin
		if(acc1[19]) begin
			acc1 <= 2*(acc1[19:0]-65536) - acc2[19:0] + in[15:0];
		end else begin
			acc1 <= 2*acc1[19:0] - acc2[19:0] + in[15:0];
		end
	end
end

always @ (posedge rst or posedge clk) begin
	if(rst) begin
		acc2 <= 20'b0;
	end else begin
		if(acc1[19]) begin
			acc2[19:0] <= acc1[19:0]-65536;
		end else begin
			acc2[19:0] <= acc1[19:0]; 
		end
	end
end

assign 	outp = acc1[19];
assign 	outn = ~acc1[19];

endmodule
