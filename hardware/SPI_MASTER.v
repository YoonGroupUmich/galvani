`timescale 1ns/10ps

module SPI_MASTER (
	input wire CLK,
	input wire RST,
	input wire TRG,
	input wire TX_START,
	input wire [15:0] CMD,
	
	output reg SCLK,
	output reg CSb,
	output reg RST_SLV,
	output reg TRG_SLV,
	output reg MOSI,
	output reg TX_END
);

	reg [5:0] STATE;
	reg [15:0] CMD_REG;

	always@(posedge CLK) begin
		if (!RST) begin
			STATE <= 6'd0;
			SCLK <= 1'b0;
			CSb <= 1'b1;
			RST_SLV <= 1'b1;
			TRG_SLV <= 1'b0;
			MOSI <= 1'b0;
			TX_END <= 1'b0;
			CMD_REG <= 16'b0;
		end			
		
		else if (TRG) begin
			STATE <= 6'd35;
			SCLK <= 1'b0;
			CSb <= 1'b1;
			RST_SLV <= 1'b0;
			TRG_SLV <= 1'b1;
			MOSI <= 1'b0;
			TX_END <= 1'b0;
			CMD_REG <= 16'b0;			
		end
		
		else begin
			case (STATE)
				6'd0: begin //TX wait
					SCLK <= 1'b0;
					CSb <= 1'b1;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= 1'b0;
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					if (TX_START) STATE <= 6'd1;
					else STATE <= 6'd0;
				end
								
				6'd1: begin //Command store
					SCLK <= 1'b0;
					CSb <= 1'b1;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= 1'b0;
					TX_END <= 1'b0;
					CMD_REG <= CMD;
					STATE <= 6'd2;		
				end			
					
				6'd2: begin //TX state(1-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[15];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd3;
				end
				
				6'd3: begin //TX state(1-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[15];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd4;
				end
				
				6'd4: begin //TX state(2-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[14];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd5;
				end
					
				6'd5: begin //TX state(2-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[14];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd6;
				end
					
				6'd6: begin //TX state(3-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[13];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd7;
				end
			
				6'd7: begin //TX state(3-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[13];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd8;
				end
				
				6'd8: begin //TX state(4-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[12];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd9;
				end
				
				6'd9: begin //TX state(4-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[12];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd10;	
				end
					
				6'd10: begin //TX state(5-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[11];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd11;
				end
				
				6'd11: begin //TX state(5-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[11];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd12;
				end
				
				6'd12: begin //TX state(6-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[10];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd13;
				end
				
				6'd13: begin //TX state(6-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[10];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd14;
				end
				
				6'd14: begin //TX state(7-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[9];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd15;
				end
				
				6'd15: begin //TX state(7-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[9];					
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd16;
				end
					
				6'd16: begin //TX state(8-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[8];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd17;
				end
				
				6'd17: begin //TX state(8-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[8];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd18;	
				end
				
				6'd18: begin //TX state(9-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[7];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd19;
				end
				
				6'd19: begin //TX state(9-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[7];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd20;
				end
							
				6'd20: begin //TX state(10-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[6];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd21;
				end
				
				6'd21: begin //TX state(10-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[6];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd22;
				end
			
				6'd22: begin //TX state(11-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[5];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd23;
				end
				
				6'd23: begin //TX state(11-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[5];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd24;
				end
										
				6'd24: begin //TX state(12-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[4];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd25;
				end
				
				6'd25: begin //TX state(12-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[4];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd26;
				end
										
				6'd26: begin //TX state(13-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[3];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd27;
				end
				
				6'd27: begin //TX state(13-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[3];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd28;
				end
					
				6'd28: begin //TX state(14-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[2];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd29;
				end
				
				6'd29: begin //TX state(14-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[2];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd30;
				end
										
				6'd30: begin //TX state(15-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[1];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd31;
				end
				
				6'd31: begin //TX state(15-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[1];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd32;
				end
										
				6'd32: begin //TX state(16-a)
					SCLK <= 1'b0;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[0];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd33;
				end
				
				6'd33: begin //TX state(16-b)
					SCLK <= 1'b1;
					CSb <= 1'b0;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= CMD_REG[0];
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					STATE <= 6'd34;
				end
				
				6'd34: begin //TX end
					SCLK <= 1'b0;
					CSb <= 1'b1;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= 1'b0;					
					TX_END <= 1'b1;
					CMD_REG <= CMD_REG;
					STATE <= 6'd0;
				end
					
				6'd35: begin //Trigger Slave
					SCLK <= 1'b0;
					CSb <= 1'b1;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b1;
					MOSI <= 1'b0;
					TX_END <= 1'b0;
					CMD_REG <= CMD_REG;
					if (TX_START) STATE <= 6'd1;
					else STATE <= 6'd35;
				end
					
				default: begin
					SCLK <= 1'b0;
					CSb <= 1'b1;
					RST_SLV <= 1'b0;
					TRG_SLV <= 1'b0;
					MOSI <= 1'b0;
					TX_END <= 1'b0;
					CMD_REG <= 16'b0;
					STATE <= 6'd0;
				end
			endcase
		end
	end




endmodule

