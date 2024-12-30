module CPU_Core_Pipelined(
	input logic CLK, RSTn,
	input logic [31:0] idata, ddata_r,
	output logic [9:0] iaddr, daddr,
	output logic [31:0] ddata_w,
	output logic d_w, d_r
);

	logic [3:0] opcode;
	logic [31:0] PC, op1, op2, read_data1, read_data2, write_data, ALU_result;
	logic Zero;

    //ETAPA IF/ID
    logic [31:0] Instruction_IFID, PC_IFID;
    //ETAPA ID/EX
    logic RegWrite_IDEX, Branch_IDEX, MemRead_IDEX, MemWrite_IDEX, ALUSrc_IDEX, ALUToPC_IDEX;
    logic [2:0] ALUOp_IDEX;
    logic [31:0] PC_IDEX, read_data1_IDEX, read_data2_IDEX, Imm_gen_IDEX;
    logic [3:0] ALUControl_IDEX;
    logic [4:0] write_reg_IDEX;
    logic [1:0] AuipcLui_IDEX, MemtoReg_IDEX;
    //ETAPA EX/MEM
    logic RegWrite_EXMEM, Branch_EXMEM, MemRead_EXMEM, MemWrite_EXMEM, Zero_EXMEM, ALUToPC_EXMEM;
    logic [31:0] PC_EXMEM, New_PC_EXMEM, ALU_result_EXMEM, read_data2_EXMEM;
    logic [4:0] write_reg_EXMEM;
    logic [1:0] MemtoReg_EXMEM;
    //ETAPA MEM/WB
    logic RegWrite_MEMWB;
    logic [31:0] ALU_result_MEMWB, ddata_r_MEMWB, PC_MEMWB;
    logic [4:0] write_reg_MEMWB;
    logic [1:0] MemtoReg_MEMWB;

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
		.RegWrite(RegWrite_MEMWB),
		.read_reg1(Instruction_IFID[19:15]),
		.read_reg2(Instruction_IFID[24:20]),
		.write_reg(write_reg_MEMWB),
		.write_data(write_data),
		.read_data1(read_data1),
		.read_data2(read_data2)
	);

    always_ff @(posedge CLK, negedge RSTn) begin
        if (!RSTn) begin
            //ETAPA IF/ID
            Instruction_IFID <= 32'd0;
            PC_IFID <= 32'd0;
            //ETAPA ID/EX
            RegWrite_IDEX <= 1'b0;
            MemtoReg_IDEX <= 2'd0;
            Branch_IDEX <= 1'b0;
            MemRead_IDEX <= 1'b0;
            MemWrite_IDEX <= 1'b0;
            ALUSrc_IDEX <= 1'b0;
            ALUOp_IDEX <= 3'd0;
            AuipcLui_IDEX <= 2'd0;
            PC_IDEX<= 32'd0;
            read_data1_IDEX <= 32'd0;
            read_data2_IDEX <= 32'd0;
            Imm_gen_IDEX <= 32'd0;
            ALUControl_IDEX <= 4'd0;
            write_reg_IDEX <= 5'd0;
            ALUToPC_IDEX <= 1'b0;
            //ETAPA EX/MEM
            RegWrite_EXMEM <= 1'b0;
            MemtoReg_EXMEM <= 2'd0;
            Branch_EXMEM <= 1'b0;
            MemRead_EXMEM <= 1'b0;
            MemWrite_EXMEM <= 1'b0;
            Zero_EXMEM <= 1'b0;
            PC_EXMEM <= 32'd0;
            New_PC_EXMEM <= 32'd0;
            ALU_result_EXMEM <= 32'd0;
            read_data2_EXMEM <= 32'd0;
            write_reg_EXMEM <= 5'd0;
            ALUToPC_EXMEM <= 1'b0;
            //ETAPA MEM/WB
            RegWrite_MEMWB <= 1'b0;
            MemtoReg_MEMWB <= 2'd0;
            ALU_result_MEMWB <= 32'd0;
            ddata_r_MEMWB <= 32'd0;
            write_reg_MEMWB <= 5'd0;
            PC_MEMWB <= 32'd0;
        end

        else begin
            //ETAPA IF/ID
            Instruction_IFID <= idata;
            PC_IFID <= PC;
            //ETAPA ID/EX
            PC_IDEX <= PC_IFID;
            read_data1_IDEX <= read_data1;
            read_data2_IDEX <= read_data2;
            ////////////// Imm_gen/////////////////
            case (Instruction_IFID[6:0])
                7'b0010011: Imm_gen_IDEX <= {{21{Instruction_IFID[31]}}, Instruction_IFID[30:20]}; //Instruccion tipo I 
                7'b0000011: Imm_gen_IDEX <= {{21{Instruction_IFID[31]}}, Instruction_IFID[30:20]}; //Instruccion de carga (LW)
                7'b0100011: Imm_gen_IDEX <= {{21{Instruction_IFID[31]}}, Instruction_IFID[30:25], Instruction_IFID[11:7]}; //Instruccion tipo S
                7'b1100011: Imm_gen_IDEX <= {{20{Instruction_IFID[31]}}, Instruction_IFID[7], Instruction_IFID[30:25], Instruction_IFID[11:8], 1'b0}; //Instruccion tipo B
                7'b0010111: Imm_gen_IDEX <= {Instruction_IFID[31:12], 12'd0}; //Instruccion tipo U (AUIPC)
                7'b0110111: Imm_gen_IDEX <= {Instruction_IFID[31:12], 12'd0}; //Instruccion tipo U (LUI)
                7'b1101111: Imm_gen_IDEX <= {{12{Instruction_IFID[31]}}, Instruction_IFID[19:12], Instruction_IFID[20], Instruction_IFID[30:21], 1'b0}; //Instruccion JAL
                7'b1100111: Imm_gen_IDEX <= {{21{Instruction_IFID[31]}}, Instruction_IFID[30:20]}; //Instruccion JALR
			    default: Imm_gen_IDEX <= 32'd0;
            endcase

            //Unidad de control
            case(Instruction_IFID[6:0])
			
                7'b0110011: begin //R-format
                    Branch_IDEX <= 1'b0;
                    MemRead_IDEX <= 1'b0;
                    MemtoReg_IDEX <= 2'd0;
                    ALUOp_IDEX <= 3'b000;
                    ALUToPC_IDEX <= 1'b0;
                    MemWrite_IDEX <= 1'b0;
                    ALUSrc_IDEX <= 1'b0;
                    RegWrite_IDEX <= 1'b1;
                    AuipcLui_IDEX <= 2'd2;
                end 
                7'b0010011: begin //I-format 
                    Branch_IDEX <= 1'b0;
                    MemRead_IDEX <= 1'b0;
                    MemtoReg_IDEX <= 2'd0;
                    ALUOp_IDEX <= 3'b001;
                    ALUToPC_IDEX <= 1'b0;
                    MemWrite_IDEX <= 1'b0;
                    ALUSrc_IDEX <= 1'b1;
                    RegWrite_IDEX <= 1'b1;
                    AuipcLui_IDEX <= 2'd2;
                end 
                7'b0000011: begin //L-format
                    Branch_IDEX <= 1'b0;
                    MemRead_IDEX <= 1'b1;
                    MemtoReg_IDEX <= 2'd1;
                    ALUOp_IDEX <= 3'b010;
                    ALUToPC_IDEX <= 1'b0;
                    MemWrite_IDEX <= 1'b0;
                    ALUSrc_IDEX <= 1'b1;
                    RegWrite_IDEX <= 1'b1;
                    AuipcLui_IDEX <= 2'd2;
                end
                7'b0100011: begin //S-format
                    Branch_IDEX <= 1'b0;
                    MemRead_IDEX <= 1'b0;
                    MemtoReg_IDEX <= 2'd0;
                    ALUOp_IDEX <= 3'b010;
                    ALUToPC_IDEX <= 1'b0;
                    MemWrite_IDEX <= 1'b1;
                    ALUSrc_IDEX <= 1'b1;
                    RegWrite_IDEX <= 1'b0;
                    AuipcLui_IDEX <= 2'd2;
                end 
                7'b1100011: begin //B-format
                    Branch_IDEX <= 1'b1;
                    MemRead_IDEX <= 1'b0;
                    MemtoReg_IDEX <= 2'd0;
                    ALUOp_IDEX <= 3'b100;
                    ALUToPC_IDEX <= 1'b0;
                    MemWrite_IDEX <= 1'b0;
                    ALUSrc_IDEX <= 1'b0;
                    RegWrite_IDEX <= 1'b0;
                    AuipcLui_IDEX <= 2'd2;
                end

                7'b0010111: begin //AUIPC
                    Branch_IDEX <= 1'b0;
                    MemRead_IDEX <= 1'b0;
                    MemtoReg_IDEX <= 2'd0;
                    ALUOp_IDEX <= 3'b010;
                    ALUToPC_IDEX <= 1'b0;
                    MemWrite_IDEX <= 1'b0;
                    ALUSrc_IDEX <= 1'b1;
                    RegWrite_IDEX <= 1'b1;
                    AuipcLui_IDEX <= 2'd0;
                end

                7'b0110111: begin //LUI
                    Branch_IDEX <= 1'b0;
                    MemRead_IDEX <= 1'b0;
                    MemtoReg_IDEX <= 2'd0;
                    ALUOp_IDEX <= 3'b010;
                    ALUToPC_IDEX <= 1'b0;
                    MemWrite_IDEX <= 1'b0;
                    ALUSrc_IDEX <= 1'b1;
                    RegWrite_IDEX <= 1'b1;
                    AuipcLui_IDEX <= 2'd1;
                end

                7'b1101111: begin // JAL
                    Branch_IDEX <= 1'b1;
                    MemRead_IDEX <= 1'b0;
                    MemtoReg_IDEX <= 2'd2;
                    ALUOp_IDEX <= 3'b101;
                    ALUToPC_IDEX <= 1'b0;
                    MemWrite_IDEX <= 1'b0;
                    ALUSrc_IDEX <= 1'b0; 
                    RegWrite_IDEX <= 1'b1;
                    AuipcLui_IDEX <= 2'd1;
                end

                7'b1100111: begin //JALR
                    Branch_IDEX <= 1'b1;
                    MemRead_IDEX <= 1'b0;
                    MemtoReg_IDEX <= 2'd2;
                    ALUOp_IDEX <= 3'b010;
                    ALUToPC_IDEX <= 1'b1;
                    MemWrite_IDEX <= 1'b0;
                    ALUSrc_IDEX <= 1'b1; 
                    RegWrite_IDEX <= 1'b1;
                    AuipcLui_IDEX <= 2'd2;
                end

                default:  begin 
                    Branch_IDEX <= 1'b0;
                    MemRead_IDEX <= 1'b0;
                    MemtoReg_IDEX <= 2'd0;
                    ALUOp_IDEX <= 3'b000;
                    ALUToPC_IDEX <= 1'b0;
                    MemWrite_IDEX <= 1'b0;
                    ALUSrc_IDEX <= 1'b0; 
                    RegWrite_IDEX <= 1'b0;
                    AuipcLui_IDEX <= 2'd0;
                end 
		    endcase

            ALUControl_IDEX <= {Instruction_IFID[30], Instruction_IFID[14:12]};
            write_reg_IDEX <= Instruction_IFID[11:7];
		
            //ETAPA EX/MEM
            RegWrite_EXMEM <= RegWrite_IDEX;
            MemtoReg_EXMEM <= MemtoReg_IDEX;
            Branch_EXMEM <= Branch_IDEX;
            MemRead_EXMEM <= MemRead_IDEX;
            MemWrite_EXMEM <= MemWrite_IDEX;
            PC_EXMEM <= PC_IDEX + Imm_gen_IDEX;
            New_PC_EXMEM <= PC_IDEX + 32'd4;
            Zero_EXMEM <= Zero;
            ALU_result_EXMEM <= ALU_result;
            read_data2_EXMEM <= read_data2_IDEX;
            write_reg_EXMEM <= write_reg_IDEX;
            ALUToPC_EXMEM <= ALUToPC_IDEX;

            //ETAPA MEM/WB
            RegWrite_MEMWB <= RegWrite_EXMEM;
            MemtoReg_MEMWB <= MemtoReg_EXMEM;
            ddata_r_MEMWB <= ddata_r;
            ALU_result_MEMWB <= ALU_result_EXMEM;
            write_reg_MEMWB <= write_reg_EXMEM;
            PC_MEMWB <= New_PC_EXMEM;
        end
    end

	//////////////////////////////////////////////// PC //////////////////////////////////////
	always_ff @(posedge CLK, negedge RSTn) begin

		if(!RSTn) PC <= 32'd0;

		else begin
            case ({Branch_EXMEM & Zero_EXMEM, ALUToPC_EXMEM})
                2'b00: PC <= PC + 32'd4;
                2'b10: PC <= PC_EXMEM;
                2'b01: PC <= ALU_result_EXMEM;
                2'b11: PC <= ALU_result_EXMEM;
            endcase
		end

	end	

    assign daddr = ALU_result_EXMEM[11:2];
    assign ddata_w = read_data2_EXMEM;
    assign iaddr = PC[11:2];
    assign d_w = MemWrite_EXMEM;
    assign d_r = MemRead_EXMEM;

    ////////////////////////////////////////////// ALU CONTROL /////////////////////////////////////////////////////
	always_comb begin
	
		case(ALUOp_IDEX)
			
			3'b000: //R
				case(ALUControl_IDEX)

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
					
				casex(ALUControl_IDEX)
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

				case (ALUControl_IDEX[2:0])
					3'b000: opcode = 4'b0001; //BEQ
                    3'b100: opcode = 4'b1010; //BLT
					3'b101: opcode = 4'b0010; //BGE
                    3'b110: opcode = 4'b1011; //BLTU
                    3'b111: opcode = 4'b0011; //BGEU
					default: opcode = 4'b0001;
				endcase
			

			3'b101: //JAL
				
				opcode = 4'b0100; //AND


			default: opcode = 4'b0000; //ADD
		endcase
	end

	always_comb begin
		op2 = (ALUSrc_IDEX)? Imm_gen_IDEX : read_data2_IDEX;
        case (MemtoReg_MEMWB)
            2'd0: write_data = ALU_result_MEMWB;
            2'd1: write_data = ddata_r_MEMWB;
            2'd2: write_data = PC_MEMWB;
            default: write_data = 32'd0;
        endcase

        case (AuipcLui_IDEX)
            2'd0: op1 = PC_IDEX;
            2'd1: op1 = 32'd0;
            2'd2: op1 = read_data1_IDEX;
            default: op1 = 32'd0;
        endcase

	end


endmodule