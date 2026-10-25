`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2026 06:30:47 PM
// Design Name: 
// Module Name: half_adder_tb
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


module half_adder_tb(

    );
    
    logic a_tb, b_tb;
    logic [1:0] sum_tb;
    
    half_adder UUT(
        .sum (sum_tb[0]),
        .a (a_tb),
        .carry (sum_tb[1]),
        .b (b_tb)
    );
    
    string vcd_file;

    initial begin
        if (!$value$plusargs("VCD=%s", vcd_file))
            vcd_file = "simulation.vcd";

        $dumpfile(vcd_file);
        $dumpvars(0, half_adder_tb);
        
		a_tb = 0; b_tb = 0; #5;
        assert (sum_tb == 2'b00) $display("%b + %b = %b < Correct", a_tb, b_tb, sum_tb);
            else $error("%b + %b = %b < Incorrect, must be 00", a_tb, b_tb, sum_tb);

        a_tb = 0; b_tb = 1; #5;
        assert (sum_tb == 2'b01) $display("%b + %b = %b < Correct", a_tb, b_tb, sum_tb);
            else $error("%b + %b = %b < Incorrect, must be 01", a_tb, b_tb, sum_tb);

        a_tb = 1; b_tb = 0; #5;
        assert (sum_tb == 2'b01) $display("%b + %b = %b < Correct", a_tb, b_tb, sum_tb);
            else $error("%b + %b = %b < Incorrect, must be 01", a_tb, b_tb, sum_tb);

        a_tb = 1; b_tb = 1; #5;
        assert (sum_tb == 2'b10) $display("%b + %b = %b < Correct", a_tb, b_tb, sum_tb);
            else $error("%b + %b = %b < Incorrect, must be 10", a_tb, b_tb, sum_tb);
        $stop;
		$finish;
    end
    
endmodule
