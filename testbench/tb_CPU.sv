`timescale 1ns/1ns

module tb_CPU();

    logic CLK, RSTn;

    RISCV DUV(
        .CLK(CLK),
        .RSTn(RSTn)
    );

    localparam T = 20;
	
	always
	begin
		#(T/2) CLK = ~CLK;
	end

    task reset;
		@(negedge CLK);
		RSTn = 1'b0;
		@(negedge CLK);
		RSTn = 1'b1;
		@(negedge CLK); //1 ciclo de espera
	endtask

    initial begin
        CLK = 1'b0;
        RSTn = 1'b1;

        reset();

        repeat(300) @(negedge CLK);
        
        $stop();

    end


endmodule