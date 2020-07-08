`timescale 1ns/10ps

`ifndef UD
`define UD #1
`endif

/*
 
After sending the start_code (16'hfedc), the impedance measurement begins: 
every spi cycle (2 us), samples are sent on d_in1 and d_in2 (16 bits each) 
to the DAC, where d_in1 and d_in2 are applied to channels 0 and 16. So:
32 bits / 2 us = 16 Mbits/s = 1 MSamples/s

For a 50 Hz waveform, within one period (20 ms), we send:
(1 MSamples/s) * (20 ms) = 20 KSamples
For a 5 KHz waveform, we send (1 MSamples/s) * (200 us) = 200 samples
within one period

On a positive clk edge, if z_meas_trig is 1, then this module (FPGA) will latch
stim_cycles_per_elctrd into a register and output for 
(16 * stim_cycles_per_elctrd) + 1 spi cycle on MOSI as seen in the table below. 
Note that there are two elctrd_ns on each 32-ch-module being measured at the same time 
(as indicated by "elctrd_ns" in the table below). This is why 16*stim_cycles_per_elctrd 
of spi cycles are executed (plus 1 cycle during the start to tell the spi_slave that 
impedance measurement transmission is starting). This means that this module has
no knowledge of the frequency or the # of periods to send.

SPI cycle			mosi_r[31:16]	mosi_r[15:0]		elctrd_ns
------------------------------------------------------------------------------------------
-3				stop_code 		{9'h000, z_param}	none
-2				stop_code 		{9'h000, z_param}	none
-1				stop_code 		{9'h000, z_param}	none
0				start_code 		stim_cycles_per_elctrd	none
1 				d_in1			d_in2			0, 16
2 				d_in1			d_in2			0, 16
...		
stim_cycles_per_elctrd 		d_in1			d_in2			0, 16
stim_cycles_per_elctrd+1 	d_in1			d_in2			1, 17
stim_cycles_per_elctrd+2 	d_in1			d_in2			1, 17
...
(15*stim_cycles_per_elctrd)-2	d_in1			d_in2			14, 30
(15*stim_cycles_per_elctrd)-1	d_in1			d_in2			14, 30
(15*stim_cycles_per_elctrd)	d_in1			d_in2			14, 30
(15*stim_cycles_per_elctrd)+1 	d_in1			d_in2			15, 31
(15*stim_cycles_per_elctrd)+2 	d_in1			d_in2			15, 31
...
(15*stim_cycles_per_elctrd)-2 	d_in1			d_in2			15, 31
(16*stim_cycles_per_elctrd)-1 	d_in1			d_in2			15, 31
(16*stim_cycles_per_elctrd) 	d_in1			d_in2			15, 31
	
	   		end of an impedance measurement 		*/


module spi_master_z (

	// main clk and reset
	input wire	CLK,
	input wire	RST,

	// pulse spi_test_trig high to send command to recieve test pattern from slave:
	input wire	spi_test_trig,
	// pulse z_meas_trig high to begin measurement:
	input wire	z_meas_trig,
	// stim_cycles_per_elctrd*2 samples are output to the DAC per ch/elctrd_n:
	input wire	[15:0] stim_cycles_per_elctrd,
	// d_in1 & din_2 are sent to the DAC every spi_cycle
	input wire	[15:0] d_in1,
	input wire	[15:0] d_in2,

	// SPI-related signals
	input wire  	MISO,
	output reg  	CS_b, // SPI cycle freq = 500 KHz
	output reg  	SCLK,
	output reg  	MOSI
);

reg		[6:0]	main_state;
reg		[31:0]	mosi_r;
reg		[31:0]	shift_in;

reg		[15:0]	stim_cycles_per_elctrd_r;
reg		[15:0]	spi_cycle;
reg		[5:0]	elctrd_n;

reg		[2:0]	params2send;

reg			spi_test_en;

reg 		[1:0]	sel;
reg 		[4:0]	s_r;

