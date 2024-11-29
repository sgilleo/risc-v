module ROM #(parameter address_width=1024) (
    input logic [($clog2(address_width)-1):0] address,
    output logic [31:0] instruction
);

logic [31:0] memoria[(address_width-1):0];

initial
	$readmemh("ROM.hex",memoria);

assign instruction=memoria[address];
endmodule
