`timescale 1ns / 1ps

import cpu_pkg::*;

module cpu
    (input logic clk, rst,
     output logic [7:0] instr_addr, // to instruction memory
     input logic [13:0] instr_data, // from instruction memory
     output logic halted);

    logic [7:0] pc;         // program counter
    logic [13:0] ir;        // instruction register
    logic [7:0] a;          // accumulator
    logic [7:0] r [0:7];    // register file R0..R7
    logic [3:0] flags;      // flags register {EQ, OV, Z, C}
    logic [7:0] sp;         // stack pointer
    logic [7:0] op_b;       //
    logic [7:0] res;        //
    logic [7:0] alu_result; //
    logic [3:0] res_flags;  //
    logic [3:0] alu_flags;  //
    logic [7:0] pc_target;  //
    logic [7:0] pc_next;    //
    ctrl_t ctrl;
    state_t state, state_next;  // current and next state of the FSM
    opcode_t opcode;
    logic [7:0] operand;
    logic [7:0] b_value;

    // state register
    always_ff @(posedge clk or posedge rst) begin : state_reg
        if (rst) state <= FETCH;
        else state <= state_next;
    end : state_reg

    // next-state logic
    always_comb begin : next_state_logic
        case (state)
            FETCH: state_next = DECODE;
            DECODE: state_next = EXECUTE;
            EXECUTE: state_next = WRITEBACK;
            WRITEBACK: state_next = ctrl.halt ? WRITEBACK : FETCH;
            default: state_next = FETCH;
        endcase
    end : next_state_logic

    // 2.2 Fetch
    assign instr_addr = pc;

    alu #(.WIDTH(8)) u_alu (
        .a (a),
        .b (op_b),
        .op (ctrl.alu_op),
        .flags_in (flags),
        .result (alu_result),
        .flags_out (alu_flags));

    always_ff @(posedge clk or posedge rst) begin : datapath_regs
        if (rst) begin
            pc <= '0;
            ir <= '0;
        end else begin
            case (state)
                FETCH: ir <= instr_data;    // IR <- IM[PC]
                EXECUTE: begin
                    res <= alu_result; // ALU result
                    res_flags <= alu_flags; // new flags
                    pc_target <= pc_next; // next PC or jump target
                end
                WRITEBACK: begin
                    case (ctrl.dest)
                        DST_A: a <= res;
                        DST_R0: r[0] <= res;
                        DST_R: r[operand[2:0]] <= res;
                        default: ;
                    endcase
                    if (ctrl.upd_flags) flags <= res_flags;
                    if (ctrl.sp_inc) sp <= sp + 1'b1;
                    if (ctrl.sp_dec) sp <= sp - 1'b1;
                    pc <= pc_target;
                end
                default: ;
            endcase
        end
    end : datapath_regs

    // data memory is written at the end of the Write-Back state
    // assign dmem_rw = (state == WRITEBACK) && ctrl.mem_we;

    // 2.3 Decode
    assign opcode = opcode_t'(ir[13:8]);    // -> decoder, next PC
    assign operand = ir[7:0];               // -> B mux, addresses
    always_ff @(posedge clk or posedge rst) begin : decoder
        case (state)
            DECODE: op_b <= b_value; // operand B for the ALU
        endcase
    end : decoder

    // 2.4 Execute
    // take the jump when cond is 1
    task automatic jump_if (input logic cond,
                            input logic [7:0] target,
                            inout logic [7:0] next);
        if (cond) next = target;
    endtask

    always_comb begin : next_pc_logic
        pc_next = pc + 1'b1; // default: next instruction
        case (opcode)
            JMP: jump_if(1'b1, operand, pc_next);
            JMPZ: jump_if(flags[FLAG_Z], operand, pc_next);
            JMPC: jump_if(flags[FLAG_C], operand, pc_next);
            JMP_REL: jump_if(1'b1, pc + operand, pc_next);
            LOAD_PC: jump_if(1'b1, a, pc_next);
            HALT: pc_next = pc; // stay here
            default: ;
        endcase
    end : next_pc_logic

    // 4.0 Datapath
    // operand B: input multiplexer of the ALU
    always_comb begin : operand_b_mux
        case (ctrl.b_src)
            SRC_REG: b_value = r[operand[2:0]]; // register file
            SRC_MEM: b_value = dmem_rdata;      // data memory
            SRC_DIR: b_value = operand;         // constant
            SRC_ONE: b_value = 8'd1;            // IncA, DecA
            SRC_PC: b_value = pc;               // SavePC
            default: b_value = '0;              // ClearACC
        endcase
    end : operand_b_mux

    // data memory read address
    always_comb begin : dmem_read_address
        case (ctrl.rd_sel)
            RD_A: dmem_rd_addr = a;             // Load_Ind_A
            RD_SP: dmem_rd_addr = sp - 1'b1;    // POP
            default: dmem_rd_addr = operand;    // Mem[operand]
        endcase
    end : dmem_read_address

    // data memory write address and data
    assign dmem_wr_addr = ctrl.wr_at_sp ? sp : operand; // PUSH : Store
    assign dmem_wdata = a;

endmodule : cpu
