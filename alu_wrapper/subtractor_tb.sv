`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 07:22:31 PM
// Design Name: 
// Module Name: subtractor_tb
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


module subtractor_tb(
    );

    logic [3:0] a_tb;
    logic [3:0] b_tb;
    logic [3:0] sum_tb;
    logic reminder_tb;
    
    subtractor UUT(
        .a(a_tb), .b(b_tb), 
        .sum(sum_tb[3:0]), 
        .reminder(reminder_tb)
    );
    
    string vcd_file;

    initial begin
        if (!$value$plusargs("VCD=%s", vcd_file))
            vcd_file = "simulation.vcd";

        $dumpfile(vcd_file);
        $dumpvars(0, subtractor_tb);

        a_tb = 4'h0; b_tb = 4'h0; #5;
        assert (sum_tb == 4'h0 && reminder_tb == 1'b1) $display("%h-%h=%h R=%b < Correct", a_tb, b_tb, sum_tb, reminder_tb);
            else $error("%h-%h=%h R=%b < Incorrect, must be 0 R=1", a_tb, b_tb, sum_tb, reminder_tb);

        a_tb = 4'hf; b_tb = 4'hf; #5;
        assert (sum_tb == 4'h0 && reminder_tb == 1'b1) $display("%h-%h=%h R=%b < Correct", a_tb, b_tb, sum_tb, reminder_tb);
            else $error("%h-%h=%h R=%b < Incorrect, must be 0 R=1", a_tb, b_tb, sum_tb, reminder_tb);

        a_tb = 4'hf; b_tb = 4'h0; #5;
        assert (sum_tb == 4'hf && reminder_tb == 1'b1) $display("%h-%h=%h R=%b < Correct", a_tb, b_tb, sum_tb, reminder_tb);
            else $error("%h-%h=%h R=%b < Incorrect, must be f R=1", a_tb, b_tb, sum_tb, reminder_tb);

        a_tb = 4'h0; b_tb = 4'hf; #5;
        assert (sum_tb == 4'h1 && reminder_tb == 1'b0) $display("%h-%h=%h R=%b < Correct", a_tb, b_tb, sum_tb, reminder_tb);
            else $error("%h-%h=%h R=%b < Incorrect, must be 1 R=0", a_tb, b_tb, sum_tb, reminder_tb);

        a_tb = 4'h8; b_tb = 4'h1; #5;
        assert (sum_tb == 4'h7 && reminder_tb == 1'b1) $display("%h-%h=%h R=%b < Correct", a_tb, b_tb, sum_tb, reminder_tb);
            else $error("%h-%h=%h R=%b < Incorrect, must be 7 R=1", a_tb, b_tb, sum_tb, reminder_tb);

        a_tb = 4'h0; b_tb = 4'h1; #5;
        assert (sum_tb == 4'hf && reminder_tb == 1'b0) $display("%h-%h=%h R=%b < Correct", a_tb, b_tb, sum_tb, reminder_tb);
            else $error("%h-%h=%h R=%b < Incorrect, must be f R=0", a_tb, b_tb, sum_tb, reminder_tb);

        a_tb = 4'h5; b_tb = 4'ha; #5;
        assert (sum_tb == 4'hb && reminder_tb == 1'b0) $display("%h-%h=%h R=%b < Correct", a_tb, b_tb, sum_tb, reminder_tb);
            else $error("%h-%h=%h R=%b < Incorrect, must be b R=0", a_tb, b_tb, sum_tb, reminder_tb);

        a_tb = 4'ha; b_tb = 4'h5; #5;
        assert (sum_tb == 4'h5 && reminder_tb == 1'b1) $display("%h-%h=%h R=%b < Correct", a_tb, b_tb, sum_tb, reminder_tb);
            else $error("%h-%h=%h R=%b < Incorrect, must be 5 R=1", a_tb, b_tb, sum_tb, reminder_tb);

        $stop;
    end

endmodule
