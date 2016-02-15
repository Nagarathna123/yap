//Control unit

//macros
//instruction width
`define INSTRUCTION_WIDTH 32
//ALU control signal width
`define ALU_CTRL_WIDTH 5

//Instruction types
//R-type
`define R_TYPE 5'b01100
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

module ctrl(
	//outputs
	/*ALU control signal
	bits 2 - 0 : ALU operation to be performed
	bit 3 : Set to 1 when a subtract operation is to be performed
	bit 4 : Set to 1 in case of branch instruction
	*/
	output reg [(`ALU_CTRL_WIDTH-1):0] alu_ctrl,
	//Register file write enable signal
	output reg reg_file_wr_en,
	/*Register file writeback select signal (2 bits)
	(00) output of ALU
	(01) output of data memory
	(10) output of PC+4
	(11) output of PC+immediate value
	*/
	output reg [1:0] reg_file_wr_back_sel,
	//ALU operand select signal
	output reg alu_op2_sel,
	//Data memory read enable signal
	output reg d_mem_rd_en,
	//Data memory write enalbe signal
	output reg d_mem_wr_en,
	/*Data memory size
	(10) 32 bit value
	(01) 16 bit value
	(00) 8 bit value
	(11) undefined
	*/
	output reg [2:0] d_mem_size,
	//JAL instruction
	output reg jal,
	//JALR instruction
	output reg jalr, 
	//inputs
	input [(`INSTRUCTION_WIDTH - 1):0] inst
);
	
	//combinational logic
	always @ (*) begin
		//first check if the input instruction is valid
		if (inst[1:0] == 2'b11) begin
			//determine the type of instruction
			case (inst[6:2])
			
				//R-type
				`R_TYPE: begin
					//set the alu_ctrl signal to be the packed version of
					//bit(3) = inst[31] and remaining bits = funct3 field as specified in the ISA
					//bit(3) = 1 distinguishes between SUB and ADD
					//bit(3) = 1 ==> SUB
					//bit(4) = 0 (No branching)
					//ALU control signal
					alu_ctrl[3:0] = {inst[30], inst[14:12]};
					//no branching
					alu_ctrl[4] = 1'b0;
					//Register file write enable signal
					//the value generated from the ALU is always written back to the register file in R-type
					reg_file_wr_en = 1'b1;
					//Register file writeback select signal
					//by default, the value generated by the ALU is written back 
					reg_file_wr_back_sel = 2'b00;
					//ALU operand select signal
					//the second operand for the ALU is obtained from the register file
					alu_op2_sel = 1'b0;
					//Data memory read enable signal
					//Data memory is not read
					d_mem_rd_en = 1'b0;
					//Data memory write enable signal
					//Data memory is not written to
					d_mem_wr_en = 1'b0;
					//data memory size
					//No data is written to or read from data memory
					d_mem_size = 2'bxx;
					//JAL instruction
					//not valid
					jal = 1'b0;
					//JALR instruction
					//not valid
					jalr = 1'b0;
				end
				
				//I-type
				`JALR: begin
					//ALU control signal
					//copy the MSB bits of the opcode for JALR to the alu_ctrl signal
					alu_ctrl = inst[6:2];
					//Register file write enable signal
					//return address is written to the register file
					reg_file_wr_en = 1'b1;
					//Register file writeback select signal
					//PC+4 is written back to register file
					reg_file_wr_back_sel = 2'b10;
					//ALU operand select signal
					//select the sign or zero extended operand
					alu_op2_sel = 1'b1;
					//Data memory read enable signal
					//nothing is read from data memory
					d_mem_rd_en = 1'b0;
					//Data memory write enalbe signal
					//noting is written to data memory
					d_mem_wr_en = 1'b0;
					//data memory size
					//don't care
					d_mem_size = 2'bxx;
					//JAL instruction
					//not valid
					jal = 1'b0;
					//JALR instruction
					//valid
					jalr = 1'b1;
				end
									
				`LOAD: begin
					//ALU control signal
					//set the ALU control to add operation
					//The operand obtained from the register is added to the immediate value
					//no branching
					alu_ctrl = {(`ALU_CTRL_WIDTH){1'b0}};
					//Register file write enable signal
					//Value read from the data memory is written back to the register file
					reg_file_wr_en = 1'b1;
					//Register file writeback select signal
					//Value read from data memory is written back to register file
					reg_file_wr_back_sel = 2'b01;
					//ALU operand select signal
					//select the sign or zero extended operand
					alu_op2_sel = 1'b1;
					//Data memory read enable signal
					//The value is loaded from data memory
					d_mem_rd_en = 1'b1;
					//Data memory write enalbe signal
					//no value is written to data memory
					d_mem_wr_en = 1'b0;
					//data memory size
					//size depends on the instruction
					d_mem_size = inst[13:12];
					//JAL instruction
					//not valid
					jal = 1'b0;
					//JALR instruction
					//not valid
					jalr = 1'b0;
				end
				
				`ALU: begin
					//ALU control signal
					//set the alu_ctrl signal to {1'b0, "funct3"}
					//bit3 = 1'b0, no subtract instructions (I-type)
					//MSB (bit 4) = 1'b0, no branching
					alu_ctrl = {2'b00, inst[14:12]};
					//Register file write enable signal
					//value generated by the ALU is always written back to the register file
					reg_file_wr_en = 1'b1;
					//Register file writeback select signal
					//select the value generated by the ALU
					reg_file_wr_back_sel = 2'b00;
					//ALU operand select signal
					//select the sign or zero extended immediate value
					alu_op2_sel = 1'b1;
					//Data memory read enable signal
					//no value is read from data memory
					d_mem_rd_en = 1'b0;
					//Data memory write enalbe signal
					//no value is written back to data memory
					d_mem_wr_en = 1'b0;
					//data memory size
					//data is not written to or read from data memory
					d_mem_size = 2'bxx;
					//JAL instruction
					//not valid
					jal = 1'b0;
					//JALR instruction
					//not valid
					jalr = 1'b0;	
				end	
				
				//S-type
				`STORE: begin
					//ALU control signal
					//set the ALU control signal to add "rs1" to immediate value
					//no subtract
					//no branching
					alu_ctrl = {(`ALU_CTRL_WIDTH){1'b0}};
					//Register file write enable signal
					//no write to register file
					reg_file_wr_en = 1'b0;
					//Register file writeback select signal
					//Nothing written back to the register file
					//don't care
					reg_file_wr_back_sel = 2'bxx;
					//ALU operand select signal
					//select the sign or zero extended immediate value
					alu_op2_sel = 1'b1;
					//Data memory read enable signal
					//no data is read from data memory
					d_mem_rd_en = 1'b0;
					//Data memory write enable signal
					//Data is written to data memory
					d_mem_wr_en = 1'b1;
					//data memory size
					//data is written to data memory
					d_mem_size = inst[13:12];
					//JAL instruction
					//not valid
					jal = 1'b0;
					//JALR instruction
					//not valid
					jalr = 1'b0;
				end
				
				//SB-type
				`BRANCH: begin
					//ALU control signal
					//set the alu_ctrl signal to {1'b0, "funct3"}
					//bit3 = 1'b0, no subtract instructions (I-type)
					//MSB (bit 4) = 1'b0, no branching
					alu_ctrl = {(`ALU_CTRL_WIDTH){1'b0}};
					//Register file write enable signal
					//no write to register file
					reg_file_wr_en = 1'b0;
					//Register file writeback select signal
					//Nothing written back to the register file
					//don't care
					reg_file_wr_back_sel = 2'bxx;
					//ALU operand select signal
					//select the sign or zero extended immediate value
					alu_op2_sel = 1'b1;
					//Data memory read enable signal
					//no data is read from data memory
					d_mem_rd_en = 1'b0;
					//Data memory write enable signal
					//Data is written to data memory
					d_mem_wr_en = 1'b1;
					//data memory size
					//data is written to data memory
					d_mem_size = inst[13:12];
					//JAL instruction
					//not valid
					jal = 1'b0;
					//JALR instruction
					//not valid
					jalr = 1'b0;
				end
				
				//U-type
				`U_TYPE: begin
					//ALU control signal
					//The immediate value is written to rd in case of LUI
					//For AUIPC no ALU operation is to performed. Hence set to 'x'
					if(inst[5]==1) begin
						//ensure that the top two bits of alu_ctrl = 2'b11 to avoid conflict with other instructions
						//set the bottom 3 bits to be 0, to convey that it is the LUI instruction to the ALU					
						alu_ctrl = 5'b11000;
					end
					
					else begin
						alu_ctrl = {(`ALU_CTRL_WIDTH){1'bx}};
					end					
					//Register file write enable signal
					//Value read from the data memory is written back to the register file
					reg_file_wr_en = 1'b1;
					//Register file writeback select signal
					//Value read from data memory is written back to register file
					//If LUI, ALU o/p is written to rd. Else pc+offset is written to rd
					if(inst[5]==1) begin
						reg_file_wr_back_sel = 2'b00;
					end
					
					else begin
						reg_file_wr_back_sel = 2'b11;
					end					
					//ALU operand select signal
					//select the sign or zero extended operand for both LUI and AUIPC
					alu_op2_sel = 1'b1;
					//Data memory read enable signal
					//No value is loaded from data memory
					d_mem_rd_en = 1'b0;
					//Data memory write enalbe signal
					//no value is written to data memory
					d_mem_wr_en = 1'b0;
					//JAL instruction
					//not valid
					jal = 1'b0;
					//JALR instruction
					//not valid
					jalr = 1'b0;
				end
				
				//UJ-type
				`JAL:begin
					//For JAL no ALU operation is to performed. Hence set to 'x'
					alu_ctrl = {(`ALU_CTRL_WIDTH){1'bx}};
					//Register file write enable signal
					//PC+4 is written to register file
					reg_file_wr_en = 1'b1;
					//Register file writeback select signal
					//Value 'PC+4' is written back to register file
					reg_file_wr_back_sel = 2'b10;
					//ALU operand select signal
					//No operand is to be selected
					alu_op2_sel = 1'bx;
					//Data memory read enable signal
					//No value is loaded from data memory
					d_mem_rd_en = 1'b0;
					//Data memory write enalbe signal
					//No value is written to data memory
					d_mem_wr_en = 1'b0;
					//JAL instruction					
					jal = 1'b1;
					//JALR instruction
					//not valid
					jalr = 1'b0;
				end			

				//default
				default: begin
					//ALU control signal
					//don't care
					alu_ctrl = {(`ALU_CTRL_WIDTH){1'bx}};
					//Register file write enable signal
					//no write to register file
					reg_file_wr_en = 1'b0;
					//Register file writeback select signal
					//Nothing written back to the register file
					//don't care
					reg_file_wr_back_sel = 2'bxx;
					//ALU operand select signal
					//don't care
					alu_op2_sel = 1'bx;
					//Data memory read enable signal
					//no data is read from data memory
					d_mem_rd_en = 1'b0;
					//Data memory write enable signal
					//no data is written to data memory
					d_mem_wr_en = 1'b0;
					//data memory size
					//data is not written to data memory
					//don't care
					d_mem_size = 2'bxx;
					//JAL instruction
					//not valid
					jal = 1'b0;
					//JALR instruction
					//not valid
					jalr = 1'b0;
				end
				
			endcase
			
		end
		
		else begin
			//ALU control signal
			//don't care
			alu_ctrl = {(`ALU_CTRL_WIDTH){1'bx}};
			//Register file write enable signal
			//no write to register file
			reg_file_wr_en = 1'b0;
			//Register file writeback select signal
			//Nothing written back to the register file
			//don't care
			reg_file_wr_back_sel = 2'bxx;
			//ALU operand select signal
			//don't care
			alu_op2_sel = 1'bx;
			//Data memory read enable signal
			//no data is read from data memory
			d_mem_rd_en = 1'b0;
			//Data memory write enable signal
			//no data is written to data memory
			d_mem_wr_en = 1'b0;
			//data memory size
			//data is not written to data memory
			//don't care
			d_mem_size = 2'bxx;
			//JAL instruction
			//not valid
			jal = 1'b0;
			//JALR instruction
			//not valid
			jalr = 1'b0;
		end
	
	end

endmodule
