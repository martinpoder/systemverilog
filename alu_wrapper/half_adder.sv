`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2026 06:28:05 PM
// Design Name: 
// Module Name: half_adder
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


module half_adder(
    input a,
    input b,
    output sum,
    output carry
    );
    
    assign sum = a ^ b;
    assign carry = a & b;
    
endmodule
