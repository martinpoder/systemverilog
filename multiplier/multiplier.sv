`timescale 1ns / 1ps

module multiplier 
    # (parameter int data_width = 4)
    (input [data_width-1:0] a, b,
    input carry_in,
    output [(data_width*2)-1:0] multiplication);     // output has 2x bits as input
    // output carry_out);

	// data_width + 1 number of vector arrays with width of data_width + 1
    logic [data_width:0] rca [0:data_width];	// {MSB carry, 4 bit sum out}
	assign rca [0] = {1'b0, a & {data_width{b[0]}}};

	assign multiplication[(data_width*2)-1:data_width-1] = rca[data_width-1];

    generate
        for (genvar i = 0; i < data_width-1; i++) begin : adder
            ripple_carry_adder #(.n(data_width)) RCA(.a(a & {data_width{b[i+1]}}), 
                                                     .b({1'b0, rca[i][data_width-1:1]}), 
                                                     .carry_in(1'b0), 
                                                     .sum_out(rca[i+1][data_width-1:0]), 
                                                     .carry_out(rca[i+1][data_width]));
            assign multiplication[i] = rca[i][0];
         end
     endgenerate

/*  genvar is doing this:
    ripple_carry_adder #(.n(4)) RCA0(.a(a & {4{b[1]}}), .b({1'b0, rca[0][3:1]}), 
                .carry_in(1'b0), .sum_out(rca[1][3:0]), .carry_out(rca[1][4]));
    ripple_carry_adder #(.n(4)) RCA1(.a(a & {4{b[2]}}), .b({1'b0, rca[1][3:1]}), 
                .carry_in(1'b0), .sum_out(rca[2][3:0]), .carry_out(rca[2][4]));
    ripple_carry_adder #(.n(4)) RCA2(.a(a & {4{b[3]}}), .b({1'b0, rca[2][3:1]}), 
                .carry_in(1'b0), .sum_out(rca[3][3:0]), .carry_out(rca[3][4]));
    assign multiplication[0] = rca[0][0];
	assign multiplication[1] = rca[1][0];
	assign multiplication[2] = rca[2][0];
*/

endmodule
