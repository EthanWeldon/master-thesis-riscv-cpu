module MEM_WB(
    input logic clk,
    input logic reset,

    // Signals from Memory Stage
    input logic [31:0] dmem_readdata_m,
    input logic [31:0] execute_out_m, 
    input logic [4:0] reg_write_addr_m,
    input logic reg_write_en_m,
    input logic reg_writedata_sel_m,


    // Signals for Write Back Stage
    output logic [31:0] dmem_readdata_w,
    output logic [31:0] execute_out_w, 
    output logic [4:0] reg_write_addr_w,
    output logic reg_write_en_w,
    output logic reg_writedata_sel_w
);


always_ff @(posedge clk) begin
    if (reset) begin
        // Reset all outputs to zero
        dmem_readdata_w <= 32'b0;
        execute_out_w <= 32'b0;
        reg_write_addr_w <= 5'b0;
        reg_write_en_w <= 1'b0;
        reg_writedata_sel_w <= 1'b0;
    end else begin
        // Pass inputs to outputs
        dmem_readdata_w <= dmem_readdata_m;
        execute_out_w <= execute_out_m;
        reg_write_addr_w <= reg_write_addr_m;
        reg_write_en_w <= reg_write_en_m;
        reg_writedata_sel_w <= reg_writedata_sel_m;
    end
end

endmodule