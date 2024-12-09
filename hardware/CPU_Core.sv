module CPU_Core(
	input logic CLK, RSTn,
	input logic [31:0] Instruction, data_DMEM,
	output logic [9:0] address_IMEM, address_DMEM,
	output logic [31:0] write_data_DMEM,
	output logic MemWrite, MemRead
);

	logic[2:0] ALUOp;
	logic [1:0] AuipcLui;
	logic [3:0] opcode;
	logic [31:0] PC,PC, Imm_gen, op1, op2, read_data1, read_data2, write_data, ALU_result,write_data_res;
	logic Branch, MemtoReg, ALUSrc, RegWrite, Zero;
	

	ALU alu(
		.opcode(opcode),
		.op1(op1),
		.op2(op2),
		.res(ALU_result),
		.zero(Zero)
	);

	REG reg_bank(
		.CLK(CLK),
		.RSTn(RSTn),
		.RegWrite(RegWrite),
		.read_reg1(Instruction[19:15]),
		.read_reg2(Instruction[24:20]),
		.write_reg(Instruction[11:7]),
		.write_data(write_data),
		.read_data1(read_data1),
		.read_data2(read_data2)
	);

	///////////////////////////////// UNIDAD DE CONTROL ////////////////////////////////////////
	always_comb begin
		case(Instruction[6:0])
			
			7'b0110011: begin //R-format
				Branch = 1'b0;
				MemRead = 1'b0;
				MemtoReg = 1'b0;
				ALUOp = 4'b0000;
				MemWrite = 1'b0;
				ALUSrc = 1'b0;
				RegWrite = 1'b1;
				AuipcLui = 2'd2;
			end 
			7'b0010011: begin //I-format 
				Branch = 1'b0;
				MemRead = 1'b0;
				MemtoReg = 1'b0;
				ALUOp = 4'b0001;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				AuipcLui = 2'd2;
			end 
			7'b0000011: begin //L-format
				Branch = 1'b0;
				MemRead = 1'b1;
				MemtoReg = 1'b1;
				ALUOp = 4'b0010;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				AuipcLui = 2'd2;
			end
			7'b0100011: begin //S-format
				Branch = 1'b0;
				MemRead = 1'b0;
				MemtoReg = 1'b0;
				ALUOp = 4'b0011;
				MemWrite = 1'b1;
				ALUSrc = 1'b1;
				RegWrite = 1'b0;
				AuipcLui = 2'd2;
			end 
			7'b1100111: begin //B-format
				Branch = 1'b1;
				MemRead = 1'b0;
				MemtoReg = 1'b0;
				ALUOp = 4'b0100;
				MemWrite = 1'b0;
				ALUSrc = 1'b0;
				RegWrite = 1'b0;
				AuipcLui = 2'd2;
			end 

			7'b0010111: begin //AUIPC
				Branch = 1'b0;
				MemRead = 1'b0;
				MemtoReg = 1'b0;
				ALUOp = 4'b0101;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				AuipcLui = 2'd0;
			end 

			7'b0110111: begin //LUI
				Branch = 1'b0;
				MemRead = 1'b0;
				MemtoReg = 1'b0;
				ALUOp = 4'b0110;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				AuipcLui = 2'd1;
			end 

			7'b1101111: begin // JAL
				Branch = 1'b1;
				MemRead = 1'b0;
				MemtoReg = 1'b0;
				ALUOp = 4'b0111;
				MemWrite = 1'b0;
				ALUSrc = 1'b0;
				RegWrite = 1'b1;
				AuipcLui = 2'd1;
			end 

			7'b1100111: begin //JALR
				Branch = 1'b1;
				MemRead = 1'b0;
				MemtoReg = 1'b0;
				ALUOp = 4'b1000;
				MemWrite = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				AuipcLui = 2'd2;
			end 
			
			default:  begin 
				Branch = 1'b0;
				MemRead = 1'b0;
				MemtoReg = 1'b0;
				ALUOp = 3'b000;
				MemWrite = 1'b0;
				ALUSrc = 1'b0; 
				RegWrite = 1'b0;
				AuipcLui = 2'b00;
			end 
		endcase	
	end

	//////////////////////////////////////////////// PC //////////////////////////////////////
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
			7'b1100011: Imm_gen = {Instruction[31], 19'd0, Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0}; //Instruccion tipo B
			7'b0010111: Imm_gen = {Instruction[31:12], 12'd0}; //Instruccion tipo U (AUIPC)
			7'b0110111: Imm_gen = {Instruction[31:12], 12'd0}; //Instruccion tipo U (LUI)
			7'b1101111: Imm_gen = {Instruction[31], 11'd0, Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0}; //Instruccion JAL
			7'b1100111: Imm_gen = {Instruction[31], 20'd0, Instruction[30:20]}; //Instruccion JALR
			default: Imm_gen = 32'd0;
		endcase

	end

	

		////////////////////////////////////////////// ALU CONTROL /////////////////////////////////////////////////////
	always_comb begin
	
		case(ALUOp)
			
			4'b0000: //R
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
					default: opcode = 4'd0;
				endcase

			4'b0001: //I
					
				casex({Instruction[30], Instruction[14:12]})
					4'bX000: opcode = 4'b0000;
					4'bX010: opcode = 4'b0010;
					4'bX100: opcode = 4'b0110;
					4'bX110: opcode = 4'b0101;
					4'bX111: opcode = 4'b0100;
					4'bX001: opcode = 4'b0111;
					4'b0101: opcode = 4'b1000;
					4'b1101: opcode = 4'b1001;
					default: opcode = 4'd0;
				endcase

		

			4'b0010: //L
							
				opcode = 4'b0000; //ADD
				

			4'b0011: //S
				
				opcode = 4'b0000; //ADD


			4'b0100: //B
				
				opcode = 4'b0001; //SUB

			4'b0101: //AUIPC
				
				opcode = 4'b0000; //ADD

			4'b0110: //LUI
				
				opcode = 4'b0000; //ADD


			4'b0111: //JAL
				
				opcode = 4'b0100; //AND

			4'b1000: //JALR
				
				opcode = 4'b0000; //ADD

			default: opcode = 4'b0000; //ADD
		endcase
	end

	always_comb begin
		
		case (AuipcLui)
			2'd0: op1 = PC;
			2'd1: op1 = 32'd0;
			2'd2: op1 = read_data1; 
			default: op1 = 32'd0;
		endcase

		op2 = (ALUSrc)? Imm_gen : read_data2;

		write_data_res = (MemtoReg)? data_DMEM: ALU_result;

		if (ALUOp == 4'b0111 || ALUOp == 4'b1000)
		
			write_data = PC + 32'd4;

			else 

			write_data = write_data_res;

		if (ALUOp == 1000)

			PC = write_data_res;

			else

			PC = PC + 32'd4;
			
		address_DMEM = ALU_result[11:2];
		address_IMEM = PC[11:2];
		write_data_DMEM = read_data2;
	end


endmodule