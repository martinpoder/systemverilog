`timescale 1ns / 1ps

module full_adder(
    input a,
    input b,
    input carry_in,
    output sum,
    output carry_out
    );

    logic sum1, carry1, carry2;

    assign sum1 = a ^ b;
    assign carry1 = a & b;
    assign sum = sum1 ^ carry_in;
    assign carry2 = sum1 & carry_in;
    assign carry_out = carry1 | carry2;

endmodule
