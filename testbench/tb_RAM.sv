`timescale 1ns/1ns

module tb_RAM();

	logic CLK, MemWrite, MemRead;
	logic [31:0] write_data, read_data;
	logic [9:0] address;
	
	logic [9:0] test_address;
	logic [31:0] test_read_data, test_write_data;
	
	RAM DUV(
		.CLK(CLK),
		.MemWrite(MemWrite),
		.MemRead(MemRead),
		.write_data(write_data),
		.address(address),
		.read_data(read_data)
	);
	
	localparam T = 20;
	
	always #(T/2) CLK = ~ CLK;
	
	task write(input logic [9:0] tb_address, input logic [31:0] tb_data);
		write_data = tb_data;
		address = tb_address;
		MemWrite = 1'b1;
		@(negedge CLK);
		write_data = 32'd0;
		address = 10'd0;
		MemWrite = 1'b0;
		@(negedge CLK);
	endtask
	
	task read(input logic [9:0] tb_address, output logic [31:0] tb_data);
		address = tb_address;
		MemRead = 1'b1;
		@(posedge CLK);
		tb_data = read_data;
		@(negedge CLK);
		address = 10'd0;
		MemRead = 1'b0;
		@(negedge CLK);
	endtask
	
	initial begin
		CLK = 1'b0;
		MemWrite = 1'b0;
		MemRead = 1'b0;
		write_data = 32'd0;
		address = 10'd0;
		
		@(negedge CLK);
		
		repeat(3) begin
			test_address = $random;
			test_write_data = $random;
			write(test_address, test_write_data);
			read(test_address, test_read_data);
			assert (test_read_data == test_write_data) $display("Escritura y Lectura Correcta"); else $error("Error en la lectura de la RAM");
		end

		
		$stop;
	end



endmodule