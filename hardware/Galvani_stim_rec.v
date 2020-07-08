`timescale 1ns/10ps

module Galvani_stim_rec (
	input wire CLK,
	input wire RST,
	
	/// Stim	
	input wire NI_CLK,
	input wire [7:0] NI_DIGITAL_IN,
	input wire FIFO_DATA_READY,
	output wire FIFO_FULL,
	
	output wire SCLK,
	output wire CSb,
	output wire RST_SLV,
	output wire TRG_SLV,
	output wire	[3:0] MOSI,
	
	
	/// Rec	
	// U = USB-C
	input	wire	[7:0]	MISO_U,
	output	wire	[7:0]	MOSI_U,
	output	wire		CS_b_U,
	output	wire		SCLK_U,
	
	// O = Omnetics
	input	wire	[7:0]	MISO_O, 
	output	wire	[7:0]	MOSI_O,
	output	wire		CS_b_O,
	output	wire		SCLK_O,

	// Z = impedance measurement
	input	wire	   	MISO_Z_O, 
	output	wire	    	MOSI_Z_O,
	output	wire		CS_b_Z_O,
	output	wire		SCLK_Z_O,
	output	wire	[1:0]	SEL_O,

	output	wire	[9:0]	DATA_OUT_A,
	output	wire	[9:0]	DATA_OUT_B,
	output	wire		DATA_OUT_CLK,	
	output 	wire		SYNC,
	
	
	/// Trigger Out
	output wire DATA_OUT_TRIG_OUT
);

	wire [127:0] trig_out;

GALVANI_STIM stim (
	.CLK(CLK),
	.RST(RST),	
	.NI_CLK(NI_CLK),
	.NI_DIGITAL_IN(NI_DIGITAL_IN),
	.FIFO_DATA_READY(FIFO_DATA_READY),
	.FIFO_FULL(FIFO_FULL),	
	.SCLK(SCLK),
	.CSb(CSb),
	.RST_SLV(RST_SLV),
	.TRG_SLV(TRG_SLV),
	.MOSI(MOSI),
	.trig_out(trig_out)
);

AFE_256CH rec (
	.CLK(CLK), // from crystal
	.PB(RST),
	.MISO_U(MISO_U),
	.MOSI_U(MOSI_U),
	.CS_b_U(CS_b_U),
	.SCLK_U(SCLK_U),
	.MISO_O(MISO_O), 
	.MOSI_O(MOSI_O),
	.CS_b_O(CS_b_O),
	.SCLK_O(SCLK_O),
	.MISO_Z_O(MISO_Z_O), 
	.MOSI_Z_O(MOSI_Z_O),
	.CS_b_Z_O(CS_b_Z_O),
	.SCLK_Z_O(SCLK_Z_O),
	.SEL_O(SEL_O),
	.DATA_OUT_A(DATA_OUT_A),
	.DATA_OUT_B(DATA_OUT_B),
	.DATA_OUT_CLK(DATA_OUT_CLK),	
	.SYNC(SYNC),
	.trig_out(trig_out),
	.trig_out_ni(DATA_OUT_TRIG_OUT)
);

endmodule