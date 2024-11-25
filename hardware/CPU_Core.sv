module CPU_Core(
	input logic CLK, RSTn,
	input logic [31:0] data_IMEM, data_DMEM,
	output logic [9:0] address_IMEM, address_DMEM,
	output logic [31:0] write_data_DMEM,
	output logic MemWrite, MemRead
);

logic [31:0] Instruccion;
logic Branch,MemtoReg,ALUScr,RegWrite;
logic[2:0] ALUOp;
logic [1:0] AuipcLui;

always_comb begin //Control
case(Instruccion[6:0])
	
		7'b0110011: begin //R-format
		Branch = 1'b0;
		MemRead = 1'b0;
		MemtoReg = 1'b0;
		ALUOp = 3'000;
		MemWrite = 1'b0;
		ALUScr = 1'b0;
		RegWrite = 1'b1;
		AuipcLui = 2'b10;
		end 
		7'b0010011: begin //I-format 
		Branch = 1'b0;
		MemRead = 1'b0;
		MemtoReg = 1'b0;
		ALUOp = 3'b001;
		MemWrite = 1'b0;
		ALUScr = 1'b1;
		RegWrite = 1'b1;
		AuipcLui = 2'b10;
		end 
		7'b0000011: begin //L-format
		Branch = 1'b0;
		MemRead = 1'b0;
		MemtoReg = 1'b0;
		ALUOp = 3'b010;
		MemWrite = 1'b1;
		ALUScr = 1'b1;
		RegWrite = 1'b1;
		AuipcLui = 2'b10;
		end
		7'0100011: begin //S-format
		Branch = 1'b0;
		MemRead = 1'b1;
		MemtoReg = 1'b1;
		ALUOp = 3'b011;
		MemWrite = 1'b0;
		ALUScr = 1'b1;
		RegWrite = 1'b1;
		AuipcLui = 2'b10;
		end 
		7'1100011: begin //B-format
		Branch = 1'b1;
		MemRead = 1'b0;
		MemtoReg = 1'b0;
		ALUOp = 3'b100;
		MemWrite = 1'b0;
		ALUScr = 1'b1;
		RegWrite = 1'b1;
		AuipcLui = 2'b10;
		end 
		
		default:  begin 
		Branch = 1'b0;
		MemRead = 1'b0;
		MemtoReg = 1'b0;
		ALUOp = 2'b00;
		MemWrite = 1'b0;
		ALUScr = 1'b0;
		RegWrite = 1'b0;
		AuipcLui = 2'b00;
		end ;
endcase
	
end

endmodule