`timescale 1ns/10ps

module INPUT_RECV (
	input wire CLK,
	input wire RST,
	input wire TX_START,
	
	input wire NI_CLK,
	input wire [7:0] NI_DIGITAL_IN,
	input wire FIFO_DATA_READY,
	output wire FIFO_FULL,
	
	output wire MODE,
	output wire BIAS_SEL,
	output wire [6:0] BIAS_AMP,
	output wire [4:0] ADDR,
	output wire [7:0] AMP0,
	output wire [7:0] AMP1,
	output wire [7:0] AMP2,
	output wire [7:0] AMP3
);

	reg [1:0] active_buffer;
	reg [1:0] read_buffer;
	reg [45:0] output_param [3:0];
	reg [2:0] read_counter;
	reg [3:0] data_invalid_req;
	reg TX_PREV;
	
	assign MODE = output_param[active_buffer][45];
	//assign BIAS_SEL = output_param[active_buffer][44];
	//assign BIAS_AMP = output_param[active_buffer][43:37];
	//assign ADDR = output_param[active_buffer][36:32];
	assign ADDR = output_param[active_buffer][44:40];
	assign BIAS_SEL = output_param[active_buffer][39];
	assign BIAS_AMP = output_param[active_buffer][38:32];
	assign AMP0 = output_param[active_buffer][31:24];
	assign AMP1 = output_param[active_buffer][23:16];
	assign AMP2 = output_param[active_buffer][15:8];
	assign AMP3 = output_param[active_buffer][7:0];
	assign FIFO_FULL = ((read_buffer + 1) & 3) == active_buffer || ((read_buffer + 2) & 3) == active_buffer;
	
	always@(posedge CLK) begin
		if (!RST) begin
			active_buffer <= 0;
		end
		else begin
			if (TX_START && !TX_PREV && (read_buffer !=((active_buffer+1) & 3))) begin
				active_buffer <= (active_buffer + 1) & 3;
			end
		end
		TX_PREV <= TX_START;
	end
	
	always@(posedge NI_CLK) begin
		if (!RST) begin
			read_buffer <= 1;
			output_param[0] <= 0;
			output_param[1] <= 0;
			output_param[2] <= 0;
			output_param[3] <= 0;
			read_counter <= 0;
		end
		if (FIFO_DATA_READY) begin
			case (read_counter)
				0: begin
					if (NI_DIGITAL_IN == 8'haa)
						read_counter <= read_counter + 1;
					else
						read_counter <= 0;
				end
				
				1: begin
					if (NI_DIGITAL_IN[7:6] == 0) begin
						output_param[read_buffer][45:40] <= NI_DIGITAL_IN[5:0];
						read_counter <= read_counter + 1;
					end
					else
						read_counter <= 0;
				end
				
				2: begin
					output_param[read_buffer][39:32] <= NI_DIGITAL_IN;
					read_counter <= read_counter + 1;
				end
				
				3: begin
					output_param[read_buffer][31:24] <= NI_DIGITAL_IN;
					read_counter <= read_counter + 1;
				end
				
				4: begin
					output_param[read_buffer][23:16] <= NI_DIGITAL_IN;
					read_counter <= read_counter + 1;
				end
				
				5: begin
					output_param[read_buffer][15:8] <= NI_DIGITAL_IN;
					read_counter <= read_counter + 1;
				end
				
				6: begin
					output_param[read_buffer][7:0] <= NI_DIGITAL_IN;
					read_counter <= read_counter + 1;
				end
				
				7: begin
					if (NI_DIGITAL_IN == 8'hab) begin
						read_counter <= read_counter + 1;
						read_buffer <= read_buffer + 1;
					end
					else
						read_counter <= 0;
				end
				
			endcase
		end
	end
	
endmodule
	