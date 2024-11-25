module CPU_Core(
	input logic CLK, RSTn,
	input logic [31:0] data_IMEM, read_data_DMEM,
	output logic [9:0] address_IMEM, address_DMEM,
	output logic [31:0] write_data_DMEM,
	output logic w_DMEM
);

	logic [31:0] PC;
	
	logic Branch, Zero, MemRead, MemtoReg, ALUSrc, RegWrite; 
	
	logic [31:0] reg_bank_write_data, reg_bank_read_data1;
	
	logic [31:0] alu_result, alu_op1, alu_op2;
	
	logic [31:0] Imm_gen;
	
	ALU alu(
		.opcode(),
		.op1(alu_op1),
		.op2(alu_op2),
		.res(alu_result),
		.zero(Zero)
	);
	
	REG reg_bank(
		.CLK(CLK),
		.RSTn(RSTn),
		.RegWrite(RegWrite),
		.read_reg1(data_IMEM[19:15]),
		.read_reg2(data_IMEM[24:20]),
		.write_reg(data_IMEM[11:7]),
		.write_data(reg_bank_write_data),
		.read_data1(reg_bank_read_data1),
		.read_data2(write_data_DMEM)
	);
	
	always_comb begin
		
		reg_bank_write_data = (MemtoReg)? read_data_DMEM : alu_result;
		
		alu_op2 = (ALUSrc)? Imm_gen : write_data_DMEM;
		
		///////////Auipc Y Lui//////////////////
		if() alu_op1 = PC; 
		else if() alu_op1 = reg_bank_read_data1; 
		else alu_op1 = 32'd0;
	
	end
	
	////////////////////////////////////////////// Imm_gen/////////////////////////////////////////////////////
	always_comb begin 
		if(data_IMEM[6:0] == 7'b0010011 || data_IMEM[6:0] == 7'b0000011) //Instruccion tipo I y de carga (LW)
			Imm_gen = {data_IMEM[31], 20'd0, data_IMEM[30:20]};
			
		else if (data_IMEM[6:0] == 7'b0100011) //Instruccion tipo S
			Imm_gen = {data_IMEM[31], 20'd0 , data_IMEM[30:25], data_IMEM[11:7]};
		
		else if (data_IMEM[6:0] == 7'b1100011) //Instruccion tipo B
			Imm_gen = {data_IMEM[31], 19'd0, , data_IMEM[7], data_IMEM[30:25], data_IMEM[11:8], 1'b0};
		
		else if (data_IMEM[6:0] == 7'b0010111 || data_IMEM[6:0] == 7'b0110111) //Instruccion tipo U (LUI y AUIPC)
			Imm_gen = {data_IMEM[31:12], 12'd0};
			
		else if (data_IMEM[6:0] == 7'b1101111) //Instruccion JAL
			Imm_gen = {data_IMEM[31], 11'd0, data_IMEM[19:12], data_IMEM[20], data_IMEM[30:21], 1'b0};
			
		else if (data_IMEM[6:0] == 7'b1100111) //Instruccion JALR
			Imm_gen = {data_IMEM[31], 20'd0, data_IMEM[30:20]};
		else
			Imm_gen = 32'd0;
	end
	
	always_ff @(posedge CLK, negedge RSTn) begin
	
		if(!RSTn) begin
			PC <= 32'd0;
		end
		
		else begin
			if (Branch && Zero) PC = PC + Imm_gen;
			else PC = PC + 32'd4;
		end
	
	end

	assign address_IMEM = PC[11:2];
	assign address_DMEM = alu_result[11:2];
	
	
endmodule