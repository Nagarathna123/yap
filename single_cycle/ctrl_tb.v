`timescale 1ns / 1ps

//macros
//instruction width
`define INSTRUCTION_WIDTH 32
//number of test vectors
`define NUM_TEST_VECTORS 10

module ctrl_tb;

	// Inputs
	reg [31:0] inst;

	// Outputs
	wire [4:0] alu_ctrl;
	wire reg_file_wr_en;
	wire [1:0] reg_file_wr_back_sel;
	wire alu_op2_sel;
	wire d_mem_rd_en;
	wire d_mem_wr_en;
	wire [1:0] d_mem_size;
	wire jal;
	wire jalr;

	// Instantiate the Unit Under Test (UUT)
	ctrl uut (
		.alu_ctrl(alu_ctrl), 
		.reg_file_wr_en(reg_file_wr_en), 
		.reg_file_wr_back_sel(reg_file_wr_back_sel), 
		.alu_op2_sel(alu_op2_sel), 
		.d_mem_rd_en(d_mem_rd_en), 
		.d_mem_wr_en(d_mem_wr_en), 
		.d_mem_size(d_mem_size), 
		.jal(jal), 
		.jalr(jalr), 
		.inst(inst)
	);
	
	//Test vectors
	reg [(`INSTRUCTION_WIDTH-1):0] test_vec [(`NUM_TEST_VECTORS-1):0];

	//count variable
	integer i;
	
	initial begin
		// Initialize Inputs
		inst = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

		//Initialize test vector
		//LUI
		test_vec[0] = 32'h80000037;
		//AUIPC
		test_vec[1] = 32'h80000017;
		//JAL
		test_vec[2] = 32'h8020006F;
		//JALR
		test_vec[3] = 32'h80000067;
		//BRANCH (BEQ)
		test_vec[4] = 32'h800000E3;
		//LOAD (LB)
		test_vec[5] = 32'h80000003;
		//STORE (SB)
		test_vec[6] = 32'h80000823;
		//ALU (I-TYPE) (SLTIU)
		test_vec[7] = 32'h80003013;
		//SHIFT (SRAI)
		test_vec[8] = 32'h41005013;
		//Invalid
		test_vec[`NUM_TEST_VECTORS - 1] = 32'h00000000;
		
		$display ("\n*-------------------------------------------------*\n");
		$display ("Reporting the generated control signals :- \n");
		
		//write each one of test vectors and check the output value				
		for(i=0; i<`NUM_TEST_VECTORS; i = i+1) begin
			//apply test input
			inst = test_vec[i];
			//delay
			#5;
			//report the control signals generated
			$display ("Input Instruction : %x \n\
alu_ctrl : %b, reg_file_wr_en : %b, reg_file_wr_back_sel : %b, alu_op2_sel : %b, d_mem_rd_en : %b, \
d_mem_wr_en : %b, d_mem_size : %b, jal : %b, jalr : %b\n", inst, alu_ctrl, reg_file_wr_en, 
				reg_file_wr_back_sel, alu_op2_sel, d_mem_rd_en, d_mem_wr_en, d_mem_size, jal, jalr);
		end
		
		$display ("\n*-------------------------------------------------*\n");


	end
      
endmodule

