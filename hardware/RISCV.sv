module RISCV(input logic CLK, RSTn);

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

    CPU_Core cpu(
        .CLK(CLK), 
        .RSTn(RSTn),
        .Instruction(Instruction),
        .data_DMEM(),
        .address_IMEM(address_IMEM),
        .address_DMEM(address_DMEM),
        .write_data_DMEM(write_data_DMEM),
        .MemWrite(MemWrite),
        .MemRead(MemRead)
    );

endmodule