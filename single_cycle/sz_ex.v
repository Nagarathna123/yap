//sign and zero extend

//Include header
`include "sz_ex.h"

//instruction types
//I-type
`define JALR 5'b11001
`define LOAD 5'b00000
`define ALU 5'b00100
//S-type
   
module sz_ex(
	//sign or zero extended value
	output reg [(`OPERAND_WIDTH - 1):0] sz_ex_val,
	//input instruction
	input [(`INSTRUCTION_WIDTH - 1):0] inst
);

	//function for sign or zero extend (12 bits to 32 bits)
	function [(`OPERAND_WIDTH-1):0] sz_ex_12_to_32;
		//12 bit value
		input [11:0] val;
		//(0) - zero extend, (1) - sign extend
		input k;
		
		begin
			//copy LSB (12 bits)
			sz_ex_12_to_32[11:0] = val;
			
			if (k==1'b1) begin
				//sign extend
				//replicate sign bits
				sz_ex_12_to_32[(`OPERAND_WIDTH-1):12] = {(`OPERAND_WIDTH-12){val[11]}};
			end
			
			else begin
				//zero extend
				sz_ex_12_to_32[(`OPERAND_WIDTH-1):12] = {(`OPERAND_WIDTH-12){1'b0}};
			end
				
		end
		
	endfunction

	//combinational logic
	always @ (*) begin
		//first check if the input instruction is valid
		if (inst[1:0] == 2'b11) begin
			//determine the type of instruction
			case (inst[6:2])
			
			//I-type
			`JALR: begin
				//perform sign extend
				sz_ex_val = sz_ex_12_to_32(inst[31:20],1'b1);				
			end
			
			`LOAD: begin
				//perform zero or sign extend based on the value of bit 14
				//if bit 14 is 0 perform sign extend, else zero extend
				//use !(bit 14)
				sz_ex_val = sz_ex_12_to_32(inst[31:20],!inst[14]);
			end
			
			`ALU: begin
				//perform zero extension only for SLTIU
				if(inst[14:12] == 3'b011) begin
					sz_ex_val = sz_ex_12_to_32(inst[31:20],1'b0);
				end
				
				//else perform sign extend
				else begin
					sz_ex_val = sz_ex_12_to_32(inst[31:20],1'b1);
				end
			end
				
			default: begin
				//set output to defult value (0)
				sz_ex_val = {`OPERAND_WIDTH{1'b0}};
			end
			
			endcase
			
		end
		
		else begin
			//set output to defult value (0)
			sz_ex_val = {`OPERAND_WIDTH{1'b0}};
		end
		
	end

endmodule


