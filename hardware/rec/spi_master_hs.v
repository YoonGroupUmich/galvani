`timescale 1ns/10ps

`ifndef UD
`define UD #1
`endif


module spi_master_hs (
	
	input wire			CLK, 
	input wire			RST,
	input wire			spi_trig_in,
	input wire  			MISO,
	
	output reg  			CS_b,
	output reg  			SCLK,
	output reg  			MOSI,
	
	// change out_A,B to register (internal latch)
	output reg		[9:0]	out_A,
	output reg		[9:0]	out_B,

	output wire			spi_receiving,
	output wire		[5:0]   ch,

	input wire			SPI_run_continuous
);

	parameter MOD = 0;

	reg 	[9:0]	cntA;
	reg 	[9:0] 	cntB;

	reg		[5:0]	channel;
	reg		[15:0]	MOSI_cmd_A;
	reg		[15:0]	MOSI_cmd_B;
	reg 	[31:0] 	shift_in;
	
	reg		[15:0]	in_A;
	reg		[15:0]	in_B;
	
	reg				sp_rx_reg;

	reg		[31:0]	shift_out;
	wire	[15:0] 	MOSI_cmd_A_selected;
	wire	[15:0]	MOSI_cmd_B_selected;

	
	// see command_selector.v for bias and PGA gain options
	command_selector u_command_selector_A (
		.channel(channel),
		.bias(2'b01), // 2'b01 = internal bias
		.gain(2'b00), 
		.MOSI_cmd(MOSI_cmd_A_selected)
	);

	command_selector u_command_selector_B (
		.channel(channel),
		.bias(2'b01), 
		.gain(2'b00), 
		.MOSI_cmd(MOSI_cmd_B_selected)
	);

	assign spi_receiving = sp_rx_reg;
	assign ch = channel;
	//assign out_A = in_A[9:0];
	//assign out_B = in_B[9:0];

	integer main_state;
	localparam
			ms_wait    = 99,
	        ms_clk1_a  = 100,
			ms_clk1_b  = 101,
            ms_clk1_c  = 102,
            ms_clk1_d  = 103,
			ms_clk2_a  = 104,
			ms_clk2_b  = 105,
            ms_clk2_c  = 106,
            ms_clk2_d  = 107,
			ms_clk3_a  = 108,
			ms_clk3_b  = 109,
            ms_clk3_c  = 110,
            ms_clk3_d  = 111,
			ms_clk4_a  = 112,
			ms_clk4_b  = 113,
            ms_clk4_c  = 114,
            ms_clk4_d  = 115,
			ms_clk5_a  = 116,
			ms_clk5_b  = 117,
            ms_clk5_c  = 118,
            ms_clk5_d  = 119,
			ms_clk6_a  = 120,
			ms_clk6_b  = 121,
            ms_clk6_c  = 122,
            ms_clk6_d  = 123,
			ms_clk7_a  = 124,
		    ms_clk7_b  = 125,
            ms_clk7_c  = 126,
            ms_clk7_d  = 127,
		    ms_clk8_a  = 128,
			ms_clk8_b  = 129,
            ms_clk8_c  = 130,
            ms_clk8_d  = 131,
			ms_clk9_a  = 132,
			ms_clk9_b  = 133,
            ms_clk9_c  = 134,
            ms_clk9_d  = 135,
			ms_clk10_a = 136,
			ms_clk10_b = 137,
            ms_clk10_c = 138,
            ms_clk10_d = 139,
			ms_clk11_a = 140,
			ms_clk11_b = 141,
            ms_clk11_c = 142,
            ms_clk11_d = 143,
			ms_clk12_a = 144,
			ms_clk12_b = 145,
            ms_clk12_c = 146,
            ms_clk12_d = 147,
			ms_clk13_a = 148,
			ms_clk13_b = 149,
            ms_clk13_c = 150,
            ms_clk13_d = 151,
			ms_clk14_a = 152,
			ms_clk14_b = 153,
            ms_clk14_c = 154,
            ms_clk14_d = 155,
			ms_clk15_a = 156,
			ms_clk15_b = 157,
            ms_clk15_c = 158,
            ms_clk15_d = 159,
			ms_clk16_a = 160,
			ms_clk16_b = 161,
            ms_clk16_c = 162,
            ms_clk16_d = 163,
            ms_clk17_a = 164,
            ms_clk17_b = 165,
			ms_cs_a    = 166,
			ms_cs_b    = 167,
			ms_cs_c    = 168,
			ms_cs_d    = 169,
			ms_cs_e    = 170,
			ms_cs_f    = 171,
			ms_cs_g    = 172,
			ms_cs_h    = 173,
			ms_cs_i    = 174,
			ms_cs_j    = 175,
			ms_cs_m    = 176,
			ms_cs_n    = 177,
			ms_cs_o	   = 178,
			ms_cs_p    = 179;	 

	always @(posedge RST or posedge CS_b) begin
		if (RST) begin
			out_A <= 10'd0;
			out_B <= 10'd0;
		end else begin
			out_A <= in_A;
			out_B <= in_B;
		end
	end

	always @(posedge CLK or posedge RST) begin
		if (RST) begin
			main_state <= ms_wait;
			channel <= 6'd0;
			CS_b <= 1'b1;
			SCLK <= 1'b0;
			MOSI <= 1'b0;
			in_A <= 16'b0;
			in_B <= 16'b0;
			sp_rx_reg <= 1'b0;
		end else begin
			CS_b <= 1'b0;
			SCLK <= 1'b0;

			case (main_state)
				ms_wait: begin
					channel <= 6'd0;
					CS_b <= 1'b1;
					SCLK <= 1'b0;
					MOSI <= 1'b0;
					in_A <= 16'b0;
					in_B <= 16'b0;
					sp_rx_reg <= 1'b0;

					if (spi_trig_in) begin
						main_state <= ms_cs_n;
					end
				end

				ms_cs_n: begin
					if (channel == 6'd2) begin
						sp_rx_reg <= 1'b1;
					end
					MOSI_cmd_A <= MOSI_cmd_A_selected;
					MOSI_cmd_B <= MOSI_cmd_B_selected;
					CS_b <= 1'b1;
					main_state <= ms_cs_o;
				end

				ms_cs_o: begin
					main_state <= ms_cs_p;
				end

				ms_cs_p: begin
					main_state <= ms_clk1_a;
				end

				ms_clk1_a: begin
					MOSI <= MOSI_cmd_A[15];
					main_state <= ms_clk1_b;
				end

				ms_clk1_b: begin
					main_state <= ms_clk1_c;
				end

				ms_clk1_c: begin
					SCLK <= 1'b1;
					in_A[15] <= MISO;
					main_state <= ms_clk1_d;
				end

				ms_clk1_d: begin
					MOSI <= MOSI_cmd_A[14];
					main_state <= ms_clk2_a;
				end

				ms_clk2_a: begin
					SCLK <= 1'b1;
					in_A[14] <= MISO;
					main_state <= ms_clk2_b;
				end

				ms_clk2_b: begin
					MOSI <= MOSI_cmd_A[13];
					main_state <= ms_clk2_c;
				end

				ms_clk2_c: begin
					SCLK <= 1'b1;
					in_A[13] <= MISO;
					main_state <= ms_clk2_d;
				end
				
				ms_clk2_d: begin
					MOSI <= MOSI_cmd_A[12];
					main_state <= ms_clk3_a;
				end
				
				ms_clk3_a: begin
					SCLK <= 1'b1;
					in_A[12] <= MISO;
					main_state <= ms_clk3_b;
				end

				ms_clk3_b: begin
					MOSI <= MOSI_cmd_A[11];
					main_state <= ms_clk3_c;
				end

				ms_clk3_c: begin
					SCLK <= 1'b1;
					in_A[11] <= MISO;
					main_state <= ms_clk3_d;
				end
				
				ms_clk3_d: begin
					MOSI <= MOSI_cmd_A[10];
					main_state <= ms_clk4_a;
				end

				ms_clk4_a: begin
					SCLK <= 1'b1;
					in_A[10] <= MISO;
					main_state <= ms_clk4_b;
				end

				ms_clk4_b: begin
					MOSI <= MOSI_cmd_A[9];
					main_state <= ms_clk4_c;
				end

				ms_clk4_c: begin
					SCLK <= 1'b1;
					in_A[9] <= MISO;
					main_state <= ms_clk4_d;
				end
				
				ms_clk4_d: begin
					MOSI <= MOSI_cmd_A[8];
					main_state <= ms_clk5_a;
				end
				
				ms_clk5_a: begin
					SCLK <= 1'b1;
					in_A[8] <= MISO;
					main_state <= ms_clk5_b;
				end

				ms_clk5_b: begin
					MOSI <= MOSI_cmd_A[7];
					main_state <= ms_clk5_c;
				end

				ms_clk5_c: begin
					SCLK <= 1'b1;
					in_A[7] <= MISO;
					main_state <= ms_clk5_d;
				end
				
				ms_clk5_d: begin
					MOSI <= MOSI_cmd_A[6];
					main_state <= ms_clk6_a;
				end
				
				ms_clk6_a: begin
					SCLK <= 1'b1;
					in_A[6] <= MISO;
					main_state <= ms_clk6_b;
				end

				ms_clk6_b: begin
					MOSI <= MOSI_cmd_A[5];
					main_state <= ms_clk6_c;
				end

				ms_clk6_c: begin
					SCLK <= 1'b1;
					in_A[5] <= MISO;
					main_state <= ms_clk6_d;
				end
				
				ms_clk6_d: begin
					MOSI <= MOSI_cmd_A[4];
					main_state <= ms_clk7_a;
				end
				
				ms_clk7_a: begin
					SCLK <= 1'b1;
					in_A[4] <= MISO;
					main_state <= ms_clk7_b;
				end

				ms_clk7_b: begin
					MOSI <= MOSI_cmd_A[3];
					main_state <= ms_clk7_c;
				end

				ms_clk7_c: begin
					SCLK <= 1'b1;
					in_A[3] <= MISO;
					main_state <= ms_clk7_d;
				end
				
				ms_clk7_d: begin
					MOSI <= MOSI_cmd_A[2];
					main_state <= ms_clk8_a;
				end

				ms_clk8_a: begin
					SCLK <= 1'b1;
					in_A[2] <= MISO;
					main_state <= ms_clk8_b;
				end

				ms_clk8_b: begin
					MOSI <= MOSI_cmd_A[1];
					main_state <= ms_clk8_c;
				end

				ms_clk8_c: begin
					SCLK <= 1'b1;
					in_A[1] <= MISO; 
					main_state <= ms_clk8_d;
				end
				
				ms_clk8_d: begin
					MOSI <= MOSI_cmd_A[0];
					main_state <= ms_clk9_a;
				end

				ms_clk9_a: begin
					SCLK <= 1'b1;
					in_A[0] <= MISO;
					main_state <= ms_clk9_b;
				end

				ms_clk9_b: begin
					MOSI <= MOSI_cmd_B[15];
					main_state <= ms_clk9_c;
				end

				ms_clk9_c: begin
					SCLK <= 1'b1;
					in_B[15] <= MISO;
					main_state <= ms_clk9_d;
				end
				
				ms_clk9_d: begin
					MOSI <= MOSI_cmd_B[14];
					main_state <= ms_clk10_a;
				end

				ms_clk10_a: begin
					SCLK <= 1'b1;
					in_B[14] <= MISO;
					main_state <= ms_clk10_b;
				end

				ms_clk10_b: begin
					MOSI <= MOSI_cmd_B[13];
					main_state <= ms_clk10_c;
				end

				ms_clk10_c: begin
					SCLK <= 1'b1;
					in_B[13] <= MISO;
					main_state <= ms_clk10_d;
				end
				
				ms_clk10_d: begin
					MOSI <= MOSI_cmd_B[12];
					main_state <= ms_clk11_a;
				end

				ms_clk11_a: begin
					SCLK <= 1'b1;
					in_B[12] <= MISO;
					main_state <= ms_clk11_b;
				end

				ms_clk11_b: begin
					MOSI <= MOSI_cmd_B[11];
					main_state <= ms_clk11_c;
				end

				ms_clk11_c: begin
					SCLK <= 1'b1;
					in_B[11] <= MISO;
					main_state <= ms_clk11_d;
				end
				
				ms_clk11_d: begin
					MOSI <= MOSI_cmd_B[10];
					main_state <= ms_clk12_a;
				end

				ms_clk12_a: begin
					SCLK <= 1'b1;
					in_B[10] <= MISO;
					main_state <= ms_clk12_b;
				end

				ms_clk12_b: begin
					MOSI <= MOSI_cmd_B[9];
					main_state <= ms_clk12_c;
				end

				ms_clk12_c: begin
					SCLK <= 1'b1;
					in_B[9] <= MISO;
					main_state <= ms_clk12_d;
				end
				
				ms_clk12_d: begin
					MOSI <= MOSI_cmd_B[8];
					main_state <= ms_clk13_a;
				end

				ms_clk13_a: begin
					SCLK <= 1'b1;
					in_B[8] <= MISO;
					main_state <= ms_clk13_b;
				end

				ms_clk13_b: begin
					MOSI <= MOSI_cmd_B[7];
					main_state <= ms_clk13_c;
				end

				ms_clk13_c: begin
					SCLK <= 1'b1;
					in_B[7] <= MISO;
					main_state <= ms_clk13_d;
				end
				
				ms_clk13_d: begin
					MOSI  <= MOSI_cmd_B[6];
					main_state <= ms_clk14_a;
				end

				ms_clk14_a: begin
					SCLK <= 1'b1;
					in_B[6] <= MISO; 
					main_state <= ms_clk14_b;
				end

				ms_clk14_b: begin
					MOSI <= MOSI_cmd_B[5];
					main_state <= ms_clk14_c;
				end

				ms_clk14_c: begin
					SCLK <= 1'b1;
					in_B[5] <= MISO; 
					main_state <= ms_clk14_d;
				end
				
				ms_clk14_d: begin
					MOSI <= MOSI_cmd_B[4];
					main_state <= ms_clk15_a;
				end

				ms_clk15_a: begin
					SCLK <= 1'b1;
					in_B[4] <= MISO;
					main_state <= ms_clk15_b;
				end

				ms_clk15_b: begin
					MOSI <= MOSI_cmd_B[3];
					main_state <= ms_clk15_c;
				end

				ms_clk15_c: begin
					SCLK <= 1'b1;
					in_B[3] <= MISO;
					main_state <= ms_clk15_d;
				end
				
				ms_clk15_d: begin
					MOSI <= MOSI_cmd_B[2];
					main_state <= ms_clk16_a;
				end

				ms_clk16_a: begin
					SCLK <= 1'b1;
					in_B[2] <= MISO;
					main_state <= ms_clk16_b;
				end

				ms_clk16_b: begin
					MOSI <= MOSI_cmd_B[1];
					main_state <= ms_clk16_c;
				end

				ms_clk16_c: begin
					SCLK <= 1'b1;
					in_B[1] <= MISO;
					main_state <= ms_clk16_d;
				end
				
				ms_clk16_d: begin
					MOSI <= MOSI_cmd_B[0];
					main_state <= ms_clk17_a;
				end

				ms_clk17_a: begin
					SCLK <= 1'b1;
					in_B[0] <= MISO;
					main_state <= ms_clk17_b;
				end

				ms_clk17_b: begin
					main_state <= ms_cs_a;
				end

				ms_cs_a: begin
					main_state <= ms_cs_b;
				end

				ms_cs_b: begin
					main_state <= ms_cs_c;
				end

				ms_cs_c: begin
					main_state <= ms_cs_d;
				end
				
				ms_cs_d: begin
					main_state <= ms_cs_e;
				end
				
				ms_cs_e: begin
					CS_b <= 1'b1;
					main_state <= ms_cs_f;
				end
				
				ms_cs_f: begin
					CS_b <= 1'b1;
					main_state <= ms_cs_g;
				end
				
				ms_cs_g: begin
					CS_b <= 1'b1;
					main_state <= ms_cs_h;
				end
				
				ms_cs_h: begin
					CS_b <= 1'b1;
					main_state <= ms_cs_i;
				end
				
				ms_cs_i: begin
					CS_b <= 1'b1;
					main_state <= ms_cs_j;
				end
				
				ms_cs_j: begin
					CS_b <= 1'b1;
					main_state <= ms_cs_m;
				end
				
				ms_cs_m: begin
					if (channel == 6'd15) begin
						channel <= 6'd0;
					end else begin
						channel <= channel + 6'b1;
					end
					CS_b <= 1'b1;	
					main_state <= ms_cs_n;
				end
								
				default: begin
					main_state <= ms_wait;
				end
				
			endcase
		end
	end
endmodule

