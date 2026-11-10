// Behavioral instruction memory (converted from InstMem.vhd)
// Instruction format: [InstructionWidth-1 : BitWidth] = OPCODE (6 bits)
//                     [BitWidth-1 : 0]                = OPERAND
module InstMem
    #(parameter int BitWidth         = 8,
      parameter int InstructionWidth = 14)
    (input  logic [BitWidth-1:0]         address,
     output logic [InstructionWidth-1:0] data);

    typedef logic [InstructionWidth-1:0] mem [0:(2**BitWidth)-1];

    localparam mem my_InstMem = '{
         0 : 14'b10000100011000, // Load_R0_Dir
         1 : 14'b00111100000000, // OR_A_R 0
         2 : 14'b00011000000000, // IncA
         3 : 14'b00001100000000, // Sub_A_R 0
         4 : 14'b01011000000111, // JmpC 7
         5 : 14'b11111011110000, // NOP
         6 : 14'b11111000000000, // NOP
         7 : 14'b00110000000000, // RRC
         8 : 14'b00110100000000, // RLC
         9 : 14'b11111000000000, // NOP
        10 : 14'b01101100000000, // ClearC
        11 : 14'b10000000010000, // Store_A_Mem
        12 : 14'b11110000000000, // PUSH
        13 : 14'b01111000000000, // SavePC
        14 : 14'b11110000000000, // PUSH
        15 : 14'b01001100010100, // Jmp 20
        16 : 14'b11110100000000, // pop
        17 : 14'b00100100000000, // ShiftArithL
        18 : 14'b00011100000000, // DecA
        19 : 14'b11111100000000, // HALT
        20 : 14'b01111100010000, // Load_A_Mem
        21 : 14'b00111000000000, // AND
        22 : 14'b01010000011000, // JMPZ 24
        23 : 14'b11111000000000, // NOP
        24 : 14'b01101100000000, // ClearZ
        25 : 14'b00000100010000, // Add_A_Mem
        26 : 14'b00010000010000, // Sub_A_Mem
        27 : 14'b00000000000000, // ADD_A_R 0
        28 : 14'b00010100001100, // SUB_A_DIR C
        29 : 14'b01000100000000, // FlipA
        30 : 14'b01000000000000, // XOR_A_R 0
        31 : 14'b01001000000000, // NegA
        32 : 14'b00100000000000, // ShiftArithR
        33 : 14'b00101100000000, // ShiftA_L
        34 : 14'b00101000000000, // ShiftA_R
        35 : 14'b01110000000000, // ClearACC
        36 : 14'b11110100000000, // POP
        37 : 14'b00001000000011, // Add_A_Dir
        38 : 14'b01110100000000, // LoadPC
        default : 14'b00000000000000
    };

    assign data = my_InstMem[address];

endmodule : InstMem
