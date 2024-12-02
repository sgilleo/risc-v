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

class LInst;
    rand logic [31:0] inst;
    constraint opcode {inst[6:0] == 7'b0000011;}
    constraint funct3 {inst[14:12] == 3'b010;}    
endclass

class SInst;
    rand logic [31:0] inst;
    constraint opcode {inst[6:0] == 7'b0100011;}
    constraint funct3 {inst[14:12] == 3'b010;}
endclass

class BInst;
    rand logic [31:0] inst;
    constraint opcode {inst[6:0] == 7'b1100011;}
    constraint funct3 {inst[14:12] == 3'b000;}
endclass

program Estimulos (CLK, RSTn, Instruction);

    input logic CLK, RSTn;
    output logic [31:0] Instruction;

    covergroup RCover;
        rs2: coverpoint Instruction[24:20];
        rs1: coverpoint Instruction[19:15];
        rd: coverpoint Instruction[11:7];
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
        rs1: coverpoint Instruction[19:15];
        rd: coverpoint Instruction[11:7];
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
        imm: coverpoint Instruction[31:20] {
            bins b_imm[] = {[-2048:2047]};
        }
        rs1: coverpoint Instruction[19:15];
        rd: coverpoint Instruction[11:7];
    endgroup

    covergroup SCover;
        imm: coverpoint {Instruction[31:25], Instruction[11:7]} {
            bins b_imm[] = {[-2048:2047]};
        }
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

    LInst linst;
    LCover lcov;

    SInst sinst;
    SCover scov;

    BInst binst;
    BCover bcov;

    task test_R;
        rinst.opcode.constraint_mode(1);
        rinst.funct7.constraint_mode(1);
        rinst.illegal_funct.constraint_mode(1);
        while(rcov.get_coverage() < 100) begin
            assert(rinst.randomize()) else $error("Error en randomizacion de instruccion tipo R");

            Instruction = rinst.inst;
            rcov.sample();

             @(posedge CLK);

            assert (Instruction[19:15] == duv.Instruction[19:15]) else $display("El registro de lectura 1 no es correcto");
            assert (Instruction[24:20] == duv.Instruction[24:20]) else $display("El registro de lectura 2 no es correcto");
            assert (Instruction[11:7] == duv.Instruction[11:7]) else $display("El registro de escritura no es correcto");
            assert (duv.Branch == 1'b0) else $display("Ha fallado la señal Branch de la unidad de control");
            assert (duv.MemRead == 1'b0) else $display("Ha fallado la señal MemRead de la unidad de control");
            assert (duv.MemtoReg == 1'b0) else $display("Ha fallado la señal MemtoReg de la unidad de control");
            assert (duv.ALUOp == 3'b000) else $display("Ha fallado la señal ALUOp de la unidad de control");
            assert (duv.MemWrite == 1'b0) else $display("Ha fallado la señal MemWrite de la unidad de control");
            assert (duv.ALUSrc == 1'b0) else $display("Ha fallado la señal ALUSrc de la unidad de control");
            assert (duv.RegWrite == 1'b1) else $display("Ha fallado la señal RegWrite de la unidad de control");
            assert (duv.AuipcLui == 2'd2) else $display("Ha fallado la señal AuipcLuide la unidad de control");
            
            case({Instruction[30], Instruction[14:12]})

                4'b0000: assert(duv.opcode == 4'b0000) else $display("El código de operación no ha coincidido");
                4'b1000: assert(duv.opcode == 4'b0001) else $display("El código de operación no ha coincidido");
                4'b0001: assert(duv.opcode == 4'b0010) else $display("El código de operación no ha coincidido");
                4'b0010: assert(duv.opcode == 4'b0011) else $display("El código de operación no ha coincidido");
                4'b0011: assert(duv.opcode == 4'b0100) else $display("El código de operación no ha coincidido");
                4'b0100: assert(duv.opcode == 4'b0110) else $display("El código de operación no ha coincidido");
                4'b0101: assert(duv.opcode == 4'b1000) else $display("El código de operación no ha coincidido");
                4'b1101: assert(duv.opcode == 4'b1001) else $display("El código de operación no ha coincidido");
                4'b0110: assert(duv.opcode == 4'b0101) else $display("El código de operación no ha coincidido");
                4'b0111: assert(duv.opcode == 4'b0100) else $display("El código de operación no ha coincidido");
                default: assert(duv.opcode == 4'd0);
            endcase

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

    task test_L;
        linst.opcode.constraint_mode(1);
        linst.funct3.constraint_mode(1);
        while(lcov.get_coverage() < 100) begin
            assert(linst.randomize()) else $error("Error en randomizacion de instruccion tipo L");

            Instruction = linst.inst;
            lcov.sample();

            @(negedge CLK);
        end
    endtask

    task test_S;
        sinst.opcode.constraint_mode(1);
        sinst.funct3.constraint_mode(1);
        while(scov.get_coverage() < 100) begin
            assert(sinst.randomize()) else $error("Error en randomizacion de instruccion tipo S");

            Instruction = sinst.inst;
            scov.sample();

            @(negedge CLK);
        end
    endtask

    task test_B;
        binst.opcode.constraint_mode(1);
        binst.funct3.constraint_mode(1);
        while(bcov.get_coverage() < 100) begin
            assert(binst.randomize()) else $error("Error en randomizacion de instruccion tipo B");

            Instruction = binst.inst;
            bcov.sample();

            @(negedge CLK);
        end
    endtask

    initial begin
        rinst = new();
        rcov = new();

        iinst = new();
        icov = new();

        linst = new();
        lcov = new();

        sinst = new();
        scov = new();        

        binst = new();
        bcov = new();

        repeat(3) @(negedge CLK);

        test_I; $display("Instrucciones tipo I comprobadas");

        Instruction = 31'd0;
        repeat(500) @(negedge CLK);

        test_R; $display("Instrucciones tipo R comprobadas");

        repeat(500) @(negedge CLK);

        test_L; $display("Instrucciones tipo L comprobadas");

        repeat(500) @(negedge CLK);

        test_S; $display("Instrucciones tipo S comprobadas");

        repeat(500) @(negedge CLK);

        test_B; $display("Instrucciones tipo B comprobadas");

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