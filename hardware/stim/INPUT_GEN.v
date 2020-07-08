`timescale 1ns/10ps

module INPUT_GEN (
	input wire CLK,
	input wire RST,
	input wire TX_START,
	
	output reg MODE,
	output reg BIAS_SEL,
	output reg [6:0] BIAS_AMP,
	output reg [4:0] ADDR,
	output reg [7:0] AMP0,
	output reg [7:0] AMP1,
	output reg [7:0] AMP2,
	output reg [7:0] AMP3	
);

	parameter CH_N = 32;
	
	reg [1:0] STATE;
	reg [7:0] AMP_CNT;
	
	reg [6:0] TMP_BIAS_AMP;
	reg [7:0] TMP_AMP0;
	reg [7:0] TMP_AMP1;
	reg [7:0] TMP_AMP2;
	reg [7:0] TMP_AMP3;
	
	always@(posedge CLK) begin
		if (!RST) begin
			MODE <= 1'b0;
			BIAS_SEL <= 1'b0;
			BIAS_AMP <= 7'd0;
			ADDR <= 5'd0;
			AMP0 <= 8'd0;
			AMP1 <= 8'd0;
			AMP2 <= 8'd0;
			AMP3 <= 8'd0;
			TMP_BIAS_AMP <= 7'd0;
			TMP_AMP0 <= 8'd0;
			TMP_AMP1 <= 8'd0;
			TMP_AMP2 <= 8'd0;
			TMP_AMP3 <= 8'd0;
			AMP_CNT <= 2'd0;
			STATE <= 2'd0;			
		end
		else begin
			case (STATE)
				2'd0: begin //Initial zero data
					MODE <= 1'b0;
					BIAS_SEL <= 1'b0;
					BIAS_AMP <= 7'd0;
					ADDR <= 5'd0;
					AMP0 <= 8'd0;
					AMP1 <= 8'd0;
					AMP2 <= 8'd0;
					AMP3 <= 8'd0;
					TMP_BIAS_AMP <= 7'd0;
					TMP_AMP0 <= 8'd0;
					TMP_AMP1 <= 8'd0;
					TMP_AMP2 <= 8'd0;
					TMP_AMP3 <= 8'd0; 					
					AMP_CNT <= 2'd0;
					
					if (TX_START) STATE <= 2'd1;
					else STATE <= 2'd0;
				end
				
				2'd1: begin //Bias control
					MODE <= 1'b0;
					BIAS_SEL <= 1'b0;
					BIAS_AMP <= TMP_BIAS_AMP;			
					ADDR <= ADDR;
					AMP0 <= AMP0;
					AMP1 <= AMP1;
					AMP2 <= AMP2;
					AMP3 <= AMP3;
					TMP_BIAS_AMP <= TMP_BIAS_AMP;
					TMP_AMP0 <= TMP_AMP0;
					TMP_AMP1 <= TMP_AMP1;
					TMP_AMP2 <= TMP_AMP2;
					TMP_AMP3 <= TMP_AMP3; 					
					STATE <= 2'd3;					
					AMP_CNT <= AMP_CNT;
				end
				
				2'd2: begin //Amplidute control
					MODE <= 1'b1;
					BIAS_SEL <= BIAS_SEL;
					BIAS_AMP <= BIAS_AMP;
					ADDR <= ADDR;
					AMP0 <= TMP_AMP0;
					AMP1 <= TMP_AMP1;
					AMP2 <= TMP_AMP2;
					AMP3 <= TMP_AMP3;
					
					if (ADDR == 5'd60) begin
						AMP1 <= TMP_AMP1;
					end
					else begin
						AMP1 <= 8'd0;
					end
					
					TMP_BIAS_AMP <= TMP_BIAS_AMP;
					TMP_AMP0 <= TMP_AMP0;
					TMP_AMP1 <= TMP_AMP1;
					TMP_AMP2 <= TMP_AMP2;
					TMP_AMP3 <= TMP_AMP3;
					AMP_CNT <= AMP_CNT;
					STATE <= 2'd3;					
				end
				
				2'd3: begin //Waiting for update
					MODE <= MODE;
					BIAS_SEL <= BIAS_SEL;
					BIAS_AMP <= BIAS_AMP;
					
					AMP0 <= AMP0;
					AMP1 <= AMP1;
					AMP2 <= AMP2;
					AMP3 <= AMP3;
					
					if (TX_START) begin
						if (MODE) begin
							if (ADDR < CH_N - 1) begin
								ADDR <= ADDR + 1'b1;
								TMP_AMP0 <= TMP_AMP0;
								TMP_AMP1 <= TMP_AMP1;
								TMP_AMP2 <= TMP_AMP2;
								TMP_AMP3 <= TMP_AMP3;
								AMP_CNT <= AMP_CNT;
							end
							else begin
								ADDR <= 5'd0;
								
								if (AMP_CNT < 63) begin
									TMP_BIAS_AMP <= 7'd57;
									TMP_AMP0 <= 8'd0;
									TMP_AMP1 <= 8'd25;
									TMP_AMP2 <= 8'd0;
									
									/* Arb waveform (Gaussian)
									case (AMP_CNT)
										8'd0: TMP_AMP1 <= 8'd0;
										8'd1: TMP_AMP1 <= 8'd1;
										8'd2: TMP_AMP1 <= 8'd3;
										8'd3: TMP_AMP1 <= 8'd6;
										8'd4: TMP_AMP1 <= 8'd9;
										8'd5: TMP_AMP1 <= 8'd14;
										8'd6: TMP_AMP1 <= 8'd19;
										8'd7: TMP_AMP1 <= 8'd25;
										8'd8: TMP_AMP1 <= 8'd32;
										8'd9: TMP_AMP1 <= 8'd40;
										8'd10: TMP_AMP1 <= 8'd48;
										8'd11: TMP_AMP1 <= 8'd56;
										8'd12: TMP_AMP1 <= 8'd63;
										8'd13: TMP_AMP1 <= 8'd70;
										8'd14: TMP_AMP1 <= 8'd77;
										8'd15: TMP_AMP1 <= 8'd82;
										8'd16: TMP_AMP1 <= 8'd86;
										8'd17: TMP_AMP1 <= 8'd90;
										8'd18: TMP_AMP1 <= 8'd92;
										8'd19: TMP_AMP1 <= 8'd94;
										8'd20: TMP_AMP1 <= 8'd95;
										8'd21: TMP_AMP1 <= 8'd95;
										8'd22: TMP_AMP1 <= 8'd95;
										8'd23: TMP_AMP1 <= 8'd95;
										8'd24: TMP_AMP1 <= 8'd95;
										8'd25: TMP_AMP1 <= 8'd95;
										8'd26: TMP_AMP1 <= 8'd95;
										8'd27: TMP_AMP1 <= 8'd95;
										8'd28: TMP_AMP1 <= 8'd95;
										8'd29: TMP_AMP1 <= 8'd95;
										8'd30: TMP_AMP1 <= 8'd95;
										8'd31: TMP_AMP1 <= 8'd95;
										8'd32: TMP_AMP1 <= 8'd95;
										8'd33: TMP_AMP1 <= 8'd95;
										8'd34: TMP_AMP1 <= 8'd95;
										8'd35: TMP_AMP1 <= 8'd95;
										8'd36: TMP_AMP1 <= 8'd95;
										8'd37: TMP_AMP1 <= 8'd95;
										8'd38: TMP_AMP1 <= 8'd95;
										8'd39: TMP_AMP1 <= 8'd95;
										8'd40: TMP_AMP1 <= 8'd95;
										8'd41: TMP_AMP1 <= 8'd95;
										8'd42: TMP_AMP1 <= 8'd95;
										8'd43: TMP_AMP1 <= 8'd94;
										8'd44: TMP_AMP1 <= 8'd92;
										8'd45: TMP_AMP1 <= 8'd90;
										8'd46: TMP_AMP1 <= 8'd86;
										8'd47: TMP_AMP1 <= 8'd82;
										8'd48: TMP_AMP1 <= 8'd77;
										8'd49: TMP_AMP1 <= 8'd70;
										8'd50: TMP_AMP1 <= 8'd63;
										8'd51: TMP_AMP1 <= 8'd56;
										8'd52: TMP_AMP1 <= 8'd48;
										8'd53: TMP_AMP1 <= 8'd40;
										8'd54: TMP_AMP1 <= 8'd32;
										8'd55: TMP_AMP1 <= 8'd25;
										8'd56: TMP_AMP1 <= 8'd19;
										8'd57: TMP_AMP1 <= 8'd14;
										8'd58: TMP_AMP1 <= 8'd9;
										8'd59: TMP_AMP1 <= 8'd6;
										8'd60: TMP_AMP1 <= 8'd3;
										8'd61: TMP_AMP1 <= 8'd1;
										8'd62: TMP_AMP1 <= 8'd0;
										default: TMP_AMP1 <= 8'd0;
									endcase
									*/
																		
									AMP_CNT <= AMP_CNT + 1'b1;
								end
								else if (AMP_CNT < 127) begin
									TMP_BIAS_AMP <= 7'd57;
									TMP_AMP0 <= 8'd0;
									TMP_AMP1 <= 8'd0;
									TMP_AMP2 <= 8'd0;
									TMP_AMP3 <= 8'd0;
									AMP_CNT <= AMP_CNT + 1'b1;
								end
								else begin
									TMP_BIAS_AMP <= 7'd57;
									TMP_AMP0 <= 8'd0;
									TMP_AMP1 <= 8'd0;
									TMP_AMP2 <= 8'd0;
									TMP_AMP3 <= 8'd0;
									AMP_CNT <= 7'd0;
								end								
							end
							
							STATE <= 2'd1;
						end
						else begin
							ADDR <= ADDR;
							TMP_AMP0 <= TMP_AMP0;
							TMP_AMP1 <= TMP_AMP1;
							TMP_AMP2 <= TMP_AMP2;
							TMP_AMP3 <= TMP_AMP3;
							AMP_CNT <= AMP_CNT;
							STATE <= 2'd2;
						end				
					end
					else begin
						ADDR <= ADDR;
						TMP_AMP0 <= TMP_AMP0;
						TMP_AMP1 <= TMP_AMP1;
						TMP_AMP2 <= TMP_AMP2;
						TMP_AMP3 <= TMP_AMP3;
						AMP_CNT <= AMP_CNT;
						STATE <= 2'd3;						
					end
				end
			endcase
		end
	end

endmodule
	