`timescale 1ns / 1ps

module ripple_carry_adder
    # (parameter int n = 4)
    (input logic [n-1:0] a, b,
    input logic carry_in,
    output logic [n-1:0] sum_out,
    output logic carry_out);

    logic [n:0] c;              // for n=4 4:0 5 bit
    assign c[0] = carry_in;     // first bit carry_in
    assign carry_out = c[n];    // last bit carry_out

    generate
        for (genvar i = 0; i < n; i++) begin : adder
            full_adder FA(.a(a[i]), .b(b[i]), .carry_in(c[i]), .sum(sum_out[i]), .carry_out(c[i+1]));
         end
     endgenerate

endmodule
