module EX_MEM(
    input logic clk,
    input logic reset,

    // Signals from Execute Stage
    input logic [31:0] execute_out_e, 
    input logic [4:0] reg_write_addr_e,
    input logic reg_write_en_e,
    input logic dmem_read_en_e,
    input logic dmem_write_en_e,
    input logic reg_writedata_sel_e,
    input logic [31:0] reg_readdata2_e,

    // Signals for Memory Stage
    output logic [31:0] execute_out_m, 
    output logic [4:0] reg_write_addr_m,
    output logic reg_write_en_m,
    output logic dmem_read_en_m,
    output logic dmem_write_en_m,
    output logic reg_writedata_sel_m,
    output logic [31:0] reg_readdata2_m

);

always_ff @(posedge clk) begin
    if (reset) begin
        // Reset all outputs to zero
        execute_out_m <= 32'b0;
        reg_write_addr_m <= 5'b0;
        reg_write_en_m <= 1'b0;
        dmem_read_en_m <= 1'b0;
        dmem_write_en_m <= 1'b0;
        reg_writedata_sel_m <= 1'b0;
        reg_readdata2_m <= 32'b0;
    end else begin
        // Pass inputs to outputs
        execute_out_m <= execute_out_e;
        reg_write_addr_m <= reg_write_addr_e;
        reg_write_en_m <= reg_write_en_e;
        dmem_read_en_m <= dmem_read_en_e;
        dmem_write_en_m <= dmem_write_en_e;
        reg_writedata_sel_m <= reg_writedata_sel_e;
        reg_readdata2_m <= reg_readdata2_e;
    end
end

endmodule