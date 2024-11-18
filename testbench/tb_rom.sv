`timescale 1ns/1ns

module tb_ROM; 
	logic CLK;
	logic [9:0] address;
	logic [31:0] instruccion;

	rom rom_inst(
	 .address(address),
	 .instruccion(instruccion)
	);
	
	parameter T = 20;
	
	always #(T/2) CLK = ~ CLK;	
	  
	initial begin
		CLK = 1'b0;
		@(negedge CLK); 
    
		for (int i = 0; i < 10; i++) begin
			address = i;
			@(negedge CLK);
			$display("Address: %0d, Instruction: %h", address, instruccion);
		end

    
    $display("ROM Testbench complete.");
    $stop;
  end

endmodule
