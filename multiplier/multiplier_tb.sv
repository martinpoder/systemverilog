`timescale 1ns / 1ps

module multiplier_tb #(
    parameter int DATA_WIDTH = 4);

    logic [DATA_WIDTH-1:0] a_tb, b_tb;
    logic [(DATA_WIDTH*2)-1:0] mul_tb;

    multiplier #(.data_width(DATA_WIDTH)) MUL(.a(a_tb), .b(b_tb), .multiplication(mul_tb));

string vcd_file;

initial begin
    if (!$value$plusargs("VCD=%s", vcd_file))
        vcd_file = "simulation.vcd";

    $dumpfile(vcd_file);
    $dumpvars(0, multiplier_tb);

    $display("%d-BIT TEST START", DATA_WIDTH);

    for (int a = 0; a < 2 ** DATA_WIDTH; a++) begin
        for (int b = 0; b < 2 ** DATA_WIDTH; b++) begin
            a_tb = a[DATA_WIDTH-1:0];
            b_tb = b[DATA_WIDTH-1:0];
            #5;
            assert (mul_tb == (DATA_WIDTH*2)'(a * b)) $display("%h*%h=%h < Correct", a_tb, b_tb, mul_tb);
                else $error("%h*%h=%h < Incorrect, must be %h", a_tb, b_tb, mul_tb, (DATA_WIDTH*2)'(a * b));
        end
    end
    $display("%d-BIT TEST STOP", DATA_WIDTH);
    $stop;
end

endmodule
