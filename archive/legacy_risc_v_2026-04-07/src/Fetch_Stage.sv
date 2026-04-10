module Fetch_Stage (
    input logic clk,
    input logic reset,
    input logic [31:0] pc_branch,
    input logic pc_branch_en_sel,
    input logic imem_read_en, // Instruction Memory Read Enable
    

    output logic [31:0] pc_f, // Program Counter Output
    output logic [31:0] instr_f // Instruction Output
);


    // Internal signals
    logic [31:0] pc_next; // Next Program Counter value

    // Program Counter Logic
    always_ff @(posedge clk) begin
        if (reset) begin
            pc_f <= 32'h00000000; // Reset PC to 0
        end else begin
            if (pc_branch_en_sel) begin
                pc_f <= pc_branch; // Update PC with branch target
            end else begin
                pc_f <= pc_next; // Update PC with next value
            end
        end
    end

    // Calculate next PC value (PC + 4)
    assign pc_next = pc_f + 4;

    // Instruction Memory Block Instance
    Instruction_Memory_Block # (
        .IMEM_DEPTH(256),          // Depth of instruction memory
        .INIT_FILE("/home/dlsconnect/Documents/SFSU_2020_2025/SeniorProject_RISC_V/RISC_V/src/Instructions_Folder/imem.hex")     // Initialization file for instruction memory
        ) imem (
        .PC_f(pc_f),
        .imem_read_en(imem_read_en),
        .Instruction_f(instr_f)
    );

endmodule