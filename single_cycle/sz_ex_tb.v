`timescale 1ns / 1ps

//Include header
`include "sz_ex.h"

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

	initial begin
		// Initialize Inputs
		inst = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		//monitor signlas
		$monitor($time, " Input inst :- %b, Output val = %b\n", inst, sz_ex_val); 
		
		//test a bunch of valid instruction values
		inst = 32'hF0000067;
		#5;
		
		inst = 'b1000011;
		#5;
		
		inst = 'b0000011;
		#5;
		
		$finish;
		

	end
      
endmodule

