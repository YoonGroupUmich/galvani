`timescale 1ns/10ps

module CMD_GEN (
	input wire CLK,
	input wire RST,
	input wire TX_END,
	input wire MODE,
	input wire BIAS_SEL,
	input wire [6:0] BIAS_AMP,
	input wire [4:0] ADDR,
	input wire [7:0] AMP,
	
	output reg TX_START,
	output reg TRG,
	output reg [15:0] CMD
);

	parameter CH_N = 32;
	
	reg [1:0] STATE;

	always@(posedge CLK) begin
		if (!RST) begin
			TX_START <= 1'b0;
			TRG <= 1'b0;			
			CMD <= 16'b0;	
			STATE <= 2'd0;
		end
		
		else begin
			case (STATE)
				2'd0: begin //CMD generation
					TX_START <= 1'b0;
					TRG <= 1'b0;
					
					if (!MODE) CMD <= {MODE, 7'b0, BIAS_SEL, BIAS_AMP};
					else CMD <= {MODE, 2'b0, ADDR, AMP};
					
					STATE <= 2'd1;
				end
	
				2'd1: begin //TX start
					TX_START <= 1'b1;
					TRG <= 1'b0;					
					CMD <= CMD;
					STATE <= 2'd2;					
				end
					
				2'd2: begin //TX end
					TX_START <= 1'b0;
					TRG <= 1'b0;					
					CMD <= CMD;
										
					if (TX_END) begin
						if (!CMD[15]) begin
							STATE <= 2'd0;
						end
						else begin
							if (CMD[12:8] < CH_N - 1) STATE <= 2'd0;
							else STATE <= 2'd3;
						end
					end
					
					else STATE <= 2'd2;
				end
									
				2'd3: begin //Trigger
					TX_START <= 1'b0;
					TRG <= 1'b1;					
					CMD <= CMD;
					STATE <= 2'd0;
				end
				
				default: begin
					TX_START <= 1'b0;
					TRG <= 1'b0;					
					CMD <= 16'b0;		
					STATE <= 2'd0;
				end
			endcase
		end
	end

	
endmodule
	