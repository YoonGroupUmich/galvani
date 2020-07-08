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
	
	output	wire		CS_b_test,

	output	wire	[9:0]	DATA_OUT_A,
	output	wire	[9:0]	DATA_OUT_B,
	output	wire		DATA_OUT_CLK,	
	output 	wire		SYNC
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

reg 	[3:0]	count5;
reg 	[7:0] 	tdm_index;
reg 		tdm_clk;
reg		sync_reg;
wire	[5:0] 	ch; // channels 1-16 (A and B)

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
	.PB_down(pbd),
	.PB_up()
);

wire [15:0] din1;
wire [15:0] din2;

// start sending sine wave when 'send' = 1
sine_gen sg0 (
	.clk(cs_b_z),
	.rst(rst_state),
	.send(z_meas_trig_r),
	.s1(din1),
	.s2(din2)
);

assign SEL_O = 2'b11;


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


//// MOSI is deserialized in spi_master (see out_A, out_B)
spi_master u_spi_master0 (
	.CLK(div_clk),
	.RST(rst_state),
	.spi_trig_in(1'b1),
	.MISO(MISO_int[0]),
	.CS_b(CS_b_int),
	.SCLK(SCLK_int),
	.MOSI(MOSI_int[0]),
	.spi_receiving(spi_receiving),
	.out_A(DATA_A[0]),
	.out_B(DATA_B[0]),
	.ch(ch)
);


spi_master u_spi_master1 (
	.MISO(MISO_int[1]),
	
	.CS_b(),
	.SCLK(),
	.MOSI(MOSI_int[1]),	
	.spi_receiving(),
	
	.out_A(DATA_A[1]),
	.out_B(DATA_B[1]),
	.ch(),
	.CLK(div_clk),
	.RST(rst_state),
	.spi_trig_in(1'b1)
);

spi_master u_spi_master2 (
	.MISO(MISO_int[2]),
	
	.CS_b(),
	.SCLK(),
	.MOSI(MOSI_int[2]),
	.spi_receiving(),

	.out_A(DATA_A[2]),
	.out_B(DATA_B[2]),
	.ch(),
	.CLK(div_clk),
	.RST(rst_state),
	.spi_trig_in(1'b1)
);

spi_master u_spi_master3 (
	.MISO(MISO_int[3]),

	.CS_b(),
	.SCLK(),	
	.MOSI(MOSI_int[3]),
	.spi_receiving(),

	.out_A(DATA_A[3]),
	.out_B(DATA_B[3]),
	.ch(),
	.CLK(div_clk),
	.RST(rst_state),
	.spi_trig_in(1'b1)
);

spi_master u_spi_master4 (
	.MISO(MISO_int[4]),

	.CS_b(),
	.SCLK(),
	.MOSI(MOSI_int[4]),
	.spi_receiving(),
	
	.out_A(DATA_A[4]),
	.out_B(DATA_B[4]),
	.ch(),
	.CLK(div_clk),
	.RST(rst_state),
	.spi_trig_in(1'b1)
);

spi_master u_spi_master5 (
	.MISO(MISO_int[5]),

	.CS_b(),
	.SCLK(),
	.MOSI(MOSI_int[5]),
	.spi_receiving(),

	.out_A(DATA_A[5]),
	.out_B(DATA_B[5]),
	.ch(),
	.CLK(div_clk),
	.RST(rst_state),
	.spi_trig_in(1'b1)
);

spi_master u_spi_master6 (
	.MISO(MISO_int[6]),

	.CS_b(),
	.SCLK(),
	.MOSI(MOSI_int[6]),
	.spi_receiving(),
	
	.out_A(DATA_A[6]),
	.out_B(DATA_B[6]),
	.ch(),
	.CLK(div_clk),
	.RST(rst_state),
	.spi_trig_in(1'b1)
);

spi_master u_spi_master7 (
	.MISO(MISO_int[7]),

	.CS_b(),
	.SCLK(),
	.MOSI(MOSI_int[7]),
	.spi_receiving(),

	.out_A(DATA_A[7]),
	.out_B(DATA_B[7]),
	.ch(),
	.CLK(div_clk),
	.RST(rst_state),
	.spi_trig_in(1'b1)
);


/*
defparam u_spi_master0.MOD = 10'd0;
defparam u_spi_master1.MOD = 10'd32;
defparam u_spi_master2.MOD = 10'd64;
defparam u_spi_master3.MOD = 10'd96;
defparam u_spi_master4.MOD = 10'd128;
defparam u_spi_master5.MOD = 10'd160;
defparam u_spi_master6.MOD = 10'd192;
defparam u_spi_master7.MOD = 10'd224;
*/

wire clk_z;
CLK_DIV u_clk_div1 (
	.clk(CLK),
	.rst(rst_state),
	.div_clk(clk_z) 
);
defparam u_clk_div1.N = 32;

CLK_DIV u_clk_div0 (
	.clk(CLK),
	.rst(rst_state),
	.div_clk(div_clk) 
);
defparam u_clk_div0.N = 2;

localparam
		stim_cycles_per_elec = 16'hFFFF; // 2^16-1 cycles / 400 khz clock = 167 ms period for each electrode

// There are 80 clk cycles in every spi cycle.
// Need to send out two 10-bit samples from 8 modules 
// within these 80 cycles:
always @(posedge rst_state or posedge div_clk) begin
	if (rst_state) begin
		tdm_clk <= 1'b0;
		count5 <= 3'd1;
		spi_test_trig_r <= 1'b0;
		z_meas_trig_r <= 1'b0;
	end
	else if (spi_receiving) begin
		count5 <= count5 + 3'd1;
		if (count5 == 3'd5) begin
			tdm_clk <= ~tdm_clk;
			count5 <= 3'd1;
		end
		z_meas_trig_r <= 1'b1;
	end
	else begin
		spi_test_trig_r <= spi_test_trig_r;
		z_meas_trig_r <= 1'b1;
	end
end

always @(posedge rst_state or negedge tdm_clk) begin
	if (rst_state) begin
		DATA_Ar[0] <= 10'd0;
	   	DATA_Br[0] <= 10'd0;
	    DATA_Ar[1] <= 10'd0;
	    DATA_Br[1] <= 10'd0;
		DATA_Ar[2] <= 10'd0;
		DATA_Br[2] <= 10'd0;
		DATA_Ar[3] <= 10'd0;
		DATA_Br[3] <= 10'd0;
		DATA_Ar[4] <= 10'd0;
		DATA_Br[4] <= 10'd0;
		DATA_Ar[5] <= 10'd0;
		DATA_Br[5] <= 10'd0;
		DATA_Ar[6] <= 10'd0;
		DATA_Br[6] <= 10'd0;
		DATA_Ar[7] <= 10'd0;
		DATA_Br[7] <= 10'd0;

		tdm_index <= 8'h01;
		//sync_reg <= 1'b0;

	end else if (spi_receiving) begin
		if (tdm_index[7]) begin
			DATA_Ar[0] <= DATA_A[0];
			DATA_Br[0] <= DATA_B[0];
			DATA_Ar[1] <= DATA_A[1];
			DATA_Br[1] <= DATA_B[1]; 
			DATA_Ar[2] <= DATA_A[2];
			DATA_Br[2] <= DATA_B[2]; 
			DATA_Ar[3] <= DATA_A[3];
			DATA_Br[3] <= DATA_B[3]; 
			DATA_Ar[4] <= DATA_A[4];
			DATA_Br[4] <= DATA_B[4]; 
			DATA_Ar[5] <= DATA_A[5];
			DATA_Br[5] <= DATA_B[5]; 
			DATA_Ar[6] <= DATA_A[6];
			DATA_Br[6] <= DATA_B[6]; 
			DATA_Ar[7] <= DATA_A[7]; 
			DATA_Br[7] <= DATA_B[7];	

			tdm_index <= 8'h01;
			//sync_reg <= 1'b1;
		end else begin
			tdm_index <= (tdm_index << 1);
			//sync_reg <= 1'b0;
		end
	end
end

assign DATA_OUT_A = DATA_A[0];
assign DATA_OUT_B = DATA_B[0];

//assign DATA_OUT_A = DATA_Ar[0];
//assign DATA_OUT_B = DATA_Br[0];

/*
assign DATA_OUT_A = (tdm_index[0] ? DATA_Ar[0] :
			tdm_index[1] ? DATA_Ar[1] :
			tdm_index[2] ? DATA_Ar[2] :
			tdm_index[3] ? DATA_Ar[3] :
			tdm_index[4] ? DATA_Ar[4] :
			tdm_index[5] ? DATA_Ar[5] :
			tdm_index[6] ? DATA_Ar[6] :
			tdm_index[7] ? DATA_Ar[7] :
			10'd512);

assign DATA_OUT_B = (tdm_index[0] ? DATA_Br[0] :
			tdm_index[1] ? DATA_Br[1] :
			tdm_index[2] ? DATA_Br[2] :
			tdm_index[3] ? DATA_Br[3] :
			tdm_index[4] ? DATA_Br[4] :
			tdm_index[5] ? DATA_Br[5] :
			tdm_index[6] ? DATA_Br[6] :
			tdm_index[7] ? DATA_Br[7] :
			10'd512);
*/

// output to LabView
//assign DATA_OUT_A = {5'h00,ch};
//assign DATA_OUT_B = {5'h1f,ch};
//assign DATA_OUT_A = DATA_Ar[0];
//assign DATA_OUT_B = DATA_Br[0];
//assign DATA_OUT_A = DATA_Ar[tdm_index];
//assign DATA_OUT_B = DATA_Br[tdm_index];
//assign DATA_OUT_CLK = tdm_clk;
assign DATA_OUT_CLK = ~CS_b_int;

always @(posedge rst_state or posedge CS_b_int) begin
	if (rst_state) begin
		sync_reg <= 1'b0;
	end else begin
		sync_reg <= spi_receiving ? (ch == 6'd2) : 1'b0;
	end
end
		
		
assign SYNC = sync_reg;
		
//assign SYNC = sync_reg && (ch == 6'd3);
//assign SPI_RECV = spi_receiving;

assign	CS_b_test = div_clk;

/* output assigment for test pcb with USB-C connectors */
//assign	CS_b_U = CS_b_int;
//assign	SCLK_U = SCLK_int;
//assign	MOSI_U[7:0] = MOSI_int[7:0];
//assign 	MISO_int[7:0] = MISO_U[7:0];

/* output assigment for test pcb with omnetics connectors */
assign	CS_b_O = CS_b_int;
assign	SCLK_O = SCLK_int;
assign	MOSI_O[7:0] = MOSI_int[7:0];
assign 	MISO_int[7:0] = MISO_O[7:0];

endmodule


