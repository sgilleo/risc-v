`timescale 1ns/1ns

class RInst;
    rand logic [31:0] inst;
    constraint opcode {inst[6:0] == 7'b0110011;}
    constraint funct7 {inst[31] == 1'b0 && inst[29:25] == 5'b0;}
    constraint illegal_funct {
        {inst[30], inst[14:12]} != 9 &&
        {inst[30], inst[14:12]} != 10 && 
        {inst[30], inst[14:12]} != 11 && 
        {inst[30], inst[14:12]} != 12 && 
        {inst[30], inst[14:12]} != 14 && 
        {inst[30], inst[14:12]} != 15; 
    }
endclass

class IInst;
    rand logic [31:0] inst;
    constraint opcode {inst[6:0] == 7'b0010011;}
    constraint funct3 {inst[14:12] != 3;}
endclass

program Estimulos (CLK, RSTn, Instruction);

    input logic CLK, RSTn;
    output logic [31:0] Instruction;

    covergroup RCover;
        rs2: coverpoint Instruction[24:20] {
            bins b_rs2[] = {[0:31]};
        }
        rs1: coverpoint Instruction[19:15] {
            bins b_rs1[] = {[0:31]};
        }
        rd: coverpoint Instruction[11:7] {
            bins b_rd[] = {[0:31]};
        }
        operation: coverpoint ({Instruction[30], Instruction[14:12]}) 
        {
            bins b_add = {0};
            bins b_sub = {8};
            bins b_sll = {1};
            bins b_slt = {2};
            bins b_sltu = {3};
            bins b_xor = {4};
            bins b_srl = {5};
            bins b_sra = {13};
            bins b_or = {6};
            bins b_and = {7};
            illegal_bins imposible = {9, 10, 11, 12, 14, 15};
        } 
    endgroup

    covergroup ICover;
        imm: coverpoint Instruction[31:20] {
            bins b_imm[] = {[-2048:2047]};
        }
        rs1: coverpoint Instruction[19:15] {
            bins b_rs1[] = {[0:31]};
        }
        rd: coverpoint Instruction[11:7] {
            bins b_rd[] = {[0:31]};
        }
        operation: coverpoint Instruction[14:12] {
            bins b_addi = {3'b000};
            bins b_slti = {3'b010};
            bins b_xori = {3'b100};
            bins b_ori = {3'b110};
            bins b_andi = {3'b111};
            bins b_slli = {3'b001};
            bins b_srli = {3'b101};
            illegal_bins imposible = {3};
        }
    endgroup

    covergroup LCover;
        imm: coverpoint Instruction[31:20];
        rs1: coverpoint Instruction[19:15];
        rd: coverpoint Instruction[11:7];
    endgroup

    covergroup SCover;
        imm: coverpoint {Instruction[31:25], Instruction[11:7]};
        rs2: coverpoint Instruction[24:20];
        rs1: coverpoint Instruction[19:15];
    endgroup

    covergroup BCover;
        imm: coverpoint {Instruction[31], Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
        rs2: coverpoint Instruction[24:20];
        rs1: coverpoint Instruction[19:15];
    endgroup

    RInst rinst;
    RCover rcov;

    IInst iinst;
    ICover icov;

    task test_R;
        rinst.opcode.constraint_mode(1);
        rinst.funct7.constraint_mode(1);
        rinst.illegal_funct.constraint_mode(1);
        while(rcov.get_coverage() < 100) begin
            assert(rinst.randomize()) else $error("Error en randomizacion de instruccion tipo R");

            Instruction = rinst.inst;
            rcov.sample();

            @(negedge CLK);
        end
    endtask

    task test_I;
        iinst.opcode.constraint_mode(1);
        iinst.funct3.constraint_mode(1);
        while(icov.get_coverage() < 100) begin
            assert(iinst.randomize()) else $error("Error en randomizacion de instruccion tipo I");

            Instruction = iinst.inst;
            icov.sample();

            @(negedge CLK);
        end
    endtask

    initial begin
        rinst = new();
        rcov = new();

        iinst = new();
        icov = new();

        repeat(3) @(negedge CLK);

        test_I; $display("Instrucciones tipo I comprobadas");

        Instruction = 31'd0;
        repeat(500) @(negedge CLK);

        test_R; $display("Instrucciones tipo R comprobadas");

        $stop;
    end

endprogram


module tb_CPU_Core();
    logic CLK, RSTn, MemWrite, MemRead;
    logic [9:0] address_DMEM, address_IMEM;
    logic [31:0] Instruction, data_DMEM, write_data_DMEM;

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

    Estimulos estimulos(
        .CLK(CLK),
        .RSTn(RSTn),
        .Instruction(Instruction)
    );

    parameter T = 20;

    always #(T/2) CLK = ~ CLK;

    task reset;
        @(negedge CLK);
        RSTn = 1'b0;
        @(negedge CLK);
        RSTn = 1'b1;
        @(negedge CLK);
    endtask

    initial begin
        CLK = 1'b0;
        RSTn = 1'b1;
        data_DMEM = 32'd0;

        reset();
    end

endmodule