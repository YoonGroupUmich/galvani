`timescale 1ns/10ps

`ifndef UD
`define UD #1
`endif


module spi_master256 (
	
	input wire			CLK, 
	input wire			RST,
	input wire  		[7:0]	MISO,
	input wire			[15:0] fake_data,

	output reg  			CS_b,
	output reg  			SCLK,
	output reg  			MOSI,
	output reg		[9:0]	outA,
	output reg		[9:0]	outB,
	output reg			sync_ni,
	output reg		[5:0]   channel,
	output reg			clk_ni,
	output reg			data_valid,
	output reg			spi_receiving,
	input wire			spi_trig_in,
	input wire			SPI_run_continuous,
	
	input wire [127:0] trig_out,
	output wire trig_out_ni
);

	reg		[15:0]	MOSI_cmd_A;
	reg		[15:0]	MOSI_cmd_B;
	
	reg		[15:0]	in_A0;
	reg		[15:0]	in_A1;
	reg		[15:0]	in_A2;
	reg		[15:0]	in_A3;
	reg		[15:0]	in_A4;
	reg		[15:0]	in_A5;
	reg		[15:0]	in_A6;
	reg		[15:0]	in_A7;
	reg		[15:0]	in_B0;
	reg		[15:0]	in_B1;
	reg		[15:0]	in_B2;
	reg		[15:0]	in_B3;
	reg		[15:0]	in_B4;
	reg		[15:0]	in_B5;
	reg		[15:0]	in_B6;
	reg		[15:0]	in_B7;

	// for time division multiplexing
	reg		[9:0]	tmp_A0;
	reg		[9:0]	tmp_A1;
	reg		[9:0]	tmp_A2;
	reg		[9:0]	tmp_A3;
	reg		[9:0]	tmp_A4;
	reg		[9:0]	tmp_A5;
	reg		[9:0]	tmp_A6;
	reg		[9:0]	tmp_A7;
	reg		[9:0]	tmp_B0;
	reg		[9:0]	tmp_B1;
	reg		[9:0]	tmp_B2;
	reg		[9:0]	tmp_B3;
	reg		[9:0]	tmp_B4;
	reg		[9:0]	tmp_B5;
	reg		[9:0]	tmp_B6;
	reg		[9:0]	tmp_B7;
	
	wire	[15:0] 	MOSI_cmd_A_selected;
	wire	[15:0]	MOSI_cmd_B_selected;
	
	reg [6:0] trig_out_channel;
	assign trig_out_ni = trig_out[trig_out_channel];

	localparam	
		debug_with_fake_data = 1'b1;

	localparam
		bias = 2'b01, // 00 = off, 01 = internal, 10 = forbidden, 11 = external
		gain = 2'b10; // 00 = 0 dB, 01 = 5.6 dB, 10 = 9 dB, 11 = 20 dB

	command_selector u_command_selector_A (
		.channel(channel),
		.bias(bias), 
		.gain(gain),
		.MOSI_cmd(MOSI_cmd_A_selected)
	);

	command_selector u_command_selector_B (
		.channel(channel),
		.bias(bias), 
		.gain(gain), 
		.MOSI_cmd(MOSI_cmd_B_selected)
	);

	integer main_state;

	localparam
		ms_wait    = 100,
		ms_cs_n    = 101, // clk_ni <= `UD 1'b0; 
		ms_clk1_a  = 102, // clk_ni <= `UD 1'b0; 
		ms_clk1_b  = 103, // clk_ni <= `UD 1'b0; 
		ms_clk1_c  = 104, // clk_ni <= `UD 1'b0; 
		ms_clk1_d  = 105, // clk_ni <= `UD 1'b0; 
		ms_clk2_a  = 106, // clk_ni <= `UD 1'b1; 
		ms_clk2_b  = 107, // clk_ni <= `UD 1'b1; 
		ms_clk2_c  = 108, // clk_ni <= `UD 1'b1; 
		ms_clk2_d  = 109, // clk_ni <= `UD 1'b1; 
		ms_clk3_a  = 110, // clk_ni <= `UD 1'b1; 
		ms_clk3_b  = 111, // clk_ni <= `UD 1'b0; etc...
		ms_clk3_c  = 112,
		ms_clk3_d  = 113,
		ms_clk4_a  = 114,
		ms_clk4_b  = 115,
		ms_clk4_c  = 116,
		ms_clk4_d  = 117,
		ms_clk5_a  = 118,
		ms_clk5_b  = 119,
		ms_clk5_c  = 120,
		ms_clk5_d  = 121,
		ms_clk6_a  = 122,
		ms_clk6_b  = 123,
		ms_clk6_c  = 124,
		ms_clk6_d  = 125,
		ms_clk7_a  = 126,
		ms_clk7_b  = 127,
		ms_clk7_c  = 128,
		ms_clk7_d  = 129,
		ms_clk8_a  = 130,
		ms_clk8_b  = 131,
		ms_clk8_c  = 132,
		ms_clk8_d  = 133,
		ms_clk9_a  = 134,
		ms_clk9_b  = 135,
		ms_clk9_c  = 136,
		ms_clk9_d  = 137,
		ms_clk10_a = 138,
		ms_clk10_b = 139,
		ms_clk10_c = 140,
		ms_clk10_d = 141,
		ms_clk11_a = 142,
		ms_clk11_b = 143,
		ms_clk11_c = 144,
		ms_clk11_d = 145,
		ms_clk12_a = 146,
		ms_clk12_b = 147,
		ms_clk12_c = 148,
		ms_clk12_d = 149,
		ms_clk13_a = 150,
		ms_clk13_b = 151,
		ms_clk13_c = 152,
		ms_clk13_d = 153,
		ms_clk14_a = 154,
		ms_clk14_b = 155,
		ms_clk14_c = 156,
		ms_clk14_d = 157,
		ms_clk15_a = 158,
		ms_clk15_b = 159,
		ms_clk15_c = 160,
		ms_clk15_d = 161,
		ms_clk16_a = 162,
		ms_clk16_b = 163,
		ms_clk16_c = 164,
		ms_clk16_d = 165,
		ms_clk17_a = 166,
		ms_clk17_b = 167,
		ms_cs_a    = 168,
		ms_cs_b    = 169,
		ms_cs_c    = 170,
		ms_cs_d    = 171,
		ms_cs_e    = 172,
		ms_cs_f    = 173,
		ms_cs_g    = 174,
		ms_cs_h    = 175,
		ms_cs_i    = 176,
		ms_cs_j    = 177,
		ms_cs_k    = 178, 
		ms_cs_l    = 179,
		ms_cs_m    = 180;

	always @(posedge RST or posedge CLK) begin
		if (RST) begin
			main_state <= `UD ms_wait; // 99
			channel <= `UD 0;
			sync_ni <= `UD 1'b0;
			spi_receiving <= `UD 1'b0;
			CS_b <= `UD 1'b1;
			SCLK <= `UD 1'b0;
			MOSI <= `UD 1'b0;
			in_A0 <= `UD 16'h0000;
			in_A1 <= `UD 16'h0000;
			in_A2 <= `UD 16'h0000;
			in_A3 <= `UD 16'h0000;
			in_A4 <= `UD 16'h0000;
			in_A5 <= `UD 16'h0000;
			in_A6 <= `UD 16'h0000;
			in_A7 <= `UD 16'h0000;
			in_B0 <= `UD 16'h0000;
			in_B1 <= `UD 16'h0000;
			in_B2 <= `UD 16'h0000;
			in_B3 <= `UD 16'h0000;
			in_B4 <= `UD 16'h0000;
			in_B5 <= `UD 16'h0000;
			in_B6 <= `UD 16'h0000;
			in_B7 <= `UD 16'h0000;
			tmp_A0 <= `UD 10'h000;
			tmp_A1 <= `UD 10'h000;
			tmp_A2 <= `UD 10'h000;
			tmp_A3 <= `UD 10'h000;
			tmp_A4 <= `UD 10'h000;
			tmp_A5 <= `UD 10'h000;
			tmp_A6 <= `UD 10'h000;
			tmp_A7 <= `UD 10'h000;
			tmp_B0 <= `UD 10'h000;
			tmp_B1 <= `UD 10'h000;
			tmp_B2 <= `UD 10'h000;
			tmp_B3 <= `UD 10'h000;
			tmp_B4 <= `UD 10'h000;
			tmp_B5 <= `UD 10'h000;
			tmp_B6 <= `UD 10'h000;
			tmp_B7 <= `UD 10'h000;
			outA <= `UD 10'h000;
			outB <= `UD 10'h000;
			clk_ni <= `UD 0;
			data_valid <= `UD 1'b0;
			
			trig_out_channel <= 7'h0;
		end else begin
			CS_b <= `UD 1'b0;
			SCLK <= `UD 1'b0;
			clk_ni <= `UD 1'b0;
			sync_ni <= `UD 1'b0;

			case (main_state)
				ms_wait: begin // 100
					channel <= `UD 0;
					sync_ni <= `UD 1'b0;
					CS_b <= `UD 1'b1;
					SCLK <= `UD 1'b0;
					MOSI <= `UD 1'b0;
					in_A0 <= `UD 16'h0000;
					in_A1 <= `UD 16'h0000;
					in_A2 <= `UD 16'h0000;
					in_A3 <= `UD 16'h0000;
					in_A4 <= `UD 16'h0000;
					in_A5 <= `UD 16'h0000;
					in_A6 <= `UD 16'h0000;
					in_A7 <= `UD 16'h0000;
					in_B0 <= `UD 16'h0000;
					in_B1 <= `UD 16'h0000;
					in_B2 <= `UD 16'h0000;
					in_B3 <= `UD 16'h0000;
					in_B4 <= `UD 16'h0000;
					in_B5 <= `UD 16'h0000;
					in_B6 <= `UD 16'h0000;
					in_B7 <= `UD 16'h0000;
					tmp_A0 <= `UD 10'h000;
					tmp_A1 <= `UD 10'h000;
					tmp_A2 <= `UD 10'h000;
					tmp_A3 <= `UD 10'h000;
					tmp_A4 <= `UD 10'h000;
					tmp_A5 <= `UD 10'h000;
					tmp_A6 <= `UD 10'h000;
					tmp_A7 <= `UD 10'h000;
					tmp_B0 <= `UD 10'h000;
					tmp_B1 <= `UD 10'h000;
					tmp_B2 <= `UD 10'h000;
					tmp_B3 <= `UD 10'h000;
					tmp_B4 <= `UD 10'h000;
					tmp_B5 <= `UD 10'h000;
					tmp_B6 <= `UD 10'h000;
					tmp_B7 <= `UD 10'h000;
					outA <= `UD 10'h000;
					outB <= `UD 10'h000;
					clk_ni <= `UD 0;
					data_valid <= `UD 1'b0;
					if (spi_trig_in) begin
						main_state <= `UD ms_cs_n;
					end
				end

				ms_cs_n: begin // 101
					if (data_valid) begin
						outA <= `UD tmp_A0;
						outB <= `UD tmp_B0;
					end
					if (3 == channel) begin
						sync_ni <= `UD 1'b1;
						trig_out_channel <= 7'h0;
					end else begin
						trig_out_channel <= trig_out_channel + 7'h1;
					end
					MOSI_cmd_A <= `UD MOSI_cmd_A_selected;
					MOSI_cmd_B <= `UD MOSI_cmd_B_selected;
					CS_b <= `UD 1'b1;
					main_state <= `UD ms_clk1_a;
				end

				ms_clk1_a: begin // 102
					if (3 == channel) begin
						sync_ni <= `UD 1'b1;
						spi_receiving <= `UD 1'b1; 
					end
					MOSI <= `UD MOSI_cmd_A[15];
					main_state <= `UD ms_clk1_b;
				end

				ms_clk1_b: begin // 103
					if (3 == channel) begin
						sync_ni <= `UD 1'b1;
					end
					main_state <= `UD ms_clk1_c;
				end

				ms_clk1_c: begin // 104
					if (3 == channel) begin
						sync_ni <= `UD 1'b1;
					end
					SCLK <= `UD 1'b1;
					in_A0[15] <= `UD MISO[0];
					in_A1[15] <= `UD MISO[1];
					in_A2[15] <= `UD MISO[2];
					in_A3[15] <= `UD MISO[3];
					in_A4[15] <= `UD MISO[4];
					in_A5[15] <= `UD MISO[5];
					in_A6[15] <= `UD MISO[6];
					in_A7[15] <= `UD MISO[7];
					main_state <= `UD ms_clk1_d;
				end

				ms_clk1_d: begin // 105
					if (3 == channel) begin
						sync_ni <= `UD 1'b1;
					end
					MOSI <= `UD MOSI_cmd_A[14];
					main_state <= `UD ms_clk2_a;
				end

				ms_clk2_a: begin // 106
					if (3 == channel) begin
						sync_ni <= `UD 1'b1;
					end
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_A0[14] <= `UD MISO[0];
					in_A1[14] <= `UD MISO[1];
					in_A2[14] <= `UD MISO[2];
					in_A3[14] <= `UD MISO[3];
					in_A4[14] <= `UD MISO[4];
					in_A5[14] <= `UD MISO[5];
					in_A6[14] <= `UD MISO[6];
					in_A7[14] <= `UD MISO[7];
					main_state <= `UD ms_clk2_b;
				end

				ms_clk2_b: begin // 107
					if (3 == channel) begin
						sync_ni <= `UD 1'b1;
					end
					clk_ni <= `UD 1'b1;
					MOSI <= `UD MOSI_cmd_A[13];
					main_state <= `UD ms_clk2_c;
				end

				ms_clk2_c: begin // 108
					if (3 == channel) begin
						sync_ni <= `UD 1'b1;
					end
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_A0[13] <= `UD MISO[0];
					in_A1[13] <= `UD MISO[1];
					in_A2[13] <= `UD MISO[2];
					in_A3[13] <= `UD MISO[3];
					in_A4[13] <= `UD MISO[4];
					in_A5[13] <= `UD MISO[5];
					in_A6[13] <= `UD MISO[6];
					in_A7[13] <= `UD MISO[7];
					main_state <= `UD ms_clk2_d;
				end
				
				ms_clk2_d: begin // 109
					if (3 == channel) begin
						sync_ni <= `UD 1'b1;
					end
					clk_ni <= `UD 1'b1;
					MOSI <= `UD MOSI_cmd_A[12];
					main_state <= `UD ms_clk3_a;
				end
				
				ms_clk3_a: begin // 110
					if (3 == channel) begin
						sync_ni <= `UD 1'b1;
					end
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_A0[12] <= `UD MISO[0];
					in_A1[12] <= `UD MISO[1];
					in_A2[12] <= `UD MISO[2];
					in_A3[12] <= `UD MISO[3];
					in_A4[12] <= `UD MISO[4];
					in_A5[12] <= `UD MISO[5];
					in_A6[12] <= `UD MISO[6];
					in_A7[12] <= `UD MISO[7];
					main_state <= `UD ms_clk3_b;
				end

				ms_clk3_b: begin // 111 
					if (data_valid) begin
						outA <= `UD tmp_A1; // negedge of clk_ni
						outB <= `UD tmp_B1;
						trig_out_channel <= trig_out_channel + 7'h1;
					end
					MOSI <= `UD MOSI_cmd_A[11];
					main_state <= `UD ms_clk3_c;
				end

				ms_clk3_c: begin // 112
					SCLK <= `UD 1'b1;
					in_A0[11] <= `UD MISO[0];
					in_A1[11] <= `UD MISO[1];
					in_A2[11] <= `UD MISO[2];
					in_A3[11] <= `UD MISO[3];
					in_A4[11] <= `UD MISO[4];
					in_A5[11] <= `UD MISO[5];
					in_A6[11] <= `UD MISO[6];
					in_A7[11] <= `UD MISO[7];
					main_state <= `UD ms_clk3_d;
				end
				
				ms_clk3_d: begin // 113
					MOSI <= `UD MOSI_cmd_A[10];
					main_state <= `UD ms_clk4_a;
				end

				ms_clk4_a: begin // 114
					SCLK <= `UD 1'b1;
					in_A0[10] <= `UD MISO[0];
					in_A1[10] <= `UD MISO[1];
					in_A2[10] <= `UD MISO[2];
					in_A3[10] <= `UD MISO[3];
					in_A4[10] <= `UD MISO[4];
					in_A5[10] <= `UD MISO[5];
					in_A6[10] <= `UD MISO[6];
					in_A7[10] <= `UD MISO[7];
					main_state <= `UD ms_clk4_b;
				end

				ms_clk4_b: begin // 115
					MOSI <= `UD MOSI_cmd_A[9];
					main_state <= `UD ms_clk4_c;
				end

				ms_clk4_c: begin // 116
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_A0[9] <= `UD MISO[0];
					in_A1[9] <= `UD MISO[1];
					in_A2[9] <= `UD MISO[2];
					in_A3[9] <= `UD MISO[3];
					in_A4[9] <= `UD MISO[4];
					in_A5[9] <= `UD MISO[5];
					in_A6[9] <= `UD MISO[6];
					in_A7[9] <= `UD MISO[7];
					main_state <= `UD ms_clk4_d;
				end
				
				ms_clk4_d: begin // 117
					clk_ni <= `UD 1'b1;
					MOSI <= `UD MOSI_cmd_A[8];
					main_state <= `UD ms_clk5_a;
				end
				
				ms_clk5_a: begin // 118
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_A0[8] <= `UD MISO[0];
					in_A1[8] <= `UD MISO[1];
					in_A2[8] <= `UD MISO[2];
					in_A3[8] <= `UD MISO[3];
					in_A4[8] <= `UD MISO[4];
					in_A5[8] <= `UD MISO[5];
					in_A6[8] <= `UD MISO[6];
					in_A7[8] <= `UD MISO[7];
					main_state <= `UD ms_clk5_b;
				end

				ms_clk5_b: begin // 119
					clk_ni <= `UD 1'b1;
					MOSI <= `UD MOSI_cmd_A[7];
					main_state <= `UD ms_clk5_c;
				end

				ms_clk5_c: begin // 120
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_A0[7] <= `UD MISO[0];
					in_A1[7] <= `UD MISO[1];
					in_A2[7] <= `UD MISO[2];
					in_A3[7] <= `UD MISO[3];
					in_A4[7] <= `UD MISO[4];
					in_A5[7] <= `UD MISO[5];
					in_A6[7] <= `UD MISO[6];
					in_A7[7] <= `UD MISO[7];
					main_state <= `UD ms_clk5_d;
				end
				
				ms_clk5_d: begin // 121
					if (data_valid) begin
						outA <= `UD tmp_A2;
						outB <= `UD tmp_B2;
						trig_out_channel <= trig_out_channel + 7'h1;
					end
					MOSI <= `UD MOSI_cmd_A[6];
					main_state <= `UD ms_clk6_a;
				end
				
				ms_clk6_a: begin // 122
					SCLK <= `UD 1'b1;
					in_A0[6] <= `UD MISO[0];
					in_A1[6] <= `UD MISO[1];
					in_A2[6] <= `UD MISO[2];
					in_A3[6] <= `UD MISO[3];
					in_A4[6] <= `UD MISO[4];
					in_A5[6] <= `UD MISO[5];
					in_A6[6] <= `UD MISO[6];
					in_A7[6] <= `UD MISO[7];
					main_state <= `UD ms_clk6_b;
				end

				ms_clk6_b: begin // 123
					MOSI <= `UD MOSI_cmd_A[5];
					main_state <= `UD ms_clk6_c;
				end

				ms_clk6_c: begin // 124
					SCLK <= `UD 1'b1;
					in_A0[5] <= `UD MISO[0];
					in_A1[5] <= `UD MISO[1];
					in_A2[5] <= `UD MISO[2];
					in_A3[5] <= `UD MISO[3];
					in_A4[5] <= `UD MISO[4];
					in_A5[5] <= `UD MISO[5];
					in_A6[5] <= `UD MISO[6];
					in_A7[5] <= `UD MISO[7];
					main_state <= `UD ms_clk6_d;
				end
				
				ms_clk6_d: begin // 125
					MOSI <= `UD MOSI_cmd_A[4];
					main_state <= `UD ms_clk7_a;
				end
				
				ms_clk7_a: begin // 126
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_A0[4] <= `UD MISO[0];
					in_A1[4] <= `UD MISO[1];
					in_A2[4] <= `UD MISO[2];
					in_A3[4] <= `UD MISO[3];
					in_A4[4] <= `UD MISO[4];
					in_A5[4] <= `UD MISO[5];
					in_A6[4] <= `UD MISO[6];
					in_A7[4] <= `UD MISO[7];
					main_state <= `UD ms_clk7_b;
				end

				ms_clk7_b: begin // 127
					clk_ni <= `UD 1'b1;
					MOSI <= `UD MOSI_cmd_A[3];
					main_state <= `UD ms_clk7_c;
				end

				ms_clk7_c: begin // 128
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_A0[3] <= `UD MISO[0];
					in_A1[3] <= `UD MISO[1];
					in_A2[3] <= `UD MISO[2];
					in_A3[3] <= `UD MISO[3];
					in_A4[3] <= `UD MISO[4];
					in_A5[3] <= `UD MISO[5];
					in_A6[3] <= `UD MISO[6];
					in_A7[3] <= `UD MISO[7];
					main_state <= `UD ms_clk7_d;
				end
				
				ms_clk7_d: begin // 129
					clk_ni <= `UD 1'b1;
					MOSI <= `UD MOSI_cmd_A[2];
					main_state <= `UD ms_clk8_a;
				end

				ms_clk8_a: begin // 130
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_A0[2] <= `UD MISO[0];
					in_A1[2] <= `UD MISO[1];
					in_A2[2] <= `UD MISO[2];
					in_A3[2] <= `UD MISO[3];
					in_A4[2] <= `UD MISO[4];
					in_A5[2] <= `UD MISO[5];
					in_A6[2] <= `UD MISO[6];
					in_A7[2] <= `UD MISO[7];
					main_state <= `UD ms_clk8_b;
				end

				ms_clk8_b: begin // 131
					if (data_valid) begin
						outA <= `UD tmp_A3;
						outB <= `UD tmp_B3;
						trig_out_channel <= trig_out_channel + 7'h1;
					end
					MOSI <= `UD MOSI_cmd_A[1];
					main_state <= `UD ms_clk8_c;
				end

				ms_clk8_c: begin // 132
					SCLK <= `UD 1'b1;
					in_A0[1] <= `UD MISO[0]; 
					in_A1[1] <= `UD MISO[1]; 
					in_A2[1] <= `UD MISO[2]; 
					in_A3[1] <= `UD MISO[3]; 
					in_A4[1] <= `UD MISO[4]; 
					in_A5[1] <= `UD MISO[5]; 
					in_A6[1] <= `UD MISO[6]; 
					in_A7[1] <= `UD MISO[7]; 
					main_state <= `UD ms_clk8_d;
				end
				
				ms_clk8_d: begin // 133
					MOSI <= `UD MOSI_cmd_A[0];
					main_state <= `UD ms_clk9_a;
				end

				ms_clk9_a: begin // 134
					SCLK <= `UD 1'b1;
					in_A0[0] <= `UD MISO[0];
					in_A1[0] <= `UD MISO[1];
					in_A2[0] <= `UD MISO[2];
					in_A3[0] <= `UD MISO[3];
					in_A4[0] <= `UD MISO[4];
					in_A5[0] <= `UD MISO[5];
					in_A6[0] <= `UD MISO[6];
					in_A7[0] <= `UD MISO[7];
					main_state <= `UD ms_clk9_b;
				end

				ms_clk9_b: begin // 135
					MOSI <= `UD MOSI_cmd_B[15];
					main_state <= `UD ms_clk9_c;
				end
				ms_clk9_c: begin // 136
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_B0[15] <= `UD MISO[0];
					in_B1[15] <= `UD MISO[1];
					in_B2[15] <= `UD MISO[2];
					in_B3[15] <= `UD MISO[3];
					in_B4[15] <= `UD MISO[4];
					in_B5[15] <= `UD MISO[5];
					in_B6[15] <= `UD MISO[6];
					in_B7[15] <= `UD MISO[7];
					main_state <= `UD ms_clk9_d;
				end
				
				ms_clk9_d: begin // 137
					clk_ni <= `UD 1'b1;
					MOSI <= `UD MOSI_cmd_B[14];
					main_state <= `UD ms_clk10_a;
				end

				ms_clk10_a: begin // 138
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_B0[14] <= `UD MISO[0];
					in_B1[14] <= `UD MISO[1];
					in_B2[14] <= `UD MISO[2];
					in_B3[14] <= `UD MISO[3];
					in_B4[14] <= `UD MISO[4];
					in_B5[14] <= `UD MISO[5];
					in_B6[14] <= `UD MISO[6];
					in_B7[14] <= `UD MISO[7];
					main_state <= `UD ms_clk10_b;
				end

				ms_clk10_b: begin // 139
					clk_ni <= `UD 1'b1;
					MOSI <= `UD MOSI_cmd_B[13];
					main_state <= `UD ms_clk10_c;
				end

				ms_clk10_c: begin // 140
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_B0[13] <= `UD MISO[0];
					in_B1[13] <= `UD MISO[1];
					in_B2[13] <= `UD MISO[2];
					in_B3[13] <= `UD MISO[3];
					in_B4[13] <= `UD MISO[4];
					in_B5[13] <= `UD MISO[5];
					in_B6[13] <= `UD MISO[6];
					in_B7[13] <= `UD MISO[7];
					main_state <= `UD ms_clk10_d;
				end
				
				ms_clk10_d: begin // 141
					if (data_valid) begin
						outA <= `UD tmp_A4;
						outB <= `UD tmp_B4;
						trig_out_channel <= trig_out_channel + 7'h1;
					end
					MOSI <= `UD MOSI_cmd_B[12];
					main_state <= `UD ms_clk11_a;
				end

				ms_clk11_a: begin // 142
					SCLK <= `UD 1'b1;
					in_B0[12] <= `UD MISO[0];
					in_B1[12] <= `UD MISO[1];
					in_B2[12] <= `UD MISO[2];
					in_B3[12] <= `UD MISO[3];
					in_B4[12] <= `UD MISO[4];
					in_B5[12] <= `UD MISO[5];
					in_B6[12] <= `UD MISO[6];
					in_B7[12] <= `UD MISO[7];
					main_state <= `UD ms_clk11_b;
				end

				ms_clk11_b: begin // 143
					MOSI <= `UD MOSI_cmd_B[11];
					main_state <= `UD ms_clk11_c;
				end

				ms_clk11_c: begin // 144
					SCLK <= `UD 1'b1;
					in_B0[11] <= `UD MISO[0];
					in_B1[11] <= `UD MISO[1];
					in_B2[11] <= `UD MISO[2];
					in_B3[11] <= `UD MISO[3];
					in_B4[11] <= `UD MISO[4];
					in_B5[11] <= `UD MISO[5];
					in_B6[11] <= `UD MISO[6];
					in_B7[11] <= `UD MISO[7];
					main_state <= `UD ms_clk11_d;
				end
				
				ms_clk11_d: begin // 145
					MOSI <= `UD MOSI_cmd_B[10];
					main_state <= `UD ms_clk12_a;
				end

				ms_clk12_a: begin // 146
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_B0[10] <= `UD MISO[0];
					in_B1[10] <= `UD MISO[1];
					in_B2[10] <= `UD MISO[2];
					in_B3[10] <= `UD MISO[3];
					in_B4[10] <= `UD MISO[4];
					in_B5[10] <= `UD MISO[5];
					in_B6[10] <= `UD MISO[6];
					in_B7[10] <= `UD MISO[7];
					main_state <= `UD ms_clk12_b;
				end

				ms_clk12_b: begin // 147
					clk_ni <= `UD 1'b1;
					MOSI <= `UD MOSI_cmd_B[9];
					main_state <= `UD ms_clk12_c;
				end

				ms_clk12_c: begin // 148
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_B0[9] <= `UD MISO[0];
					in_B1[9] <= `UD MISO[1];
					in_B2[9] <= `UD MISO[2];
					in_B3[9] <= `UD MISO[3];
					in_B4[9] <= `UD MISO[4];
					in_B5[9] <= `UD MISO[5];
					in_B6[9] <= `UD MISO[6];
					in_B7[9] <= `UD MISO[7];
					main_state <= `UD ms_clk12_d;
				end
				
				ms_clk12_d: begin // 149
					clk_ni <= `UD 1'b1;
					MOSI <= `UD MOSI_cmd_B[8];
					main_state <= `UD ms_clk13_a;
				end

				ms_clk13_a: begin // 150
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_B0[8] <= `UD MISO[0];
					in_B1[8] <= `UD MISO[1];
					in_B2[8] <= `UD MISO[2];
					in_B3[8] <= `UD MISO[3];
					in_B4[8] <= `UD MISO[4];
					in_B5[8] <= `UD MISO[5];
					in_B6[8] <= `UD MISO[6];
					in_B7[8] <= `UD MISO[7];
					main_state <= `UD ms_clk13_b;
				end

				ms_clk13_b: begin // 151
					if (data_valid) begin
						outA <= `UD tmp_A5;
						outB <= `UD tmp_B5;
						trig_out_channel <= trig_out_channel + 7'h1;
					end
					MOSI <= `UD MOSI_cmd_B[7];
					main_state <= `UD ms_clk13_c;
				end

				ms_clk13_c: begin // 152
					SCLK <= `UD 1'b1;
					in_B0[7] <= `UD MISO[0];
					in_B1[7] <= `UD MISO[1];
					in_B2[7] <= `UD MISO[2];
					in_B3[7] <= `UD MISO[3];
					in_B4[7] <= `UD MISO[4];
					in_B5[7] <= `UD MISO[5];
					in_B6[7] <= `UD MISO[6];
					in_B7[7] <= `UD MISO[7];
					main_state <= `UD ms_clk13_d;
				end
				
				ms_clk13_d: begin // 153
					MOSI  <= `UD MOSI_cmd_B[6];
					main_state <= `UD ms_clk14_a;
				end

				ms_clk14_a: begin // 154
					SCLK <= `UD 1'b1;
					in_B0[6] <= `UD MISO[0]; 
					in_B1[6] <= `UD MISO[1]; 
					in_B2[6] <= `UD MISO[2]; 
					in_B3[6] <= `UD MISO[3]; 
					in_B4[6] <= `UD MISO[4]; 
					in_B5[6] <= `UD MISO[5]; 
					in_B6[6] <= `UD MISO[6]; 
					in_B7[6] <= `UD MISO[7]; 
					main_state <= `UD ms_clk14_b;
				end

				ms_clk14_b: begin // 155
					MOSI <= `UD MOSI_cmd_B[5];
					main_state <= `UD ms_clk14_c;
				end

				ms_clk14_c: begin // 156
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_B0[5] <= `UD MISO[0]; 
					in_B1[5] <= `UD MISO[1]; 
					in_B2[5] <= `UD MISO[2]; 
					in_B3[5] <= `UD MISO[3]; 
					in_B4[5] <= `UD MISO[4]; 
					in_B5[5] <= `UD MISO[5]; 
					in_B6[5] <= `UD MISO[6]; 
					in_B7[5] <= `UD MISO[7]; 
					main_state <= `UD ms_clk14_d;
				end
				
				ms_clk14_d: begin // 157
					clk_ni <= `UD 1'b1;
					MOSI <= `UD MOSI_cmd_B[4];
					main_state <= `UD ms_clk15_a;
				end

				ms_clk15_a: begin // 158
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_B0[4] <= `UD MISO[0];
					in_B1[4] <= `UD MISO[1];
					in_B2[4] <= `UD MISO[2];
					in_B3[4] <= `UD MISO[3];
					in_B4[4] <= `UD MISO[4];
					in_B5[4] <= `UD MISO[5];
					in_B6[4] <= `UD MISO[6];
					in_B7[4] <= `UD MISO[7];
					main_state <= `UD ms_clk15_b;
				end

				ms_clk15_b: begin // 159
					clk_ni <= `UD 1'b1;
					MOSI <= `UD MOSI_cmd_B[3];
					main_state <= `UD ms_clk15_c;
				end

				ms_clk15_c: begin // 160
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_B0[3] <= `UD MISO[0];
					in_B1[3] <= `UD MISO[1];
					in_B2[3] <= `UD MISO[2];
					in_B3[3] <= `UD MISO[3];
					in_B4[3] <= `UD MISO[4];
					in_B5[3] <= `UD MISO[5];
					in_B6[3] <= `UD MISO[6];
					in_B7[3] <= `UD MISO[7];
					main_state <= `UD ms_clk15_d;
				end
				
				ms_clk15_d: begin // 161
					if (data_valid) begin
						outA <= `UD tmp_A6;
						outB <= `UD tmp_B6;
						trig_out_channel <= trig_out_channel + 7'h1;
					end
					MOSI <= `UD MOSI_cmd_B[2];
					main_state <= `UD ms_clk16_a;
				end

				ms_clk16_a: begin // 162
					SCLK <= `UD 1'b1;
					in_B0[2] <= `UD MISO[0];
					in_B1[2] <= `UD MISO[1];
					in_B2[2] <= `UD MISO[2];
					in_B3[2] <= `UD MISO[3];
					in_B4[2] <= `UD MISO[4];
					in_B5[2] <= `UD MISO[5];
					in_B6[2] <= `UD MISO[6];
					in_B7[2] <= `UD MISO[7];
					main_state <= `UD ms_clk16_b;
				end

				ms_clk16_b: begin // 163
					MOSI <= `UD MOSI_cmd_B[1];
					main_state <= `UD ms_clk16_c;
				end

				ms_clk16_c: begin // 164
					SCLK <= `UD 1'b1;
					in_B0[1] <= `UD MISO[0];
					in_B1[1] <= `UD MISO[1];
					in_B2[1] <= `UD MISO[2];
					in_B3[1] <= `UD MISO[3];
					in_B4[1] <= `UD MISO[4];
					in_B5[1] <= `UD MISO[5];
					in_B6[1] <= `UD MISO[6];
					in_B7[1] <= `UD MISO[7];
					main_state <= `UD ms_clk16_d;
				end
				
				ms_clk16_d: begin // 165
					MOSI <= `UD MOSI_cmd_B[0];
					main_state <= `UD ms_clk17_a;
				end

				ms_clk17_a: begin // 166
					clk_ni <= `UD 1'b1;
					SCLK <= `UD 1'b1;
					in_B0[0] <= `UD MISO[0];
					in_B1[0] <= `UD MISO[1];
					in_B2[0] <= `UD MISO[2];
					in_B3[0] <= `UD MISO[3];
					in_B4[0] <= `UD MISO[4];
					in_B5[0] <= `UD MISO[5];
					in_B6[0] <= `UD MISO[6];
					in_B7[0] <= `UD MISO[7];
					main_state <= `UD ms_clk17_b;
				end

				ms_clk17_b: begin // 167
					clk_ni <= `UD 1'b1;
					main_state <= `UD ms_cs_a;
				end

				ms_cs_a: begin // 168
					clk_ni <= `UD 1'b1;
					MOSI <= `UD 1'bz;
					CS_b <= `UD 1'b1;
					main_state <= `UD ms_cs_b;
				end

				ms_cs_b: begin // 169
					clk_ni <= `UD 1'b1;
					CS_b <= `UD 1'b1;
					main_state <= `UD ms_cs_c;
				end

				ms_cs_c: begin // 170
					clk_ni <= `UD 1'b1;
					CS_b <= `UD 1'b1;
					main_state <= `UD ms_cs_d;
				end
				
				ms_cs_d: begin // 171
					if (data_valid) begin
						outA <= `UD tmp_A7;
						outB <= `UD tmp_B7;
						trig_out_channel <= trig_out_channel + 7'h1;
					end
					CS_b <= `UD 1'b1;
					main_state <= `UD ms_cs_e;
				end
				
				ms_cs_e: begin // 172
					CS_b <= `UD 1'b1;
					main_state <= `UD ms_cs_f;
				end
				
				ms_cs_f: begin // 173
					CS_b <= `UD 1'b1;
					main_state <= `UD ms_cs_g;
				end
				
				ms_cs_g: begin // 174
					CS_b <= `UD 1'b1;
					main_state <= `UD ms_cs_h;
				end
				
				ms_cs_h: begin // 175
					CS_b <= `UD 1'b1;
					main_state <= `UD ms_cs_i;
				end
				
				ms_cs_i: begin // 176
					clk_ni <= `UD 1'b1;
					CS_b <= `UD 1'b1;
					main_state <= `UD ms_cs_j;
				end
				
				ms_cs_j: begin // 177
					clk_ni <= `UD 1'b1;
					CS_b <= `UD 1'b1;
					main_state <= `UD ms_cs_k;
				end
				
				ms_cs_k: begin // 178
					if (debug_with_fake_data) begin
						tmp_A0 <= `UD fake_data >> 6;  
						tmp_A1 <= `UD fake_data >> 6; 
						tmp_A2 <= `UD fake_data >> 6; 
						tmp_A3 <= `UD fake_data >> 6; 
						tmp_A4 <= `UD fake_data >> 6; 
						tmp_A5 <= `UD fake_data >> 6; 
						tmp_A6 <= `UD fake_data >> 6; 
						tmp_A7 <= `UD fake_data >> 6; 
						tmp_B0 <= `UD fake_data >> 6; 
						tmp_B1 <= `UD fake_data >> 6; 
						tmp_B2 <= `UD fake_data >> 6; 
						tmp_B3 <= `UD fake_data >> 6; 
						tmp_B4 <= `UD fake_data >> 6; 
						tmp_B5 <= `UD fake_data >> 6; 
						tmp_B6 <= `UD fake_data >> 6; 
						tmp_B7 <= `UD fake_data >> 6; 
					end else begin
						tmp_A0 <= `UD in_A0[9:0];
						tmp_A1 <= `UD in_A1[9:0];
						tmp_A2 <= `UD in_A2[9:0];
						tmp_A3 <= `UD in_A3[9:0];
						tmp_A4 <= `UD in_A4[9:0];
						tmp_A5 <= `UD in_A5[9:0];
						tmp_A6 <= `UD in_A6[9:0];
						tmp_A7 <= `UD in_A7[9:0];
						tmp_B0 <= `UD in_B0[9:0];
						tmp_B1 <= `UD in_B1[9:0];
						tmp_B2 <= `UD in_B2[9:0];
						tmp_B3 <= `UD in_B3[9:0];
						tmp_B4 <= `UD in_B4[9:0];
						tmp_B5 <= `UD in_B5[9:0];
						tmp_B6 <= `UD in_B6[9:0];
						tmp_B7 <= `UD in_B7[9:0];
					end 

					if (2 == channel) begin
						data_valid <= `UD 1'b1;
					end
					clk_ni <= `UD 1'b1;
					CS_b <= `UD 1'b1;
					main_state <= `UD ms_cs_l;
				end
				
				ms_cs_l: begin // 179
					clk_ni <= `UD 1'b1;
					CS_b <= `UD 1'b1;			
					main_state <= `UD ms_cs_m;
				end
				
				ms_cs_m: begin // 180
					clk_ni <= `UD 1'b1;
					if (channel == 15) begin
						channel <= `UD 6'b0;
					end else begin
						channel <= `UD channel + 6'b1;
					end
					CS_b <= `UD 1'b1;	
					main_state <= `UD ms_cs_n; // 101
				end
								
				default: begin
					main_state <= `UD ms_wait; // 100
				end
				
			endcase
		end
	end
endmodule

