module FE_DE (
    input logic clk,
    input logic reset,
    input logic pipe_flush,
    
    // Signals from Fetch Stage
    input logic [31:0] instr_f,
    input logic [31:0] pc_f,
    
    // Signals to Decode Stage
    output logic [31:0] instr_d,
    output logic [31:0] pc_d
);
    
    always_ff @(posedge clk) begin
        if (reset || pipe_flush) begin
            instr_d <= 32'b0;
            pc_d <= 32'b0;
        end else begin
            instr_d <= instr_f;
            pc_d <= pc_f;
        end
    end
endmodule