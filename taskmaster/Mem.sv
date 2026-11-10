// Behavioral data memory (converted from Memory.vhd)
// - asynchronous reset clears the whole memory
// - synchronous write on the rising clock edge when RW = 1
// - asynchronous (combinational) read
module Mem
    #(parameter int BitWidth = 8)
    (input  logic [BitWidth-1:0] RdAddress,
     input  logic [BitWidth-1:0] Data_in,
     input  logic [BitWidth-1:0] WrtAddress,
     input  logic                clk,
     input  logic                RW,
     input  logic                rst,
     output logic [BitWidth-1:0] Data_Out);

    typedef logic [BitWidth-1:0] Mem_type [0:(2**BitWidth)-1];
    Mem_type Mem_data;

    always_ff @(posedge clk or posedge rst) begin : MemProcess
        if (rst) begin
            Mem_data <= '{default: '0};
        end else begin
            if (RW) begin
                Mem_data[WrtAddress] <= Data_in;
            end
        end
    end

    assign Data_Out = Mem_data[RdAddress];

endmodule : Mem
