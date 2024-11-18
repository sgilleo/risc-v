module banco_registros (
	input logic [4:0] read_reg1,
	input logic [4:0] read_reg2,
	input logic [4:0] write_reg,
	input logic	[31:0] write_data,
	input logic clk, rsta,
	input logic RegWrite,
	output logic [31:0] read_data1,
	output logic [31:0] read_data2 
	);
	
logic [31:0] regs [31:0];
	
assign read_data1 = (read_reg1 == 5'b00000) ? 32'b0 : regs[read_reg1];
assign read_data2 = (read_reg2 == 5'b00000) ? 32'b0 : regs[read_reg2];

always_ff @(posedge clk, negedge rsta)
begin

	if(!rsta) regs <= '{32{'0}};
	else if (RegWrite && (write_reg != 5'b00000)) regs[write_reg] <= write_data;
		
end

endmodule

