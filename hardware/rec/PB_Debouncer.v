`timescale 1ns/10ps

`ifndef UD
	`define UD #1
`endif

/*Push buttom debouncer 2014.7.28*/
/*modified 2019.12.14*/
module PB_Debouncer(clk, PB, PB_state, PB_down, PB_up);

input wire	clk, PB;
output reg	PB_state;
output wire 	PB_down, PB_up;

/* Synchronize PB signal the "clk" clock domain */
reg	PB_sync0; always @(posedge clk) PB_sync0 <= `UD ~PB;
reg	PB_sync1; always @(posedge clk) PB_sync1 <= `UD PB_sync0;

reg	[9:0] PB_cnt;

wire	PB_idle = (PB_state == PB_sync1);
wire	PB_cnt_max = &PB_cnt;

always @(posedge clk) begin
	if(PB_idle) begin
		PB_cnt <= `UD 0;
	end else begin
		PB_cnt <= `UD PB_cnt + 10'd1;
		if(PB_cnt_max) PB_state <= `UD ~PB_state;
	end
end

assign PB_down = ~PB_idle & PB_cnt_max & ~PB_state;
assign PB_up	= ~PB_idle & PB_cnt_max &  PB_state;

endmodule
