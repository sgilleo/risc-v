//Alejandro Bataller Sastre
module RAM #(parameter address_width = 1024, data_width = 32)
(
input CLK, MemWrite, //Memwrite senyal de habilitacion de escritura
input [data_width-1:0] write_data,
input[$clog2(address_width)-1:0] address, 
output [data_width-1:0] read_data
);

logic [data_width-1:0] memoria [address_width-1:0];


always_ff @(posedge CLK)

	if (MemWrite)
			memoria[address] <= write_data;

assign read_data = memoria[address];


endmodule 
/*
initial begin
 $readmemh("RAM.txt", memoria);
end
 Esto parece ir*/