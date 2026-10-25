`timescale 1ns / 1ps

module ripple_carry_adder_tb();
    // 4-bit adder
    logic carry_in_tb;
    logic [3:0] a_tb;
    logic [3:0] b_tb;
    logic [3:0] sum_tb;
    logic carry_out_tb;

    ripple_carry_adder #(.n(4)) RPA4(
        .carry_in(carry_in_tb),
        .a(a_tb), .b(b_tb), 
        .sum_out(sum_tb), 
        .carry_out(carry_out_tb)
    );

    // 8-bit adder
    logic [7:0] a_tb8;
    assign a_tb8 = {a_tb, a_tb};
    logic [7:0] b_tb8;
    assign b_tb8 = {b_tb, b_tb};
    logic [7:0] sum_tb8;
    logic carry_out_tb8;

    ripple_carry_adder #(.n(8)) RPA8(
        .carry_in(carry_in_tb),
        .a(a_tb8), .b(b_tb8), 
        .sum_out(sum_tb8), 
        .carry_out(carry_out_tb8)
    );

string vcd_file;

initial begin
    if (!$value$plusargs("VCD=%s", vcd_file))
        vcd_file = "simulation.vcd";

    $dumpfile(vcd_file);
    $dumpvars(0, ripple_carry_adder_tb);
        carry_in_tb = 0; a_tb = 4'h0; b_tb = 4'h0; #5;
        assert (sum_tb == a_tb + b_tb + carry_in_tb && carry_out_tb == 1'b0) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be 0 CO=0", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
        assert (sum_tb8 == a_tb8 + b_tb8 && carry_out_tb8 == 1'b0) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be 0 CO=0", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);

        carry_in_tb = 1; a_tb = 4'hf; b_tb = 4'hf; #5;
        assert (sum_tb == a_tb + b_tb + carry_in_tb && carry_out_tb == 1'b1) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be f CO=1", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
        assert (sum_tb8 == a_tb8 + b_tb8 + carry_in_tb && carry_out_tb8 == 1'b1) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be f CO=1", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);

        carry_in_tb = 0; a_tb = 4'hf; b_tb = 4'h0; #5;
        assert (sum_tb == a_tb + b_tb + carry_in_tb && carry_out_tb == 1'b0) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be f CO=0", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
        assert (sum_tb8 == a_tb8 + b_tb8 + carry_in_tb && carry_out_tb8 == 1'b0) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be f CO=0", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);

        carry_in_tb = 0; a_tb = 4'h0; b_tb = 4'hf; #5;
        assert (sum_tb == a_tb + b_tb + carry_in_tb && carry_out_tb == 1'b0) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be f CO=0", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
        assert (sum_tb8 == a_tb8 + b_tb8 + carry_in_tb && carry_out_tb8 == 1'b0) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be f CO=0", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);

        carry_in_tb = 1; a_tb = 4'hf; b_tb = 4'h0; #5;
        assert (sum_tb == a_tb + b_tb + carry_in_tb && carry_out_tb == 1'b1) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be 0 CO=1", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
        assert (sum_tb8 == a_tb8 + b_tb8 + carry_in_tb && carry_out_tb8 == 1'b1) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be 0 CO=1", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);

        carry_in_tb = 1; a_tb = 4'h0; b_tb = 4'hf; #5;
        assert (sum_tb == a_tb + b_tb + carry_in_tb && carry_out_tb == 1'b1) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be 0 CO=1", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
        assert (sum_tb8 == a_tb8 + b_tb8 + carry_in_tb && carry_out_tb8 == 1'b1) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be 0 CO=1", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);

        carry_in_tb = 0; a_tb = 4'h5; b_tb = 4'ha; #5;
        assert (sum_tb == a_tb + b_tb + carry_in_tb && carry_out_tb == 1'b0) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be f CO=0", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
        assert (sum_tb8 == a_tb8 + b_tb8 + carry_in_tb && carry_out_tb8 == 1'b0) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be f CO=0", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);

        carry_in_tb = 1; a_tb = 4'ha; b_tb = 4'h5; #5;
        assert (sum_tb == a_tb + b_tb + carry_in_tb && carry_out_tb == 1'b1) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be 0 CO=1", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
        assert (sum_tb8 == a_tb8 + b_tb8 + carry_in_tb && carry_out_tb8 == 1'b1) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be 0 CO=1", carry_in_tb, a_tb8, b_tb8, sum_tb8, carry_out_tb8);

        $stop;
    end

endmodule

