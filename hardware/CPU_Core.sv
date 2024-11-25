module CPU_Core(
	input logic CLK, RSTn,
	input logic [31:0] data_IMEM, data_DMEM,
	output logic [9:0] address_IMEM, address_DMEM,
	output logic [31:0] write_data_DMEM,
	output logic MemWrite, MemRead
);

logic [3:0] opcode;

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