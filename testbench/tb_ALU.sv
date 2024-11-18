`timescale 1ns/1ns

module tb_ALU();

	logic CLK, zero;
	logic [31:0] op1, op2, res;
	logic [3:0] opcode;
	
	ALU DUV(
		.opcode(opcode),
		.op1(op1),
		.op2(op2),
		.res(res),
		.zero(zero)
	);
	
	localparam T = 20;
	
	always
	begin
		#(T/2) CLK = ~CLK;
	end
	
	task check_add(input logic [31:0] op1_test, op2_test);
		@(negedge CLK);
		opcode = 4'b0000;
		op1 = op1_test;
		op2 = op2_test;
		@(posedge CLK);
		assert (res == op1_test + op2_test) $display("ADD result OK"); else $error("Error en el resultado de ADD");
	endtask

	task check_sub(input logic [31:0] op1_test, op2_test);
		@(negedge CLK);
		opcode = 4'b0001;
		op1 = op1_test;
		op2 = op2_test;
		@(posedge CLK);
		assert (res == op1_test - op2_test) $display("SUB result OK"); else $error("Error en el resultado de SUB");
	endtask

	task check_slt(input logic signed [31:0] op1_test, op2_test);
		@(negedge CLK);
		opcode = 4'b0010;
		op1 = op1_test;
		op2 = op2_test;
		@(posedge CLK);
		assert (res == (op1_test < op2_test)) $display("SLT result OK"); else $error("Error en el resultado de SLT");
	endtask

	task check_sltu(input logic unsigned [31:0] op1_test, op2_test);
		@(negedge CLK);
		opcode = 4'b0011;
		op1 = op1_test;
		op2 = op2_test;
		@(posedge CLK);
		assert (res == (op1_test < op2_test)) $display("SLTU result OK"); else $error("Error en el resultado de SLTU");
	endtask

	task check_and(input logic [31:0] op1_test, op2_test);
		@(negedge CLK);
		opcode = 4'b0100;
		op1 = op1_test;
		op2 = op2_test;
		@(posedge CLK);
		assert (res == (op1_test & op2_test)) $display("AND result OK"); else $error("Error en el resultado de AND");
	endtask

	task check_or(input logic [31:0] op1_test, op2_test);
		@(negedge CLK);
		opcode = 4'b0101;
		op1 = op1_test;
		op2 = op2_test;
		@(posedge CLK);
		assert (res == (op1_test | op2_test)) $display("OR result OK"); else $error("Error en el resultado de OR");
	endtask

	task check_xor(input logic [31:0] op1_test, op2_test);
		@(negedge CLK);
		opcode = 4'b0110;
		op1 = op1_test;
		op2 = op2_test;
		@(posedge CLK);
		assert (res == (op1_test ^ op2_test)) $display("XOR result OK"); else $error("Error en el resultado de XOR");
	endtask
	
	task check_sll(input logic [31:0] op1_test, op2_test);
		@(negedge CLK);
		opcode = 4'b0111;
		op1 = op1_test;
		op2 = op2_test;
		@(posedge CLK);
		assert (res == (op1_test << op2_test)) $display("SLL result OK"); else $error("Error en el resultado de SLL");
	endtask

	task check_srl(input logic [31:0] op1_test, op2_test);
		@(negedge CLK);
		opcode = 4'b1000;
		op1 = op1_test;
		op2 = op2_test;
		@(posedge CLK);
		assert (res == (op1_test >> op2_test)) $display("SRL result OK"); else $error("Error en el resultado de SRL");
	endtask

	task check_sra(input logic [31:0] op1_test, op2_test);
		@(negedge CLK);
		opcode = 4'b1001;
		op1 = op1_test;
		op2 = op2_test;
		@(posedge CLK);
		assert (res == (op1_test >>> op2_test)) $display("SRA result OK"); else $error("Error en el resultado de SRA");
	endtask

	initial begin
		CLK = 1'b0;
		opcode = 4'd0;
		op1 = 32'd0;
		op2 = 32'd0;
		
		 @(negedge CLK);
		
		check_add($random, $random);
		check_sub($random, $random);
		check_slt($random, $random);
		check_sltu($random, $random);
		check_and($random, $random);
		check_or($random, $random);
		check_xor($random, $random);
		check_sll($random, ($random >> 28)); //Genera un numero aleatorio de 32 bits y desplazalo 28 veces a la derecha
		check_srl($random, ($random >> 28)); //para dejar los 4 bits de menor peso aleatorios y el resto a cero
		check_sra($random, ($random >> 28));
		
		$stop;
	end

	always @(posedge CLK) assert (zero == (res == 31'd0)) else $error("Error en el flag zero");
	
endmodule