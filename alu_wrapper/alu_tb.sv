`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 08:04:07 PM
// Design Name: 
// Module Name: alu_tb
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


module alu_tb(

    );
    
    logic [3:0] a_tb;
    logic [3:0] b_tb;
    logic carry_in_tb;
    logic [2:0] op_tb;
    logic [3:0] result_tb;
    logic [1:0] flags_out_tb;

    alu UUT(
        .a(a_tb), .b(b_tb), .carry_in(carry_in_tb), .op(op_tb),
        .result(result_tb), .flags_out(flags_out_tb)
    );

    string vcd_file;

    initial begin
        if (!$value$plusargs("VCD=%s", vcd_file))
            vcd_file = "simulation.vcd";

        $dumpfile(vcd_file);
        $dumpvars(0, alu_tb);

        a_tb = 4'hA; b_tb = 4'h5; carry_in_tb = 1'b1;

        op_tb = 3'b000; #5; // ADD
        assert (result_tb == 4'h0 && flags_out_tb == 2'b11) $display("%h+%h=%h F=%b < Correct", a_tb, b_tb, result_tb, flags_out_tb);
            else $error("%h+%h=%h F=%b < Incorrect, must be F F=11", a_tb, b_tb, result_tb, flags_out_tb);

        op_tb = 3'b001; #5; // SUB
        assert (result_tb == 4'h5 && flags_out_tb == 2'b11) $display("%h-%h=%h F=%b < Correct", a_tb, b_tb, result_tb, flags_out_tb);
            else $error("%h-%h=%h F=%b < Incorrect, must be 5 F=10", a_tb, b_tb, result_tb, flags_out_tb);

        op_tb = 3'b010; #5; // AND
        assert (result_tb == 4'h0) $display("%b & %b=%b < Correct", a_tb, b_tb, result_tb);
            else $error("%h & %h=%h < Incorrect, must be 0000", a_tb, b_tb, result_tb);

        op_tb = 3'b011; #5; // OR
        assert (result_tb == 4'hF) $display("%b | %b=%b < Correct", a_tb, b_tb, result_tb);
            else $error("%h | %h=%h < Incorrect, must be 1111", a_tb, b_tb, result_tb);

        op_tb = 3'b100; #5; // XOR
        assert (result_tb == 4'hF) $display("%b ^ %b=%b < Correct", a_tb, b_tb, result_tb);
            else $error("%h ^ %h=%h < Incorrect, must be 1111", a_tb, b_tb, result_tb);

        op_tb = 3'b101; #5; // INV
        assert (result_tb == 4'h5) $display("~%b=%b < Correct", a_tb, result_tb);
            else $error("~%b=%b < Incorrect, must be 0101", a_tb, result_tb);

        a_tb = 4'h6; b_tb = 4'h1;

        op_tb = 3'b110; #5; // SHL
        assert (result_tb == 4'hC) $display("%b << %b=%b < Correct", a_tb, b_tb, result_tb);
            else $error("%b << %b=%b < Incorrect, must be 1100", a_tb, b_tb, result_tb);

        op_tb = 3'b111; #5; // SHR
        assert (result_tb == 4'h3) $display("%b >> %b=%b < Correct", a_tb, b_tb, result_tb);
            else $error("%b >> %b=%b < Incorrect, must be 0011", a_tb, b_tb, result_tb);

        $stop;
    end

endmodule
