`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 05:36:18 PM
// Design Name: 
// Module Name: adder
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


module adder #(
    parameter int WIDTH = 4
)(
    input carry_in,
    input [WIDTH - 1:0] a,
    input [WIDTH - 1:0] b,
    output [WIDTH - 1:0] sum,
    output carry_out
    );
    
    logic carry1, carry2, carry3;
    
    full_adder FA0(.a(a[0]), .b(b[0]), .carry_in(carry_in), .sum(sum[0]), .carry_out(carry1));
    full_adder FA1(.a(a[1]), .b(b[1]), .carry_in(carry1), .sum(sum[1]), .carry_out(carry2));
    full_adder FA2(.a(a[2]), .b(b[2]), .carry_in(carry2), .sum(sum[2]), .carry_out(carry3));
    full_adder FA3(.a(a[3]), .b(b[3]), .carry_in(carry3), .sum(sum[3]), .carry_out(carry_out));

endmodule
