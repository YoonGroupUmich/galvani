//Verilog HDL for "OSC3", "STIM_SPI" "functional"

module STIM_SPI (
	SCLK, // Clock
	RST, // Reset
	CSb, // Chip Select bar (Active low)
	TRG, // Stimulation trigger
	MOSI,

	MISO,
	BIAS_SEL, // Select external or internal bias current
	BIAS_CTRL, // Control internal bias current
	AMP_CTRL // Control stimulation current
 );

//Input & Ouput
input wire SCLK;
input wire RST;
input wire CSb;
input wire TRG;
input wire MOSI;

output wire MISO;
output reg BIAS_SEL;
output reg [6:0] BIAS_CTRL;
output reg [255:0] AMP_CTRL;

// SPI communication
reg [15:0] SPI_SHIFT_REG;
reg [15:0] NEXT_SPI_SHIFT_REG;

always @ (posedge SCLK or posedge RST) begin
	if (RST) SPI_SHIFT_REG <= 0;
	else SPI_SHIFT_REG <= NEXT_SPI_SHIFT_REG;
end

always @ (*) begin
	if (CSb) NEXT_SPI_SHIFT_REG = SPI_SHIFT_REG;
	else NEXT_SPI_SHIFT_REG = {SPI_SHIFT_REG[14:0], MOSI};
end

// Value assignment
reg NEXT_BIAS_SEL;
reg [6:0] NEXT_BIAS_CTRL;
reg [255:0] NEXT_AMP_CTRL;
reg [255:0] TEMP_AMP_CTRL;

always @ (posedge CSb or posedge RST) begin
	if (RST) begin
		BIAS_SEL <= 0;
		BIAS_CTRL <= 0;
		TEMP_AMP_CTRL <= 0;
	end
	else begin
		BIAS_SEL <= NEXT_BIAS_SEL;
		BIAS_CTRL <= NEXT_BIAS_CTRL;
		TEMP_AMP_CTRL <= NEXT_AMP_CTRL;
	end
end

always @ (posedge TRG or posedge RST) begin
	if (RST) AMP_CTRL <= 0;
	else AMP_CTRL <= TEMP_AMP_CTRL;
end

always @ (*) begin
	NEXT_BIAS_SEL = BIAS_SEL;
	NEXT_BIAS_CTRL = BIAS_CTRL;
	NEXT_AMP_CTRL = TEMP_AMP_CTRL;
	case (SPI_SHIFT_REG[15])
		1'b0: begin
			NEXT_BIAS_SEL = SPI_SHIFT_REG[7];
			NEXT_BIAS_CTRL = SPI_SHIFT_REG[6:0];
			NEXT_AMP_CTRL = TEMP_AMP_CTRL;
		end
		1'b1: begin
			NEXT_BIAS_SEL = BIAS_SEL;
			NEXT_BIAS_CTRL = BIAS_CTRL;
			NEXT_AMP_CTRL[(8 * SPI_SHIFT_REG[14:8] + 7)-:8] = SPI_SHIFT_REG[7:0];
		end
		default: begin
			NEXT_BIAS_SEL = BIAS_SEL;
			NEXT_BIAS_CTRL = BIAS_CTRL;
			NEXT_AMP_CTRL = TEMP_AMP_CTRL;
		end
	endcase
end

assign MISO = SPI_SHIFT_REG[15]; //Check the SPI working in the first place

endmodule

