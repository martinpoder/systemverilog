`timescale 1ns / 1ps

import cpu_pkg::*;

module alu #(
    parameter int WIDTH = 8
)(
    input logic [WIDTH - 1:0] a,
    input logic [WIDTH - 1:0] b,
	input flag_t flags_in,
	input alu_ops_t op,
    output logic [WIDTH - 1:0] result,
	output flag_t flags_out
    );

	logic [WIDTH - 1:0] add_r, sub_r, and_r, or_r, xor_r, inv_r, 
		shl_r, shr_r, ashl_r, ashr_r, rrc_r, rlc_r, neg_r;
	logic add_carry_out, sub_carry_out;

	ripple_carry_adder #(.n(WIDTH)) RCA1(.a(a), .b(b), .carry_in(flags_in[FLAG_C]), 
		.sum_out(add_r), .carry_out(add_carry_out));
	ripple_carry_adder #(.n(WIDTH)) RCA2(.a(a), .b(~b), .carry_in(1'b1), 
		.sum_out(sub_r), .carry_out(sub_carry_out));
	assign and_r = a & b;
	assign or_r = a | b;
	assign xor_r = a ^ b;
	assign inv_r = ~a;			// invert a
	assign shl_r = a << b;		// shift a left by b
	assign shr_r = a >> b;		// shift a right by b
	assign ashl_r = a <<< b;			// arithmetic shift a left by b
	assign ashr_r = $unsigned($signed(a) >>> b);		// arithmetic shift a right by b
	assign rrc_r = {flags_in[FLAG_C], a[WIDTH - 1:1]};	// rotate right through carry
	assign rlc_r = {a[WIDTH-2:0], flags_in[FLAG_C]};	// rotate left through carry
	assign neg_r = -a;

	always_comb begin
		flags_out = flags_in; 	// keep flags by default

		case (op)
			ALU_ADD: begin
				result = add_r;
				flags_out[FLAG_C]  = add_carry_out;
				flags_out[FLAG_OV] = (a[WIDTH - 1] == b[WIDTH - 1]) &&
									 (result[WIDTH - 1] != a[WIDTH - 1]);
			end
			ALU_SUB: begin
				result = sub_r;
				flags_out[FLAG_C]  = sub_carry_out; // 1 = no borrow
				flags_out[FLAG_OV] = (a[WIDTH - 1] != b[WIDTH - 1]) &&
									 (result[WIDTH - 1] != a[WIDTH - 1]);
				flags_out[FLAG_EQ] = (a == b);
			end
			ALU_SHIFT_ARITH_R: begin
				result = ashr_r;
			end
			ALU_SHIFT_ARITH_L: begin
				result = ashl_r;
			end
			ALU_SHIFT_A_R: begin
				result = shr_r;
			end
			ALU_SHIFT_A_L: begin
				result = shl_r;
			end
			ALU_RRC: begin
				result = rrc_r;
				flags_out[FLAG_C] = a[0];
			end
			ALU_RLC: begin
				result = rlc_r;
				flags_out[FLAG_C] = a[WIDTH - 1];
			end
			ALU_AND: begin
				result = and_r;
			end
			ALU_OR: begin
				result = or_r;
			end
			ALU_XOR: begin
				result = xor_r;
			end
			ALU_FLIP: begin
				result = inv_r;
			end
			ALU_NEG: begin
				result = neg_r;
				flags_out[FLAG_OV] = (a == {1'b1, {(WIDTH - 1){1'b0}}});
			end
			default: begin
				result = a;
			end
		endcase

		flags_out[FLAG_Z] = (result == '0);
	end

endmodule
