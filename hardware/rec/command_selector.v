`ifndef UD
`define UD #1
`endif

`timescale 1ns/10ps

module command_selector (
	input wire 	[5:0] 	channel,
	input wire  [1:0]	bias,
	input wire  [1:0]   gain, // PGA gain
	output wire [15:0] 	MOSI_cmd
	);

	// bias
	// 00 Off
	// 01 Internal Bias
	// 10 Forbidden
	// 11 External Bias

	// PGA gain
	// 00 - 0.0 dB
	// 01 - 5.6 db
	// 10 - 9.0 dB
	// 11 - 20.0 db

	wire	[7:0]		prog;

	// prog[7:6] = bias
	// prog[5:4] = PGA gain 
	// prog[3:2] = bias
	// prog[1:0] = bias 

	assign prog = {bias, gain, bias, bias};
	//assign prog = {2'b00, gain, 2'b01, 2'b01};
	assign MOSI_cmd = { 2'b10, channel, prog};

	//always @(*) begin
	//	case (channel)
	//		0:       MOSI_cmd <= { 2'b10, channel, prog};
	//		1:       MOSI_cmd <= { 2'b10, channel, prog};
	//		2:       MOSI_cmd <= { 2'b10, channel, prog};
	//		3:       MOSI_cmd <= { 2'b10, channel, prog};
	//		4:       MOSI_cmd <= { 2'b10, channel, prog};
	//		5:       MOSI_cmd <= { 2'b10, channel, prog};
	//		6:       MOSI_cmd <= { 2'b10, channel, prog};
	//		7:       MOSI_cmd <= { 2'b10, channel, prog};
	//		8:       MOSI_cmd <= { 2'b10, channel, prog};
	//		9:       MOSI_cmd <= { 2'b10, channel, prog};
	//		10:      MOSI_cmd <= { 2'b10, channel, prog};
	//		11:      MOSI_cmd <= { 2'b10, channel, prog};
	//		12:      MOSI_cmd <= { 2'b10, channel, prog};
	//		13:      MOSI_cmd <= { 2'b10, channel, prog};
	//		14:      MOSI_cmd <= { 2'b10, channel, prog};
	//		15:      MOSI_cmd <= { 2'b10, channel, prog};
	//		default: MOSI_cmd <= 16'b0;
	//		endcase
	//end	
endmodule

	
