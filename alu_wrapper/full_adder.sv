`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 04:42:50 PM
// Design Name: 
// Module Name: full_adder
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


module full_adder(
    input a,
    input b,
    input carry_in,
    output sum,
    output carry_out
    );
    
    logic sum1, carry1, carry2;
    
    half_adder HA1(.a(a), .b(b), .sum(sum1), .carry(carry1));
    half_adder HA2(.a(sum1), .b(carry_in), .sum(sum), .carry(carry2));

    assign carry_out = carry1 | carry2;

endmodule
