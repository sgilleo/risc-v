/*

		ALU - Lucas Broch Monfort Grupo 3 PARS1
	--------------------------------------------

    ADD:  suma
    SUB:  resta
    SLT:  set flag zero if Less Than
    SLTU: Set flag zero if Less Than (unsigned)
    AND:  AND
    OR:   OR
    XOR:  XOR
    SLL:  Desplazamiento a la izquierda
    SRL:  Desplazamiento a la derecha
    SRA:  Desplazamiento a la derecha con signo
	 
	 Los códigos de operacion son los mismos
	 independientemente de si se opera con registros
	 o con valores inmediatos. La operación es idéntica.
*/

module ALU(opcode, op1, op2, res, zero);

  input logic[3:0] opcode;
  input logic[31:0] op1, op2;
  output logic[31:0] res;
  output bit zero;

  always_comb begin
    case(opcode)
      /*ADD */ 4'b0000: res = op1 + op2;
		
      /*SUB */ 4'b0001: res = op1 - op2;
		
      /*SLT */ 4'b0010: res = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0;
		
      /*SLTU*/ 4'b0011: res = ($unsigned(op1) < $unsigned(op2)) ? 32'b1 : 32'b0;
		
      /*AND */ 4'b0100: res = op1 & op2;
		
      /*OR  */ 4'b0101: res = op1 | op2;
		
      /*XOR */ 4'b0110: res = op1 ^ op2;
		
      /*SLL */ 4'b0111: res = op1 << op2[4:0]; // Se coloca el "[4:0]" porque solo se podrá desplazar 32 posiciones como máximo
		
      /*SRL */ 4'b1000: res = op1 >> op2[4:0];
		
      /*SRA */ 4'b1001: res = op1 >>> op2[4:0]; // Desplaza a la derecha y pero rellena los huecos con el MSB para mantener el signo
		
      default: res = 32'b0; // Resultado predeterminado por si hubiese un opcode ilegal
		
    endcase
	 
    zero = (res == 32'b0) ? 1'b1 : 1'b0; //Flag zero
	 
  end
  
endmodule
