// For Galvani

`timescale 1ns/10ps

module AFE_256CH (
	input	wire	CLK, // from crystal
	input	wire	PB,
	
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
	
	input wire [127:0] trig_out,
	output wire trig_out_ni
);

assign MOSI_U = 8'd0;
assign CS_b_U = 1'b1;
assign SCLK_U = 1'b0;

wire	[7:0]	MISO_int;
wire	[7:0]	MOSI_int;
wire		CS_b_int;
wire		SCLK_int;

wire		div_clk;
wire		rst_state;
wire		spi_receiving;
reg		z_meas_trig_r;


wire 	[9:0] 	DATA_A[7:0];
wire 	[9:0] 	DATA_B[7:0];

reg 	[9:0] 	DATA_Ar[7:0];
reg 	[9:0] 	DATA_Br[7:0];
  
reg		spi_test_trig_r;

wire		cs_b_z;

assign CS_b_Z_O = cs_b_z;

wire	[15:0]	sine_w;

PB_Debouncer u_pb_debouncer (
	.clk(CLK),
	.PB(PB),
	.PB_state(rst_state),
	.PB_down(),
	.PB_up()
);

////////////////////* RECORDING *////////////////////

/* output assigment for omnetics connectors */
assign	CS_b_O = CS_b_int;
assign	SCLK_O = SCLK_int;
assign	MOSI_O[7:0] = MOSI_int[7:0];
assign 	MISO_int[7:0] = MISO_O[7:0];

wire [15:0] faked;

sine_gen sg_fake (
	.clk(CS_b_int),
	.rst(rst_state),
	.send(1),
	.sine(faked)
);

CLK_DIV u_clk_div0 (
	.clk(CLK),
	.rst(rst_state),
	.div_clk(div_clk) 
);
defparam u_clk_div0.N = 2;

spi_master256 u_spi_master256 (
	.CLK(div_clk),
//	.CLK(clk),
	.RST(rst_state),
	.MISO(MISO_int[7:0]),
	.fake_data(faked),
	.CS_b(CS_b_int),
	.SCLK(SCLK_int),
	.MOSI(MOSI_int),
	.outA(DATA_OUT_A),
	.outB(DATA_OUT_B),
	.clk_ni(DATA_OUT_CLK),
	.spi_receiving(spi_receiving),
	.sync_ni(SYNC),
	.spi_trig_in(1'b1),
	.SPI_run_continuous(1'b1),
	.trig_out(trig_out),
	.trig_out_ni(trig_out_ni)
);

////////////////////* Z MEASURE *////////////////////

wire [15:0] din1;
wire [15:0] din2 = din1;
// start sending sine wave when 'send' = 1
sine_gen sg_z0 (
	.clk(cs_b_z),
	.rst(rst_state),
	.send(z_meas_trig_r),
	//.s1(din1),
	.sine(din1),
	//.s2(din2)
);

wire clk_z;
CLK_DIV u_clk_div_z (
	.clk(CLK),
	.rst(rst_state),
	.div_clk(clk_z) 
);
defparam u_clk_div_z.N = 2;

assign SEL_O = 2'b11;
localparam
		stim_cycles_per_elec = 16'hFFFF; // FFFF = 2^16-1 cycles / 400 khz clock = 167 ms period for each electrode
spi_master_z u_spi_master_z0 (
	.CLK(clk_z),
	.RST(rst_state),
	.spi_test_trig(spi_test_trig_r),
	.z_meas_trig(z_meas_trig_r), 
	.stim_cycles_per_elctrd(stim_cycles_per_elec),
	.d_in1(din1),
	.d_in2(din2),
	.MISO(MISO_Z_O),
	.CS_b(cs_b_z), 
	.SCLK(SCLK_Z_O),
	.MOSI(MOSI_Z_O)
);

// Need to enable spi_master_z for few cycles to turn off z measurement block
always @(posedge rst_state or posedge div_clk) begin
	if (rst_state) begin
		spi_test_trig_r <= 1'b0;
		z_meas_trig_r <= 1'b1;
	end
	else if (spi_receiving) begin
		z_meas_trig_r <= 1'b0;
	end
	else begin
		spi_test_trig_r <= spi_test_trig_r;
		z_meas_trig_r <= 1'b1;
	end
end

endmodule
