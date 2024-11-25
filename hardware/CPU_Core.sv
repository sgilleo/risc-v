module CPU_Core(
	input logic CLK, RSTn,
	input logic [31:0] data_IMEM, data_DMEM,
	output logic [9:0] address_IMEM, address_DMEM,
	output logic [31:0] write_data_DMEM,
	output logic MemWrite, MemRead
);

	logic [3:0] opcode;
	logic [31:0] PC, Imm_gen, Instruction;
	logic Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Zero;

	ALU alu(
		.opcode(opcode),
		.op1(),
		.op2(),
		.res(),
		.zero(Zero)
	);

	REG reg_bank(
		.CLK(CLK),
		.RSTn(RSTn),
		.RegWrite(RegWrite),
		.read_reg1(),
		.read_reg2(),
		.write_reg(),
		.write_data(),
		.read_data1(),
		.read_data2()
	);


	always_ff @(posedge CLK, negedge RSTn) begin

		if(!RSTn) PC <= 32'd0;

		else begin
			if(Branch && Zero) PC <= PC + Imm_gen;
			else PC <= PC + 32'd4;
		end

	end

	////////////////////////////////////////////////////// Imm_gen/////////////////////////////////////////////////////
	always_comb begin 
		
		case (Instruction[6:0])
			7'b0010011: Imm_gen = {Instruction[31], 20'd0, Instruction[30:20]}; //Instruccion tipo I 
			7'b0000011: Imm_gen = {Instruction[31], 20'd0, Instruction[30:20]}; //Instruccion de carga (LW)
			7'b0100011: Imm_gen = {Instruction[31], 20'd0 , Instruction[30:25], Instruction[11:7]}; //Instruccion tipo S
			7'b1100011: Imm_gen = {Instruction[31], 19'd0, , Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0}; //Instruccion tipo B
			7'b0010111: Imm_gen = {Instruction[31:12], 12'd0}; //Instruccion tipo U (AUIPC)
			7'b0110111: Imm_gen = {Instruction[31:12], 12'd0}; //Instruccion tipo U (LUI)
			7'b1101111: Imm_gen = {Instruction[31], 11'd0, Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0}; //Instruccion JAL
			7'b1100111: Imm_gen = {Instruction[31], 20'd0, Instruction[30:20]}; //Instruccion JALR
			default: Imm_gen = 32'd0;
		endcase

	end

	assign Instruction = data_IMEM;

		////////////////////////////////////////////// ALU CONTROL /////////////////////////////////////////////////////
	always_comb begin
	
	case(ALUOp)

		
	2'b00:
				case({Instruction[30], Instruction[14:12]})

					4'b0000: opcode = 4'b0000;
					4'b1000: opcode = 4'b0001;
					4'b0001: opcode = 4'b0010;
					4'b0010: opcode = 4'b0011;
					4'b0011: opcode = 4'b0100;
					4'b0100: opcode = 4'b0110;
					4'b0101: opcode = 4'b1000;
					4'b1101: opcode = 4'b1001;
					4'b0110: opcode = 4'b0101;
					4'b0111: opcode = 4'b0100;

				endcase

	2'b01:
			
				casex({Instruction[30], Instruction[14:12]})
					4'bX000: opcode = 4'b0000;
					4'bX010: opcode = 4'b0010;
					4'bX100: opcode = 4'b0110;
					4'bX110: opcode = 4'b0101;
					4'bX111: opcode = 4'b0100;
					4'b0001: opcode = 4'b0111;
					4'b0101: opcode = 4'b1000;
					4'b1101: opcode = 4'b1001;
				endcase

		endcase


	end

endmodule