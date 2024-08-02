`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2024 10:30:24
// Design Name: 
// Module Name: top_tb
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


module top_tb();

	parameter CLK_PERIOD = 10ns;
	parameter DATA_WIDTH = $clog2(444);
	parameter COUNT_WIDTH = $clog2(5952);
	parameter MAX_VALUE = $clog2(1002000);
	
	
	// integer i, check_48, check_1008, check_6144;

	integer check_160, check_1984, check_4736, check_5952, check_40;
	integer check_matlab_160, check_matlab_1984, check_matlab_4736, check_matlab_5952, check_matlab_40;
	string line;

	bit clk_i = 1'b0;
	
	bit [DATA_WIDTH : 0] f1;
	bit [DATA_WIDTH : 0] f2;
	bit [COUNT_WIDTH - 1 : 0] K;
	wire [MAX_VALUE - 1 : 0] index_out;
	wire index_valid_out;
	bit valid_in;
	bit rst;

	bit [COUNT_WIDTH - 1 : 0] counter = 0;
	event transaction_finish;

	bit [COUNT_WIDTH - 1 : 0] ki [0:4] = { 160, 1984, 4736, 5952, 40 };
	bit [DATA_WIDTH : 0] f1i [0:4] = { 21, 185, 71, 47, 3 };
	bit [DATA_WIDTH : 0] f2i [0:4] = { 120, 124, 444, 186, 10 };

	
	
	always #(CLK_PERIOD/2) clk_i = ~clk_i;

	task write ( 
						input [DATA_WIDTH : 0] f1_i,
						input [DATA_WIDTH : 0] f2_i,
						input [COUNT_WIDTH - 1 : 0] K_i
				);

		f1 = f1_i;
		f2 = f2_i;
		K = K_i;
		valid_in = 1'b1;
		#CLK_PERIOD;
		valid_in = 1'b0;

	endtask : write
	
	initial begin
		valid_in = 1'b0;
		rst = 1'b1;
		#100ns;
		@(posedge clk_i)
		rst = 1'b0;
		for (int k = 0; k < 5; k ++) begin
			write (.f1_i(f1i[k]), .f2_i(f2i[k]), .K_i(ki[k]));
			@(transaction_finish);
			#1us;
		end
	end


	initial begin
		check_matlab_160 = $fopen("matlab_check_160.txt", "r");	
		check_160 = $fopen("check_160.txt", "w");
		check_matlab_1984 = $fopen("matlab_check_1984.txt", "r");
		check_1984 = $fopen("check_1984.txt", "w");
		check_matlab_4736 = $fopen("matlab_check_4736.txt", "r");
		check_4736 = $fopen("check_4736.txt", "w");
		check_matlab_5952 = $fopen("matlab_check_5952.txt", "r");
		check_5952 = $fopen("check_5952.txt", "w");
		check_matlab_40 = $fopen("matlab_check_40.txt", "r");
		check_40 = $fopen("check_40.txt", "w");
	end


	always_comb
	begin
		if (index_valid_out) begin
			counter = counter + 1;
			if (counter == K) begin
				-> transaction_finish;
				counter = 0;
			end
			case (f1)
				f1i[0] : 	begin
								$fgets(line,check_matlab_160);
								$display(line.atoi(), index_out);
								$fdisplay(check_160, index_out);
								if (line.atoi() !== index_out)
									$display ("error");
							end
				f1i[1] : 	begin
								$fgets(line,check_matlab_1984);
								$display(line.atoi(), index_out);
								$fdisplay(check_1984, index_out);
								if (line.atoi() !== index_out)
									$display ("error");
							end 
				f1i[2] : 	begin
								$fgets(line,check_matlab_4736);
								$display(line.atoi(), index_out);
								$fdisplay(check_4736, index_out);
								if (line.atoi() !== index_out)
									$display ("error");
							end 
				f1i[3] : 	begin
								$fgets(line,check_matlab_5952);
								$display(line.atoi(), index_out);
								$fdisplay(check_5952, index_out);
								if (line.atoi() !== index_out)
									$display ("error");
							end 
				f1i[4] : 	begin
								$fgets(line,check_matlab_40);
								$display(line.atoi(), index_out);
								$fdisplay(check_40, index_out);
								if (line.atoi() !== index_out)
									$display ("error");
							end 
			endcase
		end
	end

	
	top #(.DATA_WIDTH(DATA_WIDTH), .COUNT_WIDTH(COUNT_WIDTH), .MAX_VALUE(MAX_VALUE))
		top_inst
	(
		.clk				(clk_i),
		.valid_in			(valid_in),
		.rst				(rst),
		.f1					(f1),
		.f2					(f2),
		.K					(K),
		.index_out 			(index_out),
		.index_valid_out 	(index_valid_out)
	);
	
	
	
endmodule
