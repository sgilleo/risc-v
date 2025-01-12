`timescale 1ns/1ns

module tb_Sorting_Pipelined();

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

    ROM #(.file("D:\\UNIVERSIDAD\\3TELECO\\ISDIGI\\risc-v\\assembly\\sorting_segmentado.hex")) rom(
        .address(address_IMEM),
        .instruction(Instruction)
    );

    CPU_Core_Pipelined DUV(
        .CLK(CLK), 
        .RSTn(RSTn),
        .idata(Instruction),
        .ddata_r(data_DMEM),
        .iaddr(address_IMEM),
        .daddr(address_DMEM),
        .ddata_w(write_data_DMEM),
        .d_w(MemWrite),
        .d_r(MemRead)
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

        wait(Instruction == 32'd0);
        
        $stop();

    end


endmodule