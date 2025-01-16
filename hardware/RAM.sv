//Alejandro Bataller Sastre
module RAM #(parameter address_width = 1024)
(
input CLK, MemWrite, MemRead, //Memwrite senyal de habilitacion de escritura
input [31:0] write_data,
input[$clog2(address_width)-1:0] address, 
output [31:0] read_data,
output [31:0] out_data
);

logic [31:0] memoria [address_width-1:0];


always_ff @(posedge CLK)

	if (MemWrite)
			memoria[address] <= write_data;

assign read_data = (MemRead)? memoria[address]: 32'd0;
assign out_data = memoria [1023]; //Modificacion para la fase 4


endmodule 
/*
initial begin
 $readmemh("RAM.txt", memoria);
end
 Esto parece ir*/
