module Fetch_Stage_bp(
    //inputs
    input clk,
    input rst,
    input [31:0] pc_branch,
    input [1:0] pc_branch_en_sel,
    input [31:0] pc_d, // Updated to 32-bit
    input logic imem_read_en, // Added missing port
    //outputs
    output logic flush_fd,
    output logic flush_de,
    output logic [31:0] pc_f, // Updated to 32-bit
    output logic [31:0] instr_f // Updated to 32-bit
);

//internal wires
logic [31:0] pc_out;

//instantiate the branch predictor
Branch_Predictor_Block int_bp(
    .clk(clk),
    .pc_branch_en_sel(pc_branch_en_sel),
    .rst(rst),
    .pc_f(pc_f),
    .pc_d(pc_d),
    .instr_f(instr_f),
    .pc_branch(pc_branch),
    .flush_fd(flush_fd),
    .flush_de(flush_de),
    .pc_out(pc_out)
);

//instantiate the imem
Instruction_Memory_Block #(
    .IMEM_DEPTH(256),          // Depth of instruction memory
    .INIT_FILE("/home/dlsconnect/Documents/SFSU_2020_2025/SeniorProject_RISC_V/RISC_V/src/Instructions_Folder/imem.hex")     // Initialization file for instruction memory
) int_imem(
    .PC_f(pc_f),
    .imem_read_en(imem_read_en), // Added missing connection
    .Instruction_f(instr_f)
);

//internal wires
always @(posedge clk) begin
    pc_f <= (rst) ? 32'h0000_0000 : pc_out; // Reset PC to 0 on reset signal
end
endmodule