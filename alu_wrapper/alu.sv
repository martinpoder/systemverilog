`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 08:00:22 PM
// Design Name: 
// Module Name: alu
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


module alu #(
    parameter int WIDTH = 4
)(
    input [WIDTH - 1:0] a,
    input [WIDTH - 1:0] b,
	input carry_in,
	input [2:0] op,
    output [WIDTH - 1:0] result,
	output [1:0] flags_out			// {adder carry out, subtractor reminder out}
    );

	logic [WIDTH - 1:0] add_r, sub_r, and_r, or_r, xor_r, inv_r, shl_r, shr_r;

	adder ADD(.a(a), .b(b), .carry_in(carry_in), .sum(add_r), .carry_out(flags_out[0]));
	subtractor SUB(.a(a), .b(b), .sum(sub_r), .reminder(flags_out[1]));
	assign and_r = a & b;
	assign or_r = a | b;
	assign xor_r = a ^ b;
	assign inv_r = ~a;			// invert a (b is not used)
	assign shl_r = a << b;		// shift a left by b
	assign shr_r = a >> b;		// shift a right by b

	// Dataflow style multiplexer
	assign result = 
		(op == 3'b000) ? add_r :
		(op == 3'b001) ? sub_r :
		(op == 3'b010) ? and_r :
		(op == 3'b011) ? or_r :
		(op == 3'b100) ? xor_r :
		(op == 3'b101) ? inv_r :
		(op == 3'b110) ? shl_r : shr_r;

endmodule
