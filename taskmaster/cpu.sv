`timescale 1ns / 1ps

import cpu_pkg::*;

module cpu
    (input logic clk, rst,
     output logic [7:0] instr_addr, // address to instruction memory
     input logic [13:0] instr_data, // data from instruction memory
     output logic halted,
     output logic [7:0] dmem_rd_addr, dmem_wr_addr, dmem_wdata,
     input logic [7:0] dmem_rdata,
     output logic dmem_rw);

    logic [7:0] pc;         // program counter (address of the instruction memory)
    assign instr_addr = pc;
    logic [13:0] ir;        // instruction register (6-bit opcode & 8-bit operand)
    logic [7:0] a;          // accumulator
    logic [7:0] r [0:7];    // register file R0..R7
    logic [3:0] flags;      // flags register {EQ, OV, Z, C}
    logic [7:0] sp;         // stack pointer
    logic [7:0] op_b;       //
    logic [7:0] res;        //
    logic [7:0] alu_result; //
    logic [3:0] res_flags;  //
    logic [3:0] alu_flags;  //
    logic [3:0] alu_flags_in;
    logic [7:0] pc_target;  //
    logic [7:0] pc_next;    //
    ctrl_t ctrl;
    state_t state, state_next;  // current and next state of the FSM
    logic [7:0] b_value;

    

    // instruction fields
    opcode_t opcode;
    // operand is a constant for the ALU, a register number,
    // a data memory address or a jump target.
    logic [7:0] operand;
    assign opcode = opcode_t'(ir[13:8]);    // -> decoder, next PC
    assign operand = ir[7:0];               // -> B mux, addresses

    // ALU result to accumulator, flags are updated
    task automatic alu_to_a(input alu_op_t f, input b_src_t src, inout ctrl_t c);
        c.alu_op = f;
        c.b_src = src;
        c.dest = DST_A;
        c.upd_flags = 1'b1;
    endtask

    // data move: source to destination, flags are kept
    task automatic move(input b_src_t src, input dest_t dst, inout ctrl_t c);
        c.alu_op = (dst == DST_R) ? ALU_PASS_A : ALU_PASS_B;
        c.b_src = src;
        c.dest = dst;
    endtask

    // The CPU's ADD instructions and INC have no carry input.
    always_comb begin
        alu_flags_in = flags;
        if (ctrl.alu_op == ALU_ADD) alu_flags_in[FLAG_C] = 1'b0;
    end

    alu #(.WIDTH(8)) u_alu (
        .a (a),
        .b (op_b),
        .op (ctrl.alu_op),
        .flags_in (alu_flags_in),
        .result (alu_result),
        .flags_out (alu_flags));

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

    always_ff @(posedge clk or posedge rst) begin : datapath_regs
        if (rst) begin
            pc <= '0;
            ir <= '0;
            a <= '0;
            r <= '{default: '0};
            flags <= '0;
            sp <= '0;
        end else begin
            case (state)
                FETCH: ir <= instr_data;        // IR <- IM[PC]
                EXECUTE: begin
                    res       <= alu_result;    // ALU result
                    res_flags <= alu_flags;     // new flags
                    pc_target <= pc_next;       // next PC or jump target
                end
                WRITEBACK: begin
                    case (ctrl.dest)
                        DST_A: a <= res;
                        DST_R0: r[0] <= res;
                        DST_R: r[operand[2:0]] <= res;
                        default: ;
                    endcase
                    if (ctrl.upd_flags) flags <= res_flags;
                    else if (ctrl.clear_flags != '0) flags <= flags & ~ctrl.clear_flags;
                    if (ctrl.sp_inc) sp <= sp + 1'b1;
                    if (ctrl.sp_dec) sp <= sp - 1'b1;
                    pc <= pc_target;
                end
                DECODE: op_b <= b_value; // operand B for the ALU               
                default: ;
            endcase
        end
    end : datapath_regs

    // data memory is written at the end of the Write-Back state
    assign dmem_rw = (state == WRITEBACK) && ctrl.mem_we;
    assign halted = (state == WRITEBACK) && ctrl.halt;

    // execution
    // take the jump when cond is 1
    task automatic jump_if (input logic cond,
                            input logic [7:0] target,
                            inout logic [7:0] next);
        if (cond) next = target;
    endtask

    always_comb begin : decoder
        ctrl = '{alu_op: ALU_PASS_A, b_src: SRC_ZERO, dest: DST_NONE,
                 rd_sel: RD_OPERAND, default: '0};
        case (opcode)
            ADD_A_R: alu_to_a(ALU_ADD, SRC_REG, ctrl);
            ADD_A_MEM: alu_to_a(ALU_ADD, SRC_MEM, ctrl);
            ADD_A_DIR: alu_to_a(ALU_ADD, SRC_DIR, ctrl);
            SUB_A_R: alu_to_a(ALU_SUB, SRC_REG, ctrl);
            SUB_A_MEM: alu_to_a(ALU_SUB, SRC_MEM, ctrl);
            SUB_A_DIR: alu_to_a(ALU_SUB, SRC_DIR, ctrl);
            INC_A: alu_to_a(ALU_ADD, SRC_ONE, ctrl);
            DEC_A: alu_to_a(ALU_SUB, SRC_ONE, ctrl);
            SHIFT_ARITH_R: alu_to_a(ALU_SHIFT_ARITH_R, SRC_ONE, ctrl);
            SHIFT_ARITH_L: alu_to_a(ALU_SHIFT_ARITH_L, SRC_ONE, ctrl);
            SHIFTA_R: alu_to_a(ALU_SHIFT_A_R, SRC_ONE, ctrl);
            SHIFTA_L: alu_to_a(ALU_SHIFT_A_L, SRC_ONE, ctrl);
            RRC: alu_to_a(ALU_RRC, SRC_ZERO, ctrl);
            RLC: alu_to_a(ALU_RLC, SRC_ZERO, ctrl);
            AND_A_R: alu_to_a(ALU_AND, SRC_REG, ctrl);
            OR_A_R: alu_to_a(ALU_OR, SRC_REG, ctrl);
            XOR_A_R: alu_to_a(ALU_XOR, SRC_REG, ctrl);
            FLIP_A: alu_to_a(ALU_FLIP, SRC_ZERO, ctrl);
            NEG_A: alu_to_a(ALU_NEG, SRC_ZERO, ctrl);
            // Jumps handled in next_pc_logic
            CLEAR_Z: ctrl.clear_flags[FLAG_Z] = 1'b1;
            CLEAR_OV: ctrl.clear_flags[FLAG_OV] = 1'b1;
            CLEAR_C: ctrl.clear_flags[FLAG_C] = 1'b1;
            CLEAR_ACC: move(SRC_ZERO, DST_A, ctrl);
            SAVE_PC: move(SRC_PC, DST_A, ctrl);
            LOAD_A_MEM: move(SRC_MEM, DST_A, ctrl);
            STORE_A_MEM: ctrl.mem_we = 1'b1;
            LOAD_R0_DIR: move(SRC_DIR, DST_R0, ctrl);
            LOAD_R0_MEM: move(SRC_MEM, DST_R0, ctrl);
            LOAD_A_R: move(SRC_REG, DST_A, ctrl);
            LOAD_R_A: move(SRC_ZERO, DST_R, ctrl);
            LOAD_IND_A: begin
                ctrl.rd_sel = RD_A;
                move(SRC_MEM, DST_A, ctrl);
            end
            PUSH: begin
                ctrl.mem_we = 1'b1;
                ctrl.wr_at_sp = 1'b1;
                ctrl.sp_inc = 1'b1;
            end
            POP: begin
                ctrl.rd_sel = RD_SP;
                ctrl.sp_dec = 1'b1;
                move(SRC_MEM, DST_A, ctrl);
            end
            HALT: ctrl.halt = 1'b1;
            default: ; // NOP, jumps
        endcase
    end : decoder

    always_comb begin : next_pc_logic
        pc_next = pc + 1'b1; // default: next instruction
        case (opcode)
            JMP: jump_if(1'b1, operand, pc_next);
            JMPZ: jump_if(flags[FLAG_Z], operand, pc_next);
            JMPOV: jump_if(flags[FLAG_OV], operand, pc_next);
            JMPC: jump_if(flags[FLAG_C], operand, pc_next);
            JMP_REL: jump_if(1'b1, pc + operand, pc_next);
            JMP_EQ: jump_if(flags[FLAG_EQ], operand, pc_next);
            LOAD_PC: jump_if(1'b1, a, pc_next);
            HALT: pc_next = pc; // stay here
            default: ;
        endcase
    end : next_pc_logic

    // Datapath
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
