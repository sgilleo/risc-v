module REG (
	input logic CLK, RSTn, RegWrite,
	input logic [4:0] read_reg1, read_reg2, write_reg,
	input logic	[31:0] write_data,
	output logic [31:0] read_data1, read_data2
	);
	
logic [31:0] regs [31:0];
	
assign read_data1 = (read_reg1 == 5'b00000) ? 32'b0 : regs[read_reg1];
assign read_data2 = (read_reg2 == 5'b00000) ? 32'b0 : regs[read_reg2];

always_ff @(posedge CLK, negedge RSTn)
begin

	if(!RSTn) regs <= '{32{'0}};
	else if (RegWrite && (write_reg != 5'b00000)) regs[write_reg] <= write_data;
		
end

endmodule

