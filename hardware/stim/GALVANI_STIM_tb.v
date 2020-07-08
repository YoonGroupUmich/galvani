`timescale 1ns/10ps

module GALVANI_STIM_TB;

	reg CLK;
	reg RST;
	reg RST_CLK;
		
	wire SCLK;
	wire CSb;
	wire RST_SLV;
	wire TRG_SLV;
	wire [3:0] MOSI;
	
	wire [3:0] MISO;
	wire [3:0] BIAS_SEL;

	wire [6:0] BIAS_CTRL0;
	wire [6:0] BIAS_CTRL1;
	wire [6:0] BIAS_CTRL2;
	wire [6:0] BIAS_CTRL3;

	wire [255:0] AMP_CTRL0;
	wire [255:0] AMP_CTRL1;
	wire [255:0] AMP_CTRL2;
	wire [255:0] AMP_CTRL3;
	
	reg NI_CLK;
	wire [7:0] NI_DIGITAL_IN;
	wire FIFO_DATA_READY;
	wire FIFO_FULL;
	
	assign FIFO_DATA_READY = !FIFO_FULL;
	
	

	GALVANI_STIM GALVANI_STIM_TEST(
		.CLK(CLK),
		.RST(RST),
		.RST_CLK(RST_CLK),
		
		.NI_CLK(NI_CLK),
		.NI_DIGITAL_IN(NI_DIGITAL_IN),
		.FIFO_DATA_READY(FIFO_DATA_READY),
		.FIFO_FULL(FIFO_FULL),
		
		.SCLK(SCLK),
		.CSb(CSb),
		.RST_SLV(RST_SLV),
		.TRG_SLV(TRG_SLV),
		.MOSI(MOSI)
	);

	STIM_SPI STIM_SPI0(
		.SCLK(SCLK),
		.RST(RST_SLV),
		.CSb(CSb),
		.TRG(TRG_SLV),
		.MOSI(MOSI[0]),

		.MISO(MISO[0]),
		.BIAS_SEL(BIAS_SEL[0]),
		.BIAS_CTRL(BIAS_CTRL0),
		.AMP_CTRL(AMP_CTRL0)
	);

	STIM_SPI STIM_SPI1(
		.SCLK(SCLK),
		.RST(RST_SLV),
		.CSb(CSb),
		.TRG(TRG_SLV),
		.MOSI(MOSI[1]),

		.MISO(MISO[1]),
		.BIAS_SEL(BIAS_SEL[1]),
		.BIAS_CTRL(BIAS_CTRL1),
		.AMP_CTRL(AMP_CTRL1)
	);

	STIM_SPI STIM_SPI2(
		.SCLK(SCLK),
		.RST(RST_SLV),
		.CSb(CSb),
		.TRG(TRG_SLV),
		.MOSI(MOSI[2]),

		.MISO(MISO[2]),
		.BIAS_SEL(BIAS_SEL[2]),
		.BIAS_CTRL(BIAS_CTRL2),
		.AMP_CTRL(AMP_CTRL2)
	);

	STIM_SPI STIM_SPI3(
		.SCLK(SCLK),
		.RST(RST_SLV),
		.CSb(CSb),
		.TRG(TRG_SLV),
		.MOSI(MOSI[3]),

		.MISO(MISO[3]),
		.BIAS_SEL(BIAS_SEL[3]),
		.BIAS_CTRL(BIAS_CTRL3),
		.AMP_CTRL(AMP_CTRL3)
	);

	always begin
		CLK = 1'b0;
		#1;
		CLK = 1'b1;
		#1;
	end
	
	
	always begin
		NI_CLK = 1'b0;
		#32;
		NI_CLK = 1'b1;
		#32;
	end
	
	reg [2:0] data_pos;
	assign NI_DIGITAL_IN = data_pos == 0 ? 8'haa :
	data_pos == 1 ? 8'h21 :
	data_pos == 2 ? 8'h23 :
	data_pos == 3 ? 8'h45 :
	data_pos == 4 ? 8'h67 :
	data_pos == 5 ? 8'h89 :
	data_pos == 6 ? 8'hab :
	data_pos == 7 ? 8'hab : 0;
	
	always@(posedge NI_CLK) begin
		if (!FIFO_FULL) data_pos <= data_pos + 1;
	end
	
	initial begin
		data_pos = 0;
		RST = 1'b1;
		RST_CLK = 1'b1;
		#128;
		RST_CLK = 1'b0;
		#128;
		RST_CLK = 1'b1;
		#1024;
		RST = 1'b0;
		#1024;
		RST = 1'b1;
		#64;		
	end

endmodule
