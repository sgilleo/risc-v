module CPU_Core(
	input logic CLK, RSTn,
	input logic [31:0] idata, ddata_r,
	output logic [9:0] iaddr, daddr,
	output logic [31:0] ddata_w,
	output logic d_w, d_r
);

	logic[2:0] ALUOp;
	logic [1:0] AuipcLui, MemtoReg;
	logic [3:0] opcode;
	logic [31:0] PC, Imm_gen, op1, op2, read_data1, read_data2, write_data, ALU_result;
	logic Branch, ALUSrc, RegWrite, Zero, ALUToPC;

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
		.read_reg1(idata[19:15]),
		.read_reg2(idata[24:20]),
		.write_reg(idata[11:7]),
		.write_data(write_data),
		.read_data1(read_data1),
		.read_data2(read_data2)
	);

	///////////////////////////////// UNIDAD DE CONTROL ////////////////////////////////////////
	always_comb begin
		case(idata[6:0])
			
			7'b0110011: begin //R-format
				Branch = 1'b0;
				d_r = 1'b0;
				MemtoReg = 2'd0;
				ALUOp = 3'b000;
				ALUToPC = 1'b0;
				d_w = 1'b0;
				ALUSrc = 1'b0;
				RegWrite = 1'b1;
				AuipcLui = 2'd2;
			end 
			7'b0010011: begin //I-format 
				Branch = 1'b0;
				d_r = 1'b0;
				MemtoReg = 2'd0;
				ALUOp = 3'b001;
				ALUToPC = 1'b0;
				d_w = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				AuipcLui = 2'd2;
			end 
			7'b0000011: begin //L-format
				Branch = 1'b0;
				d_r = 1'b1;
				MemtoReg = 2'd1;
				ALUOp = 3'b010;
				ALUToPC = 1'b0;
				d_w = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				AuipcLui = 2'd2;
			end
			7'b0100011: begin //S-format
				Branch = 1'b0;
				d_r = 1'b0;
				MemtoReg = 2'd0;
				ALUOp = 3'b010;
				ALUToPC = 1'b0;
				d_w = 1'b1;
				ALUSrc = 1'b1;
				RegWrite = 1'b0;
				AuipcLui = 2'd2;
			end 
			7'b1100011: begin //B-format
				Branch = 1'b1;
				d_r = 1'b0;
				MemtoReg = 2'd0;
				ALUOp = 3'b100;
				ALUToPC = 1'b0;
				d_w = 1'b0;
				ALUSrc = 1'b0;
				RegWrite = 1'b0;
				AuipcLui = 2'd2;
			end

			7'b0010111: begin //AUIPC
				Branch = 1'b0;
				d_r = 1'b0;
				MemtoReg = 2'd0;
				ALUOp = 3'b010;
				ALUToPC = 1'b0;
				d_w = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				AuipcLui = 2'd0;
			end 

			7'b0110111: begin //LUI
				Branch = 1'b0;
				d_r = 1'b0;
				MemtoReg = 2'd0;
				ALUOp = 3'b010;
				ALUToPC = 1'b0;
				d_w = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				AuipcLui = 2'd1;
			end 

			7'b1101111: begin // JAL
				Branch = 1'b1;
				d_r = 1'b0;
				MemtoReg = 2'd2;
				ALUOp = 3'b101;
				ALUToPC = 1'b0;
				d_w = 1'b0;
				ALUSrc = 1'b0;
				RegWrite = 1'b1;
				AuipcLui = 2'd1;
			end 

			7'b1100111: begin //JALR
				Branch = 1'b1;
				d_r = 1'b0;
				MemtoReg = 2'd0;
				ALUOp = 3'b010;
				ALUToPC = 1'b1;
				d_w = 1'b0;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
				AuipcLui = 2'd2;
			end 
			
			default:  begin 
				Branch = 1'b0;
				d_r = 1'b0;
				MemtoReg = 2'd0;
				ALUOp = 2'b00;
				ALUToPC = 1'b0;
				d_w = 1'b0;
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
			case ({Branch & Zero, ALUToPC})
				2'b00: PC <= PC + 32'd4;
				2'b10: PC <= PC + Imm_gen;
				2'bX1: PC <= ALU_result;
				default: PC <= PC + 32'd4;
			endcase
		end

	end

	////////////////////////////////////////////////////// Imm_gen/////////////////////////////////////////////////////
	always_comb begin 
		
		case (idata[6:0])
			7'b0010011: Imm_gen = {idata[31], 20'd0, idata[30:20]}; //Instruccion tipo I 
			7'b0000011: Imm_gen = {idata[31], 20'd0, idata[30:20]}; //Instruccion de carga (LW)
			7'b0100011: Imm_gen = {idata[31], 20'd0 , idata[30:25], idata[11:7]}; //Instruccion tipo S
			7'b1100011: Imm_gen = {idata[31], 19'd0, idata[7], idata[30:25], idata[11:8], 1'b0}; //Instruccion tipo B
			7'b0010111: Imm_gen = {idata[31:12], 12'd0}; //Instruccion tipo U (AUIPC)
			7'b0110111: Imm_gen = {idata[31:12], 12'd0}; //Instruccion tipo U (LUI)
			7'b1101111: Imm_gen = {idata[31], 11'd0, idata[19:12], idata[20], idata[30:21], 1'b0}; //Instruccion JAL
			7'b1100111: Imm_gen = {idata[31], 20'd0, idata[30:20]}; //Instruccion JALR
			default: Imm_gen = 32'd0;
		endcase

	end

	

		////////////////////////////////////////////// ALU CONTROL /////////////////////////////////////////////////////
	always_comb begin
	
		case(ALUOp)
			
			3'b000: //R
				case({idata[30], idata[14:12]})

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

			3'b001: //I
					
				casex({idata[30], idata[14:12]})
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


			3'b010: //L, S, AUIPC, LUI, JALR
							
				opcode = 4'b0000; //ADD
				

			3'b100: //B

				case (idata[14:12])
					3'b000: opcode = 4'b0001; //BEQ
					3'b101: opcode = 4'b0011; //BGE
					default: opcode = 4'b0001;
				endcase
			

			3'b101: //JAL
				
				opcode = 4'b0100; //AND


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

		case (MemtoReg)
			2'd0: write_data = ALU_result;
			2'd1: write_data = ddata_r;
			2'd2: write_data = PC + 32'd4;
			default: write_data = 32'd0;
		endcase

		daddr = ALU_result[11:2];
		iaddr = PC[11:2];
		ddata_w = read_data2;
	end


endmodule