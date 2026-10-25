`timescale 1ns / 1ps

module multiplier_tb();
    logic carry_in_tb;
    logic [3:0] a_tb;
    logic [3:0] b_tb;
    logic [7:0] mul_tb;

    multiplier #(.data_width(4)) MUL4(
        .carry_in(carry_in_tb),
        .a(a_tb), .b(b_tb), 
        .multiplication(mul_tb) 
    );

string vcd_file;

initial begin
    if (!$value$plusargs("VCD=%s", vcd_file))
        vcd_file = "simulation.vcd";

    $dumpfile(vcd_file);
    $dumpvars(0, multiplier_tb);

    carry_in_tb = 0;

    for (int a = 0; a < 16; a++) begin
        for (int b = 0; b < 16; b++) begin
            a_tb = a[3:0];
            b_tb = b[3:0];
            #5;
            assert (mul_tb == 8'(a * b)) $display("%h*%h=%h < Correct", a_tb, b_tb, mul_tb);
                else $error("%h*%h=%h < Incorrect, must be %h", a_tb, b_tb, mul_tb, 8'(a * b));
        end
    end
    $stop;
end

endmodule
