//sign and zero extend

//Include header
`include "sz_ex.h"

//macros for zero and sign extend arguments
`define ZERO_EXTEND 1'b0
`define SIGN_EXTEND 1'b1

//instruction types
//I-type
`define JALR 5'b11001
`define LOAD 5'b00000
`define ALU 5'b00100
//S-type
`define STORE 5'b01000
//SB-type
`define BRANCH 5'b11000
//U-type
`define U_TYPE 5'b01101, 5'b00101
//UJ-type
`define JAL 5'b11011
   
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
			
			if (k==`SIGN_EXTEND) begin
				//sign extend
				//replicate sign bits
				sz_ex_12_to_32[31:12] = {(`OPERAND_WIDTH-12){val[11]}};
			end
			
			else begin
				//zero extend
				sz_ex_12_to_32[31:12] = {(`OPERAND_WIDTH-12){1'b0}};
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
				sz_ex_val = sz_ex_12_to_32(inst[31:20],`SIGN_EXTEND);				
			end
			
			`LOAD: begin
				//perform zero or sign extend based on the value of bit 14
				//if bit 14 is 0 perform sign extend, else zero extend
				//use !(bit 14)
				sz_ex_val = sz_ex_12_to_32(inst[31:20],!inst[14]);
			end
			
			`ALU: begin
				//handle SHIFT instruction immediate values separately
				//SLLI, SRLI and SRAI
				if(inst[14:12] == 3'b001 || inst[14:12] == 3'b101) begin
					//set the output to the unsigned shift amount
					sz_ex_val[4:0] = inst[24:20];
					sz_ex_val[31:5] = {(`OPERAND_WIDTH-5){1'b0}};
				end
				
				//handle remaining ALU instructions
				else begin
					//perform zero extension only for SLTIU
					if(inst[14:12] == 3'b011) begin
						sz_ex_val = sz_ex_12_to_32(inst[31:20], `ZERO_EXTEND);
					end
					
					//else perform sign extend
					else begin
						sz_ex_val = sz_ex_12_to_32(inst[31:20], `SIGN_EXTEND);
					end
				end
			end
			
			`STORE: begin
				//perform sign extend
				sz_ex_val = sz_ex_12_to_32({inst[31:25],inst[11:7]}, `SIGN_EXTEND);
			end
			
			`BRANCH: begin
				//perform zero extend for BLTU and BGEU
				//(bits 13 and 14 are both 1 for BLTU and BGEU)
				//the immediate offset is specified as multiples of two bytes 
				if(inst[14:13] == 2'b11) begin
					sz_ex_val[0] = 1'b0;
					sz_ex_val[12:1] = {inst[31], inst[7], inst[30:25], inst[11:6]};
					sz_ex_val[31:13] = {(`OPERAND_WIDTH-13){1'b0}};
				end
				
				//else perform sign extend
				else begin
					sz_ex_val[0] = 1'b0;
					sz_ex_val[12:1] = {inst[31], inst[7], inst[30:25], inst[11:6]};
					sz_ex_val[31:13] = {(`OPERAND_WIDTH-13){inst[31]}};
				end
			end
			
			`U_TYPE: begin
				//copy the 20 bit immediate to the MSB 20 bits of the output
				//fill the remaining LSB bits with zeros
				//handles immediate values for LUI and AUIPC
				sz_ex_val[31:12] = inst[31:12];
				sz_ex_val[11:0] = {(`OPERAND_WIDTH-20){1'b0}};
			end
			
			`JAL: begin
				//offset is a multiple of two bytes
				//Therefore, least significant bit of output is zero
				//subsequent 20 bits represent the immediate value
				//immediate is sign extended
				sz_ex_val[0] = 1'b0;
				sz_ex_val[20:1] = {inst[31], inst[19:12], inst[20], inst[30:21]};
				sz_ex_val[31:21] = {(`OPERAND_WIDTH-21){inst[31]}};
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
