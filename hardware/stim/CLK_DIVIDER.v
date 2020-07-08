`timescale 1ns/10ps

module CLK_DIVIDER (
	input wire CLK,
	input wire RST,

	output reg CLK_DIV
);
	parameter N = 4;
	
	reg [19:0] CNT;

	always@(posedge CLK) begin
		if (!RST) begin
			CLK_DIV <= 1'b0;
			CNT <= 20'b0; 
		end			
		else begin
			if (CNT < N / 2) begin
				CLK_DIV <= 1'b0;
				CNT <= CNT + 1'b1;
			end
			else if (CNT < N - 1) begin
				CLK_DIV <= 1'b1;
				CNT <= CNT + 1'b1;
			end
			else begin
				CLK_DIV <= 1'b1;
				CNT <= 20'b0;
			end
		end
	end
		
endmodule

