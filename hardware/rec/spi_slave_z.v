`ifndef UD
	`define UD #1
`endif

`timescale 1ns / 10ps
`default_nettype none

/*

(16 * stim_cycles_per_elctrd) + 1 spi cycles are put on MOSI as seen in the table below.
Note that there are two elctrd_ns on each 32-ch-module being measured at the same time
(as indicated by "elctrd_ns" in the table below). This is why 16*stim_cycles_per_elctrd
of spi cycles are executed (plus 1 cycle during the start to tell the spi_slave that
impedance measurement transmission is starting). This means that this module has
no knowledge of the frequency or the # of periods to send.


SPI cycle                       shift_out[31:16]        shift_out[15:0]         elctrd_ns
 ------------------------------------------------------------------------------------------
-1                              stop_code             	don't care		none
0                               start_code              stim_cycles_per_elctrd  none
1                               d_ina                   d_inb                   0, 15
2                               d_ina                   d_inb                   0, 15
...
stim_cycles_per_elctrd          d_ina                   d_inb                   0, 15
stim_cycles_per_elctrd+1        d_ina                   d_inb                   1, 16
stim_cycles_per_elctrd+2        d_ina                   d_inb                   1, 16
...
(15*stim_cycles_per_elctrd)-2   d_ina                   d_inb                   14, 30
(15*stim_cycles_per_elctrd)-1   d_ina                   d_inb                   14, 30
(15*stim_cycles_per_elctrd)     d_ina                   d_inb                   14, 30
(15*stim_cycles_per_elctrd)+1   d_ina                   d_inb                   15, 31
(15*stim_cycles_per_elctrd)+2   d_ina                   d_inb                   15, 31
...
(15*stim_cycles_per_elctrd)-2   d_ina                   d_inb                   15, 31
(16*stim_cycles_per_elctrd)-1   d_ina                   d_inb                   15, 31
(16*stim_cycles_per_elctrd)     d_ina                   d_inb                   15, 31

                       end of an impedance measurement                 */



module spi_slave_z (
	/* external input/output */
	 input	wire			CS_b
	,input	wire			SCLK
	,input	wire			MOSI
	/* internal input/output */
	,output wire			MISO
	,output wire			clk2x
	,output wire			clk4x
	,output wire	[15:0] 		ch_sel
	,output wire	[15:0]		d_out
	,output wire			z_meas_en
	,output wire			data_rdy_nsl
	,output reg	[4:0]		s_r
	//,output reg	[1:0]		SEL
);

reg	[31:0]		cmd_in;
reg	[6:0]		sclk_count;


reg	[15:0]			r_out;
reg				clk2x_r;
reg 				clk4x_r;


reg	[15:0]			stim_cycles_per_elctrd;
reg	[15:0]			stim_cycle_n;
reg	[4:0]			ch;
reg				z_meas_en_r;

reg	[15:0]			test_out;
reg				test_en;

reg				data_rdy_nsl_r;

assign data_rdy_nsl = data_rdy_nsl_r;
assign z_meas_en = z_meas_en_r;
assign d_out = r_out;
assign clk2x = clk2x_r;
assign clk4x = clk4x_r;

assign ch_sel = (~z_meas_en_r) ? 16'h0000 : (ch ? (1 << ch) : 16'h0001);

localparam // transmision messages:
	start_code 	= 16'hfedc, 
	test_code	= 16'hff0a,
	stop_code	= 16'h0123;

always @ (posedge CS_b or posedge SCLK) begin
	if(CS_b) begin
		cmd_in <= 31'h0000;
	end else begin
		cmd_in <= {cmd_in[30:0],MOSI};
	end
end

always @ (posedge CS_b or posedge SCLK) begin
	if(CS_b) begin
		clk2x_r <= 0;
		clk4x_r <= 0;
		sclk_count <= 6'b0;
	end else begin
		sclk_count <= sclk_count + 1'b1;
		if (sclk_count == 0) begin
			clk2x_r <= 1;
			clk4x_r <= 1;
		end else if (sclk_count == 5) begin
			clk4x_r <= 0;
		end else if (sclk_count == 10) begin
			clk2x_r <= 0;
			clk4x_r <= 1;
		end else if (sclk_count == 15) begin
			clk4x_r <= 0;
		end else if (sclk_count == 20) begin
			clk2x_r <= 1;
			clk4x_r <= 1;
		end else if (sclk_count == 25) begin
			clk4x_r <= 0;
		end else if (sclk_count == 30) begin
			clk2x_r <= 0;
			clk4x_r <= 1;
		end else if (sclk_count == 35) begin
			clk4x_r <= 0;
		end
	end
end

// Because nsl using feedback, it needs to know when data is ready, 
// otherwise it will start computing on unknown (i.e. X, i.e. don't care) values
always @ (posedge clk2x) begin
	if (~z_meas_en) begin
		data_rdy_nsl_r <= 0;
	end else if (~data_rdy_nsl_r) begin
		if (stim_cycle_n[0]) begin
			data_rdy_nsl_r <= 1;
		end
	end
end

always @ (negedge SCLK) begin
	if (sclk_count == 17) begin
		if (z_meas_en_r) begin
			r_out <= cmd_in[15:0];
		end
	end else if (sclk_count == 33) begin
		
		case (cmd_in[31:16])
			start_code: begin
				stim_cycles_per_elctrd	 <= cmd_in[15:0];
				stim_cycle_n <= 0;
				ch <= 0;
				z_meas_en_r <= 1'b1;
			end
			stop_code: begin
				//SEL <= cmd_in[6:5];
				s_r <= cmd_in[4:0];
				stim_cycles_per_elctrd	 <= 0;
				stim_cycle_n <= 0;
				ch <= 0;
				z_meas_en_r <= 1'b0;
				test_en <= 1'b0;
			end
			test_code: begin
				test_en <= 1'b1;
				z_meas_en_r <= 1'b0;
			end	
			default: begin
				if (z_meas_en_r) begin
					r_out <= cmd_in[15:0];
					if (stim_cycle_n == stim_cycles_per_elctrd) begin
						if (ch == 15) begin
							z_meas_en_r <= 0;
						end else begin
						ch <= ch + 1;
						stim_cycle_n <= 1;
						end
					end else begin
						stim_cycle_n <= stim_cycle_n + 1;
					end
				end
			end
		endcase
	end
end

wire clk_test = (test_en & SCLK);
always @ (negedge clk_test) begin
	if (sclk_count == 0) begin
		test_out <= test_code;
	end else if (sclk_count == 16) begin
		test_out <= test_code;
	end else begin
		test_out <= {test_out[14:0], 1'b0};
	end
end

assign MISO = (~test_en | CS_b) ? 1'bz : test_out[15];	

endmodule

