`timescale 1ns/1ns

module tb_CPU();

    logic CLK, RSTn;

    logic MemWrite, MemRead;
    logic [9:0] address_DMEM, address_IMEM;
    logic [31:0] Instruction, data_DMEM, write_data_DMEM;

    RAM ram(
        .CLK(CLK),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .write_data(write_data_DMEM),
        .address(address_DMEM),
        .read_data(data_DMEM)
    );

    ROM rom(
        .address(address_IMEM),
        .instruction(Instruction)
    );

    CPU_Core DUV(
        .CLK(CLK), 
        .RSTn(RSTn),
        .Instruction(Instruction),
        .data_DMEM(data_DMEM),
        .address_IMEM(address_IMEM),
        .address_DMEM(address_DMEM),
        .write_data_DMEM(write_data_DMEM),
        .MemWrite(MemWrite),
        .MemRead(MemRead)
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

        repeat(3000) @(negedge CLK);
        
        $stop();

    end


endmodule