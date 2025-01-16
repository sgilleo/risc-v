module TinuC(CLK,RSTn,seg0, seg1, seg2, seg3, seg4);

input logic CLK,RSTn;

logic d_w,d_r;
logic [9:0] daddr,iaddr;
logic [31:0] ddata_w,ddata_r,idata,digit_data;

output logic [6:0] seg0, seg1, seg2, seg3, seg4;

CPU_Core CPU_Core_inst
(
	.CLK(CLK) ,	// input  CLK_sig
	.RSTn(RSTn) ,	// input  RSTn_sig
	.idata(idata) ,	// input [31:0] idata_sig
	.ddata_r(ddata_r) ,	// input [31:0] ddata_r_sig
	.iaddr(iaddr) ,	// output [9:0] iaddr_sig
	.daddr(daddr) ,	// output [9:0] daddr_sig
	.ddata_w(ddata_w) ,	// output [31:0] ddata_w_sig
	.d_w(d_w) ,	// output  d_w_sig
	.d_r(d_r) 	// output  d_r_sig
);

GPIO GPIO_inst
(
	.data_in(digit_data) ,	// input [31:0] data_in_sig
	.seg0(seg0) ,	// output [6:0] seg0_sig
	.seg1(seg1) ,	// output [6:0] seg1_sig
	.seg2(seg2) ,	// output [6:0] seg2_sig
	.seg3(seg3) ,	// output [6:0] seg3_sig
	.seg4(seg4) 	// output [6:0] seg4_sig
);

RAM RAM_inst
(
	.CLK(CLK) ,	// input  CLK_sig
	.MemWrite(d_w) ,	// input  MemWrite_sig
	.MemRead(d_r) ,	// input  MemRead_sig
	.write_data(ddata_w) ,	// input [31:0] write_data_sig
	.address(daddr) ,
	.read_data(ddata_r) ,	// output [31:0] read_data_sig
	.out_data(digit_data) 	// output [31:0] out_data_sig
);


ROM #(.file("../assembly/fibonacci_TinuC.hex")) ROM_inst //Abrir desde Quartus
(
	.address(iaddr) ,	// input [9:0] address_sig
	.instruction(idata) 	// output [31:0] instruction_sig
);

endmodule
