`ifndef UD
`define UD #1
`endif

`timescale 1ns/1ps

module tb_cpld();

`ifdef POST
//	initial $sdf_annotate("APR.sdf",cellname);
`endif

`ifdef PRE
//	initial $sdf_annotate("../SYN/sin.dc.sdf", sin_inst);
`endif



reg 	rst;

initial begin
        $shm_open("afe");
        $shm_probe("AC");

	rst <= 1'b1;
	#3000;
	rst <= 1'b0;
	#40000;
	rst <= 1'b1;

	#4000000 $stop;
	$shm_close;
	
end

reg	clk32Meg; // from FPGA

initial begin
	clk32Meg = 0;
end

always #15.625 clk32Meg = ~clk32Meg;

wire                    CS_b;
wire                    SCLK;
wire                    MOSI;
wire                    MISO;

AFE_256CH afe (
	.CLK(clk32Meg),
	.PB(rst),
	.MISO_Z_O(MISO),
	.MOSI_Z_O(MOSI),
	.CS_b_Z_O(CS_b),
	.SCLK_Z_O(SCLK)
);

wire	[15:0]	filt_out;
wire		nsl_out_p;
wire		nsl_out_n;
wire	[15:0]	ch_sel;
wire	[4:0]	s_r;

// SIN = Spi - Interpolation - Noise shaping loop
sin sin_inst (
	.CS_b(CS_b),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
	.s_r(s_r),
	.ch_sel(ch_sel),
	.nsl_out_p(nsl_out_p),
	.nsl_out_n(nsl_out_n)
);

endmodule


