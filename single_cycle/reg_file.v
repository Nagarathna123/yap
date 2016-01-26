//Register File

//Register file properties
`define REGISTER_COUNT 32
`define REGISTER_WIDTH 32
//4 bits required to address 32 registers
`define REG_INDEX_WIDTH 4

module reg_file(
	//output for two register operands (two read ports)
	output [(`REGISTER_WIDTH-1):0] reg_data_1, //bus to send or receive data
	output [(`REGISTER_WIDTH-1):0] reg_data_2, //bus to send or receive data  
	input rst, //reset signal
	input wr_en, //write enable signal
	input clk, //clock signal
	input [(`REG_INDEX_WIDTH-1):0] rd_reg_index_1, //index of register to read from
	input [(`REG_INDEX_WIDTH-1):0] rd_reg_index_2, //index of register to read from
	//single port to write data to register file
	input [(`REG_INDEX_WIDTH-1):0] wr_reg_index, //index of register to write to
	input [(`REGISTER_WIDTH-1):0] wr_reg_data //data to be written to "wr_reg_index"
);

	//register set
	//32 registers, each of width 32 bits
	reg [(`REGISTER_WIDTH-1):0] reg_array [(`REGISTER_COUNT-1):0];
	
	//count integer
	integer i;
	
	//connect the "reg_data_1" and "reg_data_2" ports to the correct registers in "reg_array"
	assign reg_data_1 = reg_array[rd_reg_index_1];
	assign reg_data_2 = reg_array[rd_reg_index_2];
	
	//synchronize reset, read and write operations with clock
	always @ (posedge clk) begin
		if (rst) begin
			//setup defaults
			//set all the register values to zero
			for(i=0; i<`REGISTER_COUNT; i=i+1) begin
				reg_array[i] <= 'b0;
			end
		end
		
		else begin
			//update register file
			//ensure that "reg_array[0]" is not modified (defaults to 0)
			if (wr_en && wr_reg_index != 'b0) begin
				reg_array[wr_reg_index] <= wr_reg_data;
			end
		end
	end

endmodule
