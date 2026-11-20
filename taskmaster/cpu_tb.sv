`timescale 1ns / 1ps

module cpu_tb;
    logic clk = 1'b0;
    logic rst = 1'b1;
    logic halted;
    logic [7:0] instr_addr;
    logic [13:0] instr_data;
    logic [7:0] dmem_rd_addr, dmem_wr_addr;
    logic [7:0] dmem_wdata, dmem_rdata;
    logic dmem_rw;

    cpu u_cpu (
        .clk(clk),
        .rst(rst),
        .instr_addr(instr_addr),
        .instr_data(instr_data),
        .halted(halted),
        .dmem_rd_addr(dmem_rd_addr),
        .dmem_wr_addr(dmem_wr_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_rdata(dmem_rdata),
        .dmem_rw(dmem_rw)
    );

    InstMem u_imem (
        .address(instr_addr),
        .data(instr_data)
    );

    Mem u_dmem (
        .RdAddress(dmem_rd_addr),
        .Data_in(dmem_wdata),
        .WrtAddress(dmem_wr_addr),
        .clk(clk),
        .RW(dmem_rw),
        .rst(rst),
        .Data_Out(dmem_rdata)
    );

endmodule : cpu_tb
