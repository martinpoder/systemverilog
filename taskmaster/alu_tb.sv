`timescale 1ns / 1ps

import cpu_pkg::*;

function automatic logic [3:0] set_flags(
    input logic c  = 0,
    input logic z  = 0,
    input logic ov = 0,
    input logic eq = 0
);
    logic [3:0] f = '0;
    f[FLAG_C]  = c;
    f[FLAG_Z]  = z;
    f[FLAG_OV] = ov;
    f[FLAG_EQ] = eq;
    return f;
endfunction

module alu_tb #(
    parameter int WIDTH = 8);

    logic [WIDTH - 1:0] a_tb;
    logic [WIDTH - 1:0] b_tb;
    logic [3:0] flags_in_tb;
    alu_op_t op_tb;
    logic [WIDTH - 1:0] result_tb;
    logic [3:0] flags_out_tb;
    logic [WIDTH:0] ex_sum_and_carry;
    logic [WIDTH:0] ex_sub_and_carry;

    // expected sum with carry added as MSB
    assign ex_sum_and_carry = {{1'b0, a_tb} + {1'b0, b_tb} + (WIDTH + 1)'(flags_in_tb[FLAG_C])};
    // A - B = A + ~B + 1; carry is 1 when subtraction did not borrow
    assign ex_sub_and_carry = {{1'b0, a_tb} + {1'b0, ~b_tb} + (WIDTH + 1)'(1'b1)};

    alu UUT(
        .a(a_tb), .b(b_tb), .flags_in(flags_in_tb), .op(op_tb),
        .result(result_tb), .flags_out(flags_out_tb)
    );

    string vcd_file;

    initial begin
        if (!$value$plusargs("VCD=%s", vcd_file))
            vcd_file = "simulation.vcd";

        $dumpfile(vcd_file);
        $dumpvars(0, alu_tb);

        flags_in_tb = set_flags(0, 0, 0, 0);
        $display("ADD TEST START");
        op_tb = ALU_ADD;
        for (int unsigned c = 0; c < 2; c++) begin
            for (int unsigned a = 0; a < 2 ** WIDTH; a++) begin
                for (int unsigned b = 0; b < 2 ** WIDTH; b++) begin
                    a_tb = a[WIDTH - 1:0];
                    b_tb = b[WIDTH - 1:0];
                    flags_in_tb[FLAG_C] = 1'(c);
                    #5;
                    assert ({flags_out_tb[FLAG_C], result_tb} == ex_sum_and_carry && 
                           (flags_out_tb[FLAG_Z] == (result_tb == '0)) &&
                           (flags_out_tb[FLAG_OV] == ((a_tb[WIDTH - 1] == b_tb[WIDTH - 1]) &&
									                 (result_tb[WIDTH - 1] != a_tb[WIDTH - 1]))))
                    //    $display("CI=%b %h+%h=%h CO=%b Z=%b OV=%b < Correct", flags_in_tb[FLAG_C], 
                    //    a_tb, b_tb, result_tb, flags_out_tb[FLAG_C], flags_out_tb[FLAG_Z], flags_out_tb[FLAG_OV]);
                    else $error("CI=%b %h+%h=%h CO=%b Z=%b OV=%b < Incorrect, must be %h CO=%b Z=%b OV=%b", 
                        flags_in_tb[FLAG_C], a_tb, b_tb, result_tb, flags_out_tb[FLAG_C], flags_out_tb[FLAG_Z], 
                        flags_out_tb[FLAG_OV], ex_sum_and_carry[WIDTH - 1:0], ex_sum_and_carry[WIDTH], result_tb == '0,
                        (a_tb[WIDTH - 1] == b_tb[WIDTH - 1]) && (result_tb[WIDTH - 1] != a_tb[WIDTH - 1]));
                end
            end
        end
        $display("ADD TEST FINISHED");

        $display("SUB TEST START");
        flags_in_tb = set_flags(1, 0, 0, 0);
        op_tb = ALU_SUB;
        for (int unsigned a = 0; a < 2 ** WIDTH; a++) begin
            for (int unsigned b = 0; b < 2 ** WIDTH; b++) begin
                a_tb = a[WIDTH - 1:0];
                b_tb = b[WIDTH - 1:0];
                #5;
                assert ({flags_out_tb[FLAG_C], result_tb} == ex_sub_and_carry &&
                        flags_out_tb[FLAG_Z] == (result_tb == '0) &&
                        flags_out_tb[FLAG_OV] == ((a_tb[WIDTH - 1] != b_tb[WIDTH - 1]) &&
                                                  (result_tb[WIDTH - 1] != a_tb[WIDTH - 1])) &&
                        flags_out_tb[FLAG_EQ] == (a_tb == b_tb))
                //    $display("CI=%b %h-%h=%h CO=%b Z=%b OV=%b < Correct", flags_in_tb[FLAG_C], 
                //    a_tb, b_tb, result_tb, flags_out_tb[FLAG_C], flags_out_tb[FLAG_Z], flags_out_tb[FLAG_OV]);
                    else $error("%h-%h=%h C=%b Z=%b OV=%b EQ=%b < Incorrect, expected %h C=%b Z=%b OV=%b EQ=%b",
                        a_tb, b_tb, result_tb, flags_out_tb[FLAG_C], flags_out_tb[FLAG_Z],
                        flags_out_tb[FLAG_OV], flags_out_tb[FLAG_EQ],
                        ex_sub_and_carry[WIDTH - 1:0], ex_sub_and_carry[WIDTH],
                        result_tb == '0,
                        (a_tb[WIDTH - 1] != b_tb[WIDTH - 1]) &&
                        (result_tb[WIDTH - 1] != a_tb[WIDTH - 1]), a_tb == b_tb);
            end
        end
        $display("SUB TEST FINISHED");

        $display("NON-ARITHMETIC TESTS START");
        // Non-arithmetic ALU operations
        a_tb = 8'h81;
        b_tb = 8'h01;
        flags_in_tb = set_flags(1, 0, 1, 1);

        op_tb = ALU_SHIFT_ARITH_R; #5;
        assert (result_tb == 8'hC0 && flags_out_tb == set_flags(1, 0, 1, 1))
            else $error("ASR: got %h flags=%b, expected C0 flags=1011", result_tb, flags_out_tb);

        op_tb = ALU_SHIFT_ARITH_L; #5;
        assert (result_tb == 8'h02 && flags_out_tb == set_flags(1, 0, 1, 1))
            else $error("ASL: got %h flags=%b, expected 02 flags=1011", result_tb, flags_out_tb);

        op_tb = ALU_SHIFT_A_R; #5;
        assert (result_tb == 8'h40 && flags_out_tb == set_flags(1, 0, 1, 1))
            else $error("LSR: got %h flags=%b, expected 40 flags=1011", result_tb, flags_out_tb);

        op_tb = ALU_SHIFT_A_L; #5;
        assert (result_tb == 8'h02 && flags_out_tb == set_flags(1, 0, 1, 1))
            else $error("LSL: got %h flags=%b, expected 02 flags=1011", result_tb, flags_out_tb);

        op_tb = ALU_RRC; #5;
        assert (result_tb == 8'hC0 && flags_out_tb == set_flags(1, 0, 1, 1))
            else $error("RRC: got %h flags=%b, expected C0 flags=1011", result_tb, flags_out_tb);

        op_tb = ALU_RLC; #5;
        assert (result_tb == 8'h03 && flags_out_tb == set_flags(1, 0, 1, 1))
            else $error("RLC: got %h flags=%b, expected 03 flags=1011", result_tb, flags_out_tb);

        a_tb = 8'hF0;
        b_tb = 8'h0F;
        op_tb = ALU_AND; #5;
        assert (result_tb == 8'h00 && flags_out_tb == set_flags(1, 1, 1, 1))
            else $error("AND: got %h flags=%b, expected 00 flags=1111", result_tb, flags_out_tb);

        op_tb = ALU_OR; #5;
        assert (result_tb == 8'hFF && flags_out_tb == set_flags(1, 0, 1, 1))
            else $error("OR: got %h flags=%b, expected FF flags=1011", result_tb, flags_out_tb);

        op_tb = ALU_XOR; #5;
        assert (result_tb == 8'hFF && flags_out_tb == set_flags(1, 0, 1, 1))
            else $error("XOR: got %h flags=%b, expected FF flags=1011", result_tb, flags_out_tb);

        op_tb = ALU_FLIP; #5;
        assert (result_tb == 8'h0F && flags_out_tb == set_flags(1, 0, 1, 1))
            else $error("FLIP: got %h flags=%b, expected 0F flags=1011", result_tb, flags_out_tb);

        a_tb = 8'h01;
        op_tb = ALU_NEG; #5;
        assert (result_tb == 8'hFF && flags_out_tb == set_flags(1, 0, 0, 1))
            else $error("NEG: got %h flags=%b, expected FF flags=1001", result_tb, flags_out_tb);

        // NEG overflow is set only for the most-negative signed value.
        a_tb = {1'b1, {(WIDTH-1){1'b0}}};
        op_tb = ALU_NEG; #5;
        assert (result_tb == a_tb && flags_out_tb == set_flags(1, 0, 1, 1))
            else $error("NEG minimum: got %h flags=%b, expected %h flags=1011", result_tb, flags_out_tb, a_tb);

        $display("NON-ARITHMETIC TESTS STOP");

        $stop;
    end

endmodule
