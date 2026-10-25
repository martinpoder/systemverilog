`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 09:00:26 PM
// Design Name: 
// Module Name: alu_wrapper
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


module alu_wrapper #(
    parameter int WIDTH = 4
)(
	input logic CLK100MHZ,
	input logic rst,       // active high
    input logic [WIDTH - 1:0] data_i,
    input logic [2:0] op_sel_i,
	input logic btnu_i,		// calculate button
	input logic carry_in,
    output logic [WIDTH - 1:0] accu_o,
	output logic [1:0] flags_o,
	output logic [WIDTH - 1:0] data_o
    );

	alu ALU(.a(accu_o), .b(data_i), .carry_in(carry_in), .op(op_sel_i), .result(data_o), .flags_out(flags_o));

	// Delay counter
	localparam int MAX_COUNT = 1000000;					// 100MHz / 1M = 100Hz		
	localparam int CNT_WIDTH = $clog2(MAX_COUNT + 1);	// celing of log base 2
	logic local_pulse, CLK100HZ;
	logic [CNT_WIDTH - 1:0] count;

	always_ff @(posedge CLK100MHZ) begin : proc_pulse_100Hz
		if (count < MAX_COUNT - 1) begin
			count <= count + 1;
			local_pulse <= 1'b0;
		end else begin
			count <= 0;
			local_pulse <= 1'b1;
		end
	end

	assign CLK100HZ = local_pulse;


	// Button debouncer	
	logic [3:0] debouncer_reg;
	logic btnu;

	always_ff @(posedge CLK100HZ or posedge rst) begin : proc_debounce_reg
		if (rst)
			debouncer_reg <= 4'b0000;
		else if (local_pulse)
			debouncer_reg <= {debouncer_reg [2:0], btnu_i};
	end

	assign btnu = &debouncer_reg;	// 1 if all bits in debouncer_reg are 1


	// Debounced button edge detection
	logic btn_current, btn_prev, detection;

	always_ff @(posedge CLK100MHZ) begin : proc_btn_current
		btn_current <= btnu;
		btn_prev <= btn_current;
	end

	assign detection = btn_current & ~btn_prev;


	// Operand accumulator
	always_ff @(posedge CLK100MHZ or posedge rst) begin : proc_op_accumulator
		if (rst)
			accu_o <= 4'b0000;
		else if (detection)
			accu_o <= data_o;
	end

endmodule
