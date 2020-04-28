`timescale 1ns/10ps

module GALVANI_STIM (
	input wire CLK,
	input wire RST,
	//input wire RST_CLK,
	
	input wire NI_CLK,
	input wire [7:0] NI_DIGITAL_IN,
	input wire FIFO_DATA_READY,
	output wire FIFO_FULL,
	
	output wire SCLK,
	output wire CSb,
	output wire RST_SLV,
	output wire TRG_SLV,
	output wire	[3:0] MOSI
);
	
	wire RST_CLK;
	assign RST_CLK = 1'b1;
	
	wire CLK_DIV;
		
	wire TX_START;	
	wire TX_END;
	wire TRG;
			
	wire MODE; //Low: Bias control, High: Amplitude control
	
	wire BIAS_SEL; //Low: Internal bias, High: External bias
	wire [6:0] BIAS_AMP;	
		
	wire [4:0] ADDR;
	
	wire [7:0] AMP0;
	wire [7:0] AMP1;
	wire [7:0] AMP2;
	wire [7:0] AMP3;
	
	wire [15:0] CMD0;
	wire [15:0] CMD1;
	wire [15:0] CMD2;
	wire [15:0] CMD3;

		
	CLK_DIVIDER CLK_DIVIDER_DIV_20(
		.CLK(CLK),
		.RST(RST_CLK),
		.CLK_DIV(CLK_DIV)
	);

/*
	INPUT_GEN INPUT_GEN_4MODULES(
		.CLK(CLK_DIV),
		.RST(RST),
		.TX_START(TX_START),
	
		.MODE(MODE),
		.BIAS_SEL(BIAS_SEL),
		.BIAS_AMP(BIAS_AMP),
		.ADDR(ADDR),
		.AMP0(AMP0),
		.AMP1(AMP1),
		.AMP2(AMP2),
		.AMP3(AMP3)	
	);
*/
	INPUT_RECV INPUT_RECV_4MODULES(
		.CLK(CLK_DIV),
		.RST(RST),
		.TX_START(TX_START),
		
		.NI_CLK(NI_CLK),
		.NI_DIGITAL_IN(NI_DIGITAL_IN),
		.FIFO_DATA_READY(FIFO_DATA_READY),
		.FIFO_FULL(FIFO_FULL),
	
		.MODE(MODE),
		.BIAS_SEL(BIAS_SEL),
		.BIAS_AMP(BIAS_AMP),
		.ADDR(ADDR),
		.AMP0(AMP0),
		.AMP1(AMP1),
		.AMP2(AMP2),
		.AMP3(AMP3),
	);

	CMD_GEN CMD_GEN0(
		.CLK(CLK_DIV),
		.RST(RST),
		.TX_END(TX_END),
		.MODE(MODE),
		.BIAS_SEL(BIAS_SEL),
		.BIAS_AMP(BIAS_AMP),
		.ADDR(ADDR),
		.AMP(AMP0),
		
		.TX_START(TX_START),
		.TRG(TRG),
		.CMD(CMD0)
	);
	
	CMD_GEN CMD_GEN1(
		.CLK(CLK_DIV),
		.RST(RST),
		.TX_END(TX_END),
		.MODE(MODE),
		.BIAS_SEL(BIAS_SEL),
		.BIAS_AMP(BIAS_AMP),
		.ADDR(ADDR),
		.AMP(AMP1),
		
		.TX_START(),
		.TRG(),
		.CMD(CMD1)
	);
	
	CMD_GEN CMD_GEN2(
		.CLK(CLK_DIV),
		.RST(RST),
		.TX_END(TX_END),
		.MODE(MODE),
		.BIAS_SEL(BIAS_SEL),
		.BIAS_AMP(BIAS_AMP),
		.ADDR(ADDR),
		.AMP(AMP2),
		
		.TX_START(),
		.TRG(),
		.CMD(CMD2)
	);
	
	CMD_GEN CMD_GEN3(
		.CLK(CLK_DIV),
		.RST(RST),
		.TX_END(TX_END),
		.MODE(MODE),
		.BIAS_SEL(BIAS_SEL),
		.BIAS_AMP(BIAS_AMP),
		.ADDR(ADDR),
		.AMP(AMP3),
		
		.TX_START(),
		.TRG(),
		.CMD(CMD3)
	);
	
	SPI_MASTER SPI_MASTER0(
		.CLK(CLK_DIV),
		.RST(RST),
		.TRG(TRG),
		.TX_START(TX_START),
		.CMD(CMD0),
		
		.SCLK(SCLK),
		.CSb(CSb),
		.RST_SLV(RST_SLV),
		.TRG_SLV(TRG_SLV),
		.MOSI(MOSI[0]),
		.TX_END(TX_END)
	);

	SPI_MASTER SPI_MASTER1(
		.CLK(CLK_DIV),
		.RST(RST),
		.TRG(TRG),
		.TX_START(TX_START),
		.CMD(CMD1),
		
		.SCLK(),
		.CSb(),
		.RST_SLV(),
		.TRG_SLV(),
		.MOSI(MOSI[1]),
		.TX_END()
	);

	SPI_MASTER SPI_MASTER2(
		.CLK(CLK_DIV),
		.RST(RST),
		.TRG(TRG),
		.TX_START(TX_START),
		.CMD(CMD2),
		
		.SCLK(),
		.CSb(),
		.RST_SLV(),
		.TRG_SLV(),
		.MOSI(MOSI[2]),
		.TX_END()
	);

	SPI_MASTER SPI_MASTER3(
		.CLK(CLK_DIV),
		.RST(RST),
		.TRG(TRG),
		.TX_START(TX_START),
		.CMD(CMD3),
		
		.SCLK(),
		.CSb(),
		.RST_SLV(),
		.TRG_SLV(),
		.MOSI(MOSI[3]),
		.TX_END()
	);

endmodule

