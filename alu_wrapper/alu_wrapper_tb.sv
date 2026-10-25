`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2026 05:50:34 PM
// Design Name: 
// Module Name: alu_wrapper_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_wrapper_tb();

localparam WIDTH = 4;

logic CLK100MHZ_tb;
logic rst_tb;
logic [WIDTH - 1:0] data_i_tb;
logic [2:0] op_sel_i_tb;
logic btnu_i_tb;		// calculate button
logic carry_in_tb;
logic [WIDTH - 1:0] accu_o_tb;
logic [1:0] flags_o_tb;
logic [WIDTH - 1:0] data_o_tb;

alu_wrapper ALUW(
    .CLK100MHZ(CLK100MHZ_tb), 
    .rst(rst_tb), 
    .data_i(data_i_tb),
    .op_sel_i(op_sel_i_tb),
    .btnu_i(btnu_i_tb),
    .carry_in(carry_in_tb),
    .accu_o(accu_o_tb),
    .flags_o(flags_o_tb),
    .data_o(data_o_tb));

always #5 CLK100MHZ_tb = ~CLK100MHZ_tb; // 5ns x 2 = 10 ns = 100 MHz

string vcd_file;

initial begin
    if (!$value$plusargs("VCD=%s", vcd_file))
        vcd_file = "simulation.vcd";

    $dumpfile(vcd_file);
    $dumpvars(0, alu_wrapper_tb);
    rst_tb = 1'b1;
	CLK100MHZ_tb = 1'b0;
	data_i_tb = 4'h7;
	op_sel_i_tb = 3'b000;  // ADD
	btnu_i_tb = 1'b0;
	carry_in_tb = 1'b0;

	#10
	rst_tb = 1'b0;

	assert (accu_o_tb + data_i_tb == data_o_tb) $display("%h+%h=%h < Correct", accu_o_tb, data_i_tb, data_o_tb);
	   else $error("%h+%h=%h < Error", accu_o_tb, data_i_tb, data_o_tb);

	btnu_i_tb = 1'b1;  #45000000;   btnu_i_tb = 1'b0;  // Press button for 45 ms

	assert (accu_o_tb + data_i_tb == data_o_tb) $display("%h+%h=%h < Correct", accu_o_tb, data_i_tb, data_o_tb);
	   else $error("%h+%h=%h < Error", accu_o_tb, data_i_tb, data_o_tb);

    data_i_tb = 4'h3;
    op_sel_i_tb = 3'b001;  // SUB
    btnu_i_tb = 1'b1;  #45000000;   btnu_i_tb = 1'b0;  // Press button for 45 ms
 
	assert (accu_o_tb - data_i_tb == data_o_tb) $display("%h-%h=%h < Correct", accu_o_tb, data_i_tb, data_o_tb);
	   else $error("%h-%h=%h < Error", accu_o_tb, data_i_tb, data_o_tb);

    $stop;
end

endmodule
