//Control unit

//instruction width
`define INSTRUCTION_WIDTH 32
//ALU control signal width
`define ALU_CTRL_WIDTH 4

//macros
`define R_TYPE 5'b01100

module ctrl(
	//outputs
	//ALU control signal
	output reg [(`ALU_CTRL_WIDTH-1):0] alu_ctrl,
	//Register file write enable signal
	output reg reg_file_wr_en,
	//Register file writeback select signal
	output reg reg_file_wr_back_sel,
	//ALU operand select signal
	output reg alu_op2_sel,
	//Data memory read enable signal
	output reg data_mem_rd_en,
	//Data memory write enalbe signal
	output reg data_mem_wr_en,
	
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
					//MSB = inst[31] and remaining bits = funct3 field as specified in the ISA
					//MSB = 1 distinguishes between SUB and ADD
					//MSB = 1 ==> SUB
					//ALU control signal
					alu_ctrl = {inst[30], inst[14:12]};
					//Register file write enable signal
					reg_file_wr_en = 1'b1;
					//Register file writeback select signal
					reg_file_wr_back_sel = 1'b1;
					//ALU operand select signal
					//let the default value be the one obtained from the register (0)
					//(1) implies imeediate zero or sign extended value
					alu_op2_sel = 1'b0;
					//Data memory read enable signal
					data_mem_rd_en = 1'b0;
					//Data memory write enalbe signal
					data_mem_wr_en = 1'b0;
				end
				
				default: begin
					//set all signals to default value (0)
					//ALU control signal
					alu_ctrl = {(`ALU_CTRL_WIDTH){1'b0}};
					//Register file write enable signal
					reg_file_wr_en = 1'b0;
					//Register file writeback select signal
					reg_file_wr_back_sel = 1'b0;
					//ALU operand select signal
					alu_op2_sel = 1'b0;
					//Data memory read enable signal
					data_mem_rd_en = 1'b0;
					//Data memory write enalbe signal
					data_mem_wr_en = 1'b0;
				end
			
			endcase
		end
		
		else begin
			//set all signals to default value (0)
			//ALU control signal
			alu_ctrl = {(`ALU_CTRL_WIDTH){1'b0}};
			//Register file write enable signal
			reg_file_wr_en = 1'b0;
			//Register file writeback select signal
			reg_file_wr_back_sel = 1'b0;
			//ALU operand select signal
			alu_op2_sel = 1'b0;
			//Data memory read enable signal
			data_mem_rd_en = 1'b0;
			//Data memory write enalbe signal
			data_mem_wr_en = 1'b0;
		end
	end

endmodule
