module rom (
    input logic [9:0] address,
    output logic [31:0] instruccion
);

logic [31:0] memoria[1023:0];

initial
	$readmemh("ROM.hex",memoria);

assign instruccion=memoria[address];
endmodule
