package cpu_pkg;

typedef enum logic [5:0] {
    ADD_A_R       = 6'b000000, // op A ← A + R[op] C Z OV
    ADD_A_MEM     = 6'b000001, // op A ← A + Mem[op] C Z OV
    ADD_A_DIR     = 6'b000010, // op A ← A + op C Z OV
    SUB_A_R       = 6'b000011, // op A ← A - R[op] C Z OV EQ
    SUB_A_MEM     = 6'b000100, // op A ← A - Mem[op] C Z OV EQ
    SUB_A_DIR     = 6'b000101, // op A ← A - op C Z OV EQ
    INC_A         = 6'b000110, // A ← A + 1 C Z OV
    DEC_A         = 6'b000111, // A ← A - 1 C Z OV EQ
    SHIFT_ARITH_R = 6'b001000, // A ← {A[7], A[7:1]} Z
    SHIFT_ARITH_L = 6'b001001, // A ← {A[7], A[5:0], 1'b0} Z
    SHIFTA_R      = 6'b001010, // A ← {1'b0, A[7:1]} Z
    SHIFTA_L      = 6'b001011, // A ← {A[6:0], 1'b0} Z
    RRC           = 6'b001100, // A ← {C, A[7:1]}, C ← A[0] C Z
    RLC           = 6'b001101, // A ← {A[6:0], C}, C ← A[7] C Z
    AND_A_R       = 6'b001110, // op A ← A & R[op] Z
    OR_A_R        = 6'b001111, // op A ← A | R[op] Z
    XOR_A_R       = 6'b010000, // op A ← A ^ R[op] Z
    FLIP_A        = 6'b010001, // A ← ~A Z
    NEG_A         = 6'b010010, // A ← ~A + 1 Z OV
    JMP           = 6'b010011, // op PC ← op –
    JMPZ          = 6'b010100, // op if Z = 1: PC ← op –
    JMPOV         = 6'b010101, // op if OV = 1: PC ← op –
    JMPC          = 6'b010110, // op if C = 1: PC ← op –
    JMP_REL       = 6'b010111, // op PC ← PC + op –
    JMP_EQ        = 6'b011000, // op if EQ = 1: PC ← op –
    CLEAR_Z       = 6'b011001, // Z ← 0 Z
    CLEAR_OV      = 6'b011010, // OV ← 0 OV
    CLEAR_C       = 6'b011011, // C ← 0 C
    CLEAR_ACC     = 6'b011100, // A ← 0 –
    LOAD_PC       = 6'b011101, // PC ← A –
    SAVE_PC       = 6'b011110, // A ← PC –
    LOAD_A_MEM    = 6'b011111, // op A ← Mem[op] –
    STORE_A_MEM   = 6'b100000, // op Mem[op] ← A –
    LOAD_R0_DIR   = 6'b100001, // op R0 ← op –
    LOAD_R0_MEM   = 6'b100010, // op R0 ← Mem[op] –
    LOAD_A_R      = 6'b100011, // op A ← R[op] –
    LOAD_R_A      = 6'b100100, // op R[op] ← A –
    LOAD_IND_A    = 6'b100101, // A ← Mem[A] –
    PUSH          = 6'b111100, // Mem[SP] ← A, SP ← SP + 1 –
    POP           = 6'b111101, // A ← Mem[SP - 1], SP ← SP - 1 –
    NOP           = 6'b111110, // no operation –
    HALT          = 6'b111111  // stop: PC and state do not change –
} opcode_t;

typedef enum logic [3:0] {  // each bit is one flag, therefore 4 bits
    FLAG_C,     // CARRY: ADD carry out of bit 7; SUB A + ~B + 1 ie no borrow; RRC/RLC: the bit shifted out
    FLAG_Z,     // ZERO: 1 if ALU result is 0
    FLAG_OV,    // OVERFLOW: signed (2’s compl) result does not fit into 8 bits, e.g. 127 + 1
    FLAG_EQ     // EQUAL: SUB the two operands are equal (A = B before subtraction)
} flag_t;

typedef enum logic [3:0] {  // value defines operation. Since below 16 values it can fit into 4 bits
    ALU_ADD,
    ALU_SUB,
    ALU_SHIFT_ARITH_R,
    ALU_SHIFT_ARITH_L,
    ALU_SHIFT_A_R,
    ALU_SHIFT_A_L,
    ALU_RRC,
    ALU_RLC,
    ALU_AND,
    ALU_OR,
    ALU_XOR,
    ALU_FLIP,
    ALU_NEG
} alu_ops_t;

endpackage
