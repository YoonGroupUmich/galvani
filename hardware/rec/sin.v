
// SIN = Spi, Interpolate, Noise shape

module sin(
	// from spi master
	input wire		CS_b,
	input wire		SCLK,
	input wire		MOSI,
	// to spi master
	output  wire		MISO,
	// to rest of chip
	//output wire 	[1:0]	SEL,
	output wire		clk_d,
	output wire	[4:0]	s_r,
	output wire	[15:0]	ch_sel,
	output wire 		nsl_out_p,
	output wire 		nsl_out_n
);


wire		clk2x;
wire		clk4x;
wire	[15:0] 	slave2dac;
wire		data_rdy_nsl;
wire		z_meas_en;

spi_slave_z slave (
	.CS_b(CS_b),
	.SCLK(SCLK),
	.MOSI(MOSI),
	.MISO(MISO),
	.clk2x(clk2x), // generated from SCLK
	.clk4x(clk4x), // generated from SCLK
	.ch_sel(ch_sel),
	.d_out(slave2dac),
	.z_meas_en(z_meas_en),
	.data_rdy_nsl(data_rdy_nsl),
	//.SEL(SEL),
	.s_r(s_r)
);

wire	[15:0] 	filt_out;
interp_filt #(.WIDTH(16)) interp_filt_inst (
	.clk2x(clk2x),
	.clk4x(clk4x),
	.enable(z_meas_en),
	.x(slave2dac),
	.y(filt_out)
);

wire nsl_rst = (~z_meas_en | ~data_rdy_nsl);

nsl12 nsl12_inst (
	.rst(nsl_rst),
	.clk(clk4x),
	.in(filt_out),
	.outp(nsl_out_p),
	.outn(nsl_out_n)
);

assign clk_d = clk4x;

endmodule


