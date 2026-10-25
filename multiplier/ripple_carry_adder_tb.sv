`timescale 1ns / 1ps

module ripple_carry_adder_tb #(
    parameter int DATA_WIDTH = 4);

    logic carry_in_tb, carry_out_tb;
    logic [DATA_WIDTH-1:0] a_tb, b_tb, sum_tb;
    logic [DATA_WIDTH:0] ex_sum_and_carry;

    // expected sum with carry added on top
    assign ex_sum_and_carry = {{1'b0, a_tb} + {1'b0, b_tb} + (DATA_WIDTH)'(carry_in_tb)};

    ripple_carry_adder #(.n(DATA_WIDTH)) RPA(.carry_in(carry_in_tb),.a(a_tb), .b(b_tb), 
        .sum_out(sum_tb), .carry_out(carry_out_tb));

string vcd_file;

initial begin
    if (!$value$plusargs("VCD=%s", vcd_file))
        vcd_file = "simulation.vcd";

    $dumpfile(vcd_file);
    $dumpvars(0, ripple_carry_adder_tb);

    $display("%d-BIT TEST START", DATA_WIDTH);

    for (int c = 0; c < 2; c++) begin
        for (int a = 0; a < 2 ** DATA_WIDTH; a++) begin
            for (int b = 0; b < 2 ** DATA_WIDTH; b++) begin
                a_tb = a[DATA_WIDTH-1:0];
                b_tb = b[DATA_WIDTH-1:0];
                carry_in_tb = 1'(c);
                #5;
                assert ({carry_out_tb, sum_tb} == ex_sum_and_carry)
                    $display("CI=%b %h+%h=%h CO=%b < Correct", carry_in_tb, a_tb, b_tb, sum_tb, carry_out_tb);
                else $error("CI=%b %h+%h=%h CO=%b < Incorrect, must be %h CO=%b", carry_in_tb, a_tb, b_tb, 
                    sum_tb, carry_out_tb, ex_sum_and_carry[DATA_WIDTH-1:0], ex_sum_and_carry[DATA_WIDTH]);
            end
        end
    end
    $display("%d-BIT TEST STOP", DATA_WIDTH);
    $stop;
end

endmodule
