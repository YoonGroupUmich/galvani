`timescale 1ns/10ps

`ifndef UD
	`define UD #1
`endif

module CLK_DIV (clk, rst, div_clk);

input 	wire clk, rst;
output	wire div_clk;

parameter N = 512;
//parameter N = 4;

reg	[12:0]	clk_cnt;
reg	clk_out_tmp;
 
always @ (posedge rst or posedge clk) begin
	if(rst) begin
		clk_cnt <= `UD 13'd0;
		clk_out_tmp <= `UD 1'b0;
	end else if(clk_cnt == N/2) begin
		clk_out_tmp <= `UD ~clk_out_tmp;
		clk_cnt <= `UD 13'd1;
	end else begin
		clk_cnt <= `UD clk_cnt + 13'd1;
	end
end
assign div_clk = clk_out_tmp;

endmodule



