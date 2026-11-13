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
    alu_ops_t op_tb;
    logic [WIDTH - 1:0] result_tb;
    logic [3:0] flags_out_tb;
    logic [WIDTH:0] ex_sum_and_carry;

    // expected sum with carry added as MSB
    assign ex_sum_and_carry = {{1'b0, a_tb} + {1'b0, b_tb} + (WIDTH + 1)'(flags_in_tb[FLAG_C])};

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

        $stop;
    end

endmodule
