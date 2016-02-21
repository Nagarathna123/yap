`timescale 1ns / 1ps

//macros
//instruction width
`define INSTRUCTION_WIDTH 32
//operand width
`define OPERAND_WIDTH 32
//number of test vectors
`define NUM_TEST_VECTORS 10

module sz_ex_tb;

	// Inputs
	reg [31:0] inst;

	// Outputs
	wire [31:0] sz_ex_val;

	// Instantiate the Unit Under Test (UUT)
	sz_ex uut (
		.sz_ex_val(sz_ex_val), 
		.inst(inst)
	);
	
	//Test vectors
	reg [(`INSTRUCTION_WIDTH-1):0] test_vec [(`NUM_TEST_VECTORS-1):0];
	
	//Expected result
	reg [(`INSTRUCTION_WIDTH-1):0] exp_result [(`NUM_TEST_VECTORS-1):0];
	
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
		
		//Initialize expected output vector
		//LUI
		exp_result[0] = 32'h80000000;
		//AUIPC
		exp_result[1] = 32'h80000000;
		//JAL
		exp_result[2] = 32'hFFF00002;
		//JALR
		exp_result[3] = 32'hFFFFF800;
		//BRANCH (BEQ)
		exp_result[4] = 32'hFFFFF800;
		//LOAD (LB)
		exp_result[5] = 32'hFFFFF800;
		//STORE (SB)
		exp_result[6] = 32'hFFFFF810;
		//ALU (I-TYPE) (SLTIU)
		exp_result[7] = 32'h00000800;
		//SHIFT (SRAI)
		exp_result[8] = 32'h00000010;
		//Invalid
		exp_result[`NUM_TEST_VECTORS - 1] = 32'hxxxxxxxx;
		
		$display ("*-------------------------------------------------*");
		$display ("Reporting those inputs that generated wrong output :- \n");
		
		//write each one of test vectors and check the output value				
		for(i=0; i<`NUM_TEST_VECTORS; i = i+1) begin
			//apply test input
			inst = test_vec[i];
			//delay
			#5;
			//check output and report if there is an error
			if(sz_ex_val != exp_result[i]) begin
				$display ("Input Instruction : %x, Output sz_ex value : %x, expected output : %x", inst, $signed(sz_ex_val), exp_result[i]);
			end
		end
		
		$display ("*-------------------------------------------------*\n");
		
		//end simulation	
		$finish;
		
	end
      
endmodule
