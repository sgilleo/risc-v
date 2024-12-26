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
    constraint funct3 {inst[14:12] == 3'b000 || inst[14:12] == 3'b101;}
endclass

class UInst;
    rand logic [31:0] inst;
    constraint opcode {inst[6:0] == 7'b0110111 || inst[6:0] == 7'b0010111;}
endclass

class JALInst;
    rand logic [31:0] inst;
    constraint opcode {inst[6:0] == 7'b1101111;}
endclass

class JALRInst;
    rand logic [31:0] inst;
    constraint opcode {inst[6:0] == 7'b1100111;}
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
        imm: coverpoint Instruction[31:20];
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

    covergroup UCover;
        imm: coverpoint {Instruction[31:12], 12'd0};
        rd: coverpoint Instruction[11:7];
    endgroup

    covergroup JALCover;
        imm: coverpoint {Instruction[31], 11'd0, Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0} {
            bins b_imm[2] = {[0:$]};
        }
        rd: coverpoint Instruction[11:7];
    endgroup

    covergroup JALRCover;
        imm: coverpoint {Instruction[31], 20'd0, Instruction[30:20]} {
            bins b_imm[2] = {[0:$]};
        }
        rs1: coverpoint Instruction[19:15];
        rd: coverpoint Instruction[11:7];
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

    UInst uinst;
    UCover ucov;

    JALInst jalinst;
    JALCover jalcov;

    JALRInst jalrinst;
    JALRCover jalrcov;

    task test_R;
        rinst.opcode.constraint_mode(1);
        rinst.funct7.constraint_mode(1);
        rinst.illegal_funct.constraint_mode(1);
        while(rcov.get_coverage() < 100) begin
            assert(rinst.randomize()) else $error("Error en randomizacion de instruccion tipo R");

            Instruction = rinst.inst;
            rcov.sample();

            @(posedge CLK);

            assert (Instruction[19:15] == DUV.idata[19:15]) else $display("El registro de lectura 1 no es correcto");
            assert (Instruction[24:20] == DUV.idata[24:20]) else $display("El registro de lectura 2 no es correcto");
            assert (Instruction[11:7] == DUV.idata[11:7]) else $display("El registro de escritura no es correcto");
            assert (DUV.Branch == 1'b0) else $display("Ha fallado la señal Branch de la unidad de control");
            assert (DUV.d_r == 1'b0) else $display("Ha fallado la señal d_r de la unidad de control");
            assert (DUV.MemtoReg == 2'd0) else $display("Ha fallado la señal MemtoReg de la unidad de control");
            assert (DUV.ALUOp == 3'b000) else $display("Ha fallado la señal ALUOp de la unidad de control");
            assert (DUV.ALUToPC == 1'b0) else  $display("Ha fallado la señal ALUToPC de la unidad de control");
            assert (DUV.d_w == 1'b0) else $display("Ha fallado la señal MemWrite de la unidad de control");
            assert (DUV.ALUSrc == 1'b0) else $display("Ha fallado la señal ALUSrc de la unidad de control");
            assert (DUV.RegWrite == 1'b1) else $display("Ha fallado la señal RegWrite de la unidad de control");
            assert (DUV.AuipcLui == 2'd2) else $display("Ha fallado la señal AuipcLui de la unidad de control");
            
            case({Instruction[30], Instruction[14:12]})

                4'b0000: assert(DUV.opcode == 4'b0000) else $display("El codigo de operacion no ha coincidido");
                4'b1000: assert(DUV.opcode == 4'b0001) else $display("El codigo de operacion no ha coincidido");
                4'b0001: assert(DUV.opcode == 4'b0010) else $display("El codigo de operacion no ha coincidido");
                4'b0010: assert(DUV.opcode == 4'b0011) else $display("El codigo de operacion no ha coincidido");
                4'b0011: assert(DUV.opcode == 4'b0100) else $display("El codigo de operacion no ha coincidido");
                4'b0100: assert(DUV.opcode == 4'b0110) else $display("El codigo de operacion no ha coincidido");
                4'b0101: assert(DUV.opcode == 4'b1000) else $display("El codigo de operacion no ha coincidido");
                4'b1101: assert(DUV.opcode == 4'b1001) else $display("El codigo de operacion no ha coincidido");
                4'b0110: assert(DUV.opcode == 4'b0101) else $display("El codigo de operacion no ha coincidido");
                4'b0111: assert(DUV.opcode == 4'b0100) else $display("El codigo de operacion no ha coincidido");
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

            @(posedge CLK);

            assert (Instruction[19:15] == DUV.idata[19:15]) else $display("El registro de lectura 1 no es correcto");
            assert ({Instruction[31], 20'd0, Instruction[30:20]} == DUV.Imm_gen) else $display("Ha fallado el generador de inmediatos");
            assert (Instruction[11:7] == DUV.idata[11:7]) else $display("El registro de escritura no es correcto");
            assert (DUV.Branch == 1'b0) else $display("Ha fallado la señal Branch de la unidad de control");
            assert (DUV.ALUToPC == 1'b0) else $display("Ha fallado la señal ALUToPC de la unidad de control");
            assert (DUV.d_r == 1'b0) else $display("Ha fallado la señal d_r de la unidad de control");
            assert (DUV.MemtoReg == 2'd0) else $display("Ha fallado la señal MemtoReg de la unidad de control");
            assert (DUV.ALUOp == 3'b001) else $display("Ha fallado la señal ALUOp de la unidad de control");
            assert (DUV.d_w == 1'b0) else $display("Ha fallado la señal MemWrite de la unidad de control");
            assert (DUV.ALUSrc == 1'b1) else $display("Ha fallado la señal ALUSrc de la unidad de control");
            assert (DUV.RegWrite == 1'b1) else $display("Ha fallado la señal RegWrite de la unidad de control");
            assert (DUV.AuipcLui == 2'd2) else $display("Ha fallado la señal AuipcLui de la unidad de control");

            case(Instruction[14:12])

                3'b000: assert(DUV.opcode == 4'b0000) else $display("El codigo de operacion no ha coincidido");
                3'b010: assert(DUV.opcode == 4'b0010) else $display("El codigo de operacion no ha coincidido");
                3'b100: assert(DUV.opcode == 4'b0110) else $display("El codigo de operacion no ha coincidido");
                3'b110: assert(DUV.opcode == 4'b0101) else $display("El codigo de operacion no ha coincidido");
                3'b111: assert(DUV.opcode == 4'b0100) else $display("El codigo de operacion no ha coincidido");
                3'b001: assert(DUV.opcode == 4'b0111) else $display("El codigo de operacion no ha coincidido");
            endcase

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

            @(posedge CLK);
            
            assert ({Instruction[31], 20'd0, Instruction[30:20]} == DUV.Imm_gen) else $display("Ha fallado el generador de inmediatos");
            assert (Instruction[19:15] == DUV.idata[19:15]) else $display("El registro de lectura 1 no es correcto");
            assert (Instruction[11:7] == DUV.idata[11:7]) else $display("El registro de escritura no es correcto");
            assert (DUV.Branch == 1'b0) else $display("Ha fallado la señal Branch de la unidad de control");
            assert (DUV.d_r == 1'b1) else $display("Ha fallado la señal d_r de la unidad de control");
            assert (DUV.MemtoReg == 2'd1) else $display("Ha fallado la señal MemtoReg de la unidad de control");
            assert (DUV.ALUOp == 3'b010) else $display("Ha fallado la señal ALUOp de la unidad de control");
            assert (DUV.ALUToPC == 1'b0) else $display("Ha fallado la señal ALUToPC de la unidad de control");
            assert (DUV.d_w == 1'b0) else $display("Ha fallado la señal d_w de la unidad de control");
            assert (DUV.ALUSrc == 1'b1) else $display("Ha fallado la señal ALUSrc de la unidad de control");
            assert (DUV.RegWrite == 1'b1) else $display("Ha fallado la señal RegWrite de la unidad de control");
            assert (DUV.AuipcLui == 2'd2) else $display("Ha fallado la señal AuipcLui de la unidad de control");
            assert (DUV.opcode == 4'b0000) else $display("El codigo de operacion no ha coincidido");
            assert (DUV.daddr == {DUV.Imm_gen + DUV.read_data1}[11:2]) else $display("La direccion de acceso a memoria en la lectura es incorrecta");

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

            @(posedge CLK);

            assert ({Instruction[31], 20'd0 , Instruction[30:25], Instruction[11:7]} == DUV.Imm_gen) else $display("Ha fallado el generador de inmediatos");
            assert (Instruction[19:15] == DUV.idata[19:15]) else $display("El registro de lectura 1 no es correcto");
            assert (Instruction[24:20] == DUV.idata[24:20]) else $display("El registro de lectura 2 no es correcto");
            assert (DUV.Branch == 1'b0) else $display("Ha fallado la señal Branch de la unidad de control");
            assert (DUV.d_r == 1'b0) else $display("Ha fallado la señal d_r de la unidad de control");
            assert (DUV.MemtoReg == 2'd0) else $display("Ha fallado la señal MemtoReg de la unidad de control");
            assert (DUV.ALUOp == 3'b010) else $display("Ha fallado la señal ALUOp de la unidad de control");
            assert (DUV.ALUToPC == 1'b0) else $display("Ha fallado la señal ALUToPC de la unidad de control");
            assert (DUV.d_w == 1'b1) else $display("Ha fallado la señal d_w de la unidad de control");
            assert (DUV.ALUSrc == 1'b1) else $display("Ha fallado la señal ALUSrc de la unidad de control");
            assert (DUV.RegWrite == 1'b0) else $display("Ha fallado la señal RegWrite de la unidad de control");
            assert (DUV.AuipcLui == 2'd2) else $display("Ha fallado la señal AuipcLui de la unidad de control");
            assert (DUV.opcode == 4'b0000) else $display("El codigo de operacion no ha coincidido");
            assert (DUV.daddr == {DUV.Imm_gen + DUV.read_data1}[11:2]) else $display("La direccion de acceso a memoria en la lectura es incorrecta");

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

            @(posedge CLK);

            assert ({Instruction[31], 19'd0, Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0} == DUV.Imm_gen) else $display("Ha fallado el generador de inmediatos");
            assert (Instruction[19:15] == DUV.idata[19:15]) else $display("El registro de lectura 1 no es correcto");
            assert (Instruction[24:20] == DUV.idata[24:20]) else $display("El registro de lectura 2 no es correcto");
            assert (DUV.Branch == 1'b1) else $display("Ha fallado la señal Branch de la unidad de control");
            assert (DUV.d_r == 1'b0) else $display("Ha fallado la señal d_r de la unidad de control");
            assert (DUV.MemtoReg == 2'd0) else $display("Ha fallado la señal MemtoReg de la unidad de control");
            assert (DUV.ALUOp == 3'b100) else $display("Ha fallado la señal ALUOp de la unidad de control");
            assert (DUV.ALUToPC == 1'b0) else $display("Ha fallado la señal ALUToPC de la unidad de control");
            assert (DUV.d_w == 1'b0) else $display("Ha fallado la señal d_w de la unidad de control");
            assert (DUV.ALUSrc == 1'b0) else $display("Ha fallado la señal ALUSrc de la unidad de control");
            assert (DUV.RegWrite == 1'b0) else $display("Ha fallado la señal RegWrite de la unidad de control");
            assert (DUV.AuipcLui == 2'd2) else $display("Ha fallado la señal AuipcLui de la unidad de control");

            case(Instruction[14:12])
                3'b000: assert (DUV.opcode == 4'b0001) else $display("El codigo de operacion no ha coincidido");
                3'b101: assert (DUV.opcode == 4'b0011) else $display("El codigo de operacion no ha coincidido");
            endcase

            @(negedge CLK);
        end
    endtask

    task test_U;
        uinst.opcode.constraint_mode(1);
        while(ucov.get_coverage() < 100) begin
            assert(uinst.randomize()) else $error("Error en randomizacion de instruccion tipo U");

            Instruction = uinst.inst;
            ucov.sample();

            @(posedge CLK);

            assert ({Instruction[31:12], 12'd0} == DUV.Imm_gen) else $display("Ha fallado el generador de inmediatos");
            assert (Instruction[11:7] == DUV.idata[11:7]) else $display("El registro de escritura no es correcto");
            assert (DUV.Branch == 1'b0) else $display("Ha fallado la señal Branch de la unidad de control");
            assert (DUV.d_r == 1'b0) else $display("Ha fallado la señal d_r de la unidad de control");
            assert (DUV.MemtoReg == 2'd0) else $display("Ha fallado la señal MemtoReg de la unidad de control");
            assert (DUV.ALUOp == 3'b010) else $display("Ha fallado la señal ALUOp de la unidad de control");
            assert (DUV.ALUToPC == 1'b0) else $display("Ha fallado la señal ALUToPC de la unidad de control");
            assert (DUV.d_w == 1'b0) else $display("Ha fallado la señal d_w de la unidad de control");
            assert (DUV.ALUSrc == 1'b1) else $display("Ha fallado la señal ALUSrc de la unidad de control");
            assert (DUV.RegWrite == 1'b1) else $display("Ha fallado la señal RegWrite de la unidad de control");
            assert (DUV.opcode == 4'b0000) else $display("El codigo de operacion no ha coincidido");

            case(Instruction[6:0])
                7'b0010111: assert (DUV.AuipcLui == 2'd0) else $display("Ha fallado la señal AuipcLui de la unidad de control");
                7'b0110111: assert (DUV.AuipcLui == 2'd1) else $display("Ha fallado la señal AuipcLui de la unidad de control");
            endcase

            @(negedge CLK);
        end
    endtask

    task test_JAL;
        jalinst.opcode.constraint_mode(1);
        while(jalcov.get_coverage() < 100) begin
            assert(jalinst.randomize()) else $error("Error en randomizacion de instruccion tipo JAL");

            Instruction = jalinst.inst;
            jalcov.sample();

            @(posedge CLK);

            assert ({Instruction[31], 11'd0, Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0} == DUV.Imm_gen) else $display("Ha fallado el generador de inmediatos");
            assert (Instruction[11:7] == DUV.idata[11:7]) else $display("El registro de escritura no es correcto");
            assert (DUV.Branch == 1'b1) else $display("Ha fallado la señal Branch de la unidad de control");
            assert (DUV.d_r == 1'b0) else $display("Ha fallado la señal d_r de la unidad de control");
            assert (DUV.MemtoReg == 2'd2) else $display("Ha fallado la señal MemtoReg de la unidad de control");
            assert (DUV.ALUOp == 3'b101) else $display("Ha fallado la señal ALUOp de la unidad de control");
            assert (DUV.ALUToPC == 1'b0) else $display("Ha fallado la señal ALUToPC de la unidad de control");
            assert (DUV.d_w == 1'b0) else $display("Ha fallado la señal d_w de la unidad de control");
            assert (DUV.ALUSrc == 1'b0) else $display("Ha fallado la señal ALUSrc de la unidad de control");
            assert (DUV.RegWrite == 1'b1) else $display("Ha fallado la señal RegWrite de la unidad de control");
            assert (DUV.opcode == 4'b0100) else $display("El codigo de operacion no ha coincidido");
            assert (DUV.AuipcLui == 2'd1) else $display("Ha fallado la señal AuipcLui de la unidad de control");
            assert (DUV.write_data == DUV.PC + 32'd4) else $display("No se ha guardado el valor correcto en la instruccion JAL");

            @(negedge CLK);
        end
    endtask

    task test_JALR;
    jalrinst.opcode.constraint_mode(1);
    jalrinst.funct3.constraint_mode(1);
    while(jalrcov.get_coverage() < 100) begin
        assert(jalrinst.randomize()) else $error("Error en randomizacion de instruccion tipo JALR");

        Instruction = jalrinst.inst;
        jalrcov.sample();

        @(posedge CLK);

        assert({Instruction[31], 20'd0, Instruction[30:20]} == DUV.Imm_gen) else $display("Ha fallado el generador de inmediatos");
        assert (Instruction[19:15] == DUV.idata[19:15]) else $display("El registro de lectura 1 no es correcto");
        assert (Instruction[11:7] == DUV.idata[11:7]) else $display("El registro de escritura no es correcto");
        assert (DUV.Branch == 1'b1) else $display("Ha fallado la señal Branch de la unidad de control");
        assert (DUV.d_r == 1'b0) else $display("Ha fallado la señal d_r de la unidad de control");
        assert (DUV.MemtoReg == 2'd2) else $display("Ha fallado la señal MemtoReg de la unidad de control");
        assert (DUV.ALUOp == 3'b010) else $display("Ha fallado la señal ALUOp de la unidad de control");
        assert (DUV.ALUToPC == 1'b1) else $display("Ha fallado la señal ALUToPC de la unidad de control");
        assert (DUV.d_w == 1'b0) else $display("Ha fallado la señal d_w de la unidad de control");
        assert (DUV.ALUSrc == 1'b1) else $display("Ha fallado la señal ALUSrc de la unidad de control");
        assert (DUV.RegWrite == 1'b1) else $display("Ha fallado la señal RegWrite de la unidad de control");
        assert (DUV.opcode == 4'b0000) else $display("El codigo de operacion no ha coincidido");
        assert (DUV.AuipcLui == 2'd2) else $display("Ha fallado la señal AuipcLui de la unidad de control");
        assert (DUV.write_data == DUV.PC + 32'd4) else $display("No se ha guardado el valor correcto en la instruccion JALR");

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

        uinst = new();
        ucov = new();

        jalinst = new();
        jalcov = new();

        jalrinst = new();
        jalrcov = new();

        repeat(3) @(negedge CLK);

        test_I; $display("Instrucciones tipo I comprobadas");

        test_R; $display("Instrucciones tipo R comprobadas");

        test_L; $display("Instrucciones tipo L comprobadas");

        test_S; $display("Instrucciones tipo S comprobadas");

        test_B; $display("Instrucciones tipo B comprobadas");

        test_U; $display("Instrucciones tipo U comprobadas");

        test_JAL; $display("Instruccion JAL comprobada");

        test_JALR; $display("Instruccion JALR comprobada");

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
        .idata(Instruction),
        .ddata_r(data_DMEM),
        .iaddr(address_IMEM),
        .daddr(address_DMEM),
        .ddata_w(write_data_DMEM),
        .d_w(MemWrite),
        .d_r(MemRead)
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