localparam // main states:
	ms_wait 	= 	7'd0,
	ms_start	= 	7'd1,
	ms_2		= 	7'd2,
	ms_3		= 	7'd3,
	ms_4		= 	7'd4,
	ms_5		= 	7'd5,
	ms_6		= 	7'd6,
	ms_7		= 	7'd7,
	ms_8		= 	7'd8,
	ms_9		= 	7'd9,
	ms_10		= 	7'd10,
	ms_11		= 	7'd11,
	ms_12		= 	7'd12,
	ms_13		= 	7'd13,
	ms_14		= 	7'd14,
	ms_15		= 	7'd15,
	ms_16		= 	7'd16,
	ms_17		= 	7'd17,
	ms_18		= 	7'd18,
	ms_19		= 	7'd19,
	ms_20		= 	7'd20,
	ms_21		= 	7'd21,
	ms_22		= 	7'd22,
	ms_23		= 	7'd23,
	ms_24		= 	7'd24,
	ms_25		= 	7'd25,
	ms_26		= 	7'd26,
	ms_27		= 	7'd27,
	ms_28		= 	7'd28,
	ms_29		= 	7'd29,
	ms_30		= 	7'd30,
	ms_31		= 	7'd31,
	ms_32		= 	7'd32,
	ms_33		= 	7'd33,
	ms_34		= 	7'd34,
	ms_35		= 	7'd35,
	ms_36		= 	7'd36,
	ms_37		= 	7'd37,
	ms_38		= 	7'd38,
	ms_39		= 	7'd39,
	ms_40		= 	7'd40,
	ms_41		= 	7'd41,
	ms_42		= 	7'd42,
	ms_43		= 	7'd43,
	ms_44		= 	7'd44,
	ms_45		= 	7'd45,
	ms_46		= 	7'd46,
	ms_47		= 	7'd47,
	ms_48		= 	7'd48,
	ms_49		= 	7'd49,
	ms_50		= 	7'd50,
	ms_51		= 	7'd51,
	ms_52		= 	7'd52,
	ms_53		= 	7'd53,
	ms_54		= 	7'd54,
	ms_55		= 	7'd55,
	ms_56		= 	7'd56,
	ms_57		= 	7'd57,
	ms_58		= 	7'd58,
	ms_59		= 	7'd59,
	ms_60		= 	7'd60,
	ms_61		= 	7'd61,
	ms_62		= 	7'd62,
	ms_63		= 	7'd63,
	ms_64		= 	7'd64,
	ms_65		= 	7'd65,
	ms_66		= 	7'd66,
	ms_67		= 	7'd67,
	ms_68		= 	7'd68,
	ms_69		= 	7'd69,
	ms_70		= 	7'd70,
	ms_71		= 	7'd71,
	ms_72		= 	7'd72,
	ms_73		= 	7'd73,
	ms_74		= 	7'd74,
	ms_csb_hi_75	= 	7'd75,
	ms_csb_hi_76	= 	7'd76,
	ms_csb_hi_77	= 	7'd77,
	ms_csb_hi_78	= 	7'd78,
	ms_csb_hi_79	= 	7'd79,
	ms_end  	= 	7'd80,
	// transmission messages:
	start_code	= 	16'hfedc, 
	test_code	=	16'hff0a,	
	stop_code	= 	16'h0123;

