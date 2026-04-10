module Instruction_Memory_Block #(
    parameter int IMEM_DEPTH = 256,          // words
    parameter     INIT_FILE  = "imem.hex"    // $readmemh file
)(
    input  logic [31:0] PC_f, // Program Counter
    input  logic        imem_read_en, // Instruction Memory Read Enable
    output logic [31:0] Instruction_f // Instruction Output
);

    localparam int ADDR_WIDTH = $clog2(IMEM_DEPTH);
    wire [ADDR_WIDTH-1:0] word_idx = PC_f[ADDR_WIDTH+1 : 2];

    logic [31:0] rom [0 : IMEM_DEPTH-1];

    initial if (INIT_FILE != "") $readmemh(INIT_FILE, rom);

    always_comb
        Instruction_f = imem_read_en ? rom[word_idx] : 32'h0000_0013;

endmodule
