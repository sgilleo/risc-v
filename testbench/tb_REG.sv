`timescale 1ns/1ns

module tb_REG();

	logic CLK, RSTn, RegWrite;
	logic [4:0] read_reg1, read_reg2, write_reg;
	logic [31:0] write_data, read_data1, read_data2;
	
	logic [31:0] tb_read_data1, tb_read_data2;

	REG DUV(
		.clk(CLK),
		.rsta(RSTn),
		.read_reg1(read_reg1),
		.read_reg2(read_reg2),
		.write_reg(write_reg),
		.write_data(write_data),
		.read_data1(read_data1),
		.read_data2(read_data2),
		.RegWrite(RegWrite)
	);
	
	localparam T = 20;
	
	always #(T/2) CLK = ~ CLK;
	
	task reset;
		@(negedge CLK);
		RSTn = 1'b0;
		@(negedge CLK);
		RSTn = 1'b1;
		@(negedge CLK); //1 ciclo de espera
	endtask
	
	task lectura_puerto_1(input logic[4:0] tb_read_reg1, output logic[31:0] tb_read_data1);
		read_reg1 = tb_read_reg1;
		@(posedge CLK); //Esperamos al flanco positivo para muestrear
		tb_read_data1 = read_data1;
		@(negedge CLK);
		read_reg1 = 0;
		@(negedge CLK);
	endtask
	
	task lectura_puerto_2(input logic[4:0] tb_read_reg2, output logic[31:0] tb_read_data2);
		read_reg2 = tb_read_reg2;
		@(posedge CLK); //Esperamos al flanco positivo para muestrear
		tb_read_data2 = read_data2;
		@(negedge CLK);
		read_reg2 = 0;
		@(negedge CLK);
	endtask
	
	task escritura(input logic [4:0] tb_write_reg, input logic [31:0] tb_write_data);
		RegWrite = 1'b1;
		write_reg = tb_write_reg;
		write_data = tb_write_data;
		@(negedge CLK);
		RegWrite = 1'b0;
		write_reg = 5'd0;
		write_data = 32'd0;
		@(negedge CLK);
	endtask
	
	
	initial begin
	CLK = 1'b0;
	RSTn = 1'b1;
	read_reg1 = 5'd0;
	read_reg2 = 5'd0;
	write_reg = 5'd0;
	write_data = 32'b0;
	RegWrite = 1'b0;

	reset();
	
	escritura(1, 32'hFF);
	escritura(2, 32'hAA);
	lectura_puerto_1(1, tb_read_data1);
	assert(tb_read_data1 == 32'hFF) else $error("Error en lectura del puerto 1");
	lectura_puerto_2(2, tb_read_data2);
	assert(tb_read_data2 == 32'hAA) else $error("Error en lectura del puerto 2");
	$stop;
	
	end

endmodule