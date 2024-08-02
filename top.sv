`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2024 09:29:54
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top
	(
		clk,
		rst,
		f1,
		f2,
		K,
		valid_in,
		index_out,
		index_valid_out
	);

	parameter DATA_WIDTH = $clog2(120);
	parameter COUNT_WIDTH = $clog2(160);
	parameter MAX_VALUE = $clog2(1002000);

	input clk; 
	input rst;
	input valid_in;
	input [DATA_WIDTH : 0] f1; 
	input [DATA_WIDTH : 0] f2; 
	input [COUNT_WIDTH - 1 : 0] K;
	output [MAX_VALUE-1 : 0] index_out;
	output index_valid_out;


	reg [13 : 0] g;
	reg [13 : 0] pre_g;
	reg [MAX_VALUE-1 : 0] pre_index;
	reg [MAX_VALUE-1 : 0] index;
	// reg [DATA_WIDTH+3 : 0] index_i;
	reg [MAX_VALUE : 0] sum_i;
	reg [MAX_VALUE : 0] sum_p;
	reg index_valid_out_i;


	reg done;
	reg [COUNT_WIDTH-1 : 0] counter;
	reg en;


	localparam IDLE = 2'b00, CALCULATE_0 = 2'b01, CALCULATE_1 = 2'b10;
	reg [1:0] state, next_state;


	always_ff @(posedge clk)
	begin
		if (valid_in)
			en <= 1'b1;
		else if (counter == K)
			en <= 1'b0;
	end

	always_ff @(posedge clk)
	begin
		if (state == IDLE)
			g <= f1 + f2;
		else if (state == CALCULATE_1)
			g <= (sum_p[MAX_VALUE] == 1'b1 || sum_p == 0) ? pre_g : sum_p;
	end


	always_ff @(posedge clk)
	begin
		if (rst || !en) 
			state <= IDLE;
		else 
			state <= next_state;
	end

	always_comb
	begin
		case (state)
		IDLE 			: begin
						if (en)  					next_state = CALCULATE_0;
						else						next_state = IDLE;
		end
		CALCULATE_0	: 	begin
						if (done)					next_state = CALCULATE_1;
						else						next_state = CALCULATE_0;
		end
		CALCULATE_1 	: begin
						if (!done)					next_state = CALCULATE_0;
						else if (!en)				next_state = IDLE;
						else						next_state = CALCULATE_1;
		end
		endcase
	end

	always_comb
	begin
		case (state)
			IDLE 			: begin
								pre_g = 0;
								pre_index = 0;
								index = 0;
								sum_i = 0;
								sum_p = 0;
								// g = f1 + f2;
								done = 1'b0;
							end
			CALCULATE_0		: begin
								pre_index = index + g; 		// pre_index(k) = (index(k-1) + g(k-1));
								sum_i = pre_index - K; 		// sum = pre_index(k) - blklen;
								index = (sum_i[MAX_VALUE] == 1'b1 || sum_i == 0) ? pre_index : sum_i;
								done = 1'b1;
							end
			CALCULATE_1		: begin
								pre_g = (g + (f2<<1)); 		// pre_g(k) = (g(k-1) + 2*f2);
								sum_p = pre_g - K; 			// sum = pre_g(k) - blklen;
								// g = (sum_p[DATA_WIDTH + 4] == 1'b1 || sum_p == 0) ? pre_g : sum_p;
								done = 1'b0;
							end
		endcase
	end

	// assign index_i = index + 1'b1;

	always_ff @(posedge clk)
	begin
		if (rst || !en) 
			counter <= {COUNT_WIDTH{1'b0}};
		else if (next_state == CALCULATE_0)
			counter <= counter + 1;
	end


	assign index_valid_out_i = (en) ? !done : 1'b0;

	assign index_out = index;
	assign index_valid_out = index_valid_out_i;
    

endmodule
