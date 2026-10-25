`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 06:18:16 PM
// Design Name: 
// Module Name: adder_tb
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


module adder_tb(

    );
    
    logic carry_in_tb;
    logic [3:0] a_tb;
    logic [3:0] b_tb;
    logic [3:0] sum_tb;
    logic carry_out_tb;
    
    adder UUT(
        .carry_in(carry_in_tb), 
        .a(a_tb), .b(b_tb), 
        .sum(sum_tb[3:0]), 
        .carry_out(carry_out_tb)
    );

    string vcd_file;
    
    initial begin
        if (!$value$plusargs("VCD=%s", vcd_file))
            vcd_file = "simulation.vcd";

        $dumpfile(vcd_file);
        $dumpvars(0, adder_tb);

        carry_in_tb = 0; a_tb = 4'h0; b_tb = 4'h0; #5;
        assert (sum_tb == 4'h0 && carry_out_tb == 1'b0) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be 0 CO=0", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);

        carry_in_tb = 1; a_tb = 4'hf; b_tb = 4'hf; #5;
        assert (sum_tb == 4'hf && carry_out_tb == 1'b1) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be f CO=1", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);

        carry_in_tb = 0; a_tb = 4'hf; b_tb = 4'h0; #5;
        assert (sum_tb == 4'hf && carry_out_tb == 1'b0) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be f CO=0", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);

        carry_in_tb = 0; a_tb = 4'h0; b_tb = 4'hf; #5;
        assert (sum_tb == 4'hf && carry_out_tb == 1'b0) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be f CO=0", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);

        carry_in_tb = 1; a_tb = 4'hf; b_tb = 4'h0; #5;
        assert (sum_tb == 4'h0 && carry_out_tb == 1'b1) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be 0 CO=1", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);

        carry_in_tb = 1; a_tb = 4'h0; b_tb = 4'hf; #5;
        assert (sum_tb == 4'h0 && carry_out_tb == 1'b1) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be 0 CO=1", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);

        carry_in_tb = 0; a_tb = 4'h5; b_tb = 4'ha; #5;
        assert (sum_tb == 4'hf && carry_out_tb == 1'b0) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be f CO=0", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);

        carry_in_tb = 1; a_tb = 4'ha; b_tb = 4'h5; #5;
        assert (sum_tb == 4'h0 && carry_out_tb == 1'b1) $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
            else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be 0 CO=1", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);

        $stop;
    end

endmodule