always @(posedge RST or posedge CLK) begin
	if (RST) begin
		main_state	<= `UD	ms_wait;
		elctrd_n	<= `UD	6'd0;

		CS_b		<= `UD	1'b1;	
		SCLK		<= `UD	1'b0;
		MOSI		<= `UD 	1'b0;

		spi_cycle 	<= `UD 	16'h0000;
		params2send 	<= `UD 	3'd0;
		spi_test_en	<= `UD 	1'b0;
		mosi_r		<= `UD 	32'd0;
		shift_in	<= `UD 	32'd0;

		sel		<= `UD	2'b01;
		s_r		<= `UD	5'b00000;

		stim_cycles_per_elctrd_r	<= `UD	16'd0;

	end else begin 

		// default
		CS_b <= `UD 1'b0;
		SCLK <= `UD 1'b0;

		case (main_state)
		ms_wait: begin
			// same as reset state
			elctrd_n 	<= `UD 	6'd0;

			CS_b		<= `UD	1'b1;	
			SCLK		<= `UD	1'b0;
			MOSI		<= `UD 	1'b0;

			spi_cycle	<= `UD	16'h0000;
			mosi_r		<= `UD	32'd0;
			shift_in	<= `UD	32'd0;
			
			sel		<= `UD	2'b01;
//			s_r		<= `UD	5'b11111;
			s_r		<= `UD	5'b00000;	// {ext_cap, s<2>, s<1>, s<0>, bias} 

			main_state	<= `UD	ms_wait;
			params2send	<= `UD	3'd0;
			spi_test_en	<= `UD	1'b0;
			stim_cycles_per_elctrd_r	<= `UD	16'd0;

			// Impedance measurements only
			if (z_meas_trig) begin
				main_state	<= `UD	ms_start;
				params2send	<= `UD	3'd2;
				stim_cycles_per_elctrd_r	<= `UD	stim_cycles_per_elctrd;
			// SPI test mode only
			end else if (spi_test_trig) begin
				main_state	<= `UD	ms_start;
				spi_test_en	<= `UD	1'b1;
			end
		end 
		ms_start: begin
			CS_b 		<= `UD 	1'b1;	
			SCLK		<= `UD 	1'b0;
				
			if (params2send == 3'd2) begin
				mosi_r <= `UD {stop_code, {9'd0, sel, s_r}}; 
			end else if (params2send == 3'd1) begin
				mosi_r <= `UD {start_code, stim_cycles_per_elctrd_r}; 
			end else if (spi_test_en) begin
				mosi_r <= `UD {test_code, 16'h0000};
			end else begin
				mosi_r <= `UD {d_in1, d_in2};
			end		

			shift_in	<= `UD	32'd0;
			main_state 	<= `UD 	ms_2;

		end 
		ms_end: begin
			CS_b 		<= `UD 	1'b1;	
			SCLK		<= `UD 	1'b0;

			main_state	<= `UD	ms_wait;

			if (spi_test_en) begin
				// SPI test mode
				if (spi_test_trig) begin
					spi_test_en <= `UD 1'b1;
					main_state <= `UD ms_start;
				end else begin
					spi_test_en <= `UD 1'b0;
					main_state <= `UD ms_wait;
				end
			end else begin
				// Examine modes
				if (params2send == 3'd0) begin
					if (spi_test_en) begin
						// SPI test mode
						if (spi_test_trig) begin
							spi_test_en <= `UD 1'b1;
							main_state <= `UD ms_start;
						end else begin
							spi_test_en <= `UD 1'b0;
							main_state <= `UD ms_wait;
						end
					end else begin
						// Z-measurement mode or idle				
						if (spi_cycle == stim_cycles_per_elctrd_r) begin										
							spi_cycle <= `UD 16'd0;	// reset SPI cycle
							if (elctrd_n == 6'd15) begin
								elctrd_n <= `UD 6'd0;
								main_state <= `UD ms_wait; // complete Z-measurement
							end else begin
								elctrd_n <= `UD elctrd_n + 6'd1; // increment electrode number
								main_state <= `UD ms_start; // continue Z-measurement						
							end						
						end else begin
							spi_cycle <= `UD spi_cycle + 16'd1;	// increment SPI cycle number
							main_state <= `UD ms_start;
						end												
					end
				end else begin
					// sending commands for Z-measurement
					params2send <= `UD params2send - 3'd1;
					main_state <= `UD ms_start;
				end
			end
		end 
		ms_2: begin	
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_3;
		end
		ms_3: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_4;
		end
		ms_4: begin	
			MOSI <= `UD mosi_r[31];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_5;
		end
		ms_5: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_6;
		end
		ms_6: begin	
			MOSI <= `UD mosi_r[30];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_7;
		end
		ms_7: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_8;
		end
		ms_8: begin	
			MOSI <= `UD mosi_r[29];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_9;
		end
		ms_9: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_10;
		end
		ms_10: begin	
			MOSI <= `UD mosi_r[28];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_11;
		end
		ms_11: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_12;
		end
		ms_12: begin	
			MOSI <= `UD mosi_r[27];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_13;
		end
		ms_13: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_14;
		end
		ms_14: begin	
			MOSI <= `UD mosi_r[26];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_15;
		end
		ms_15: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_16;
		end
		ms_16: begin	
			MOSI <= `UD mosi_r[25];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_17;
		end
		ms_17: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_18;
		end
		ms_18: begin	
			MOSI <= `UD mosi_r[24];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_19;
		end
		ms_19: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_20;
		end
		ms_20: begin	
			MOSI <= `UD mosi_r[23];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_21;
		end
		ms_21: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_22;
		end
		ms_22: begin	
			MOSI <= `UD mosi_r[22];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_23;
		end
		ms_23: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_24;
		end
		ms_24: begin	
			MOSI <= `UD mosi_r[21];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_25;
		end
		ms_25: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_26;
		end
		ms_26: begin	
			MOSI <= `UD mosi_r[20];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_27;
		end
		ms_27: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_28;
		end
		ms_28: begin	
			MOSI <= `UD mosi_r[19];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_29;
		end
		ms_29: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_30;
		end
		ms_30: begin	
			MOSI <= `UD mosi_r[18];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_31;
		end
		ms_31: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_32;
		end
		ms_32: begin	
			MOSI <= `UD mosi_r[17];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_33;
		end
		ms_33: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_34;
		end
		ms_34: begin	
			MOSI <= `UD mosi_r[16];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_35;
		end
		ms_35: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_36;
		end
		ms_36: begin	
			MOSI <= `UD mosi_r[15];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_37;
		end
		ms_37: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_38;
		end
		ms_38: begin	
			MOSI <= `UD mosi_r[14];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_39;
		end
		ms_39: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_40;
		end
		ms_40: begin	
			MOSI <= `UD mosi_r[13];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_41;
		end
		ms_41: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_42;
		end
		ms_42: begin	
			MOSI <= `UD mosi_r[12];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_43;
		end
		ms_43: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_44;
		end
		ms_44: begin	
			MOSI <= `UD mosi_r[11];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_45;
		end
		ms_45: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_46;
		end
		ms_46: begin	
			MOSI <= `UD mosi_r[10];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_47;
		end
		ms_47: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_48;
		end
		ms_48: begin	
			MOSI <= `UD mosi_r[9];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_49;
		end
		ms_49: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_50;
		end
		ms_50: begin	
			MOSI <= `UD mosi_r[8];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_51;
		end
		ms_51: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_52;
		end
		ms_52: begin	
			MOSI <= `UD mosi_r[7];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_53;
		end
		ms_53: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_54;
		end
		ms_54: begin	
			MOSI <= `UD mosi_r[6];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_55;
		end
		ms_55: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_56;
		end
		ms_56: begin	
			MOSI <= `UD mosi_r[5];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_57;
		end
		ms_57: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_58;
		end
		ms_58: begin	
			MOSI <= `UD mosi_r[4];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_59;
		end
		ms_59: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_60;
		end
		ms_60: begin	
			MOSI <= `UD mosi_r[3];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_61;
		end
		ms_61: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_62;
		end
		ms_62: begin	
			MOSI <= `UD mosi_r[2];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_63;
		end
		ms_63: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_64;
		end
		ms_64: begin	
			MOSI <= `UD mosi_r[1];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_65;
		end
		ms_65: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_66;
		end
		ms_66: begin	
			MOSI <= `UD mosi_r[0];
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_67;
		end
		ms_67: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_68;
		end
		ms_68: begin	
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_69;
		end
		ms_69: begin	
			shift_in <= `UD {shift_in[30:0], MISO};
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_70;
		end
		ms_70: begin	
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_71;
		end
		ms_71: begin
			MOSI <= `UD 1'b0;
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_72;
		end
		ms_72: begin
			MOSI <= `UD 1'b0;
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_73;
		end
		ms_73: begin
			MOSI <= `UD 1'b0;
			SCLK <= `UD 1'b1;
			main_state <= `UD ms_74;
		end
		ms_74: begin
			MOSI <= `UD 1'b0;
			SCLK <= `UD 1'b0;
			main_state <= `UD ms_csb_hi_75;
		end
		ms_csb_hi_75: begin
			MOSI <= `UD 1'b0;
			SCLK <= `UD 1'b1;
			CS_b <= `UD 1'b1;
			main_state <= `UD ms_csb_hi_76;
		end
		ms_csb_hi_76: begin
			MOSI <= `UD 1'b0;
			SCLK <= `UD 1'b0;
			CS_b <= `UD 1'b1;
			main_state <= `UD ms_csb_hi_77;
		end
		ms_csb_hi_77: begin
			MOSI <= `UD 1'b0;
			SCLK <= `UD 1'b1;
			CS_b <= `UD 1'b1;
			main_state <= `UD ms_csb_hi_78;
		end
		ms_csb_hi_78: begin
			MOSI <= `UD 1'b0;
			SCLK <= `UD 1'b0;
			CS_b <= `UD 1'b1;
			main_state <= `UD ms_csb_hi_79;
		end
		ms_csb_hi_79: begin
			MOSI <= `UD 1'b0;
			SCLK <= `UD 1'b1;
			CS_b <= `UD 1'b1;
			main_state <= `UD ms_end;
		end
	endcase
	end
end

endmodule

